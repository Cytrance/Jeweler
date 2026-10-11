# Directional founder animation

The founder now needs two kinds of movement: the physics body travels through the plaza, while its artwork changes pose. A walking frame does not move the character through the world. The player script still calculates velocity and calls `move_and_slide()`; animation makes that movement readable.

## Scenes, frames, and facing

The player's `Visual` node uses `AnimatedSprite2D` rather than the previous single-frame `Sprite2D`. A `SpriteFrames` resource defines named idle and walk animations. Each frame selects a region of the shared sprite sheet; the PNG supplies artwork, while the resource supplies frame order, timing, and looping.

There are down, up, and side views. Left movement mirrors the right-facing side view. This keeps the first animation set small, but also mirrors the pouch and its strap; anatomically consistent left-side accessories need separate left artwork later.

The script remembers the most recent facing when input stops. Equal diagonal input chooses the side view consistently, instead of switching rapidly between directions. The movement vector remains normalized, so animation does not make diagonal travel faster.

Walking uses alternating leg poses, with a small two-pixel vertical bob of the artwork. The physics body and collider do not bob. The bob supplements the drawn stride; moving an unchanged standing picture up and down would not show the legs walking.

## Movement versus intent

Facing follows movement input, but the walk loop follows actual displacement. If the player presses into a wall and stays in place, it faces the wall and returns to idle. Sliding along an obstacle still animates because the body is moving. Releasing input returns to idle without forgetting the last facing.

Opening the board dialogue immediately stops the stride and resets the visual bob. The existing movement lock still stops physical movement; closing the message lets normal control resume. The player's 32 × 48 solid rectangle, speed, and plaza prop placements are unchanged.

## Try it on Windows

1. Preserve local edits and close Godot. Fetch in GitHub Desktop, select `feat/player-animation`, and pull if offered.
2. Open `jewel-rpg/project.godot` with Godot 4.7.2 and press F5. Click the game view for keyboard focus.
3. Walk down, up, right, and left using WASD, then arrows. Check the front, back, and side poses at normal gameplay size.
4. Watch several steps. The legs should alternate, the figure should bob gently, and its head and clothes should retain a consistent size.
5. Release each direction. The founder should stop stepping and keep that facing. Try diagonal movement and direction changes.
6. Hold movement directly into a stall or tree base. Once physically stopped, the walk cycle should stop. Try sliding along a face and moving away.
7. At the board, open dialogue while walking. The founder should immediately become still. Close with E or Escape, then move again.
8. Walk behind and in front of a tree and the stall. Check that frame changes do not disrupt drawing order or make the feet drift against the ground.
9. Stop with F8 and check the debugger. Report visual or timing problems before merging.

## Learning exercise

Select the player's `Visual` node in `scenes/main.tscn` and open its SpriteFrames resource in the bottom editor. Select a walk animation, inspect the frame order and playback speed, and compare it with its idle animation. Previewing frames here tests the art sequence; running the game tests how input, physics, and animation work together.

Save changes only if you intend to keep them. Changes to frame timing appear in GitHub Desktop just like script changes. You can inspect the diff and discard an experiment before committing it.

## Limits

This is a simple walk cycle at the existing movement speed. It does not add a sprint control, clothing customization, carrying poses, tools, or a native low-resolution art pipeline. The sheet must be judged in motion; passing resource checks does not prove that generated poses form a smooth animation.

## Resource geometry

`assets/player/founder_walk_sheet.png` supplies nine explicitly measured regions, listed in [the art guide](art-guide.md). `assets/player/founder_frames.tres` gives each region logical margins so all frames share a 240 × 381 source-pixel canvas, centred horizontally and aligned at the bottom. The visual uses one uniform scale of `96 / 369` (about `0.2601626`): the neutral down pose stays 96 game pixels high, and other poses range up to about 99.12 pixels. The canvas displays at about 62.44 × 99.12 pixels; visible artwork is narrower.

The resting visual centre is `(0, -25.5609756)`, placing the shared canvas bottom at local y=24. The unchanged collider is 32 × 48. Each walk loops through idle, stride A, idle, stride B at eight frames per second. The repeated neutral frames make a deliberately simple first cycle.

## Verification

The coding agent reported a successful Godot 4.7.2 editor import and **128 focused checks passed**: 31 animation behaviour checks, 61 frame/transparency/alignment checks across nine poses, 19 movement checks, and 17 interaction checks. Movement and interaction were relevant because this checkpoint changes the shared player script; unchanged prop-art and scenery suites were not automatically repeated.

The reviewer inspected the player-script and main-scene diff, SpriteFrames resource, source sheet, measured regions, and tests. The reviewer independently reran only `verify_animation.gd`: **31 checks passed, zero failures, exit code 0**. This verifies actual directional travel, mirroring, animation progression and bounded bob, release-to-idle, diagonal priority, blocked movement, sliding, and immediate dialogue locking/resumption.

From the repository root, run the new behaviour check with the pinned cloud engine:

```bash
env XDG_DATA_HOME=/workspace/tools/data XDG_CONFIG_HOME=/workspace/tools/config XDG_CACHE_HOME=/workspace/tools/cache /workspace/tools/godot/bin/godot --headless --path jewel-rpg --script res://tests/verify_animation.gd
```

Automated results establish behaviour and resource alignment. They do not establish smooth motion or final art quality. The project manager's Windows review of timing, feet, framing, and directional appearance remains pending before merge.

The coordinating agent also rendered the actual game through Godot 4.7.2's Compatibility renderer on a virtual Xorg display with Mesa software graphics. A temporary preview driver exercised right, down, left, and up travel and pauses in the existing level. An eight-second, 240-frame capture and sampled sequential frames showed distinct front/back/profile views, visible neutral-to-stride leg changes, correct left mirroring, retained idle facing, and readable scale without obvious clipping or distracting fringe. The reviewer inspected gameplay-size down-walk, down-idle, and up-idle captures. Side-step leg identity remains subtle, so the Windows motion review is still needed. The preview driver and recording are task artifacts, not new game controls.

No game-script errors were reported. The unsupported-VSync warning and dummy audio backend belong to the cloud display environment; this checkpoint adds no audio feature.
