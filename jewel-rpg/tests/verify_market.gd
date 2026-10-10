extends SceneTree

var failures := 0
var checks := 0

func _initialize() -> void:
	_run.call_deferred()

func frames(count: int) -> void:
	for index in count:
		await physics_frame
		await process_frame

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + label)

func _run() -> void:
	var scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	var player = scene.get_node("PlayerPlaceholder")
	var stall = scene.get_node("Obstacle")
	var half_height: float = stall.get_node("CollisionShape2D").shape.size.y / 2.0 + player.get_node("CollisionShape2D").shape.size.y / 2.0
	await frames(3)
	# The horizontal tabletop must block above and below, not just its short sides.
	player.position = stall.position + Vector2(0, -140)
	Input.action_press("move_down")
	await frames(50)
	Input.action_release("move_down")
	check(absf(player.position.y - (stall.position.y - half_height)) < 0.2, "stall blocks approach from above")
	player.position = stall.position + Vector2(0, 140)
	Input.action_press("move_up")
	await frames(50)
	Input.action_release("move_up")
	check(absf(player.position.y - (stall.position.y + half_height)) < 0.2, "stall blocks approach from below")
	# Walk past both ends: cosmetic scenery and widened stall must leave clear routes.
	for side in [-1, 1]:
		player.position = stall.position + Vector2(side * 140, 140)
		Input.action_press("move_up")
		await frames(80)
		Input.action_release("move_up")
		check(player.position.y < stall.position.y - half_height, "route around stall end " + str(side))
	scene.queue_free()
	await process_frame
	print("Market checks: ", checks, "; failures: ", failures)
	quit(1 if failures else 0)
