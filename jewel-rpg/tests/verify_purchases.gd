extends SceneTree

var checks := 0
var failures := 0
var transactions := 0

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + label)

func _initialize() -> void:
	_run.call_deferred()

func frames(count: int = 2) -> void:
	for index in count:
		await physics_frame
		await process_frame

func key(code: int, echo: bool = false) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = true
	event.echo = echo
	root.push_input(event)
	event = InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = false
	root.push_input(event)

func _run() -> void:
	var scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await frames()
	var player = scene.get_node("PlayerPlaceholder")
	var state = scene.get_node("BusinessState")
	var supplier = scene.get_node("SupplierCounter")
	var sign = scene.get_node("Sign")
	var hud = scene.get_node("BusinessHUD/Panel/Margin/Summary")
	var visual = player.get_node("Visual")
	state.changed.connect(func(): transactions += 1)
	check(state.cash == 100 and state.stock == 0 and transactions == 0, "fresh game starts cash100 stock0 without a transaction")
	check(hud.text.contains("100 credits") and hud.text.contains("stock: 0"), "HUD displays fresh state")
	key(KEY_B)
	check(state.cash == 100, "closed panel ignores buy input")
	key(KEY_E)
	check(not supplier.panel.visible, "out-of-range interact does not open supplier")
	# Approach from open space at the right: verify an actual solid collider stops movement.
	player.position = Vector2(410, 440)
	Input.action_press("move_left")
	await frames(22)
	Input.action_release("move_left")
	await frames()
	check(player.position.x >= 375.0 and player.position.x <= 380.0, "supplier stall is solid on actual map")
	check(supplier.player_nearby and supplier.prompt.visible, "solid-counter side is reachable and shows prompt")
	Input.action_press("move_down")
	await frames(2)
	key(KEY_E)
	check(supplier.panel.visible and player.movement_locked and not visual.is_playing(), "opening supplier immediately locks movement and stops animation")
	var locked_position: Vector2 = player.position
	await frames()
	check(player.position == locked_position, "held movement stays frozen in supplier")
	key(KEY_E, true)
	check(supplier.panel.visible, "held interact echo cannot toggle panel")
	key(KEY_B)
	check(state.cash == 90 and state.stock == 1 and transactions == 1, "one physical B creates exactly one purchase")
	key(KEY_B, true)
	check(state.cash == 90 and transactions == 1, "held buy echo creates no repeat purchases")
	check(hud.text.contains("90 credits") and hud.text.contains("stock: 1") and supplier.details.text.contains("Stock: 1"), "HUD and open panel react to state signal")
	# Exercise real GUI mouse dispatch, not directly calling the pressed callback.
	await frames()
	var point: Vector2 = supplier.buy_button.get_global_rect().get_center()

	var motion := InputEventMouseMotion.new()
	motion.position = point
	root.push_input(motion, true)
	for pressed in [true, false]:
		var mouse := InputEventMouseButton.new()
		mouse.button_index = MOUSE_BUTTON_LEFT
		mouse.position = point
		mouse.pressed = pressed
		root.push_input(mouse, true)
	await frames()

	check(state.cash == 80 and state.stock == 2 and transactions == 2, "one GUI click creates exactly one purchase")
	for index in 8:
		key(KEY_B)
	check(state.cash == 0 and state.stock == 10 and transactions == 10, "tenth purchase spends exact last10 without negative cash")
	key(KEY_B)
	check(state.cash == 0 and state.stock == 10 and transactions == 10, "eleventh purchase cannot mutate cash stock or emit changed")
	check(supplier.feedback.text.contains("Not enough cash"), "rejected purchase gives explicit feedback")
	key(KEY_ESCAPE)
	check(not supplier.panel.visible and not player.movement_locked, "Escape closes supplier and releases own lock")
	await frames()
	check(player.position.y > locked_position.y and visual.is_playing(), "held movement resumes after closing")
	Input.action_release("move_down")
	player.position = Vector2(376, 440)
	await frames()
	key(KEY_E)
	check(supplier.panel.visible, "E can reopen panel")
	player.position = Vector2(440, 350)
	await frames(4)
	check(not supplier.panel.visible and not player.movement_locked and not supplier.prompt.visible, "leaving range closes owned panel and prompt")
	# Open the existing board, then leave supplier range: inactive supplier must not release its lock.
	player.position = sign.position + Vector2(-60, 0)
	await frames()
	key(KEY_E)
	check(sign.dialogue.visible and player.movement_locked, "existing board keeps interaction ownership")
	supplier._on_body_exited(player)
	key(KEY_B)
	check(sign.dialogue.visible and player.movement_locked and state.stock == 10, "inactive supplier cannot unlock board or buy while board is open")
	key(KEY_ESCAPE)
	check(not player.movement_locked, "board still closes normally")
	# Resource config is authoritative: cost change works without UI constants.
	state.economy = state.economy.duplicate()
	state.economy.unit_cost = 7
	state.cash = 7
	check(state.purchase_one() and state.cash == 0 and state.stock == 11, "transaction uses configured unit cost")
	var before := transactions
	check(not state.purchase_one() and transactions == before, "rejected domain transaction emits no change")
	scene.queue_free()
	await frames()
	print("Purchase checks: %d passed, %d failed" % [checks - failures, failures])
	quit(1 if failures else 0)
