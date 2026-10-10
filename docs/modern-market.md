# Modern market visual reset

This milestone changes the prototype's setting to a present-day jewellery pop-up. A casually dressed founder stands beside a modest folding table, jewellery trays, a card-payment device, and stock boxes. Pavement and neighbouring stall silhouettes provide context. The table replaces the orange collision-test block; the nearby sign becomes a contemporary price board.

This is a visual and scene-composition milestone. The board describes imitation jewellery but does not sell anything. Cash, stock, suppliers, pricing choices, customers, and complaints remain future milestones from [the game-design brief](game-design.md). Decorative merchandise is not inventory, and the card terminal is not an interaction.

## Try the branch on Windows

1. Save work and close Godot. Preserve uncommitted edits before switching branches.
2. After the branch is pushed, fetch in GitHub Desktop, select `feat/modern-market`, and pull if offered. This checks out the proposal without merging it into `main`.
3. Open `jewel-rpg/project.godot` in Godot 4.7.2 and press F5. Click the game view for keyboard focus.
4. Judge the whole scene at normal game size. Can you recognise the modern founder, jewellery table, payment device, and price board? Check that the founder remains readable and taller than the board, and the table feels plausible beside a person.
5. Walk using WASD and arrow keys. Approach the table from all four sides, try diagonal movement against each edge, and move away. It should block and allow sliding without trapping the player.
6. Walk above and below the table. Judge whether the player's drawn position and collision footprint feel consistent, and whether foreground decorations obscure the character awkwardly.
7. Approach the board, press E, and check the fixed modern message and text fit. Movement should stop while reading; E or Escape should close it and restore movement. Walk away and check the prompt disappears.
8. Check the debugger for errors. Stop with F8 and report readability, proportions, awkward overlaps, and behaviour before approving the merge.

The founder remains a single static front-facing frame; no walking animation or turning is included. The price board detects proximity but does not block movement. Stock boxes and neighbouring stalls are decorative and non-solid. The table is the only solid obstacle; market décor is not a complete playable town. Screen boundaries are deferred: restart with F8 then F5 if you leave the view.

## Composing scenes instead of replacing the movement system

`main.tscn` remains the game's entry scene. It combines the player, solid table, and sign interaction with a separate `market.tscn` background. An instanced scene lets us maintain pavement, neighbouring stalls, and background décor together instead of putting every environment detail into the entry scene. It does not create a separate branch or another running game.

The player still uses `CharacterBody2D`, velocity, and `move_and_slide()`. The table uses `StaticBody2D` with a rectangular collision shape. Its visual includes a tabletop, front edge, and legs; its solid footprint is a separate design choice. Artwork dimensions describe what is drawn; collision dimensions describe where movement is blocked. Those dimensions should cooperate, but need not be identical.

The scene keeps the historical node names `PlayerPlaceholder`, `Obstacle`, and `Sign` because scripts and checks already reference them. Their names describe the earlier prototype; the actual drawings now represent the founder, folding table, and price board.

The main scene enables Y sorting: player, table, and sign are drawn according to their vertical scene positions, while the market background uses a lower draw layer. This approximates walking behind and in front of objects; playtesting should catch visual overlap that a node-order check cannot.

Actual integration settings:

- Founder: `assets/player/founder_idle_front.png`, 1144 × 1375 RGBA source; region `Rect2(325, 57, 478, 1275)` and uniform scale `96 / 1275` give about 35.99 × 96 game pixels.
- Player collider: unchanged 32 × 48 rectangle; sprite offset `(0, -24)` aligns its lower edge to collider bottom.
- Table: centred at `(650, 270)`, with a 180 × 64 rectangular solid footprint. Its drawing includes a 180 × 48 tabletop, front cloth, and legs.
- Board: centred at `(360, 270)`, with the existing radius-72 detection area. It is deliberately non-solid.
- Market: background scene at draw layer `-10`; no camera movement or bounded map is introduced.

The price board retains the existing `Area2D` signal-based proximity detection and screen-space dialogue. Its wording and drawing change, not the interaction system's responsibilities. The board should not imply that business transactions already exist.

## Source art and display size

The sprite agent supplies a new transparent founder image, its provenance, and measured crop guidance. The coding agent integrates the texture through `Sprite2D`, a uniform scale, and a feet offset. The target founder height remains roughly 96 game pixels, addressing the project manager's earlier readability feedback.

A high-resolution generated source scaled down is not native low-resolution pixel art. Nearest filtering does not make its source pixel grid consistent or guarantee that fine details remain readable. The market uses geometric Godot drawings; their appearance and the founder's art should be judged together. See [the art guide](art-guide.md) for actual source and integration dimensions, and [asset origins](asset-origins.md) for the asset handoff.

## Verification

Independent review inspected the final scene composition, rectangular collision footprint, Y sorting, fixed dialogue, source founder framing, import settings, and changed test harnesses. A self-touching price-board leg polygon was split into two simple polygons before final review. No movement or interaction source script changed.

The coding agent reported a successful Godot 4.7.2 headless editor import, then 37 focused checks with no failures: 4 existing collision checks, 4 market checks, 17 interaction checks, and 12 sprite checks. The market suite covers blocking from above/below and clear routes around both ends; the existing collision subset covers left/right blocking, edge sliding, and moving away. Its shorter sliding interval keeps the player on the new table's shorter edge rather than walking past the corner.

The reviewer independently ran only the new market suite with the pinned Godot 4.7.2 executable: 4 checks passed, 0 failures, exit code 0. The other reported results were reviewed rather than automatically duplicated. The unchanged free-space movement and keyboard-binding checks were not rerun. Historical checks remain available if a later change warrants them.

Run the focused collision subset or market suite from the repository root:

```bash
env XDG_DATA_HOME=/workspace/tools/data XDG_CONFIG_HOME=/workspace/tools/config XDG_CACHE_HOME=/workspace/tools/cache /workspace/tools/godot/bin/godot --headless --path jewel-rpg --script res://tests/verify_movement.gd -- --collision-only
env XDG_DATA_HOME=/workspace/tools/data XDG_CONFIG_HOME=/workspace/tools/config XDG_CACHE_HOME=/workspace/tools/cache /workspace/tools/godot/bin/godot --headless --path jewel-rpg --script res://tests/verify_market.gd
```

No graphical combined-scene preview was available in the cloud. Windows appearance, keyboard controls, scale, drawing order, and overall art approval remain the project manager's checks above. Headless imports and automated assertions cannot establish that the game looks good.
