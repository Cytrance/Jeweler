# Modern market art guide

## Current direction

Present-day, friendly 2D jewellery-business RPG. The starting location is a modest market pop-up, not a medieval workshop. The [game-design brief](game-design.md) governs the setting and player progression. New artwork is pending generation and project-manager review.

- Founder: casual contemporary clothing, sneakers, optional utility apron or crossbody pouch. Keep the person approachable; no fantasy tunic, leather bracers, or adventurer accessories.
- Stall: folding table, jewellery trays, modest price cards, stock boxes, simple fabric cover, and a small card-payment device. No luxury-brand logos. The initial supplier offers imitation goods.
- Surroundings: recognisable market pavement and neighbouring stall silhouettes, with a restrained readable palette. Keep routes and interaction targets clear.
- Readability target: founder roughly 96 game pixels tall at the initial view. Check stall height against the person; a tabletop should feel waist-height in the chosen perspective. Do not mechanically reuse the workshop obstacle's proportions as a modern folding table.
- Separate visual height from foot collision geometry. Define the stall's visual and solid footprints explicitly before integration.
- Begin with one static founder frame facing down. Animation is a later assignment. Preserve transparent padding, full framing, clear outlines, and aspect ratio.
- Generate source images to a documented brief; inspect real resolution, alpha, and framing. Prefer artwork designed for the final display size. A large illustration scaled down is not automatically pixel-grid-consistent art.
- Record palette, source dimensions, display dimensions, crop, filenames, and provenance at each handoff. Review the combined scene at normal gameplay size rather than approving isolated asset previews alone.

The following sections document the existing prototype asset for maintenance. Its fantasy clothing is superseded as the intended game direction; the file is still used by the current code until the separate visual-reset milestone.

## Historical prototype

This first asset demonstrated the sprite-agent handoff and was merged after the project manager's scale feedback. It does not establish the modern game's final art style.

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
