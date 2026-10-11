# Modern market art guide

## Textured cutaway indoor walls

`assets/interiors/interior_walls.png` provides nine original modular pieces: cracked cream drywall, window wall, open doorway wall, a low front-wall section, left/right side-wall sections, two L-shaped corner pieces, and a square corner pillar. Their worn plaster and honey-brown caps/baseboards keep the apartment contemporary and modest. The project manager's indoor reference informed thick visible walls, ledges, and joins; its cathedral masonry and stained glass are not transplanted into this room.

The unchanged source is **1254 × 1254 RGBA**, alpha 0–255, with four transparent corners. Useful bounds at alpha ≥16:

| Piece | AtlasTexture region |
|---|---|
| Plain drywall | `Rect2(36, 81, 370, 366)` |
| Window wall | `Rect2(447, 81, 362, 366)` |
| Open doorway wall | `Rect2(851, 81, 366, 366)` |
| Low front wall | `Rect2(36, 632, 493, 162)` |
| Left side wall | `Rect2(601, 504, 93, 299)` |
| Right side wall | `Rect2(995, 504, 93, 299)` |
| Left L corner | `Rect2(110, 889, 292, 271)` |
| Right L corner | `Rect2(504, 889, 291, 271)` |
| Corner pillar | `Rect2(959, 837, 182, 340)` |

Use explicitly measured regions rather than assuming an evenly spaced sprite grid. The three rear wall panels share a 366-source-pixel height; logical padding can align their differing widths before placing consistent room sections. Lower walls have intentionally different silhouettes and perspectives from full-height rear panels. Use nearest filtering and preserve appropriate cap/body proportions when defining reusable engine templates. Visual caps, blocking boundaries, and passable openings belong to the reusable room shell and should be reviewed together: a pictured doorway alone does not create an exit or remove collision.

The source includes textured caps and corners, so visible room edges need not be represented by plain colour outlines alone. Fine alpha residue and small piece-width differences remain. Exact seamless joins and a common native low-resolution pixel grid are not guaranteed. Godot layout/cropping does not modify source pixels. Integrated wall joins, overlap order, door alignment, and rear-window readability require normal-size gameplay inspection.

The sprite agent inspected an actual **960 × 540** integrated apartment render on 2026-10-11. Textured rear panels, blue window panes, side faces, low foreground wall, and L-shaped front joins visibly enclose the room. Repeated panel seams remain apparent as separate wood-framed modules; this kit is not advertised as seamless plaster. The new lamp, sink, dining table, and floor rug remain recognisable beside the 96-pixel founder and fit the existing worn furniture. This establishes current composition/readability evidence, not collision correctness or the project manager's Windows approval. A HUD/title overlap in that capture was corrected; the root agent inspected a fresh render with the apartment heading clear of the HUD.

## Expanded reusable indoor furniture

`assets/interiors/interior_details.png` adds four original, separate props matching the existing warm worn starter-apartment kit: a faded sage floor rug with peach border, a taller square dining table, a chipped cream sink cabinet, and a standing fabric-shade lamp. These are reusable object illustrations rather than a flattened room. The existing oval low table remains a second table design.

The unchanged source is **1254 × 1254 RGBA**, alpha 0–255, with four fully transparent corners. Measured useful bounds at alpha ≥16 supply these engine regions:

| Prop | AtlasTexture region | Uniform gameplay display size |
|---|---|---|
| Floor rug | `Rect2(32, 158, 707, 322)` | 140 × 63.76 |
| Dining table | `Rect2(768, 108, 442, 371)` | 100 × 83.94 |
| Sink cabinet | `Rect2(83, 623, 713, 532)` | 150 × 111.92 |
| Standing lamp | `Rect2(884, 541, 280, 631)` | 55.47 × 125 |

Preserve aspect ratios with nearest filtering. Furniture visuals use their lower edge as ground contact; collision should cover the grounded footprint rather than the entire tall drawing. The rug is flat floor decoration with no collision. The lamp's warm shade is painted illumination, not dynamic lighting. Sink, table, and lamp are decoration at this milestone, without invented interaction behavior. Fine alpha residue remains outside measured useful contours; these bounds reduce it without certifying clean native-pixel edges. Source metadata and alpha inspection were read-only, with no source pixel edits. Actual room composition, clear walking routes, and gameplay-size appearance must be checked after integration.

## Reusable starter-apartment art

The apartment kit follows the approved warm, cute market direction while showing limited capital: a stained sage blanket, scuffed thrift furniture, an old television, a cheap computer, chipped cream door paint, and aged plaster. The room is assembled from separate tile materials and reusable furniture scenes; the artwork is not one flattened room image.

