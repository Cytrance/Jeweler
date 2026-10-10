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

func check_art(visual: Sprite2D, label: String) -> void:
	check(visual != null and visual.texture != null, label + " texture loads")
	if visual == null or visual.texture == null:
		return
	check(visual.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, label + " uses nearest filtering")
	check(is_equal_approx(visual.scale.x, visual.scale.y), label + " retains source aspect ratio")
	var image := visual.texture.get_image()
	check(image != null and not image.is_empty(), label + " has image data")
	if image == null or image.is_empty():
		return
	var source := Rect2(Vector2.ZERO, image.get_size())
	var frame := visual.region_rect if visual.region_enabled else source
	check(source.encloses(frame), label + " crop is within source")
	# Visible framing uses the same alpha threshold as the asset handoff.
	var minimum := Vector2i(image.get_width(), image.get_height())
	var maximum := Vector2i(-1, -1)
	for y in image.get_height():
		for x in image.get_width():
			if image.get_pixel(x, y).a >= 16.0 / 255.0:
				minimum = minimum.min(Vector2i(x, y))
				maximum = maximum.max(Vector2i(x, y))
	var visible := Rect2(Vector2(minimum), Vector2(maximum - minimum + Vector2i.ONE))
	check(visible.has_area() and frame.encloses(visible), label + " keeps visible source pixels")

func _run() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	check(packed != null, "main scene loads")
	if packed == null:
		quit(1)
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	var plaza := scene.get_node("Market/Plaza") as Sprite2D
	var stall := scene.get_node("Obstacle/Visual") as Sprite2D
	var board := scene.get_node("Sign/Visual") as Sprite2D
	check_art(plaza, "plaza")
	check_art(stall, "stall")
	check_art(board, "board")
	if plaza != null and plaza.texture != null:
		var bounds := plaza.transform * plaza.get_rect()
		check(bounds.encloses(Rect2(0, 0, 960, 540)), "plaza covers initial view without stretching")
	if stall != null and stall.texture != null:
		var bounds := stall.transform * stall.get_rect()
		check(absf(bounds.size.x - 240.0) < 0.01 and absf(bounds.end.y - 32.0) < 0.01, "stall is readable and grounded at collider bottom")
	if board != null and board.texture != null:
		var bounds := board.transform * board.get_rect()
		check(absf(bounds.size.y - 90.0) < 0.01 and absf(bounds.end.y - 34.0) < 0.01, "board remains shorter than founder and grounded")
	scene.queue_free()
	await process_frame
	print("Market art checks: ", checks, "; failures: ", failures)
	quit(1 if failures else 0)
