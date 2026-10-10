# Learning roadmap

## Completed baseline

- GitHub repository cloned on the project manager's Windows PC.
- Empty Godot project created in `jewel-rpg/` and opened locally.
- Initial project committed and pushed; cloud access verified.

## Working agreements checkpoint

Project entry point, role definitions, and roadmap established. Continue using task branches and independent review for each milestone.

## Current milestone: first running scene

Create one simple 2D scene, designate it as the main scene, and run it. Use a visible placeholder with no external assets or gameplay systems. The Windows visual playtest is pending; do not mark this milestone complete until the project manager checks it.

Acceptance checks:

- Cloud agent: verify that the intended main scene loads with Godot 4.7.2 without errors; report the actual checks performed.
- Project manager: run the project on Windows and confirm a visible placeholder appears with no errors.
- Project manager: repeat the steps in [the first-scene walkthrough](first-scene.md).
- Documentation: explain scenes, nodes, the main scene, and editor versus running game.

## Later milestones, one at a time

1. Four-direction movement: learn GDScript, input actions, and frame updates.
2. Obstacles and collision: learn physics bodies and collision shapes.
3. One interactive object and short dialogue: learn signals and basic UI.
4. Agree on a small art guide and replace a placeholder: learn the sprite agent workflow and asset imports.

Inventory, crafting, farming, NPC schedules, and save/load are deferred. Define their requirements only when the earlier milestones are understood and verified.

## Task handoff template

- Goal and what the project manager will observe.
- Included work and deferred work.
- Assigned role and branch.
- Acceptance checks and who runs each check.
- Files or systems likely to change.
- Review findings, fixes, and remaining limitations.

Each completed milestone should teach a small concept and leave a checkpoint that is easy to review and maintain.
