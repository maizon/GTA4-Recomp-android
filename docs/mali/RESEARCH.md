# Research log — Mali-G57 adaptation

**Date:** 2026-10-13. This is a source/documentation review; no physical Mali test has been run.

## References

| Project/reference | Version or ref inspected | Relevant finding | Decision |
|---|---|---|---|
| [maizon/GTA4-Recomp-android](https://github.com/maizon/GTA4-Recomp-android) | `main` source files | Android build is split between native CMake scripts and Gradle packaging; launcher supports system Vulkan driver; performance cvars already exist. | Preserve architecture and build baseline first. |
| [vaduur/LibertyRecompAndroid](https://github.com/vaduur/LibertyRecompAndroid) | README/build scripts in the fork | README says Mali is unsupported and describes Turnip-tuned renderer; Android build scripts are Windows/Git Bash oriented. | Do not claim Mali support without testing. |
| [ArkSentinel/LibertyRecompAndroid](https://github.com/ArkSentinel/LibertyRecompAndroid) | User-provided experimental Mali fork and release reference | Reported experimental Mali work includes shader compatibility and BCn texture conversion. Exact patch applicability to this fork and G57 MC2 is not yet verified here. | Investigate individual patches by commit/diff; do not bulk-copy or apply unreviewed transforms. |
| [Vulkan specification](https://registry.khronos.org/vulkan/specs/1.3-extensions/html/) | Public API reference | Vulkan API version alone does not prove support for each extension, format or feature. | Query physical-device features, extensions and format properties at runtime. |
| [Android NDK documentation](https://developer.android.com/ndk) | Official docs | Android native build depends on compatible NDK/toolchain and ABI settings. | Pin toolchain versions in CI. |
| [ARM Mali developer documentation](https://developer.arm.com/Processors/Mali-G57) | GPU family reference | Mali-G57 is a distinct GPU architecture; Adreno/Turnip-specific optimizations must not be assumed portable. | Profile on actual device before GPU-specific changes. |



## Cross-port findings relevant to GTA IV

### References inspected

| Project | Evidence inspected | Relevant finding | Decision for GTA IV |
|---|---|---|---|
| [Buku313/Skate3-Mobile](https://github.com/Buku313/Skate3-Mobile) | main README and technical overview | A separate ReXGlue static-recompilation Android port reports a verified Mali-G57 device (Anbernic RG406V / Unisoc T820). Its handheld profile reduces internal scene resolution, draw/LOD range, material complexity, grass and expensive post effects while retaining full-rate gameplay input, physics and HUD. | Strong reference for a Mali-G57 bring-up checklist and profile methodology. Reuse ideas, not its renderer or game-specific cvars. Confirm the exact GPU/driver/API and CPU requirements on Helio G99. |
| [andrewnakas/skate3-android](https://github.com/andrewnakas/skate3-android) | main README and scripts/perf.sh | Separates native engine/codegen build from Gradle APK packaging; scripts collect frame pacing, memory, thermal diagnostics, logs and symbols. README reports testing on Adreno 730, so its performance numbers are not Mali evidence. | Borrow the measurement workflow concept. Do not copy its Adreno driver proxy or Turnip tooling for Mali. |
| [SansNope/UnleashedRecomp-Android](https://github.com/SansNope/UnleashedRecomp-Android) | main README, CHANGELOG.md and UnleashedRecomp/gpu/video.cpp | README describes experimental system-driver support for recent Mali GPUs and confirms a Dimensity 8300 Ultra / Mali-G615, not Mali-G57. Changelog describes bypassing the bundled Adreno driver on non-Adreno devices, optional Vulkan features/fallbacks, and BC texture transcode to ETC2/EAC with RGBA fallback if needed. Source includes a BC decoder and renderer profiler counters (draw calls, pipeline binds, barriers, frame/fence/present timing). | High-value design reference for capability-based driver selection, texture-format fallback and profiling. Verify GTA IV's formats, SPIR-V and resource usage independently. G615 results do not establish G57 compatibility. |

### What transfers well

- Mali-G57 evidence exists, but on a different device/game: Skate 3 Mobile's docs identify the Anbernic RG406V with Unisoc T820 and Mali-G57 as verified. That is a more directly relevant GPU reference than a G615-only report, but does not prove compatibility with the GTA IV renderer, Helio G99 CPU configuration, or this phone's driver.
- Tune workload before adding driver hacks: Skate 3's handheld profile reduces expensive visual work. GTA IV already has cvars for several similar categories, so measure those before writing new renderer code.
- Instrument frame pacing, not just FPS: Skate 3 Android scripts collect frame pacing, memory and thermal data; Sonic Unleashed's renderer exposes counters/timing for draw calls, pipeline binds, barriers, frame/fence/present waits. GTA IV can adopt equivalent measurement concepts without transplanting the implementation.
- Driver choice must be capability-based: Sonic's changelog says non-Adreno devices should bypass its bundled Adreno driver and use the system driver. GTA IV should likewise use the system driver on Mali and never attempt to load Turnip on Mali.
- Texture fallback should preserve GPU-friendly compression when possible: Sonic transcodes BC formats to ETC2/EAC where supported, retaining a compressed GPU footprint, and falls back to RGBA only if ETC2 is also unavailable. Investigate this before unconditional BC-to-RGBA8 conversion; query format support on the target first.
- Do not transplant game-specific renderers: Skate 3 and Sonic use their own game-specific renderer logic and shader pipelines. Their renderer code, cvars and assumptions are not drop-in replacements for LibertyRecomp's GTA IV renderer.

### Uncertainties to resolve on Helio G99

1. Exact Android build, Vulkan API version, driver version and supported image formats.
2. Whether GTA IV SPIR-V modules and pipeline feature requirements are accepted by the stock Mali driver.
3. Whether BC formats are supported natively; if not, whether this engine can use ETC2/EAC or needs another fallback.
4. Whether the main bottleneck is CPU (world simulation) or GPU (draw/overdraw/shaders), measured by frame time.
5. Whether the actual G99 device driver exposes the required Vulkan API/features. A Mali-G57 label alone is insufficient.

## Current source-level conclusions

1. The app's launcher can select the system Vulkan driver. For a Mali phone, the first test should use that option, not Turnip.
2. The renderer remains Vulkan-only. If the system driver lacks a required feature or Vulkan 1.2 behavior, the correct next step is to capture the exact failing API/feature and evaluate a localized fallback.
3. Existing performance profile arguments can be reused because they are already present in the project. A Mali profile is a conservative starting point, not a claim of measured optimality.
4. The current source does not yet provide evidence that BC1/BC2/BC3 are unsupported on the specific G57 driver. Query formats before converting textures; CPU decode to RGBA8 can substantially increase memory bandwidth and footprint.
5. ClipDistance/CullDistance changes must preserve shader semantics. No blanket removal should be merged without shader-level reproduction and image comparison.
6. Adreno LRZ optimizations are not a valid assumption for Mali. Preserve generic Vulkan depth behavior unless profiling and device documentation justify a specific change.

## Reuse policy

For every patch imported from another project, record the exact upstream URL, immutable commit SHA, affected files, license, semantic effect, test, and measured result. Until that information is recorded, the patch remains a research candidate and is not part of the implementation.
