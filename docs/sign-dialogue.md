# Sign interaction and short dialogue

A brown sign sits left of the cyan player. Walk nearby to reveal `E: Read sign`, press E to read one message, and press E or Escape to close it. Movement is locked while the message is open. The orange obstacle and existing controls remain.

## Try the branch on Windows

1. Save your work and close Godot. Preserve uncommitted edits before switching branches.
2. After the branch is pushed, fetch in GitHub Desktop, select `feat/sign-dialogue`, and pull updates if offered. This checks out the proposal without merging it into `main`.
3. Open `jewel-rpg/project.godot` using Godot 4.7.2, press F5, and click the game view for keyboard focus.
4. Press E at the starting position: nothing should open. Walk left toward the brown sign. The prompt should appear nearby and disappear when you move away.
5. Approach again and press E. Read the welcome message near the bottom of the view. The proximity prompt should hide while the message is open.
6. Try WASD and arrow keys while reading. The player should stay still. Hold E: keyboard repeat should not repeatedly open and close the message.
7. Release E, then press it again to close the message. Move again to confirm movement resumes. Reopen the message and close it using Escape too.
8. Retest the orange obstacle and check the debugger for errors. Stop with F8 and report your results before approving a merge.

There are no screen boundaries, inventory, choices, or finished sprites. The sign is detectable but not solid: the player can walk through its drawing. Restart with F8 then F5 if you leave the screen.

The Windows visual and physical-keyboard playtest is pending. Headless checks cannot replace it.

## Detection is different from blocking

The orange obstacle uses `StaticBody2D` to block movement. The sign uses `Area2D` to detect an overlapping physics body without blocking it. Both have a `CollisionShape2D`, but the parent node determines the shape's job.

The sign's circular detection shape has a radius of 72 pixels and is centred at (360, 270). Its collision mask watches layer 1, which contains the player. The script checks that the detected body is the actual player, so other physics bodies cannot activate the prompt. Detection uses the player's collision shape, not only its centre.

## Signals report events

An area emits `body_entered` and `body_exited` signals when a physics body crosses its detection boundary. In `_ready()`, `sign.gd` connects these signals to two handler functions. Those handlers update `player_nearby` and the prompt.

This is event-driven behavior: Godot tells the sign when something happens. The sign does not repeatedly calculate the distance to the player on every frame. Movement still reads the currently held movement actions during each physics update because continuous movement needs continuous input.

## UI nodes and screen coordinates

The sign owns these additional nodes:

```text
Sign                         Area2D
├── Visual / Board           Polygon2D drawings
├── CollisionShape2D         circular detection shape
├── Prompt                   Label near the sign in the world
└── DialogueLayer            CanvasLayer
    └── Dialogue             PanelContainer
        └── Margin           MarginContainer
            └── Text         Label
```

`Label`, `PanelContainer`, and `MarginContainer` are **Control nodes**, intended for interface layout. The panel draws a background, the margin adds padding, and the label displays the fixed message. The panel is anchored near the bottom of the viewport.

`CanvasLayer` draws this dialogue in a separate canvas, so its position is relative to the screen instead of the sign's world position. The proximity label stays attached to the sign. There is no camera movement yet, but this separation makes their intended responsibilities clear.

## Input, state, and responsibilities

`project.godot` names a new input action, `interact`, mapped to physical E. Escape uses Godot's existing `ui_cancel` action.

`sign.gd` receives button presses in `_unhandled_input(event)`. Unlike polling whether a key is held, this handles discrete input events. `is_action_pressed(..., false)` rejects keyboard repeat events, so holding E does not repeatedly toggle dialogue. Once the sign handles an action it marks the event handled, preventing later unhandled-input listeners from also responding to that event.

The sign has two pieces of state: whether the player is nearby and whether the dialogue panel is visible. `_set_dialogue(open)` updates the panel, proximity prompt, and player's `movement_locked` flag together. Leaving the area closes the dialogue defensively.

`player.gd` still owns movement and collision. When `movement_locked` is true, it sets velocity to zero and skips movement for that physics update. Closing the message clears the flag; held movement keys can then move the player immediately. We lock only the player, rather than pausing the entire game.

This is deliberately one sign with one message. The sign explicitly finds `PlayerPlaceholder` in its parent scene. Renaming that node requires updating the reference. A reusable interaction or dialogue framework is deferred until a later requirement justifies it.

## Verification

The coding agent reported a successful Godot 4.7.2 headless editor import and runtime check. Independent review inspected the scene, input settings, both scripts, and both test harnesses, then reran both suites with that engine: 19 movement/collision checks and 17 interaction checks passed, each with exit code 0.

The interaction suite instantiates the actual main scene. It waits for real physics proximity signals and delivers interaction actions through the viewport input pipeline. It checks out-of-range behavior, the prompt, opening/closing, movement lock and resumption, closing/unlocking when leaving the detection area, keyboard-repeat rejection, Escape-action closing, unrelated-body filtering, welcome text, and the physical E binding. Most interaction events are simulated named actions; inspecting the E binding is not a physical-keyboard test.

The existing regression suite covers movement and selected obstacle blocking/sliding checks. The UI anchors are configured relative to the viewport, but these headless checks do not verify Windows text fit, actual screen appearance, or keyboard focus. Those remain the project manager's manual checks above.

Run from the repository root with the pinned cloud executable and writable settings/cache paths:

```bash
env XDG_DATA_HOME=/workspace/tools/data XDG_CONFIG_HOME=/workspace/tools/config XDG_CACHE_HOME=/workspace/tools/cache /workspace/tools/godot/bin/godot --headless --path jewel-rpg --script res://tests/verify_movement.gd
env XDG_DATA_HOME=/workspace/tools/data XDG_CONFIG_HOME=/workspace/tools/config XDG_CACHE_HOME=/workspace/tools/cache /workspace/tools/godot/bin/godot --headless --path jewel-rpg --script res://tests/verify_interaction.gd
```