`assets/interiors/apartment_furniture.png` is an unchanged **1254 × 1254 RGBA** source containing five isolated objects. Alpha spans 0–255 and all four corners are transparent. Strict nonzero-alpha bounds are `(0, 16, 1234, 1254)`; bounds at alpha ≥16 are `(109, 21, 1159, 1227)`. Engine regions exclude distant residue but do not certify clean fringes.

| Prop | AtlasTexture region | Suggested display size, preserving proportions |
|---|---|---|
| Single bed | `Rect2(164, 21, 301, 441)` | 130 × 190.47 |
| Television and stand | `Rect2(732, 112, 381, 321)` | 100 × 84.25 |
| Low table | `Rect2(109, 581, 414, 225)` | 100 × 54.35 |
| Computer desk | `Rect2(692, 483, 467, 338)` | 160 × 115.80 |
| Apartment door | `Rect2(193, 849, 238, 378)` | 90 × 142.94 |

Use nearest filtering and uniform scaling, with the visual's lower edge anchored at the prop's ground-contact root. Collision belongs to the reusable Godot scene: a furniture footprint must block the grounded body without turning the entire tall illustration into an invisible wall. Door and computer interaction proximity should remain separate from physical collision. The computer is attached to this desk artwork; it is not a separate movable monitor asset. Bed, table, television, computer desk, and door can be reused in later indoor scenes; they do not provide alternate rotations or animation.

`assets/interiors/apartment_surfaces.png` is an unchanged opaque **1254 × 1254 RGB** material atlas. Its left half, `Rect2(0, 0, 627, 1254)`, supplies worn honey-brown floor planks; its right half, `Rect2(627, 0, 627, 1254)`, supplies muted sage plaster. Each half can be treated as two **627 × 627** source tile variants, uniformly scaled to a **32 × 32 game-pixel** grid. Baseboard geometry and wall collision are authored in the room scene, rather than baked into furniture art. Generation requested seamless repetition, but exact edge matching is not certified; inspect repeated edges and recurring marks in the integrated room.

These are textured high-resolution pixel-style illustrations, not a shared native low-resolution pixel grid. Source framing and alpha inspection were read-only; no PNG pixels were edited. Review furniture readability against the 96-pixel founder, wall/floor repetition, foot alignment, and drawing order at the actual 960 × 540 gameplay view. Art-source inspection does not replace the project manager's room playtest.

The sprite agent inspected an actual **960 × 540** starter-apartment render on 2026-10-11 after integration. The worn blanket, television, keyboard, desk drawers, chipped door, and low table remain recognisable beside the founder; displayed proportions and warm muted colours fit the brief. Repeated floor tiles show recurring small marks, but no conspicuous hard seams were apparent in this capture. This verifies the starting room's visible composition only; it does not establish collision behavior, every possible prop arrangement, or the project manager's Windows approval.

## Reusable market customers

`assets/customers/customer_sheet.png` supplies four original static, front-facing customer figures: Mina in sage with a tote, Jo in a navy blazer and glasses, Noor in a purple hoodie, and Bea in a pink cardigan with silver hair. Their contemporary clothing and warm chibi rendering follow the approved market concept and founder. These are idle poses for a reusable customer actor; movement between arrival and service points can use scene transforms. The sheet does not provide walking animation or other directions.

The unchanged source is **1199 × 1312 RGBA**. Alpha spans 0–255; strict nonzero-alpha bounds are `(0, 40, 1144, 1312)`. Three corners are fully transparent; the bottom-left has alpha 1. Cropping at the measured alpha ≥16 bounds excludes distant residue, without guaranteeing a perfectly clean fringe.

| Customer | Full-body region | Head/neck portrait region | Logical top padding |
|---|---|---|---|
| Mina | `Rect2(225, 45, 341, 599)` | `Rect2(225, 45, 341, 280)` | 13 |
| Jo | `Rect2(662, 47, 282, 598)` | `Rect2(662, 47, 282, 280)` | 14 |
| Noor | `Rect2(257, 663, 285, 612)` | `Rect2(257, 663, 285, 280)` | 0 |
| Bea | `Rect2(649, 670, 300, 605)` | `Rect2(649, 670, 300, 280)` | 7 |

For full-body `AtlasTexture` frames, use a common **360 × 612 logical canvas**. Set `margin.position` to `((360 - region_width) / 2, 612 - region_height)` and `margin.size` to `(360 - region_width, 612 - region_height)`. Uniform scale **`96.0 / 612.0`** preserves proportions and gives visible heights about 94–96 game pixels while aligning all feet to the same logical lower edge. A centred visual at local `(0, -48)` places that lower edge at a customer root defined as ground contact. The coding agent owns actor placement and scene resources. Portraits should preserve proportions in their UI rectangle rather than stretch to fill it.

