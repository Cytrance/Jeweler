extends SceneTree

var failures := 0

func check(ok: bool, label: String) -> void:
	if ok:
		print("PASS: ", label)
	else:
		push_error("FAIL: " + label)
		failures += 1

func _initialize() -> void:
	var scene = load("res://scenes/main.tscn").instantiate()
	var player = scene.get_node("PlayerPlaceholder")
	var start: Vector2 = player.position
	player._physics_process(0.5)
	check(player.position.is_equal_approx(start), "idle remains still")
	var cases := {"move_left": Vector2.LEFT, "move_right": Vector2.RIGHT, "move_up": Vector2.UP, "move_down": Vector2.DOWN}
	for action in cases:
		player.position = start
		Input.action_press(action)
		player._physics_process(0.5)
		check((player.position - start).is_equal_approx(cases[action] * player.speed * 0.5), action + " direction and pixels/second")
		Input.action_release(action)
		var stopped: Vector2 = player.position
		player._physics_process(0.5)
		check(player.position.is_equal_approx(stopped), action + " release stops")
	player.position = start
	Input.action_press("move_right")
	Input.action_press("move_down")
	player._physics_process(0.5)
	var diagonal: Vector2 = player.position - start
	check(is_equal_approx(diagonal.length(), player.speed * 0.5), "diagonal distance equals straight distance")
	check(diagonal.x > 0 and diagonal.y > 0 and is_equal_approx(diagonal.x, diagonal.y), "diagonal direction")
	Input.action_release("move_right")
	Input.action_release("move_down")
	player.position = start
	Input.action_press("move_right")
	player._physics_process(0.25)
	player._physics_process(0.25)
	check((player.position - start).is_equal_approx(Vector2.RIGHT * player.speed * 0.5), "split delta gives same distance")
	Input.action_release("move_right")
	var bindings := {"move_left": [KEY_A, KEY_LEFT], "move_right": [KEY_D, KEY_RIGHT], "move_up": [KEY_W, KEY_UP], "move_down": [KEY_S, KEY_DOWN]}
	for action in bindings:
		var physical := false
		var arrow := false
		for event in InputMap.action_get_events(action):
			if event is InputEventKey:
				physical = physical or event.physical_keycode == bindings[action][0]
				arrow = arrow or event.keycode == bindings[action][1]
		check(physical and arrow, action + " physical WASD and arrow bindings")
	scene.free()
	print("Movement verification failures: ", failures)
	quit(1 if failures else 0)
