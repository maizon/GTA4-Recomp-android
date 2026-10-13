# Vulkan compatibility plan

## Current source facts

The app is Vulkan-only. The native Android launcher/bridge supports selecting the system Vulkan loader; Mali validation must use that mode. The bridge's existence and a successful startup probe do not prove that every game pipeline or shader is supported.

## Required checks

- Enumerate instance version and instance extensions before enabling them.
- Create the instance using a supported API version.
- Enumerate physical devices and query device properties, features, extension availability, queue families and presentation support.
- Enable only features/extensions that were queried and are required by the selected path.
- Query each texture/render-target format with `vkGetPhysicalDeviceFormatProperties` and, where relevant, `vkGetPhysicalDeviceImageFormatProperties`.
- Check image usage, tiling, sample count, memory type and alignment limits before allocating resources.
- Confirm swapchain surface capabilities, formats, present modes and queue support.
- Capture the exact failing Vulkan call/result when instance, device, pipeline, image or swapchain creation fails.

## Fallback policy

Do not disable validation wholesale. Do not infer support from Vulkan version alone. Introduce a fallback only for a reproducible missing capability and preserve the renderer's intended semantics. Driver-specific workarounds must be scoped by observed capability/driver conditions and include a regression test.

## Acceptance gate

A successful APK build is not Vulkan validation. The Vulkan stage remains **not tested** until the system driver has initialized the game, created the swapchain and rendered a real in-game scene on a Mali-G57 device with logs showing no fatal Vulkan errors.
