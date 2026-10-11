# Asset origins

## Starter-apartment furniture and materials

- Files: `jewel-rpg/assets/interiors/apartment_furniture.png` and `jewel-rpg/assets/interiors/apartment_surfaces.png`.
- Created: 2026-10-11 using the OpenAI image-generation tool. The approved market concept was visually inspected before preparing the original matching interior briefs.
- Furniture brief: five fully framed contemporary thrift props on a transparent sheet: worn single bed with sage blanket, television on a stand, low wooden table, desk with cheap computer, and chipped cream apartment door. Warm muted palette, cute textured pixel-style rendering, consistent front-facing three-quarter top-down perspective, no baked floor or labels.
- Material brief: opaque side-by-side worn honey-brown floor planks and aged muted sage plaster, for a reusable indoor tile atlas. Seamless repetition was requested but is not guaranteed by generation.
- Furniture source output: `exec-747b8545-e822-4aa6-a380-3822c7acf339.png`, **1254 × 1254 RGBA**. Material source output: `exec-21590775-5ba5-4657-93e2-5881ced22190.png`, **1254 × 1254 RGB**. Original outputs remain in the workspace generated-images directory and were copied unchanged into the repository.
- Metadata and alpha measurements were read-only. Atlas regions, scaling, tile layout, and collisions are Godot settings; no source pixels were edited.
- Purpose: modular starter-apartment room and furniture reusable in future indoor environments. These are high-resolution pixel-style illustrations, not a native pixel-grid guarantee, rotation set, or animated sprite sheet.
- The tool returned no asset-specific license notice. Applicable service terms govern usage; generation does not establish exclusive ownership or clearance. Measured framing, display guidance, and remaining appearance checks are recorded in [the art guide](art-guide.md).

## Modern market customers

- File: `jewel-rpg/assets/customers/customer_sheet.png`.
- Created: 2026-10-11 using the OpenAI image-generation tool, referencing the approved modern-market concept and existing chibi founder for rendering and proportions.
- Brief: four original, fully framed contemporary customers on a transparent 2 × 2 sheet: Mina, a commuter in sage with a tote; Jo, an office worker in a navy blazer and glasses; Noor, a fashion student in a purple hoodie; and Bea, a silver-haired neighbour in a pink cardigan. One static front-facing pose each; no logos, text, scenery, or ground shadows.
- Source output: `exec-6d4b281a-245a-4aa0-b213-02dda244d319.png`, preserved in the workspace generated-images directory and copied unchanged into the repository.
- Source canvas: 1199 × 1312 RGBA. Framing and alpha measurements were read-only. Atlas regions, logical padding, uniform scale, and portrait crops are engine settings; no image pixels were edited.
- Purpose: reusable customer actors and matching service-menu portraits. This is high-resolution pixel-style artwork, not a native pixel-grid guarantee or animation sheet.
- The tool returned no asset-specific license notice. Applicable service terms govern usage; generation does not establish exclusive ownership or clearance.
- Fine alpha residue and small figure-size differences remain. Precise handoff geometry and gameplay-size review requirements are recorded in [the art guide](art-guide.md).

## Modern market style concept v1

- File: `docs/concepts/modern-market-style-v1.png`.
- Created: 2026-10-10 using the OpenAI image-generation tool.
- The project manager's supplied reference guided warmth, pixel-style rendering, foliage, and cute proportions. The generated concept depicts an original contemporary jewellery pop-up rather than the reference's historical architecture.
- Purpose: combined art-direction preview for approval. Not imported by Godot and not a production tileset or native pixel-grid guarantee. The generated output is preserved unchanged.

## Player idle front

- File: `jewel-rpg/assets/player/jeweler_idle_front.png`
- Created: 2026-10-10.
- Method: OpenAI image-generation tool; original jeweler-apprentice brief, followed by image-tool edits requesting removal of exterior background and halo, then correction of clipped hair/boot framing.
- Source canvas: 1024 × 1536 RGBA PNG. Original generated output is preserved in the task workspace; the repository contains the selected edited output without further pixel edits.
- Intended use: provisional single-frame player illustration for learning Godot asset integration.
- Existing named game characters were not requested as references.

The tool returned no asset-specific license notice.

Known visual limitations and import guidance are recorded in [the art guide](art-guide.md).

## Modern founder idle front

- File: `jewel-rpg/assets/player/founder_idle_front.png`.
- Created: 2026-10-10.
- Method: OpenAI image-generation tool, original modern-founder brief: short brown hair, teal casual T-shirt, navy jeans, white sneakers, plain tan crossbody pouch; one front-facing frame, transparent exterior, no logos or copied characters.
- Source canvas: 1144 × 1375 RGBA PNG; copied unchanged from the generated output. Inspection used read-only image metadata; no pixel-processing edits were performed.
- Intended use: provisional static modern founder replacing the historical apprentice visual. It is not an animation sheet or a native low-resolution sprite.
- The tool returned no asset-specific license notice. Applicable service terms govern usage; generation does not establish exclusive ownership or clearance.
- Full hair and both shoes are framed. All corners are fully transparent, but faint low-alpha residue exists beyond the visible silhouette. Cropping guidance and remaining visual checks are recorded in [the art guide](art-guide.md).

## Cosy chibi founder

