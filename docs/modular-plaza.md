# Reusable modular plaza kit

This checkpoint replaces the single painted plaza background with repeatable paving and reusable props. It adds one flower planter design, used several times, and turns the existing stall and price board into their own scenes. The founder and approved warm, cute art direction remain. This is a small test plaza, not the full market or a complete town.

## Image, scene, and tile

A PNG stores the artwork. It cannot block movement or open dialogue by itself. A `Sprite2D` draws that image. A reusable Godot scene combines the drawing with the nodes that give the object behaviour.

The stall and planter use `StaticBody2D` and `CollisionShape2D`: placing their scenes includes the solid footprint automatically. The board combines an `Area2D`, its proximity shape, prompt, dialogue, and script with a separate child `StaticBody2D` and base collision shape. Placing its scene includes both interaction and a solid base. The large circular detection area only decides when E is available; the small base rectangle blocks movement.

Ground uses `TileMapLayer`. An external `TileSet` describes the available paving tile. Its cell uses the source image size, while a uniform scale on the layer makes each placed cell 192 × 192 game pixels. The layer stores its painted cells in the scene; no runtime script rebuilds the ground. This ground has no collision, so it remains walkable. The cell size is a world-layout choice, not a claim that the generated source artwork is native 192 × 192 pixel art.

## Reusing a scene

Godot stores reusable scenes as `.tscn` files and loads them as `PackedScene` resources. An instance is a placed copy that stays linked to its source scene. Moving one instance changes its placement. Editing the source scene's image, collision, or shared settings updates its instances unless an instance has overridden that setting.

This prevents rebuilding a collision shape every time we place another planter. It also means a source-scene change should be reviewed in the combined level: a larger footprint affects every linked instance. Git records the source scene and level placements as ordinary files, so those changes still go through a branch, commit, review, and merge.

Collision describes the object's physical footprint, not every visible pixel. A planter's flowers extend above and beyond its base. The base blocks movement; surrounding space stays walkable. Y sorting draws objects according to their vertical positions so the founder can appear behind foliage and in front of it. Neither a large transparent canvas nor the full canopy should automatically become a solid rectangle.

## Current scene files and geometry

- `scenes/market.tscn`: a saved `Ground` TileMapLayer with the external `resources/plaza_paving.tres` TileSet; 15 saved cells in a 5 × 3 layout form 192-game-pixel world patches covering 960 × 576, including the 960 × 540 initial view.
- `scenes/props/jewellery_stall.tscn`: existing illustrated stall and 180 × 64 solid rectangle, placed at `(650, 270)`.
- `scenes/props/price_board.tscn`: existing 90-pixel-tall drawing and radius-72 proximity area, plus a 48 × 20 solid base centred at local `(0, 24)`. The base's lower edge is local y=34, aligned with the drawing's lower edge. The main scene supplies `player_path`.
- `scenes/props/flower_planter.tscn`: 110 × 86.96 display drawing and an 80 × 36 solid base. The visual lower edge is local y=18, matching the collider's lower edge. Four instances are placed near the plaza corners.

The main scene still owns the player and level placements and enables Y sorting for the props. Editing a reusable prop source does not require copying its child nodes into the main scene.

## Try this checkpoint on Windows

1. Save local work and close Godot. Preserve uncommitted changes before switching branches.
2. In GitHub Desktop, fetch, select `feat/modular-plaza`, and pull if offered.
3. Open `jewel-rpg/project.godot` in Godot 4.7.2 and press F5. Click the game view for keyboard focus.
4. Check the repeated paving at normal game size. Report obvious seams, strange repeated highlights, muddy detail, or a mismatch with the founder and props.
5. Walk around each planter. Its base should block movement, while space beyond the base remains walkable. Walk behind and in front and judge whether drawing order feels natural.
6. Walk around all sides of the stall and check blocking, sliding, and moving away.
7. Approach the board and press E. Movement should lock while the message is open; E or Escape should close it and restore movement. Its small base should block movement without making the whole circular interaction area into a wall.
8. Stop with F8 and inspect the debugger for errors. Report appearance and collision-to-art fit before approving the merge.

## Editor learning experiment

Do this on the task branch. Save the edits only if you want to keep them; otherwise discard these experimental changes before reviewing or merging.

