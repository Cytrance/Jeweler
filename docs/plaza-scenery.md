# Flowering trees and streetlamps

This checkpoint extends the reusable plaza kit with one flowering-tree scene and one streetlamp scene, each placed twice. Their artwork is separate from the ground, and their solid bases come with the scene. It restores some of the approved cosy atmosphere without turning an entire painted town into an invisible collision map.

## Tall artwork, small solid footprint

A tree's canopy is much wider and taller than its trunk. The `Sprite2D` draws the full tree, while the `StaticBody2D` and rectangular `CollisionShape2D` block the grounded trunk/base. The founder can move beneath the surrounding canopy where there is no solid base. The streetlamp works the same way, with a smaller collision rectangle around its foot.

Neither object opens dialogue. The warm lamp glow is drawn into the image; it does not add a dynamic lighting system, a day/night cycle, or an electrical simulation.

The source PNG has transparent padding, so using its entire canvas as a physical rectangle would create a wall around empty space. Godot's sprite region selects the useful artwork, uniform scaling preserves its proportions, and the sprite offset puts its lower edge against the collision base's lower edge. Those settings belong to the reusable scene rather than being rebuilt for every placement.

## Scene geometry and placements

| Source scene | Display artwork | Solid footprint | Main instances |
|---|---|---|---|
| `scenes/props/flowering_tree.tscn` | 255.21 × 240 game pixels | 80 × 40 rectangle | `TreeLeft` at `(150, 260)` and `TreeRight` at `(830, 430)` |
| `scenes/props/streetlamp.tscn` | 30.14 × 150 game pixels | 24 × 24 rectangle | `LampLeft` at `(260, 180)` and `LampRight` at `(740, 155)` |

Paths are relative to `jewel-rpg/`. The tree sprite is centred at local `(0, -100)`, placing its lower edge at y=20. The lamp sprite is centred at `(0, -63)`, placing its lower edge at y=12. Those lower edges match their collision rectangles. Exact source regions, transparency inspection, and uniform scales are recorded in [the art guide](art-guide.md).

## Origin and drawing order

The scene root's origin is the position you move in the level editor. Its collision base is centred on that point; most of its artwork extends upwards. The main scene enables Y sorting, which compares the vertical positions of the founder and props. Walking above a tree's base draws the founder behind its canopy. Walking below the base draws the founder in front. Drawing order changes appearance, while the base collision decides which space is physically blocked.

This is a simple shared placement convention. It is not pixel-perfect overlap detection: the canopy is not a physics shape, and the player still has its existing 32 × 48 rectangular body rather than a tiny shoe-only collider. Judge the result in motion and keep this convention consistent when placing future tall props.

## Try it on Windows

1. Save or preserve local edits, then close Godot. Fetch in GitHub Desktop and select `feat/plaza-scenery`; pull if offered.
2. Open `jewel-rpg/project.godot` with Godot 4.7.2 and press F5. Click the game view for keyboard focus.
3. Walk into each tree and lamp base from different sides. The grounded base should stop movement, while moving away and sliding along it remain possible.
4. Walk behind and in front of each tree. Check whether the founder layers naturally with the canopy and remains visible on the routes through the plaza.
5. Reach the board and stall. Confirm that the extra scenery leaves useful paths; check E/Escape at the board.
6. Judge the tree and lamp at normal game size against the founder, planter, and stall. Look for cut-off artwork, a visible transparency fringe, mismatched lighting, or a base that feels disconnected from collision.
7. Stop with F8 and inspect the debugger. Report any appearance or route issues before merging.

## Reuse exercise

Open `scenes/main.tscn` and drag either new prop scene from the FileSystem dock into the level. Move its root node to place it. The image, default collision, and offsets come with the instance; no script or additional collision node is needed.

Open the prop's source scene separately and enable collision-shape visibility to compare its base with the artwork. Editing the source scene updates linked instances. Moving one instance changes its position in this level; overriding its child shape or image settings changes that instance only. Prefer the shared defaults unless a placement has a specific reason to differ.

The project manager's saved board, five planter placements, and paving edits are retained in this checkpoint. The founder now starts at `(440, 350)`: the original start was partly hidden behind the moved board and slightly overlapped its solid base. Moving the start into the clear central space keeps the character visible without undoing the map edits. Tests should create clear fixtures when checking isolated collision rather than assuming an editor experiment leaves the level in its original layout.

## Limits

This adds two static prop designs, not a complete town. Storefronts, doors, terrain transitions, native-grid art, animated foliage, and dynamic lighting remain future work. Generated images are high-resolution pixel-style illustrations, with engine crops and scales; they do not establish a shared native pixel grid.

The founder remains a static front-facing figure, and the board still displays its existing fixed message. Purchasing, selling, stock, cash, and reputation are unimplemented. There are still no map boundaries, so the player can leave the screen.

## Verification

The coding agent reported a clean Godot 4.7.2 editor import and **66 focused checks passed**: 29 new scenery checks, 4 actual-market route checks, 12 modular-plaza checks, 17 interaction checks, and 4 collision checks. Unchanged movement/input, founder-image, and older art checks were not automatically repeated.

Some earlier behaviour tests assumed the original level placements. The project manager rearranged props and added a fifth planter while learning the editor. This checkpoint preserves those map edits and gives isolated behaviour tests controlled fixtures, retaining the actual player and reusable prop scenes. The market and scenery suites separately test actual level routes. That lets future decoration edits coexist with tests of shared physics and dialogue contracts.

The reviewer inspected the source scenes, final map diff, collision footprints, measured sprite alignment, import settings, and test fixtures. The reviewer independently ran only the new `verify_scenery.gd`: **27 checks passed, zero failures, exit code 0**, before the final spawn adjustment. The coding agent then added two checks for idle stability and clear initial movement at the new start and reran only the affected scenery suite: **29 passed**. It drives the actual player into each prop from four sides, verifies escape movement and inherited collision on a freshly placed instance, checks source crops and grounding, and checks two routes through the combined scene. Existing reported passing checks were reviewed rather than duplicated.

From the repository root, run that focused check with the pinned cloud engine:

```bash
env XDG_DATA_HOME=/workspace/tools/data XDG_CONFIG_HOME=/workspace/tools/config XDG_CACHE_HOME=/workspace/tools/cache /workspace/tools/godot/bin/godot --headless --path jewel-rpg --script res://tests/verify_scenery.gd
```

The coordinating agent rendered the actual Godot 4.7.2 game at 960 × 540 using a virtual Xorg display, the Compatibility renderer, and Mesa software graphics. The reviewer inspected the final render: the founder is visible at the clear new start, both tree canopies and lamps fit the view, base placement matches the artwork, and the warm colours fit the existing stall and planters. The broad right canopy approaches the stall's edge, but the checked routes remain physically clear. Repeated paving patterns remain visible, as in the approved modular-kit checkpoint; no seamless-tile certification is implied.

No game-script errors were reported. The cloud's unsupported-VSync warning and dummy audio backend are environment limitations, and this milestone has no audio feature. The static render establishes framing and composition, not the feel of walking behind a canopy. The project manager's Windows appearance, layering-in-motion, and route review remain pending before merge.
