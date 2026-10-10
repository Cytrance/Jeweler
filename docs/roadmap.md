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

## Current milestone: one static player sprite

Replace the cyan rectangle with a transparent, generated jeweler-apprentice image. Learn the sprite-agent handoff, source assets, texture imports, filtering, and visual versus collision geometry. Windows appearance and project manager art approval are pending; do not merge yet.

Acceptance checks:

- A visible apprentice image replaces only the player's drawing.
- The source asset, import settings, art specification, and origin record are committed; generated cache files remain ignored.
- Existing controls, collision shape, and sign dialogue still work.
- Independent review checks the final asset integration and reruns existing movement and interaction regressions.
- The project manager follows [the sprite walkthrough](player-sprite.md) and approves readability, transparency, and alignment on Windows.

This is one static pose, not an animated or directional sprite sheet. Exact pixel-grid consistency and a final production art style are not established.

## Later milestones, one at a time

Agree on the next small learning goal after this milestone is reviewed and merged.

Inventory, crafting, farming, NPC schedules, and save/load are deferred. Define their requirements only when the earlier milestones are understood and verified.

## Task handoff template

- Goal and what the project manager will observe.
- Included work and deferred work.
- Assigned role and branch.
- Acceptance checks and who runs each check.
- Files or systems likely to change.
- Review findings, fixes, and remaining limitations.

Each completed milestone should teach a small concept and leave a checkpoint that is easy to review and maintain.
