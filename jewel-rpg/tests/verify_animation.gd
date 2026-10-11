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

func frames(count: int) -> void:
	for index in count:
		await physics_frame
		await process_frame

func press(action: String) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	root.push_input(event)
	event = InputEventAction.new()
	event.action = action
	event.pressed = false
	root.push_input(event)

func _run() -> void:
	var scene = load("res://scenes/main.tscn").instantiate()
	for child in scene.get_children():
		if child.name not in ["PlayerPlaceholder", "Obstacle", "Sign"]:
			child.free()
	scene.get_node("Sign").position = Vector2(360, 270)
	root.add_child(scene)
	var player = scene.get_node("PlayerPlaceholder")
	var visual := player.get_node("Visual") as AnimatedSprite2D
	await frames(2)
	var rest := visual.position
	check(visual.animation == &"idle_down" and not visual.is_playing(), "starts facing down in a still idle pose")
	var directions := {"move_down": "down", "move_up": "up", "move_right": "side", "move_left": "side"}
	for action in directions:
		player.position = Vector2(200, 350)
		Input.action_press(action)
		await frames(2)
		check(visual.animation == StringName("walk_" + directions[action]) and visual.is_playing(), action + " selects walking direction")
		check(visual.flip_h == (action == "move_left"), action + " uses correct side mirroring")
		var seen_frames := {}
		var lowest := rest.y
		var bob_in_bounds := true
		for index in 32:
			await frames(1)
			seen_frames[visual.frame] = true
			lowest = minf(lowest, visual.position.y)
			bob_in_bounds = bob_in_bounds and visual.position.x == rest.x and visual.position.y >= rest.y - 2.001 and visual.position.y <= rest.y
		check(bob_in_bounds, action + " bob affects only visual within two pixels")
		check(seen_frames.size() >= 3 and lowest < rest.y - 1.0, action + " advances poses and bobs during movement")
		Input.action_release(action)
		await frames(2)
		check(visual.animation == StringName("idle_" + directions[action]) and not visual.is_playing() and visual.frame == 0, action + " release keeps facing and stops at idle")
		check(visual.position == rest, action + " release resets bob")
	player.position = Vector2(200, 350)
	Input.action_press("move_right")
	Input.action_press("move_up")
	await frames(2)
	check(visual.animation == &"walk_side" and not visual.flip_h, "equal diagonal input consistently chooses side view")
	Input.action_release("move_right")
	Input.action_release("move_up")
	player.position = Vector2(480, 270)
	Input.action_press("move_right")
	await frames(90)
	check(visual.animation == &"idle_side" and not visual.is_playing() and visual.position == rest, "fully blocked body faces wall without walking or bobbing")
	Input.action_press("move_down")
	await frames(8)
	check(visual.animation == &"walk_side" and visual.is_playing(), "sliding along wall still animates actual movement")
	Input.action_release("move_right")
	Input.action_release("move_down")
	player.position = Vector2(400, 270)
	await frames(3)
	Input.action_press("move_right")
	await frames(3)
	press("interact")
	check(player.movement_locked and visual.animation == &"idle_side" and not visual.is_playing() and visual.position == rest, "opening dialogue immediately clears walk and bob")
	var locked_position: Vector2 = player.position
	await frames(8)
	check(player.position == locked_position and visual.position == rest, "dialogue keeps physics and visual still despite held input")
	press("ui_cancel")
	await frames(3)
	check(not player.movement_locked and visual.animation == &"walk_side" and visual.is_playing(), "closing dialogue resumes held movement animation")
	Input.action_release("move_right")
	scene.queue_free()
	await process_frame
	print("Animation checks: ", checks, "; failures: ", failures)
	quit(1 if failures else 0)
