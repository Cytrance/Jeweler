extends SceneTree

var checks := 0
var failures := 0

func check(ok: bool, label: String) -> void:
	checks += 1
	if ok:
		print("PASS: ", label)
	else:
		failures += 1
		push_error("FAIL: " + label)

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	check(packed != null, "main scene loads with sprite resource")
	if packed == null:
		quit(1)
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	var player := scene.get_node("PlayerPlaceholder") as CharacterBody2D
	var visual := player.get_node("Visual") as Sprite2D
	check(visual != null, "player visual is Sprite2D")
	if visual != null:
		check(visual.texture != null, "sprite texture is loaded")
		check(visual.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "nearest filtering preserves hard pixel edges")
		if visual.texture != null:
			var image := visual.texture.get_image()
			check(image != null and not image.is_empty(), "imported texture contains an image")
			if image != null and not image.is_empty():
				var source_rect := Rect2(Vector2.ZERO, image.get_size())
				# Ignore the generated asset's faint alpha fringe (below 16/255).
				var minimum := Vector2i(image.get_width(), image.get_height())
				var maximum := Vector2i(-1, -1)
				for y in image.get_height():
					for x in image.get_width():
						if image.get_pixel(x, y).a >= 16.0 / 255.0:
							minimum = minimum.min(Vector2i(x, y))
							maximum = maximum.max(Vector2i(x, y))
				var used_rect := Rect2(Vector2(minimum), Vector2(maximum - minimum + Vector2i.ONE))
				check(used_rect.has_area(), "image contains visible character pixels")
				check(image.detect_alpha() != Image.ALPHA_NONE, "image has transparent background")
				var frame := visual.region_rect if visual.region_enabled else source_rect
				check(source_rect.encloses(frame), "sprite region is inside source texture")
				check(frame.encloses(used_rect), "sprite region keeps character pixels at alpha 16/255 or above")
				var collider := player.get_node("CollisionShape2D") as CollisionShape2D
				var shape := collider.shape as RectangleShape2D
				check(shape != null and shape.size == Vector2(32, 48), "existing player collider stays 32 by 48")
				if shape != null:
					var bounds := visual.transform * visual.get_rect()
					var collision_bounds := Rect2(collider.position - shape.size / 2.0, shape.size)
					check(collision_bounds.encloses(bounds), "sprite display bounds fit existing collider")
					check(bounds.get_center().is_equal_approx(collider.position), "sprite stays centered on collider")
	scene.queue_free()
	await process_frame
	print("Sprite checks: ", checks, "; failures: ", failures)
	quit(1 if failures else 0)