Source inspection confirms full hair, hands, and shoes are framed. The generated figures have small height differences, fine edge residue, and subtle age/skin-tone distinctions; their clothing provides the strongest identity at gameplay size. They are high-resolution pixel-style illustrations with noninteger display scaling, not a shared native low-resolution pixel grid. Review the actual actors and portraits against the founder, scenery, and interface at normal gameplay size; source inspection does not establish integrated visual approval.

## Current direction

### Approved style: cute, cosy pixel-art direction

The project manager accepted the modern setting but requested a cutesier, more cohesive pixel-art style. The supplied environmental reference guides mood and rendering, not historical architecture: warm peach/gold light, muted pastels, textured paving and foliage, soft dark outlines, and charming rounded forms.

- Keep the contemporary market, folding table, payment device, and casual clothing. Do not transplant the reference's pagoda or historical setting.
- Prefer a broader chibi founder around 2.5 heads tall over the initial tall, narrow figure. Maintain readability around the established 96-game-pixel display height; review actual head, body, and stall proportions together.
- Use dusty teal, warm cream, peach, sage, and muted plum/brown shadows as a provisional shared palette. Avoid a richly shaded character against unrelated flat vector scenery.
- Use consistent pixel clusters and perspective across characters, stalls, pavement, and foliage. Soft lighting must not erase readable edges or walkable space.
- Review one combined style concept first. It is visual direction, not a playable level, collision map, animation sheet, or evidence of a native pixel grid.
- After concept approval, define a common source grid, display scale, transparent padding, and sprite origins before producing individual assets. Match shadows and lighting direction across assets; do not independently downscale mismatched generated illustrations and call them a consistent tileset.

The initial modern founder and geometric market were playtested for the setting on Windows. The project manager then approved a cosier combined concept. The reusable plaza kit was subsequently playtested and merged. The tree and lamp checkpoint was also tested and merged. New animation still requires its own Windows appearance check. Concept approval is not approval of every delivered asset.

The project manager approved the [combined market concept](concepts/modern-market-style-v1.png) on 2026-10-11 as the ongoing art direction: warmer palette, chibi founder, cloth stall, plants, and textured plaza together. It establishes a visual target, not the starting stock quantity or the cost of decorative surroundings; the actual starter stall should remain modest and use imitation goods. Produce separate grounded assets matching this direction rather than using this entire illustration as an interactive map. Approval of the concept does not establish that individual playable assets are complete or visually verified.

Present-day, friendly 2D jewellery-business RPG. The starting location is a modest market pop-up, not a medieval workshop. The [game-design brief](game-design.md) governs the setting and player progression. The preceding visual milestone replaced the initial narrow founder and flat geometric scenery with a broader chibi founder and textured market assets. The reusable plaza kit has been playtested and merged; the current milestone adds directional founder animation.

- Founder: casual contemporary clothing, sneakers, optional utility apron or crossbody pouch. Keep the person approachable; no fantasy tunic, leather bracers, or adventurer accessories.
- Stall: folding table, jewellery trays, modest price cards, stock boxes, simple fabric cover, and a small card-payment device. No luxury-brand logos. The initial supplier offers imitation goods.
- Surroundings: recognisable market pavement and neighbouring stall silhouettes, with a restrained readable palette. Keep routes and interaction targets clear.
- Readability target: founder roughly 96 game pixels tall at the initial view. Check stall height against the person; a tabletop should feel waist-height in the chosen perspective. Do not mechanically reuse the workshop obstacle's proportions as a modern folding table.
- Separate visual height from foot collision geometry. Define the stall's visual and solid footprints explicitly before integration.
- The initial static founder is retained as historical source art. Directional animation uses a separate shared-frame handoff. Preserve transparent padding, full framing, clear outlines, and aspect ratio.
- Generate source images to a documented brief; inspect real resolution, alpha, and framing. Prefer artwork designed for the final display size. A large illustration scaled down is not automatically pixel-grid-consistent art.
- Record palette, source dimensions, display dimensions, crop, filenames, and provenance at each handoff. Review the combined scene at normal gameplay size rather than approving isolated asset previews alone.

## Modular asset workflow

The current kit replaces the old fixed plaza image with repeatable paving and separately placed props. `scenes/props/` holds the stall, board, planter, tree, and lamp scenes, including their default physics and interaction nodes. Future artwork should arrive with measured framing, display dimensions, a ground-contact point, and a suggested physical footprint. The coding agent owns collision configuration and verifies it through actual player movement.

