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

## Current milestone: modern business design brief

Document the approved setting, tone, ethical choices, first business loop, placeholder economy, and revised art direction. No application or asset changes are included.

Acceptance checks:

- [Game design](game-design.md) reflects a modern jewellery-business RPG with meaningful simulation and playful humour.
- Initial imitation goods can be sold honestly or misrepresented; composition and sales claims are distinct.
- Prototype values and worked examples are internally consistent and explicitly unbalanced.
- [Art guide](art-guide.md) supersedes the fantasy visual direction and preserves historical import information.
- Planned features are distinguished from the currently running prototype.
- Independent review checks documents; no gameplay suites are rerun for this documentation-only milestone.

## Next milestones, each reviewed separately

1. Modern visual reset: casual founder and readable market pop-up, retaining movement and interaction.
2. Purchase loop: supplier, cash, stock, insufficient-funds feedback.
3. Sales loop: prices, sales claims, customer acceptance/rejection, transaction feedback.
4. Consequences: end-day complaints, reserved refunds, reputation feedback.

The [design brief](game-design.md) defines acceptance checks across the first complete loop. Research, precious-material suppliers, staff, boutiques, supply chains, and luxury competition remain later goals. Save/load and a final balanced economy are not yet implemented.

## Task handoff template

- Goal and what the project manager will observe.
- Included work and deferred work.
- Assigned role and branch.
- Acceptance checks and who runs each check.
- Files or systems likely to change.
- Review findings, fixes, and remaining limitations.

Each completed milestone should teach a small concept and leave a checkpoint that is easy to review and maintain.
