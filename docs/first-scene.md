# First running scene

This milestone makes the project runnable. It contains a static placeholder, with no movement, scripts, or finished art.

## Try the branch on Windows

1. Save your work and close Godot before switching branches. In GitHub Desktop, preserve any uncommitted changes before continuing.
2. After the branch is pushed, click **Fetch origin**, then choose `feat/first-scene` under **Current branch**. Pull updates if offered. Checking out this branch changes your local files; it does not merge anything into `main`.
3. Open `jewel-rpg/project.godot` with Godot 4.7.2.
4. In the FileSystem panel, open `scenes/main.tscn`. The Scene panel shows its nodes.
5. Press **F5** (Run Project). Confirm a cyan rectangle appears in the center of the initial 960 × 540 view, then stop with **F8**. Report any errors shown in Godot's debugger.

The coding agent reported successful headless import and a ten-frame runtime check with Godot 4.7.2. Independent review confirmed the scene tree, dimensions, main-scene path, and viewport settings match the requirements. The Windows visual check is pending. Review approval and cloud headless checks do not replace this check. Return your results to the project manager workflow before merging.

## What the files mean

A **node** is one building block with a particular job. The root `Main` node is a `Node2D`, which provides a position and other 2D transform properties. Its `PlayerPlaceholder` child is a `Polygon2D` that draws a 32 × 48 cyan rectangle, positioned at (480, 270). It has no movement behavior.

A **scene** is a saved tree of nodes. `main.tscn` stores this tree and its properties as text, so Git can show changes to it. Scenes can later be reused as building blocks for characters and maps.

The **main scene** is the project's starting scene. `project.godot` points to it, so **F5** runs the project from that scene. **F6** runs whichever scene is currently open instead; this is useful for checking an individual scene.

The editor lets you inspect and modify the scene. Running the project starts a separate game session; seeing a shape in the editor alone does not prove the game runs. Saving writes files locally, committing records a checkpoint, and pushing shares that checkpoint on GitHub.
