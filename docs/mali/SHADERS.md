# Shader compatibility

## Status

No Mali-specific shader transform has been merged. The experimental Mali fork is a research reference only until exact commits and effects are reviewed.

## Investigation sequence

1. Record the source shader, compiler/tool version, SPIR-V version, stage and validation output.
2. Determine whether failure occurs in compilation, SPIR-V validation, shader-module creation, pipeline creation or execution.
3. Reproduce on the target driver and preserve the complete Vulkan result/log.
4. If ClipDistance/CullDistance is involved, identify the exact instructions, stages and semantic effect before modifying anything.
5. Prefer a localized transformation guarded by a verified capability/driver condition over a blanket rewrite.
6. Validate transformed SPIR-V with compatible SPIRV-Tools and test geometry clipping, silhouettes, shadows and scene transitions.
7. Compare the resulting image against a known-good reference.

Removing clip/cull behavior can change visible geometry; a crash disappearing is not enough to accept a patch.
