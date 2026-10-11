# Jewel RPG

A modern 2D jewellery-business RPG, built in small milestones to learn agentic coding, Git, and Godot. Start with a modest pop-up selling imitation goods and grow toward an original luxury brand. Business decisions are meaningful, with a playful tone and humour. See the [game-design brief](docs/game-design.md) for the first business loop and clearly labelled placeholder economy.

## Open the project

1. Clone `Cytrance/Jeweler` with GitHub Desktop.
2. Use the standard Godot edition with GDScript. Use Godot 4.7.2, the verified cloud editor version. The project declares the 4.7 feature series; confirm your Windows editor version and record version changes explicitly.
3. In Godot's Project Manager, import `jewel-rpg/project.godot`.

The renderer is Compatibility. The implemented prototype is `jewel-rpg/scenes/main.tscn`: a direction-facing chibi founder with a simple walking animation, moved with WASD or arrow keys, a small contemporary plaza with a solid jewellery stall, flower planters, flowering trees, and streetlamps, and a nearby price board with E/Escape dialogue. Ground is painted with a `TileMapLayer`; the stall, board, planter, tree, and lamp are reusable scenes. See [the modular-plaza walkthrough](docs/modular-plaza.md) for how artwork becomes reusable game objects and how to test this checkpoint. The [plaza-scenery walkthrough](docs/plaza-scenery.md) explains grounded collision and drawing order for taller props. A supplier counter now lets the founder purchase starter stock, with visible cash and ring inventory. See [the stock-purchases walkthrough](docs/stock-purchases.md). The founder's stall now starts a one-minute market session with a reputation-dependent daily customer quota. Visible customers arrive one at a time; choose each offer's price and truthful or misleading claim. The HUD tracks cash, stock, revenue, and reputation. See [the timed-market walkthrough](docs/market-session.md). See [the customer-sales walkthrough](docs/customer-sales.md). A repeating outdoor day/night cycle now settles randomly requested refunds at day end; unpaid refund totals end the run in prison. See [the day-and-refunds walkthrough](docs/day-and-refunds.md). The unmerged wooden workshop experiment is superseded. The earlier [modern-market walkthrough](docs/modern-market.md) records the preceding visual checkpoint.

Earlier learning checkpoints are explained in [first scene](docs/first-scene.md), [movement](docs/player-movement.md), [collision](docs/player-collision.md), and [sign dialogue](docs/sign-dialogue.md). Their placeholder descriptions refer to those checkpoints. See [the animation walkthrough](docs/player-animation.md) for frame animation, facing, and playtest steps. Movement can still leave the screen; screen boundaries remain deferred.

The cloud setup has restored Godot 4.7.2 at `/workspace/tools/godot/bin/godot`; its version command was verified. The older system-default `godot` remains installed, so cloud checks must use the explicit executable path. A successful headless check does not verify appearance on Windows.

## Development workflow

Save files locally, commit a small understandable checkpoint, and push to share it on GitHub. Work on a task branch rather than directly on `main`. Review the pull request and playtest gameplay changes before merging. Squash and merge when a single feature commit is clearer than the intermediate checkpoints. A branch may contain several separately documented checkpoints when the project manager authorizes batching. The project manager tested and squash-merged the combined directional-walking and starter-purchase checkpoints into `main` at `37f1681`. That demonstrated that squashing combines the full branch changes, rather than selecting only its latest commit. The current `feat/customer-sales` branch contains the sales checkpoint, a revision to refund risk and day/night progression, and a further revision adding a finite timed market. The project manager tested sales and requested this polish before merging; all checkpoints remain on one branch for a combined pull request.

Before working on your PC, fetch and pull the intended branch in GitHub Desktop. Before agents work in the cloud, they must fetch, inspect local status, and safely check out or update the intended branch while preserving local work. Fetch downloads remote history; it does not update the checked-out files by itself. Synchronization is not automatic. Avoid simultaneous edits to the same files across machines.

Agent responsibilities are in [AGENTS.md](AGENTS.md). Milestones and acceptance checks are in [docs/roadmap.md](docs/roadmap.md).

## Repository layout

- `jewel-rpg/`: Godot project and future game assets, scenes, and scripts.
- `docs/`: project planning and explanations.
- `LICENSE`: repository license; preserve it.

Godot's generated `.godot/` directory is ignored. Commit source assets and their supported import settings, not the generated cache. Never commit credentials.
