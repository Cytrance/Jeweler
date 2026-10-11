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
	root.push_input(event)

func click(button: Control) -> void:
	var point := button.get_global_rect().get_center()
	var motion := InputEventMouseMotion.new()
	motion.position = point
	root.push_input(motion, true)
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		root.push_input(event, true)
	await frames()

func _run() -> void:
	var scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await frames()
	var state = scene.get_node("BusinessState")
	var player = scene.get_node("PlayerPlaceholder")
	var sales = scene.get_node("Obstacle")
	var supplier = scene.get_node("SupplierCounter")
	var sign = scene.get_node("Sign")
	var visual = player.get_node("Visual")
	var hud = scene.get_node("BusinessHUD/Panel/Margin/Summary")
	state.changed.connect(func(): transactions += 1)
	check(sales.price_choice.get_selected_id() == 20 and sales.claim_choice.selected == 0, "default price20 and truthful claim")
	var result: Dictionary = state.serve_customer(20, false)
	check(not result.sold and state.cash == 100 and state.stock == 0 and transactions == 0, "no stock rejection changes nothing")
	state.stock = 10
	result = state.serve_customer(25, false)
	check(not result.sold and state.cash == 100 and state.stock == 10, "unlisted price rejected without mutation")
	for price in [15, 20, 30]:
		var before_cash: int = state.cash
		var before_stock: int = state.stock
		var before_rep: int = state.reputation
		var before_transactions := transactions
		result = state.serve_customer(price, false)
		if price <= 20:
			check(result.sold and state.cash == before_cash + price and state.stock == before_stock - 1 and state.reputation == before_rep + 1, "truthful sale accepted at %d" % price)
		else:
			check(not result.sold and state.cash == before_cash and state.stock == before_stock and state.reputation == before_rep and transactions == before_transactions, "truthful overpriced rejection changes nothing")
	for price in [15, 20, 30]:
		var before_cash: int = state.cash
		var before_rep: int = state.reputation
		var before_pending: int = state.misleading_sales.size()
		result = state.serve_customer(price, true)
		check(result.sold and state.cash == before_cash + price and state.reputation == before_rep and state.misleading_sales.size() == before_pending + 1, "misleading sale records risk and credits full proceeds at %d" % price)
	check(state.revenue == 100 and state.economy.materials == "Plated brass • simulated stone", "revenue totals accepted sales; claims never change actual materials")
	state.cash = 9
	var before_stock: int = state.stock
	check(not state.purchase_one() and state.stock == before_stock and state.cash == 9, "insufficient cash purchase rejected")
	state.cash += 1
	check(state.purchase_one() and state.cash == 0, "full cash spendable despite misleading sales")
	check(hud.text.contains("Cash: 0") and not hud.text.contains("Held"), "HUD displays spendable cash without reservations")
	key(KEY_N)
	check(state.stock == before_stock + 1, "closed sales panel ignores serve key")
	# Walk into the preserved founder stall from its reachable right side.
	player.position = Vector2(790, 270)
	Input.action_press("move_left")
	await frames(22)
	Input.action_release("move_left")
	await frames()
	check(player.position.x >= 755 and player.position.x <= 760 and sales.player_nearby, "founder stall remains solid and sales range is reachable")
	Input.action_press("move_down")
	await frames(2)
	key(KEY_E)
	check(sales.panel.visible and player.movement_locked and not visual.is_playing(), "sales opens and immediately stops walk animation")
	var held_position: Vector2 = player.position
	await frames()
	check(player.position == held_position, "sales panel freezes held movement")
	key(KEY_E, true)
	check(sales.panel.visible, "interact echo cannot close sales")
	var before_transactions := transactions
	key(KEY_N)
	check(transactions == before_transactions + 1 and sales.feedback.text.contains("Sold for 20"), "one N press produces one truthful sale")
	key(KEY_N, true)
	check(transactions == before_transactions + 1, "serve echo produces no repeated transaction")
	check(sales.details.text.contains(state.economy.materials), "sales panel always shows actual materials")
	await click(sales.serve_button)
	check(transactions == before_transactions + 2, "real GUI click produces one sale")
	key(KEY_P)
	check(sales.price_choice.get_selected_id() == 30 and sales.claim_choice.selected == 0, "P changes price independently from claim")
	key(KEY_P, true)
	check(sales.price_choice.get_selected_id() == 30, "price echo cannot cycle twice")
	key(KEY_C)
	check(sales.claim_choice.selected == 1 and sales.price_choice.get_selected_id() == 30, "C changes claim independently from price")
	key(KEY_C, true)
	check(sales.claim_choice.selected == 1, "claim echo cannot toggle twice")
	key(KEY_N)
	check(sales.feedback.text.contains("complaints may") and sales.details.text.contains("10–25%"), "misleading GUI sale reports risk without promising a complaint")
	key(KEY_ESCAPE)
	await frames()
	check(not sales.panel.visible and not player.movement_locked and player.position.y > held_position.y and visual.is_playing(), "closing sales resumes held movement")
	Input.action_release("move_down")
	player.position = sales.position + Vector2(0, 80)
	await frames()
	key(KEY_E)
	check(sales.panel.visible, "sales reopens while nearby")
	player.position = Vector2(440, 350)
	await frames(4)
	check(not sales.panel.visible and not player.movement_locked and not sales.prompt.visible, "range exit closes owned sales lock")
	player.position = supplier.position + Vector2(106, 0)
	await frames(4)
	key(KEY_E)
	sales._on_body_exited(player)
	key(KEY_N)
	check(supplier.panel.visible and player.movement_locked and not sales.panel.visible, "inactive sales cannot unlock or transact through supplier")
	key(KEY_ESCAPE)
	player.position = sign.position + Vector2(-60, 0)
	await frames(4)
	key(KEY_E)
	sales._on_body_exited(player)
	check(sign.dialogue.visible and player.movement_locked, "inactive sales preserves existing board lock")
	key(KEY_ESCAPE)
	scene.queue_free()
	await frames()
	print("Sales checks: %d passed, %d failed" % [checks - failures, failures])
	quit(1 if failures else 0)
