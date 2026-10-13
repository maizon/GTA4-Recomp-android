# Known issues and validation blockers

- Mali/Immortalis is unsupported by the upstream Android README; G57 MC2 compatibility remains unvalidated.
- The launcher defaults to Turnip. Select the system driver for Mali; Turnip is an Adreno driver.
- No physical Helio G99 device was available for this audit.
- No APK build result is available until the GitHub Actions run completes and its logs are inspected.
- No Mali-specific shader transformation has been verified.
- BC1/BC2/BC3 support must be queried on the actual driver before conversion is considered.
- No FPS/frame-time/memory/thermal benchmark data is available.
- The upstream Android build scripts are designed for Windows + Git Bash and download Windows shader tools; portability to Linux/macOS is not established here.
- CI debug signing keys are ephemeral; installing APKs from different runs may require uninstalling the previous app and can remove app data. Back up saves before replacing builds.
