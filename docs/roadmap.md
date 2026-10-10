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

## Current milestone: one obstacle and collision

Convert the moving placeholder into a character physics body and add one visible, stationary obstacle. Learn physics bodies, collision shapes, velocity, and sliding. The Windows collision playtest and project manager approval are pending; do not merge yet.

Acceptance checks:

- WASD and arrow keys still move the player; releasing input stops movement.
- The player cannot pass through the orange obstacle from either side, above, or below.
- Diagonal movement into a face slides along it; moving away works immediately.
- Free-space diagonal speed remains equal to straight speed.
- Cloud verification reports actual import, runtime, and automated checks; independent review inspects the final code and tests.
- The project manager runs the [collision walkthrough](player-collision.md) on Windows and reports any errors.

No screen boundaries, animation, interaction, or finished sprites are included. The player can still move offscreen; restarting restores its starting position.

## Later milestones, one at a time

1. One interactive object and short dialogue: learn signals and basic UI.
2. Agree on a small art guide and replace a placeholder: learn the sprite agent workflow and asset imports.

Inventory, crafting, farming, NPC schedules, and save/load are deferred. Define their requirements only when the earlier milestones are understood and verified.

## Task handoff template

- Goal and what the project manager will observe.
- Included work and deferred work.
- Assigned role and branch.
- Acceptance checks and who runs each check.
- Files or systems likely to change.
- Review findings, fixes, and remaining limitations.

Each completed milestone should teach a small concept and leave a checkpoint that is easy to review and maintain.
