# Texture format compatibility

## Status

No texture conversion has been enabled by default. The Mali-G57 device/driver format support is unknown until queried.

## Required investigation

- Inventory source and GPU formats, including BC1/DXT1, BC2/DXT3 and BC3/DXT5 where used.
- Query sampled-image, filtering, transfer and render-target support for each exact format.
- Separate compressed source format from GPU storage format and swapchain presentation format.
- Reproduce unsupported format failures before adding a fallback.

## Conversion policy

If BCn is not supported for a required sampled-image use, use a tested decoder or proven library and cache the decoded result. Verify alpha, channel order, partial blocks, mip levels, sRGB handling and filtering. RGBA8 can multiply texture storage substantially compared with 4-bit-per-pixel BC formats; account for memory, transfer and cache costs.

Add golden-image tests for known BC1/BC2/BC3 blocks. Do not swap R/B channels as an unverified workaround. Do not convert all textures unconditionally if the device supports the original format.
