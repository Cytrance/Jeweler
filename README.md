# Jewel RPG

A modern 2D jewellery-business RPG, built in small milestones to learn agentic coding, Git, and Godot. Start with a modest pop-up selling imitation goods and grow toward an original luxury brand. Business decisions are meaningful, with a playful tone and humour. See the [game-design brief](docs/game-design.md) for the first business loop and clearly labelled placeholder economy.

## Open the project

1. Clone `Cytrance/Jeweler` with GitHub Desktop.
2. Use the standard Godot edition with GDScript. Use Godot 4.7.2, the verified cloud editor version. The project declares the 4.7 feature series; confirm your Windows editor version and record version changes explicitly.
3. In Godot's Project Manager, import `jewel-rpg/project.godot`.

The renderer is Compatibility. The prototype opens a Continue / New game screen. A new business starts in the founder's modest apartment and shares one business state across the apartment and contemporary plaza. Use **Save (F6)** or **Save & Quit**; normal window closing also saves. Continue restores the business, including paid orders, calendar, market progress, and interrupted reports. See [save and continue](docs/save-and-continue.md) for backup recovery and limitations. The apartment has tiled floors/walls and reusable solid furniture. Its computer orders imitation rings for next-morning delivery; its bed lets you sleep until 08:00 after resolving midnight refunds. The apartment door and plaza exit use the same destination menu, with a 30-game-minute journey. See [the apartment and deliveries walkthrough](docs/apartment-and-deliveries.md).

At the plaza, WASD or arrows move the direction-facing chibi founder. Reusable stalls, planters, trees, and lamps combine artwork with collision. The founder's stall requires available stock before opening and runs a one-minute market session with reputation-dependent attendance: choose each visitor's price and truthful or misleading claim. Closing skips to 18:00; refunds settle at midnight, and an unaffordable refund batch ends the run in prison. The HUD tracks shared cash, available rings, revenue, and reputation. See [the timed-market walkthrough](docs/market-session.md), [customer sales](docs/customer-sales.md), [day and refunds](docs/day-and-refunds.md), and [the modular-plaza walkthrough](docs/modular-plaza.md). The earlier immediate supplier purchase interaction is a historical learning checkpoint; playable stock sourcing now uses the apartment computer.
Earlier learning checkpoints are explained in [first scene](docs/first-scene.md), [movement](docs/player-movement.md), [collision](docs/player-collision.md), and [sign dialogue](docs/sign-dialogue.md). Their placeholder descriptions refer to those checkpoints. See [the animation walkthrough](docs/player-animation.md) for frame animation, facing, and playtest steps. The plaza has reusable physical edge collision that keeps the full founder sprite on screen; the apartment has its own solid room shell.

The cloud setup has restored Godot 4.7.2 at `/workspace/tools/godot/bin/godot`; its version command was verified. The older system-default `godot` remains installed, so cloud checks must use the explicit executable path. A successful headless check does not verify appearance on Windows.

## Development workflow

Save files locally, commit a small understandable checkpoint, and push to share it on GitHub. Work on a task branch rather than directly on `main`. Review the pull request and playtest gameplay changes before merging. Squash and merge when a single feature commit is clearer than the intermediate checkpoints. A branch may contain several separately documented checkpoints when the project manager authorizes batching. The project manager tested and squash-merged the combined directional-walking and starter-purchase checkpoints into `main` at `37f1681`. That demonstrated that squashing combines the full branch changes, rather than selecting only its latest commit. The project manager tested the timed-market revision and merged the combined sales, refunds, and market branch into `main` at `4093d6d`. The project manager approved apartment, travel, orders, and sleep; that checkpoint was fast-forward merged and published on `main` at `9053091`. Save/continue is the next approved development checkpoint on `feat/save-continue`; it remains unmerged for review.

Before working on your PC, fetch and pull the intended branch in GitHub Desktop. Before agents work in the cloud, they must fetch, inspect local status, and safely check out or update the intended branch while preserving local work. Fetch downloads remote history; it does not update the checked-out files by itself. Synchronization is not automatic. Avoid simultaneous edits to the same files across machines.

Agent responsibilities are in [AGENTS.md](AGENTS.md). Milestones and acceptance checks are in [docs/roadmap.md](docs/roadmap.md).

## Repository layout

- `jewel-rpg/`: Godot project and future game assets, scenes, and scripts.
- `docs/`: project planning and explanations.
- `LICENSE`: repository license; preserve it.

Godot's generated `.godot/` directory is ignored. Commit source assets and their supported import settings, not the generated cache. Never commit credentials.
