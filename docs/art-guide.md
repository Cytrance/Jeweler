# Provisional player art guide

This first asset demonstrates the sprite-agent handoff. Its appearance is pending project-manager approval; it does not establish a finished game art style.

## Brief

- One original friendly jeweler apprentice, standing still and facing down toward the viewer.
- Warm brown hair, teal tunic, ochre apron, brown boots, turquoise gem accessory.
- Restrained colors and dark outlines; readable in a top-down 2D game.
- One frame only. No walking animation or directional changes.
- Revised readability target: 96 game pixels tall, preserving proportions (about 37.46 pixels wide). The first 48-pixel-tall integration was too small in the project manager's playtest.

## Delivered asset

`jewel-rpg/assets/player/jeweler_idle_front.png` is a **1024 × 1536 RGBA source image**, not a native 32 × 48 pixel-art sprite. It was generated and then edited using the image-generation tool to improve exterior transparency. No separate pixel-processing edit was performed.

Inspection found alpha values from 0 to 254. Transparent exterior samples and all four corners have alpha 0, but faint low-alpha residue remains: the strict nonzero-alpha bounding box is `(49, 69, 1016, 1514)` in left/top/right/bottom coordinates. At alpha ≥16 the bounds are `(251, 121, 759, 1423)`. A further image-tool edit corrected clipped hair and boots; both are now fully visible with transparent padding. The source has more detail and taller proportions than the original low-resolution brief.

## Godot handoff

Use a `Sprite2D` with nearest-neighbor texture filtering and one frame. Keep the PNG unchanged. A region of `Rect2(251, 121, 508, 1302)` excludes most faint exterior residue; it does not guarantee a completely clean alpha mask. A uniform scale of `96.0 / 1302.0` (about `0.07373272`) displays this region at about 37.46 × 96 game pixels without stretching. Offset the visual by `(0, -24)` relative to the player so its lower edge remains at the bottom of the existing 32 × 48 collider. The visual extends above and slightly to either side of that collider; collision geometry and visual size have separate responsibilities.

The coding agent owns the actual scene positioning and import settings. Visual playtesting must check readability, centering, fringe visibility, and hair/boot framing on the game's background. Automated import checks cannot approve the artwork's appearance.

## Future assets

Agree on native pixel dimensions, palette, direction count, frame count, and framing before requesting an animation sheet. This illustration is not animation-ready and should not be treated as a consistent sprite-sheet template without further review.
