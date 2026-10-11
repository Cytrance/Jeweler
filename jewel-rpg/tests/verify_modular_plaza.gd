extends SceneTree

var checks := 0
var failures := 0

func _initialize() -> void:
	_run.call_deferred()

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + label)

func frames(count: int) -> void:
	for index in count:
		await physics_frame
		await process_frame

func _run() -> void:
	var scene = load("res://scenes/main.tscn").instantiate()
	# Keep the real player, planter, and board in a controlled fixture. Level
	# decoration can be rearranged without changing these collision contracts.
	for child in scene.get_children():
		if child.name not in ["PlayerPlaceholder", "PlanterTopLeft", "Sign"]:
			child.free()
	scene.get_node("PlanterTopLeft").position = Vector2(150, 150)
	root.add_child(scene)
	await frames(3)
	var player = scene.get_node("PlayerPlaceholder")
	var planter = scene.get_node("PlanterTopLeft")
	var half_size: Vector2 = (planter.get_node("CollisionShape2D").shape.size + player.get_node("CollisionShape2D").shape.size) / 2.0
	var cases := {"move_right": Vector2.LEFT, "move_left": Vector2.RIGHT, "move_down": Vector2.UP, "move_up": Vector2.DOWN}
	for action in cases:
		var side: Vector2 = cases[action]
		player.position = planter.position + side * 100.0
		await frames(2)
		Input.action_press(action)
		await frames(60)
		Input.action_release(action)
		var expected: Vector2 = planter.position + side * half_size
		check(player.position.distance_to(expected) < 0.2, "planter blocks " + action + " approach through engine physics")
	var contact: Vector2 = player.position
	Input.action_press("move_down")
	await frames(15)
	Input.action_release("move_down")
	check(player.position.y > contact.y + 40.0, "player can walk away from planter")
	# A newly placed instance inherits its solid footprint without adding nodes.
	var copy = load("res://scenes/props/flower_planter.tscn").instantiate()
	copy.position = Vector2(480, 450)
	scene.add_child(copy)
	await frames(2)
	player.position = Vector2(380, 450)
	Input.action_press("move_right")
	await frames(60)
	Input.action_release("move_right")
	check(absf(player.position.x - (copy.position.x - half_size.x)) < 0.2, "fresh planter instance inherits working collision")
	var board = scene.get_node("Sign")
	var board_body = board.get_node("SolidFootprint")
	player.position = board.position + board_body.position + Vector2(0, 100)
	await frames(2)
	Input.action_press("move_up")
	await frames(45)
	Input.action_release("move_up")
	check(absf(player.position.y - (board.position.y + board_body.position.y + 34.0)) < 0.2, "price board has solid base separate from proximity area")
	contact = player.position
	Input.action_press("move_down")
	await frames(15)
	Input.action_release("move_down")
	check(player.position.y > contact.y + 40.0, "player can walk away from board base")
	# Place a second configured board before the original in input order.
	var second_board = load("res://scenes/props/price_board.tscn").instantiate()
	second_board.player_path = player.get_path()
	second_board.position = board.position
	scene.add_child(second_board)
	scene.move_child(second_board, 0)
	player.position = board.position + Vector2(-60, 0)
	await frames(3)
	board._set_dialogue(true)
	second_board._on_body_exited(player)
	check(player.movement_locked, "inactive board exit cannot unlock another board dialogue")
	second_board._on_body_entered(player)
	var event := InputEventAction.new()
	event.action = "interact"
	event.pressed = true
	root.push_input(event)
	check(not board.dialogue.visible and not second_board.dialogue.visible and not player.movement_locked, "E closes owning board instead of opening earlier nearby board")
	var unassigned_board = load("res://scenes/props/price_board.tscn").instantiate()
	unassigned_board.position = Vector2(-500, -500)
	scene.add_child(unassigned_board)
	await frames(2)
	check(unassigned_board.player == null and not unassigned_board.prompt.visible and not unassigned_board.dialogue.visible, "unassigned standalone board stays inactive safely")
	unassigned_board._set_dialogue(false)
	check(not unassigned_board.dialogue.visible, "unassigned board close does not access absent player")
	scene.queue_free()
	await process_frame
	print("Modular plaza checks: ", checks, "; failures: ", failures)
	quit(1 if failures else 0)
