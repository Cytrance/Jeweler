# Jewel RPG

A small 2D RPG project used to learn agentic coding, Git, and Godot. Learning and maintainability come before game scope. Stardew Valley and Graveyard Keeper are inspirations, not initial feature targets.

## Open the project

1. Clone `Cytrance/Jeweler` with GitHub Desktop.
2. Use the standard Godot edition with GDScript. The current project declares Godot 4.7; confirm the exact local editor version, choose a matching supported version across machines, and record version changes explicitly.
3. In Godot's Project Manager, import `jewel-rpg/project.godot`.

The renderer is Compatibility. The project currently has no scenes or scripts, so there is no playable game or automated test suite yet. Opening the editor verifies project access, not gameplay.

The cloud machine currently reports Godot 4.6.3, which differs from the project's declared 4.7. Resolve the exact editor version before the first running-scene milestone; cloud gameplay compatibility has not been verified.

## Development workflow

Save files locally, commit a small understandable checkpoint, and push to share it on GitHub. Work on a task branch rather than directly on `main`. Review the pull request and playtest gameplay changes before merging. Squash and merge when a single feature commit is clearer than the intermediate checkpoints.

Before working on your PC, fetch and pull the intended branch in GitHub Desktop. Before agents work in the cloud, they must fetch, inspect local status, and safely check out or update the intended branch while preserving local work. Fetch downloads remote history; it does not update the checked-out files by itself. Synchronization is not automatic. Avoid simultaneous edits to the same files across machines.

Agent responsibilities are in [AGENTS.md](AGENTS.md). Milestones and acceptance checks are in [docs/roadmap.md](docs/roadmap.md).

## Repository layout

- `jewel-rpg/`: Godot project and future game assets, scenes, and scripts.
- `docs/`: project planning and explanations.
- `LICENSE`: repository license; preserve it.

Godot's generated `.godot/` directory is ignored. Commit source assets and their supported import settings, not the generated cache. Never commit credentials.
