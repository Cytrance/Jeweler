extends SceneTree

var checks := 0
var failures := 0

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + label)

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	check(packed != null, "main scene loads with animated sprite resource")
	if packed == null:
		quit(1)
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	var player := scene.get_node("PlayerPlaceholder") as CharacterBody2D
	var visual := player.get_node("Visual") as AnimatedSprite2D
	check(visual != null and visual.sprite_frames != null, "player visual has SpriteFrames")
	if visual != null and visual.sprite_frames != null:
		check(visual.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "nearest filtering preserves artwork edges")
		check(is_equal_approx(visual.scale.x, visual.scale.y), "all directions use one uniform aspect-preserving scale")
		var collider := player.get_node("CollisionShape2D") as CollisionShape2D
		var shape := collider.shape as RectangleShape2D
		check(shape != null and shape.size == Vector2(32, 48), "player collider remains 32 by 48")
		var neutral := visual.sprite_frames.get_frame_texture(&"idle_down", 0) as AtlasTexture
		var canvas := neutral.get_size()
		var seen := {}
		for animation in visual.sprite_frames.get_animation_names():
			for index in visual.sprite_frames.get_frame_count(animation):
				var texture := visual.sprite_frames.get_frame_texture(animation, index) as AtlasTexture
				if texture == null or seen.has(texture):
					continue
				seen[texture] = true
				var image := texture.atlas.get_image()
				var region := Rect2i(texture.region)
				check(Rect2i(Vector2i.ZERO, image.get_size()).encloses(region), "frame crop stays within source sheet")
				check(image.detect_alpha() != Image.ALPHA_NONE, "frame sheet preserves transparency")
				check(texture.get_size() == canvas, "frame uses shared logical canvas without individual rescaling")
				var minimum := region.end
				var maximum := Vector2i(-1, -1)
				for y in range(region.position.y, region.end.y):
					for x in range(region.position.x, region.end.x):
						if image.get_pixel(x, y).a >= 16.0 / 255.0:
							minimum = minimum.min(Vector2i(x, y))
							maximum = maximum.max(Vector2i(x, y))
				check(maximum.x >= minimum.x, "frame contains visible character pixels")
				var visible := Rect2(Vector2(minimum - region.position) + texture.margin.position, Vector2(maximum - minimum + Vector2i.ONE))
				var bounds := visual.transform * Rect2(visible.position - canvas / 2.0, visible.size)
				check(absf(bounds.end.y - 24.0) < 0.2, "all pose feet stay aligned with collider bottom at rest")
				check(bounds.size.y >= 80.0 and bounds.size.y <= 110.0 and bounds.size.x >= 32.0 and bounds.size.x <= 75.0, "directional pose stays readable at gameplay scale")
				if texture == neutral:
					check(absf(bounds.size.y - 96.0) < 0.02, "front neutral retains 96-pixel reference height")
		check(seen.size() == 9, "three directions contain three distinct source poses each")
	scene.queue_free()
	await process_frame
	print("Sprite checks: ", checks, "; failures: ", failures)
	quit(1 if failures else 0)
