# One obstacle and collision

The cyan player still moves with WASD or arrow keys. It now has a physics body that stops at one orange obstacle and slides along its surface. Screen boundaries, interactions, animation, and finished art are deferred.

## Try the branch on Windows

1. Save your work and close Godot. Preserve any uncommitted changes in GitHub Desktop before switching branches.
2. After the branch is pushed, click **Fetch origin**, select `feat/player-collision`, and pull updates if offered. This changes local files without merging into `main`.
3. Open `jewel-rpg/project.godot` with Godot 4.7.2 and press **F5**. Click the game view to give it keyboard focus.
4. Check that WASD and arrow keys still work and releasing the keys stops the player. Try diagonals in open space: they should not be faster.
5. Move right toward the orange obstacle. The player should stop at its left face without passing through it.
6. Hold a diagonal direction toward that face: the player should slide upward or downward along it. Release the keys, then move away; the player should respond immediately.
7. Walk around the obstacle and approach its right, top, and bottom faces. Each should block movement. Try sliding from the opposite side too.
8. Check the debugger for errors, stop with **F8**, and report your results before approving a merge.

There are no screen boundaries. If the player leaves the view, press **F8**, then **F5** to restore its starting position. After the approved merge, switch to `main`, fetch and pull to receive the merged checkpoint.

The Windows playtest is pending. Cloud checks and independent review cannot establish how the game appears or responds to physical keyboard input on your PC.

## Read the scene tree

```text
Main                         Node2D
├── PlayerPlaceholder        CharacterBody2D
│   ├── Visual               Polygon2D
│   └── CollisionShape2D     CollisionShape2D
└── Obstacle                 StaticBody2D
    ├── Visual               Polygon2D
    └── CollisionShape2D     CollisionShape2D
```

A **physics body** participates in Godot's collision simulation. `CharacterBody2D` is intended for characters controlled by code. `StaticBody2D` represents a stationary obstacle.

A `Polygon2D` draws a shape, but drawing alone does not block movement. Each body needs a `CollisionShape2D` child, whose shape resource defines the physical area. Here, rectangle shape resources match the drawn rectangles: 32 × 48 for the player and 64 × 160 for the obstacle. The player starts at (480, 270); the obstacle is centred at (650, 270).

Separating the visual child from the body lets us eventually replace the cyan polygon with a sprite without changing the movement body's job. This milestone keeps the shapes centred and unscaled so visual and physical edges agree.

## Read the movement change

The earlier script directly changed a `Polygon2D`'s position. That bypassed collision handling. The script now extends `CharacterBody2D` and follows this pattern:

```gdscript
velocity = direction * speed
move_and_slide()
```

`direction` still comes from `Input.get_vector`, which limits diagonal input to a length of one. `speed` remains 200 pixels per second.

**Velocity** is speed with a direction, measured here in pixels per second. **Displacement** is the distance moved during an update, measured in pixels. Previously, we calculated displacement ourselves using `direction * speed * delta` and added it to `position`.

`move_and_slide()` uses the body's velocity and the physics update's elapsed time internally. Therefore, we do **not** multiply velocity by `delta`: doing so would apply the elapsed time twice. Godot attempts the movement, detects collisions, and slides along contacted surfaces. The script runs in `_physics_process`; its unused time parameter is named `_delta` to make that intentional.

The player uses floating motion mode, appropriate for top-down movement: surfaces are treated as walls rather than floors and ceilings. There is no gravity in this script. Both bodies use collision layer 1 and mask 1, so the player can detect the obstacle.

## Verification

The coding agent reported successful headless editor import, runtime, and automated checks using Godot 4.7.2. Independent review inspected the scene, script, input bindings, and harness and reran the harness: all 19 assertions passed with exit code 0.

The harness instantiates the real main scene and waits for actual engine physics updates. Its 15 movement/input checks cover idle behavior, four directions and distances, stopping on release, diagonal distance and direction, and both configured key sets. Four collision checks cover blocking from the left, sliding down the left face, moving away, and blocking from the right.

It simulates named input actions, not physical keyboard events. Top/bottom approaches, opposite-side sliding, visual alignment, and Windows keyboard focus remain manual playtest checks; do not infer them from the automated count.

Run from the repository root using Godot 4.7.2:

```bash
godot --headless --path jewel-rpg --script res://tests/verify_movement.gd
```

The test keeps its original movement filename because it extends the existing regression checks. In the cloud, select the matching executable explicitly and use writable settings/cache locations:

```bash
env XDG_DATA_HOME=/workspace/tools/data XDG_CONFIG_HOME=/workspace/tools/config XDG_CACHE_HOME=/workspace/tools/cache /workspace/tools/godot/bin/godot --headless --path jewel-rpg --script res://tests/verify_movement.gd
```
