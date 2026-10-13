# Reproducible Android build

## Automated build

The workflow `.github/workflows/android-apk.yml` builds the Android ARM64 debug APK on a Windows runner because the existing scripts explicitly rely on Git Bash and Windows DXC/glslang host binaries.

Trigger it from GitHub Actions with **Run workflow**, or push a change affecting the workflow/build paths. The workflow uploads the APK, SHA-256 checksum and build log as an artifact when available. The first run must be checked for success/failure; the presence of a workflow file is not proof that the build succeeded.

## Pinned toolchain

- Python 3.12
- Java 17
- Android SDK platform 35
- Android NDK 29.0.14206865
- CMake 3.31.x
- Ninja
- Project-managed pinned submodules/dependency patches

## Manual commands (Git Bash on Windows)

```bash
python tools/setup_repo.py
bash os/android/scripts/build_driver_proxy.sh
STRIP=1 BUILD_TYPE=RelWithDebInfo bash os/android/scripts/build_native.sh
rm -f os/android/app/build/outputs/apk/debug/app-debug.apk
bash os/android/scripts/build_apk.sh debug
```

Expected output: `os/android/app/build/outputs/apk/debug/app-debug.apk`.

The build uses runtime game asset installation and must not package, publish or upload proprietary game images, title updates or extracted game assets. Only the APK and build diagnostics belong in CI artifacts.

## Validation boundaries

CI compilation checks the build/package path and ARM64 native libraries. It does not run the game on a Mali device and cannot establish Vulkan compatibility, visual correctness, audio/input/save behavior, stable frame times or thermal performance.
