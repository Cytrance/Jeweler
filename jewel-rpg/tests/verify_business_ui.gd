extends SceneTree
var checks := 0
var failures := 0
func check(value: bool, label: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(label)
func _initialize() -> void:
	_run.call_deferred()
func frames() -> void:
	await physics_frame
	await process_frame
func key(code: int) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = true
	root.push_input(event)
	event = InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	root.push_input(event)
func click(button: Control) -> void:
	await frames()
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
	root.size = Vector2i(960, 540)
	var scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await frames()
	var state = scene.get_node("BusinessState")
	var clock = scene.get_node("MarketClock")
	var orders = scene.get_node("DeliveryOrders")
	var travel = scene.get_node("AreaTravel")
	var hud = scene.get_node("BusinessHUD/Panel/Margin/Summary")
	clock.set_process(false)
	check(travel.open_menu("order", null), "Computer opens")
	check(travel.quantity.value == 1, "Single ring remains default")
	check(travel.action.text.contains("Total 10"), "Default total shown before purchase")
	check(travel.feedback.text.contains("day 2 at 08:00"), "Arrival date shown")
	travel.quantity.value = 5
	check(travel.action.text.contains("Total 50"), "Quantity updates total")
	await click(travel.action)
	check(state.cash == 50 and orders.pending_quantity() == 5 and state.stock == 0, "Mouse purchases selected batch, not immediate stock")
	check(hud.text.contains("On order  5") and hud.text.contains("Available rings  0"), "Pending and available inventories distinct")
	travel.quantity.value = 10
	check(travel.action.disabled, "Unaffordable action disabled")
	key(KEY_B)
	check(state.cash == 50 and orders.pending_quantity() == 5, "Keyboard cannot bypass affordability")
	travel.quantity.value = 1
	key(KEY_B)
	check(state.cash == 40 and orders.pending_quantity() == 6, "B respects selected quantity")
	travel.close_menu()
	travel.open_menu("travel", null)
	check(not travel.quantity.visible, "Quantity absent from travel menu")
	travel.close_menu()
	travel.open_menu("order", null)
	check(travel.quantity.value == 1, "Fresh order resets quantity")
	travel.close_menu()
	clock.day = 2
	clock.hour = 8.0
	orders.check_deliveries()
	check(hud.text.contains("Available rings  6") and hud.text.contains("On order  0"), "HUD refreshes when delivery moves inventory")
	var market = scene.get_node("MarketSession")
	market._refresh_report()
	check(market.details.text.contains("6PM") and market.details.text.contains("Midnight"), "Six pm report identifies separate later refund settlement")
	var cycle = scene.get_node("DayCycle")
	cycle.present_report(state.settle_day(2))
	check(cycle.heading.text.contains("Midnight"), "Financial report distinct from six pm")
	check(cycle.details.text.contains("Cash before") and cycle.details.text.contains("Cash remaining"), "Refund report shows before and after cash")
	await frames()
	await frames()
	check(Rect2(0, 0, 960, 540).encloses(cycle.report.get_global_rect()), "Midnight report fits viewport")
	state.imprisoned = true
	cycle.present_report({"day": 2, "misleading_count": 20, "complaints": 20, "refund_total": 1000, "cash_before": 40})
	await frames()
	await frames()
	check(Rect2(0, 0, 960, 540).encloses(cycle.report.get_global_rect()), "Prison report fits viewport")
	cycle.report.hide()
	state.imprisoned = false
	state.begin_day()
	clock.day = 3
	clock.hour = 8.0
	clock.awaiting_report = false
	var player = scene.get_node("PlayerPlaceholder")
	player.movement_locked = false
	travel.set_area("plaza")
	var stall = scene.get_node("Obstacle")
	stall.player_nearby = true
	stall._set_open(true)
	stall._start_day()
	await frames()
	await frames()
	check(market.active, "Geometry uses actual market start flow")
	check(Rect2(0, 0, 960, 540).encloses(stall.panel.get_global_rect()), "Active stall fits viewport including start feedback")
	check(not stall.panel.get_global_rect().intersects(scene.get_node("BusinessHUD/Panel").get_global_rect()), "Active stall leaves business HUD visible")
	check(not stall.panel.get_global_rect().intersects(cycle.get_node("ClockPanel").get_global_rect()), "Active stall leaves clock visible")
	stall._set_open(false)
	market.report.show()
	await frames()
	await frames()
	check(Rect2(0, 0, 960, 540).encloses(market.report.get_global_rect()), "Six pm report fits viewport")
	print("Business UI checks: %d passed, %d failed" % [checks - failures, failures])
	scene.queue_free()
	await process_frame
	quit(1 if failures else 0)
