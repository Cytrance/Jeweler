# Learning roadmap

## Completed baseline

- GitHub repository cloned on the project manager's Windows PC.
- Empty Godot project created in `jewel-rpg/` and opened locally.
- Initial project committed and pushed; cloud access verified.

## Working agreements checkpoint

Project entry point, role definitions, and roadmap established. Continue using task branches and independent review for each milestone.

## Completed milestone: first running scene

Created one simple 2D scene, designated it as the main scene, and ran it. The project manager confirmed the rectangle on Windows, approved the branch, and the milestone was merged into `main`.

Acceptance checks:

- Cloud agent: verify that the intended main scene loads with Godot 4.7.2 without errors; report the actual checks performed.
- Project manager: run the project on Windows and confirm a visible placeholder appears with no errors.
- Project manager: repeat the steps in [the first-scene walkthrough](first-scene.md).
- Documentation: explain scenes, nodes, the main scene, and editor versus running game.

## Completed milestone: four-direction movement

Move the existing placeholder using WASD and arrow keys. Learn GDScript, input actions, vectors, and physics updates. The project manager tested movement on Windows, approved the change, and merged it into `main` at `1e15da4`.

Acceptance checks:

- Both control sets move the placeholder in all four directions.
- Releasing the keys stops movement immediately.
- Diagonal movement has the same speed as straight movement.
- Cloud verification reports actual import, runtime, and movement checks performed; headless checks do not replace the Windows playtest.
- Independent review checks the actual diff and updates the [movement walkthrough](player-movement.md).

At that checkpoint, collision, boundaries, animation, and finished sprites were deferred.

## Completed milestone: one obstacle and collision

Convert the moving placeholder into a character physics body and add one visible, stationary obstacle. Learn physics bodies, collision shapes, velocity, and sliding. The project manager tested collision on Windows, approved the change, and merged it into `main` at `4d913c3`.

Acceptance checks:

- WASD and arrow keys still move the player; releasing input stops movement.
- The player cannot pass through the orange obstacle from either side, above, or below.
- Diagonal movement into a face slides along it; moving away works immediately.
- Free-space diagonal speed remains equal to straight speed.
- Cloud verification reports actual import, runtime, and automated checks; independent review inspects the final code and tests.
- The project manager runs the [collision walkthrough](player-collision.md) on Windows and reports any errors.

No screen boundaries, animation, interaction, or finished sprites are included. The player can still move offscreen; restarting restores its starting position.

## Completed milestone: sign interaction and short dialogue

Add one sign with a proximity prompt and one fixed message. Learn detection areas, signals, input handling, and UI. The project manager tested the sign on Windows, approved the change, and merged it into `main` at `7b7ae25`.

Acceptance checks:

- Existing movement and solid obstacle collision still work.
- A prompt appears only while the player is near the sign.
- Pressing E nearby opens the message; pressing E elsewhere does nothing.
- Movement stops while the dialogue is open.
- E or Escape closes the dialogue; movement then resumes.
- Cloud verification reports actual checks, and independent review inspects final code and tests.
- The project manager follows [the sign-dialogue walkthrough](sign-dialogue.md) on Windows before approving the merge.

No inventory, dialogue choices, animation, sprites, or screen boundaries are included.

## Completed milestone: one static player sprite

The project manager reviewed the sprite, requested a larger readable character, and merged the correction at `6d2f0bd`. This established the asset handoff and focused-verification workflow. The fantasy-styled clothing is superseded by the modern business setting.

## Superseded experiment: wooden workshop

`feat/workshop-room` was tested locally but remains unmerged. It explored scene composition, boundaries, and collision layers. Do not merge its historical workshop visuals into the modern-market direction. Reuse useful techniques in a separately reviewed change when needed.

## Completed milestone: modern business design brief

The project manager reviewed and merged the brief into `main`. It documents the approved setting, tone, ethical choices, first business loop, placeholder economy, and revised art direction. That documentation milestone included no application or asset changes.

Acceptance checks:

- [Game design](game-design.md) reflects a modern jewellery-business RPG with meaningful simulation and playful humour.
- Initial imitation goods can be sold honestly or misrepresented; composition and sales claims are distinct.
- Prototype values and worked examples are internally consistent and explicitly unbalanced.
- [Art guide](art-guide.md) supersedes the fantasy visual direction and preserves historical import information.
- Planned features are distinguished from the currently running prototype.
- Independent review checks documents; no gameplay suites are rerun for this documentation-only milestone.

## Previous milestone: modern market visual reset

The initial modern setting was playtested on Windows. The project manager then approved the combined cosy concept, and the refined visual checkpoint was merged into `main` at `aaf5da0`. It introduced a chibi founder, warm textured pavement, neighbouring market stalls, and a modest jewellery pop-up while retaining movement, collision, and nearby E/Escape interaction. The merge records inclusion in the shared baseline; it does not establish that every visual acceptance check was separately reported. No economy was implemented.

