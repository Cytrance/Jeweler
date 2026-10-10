# Jewel RPG

A small 2D RPG project used to learn agentic coding, Git, and Godot. Learning and maintainability come before game scope. Stardew Valley and Graveyard Keeper are inspirations, not initial feature targets.

## Open the project

1. Clone `Cytrance/Jeweler` with GitHub Desktop.
2. Use the standard Godot edition with GDScript. Use Godot 4.7.2, the verified cloud editor version. The project declares the 4.7 feature series; confirm your Windows editor version and record version changes explicitly.
3. In Godot's Project Manager, import `jewel-rpg/project.godot`.

The renderer is Compatibility. The main scene is `jewel-rpg/scenes/main.tscn`: a player moved with WASD or arrow keys, one orange solid obstacle, and a nearby sign with E/Escape dialogue. The current branch replaces the cyan rectangle with a static jeweler-apprentice image; movement, collision, and dialogue behavior remain unchanged. See [the sprite walkthrough](docs/player-sprite.md) for asset imports and playtest steps.

Earlier learning checkpoints are explained in [first scene](docs/first-scene.md), [movement](docs/player-movement.md), [collision](docs/player-collision.md), and [sign dialogue](docs/sign-dialogue.md). Their placeholder descriptions refer to those checkpoints. Screen boundaries and animation remain deferred.

The cloud setup has restored Godot 4.7.2 at `/workspace/tools/godot/bin/godot`; its version command was verified. The older system-default `godot` remains installed, so cloud checks must use the explicit executable path. A successful headless check does not verify appearance on Windows.

## Development workflow

Save files locally, commit a small understandable checkpoint, and push to share it on GitHub. Work on a task branch rather than directly on `main`. Review the pull request and playtest gameplay changes before merging. Squash and merge when a single feature commit is clearer than the intermediate checkpoints.

Before working on your PC, fetch and pull the intended branch in GitHub Desktop. Before agents work in the cloud, they must fetch, inspect local status, and safely check out or update the intended branch while preserving local work. Fetch downloads remote history; it does not update the checked-out files by itself. Synchronization is not automatic. Avoid simultaneous edits to the same files across machines.

Agent responsibilities are in [AGENTS.md](AGENTS.md). Milestones and acceptance checks are in [docs/roadmap.md](docs/roadmap.md).

## Repository layout

- `jewel-rpg/`: Godot project and future game assets, scenes, and scripts.
- `docs/`: project planning and explanations.
- `LICENSE`: repository license; preserve it.

Godot's generated `.godot/` directory is ignored. Commit source assets and their supported import settings, not the generated cache. Never commit credentials.