A canopy, flower, or transparent margin is not automatically solid. Block the grounded base where a person would collide and allow movement beyond that footprint. Check drawing order from both sides. The board has separate proximity detection and a small solid base: detection range must not become a large invisible wall. Ground paving remains walkable.

`assets/modular/paving.png` is an opaque **1254 × 1254 RGB** source generated on 2026-10-11. The TileSet uses the full source canvas as a cell, and the layer is uniformly scaled so that each cell occupies **192 × 192 game pixels**. Cells are saved in the market scene and editable with Godot's TileMap paint tools. This layout choice does not establish native 192 × 192 source art. The original image is not certified seamless; inspect repeated edges and recurring highlights at actual gameplay size.

`assets/modular/flower_planter.png` is a **1212 × 1298 RGBA** source generated on the same date. Alpha ranges from 0 to 255 and all corners are transparent. Strict nonzero-alpha bounds are `(0, 21, 1198, 1298)`; visible bounds at alpha ≥16 are `(76, 278, 1160, 1135)`. Region `Rect2(76, 278, 1084, 857)` excludes distant residue but does not guarantee a clean fringe. The source is preserved unchanged. The sprite agent suggested a 112-game-pixel display width; final integration uses 110 pixels, producing about 86.96 pixels of height under uniform scaling. The planter is a waist-height flower prop, not a full-size tree. Final scene footprint and rendered checks are recorded in [the modular-plaza walkthrough](modular-plaza.md).

The older environment handoff below describes the preceding visual checkpoint. Its plaza background is retained as historical artwork; it is no longer the playable modular ground. Stall, board, and founder source images continue to be reused.

## Flowering tree and streetlamp handoff

Both source PNGs were generated on 2026-10-11 and preserved unchanged. Crops use the bounds at alpha ≥16; these exclude distant residue but do not certify a perfectly clean fringe. Nearest filtering and uniform scaling retain source proportions. Their noninteger scales and detailed source rendering remain high-resolution pixel-style art rather than an established native pixel grid.

| Asset | Source canvas | Godot region | Display | Solid base | Visual centre offset |
|---|---|---|---|---|---|
| `assets/modular/flowering_tree.png` | 1212 × 1298 RGBA | `Rect2(46, 117, 1124, 1057)` | 255.21 × 240, scale `240 / 1057` | 80 × 40 | `(0, -100)` |
| `assets/modular/streetlamp.png` | 1024 × 1536 RGBA | `Rect2(381, 114, 262, 1304)` | 30.14 × 150, scale `150 / 1304` | 24 × 24 | `(0, -63)` |

The tree alpha ranges from 0 to 255; strict nonzero-alpha bounds are `(0, 23, 1198, 1298)`. The lamp ranges from 0 to 254, with strict bounds `(73, 36, 964, 1476)`. All corners have alpha 0. Hairline residue remains outside the selected regions in the unchanged sources.

The broad tree canopy is deliberately wider than its trunk collision. Its region's lower edge is local y=20, matching the solid base's lower edge. The lamp's lower edge is local y=12, matching its smaller base. Root origins are at the centres of those solid bases, so placing the scene positions both artwork and physics consistently. The tree is about 2.5 times the founder's displayed height; the lamp is about 1.56 times. Inspect the combined render for proportions and soft-fringe visibility.

Trees and lamps do not have interaction prompts. Lamp glow is baked into its static artwork; the milestone does not implement dynamic light or a day/night cycle. Source scenes and main-level placements are recorded in [the scenery walkthrough](plaza-scenery.md).

## Directional animation handoff

`assets/player/founder_walk_sheet.png` is a 1254 × 1254 RGBA image generated and edited on 2026-10-11. It supplies nine poses: rows are down, up, and right; columns are idle, stride A, and stride B. The left view mirrors right, including its pouch. Front and back stride poses alternate the forward leg; side stride silhouettes are more similar, with distinct arm swings. The initial front/back repeat was corrected through the image-generation tool before integration.

The sheet does not have equal grid cells. Visible bounds at alpha ≥16, in left/top/right/bottom coordinates, are:

| View | Idle | Stride A | Stride B |
|---|---|---|---|
| Down | `(183, 36, 398, 405)` | `(515, 36, 732, 408)` | `(853, 38, 1069, 410)` |
| Up | `(184, 428, 398, 802)` | `(521, 425, 733, 802)` | `(857, 427, 1070, 798)` |
| Right | `(188, 820, 384, 1201)` | `(514, 820, 738, 1200)` | `(858, 821, 1081, 1201)` |

