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
	var scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await frames()
	var travel = scene.get_node("AreaTravel")
	var orders = scene.get_node("DeliveryOrders")
	var clock = scene.get_node("MarketClock")
	var state = scene.get_node("BusinessState")
	var player = scene.get_node("PlayerPlaceholder")
	var session = scene.get_node("MarketSession")
	var cycle = scene.get_node("DayCycle")
	clock.set_process(false)
	clock.hour = 8.0
	clock._refresh()
	session.set_process(false)
	check(travel.current_area == "apartment" and scene.get_node("Apartment").visible and not scene.get_node("Market").visible, "new game begins inside apartment")
	check(scene.get_node("Obstacle/Stall").collision_layer == 0 and scene.get_node("SupplierCounter").collision_layer == 0, "inactive plaza and instant supplier have no collision")
	check(not scene.get_node("Obstacle/UILayer/Panel").visible and not scene.get_node("Apartment/Bed/Interaction/Prompt").visible, "area activation preserves hidden prompts and modals")
	check(scene.get_node("OutdoorTint").color == Color.WHITE, "indoor lighting stays untinted")
	player.position = Vector2(540, 285)
	await frames()
	await frames()
	await create_timer(0.1).timeout
	key(KEY_E)
	check(travel.panel.visible and travel.mode == "order" and player.movement_locked, "physical E opens nearby computer menu")
	check("plated brass" in travel.feedback.text.to_lower(), "computer identifies actual imitation composition")
	key(KEY_B, true)
	check(state.cash == 100 and orders.pending_quantity() == 0, "echo B cannot repeat purchases")
	key(KEY_B)
	check(state.cash == 90 and orders.pending_quantity() == 1, "physical B places one order")
	key(KEY_ESCAPE)
	check(not travel.panel.visible and not player.movement_locked, "Escape closes computer without retaining lock")
	player.position = Vector2(755, 300)
	await create_timer(0.1).timeout
	key(KEY_E)
	check(travel.panel.visible and travel.mode == "travel" and "Plaza" in travel.action.text, "physical E opens door destination menu")
	await click(travel.action)
	check(travel.current_area == "plaza" and is_equal_approx(clock.hour, 8.5), "door destination button travels and charges 30 minutes")
	travel.set_area("apartment")
	clock.hour = 8.0
	clock._refresh()
	# Reset only this input fixture so financial boundary checks have simple values.
	state.cash = 100
	orders.pending.clear()
	player.position = Vector2(360, 300)
	Input.action_press("move_left")
	for frame in range(25):
		await physics_frame
	Input.action_release("move_left")
	check(player.position.x >= 327.0 and player.position.x < 359.0, "active reusable bed physically blocks player movement")
	var ray := PhysicsRayQueryParameters2D.create(Vector2(330, 300), Vector2(240, 300), 1)
	check(not player.get_world_2d().direct_space_state.intersect_ray(ray).is_empty(), "bed footprint participates in physics queries")
	check(orders.place_order(2) and state.cash == 80 and state.stock == 0, "orders deduct cash immediately without stock")
	check(orders.place_order() and orders.pending_quantity() == 3, "orders accumulate")
	check(not orders.place_order(100) and state.cash == 70 and orders.pending_quantity() == 3, "unaffordable order changes nothing")
	check(not orders.place_order(0) and not orders.place_order(-1), "invalid quantities rejected")
	orders.check_deliveries()
	check(state.stock == 0, "08am same day does not deliver newly ordered stock")
	clock.hour = 23.99
	check(travel.travel_to("plaza") and clock.awaiting_report and cycle.report.visible, "travel crossing midnight opens refund report")
	check(state.stock == 0 and player.movement_locked, "midnight report blocks delivery and movement")
	cycle._continue()
	await frames()
	check(player.get_world_2d().direct_space_state.intersect_ray(ray).is_empty(), "inactive bed leaves no ghost collision in plaza")
	check(not scene.get_node("Apartment/ComputerDesk/Interaction").nearby, "travel invalidates previous computer proximity")
	check(clock.day == 2 and is_equal_approx(clock.hour, 0.49), "travel remaining minutes resume after midnight report")
	clock.hour = 7.9
	clock._refresh()
	check(state.stock == 0, "delivery waits for 08am")
	clock.advance_minutes(6.0)
	check(state.stock == 3 and orders.pending_quantity() == 0 and orders.notice.visible, "morning delivers pending orders and displays notification")
	orders.check_deliveries()
	check(state.stock == 3, "delivery applies once only")
	check(travel.travel_to("apartment") and scene.get_node("Apartment/Walls").collision_layer == 1 and scene.get_node("Obstacle/Stall").collision_layer == 0, "return enables room collision and disables plaza")
	clock.hour = 18.0
	player.position = Vector2(255, 370)
	await frames()
	await frames()
	await create_timer(0.1).timeout
	key(KEY_E)
	check(travel.panel.visible and travel.mode == "sleep", "physical E opens accessible bed menu")
	await click(travel.action)
	check(clock.awaiting_report and travel.pending_sleep, "bed button settles midnight before morning")
	cycle._continue()
	check(clock.day == 3 and is_equal_approx(clock.hour, 8.0), "Continue wakes next morning at 08am")
	clock.hour = 2.0
	check(travel.sleep_until_morning() and clock.day == 3 and is_equal_approx(clock.hour, 8.0), "after-midnight sleep uses current morning")
	check(travel.open_menu("order", scene.get_node("Apartment/ComputerDesk/Interaction")) and player.movement_locked, "computer owns modal movement lock")
	check(not travel.travel_to("plaza"), "other modal prevents travel")
	travel.close_menu()
	check(not player.movement_locked, "closing owned menu releases lock")
	check(travel.travel_to("plaza") and is_equal_approx(clock.hour, 8.5), "ordinary travel costs 30 game minutes")
	session.start_day()
	check(not travel.travel_to("apartment") and not travel.open_menu("travel", null), "market phase blocks travel and destination menu")
	session.active = false
	session.finished = true
	clock.market_hold = false
	check(travel.travel_to("apartment") and travel.travel_to("plaza") and not session.can_start(), "area changes preserve once-per-day market state")
	clock.hour = 23.9
	state.economy = state.economy.duplicate()
	state.economy.refund_chance_min = 1.0
	state.economy.refund_chance_max = 1.0
	state.cash = 10
	check(orders.place_order() and state.cash == 0, "late order spends cash before tonight refunds")
	state.misleading_sales.append(30)
	travel.travel_to("apartment")
	check(state.imprisoned and clock.awaiting_report and not orders.place_order(), "refund insolvency blocks further ordering")
	cycle._continue()
	clock.day += 1
	clock.hour = 8.0
	orders.check_deliveries()
	check(state.stock == 3 and orders.pending_quantity() == 1, "prison prevents wake and morning delivery")
	scene.queue_free()
	await frames()
	# Interaction scenes can be dropped into an unconfigured room without errors.
	var standalone = load("res://scenes/props/room_interaction.tscn").instantiate()
	root.add_child(standalone)
	await frames()
	check(not standalone.is_processing_unhandled_input(), "standalone interaction safely disables until configured")
	standalone.queue_free()
	print("Apartment, travel and delivery checks: %d passed / %d" % [checks - failures, checks])
	quit(1 if failures else 0)
