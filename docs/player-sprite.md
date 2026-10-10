# First static player sprite

This milestone replaces the cyan player rectangle with a transparent jeweler-apprentice image. Only the drawing changes: WASD and arrow keys, collision with the orange obstacle, and E/Escape sign dialogue retain their existing behavior.

## Try the branch on Windows

1. Save work and close Godot. Preserve uncommitted edits before switching branches.
2. After the branch is pushed, fetch in GitHub Desktop, select `feat/player-sprite`, and pull if offered. This checks out the proposal without merging it into `main`.
3. Open `jewel-rpg/project.godot` in Godot 4.7.2 and press F5.
4. Confirm that the apprentice replaces the cyan rectangle, with no opaque background around the character. Faint low-alpha fringe remains in the generated asset; check whether it is visible or distracting on the game background. Check that the character is readable at the actual game size, rather than only in a large image preview.
5. Move in all directions with both control sets. The same pose remains visible in every direction: animation and turning are deferred.
6. Approach the orange obstacle from all sides and slide along an edge. The existing rectangular collision shape remains; the character's irregular outline is not a new collision shape.
7. Approach the sign, press E, confirm movement stops, and close with E or Escape. Check the debugger for errors.
8. Stop with F8 and report appearance, behavior, and any errors before approving the merge.

There are still no screen boundaries. Restart if you move offscreen. Windows visual approval is pending; headless tests cannot establish how readable the artwork is on your monitor.

## A texture is an image; a sprite draws it

The source PNG contains image pixels and an alpha channel for transparency. `Sprite2D` is the Godot node that draws the imported texture in the scene. The player remains a `CharacterBody2D`, with the same script and `CollisionShape2D`; changing its visual child does not change movement logic.

Source image size and rendered size are different. A generated image can have a large canvas and transparent margins. A texture region selects the part to display, while the sprite's scale determines how large that region appears in the game. Centering aligns the selected rectangle with the player origin; it does not automatically align every opaque pixel or the character's feet with collision geometry.

Nearest filtering selects nearby source pixels without smoothing between them. It avoids blur from linear filtering, but does not turn generated artwork into exact low-resolution pixel art. A static generated image can have inconsistent pixel sizes, soft edges, or details that disappear when reduced. This asset is an initial art-workflow experiment; the project manager still approves the style and readability.

## Actual integration settings

- Source: `assets/player/jeweler_idle_front.png`, 1024 × 1536 RGBA.
- Displayed region: `Rect2(251, 121, 508, 1302)`.
- Uniform scale: about `0.03686636`, calculated as `48 / 1302`.
- Rendered rectangle: about 18.73 × 48 game pixels, centered on the existing 32 × 48 collider.
- Filtering: nearest; import: lossless texture compression with mipmaps disabled.

The region includes the source pixels whose alpha is at least 16/255 and excludes most low-alpha exterior residue. It is not a guarantee of flawless transparency. Because the illustration is narrower than the collider, blocking can happen before its visible side touches the orange obstacle. That is expected for this unchanged collision geometry; a later art/collision design decision can refine it.

See [the provisional art guide](art-guide.md) and [asset origins](asset-origins.md) for the brief, generation method, and limitations.

## Asset handoff and version control

The sprite agent supplies the image, art guidance, and origin record. The coding agent integrates it into the scene. The reviewer checks that the image and scene agree and that existing behavior still passes verification. These roles share a specification rather than editing each other's files without coordination.

Commit the source PNG and its `.import` settings. Godot generates the runtime texture cache under `.godot/`; that cache is ignored and recreated when another machine imports the source image. The repository license alone does not establish a generated asset's origin: consult the art documentation and its recorded limitations.

## Verification

Independent review inspected the scene diff, PNG alpha bounds and framing, import settings, and test harness. The only scene behavior-related edit is replacing the visual node; the player script, input settings, collider, and sign logic are unchanged. Source PNG and import settings are included for commit, and the generated `.godot/` cache remains ignored.

The reviewer independently ran a Godot 4.7.2 headless editor import (exit code 0), then all three suites: 19 movement/collision checks, 17 interaction checks, and 12 sprite integration checks passed with exit code 0. Sprite checks cover texture availability and transparency, source-region containment, inclusion of pixels above the alpha threshold, and alignment within the unchanged collider. They do not establish visual quality or a native pixel grid.

Run the sprite suite from the repository root:

```bash
env XDG_DATA_HOME=/workspace/tools/data XDG_CONFIG_HOME=/workspace/tools/config XDG_CACHE_HOME=/workspace/tools/cache /workspace/tools/godot/bin/godot --headless --path jewel-rpg --script res://tests/verify_sprite.gd
```

Windows keyboard, actual in-game readability, fringe appearance, and art approval remain the project manager's checks above.
