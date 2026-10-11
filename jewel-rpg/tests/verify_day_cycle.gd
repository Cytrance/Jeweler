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

func business(chance: float):
	var node = load("res://scripts/business_state.gd").new()
	node.economy = load("res://resources/prototype_economy.tres").duplicate()
	node.economy.refund_chance_min = chance
	node.economy.refund_chance_max = chance
	root.add_child(node)
	return node

func _run() -> void:
	var zero = business(0.0)
	zero.stock = 2
	zero.serve_customer(30, true)
	zero.serve_customer(20, false)
	check(zero.cash == 150 and zero.revenue == 50 and zero.reputation == 1, "sale proceeds fully credited; truthful gain independent")
	zero.cash = 10
	check(zero.purchase_one() and zero.cash == 0, "misleading proceeds can be spent with future risk")
	var result: Dictionary = zero.settle_day(1)
	check(result.complaints == 0 and zero.cash == 0 and not zero.imprisoned and zero.revenue == 50, "zero probability leaves sales intact even with zero cash")
	check(zero.misleading_sales.is_empty(), "settlement consumes daily risk records")
	var rng_before: int = zero.refund_rng.state
	check(zero.settle_day(1) == result and zero.last_settled_day == 1 and zero.refund_rng.state == rng_before, "same day never rerolls or advances RNG")
	check(not zero.purchase_one() and not zero.serve_customer(20, false).sold, "closed day blocks transactions until Continue")
	check(zero.settle_day(0) == result, "older day cannot settle again")
	var full = business(1.0)
	full.stock = 3
	full.serve_customer(15, true)
	full.serve_customer(30, true)
	full.serve_customer(20, false)
	full.cash = 45
	result = full.settle_day(1)
	check(result.complaints == 2 and result.refund_total == 45, "forced complaints refund exact original selling prices")
	check(full.cash == 0 and full.stock == 2 and full.revenue == 20 and full.reputation == -9 and not full.imprisoned, "exact-cash settlement returns stock reverses revenue and applies reputation loss")
	var snapshot := [full.cash, full.stock, full.revenue, full.reputation]
	full.settle_day(1)
	check(snapshot == [full.cash, full.stock, full.revenue, full.reputation], "duplicate settlement cannot pay or return rings twice")
	full.begin_day()
	full.stock += 1
	full.serve_customer(30, true)
	full.cash = 29
	snapshot = [full.cash, full.stock, full.revenue, full.reputation]
	result = full.settle_day(2)
	check(result.imprisoned and result.cash_before == 29 and result.refund_total == 30, "refund exceeding cash triggers prison")
	check(snapshot == [full.cash, full.stock, full.revenue, full.reputation], "insolvency atomic with no negative cash or partial refunds")
	check(not full.purchase_one() and not full.serve_customer(20, false).sold, "prison blocks all transactions")
	check(full.settle_day(3) == result, "prison cannot settle a later day")
	var seeded_a = business(0.10)
	var seeded_b = business(0.10)
	for node in [seeded_a, seeded_b]:
		node.economy.refund_chance_max = 0.25
		node.refund_rng.seed = 984723
		node.stock = 100
		for index in 100:
			node.serve_customer(30, true)
	var first: Dictionary = seeded_a.settle_day(1)
	var second: Dictionary = seeded_b.settle_day(1)
	check(first == second, "fixed seeds reproduce sampled probability and per-sale decisions")
	check(first.probability >= 0.10 and first.probability <= 0.25 and first.complaints > 0 and first.complaints < 100, "production range yields partial rather than guaranteed complaints")
	for node in [zero, full, seeded_a, seeded_b]:
		node.queue_free()
	var scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await frames()
	var state = scene.get_node("BusinessState")
	var clock = scene.get_node("MarketClock")
	var cycle = scene.get_node("DayCycle")
	var player = scene.get_node("PlayerPlaceholder")
	var sales = scene.get_node("Obstacle")
	clock.set_process(false)
	clock.hour = 8.0
	clock.advance_time(20.0)
	check(is_equal_approx(clock.hour, 9.0) and clock.day == 1, "480 second day advances one hour each20 seconds")
	check(clock.time_label().contains("09:00"), "visible clock gives day and readable time")
	player.movement_locked = true
	clock.advance_time(20.0)
	check(clock.hour == 9.0, "dialogue movement lock pauses clock")
	clock.finish_day()
	check(not clock.awaiting_report, "manual closing cannot steal another panel lock")
	player.movement_locked = false
	check(clock.color_at_hour(12.0) == Color.WHITE and clock.color_at_hour(0.0) == clock.color_at_hour(24.0), "daylight white and midnight tint continuous")
	check(clock.color_at_hour(18.0) != Color.WHITE and clock.color_at_hour(22.0).b > clock.color_at_hour(22.0).r, "warm dusk becomes cooler dark night")
	clock.hour = 18.0
	clock.advance_time(0.0)
	check(scene.get_node("OutdoorTint").color == clock.color_at_hour(18.0), "world CanvasModulate follows clock")
	check(scene.get_node("BusinessHUD") is CanvasLayer and cycle is CanvasLayer, "HUD and report use independent unshaded canvases")
	clock.hour = 23.9
	clock.advance_time(100.0)
	check(clock.awaiting_report and cycle.report.visible and player.movement_locked and state.last_settled_day == 1, "midnight settles once and opens modal report")
	clock.advance_time(100.0)
	check(clock.day == 1 and state.last_settled_day == 1, "large delta cannot skip unsettled days")
	key(KEY_E)
	key(KEY_ESCAPE)
	check(cycle.report.visible and player.movement_locked, "unrelated interaction keys cannot dismiss report or unlock movement")
	await click(cycle.continue_button)
	check(clock.day == 2 and clock.hour == 0.0 and not clock.awaiting_report and not player.movement_locked, "actual Continue click begins next midnight and unlocks")
	player.position = sales.position + Vector2(106, 0)
	await frames(4)
	key(KEY_E)
	check(sales.panel.visible, "sales still opens before manual closing")
	key(KEY_T, true)
	check(not cycle.report.visible and sales.panel.visible, "end day keyboard echo cannot settle")
	key(KEY_T)
	check(cycle.report.visible and not sales.panel.visible and player.movement_locked and state.last_settled_day == 2, "T closes sales before modal acquires lock")
	key(KEY_T)
	check(state.last_settled_day == 2 and player.movement_locked, "repeated T cannot settle twice")
	await click(cycle.continue_button)
	await frames()
	key(KEY_E)
	await click(sales.get_node("UILayer/Panel/Margin/Rows/EndDay"))
	check(state.last_settled_day == 3 and cycle.report.visible, "actual End day button follows same settlement path")
	await click(cycle.continue_button)
	state.economy = state.economy.duplicate()
	state.economy.refund_chance_min = 1.0
	state.economy.refund_chance_max = 1.0
	state.stock = 1
	state.serve_customer(30, true)
	state.cash = 0
	cycle.end_day()
	check(state.imprisoned and cycle.restart_button.visible and not cycle.continue_button.visible and player.movement_locked, "prison report exposes restart only and holds player")
	var prison_hour: float = clock.hour
	clock.advance_time(200.0)
	check(clock.hour == prison_hour, "prison freezes time")
	await click(cycle.restart_button)
	await frames(4)
	check(current_scene != scene and current_scene.get_node("BusinessState").cash == 100 and not current_scene.get_node("BusinessState").imprisoned, "actual restart button reloads a fresh playable run")
	check(current_scene.get_node("MarketClock").day == 1 and not current_scene.get_node("PlayerPlaceholder").movement_locked, "restart resets day and movement lock")
	current_scene.queue_free()
	await frames()
	print("Day/refund checks: %d passed, %d failed" % [checks - failures, failures])
	quit(1 if failures else 0)
