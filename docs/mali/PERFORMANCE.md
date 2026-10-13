# Performance plan — Mali-G57 MC2

## Principle

Establish a working baseline before optimizing. There are currently no measured Helio G99 FPS or frame-time results in this repository audit.

## First profile

Use a repeatable scene and record device/Android/driver versions, APK commit/hash, internal resolution, graphics settings, session duration, average FPS, frame-time p50/p95/p99, stutter count, memory and reported thermal state. Compare cold and warmed runs separately.

## Existing settings to reuse

The project already recognizes settings for FSR1, FXAA, draw distance, dynamic draw distance, shadow map size/distance, reflection capture/resolution, frame limit, traffic/pedestrian density, motion blur and queued frames. Start with conservative settings in the Mali profile and tune only from measurements.

## CPU/GPU diagnosis

- Use Perfetto/simpleperf for CPU scheduling, hot functions and blocking where available.
- Use renderer timing and Vulkan timestamp queries only when supported and implemented safely.
- Use vendor GPU counters only when the device permits them.
- A 30 FPS cap means a 33.3 ms nominal frame budget; it does not demonstrate that the game meets it.
- Avoid attributing a slow frame to the GPU without evidence; the render thread, guest CPU, shader/pipeline compilation, storage and synchronization may be limiting.

## Acceptance

Report results only for tests actually executed. A source change stays experimental until correctness tests pass and its before/after performance comparison uses the same device, scene, resolution and warm-up procedure.