The source is preserved unchanged. `AtlasTexture` regions select each pose; logical margins centre them horizontally and align their bottoms on one shared canvas. A single uniform display scale avoids stretching or resizing each pose independently. Small generated height differences remain and should be judged in motion. The resting feet stay at local y=24, matching the existing collider's lower edge; the visual bob rises by at most two game pixels without moving that collider.

The sheet has alpha values 0–255 and some warm outline residue, visible against a dark inspection background. Cropping excludes distant residue but does not certify clean transparency. Nearest filtering and engine scaling do not establish a shared native pixel grid. Final resource geometry and verification are recorded in [the animation walkthrough](player-animation.md).

## Previous static chibi founder handoff

`jewel-rpg/assets/player/founder_chibi_idle.png` is a **1199 × 1312 RGBA PNG**, generated on 2026-10-11 from the approved combined concept. The broader, shorter character has brown hair, a teal casual shirt, navy trousers, white sneakers, and a tan pouch. It is one static front-facing frame, not a walking-animation sheet.

Read-only inspection found alpha values 0–255. Strict nonzero-alpha bounds are `(0, 9, 1189, 1312)`; faint exterior residue therefore reaches the canvas edge. At alpha ≥16, bounds are `(306, 137, 874, 1199)`, measuring **568 × 1062 source pixels**. Hair and shoes are fully framed within that visible region. The image-generation output is preserved unchanged.

Godot uses region `Rect2(306, 137, 568, 1062)`, nearest filtering, and uniform scale `96 / 1062` (about `0.09039548`). The figure displays at approximately **51.34 × 96 game pixels**. Offset `(0, -24)` puts the lower region edge at local y=24, aligned with the unchanged 32 × 48 player collider. The wider artwork does not widen the solid body. This means shoulders may visually overlap objects when the player's smaller foot/body collider does not.

The crop excludes distant alpha residue but cannot guarantee a clean fringe. Inspect the character against the integrated plaza at gameplay size. Source illustration detail and noninteger downscaling mean this is **high-resolution pixel-style artwork**, not a native low-resolution pixel grid. The new animation handoff below defines a shared frame canvas; it does not retroactively make this static illustration animation-ready.

## Previous environment asset handoff

All three images were generated on 2026-10-11 using the approved combined concept. The sources are preserved unchanged. Godot uses nearest filtering and uniform scales to avoid stretching. These are high-resolution pixel-style illustrations, not a modular native-grid tileset.

| Asset | Source | Visible crop / Godot region | Display |
|---|---|---|---|
| `assets/market/market_plaza.png` | 1672 × 941 RGB, opaque | Full canvas | 960 × 540.29, uniform scale `960 / 1672`, centred at `(480, 270)` |
| `assets/market/jewellery_stall.png` | 1448 × 1086 RGBA | `Rect2(119, 101, 1290, 905)` | 240 × 168.37, uniform scale `240 / 1290`, local offset `(0, -52.18604651)` |
| `assets/market/price_board.png` | 1096 × 1435 RGBA | `Rect2(99, 172, 947, 1147)` | 74.31 × 90, uniform scale `90 / 1147`, local offset `(0, -11)` |

Paths above are relative to `jewel-rpg/`. The plaza is rendered beneath the separate interactive objects. It includes decorative neighbouring stalls and plants, but no duplicate founder, foreground jewellery stall, or price board. It is a fixed backdrop, not a collision map.

Read-only alpha inspection found 0–255 and transparent corners for both props. Strict nonzero-alpha bounds are `(0, 0, 1432, 1068)` for the stall and `(0, 9, 1048, 1397)` for the board. The regions above match bounds at alpha ≥16: `(119, 101, 1409, 1006)` and `(99, 172, 1046, 1319)` respectively. Low-alpha residue remains in the source images; the crop removes distant residue but is not a guarantee of a clean outline.

The stall is centred on the existing body at `(650, 270)`; its lower visual edge is local y=32. Its wider 240-pixel drawing surrounds the unchanged **180 × 64** solid footprint. The preceding visual checkpoint placed the board at `(360, 270)`; the project manager's merged layout now places it at `(503, 278)`. Its radius-72 proximity detection and lower visual edge local y=34 remain unchanged. The current modular kit adds a separate 48 × 20 solid base centred at local `(0, 24)`; the larger detection area still only controls interaction range. Its artwork depicts jewellery rather than containing a trustworthy price label; product descriptions remain in the existing dialogue. Review whether approaching and walking around these visual footprints feels natural.

## Previous modern founder handoff

This narrow founder was used in the initial modern-setting playtest. It is superseded by the chibi texture above and retained as an earlier source checkpoint.


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