Acceptance checks:

- The founder reads as a contemporary person in casual clothes and is readable at normal game size.
- The folding table, jewellery trays, price information, stock boxes, and card-payment device communicate a modest modern business.
- Founder, table, and board have coherent proportions; the character is not reduced to the earlier unreadable 48-pixel size.
- The table blocks movement from all four sides, supports sliding, and permits moving away.
- The nearby board opens the modern fixed message; movement locks while reading and resumes on closing.
- The combined scene has acceptable layering, framing, colour contrast, and UI text fit on Windows.
- Independent review inspects the actual scene and assets; focused checks cover changed scene dependencies rather than automatically repeating every historical suite.
- Follow [the modern-market walkthrough](modern-market.md) and report the visual playtest before approving the merge.

## Completed milestone: reusable modular plaza kit

The project manager confirmed collision, adding new prop instances, and the tilemap on Windows, then merged the kit into `main` at `1a9b871`. The merged level also includes the project manager's saved placement and paving edits.

Replace the fixed plaza backdrop with repeatable ground and separately placed objects. Extract the existing stall and board into reusable scenes, and add a flower planter with its own solid footprint. This is a small asset workflow checkpoint before the business loop; it does not promise a complete town or convert every pictured object into a game asset.

Acceptance checks:

- Ground uses a `TileMapLayer` with 192-game-pixel cells and is walkable.
- A reusable planter scene combines artwork and a solid base footprint; multiple instances inherit those settings.
- The existing stall scene includes its collision by default; the board includes proximity detection, dialogue, and a small solid base by default.
- The board works without assuming its parent contains a specifically named player sibling.
- Player, stall, board, and planters layer coherently; foliage can extend over walkable space outside a planter's base.
- Repeated paving looks coherent at gameplay size, and the founder and props retain the approved warm, cute direction.
- Relevant physics, interaction, and asset checks run; unchanged suites are reused when justified.
- The project manager follows [the modular-plaza walkthrough](modular-plaza.md), judges appearance and collision fit on Windows, and approves the merge.

## Completed milestone: flowering trees and streetlamps

The project manager tested and merged this checkpoint into `main` at `4128dae`. Restore some of the approved cosy atmosphere with two tall reusable prop designs, each combining its artwork and a solid grounded base. This builds on the tested modular kit rather than returning to a flat background.

Acceptance checks:

- Two flowering-tree instances and two streetlamp instances share their respective source scenes and inherit collision.
- Tree collision covers the trunk/base; its broader canopy does not become an invisible wall. Lamp collision covers its small base.
- Ground-contact points, uniform display scales, and Y sorting allow the founder to walk behind tall artwork and appear in front when below it.
- Tree, lamp, founder, stall, and planter scales and lighting fit the approved warm modern-market direction.
- The initial player position and routes to the board and stall remain usable.
- Focused checks cover new prop integration and physics. Existing checks that depend on level layout remain usable without automatically repeating every historical suite.
- The project manager follows [the scenery walkthrough](plaza-scenery.md), checks visual quality and routes on Windows, and approves the merge.

## Current milestone: directional founder walking animation

Replace the static founder with down, up, and side poses and a simple alternating-leg walk cycle. Mirror the side view for left movement. Keep the existing physical movement, map placements, collision, and board interaction.

Acceptance checks:

- WASD and arrows select the appropriate facing; equal diagonal input consistently uses the side view.
- Walking visibly alternates leg poses, with a small visual bob. Up shows the back; side movement uses a side pose.
- Releasing input keeps the last facing and returns to idle. Pressing into a blocking wall stops the stride when there is no actual displacement.
- Dialogue immediately stops the animation and bob; closing it allows movement to resume.
- Frame crops share a canvas and uniform scale so changing poses does not resize the body or slide its grounding point.
- Existing player speed, diagonal normalization, solid collision, and scene placements remain intact.
- Relevant animation, movement, and interaction checks run; unchanged prop-art suites are not automatically repeated.
- The project manager follows [the animation walkthrough](player-animation.md), judges the cycle at gameplay size, and approves the merge.

## Next milestones, each reviewed separately

1. Purchase loop: supplier, cash, stock, insufficient-funds feedback.
2. Sales loop: prices, sales claims, customer acceptance/rejection, transaction feedback.
3. Consequences: end-day complaints, reserved refunds, reputation feedback.

The [design brief](game-design.md) defines acceptance checks across the first complete loop. Research, precious-material suppliers, staff, boutiques, supply chains, and luxury competition remain later goals. Save/load and a final balanced economy are not yet implemented.

## Task handoff template

- Goal and what the project manager will observe.
- Included work and deferred work.
- Assigned role and branch.
- Acceptance checks and who runs each check.
- Files or systems likely to change.
- Review findings, fixes, and remaining limitations.

Each completed milestone should teach a small concept and leave a checkpoint that is easy to review and maintain.
