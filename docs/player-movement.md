# First player movement

The cyan placeholder now moves using WASD or arrow keys. This is one small programming milestone: no collision, boundaries, animation, or finished art.

## Try the branch on Windows

1. Save your work and close Godot. Preserve any uncommitted changes in GitHub Desktop before switching branches.
2. After the branch is pushed, click **Fetch origin**, select `feat/player-movement` under **Current branch**, and pull updates if offered. This changes your local files without merging into `main`.
3. Open `jewel-rpg/project.godot` using Godot 4.7.2 and press **F5**.
4. Click the running game view to give it keyboard focus. Try W, A, S, D, then each arrow key. Each should move the rectangle in the corresponding direction.
5. Release the keys: movement should stop immediately. Hold W+D or Up+Right: diagonal movement should not be faster than straight movement.
6. Check Godot's debugger for errors. Report your results before approving the merge.

There are no obstacles or screen boundaries. If the rectangle leaves the view, stop with **F8** and restart with **F5** to restore its initial position. After the approved merge, switch to `main`, fetch and pull to get the merged checkpoint.

The Windows playtest is pending. The coding agent reported successful headless import and runtime checks using Godot 4.7.2. Independent review inspected the script, scene attachment, input settings, and test harness, and reran the harness: all 16 assertions passed with exit code 0.

The harness calls the real attached script with simulated input actions. It checks idle behavior, all four directions and distances, stopping on release, diagonal distance and direction, consistent displacement across split update intervals, and configured key bindings. It does not simulate actual keyboard events or prove Windows appearance and focus behavior.

Run the check from the repository root with your Godot 4.7.2 executable:

```bash
godot --headless --path jewel-rpg --script res://tests/verify_movement.gd
```

In the cloud, use the verified executable explicitly and writable settings/cache locations:

```bash
env XDG_DATA_HOME=/workspace/tools/data XDG_CONFIG_HOME=/workspace/tools/config XDG_CACHE_HOME=/workspace/tools/cache /workspace/tools/godot/bin/godot --headless --path jewel-rpg --script res://tests/verify_movement.gd
```

## Read the script

`jewel-rpg/scripts/player.gd` is attached to the scene's `PlayerPlaceholder` node:

```gdscript
extends Polygon2D

@export var speed: float = 200.0

func _physics_process(delta: float) -> void:
    var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    position += direction * speed * delta
```

- `extends Polygon2D` gives the script the properties of the shape it controls, including `position`. It is not a physics body and does not handle collision.
- `@export` exposes `speed` in the Inspector when you select the node. Its initial value is 200 pixels per second. Changing it in the editor and saving records a source-file change; experimenting in a running game does not automatically change the saved scene.
- `_physics_process` is a Godot callback: the engine calls it at regular physics intervals. `delta` is the elapsed time for an update, in seconds.
- `Input.get_vector` reads four named actions and returns a two-number vector: horizontal and vertical direction. Godot's positive X points right and positive Y points down. With no input, the vector is zero.
- The vector's length is limited to one, so pressing two perpendicular directions does not increase the overall speed.
- `position += ...` adds displacement to the current position. Direction × pixels per second × elapsed seconds gives the distance to move for that update.

## Input actions

`project.godot` stores `move_left`, `move_right`, `move_up`, and `move_down` in the Input Map. Each has a WASD binding and an arrow-key binding. View these under **Project → Project Settings → Input Map**.

The script refers to action names instead of individual keys. We can change bindings without rewriting movement code. The letter bindings use physical key positions, so on a non-QWERTY layout their printed letters may differ; the arrow keys remain an alternative.