- File: `jewel-rpg/assets/player/founder_chibi_idle.png`.
- Created: 2026-10-11 using the OpenAI image-generation tool.
- Method: original contemporary founder brief using the project manager's approved `docs/concepts/modern-market-style-v1.png` as the style reference: broader chibi proportions, warm palette, teal casual clothing, sneakers, and pouch; one front-facing frame.
- Source canvas: 1199 × 1312 RGBA PNG. Copied unchanged from the generated output; metadata and alpha inspection were read-only. Cropping and scaling happen in Godot, not by editing image pixels.
- Purpose: replace the initial narrow founder in the playable visual reset. No movement frames are included. This generated pixel-style illustration does not establish a native pixel grid.
- Alpha residue and the exact visible-region settings are documented in [the art guide](art-guide.md). Integrated appearance remains subject to the project manager's Windows review.

## Cosy market environment

- Files: `jewel-rpg/assets/market/market_plaza.png`, `jewel-rpg/assets/market/jewellery_stall.png`, and `jewel-rpg/assets/market/price_board.png`.
- Created: 2026-10-11 using the OpenAI image-generation tool, with the project manager's approved combined modern-market concept as the style reference.
- Brief: warm textured contemporary plaza with a clear central play area; a separate modest teal-cloth jewellery table with trays, imitation pieces, payment terminal, and stock box; a separate standing pictorial jewellery board. The foreground objects and player are not baked into the plaza.
- Source canvases: plaza 1672 × 941 RGB; stall 1448 × 1086 RGBA; board 1096 × 1435 RGBA. Selected generated outputs were copied unchanged. All inspections were read-only; no pixel-processing edits were performed.
- Purpose: separate background and object textures for the playable visual reset. Decorative merchandise is not inventory, and generated detail is not a native pixel-grid guarantee.
- Exact source framing, alpha residue, and engine display geometry are recorded in [the art guide](art-guide.md). Visual approval of the concept precedes, and does not replace, approval of the integrated game scene.

## Modular paving and flower planter

- Files: `jewel-rpg/assets/modular/paving.png` and `jewel-rpg/assets/modular/flower_planter.png`.
- Created: 2026-10-11 using the OpenAI image-generation tool, referencing the approved modern-market concept for warm paving, muted colours, and cute contemporary scenery.
- Source canvases: paving 1254 × 1254 RGB; planter 1212 × 1298 RGBA. The selected generated outputs were copied unchanged; metadata and alpha inspection were read-only. Engine cropping, scaling, and tile transforms do not edit source image pixels.
- Purpose: repeatable ground texture and a single reusable flower-planter design. The planter's collision is authored in its Godot scene; the paving's walkable configuration is authored in the TileSet.
- Planter alpha ranges from 0 to 255, with transparent corners and faint exterior residue. The paving source is not guaranteed exactly seamless; repeated appearance requires review in the rendered game. These are pixel-style illustrations, not an established native low-resolution grid.
- Source framing and final engine geometry are recorded in [the art guide](art-guide.md).


## Flowering tree and streetlamp

- Files: `jewel-rpg/assets/modular/flowering_tree.png` and `jewel-rpg/assets/modular/streetlamp.png`.
- Created: 2026-10-11 using the OpenAI image-generation tool, referencing the approved modern-market concept; the tree also references the existing flower planter for consistency.
- Brief: one fully framed pink-flowering tree and one warm contemporary market streetlamp, each on a transparent exterior, with separate artwork for reusable grounded prop scenes.
- Source canvases: tree 1212 × 1298 RGBA; lamp 1024 × 1536 RGBA. Selected generated outputs are copied unchanged; source-image inspections are read-only. Godot regions and uniform scales do not edit source pixels.
- Tree source output: `exec-1b5f1dd5-da76-4306-8c15-e55235f18668.png`; lamp source output: `exec-eb9dd24c-d053-46d7-914f-88bccff488f9.png`. Original outputs remain in the task workspace's generated-images directory.
- Both have transparent corners and faint alpha residue beyond the useful silhouette. These are high-resolution pixel-style illustrations, not animation sheets or a shared native pixel grid.
- Collision is authored in each Godot scene. The warm lamp illumination is part of the static drawing, not dynamic lighting. Final geometry and framing are recorded in [the art guide](art-guide.md) and [scenery walkthrough](plaza-scenery.md).

## Directional founder walking sheet

- File: `jewel-rpg/assets/player/founder_walk_sheet.png`.
- Created: 2026-10-11 using the OpenAI image-generation tool, referencing the existing chibi founder and approved market style.
- Brief: nine complete transparent poses, arranged as down, up, and right views, each with idle and two stride poses. Left uses Godot mirroring.
- The initial generated sheet repeated the front/back step pose. An image-generation edit corrected opposite-leg poses in the third column. The selected edited output `exec-cc5c8de1-b1ae-4a96-9632-26f5f61e5e02.png` is copied unchanged into the repository; the initial output was `exec-36f76215-b7b8-4928-a20e-a510e8132ad8.png`.
- Source canvas: 1254 × 1254 RGBA, alpha 0–255. Inspection is read-only; regions, logical padding, uniform scale, and mirroring are configured in Godot without pixel edits.
- Purpose: first directional walking animation. Frame positions are uneven, so the engine uses explicitly measured regions rather than assuming nine equal cells. This is pixel-style illustration, not a native low-resolution grid.
- Known limitations: warm edge residue, small pose-to-pose size differences, subtle side-step leg identity, and a mirrored pouch on the left view. Actual gameplay-size motion requires review. See [the art guide](art-guide.md) and [animation walkthrough](player-animation.md).
