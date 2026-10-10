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

Source image size and rendered size are different. A generated image can have a large canvas and transparent margins. A texture region selects the part to display, while the sprite's scale determines how large that region appears in the game. A centered sprite initially places the selected rectangle around its own origin. We then offset that visual upward to align its lower edge with the collision shape; centering alone does not align feet.

Nearest filtering selects nearby source pixels without smoothing between them. It avoids blur from linear filtering, but does not turn generated artwork into exact low-resolution pixel art. A static generated image can have inconsistent pixel sizes, soft edges, or details that disappear when reduced. This asset is an initial art-workflow experiment; the project manager still approves the style and readability.

## Actual integration settings

- Source: `assets/player/jeweler_idle_front.png`, 1024 × 1536 RGBA.
- Displayed region: `Rect2(251, 121, 508, 1302)`.
- Uniform scale: about `0.07373272`, calculated as `96 / 1302`.
- Rendered rectangle: about 37.46 × 96 game pixels.
- Visual offset: `(0, -24)`, horizontally centered with its lower edge aligned to the bottom of the existing 32 × 48 collider.
- Filtering: nearest; import: lossless texture compression with mipmaps disabled.

The region includes the source pixels whose alpha is at least 16/255 and excludes most low-alpha exterior residue. It is not a guarantee of flawless transparency. The first integration displayed the character at 48 pixels tall. The project manager found that too small beside the sign, so this revision doubles its height to improve readability.

The unchanged collider now covers the lower part of the taller visual. The visible head and sides can overlap the obstacle even while the collision body stops correctly: the image outline is not the physics boundary. Check whether that relationship feels acceptable in the game; a later art/collision design decision can refine it.

See [the provisional art guide](art-guide.md) and [asset origins](asset-origins.md) for the brief, generation method, and limitations.

## Asset handoff and version control

The sprite agent supplies the image, art guidance, and origin record. The coding agent integrates it into the scene. The reviewer checks that the image and scene agree and that existing behavior still passes verification. These roles share a specification rather than editing each other's files without coordination.

Commit the source PNG and its `.import` settings. Godot generates the runtime texture cache under `.godot/`; that cache is ignored and recreated when another machine imports the source image. The repository license alone does not establish a generated asset's origin: consult the art documentation and its recorded limitations.

## Verification

Independent review inspected the scene diff, PNG alpha bounds and framing, import settings, and test harness. The only scene behavior-related edit is replacing the visual node; the player script, input settings, collider, and sign logic are unchanged. Source PNG and import settings are included for commit, and the generated `.godot/` cache remains ignored.

For the original 48-pixel integration, the reviewer independently ran a Godot 4.7.2 headless editor import (exit code 0), then all three suites: 19 movement/collision checks, 17 interaction checks, and 12 sprite integration checks passed with exit code 0. Those results are historical evidence for the unchanged movement and interaction logic.

For the current 96-pixel revision, independent review checked the scene scale/offset and updated sprite assertions. The focused sprite suite checks texture availability and transparency, region containment, inclusion of pixels above the alpha threshold, target display height, horizontal alignment, and lower-edge alignment with the unchanged collider. It does not establish visual quality or a native pixel grid. The coordinating agent ran Godot 4.7.2 editor import and the focused sprite suite: import completed without errors, and all 12 sprite checks passed, both with exit code 0. Independent review inspected those reported results rather than duplicating the same run. Unchanged movement and interaction suites were not rerun for this visual-only adjustment.

Run the sprite suite from the repository root:

```bash
env XDG_DATA_HOME=/workspace/tools/data XDG_CONFIG_HOME=/workspace/tools/config XDG_CACHE_HOME=/workspace/tools/cache /workspace/tools/godot/bin/godot --headless --path jewel-rpg --script res://tests/verify_sprite.gd
```

Windows keyboard, actual in-game readability, fringe appearance, and art approval remain the project manager's checks above.
