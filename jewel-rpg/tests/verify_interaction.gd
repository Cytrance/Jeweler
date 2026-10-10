extends SceneTree

var checks := 0
var failures := 0

func _initialize() -> void:
	_run.call_deferred()

func check(ok: bool, label: String) -> void:
	checks += 1
	if ok:
		print("PASS: ", label)
	else:
		failures += 1
		push_error("FAIL: " + label)

func frames(count: int = 3) -> void:
	for index in count:
		await physics_frame
		await process_frame

# Deliver events through the viewport, rather than calling the sign's handler.
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
	root.add_child(scene)
	var player = scene.get_node("PlayerPlaceholder")
	var sign = scene.get_node("Sign")
	await frames()
	check(not sign.player_nearby and not sign.prompt.visible, "far player has no prompt")
	press("interact")
	check(not sign.dialogue.visible, "interact cannot open from far away")
	player.position = Vector2(400, 270)
	await frames()
	check(sign.player_nearby and sign.prompt.visible, "physics proximity shows prompt")
	check(sign.prompt.text == "E: Read sign", "prompt names interaction key")
	press("interact")
	check(sign.dialogue.visible and not sign.prompt.visible, "interact opens panel and hides prompt")
	check(sign.get_node("DialogueLayer/Dialogue/Margin/Text").text.contains("First day. Small stock, big plans."), "dialogue introduces modern business setting")
	var origin: Vector2 = player.position
	Input.action_press("move_right")
	await frames(12)
	check(player.position.is_equal_approx(origin) and player.velocity == Vector2.ZERO, "dialogue locks actual physics movement")
	var echo := InputEventKey.new()
	echo.physical_keycode = KEY_E
	echo.pressed = true
	echo.echo = true
	root.push_input(echo)
	check(sign.dialogue.visible, "key repeat does not close dialogue")
	press("interact")
	check(not sign.dialogue.visible and not player.movement_locked, "second interact closes and unlocks")
	await frames(3)
	check(player.position.x > origin.x, "held movement resumes after close")
	Input.action_release("move_right")
	press("interact")
	check(sign.dialogue.visible, "fresh interact can reopen")
	press("ui_cancel")
	check(not sign.dialogue.visible and not player.movement_locked, "Escape action dismisses and unlocks")
	press("interact")
	player.position = Vector2(480, 270)
	await frames()
	check(not sign.player_nearby and not sign.prompt.visible, "leaving physics range hides prompt")
	check(not sign.dialogue.visible and not player.movement_locked, "leaving range closes dialogue and unlocks movement")
	root.push_input(echo)
	check(not sign.dialogue.visible, "repeat cannot reopen closed dialogue")
	# A real second physics body in range must not unlock interaction for the player.
	var other := CharacterBody2D.new()
	var collider := CollisionShape2D.new()
	collider.shape = CircleShape2D.new()
	other.add_child(collider)
	other.position = Vector2(360, 270)
	scene.add_child(other)
	await frames()
	check(not sign.player_nearby, "unrelated body cannot enable interaction")
	var bound := false
	for event in InputMap.action_get_events("interact"):
		if event is InputEventKey and event.physical_keycode == KEY_E:
			bound = true
	check(bound, "interact maps to physical E")
	scene.queue_free()
	await process_frame
	print("Interaction checks: ", checks, "; failures: ", failures)
	quit(1 if failures else 0)
