extends SceneTree

var failures := 0
var checks := 0

func check(ok: bool, label: String) -> void:
	checks += 1
	if ok:
		print("PASS: ", label)
	else:
		push_error("FAIL: " + label)
		failures += 1

func _initialize() -> void:
	_run.call_deferred()

# Wait for actual engine physics updates, then observe their completed movement.
func frames(count: int) -> void:
	for index in count:
		await physics_frame
		await process_frame

func _run() -> void:
	var scene = load("res://scenes/main.tscn").instantiate()
	# Verify player/stall behavior without editable scenery blocking the fixture.
	for child in scene.get_children():
		if child.name not in ["PlayerPlaceholder", "Obstacle"]:
			child.free()
	root.add_child(scene)
	var player = scene.get_node("PlayerPlaceholder")
	await frames(2)
	# The layout milestone can run just collision checks without repeating input tests.
	if not "--collision-only" in OS.get_cmdline_user_args():
		# Keep basic movement checks far from the obstacle.
		var start := Vector2(200, 200)
		player.position = start
		await frames(15)
		check(player.position.is_equal_approx(start), "idle remains still")
		var cases := {"move_left": Vector2.LEFT, "move_right": Vector2.RIGHT, "move_up": Vector2.UP, "move_down": Vector2.DOWN}
		var duration := 30.0 / Engine.physics_ticks_per_second
		for action in cases:
			player.position = start
			Input.action_press(action)
			await frames(30)
			check((player.position - start).distance_to(cases[action] * player.speed * duration) < 0.1, action + " direction and pixels/second")
			Input.action_release(action)
			var stopped: Vector2 = player.position
			await frames(5)
			check(player.position.is_equal_approx(stopped), action + " release stops")
		player.position = start
		Input.action_press("move_right")
		Input.action_press("move_down")
		await frames(30)
		var diagonal: Vector2 = player.position - start
		check(absf(diagonal.length() - player.speed * duration) < 0.1, "diagonal distance equals straight distance")
		check(diagonal.x > 0 and diagonal.y > 0 and is_equal_approx(diagonal.x, diagonal.y), "diagonal direction")
		Input.action_release("move_right")
		Input.action_release("move_down")
		var bindings := {"move_left": [KEY_A, KEY_LEFT], "move_right": [KEY_D, KEY_RIGHT], "move_up": [KEY_W, KEY_UP], "move_down": [KEY_S, KEY_DOWN]}
		for action in bindings:
			var physical := false
			var arrow := false
			for event in InputMap.action_get_events(action):
				if event is InputEventKey:
					physical = physical or event.physical_keycode == bindings[action][0]
					arrow = arrow or event.keycode == bindings[action][1]
			check(physical and arrow, action + " physical WASD and arrow bindings")

	# Infer contact from actual scene geometry, so a resized stall is checked correctly.
	var obstacle = scene.get_node("Obstacle")
	var obstacle_collider = obstacle.get_node("CollisionShape2D")
	var player_collider = player.get_node("CollisionShape2D")
	var half_width: float = obstacle_collider.shape.size.x / 2.0 + player_collider.shape.size.x / 2.0
	var left_contact: float = obstacle.position.x + obstacle_collider.position.x - half_width
	var right_contact: float = obstacle.position.x + obstacle_collider.position.x + half_width
	player.position = Vector2(480, 270)
	Input.action_press("move_right")
	await frames(90)
	Input.action_release("move_right")
	check(absf(player.position.x - left_contact) < 0.2 and absf(player.position.y - 270.0) < 0.1, "obstacle blocks approach from left")
	var contact: Vector2 = player.position
	Input.action_press("move_right")
	Input.action_press("move_down")
	await frames(12)
	Input.action_release("move_right")
	Input.action_release("move_down")
	check(absf(player.position.x - contact.x) < 0.2 and player.position.y > contact.y + 20, "diagonal input slides along vertical edge")
	var before_away: Vector2 = player.position
	Input.action_press("move_left")
	await frames(15)
	Input.action_release("move_left")
	check(player.position.x < before_away.x - 40, "player can move away from obstacle")
	player.position = Vector2(800, 270)
	Input.action_press("move_left")
	await frames(90)
	Input.action_release("move_left")
	check(absf(player.position.x - right_contact) < 0.2 and absf(player.position.y - 270.0) < 0.1, "obstacle blocks approach from right")
	scene.queue_free()
	await process_frame
	print("Verification checks: ", checks, "; failures: ", failures)
	quit(1 if failures else 0)
