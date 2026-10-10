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

## Current milestone: four-direction movement

Move the existing placeholder using WASD and arrow keys. Learn GDScript, input actions, vectors, and physics updates. The Windows movement playtest is pending; do not mark this milestone complete or merge without project manager approval.

Acceptance checks:

- Both control sets move the placeholder in all four directions.
- Releasing the keys stops movement immediately.
- Diagonal movement has the same speed as straight movement.
- Cloud verification reports actual import, runtime, and movement checks performed; headless checks do not replace the Windows playtest.
- Independent review checks the actual diff and updates the [movement walkthrough](player-movement.md).

Collision, boundaries, animation, and finished sprites are deferred. The placeholder can move offscreen; restarting the game restores its starting position.

## Later milestones, one at a time

1. Obstacles and collision: learn physics bodies and collision shapes.
2. One interactive object and short dialogue: learn signals and basic UI.
3. Agree on a small art guide and replace a placeholder: learn the sprite agent workflow and asset imports.

Inventory, crafting, farming, NPC schedules, and save/load are deferred. Define their requirements only when the earlier milestones are understood and verified.

## Task handoff template

- Goal and what the project manager will observe.
- Included work and deferred work.
- Assigned role and branch.
- Acceptance checks and who runs each check.
- Files or systems likely to change.
- Review findings, fixes, and remaining limitations.

Each completed milestone should teach a small concept and leave a checkpoint that is easy to review and maintain.
