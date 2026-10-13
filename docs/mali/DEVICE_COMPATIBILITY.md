# Device compatibility — Helio G99 / Mali-G57 MC2

## Target

- SoC: MediaTek Helio G99.
- CPU: 2x Cortex-A76 plus 6x Cortex-A55.
- GPU: ARM Mali-G57 MC2.
- Android: ARM64; actual Android/API/driver versions vary by device.

## Current status

**Experimental / not validated on physical hardware.** No device diagnostics were available during this audit. Do not infer Vulkan API level or format support from the GPU name.

## Collect device facts

Connect the phone with USB debugging enabled, authorize ADB, and run:

```sh
adb devices
adb shell getprop ro.product.model
adb shell getprop ro.build.version.release
adb shell getprop ro.build.version.sdk
adb shell getprop ro.product.cpu.abi
adb shell getprop ro.hardware
adb shell dumpsys SurfaceFlinger
adb shell cat /proc/meminfo
adb shell dumpsys meminfo com.libertyrecomp
adb logcat -d -s LibertyDriver LibertyRecomp LibertyLauncher
```

Some fields may be absent or access-restricted on a given Android build. Missing properties are not proof of missing hardware capability.

## Vulkan report requirements

The diagnostic should capture the physical device name/vendor/device IDs, API and driver versions, driver name/info where exposed, device and instance extensions, core/optional features, queue families and presentation support, surface formats/modes, image format properties, sampled/storage/attachment support, memory heaps/types and shader-related failures. Record the exact Vulkan result code for each failed operation.

The launcher writes `Android/data/com.libertyrecomp/files/last_launch.txt`; copy it with the app's share/report flow or ADB when available. It currently helps identify device/driver selection but is not a full physical-device capability dump.

## Mali launch procedure

1. Install the CI APK.
2. Open the launcher and select the **system** Vulkan driver.
3. Start with default settings, then collect the launch report and logcat.
4. Confirm that a game scene actually renders before changing graphics settings.
5. Test input, audio, save/load, pause/resume and a sustained session.
6. Only after correctness is established, test the profile in `os/android/android_args/mali-g57-g99.txt`.

Do not use Turnip on Mali. Do not root the device or modify its driver/kernel.
