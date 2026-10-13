# Initial audit — Mali-G57 / Helio G99

**Audit date:** 2026-10-13  
**Repository:** `maizon/GTA4-Recomp-android`  
**Audited ref:** `main` at the time of inspection  
**Status:** source inspection only; no APK build or physical-device run has been executed by this audit.

## Facts confirmed from source

- The Android app is under `os/android/`; the native game/runtime is configured from the top-level CMake project.
- Android packaging uses Gradle Kotlin DSL at `os/android/app/build.gradle.kts`. The native build is performed separately by `os/android/scripts/build_native.sh`, which stages libraries into `app/src/main/jniLibs/arm64-v8a`.
- The documented build is designed for Windows + Git Bash, Python 3.12, CMake 3.29+, Ninja, Java 17+, Android SDK platform 35 and NDK `29.0.14206865`. The host shader-tool script downloads Windows DXC and glslang binaries.
- The native build uses `-march=armv8.2-a -fno-emulated-tls`. This matches the Helio G99 Cortex-A76/A55 class, but the project README also describes ARMv8.2/LSE as a requirement; broader device support is not established by this audit.
- The default launcher driver mode is Turnip. The launcher offers a system-driver mode; `LibertyActivity.loadLibraries()` calls `DriverBridge.initialize()` before loading the game libraries and writes `last_launch.txt`.
- `os/android/native/CMakeLists.txt` builds a Vulkan proxy and links `libadrenotools`. This is a driver-selection bridge, not evidence that Turnip supports Mali. On Mali, testing must explicitly select the Android system driver.
- The app is Vulkan-only; `AndroidManifest.xml` declares Vulkan 1.1 as a required feature. The runtime/README documents a Vulkan 1.2 requirement. The actual device's Vulkan API, extensions, formats and driver behavior must be queried at runtime.
- The README explicitly states ARM Mali/Immortalis GPUs are unsupported by the upstream Android port. This makes Mali support experimental until a real Mali device has passed functional tests.
- The existing `os/android/android_args/perf.txt` already contains recognized renderer cvars for FSR1, FXAA, dynamic draw distance, shadow settings, reflections, frame limiting and reduced traffic/pedestrian density. The profile is documented as tuned for Snapdragon 865 / Adreno 650; its performance claims cannot be transferred to Mali without measurement.
- `CMakeLists.txt` supports Android runtime asset installation, so the build does not need to package proprietary GTA IV files. The project must not upload game payloads to CI artifacts.

## Important unknowns

- No Helio G99/Mali-G57 device was connected to this audit, so the installed Android version, Vulkan driver version/API, format support, memory budget and thermal behavior are unknown.
- The repository could not be compiled or run in this assistant session; the GitHub Actions workflow is intended to provide a reproducible build attempt. Its first run must be inspected before calling the build validated.
- No Mali-specific SPIR-V or BCn conversion patch has been accepted yet. Such patches must be applied only after reproducing a concrete shader/format failure and testing visual correctness.
- No FPS, frame-time, memory, temperature or stability results are available.
- No evidence yet establishes that every Turnip/Adreno optimization is portable to Mali. In particular, do not port Adreno LRZ assumptions to Mali.

## Build flow mapped from source

1. `python tools/setup_repo.py` — initialize pinned dependencies and reapply reviewed dependency patches.
2. `bash os/android/scripts/build_driver_proxy.sh` — build and stage the Vulkan proxy/hook libraries.
3. `bash os/android/scripts/build_native.sh` — prepare host shader tools, configure CMake for Android ARM64, compile native runtime and stage libraries/resources.
4. `bash os/android/scripts/build_apk.sh debug` — package the staged files using Gradle.
5. Install and launch on a real device, selecting **System** as the Vulkan driver on Mali; inspect `last_launch.txt`, logcat and visual/gameplay behavior.

## Immediate safe actions

- Keep Mali changes on a dedicated branch and preserve `main`.
- Build an APK without game assets on CI, and archive logs even on failure.
- Start from the existing recognized performance cvars rather than inventing new arguments.
- Treat successful compilation as build validation only, not proof of Vulkan compatibility or gameplay.
- Do not merge driver, shader or texture fallbacks without device evidence and regression checks.
