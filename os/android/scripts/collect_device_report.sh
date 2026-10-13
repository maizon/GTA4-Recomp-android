#!/usr/bin/env bash
# Collect non-root Android/device diagnostics for the Mali investigation.
# Usage: bash os/android/scripts/collect_device_report.sh [output-directory]
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/env.sh"

if ! command -v adb >/dev/null 2>&1; then
  echo "adb is not available on PATH" >&2
  exit 1
fi
if [ -z "${SERIAL:-}" ]; then
  echo "No single authorized ADB device found. Connect exactly one device or set SERIAL." >&2
  adb devices -l >&2 || true
  exit 2
fi
if ! adbs get-state >/dev/null 2>&1; then
  echo "ADB device $SERIAL is not ready/authorized." >&2
  exit 2
fi

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT="${1:-$REPO/out/device-report-$STAMP}"
mkdir -p "$OUT"
REPORT="$OUT/device_report.txt"

{
  echo "GTA IV Recomp Android device report"
  echo "Collected UTC: $STAMP"
  echo "ADB serial: $SERIAL"
  echo "Collection scope: non-root Android properties and system diagnostics"
  echo "This is not a complete Vulkan feature/format query."
  echo
  for key in \
    ro.product.manufacturer \
    ro.product.model \
    ro.product.device \
    ro.soc.manufacturer \
    ro.soc.model \
    ro.hardware \
    ro.board.platform \
    ro.build.version.release \
    ro.build.version.sdk \
    ro.build.fingerprint \
    ro.product.cpu.abi \
    ro.product.cpu.abilist64; do
    printf '%s=' "$key"
    adbs shell getprop "$key" 2>&1 | tr -d '\r'
  done
  echo
  echo "=== Display size ==="
  adbs shell wm size 2>&1 | tr -d '\r' || true
  echo "=== Display density ==="
  adbs shell wm density 2>&1 | tr -d '\r' || true
  echo "=== Vulkan-related properties (if exposed) ==="
  adbs shell getprop 2>&1 | tr -d '\r' | grep -iE 'vulkan|gpu|gles|graphics' || true
  echo "=== SurfaceFlinger ==="
  adbs shell dumpsys SurfaceFlinger 2>&1 | tr -d '\r' || true
  echo "=== /proc/meminfo ==="
  adbs shell cat /proc/meminfo 2>&1 | tr -d '\r' || true
  echo "=== App memory (com.libertyrecomp) ==="
  adbs shell dumpsys meminfo com.libertyrecomp 2>&1 | tr -d '\r' || true
} > "$REPORT"

# Keep the raw log separate; it is useful for driver initialization failures.
adbs logcat -d -s LibertyDriver LibertyRecomp LibertyLauncher SDL 2>&1 | tr -d '\r' > "$OUT/graphics_logcat.txt" || true
{
  echo "Report directory: $OUT"
  echo "Device report: $REPORT"
  echo "Graphics logcat: $OUT/graphics_logcat.txt"
  echo "No root access was requested. Missing properties are not proof of missing features."
} | tee "$OUT/README.txt"

echo "Diagnostics collected. Review before sharing: logs can include device/build details."
