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

## Current source-level conclusions

1. The app's launcher can select the system Vulkan driver. For a Mali phone, the first test should use that option, not Turnip.
2. The renderer remains Vulkan-only. If the system driver lacks a required feature or Vulkan 1.2 behavior, the correct next step is to capture the exact failing API/feature and evaluate a localized fallback.
3. Existing performance profile arguments can be reused because they are already present in the project. A Mali profile is a conservative starting point, not a claim of measured optimality.
4. The current source does not yet provide evidence that BC1/BC2/BC3 are unsupported on the specific G57 driver. Query formats before converting textures; CPU decode to RGBA8 can substantially increase memory bandwidth and footprint.
5. ClipDistance/CullDistance changes must preserve shader semantics. No blanket removal should be merged without shader-level reproduction and image comparison.
6. Adreno LRZ optimizations are not a valid assumption for Mali. Preserve generic Vulkan depth behavior unless profiling and device documentation justify a specific change.

## Reuse policy

For every patch imported from another project, record the exact upstream URL, immutable commit SHA, affected files, license, semantic effect, test, and measured result. Until that information is recorded, the patch remains a research candidate and is not part of the implementation.
