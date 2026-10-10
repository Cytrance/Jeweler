# Modern market art guide

## Current direction

### Style refinement: cute, cosy pixel-art direction

The project manager accepted the modern setting but requested a cutesier, more cohesive pixel-art style. The supplied environmental reference guides mood and rendering, not historical architecture: warm peach/gold light, muted pastels, textured paving and foliage, soft dark outlines, and charming rounded forms.

- Keep the contemporary market, folding table, payment device, and casual clothing. Do not transplant the reference's pagoda or historical setting.
- Prefer a broader chibi founder around 2.5 heads tall over the current tall, narrow figure. Maintain readability around the established 96-game-pixel display height; review actual head, body, and stall proportions together.
- Use dusty teal, warm cream, peach, sage, and muted plum/brown shadows as a provisional shared palette. Avoid a richly shaded character against unrelated flat vector scenery.
- Use consistent pixel clusters and perspective across characters, stalls, pavement, and foliage. Soft lighting must not erase readable edges or walkable space.
- Review one combined style concept first. It is visual direction, not a playable level, collision map, animation sheet, or evidence of a native pixel grid.
- After concept approval, define a common source grid, display scale, transparent padding, and sprite origins before producing individual assets. Match shadows and lighting direction across assets; do not independently downscale mismatched generated illustrations and call them a consistent tileset.

The current in-game founder and geometric market remain provisional until the separate asset-refinement work is reviewed. The style concept does not change game code or gameplay.

The proposed [combined market concept](concepts/modern-market-style-v1.png) shows the warmer palette, chibi founder, cloth stall, plants, and textured plaza together. Project-manager style approval is pending. It establishes a visual target, not the starting stock quantity or the cost of decorative surroundings; the actual starter stall should remain modest and use imitation goods. Produce separate grounded assets after approval rather than using this entire illustration as an interactive map.

Present-day, friendly 2D jewellery-business RPG. The starting location is a modest market pop-up, not a medieval workshop. The [game-design brief](game-design.md) governs the setting and player progression. The modern founder is generated and awaiting project-manager review in the combined market scene.

- Founder: casual contemporary clothing, sneakers, optional utility apron or crossbody pouch. Keep the person approachable; no fantasy tunic, leather bracers, or adventurer accessories.
- Stall: folding table, jewellery trays, modest price cards, stock boxes, simple fabric cover, and a small card-payment device. No luxury-brand logos. The initial supplier offers imitation goods.
- Surroundings: recognisable market pavement and neighbouring stall silhouettes, with a restrained readable palette. Keep routes and interaction targets clear.
- Readability target: founder roughly 96 game pixels tall at the initial view. Check stall height against the person; a tabletop should feel waist-height in the chosen perspective. Do not mechanically reuse the workshop obstacle's proportions as a modern folding table.
- Separate visual height from foot collision geometry. Define the stall's visual and solid footprints explicitly before integration.
- Begin with one static founder frame facing down. Animation is a later assignment. Preserve transparent padding, full framing, clear outlines, and aspect ratio.
- Generate source images to a documented brief; inspect real resolution, alpha, and framing. Prefer artwork designed for the final display size. A large illustration scaled down is not automatically pixel-grid-consistent art.
- Record palette, source dimensions, display dimensions, crop, filenames, and provenance at each handoff. Review the combined scene at normal gameplay size rather than approving isolated asset previews alone.

## Modern founder asset handoff

`jewel-rpg/assets/player/founder_idle_front.png` is a generated **1144 × 1375 RGBA PNG** with short brown hair, a teal T-shirt, navy jeans, white sneakers, and a plain tan crossbody pouch. Teal, navy, warm brown, tan, white, and dark outlines form the provisional palette. It is one static front-facing frame. The chunky pixel-like illustration is not a native low-resolution pixel sprite; future animation requires a separate agreed grid and frame specification.

Read-only inspection found alpha from 0 to 255 and alpha 0 at all four corners. Strict nonzero-alpha bounds are `(47, 54, 1062, 1336)`; faint residue extends beyond the visible figure. At alpha ≥16, bounds are `(325, 57, 803, 1332)`, measuring 478 × 1275 source pixels. Hair and both shoes are fully framed.

For `Sprite2D`, use nearest-neighbor filtering, region `Rect2(325, 57, 478, 1275)`, and uniform scale `96.0 / 1275.0` (about `0.07529412`). The displayed figure is approximately 35.99 × 96 game pixels. With centered sprite offset `(0, -24)`, its bottom reaches the existing player collider's lower edge at local y=24. The coding agent owns final scene placement and import settings. No image pixels were edited; the region is an engine display setting.

The region excludes distant alpha residue but cannot guarantee a perfectly clean fringe. Review readability, hair/shoe framing, relative stall scale, and transparency against the actual market background at gameplay size. Automated import checks do not approve visual quality. Provenance is recorded in [asset origins](asset-origins.md).

The following sections document the historical prototype asset for maintenance. Its fantasy clothing is superseded by the modern founder in the visual-reset branch; the old source may remain as historical reference.

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