1. Open `scenes/main.tscn`. In the FileSystem dock, drag `scenes/props/flower_planter.tscn` into the main scene. Select the new instance and move it using the 2D editor. Running the game includes its collision without adding another shape yourself.
2. Open the original planter scene separately to see `StaticBody2D`, `Sprite2D`, and `CollisionShape2D`. Select the shape to see the small base footprint. Editing this source changes all linked planters. Editing a property on one instance in `main.tscn` creates a local override for that instance instead. Keep collision shared unless there is a specific reason for a different footprint.
3. A newly placed price board needs its `Player Path` assigned in the Inspector to the player node, using the node picker. This connects the reusable board to the player in this level; its script does not search for a hardcoded sibling name. The player must provide `movement_locked` and `velocity`, as the current player script does.
4. Open `scenes/market.tscn` and select its paving `TileMapLayer`. In the TileMap editor at the bottom, select the available paving tile, use the paint tool, and click a cell in the 2D view. Erasing a cell exposes empty ground; it does not add a wall. Save to record the cell placements in the scene.
5. Open `resources/plaza_paving.tres`, the external TileSet resource, to inspect the source tile. This is where future terrain-tile collision can be configured. The current paving deliberately has none. Do not edit imported image-cache files.

A reusable asset includes its default collision or interaction configuration, but its placement and necessary links still belong to the level. An image-generation agent supplies artwork; the coding agent builds and verifies the Godot scene around it.

## Limits

Only the paving, one planter, existing stall, and existing board form this kit. The old café, lamps, and neighbouring stalls were baked into the previous backdrop; they are not newly reusable objects. The old background image remains as historical source artwork but is no longer the playable ground.

The generated assets are high-resolution pixel-style illustrations scaled for gameplay. A consistent native pixel grid and animation sheets have not yet been established. A repeatable paving tile is not a complete terrain system: transitions, roads, grass, doors, buildings, and map boundaries are deferred.

The founder remains one static front-facing frame. The board still shows one fixed message. Decorative jewellery is not inventory; purchasing, sales, money, reputation, save/load, and audio are unimplemented. The player can still leave the screen; restart with F8 then F5.

## Verification

The coding agent reported a clean Godot 4.7.2 import and focused checks: 12 modular-plaza checks, 17 existing interaction checks, 4 existing collision checks, and 15 modular-art checks. Existing founder source-image checks and unrelated movement checks were not automatically repeated. Ground-display assertions were updated after increasing the paving patch size for readability.

The reviewer independently ran only `verify_modular_plaza.gd`: **12 checks passed, zero failures, exit code 0**. It moves the actual player into all four sides of a planter, checks escape movement, places a fresh planter instance and verifies inherited collision, and checks the board's separate solid base. It also checks that overlapping boards do not steal another board's close input or unlock its dialogue, and that an unassigned standalone board remains inactive. The test deliberately creates that unassigned board, so its missing-player warning is expected; the configured level supplies the link.

Review inspected the actual source-scene extraction, shared shapes, saved tile cells, external TileSet, uniform display scales, and the board's explicit player dependency. Two ownership issues were fixed before approval: exiting an inactive board no longer unlocks another dialogue, and a closed board does not consume E while another board has locked movement. Other reported passing suites were reviewed rather than rerun merely for duplication.

From the repository root, run the new behaviour check with the pinned cloud engine:

```bash
env XDG_DATA_HOME=/workspace/tools/data XDG_CONFIG_HOME=/workspace/tools/config XDG_CACHE_HOME=/workspace/tools/cache /workspace/tools/godot/bin/godot --headless --path jewel-rpg --script res://tests/verify_modular_plaza.gd
```

The coordinating agent rendered the actual Godot 4.7.2 game at 960 × 540 through a virtual Xorg display with the Compatibility renderer and Mesa software graphics. The reviewer inspected that final render: the 192-pixel patches keep stones readable beside the founder and stall, the flower planters are fully framed, and the ground covers the view without empty gaps. Repetition and tile-edge joins remain discernible; this is not an exact seamless paving certification. Tile variants and terrain transitions are future art work. The intentionally sparse kit section replaces the painted café and surrounding town rather than recreating them as fake interactive scenery. No game-script errors were reported; a dummy audio backend is expected in the cloud and this checkpoint has no audio feature.

Automated checks establish selected structural and behavioural properties; the project manager's Windows playtest remains the final appearance and feel check.
