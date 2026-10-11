extends SceneTree
const Snapshot = preload("res://scripts/save_snapshot.gd")
const Store = preload("res://scripts/save_store.gd")
var checks := 0
var failures := 0
var game: Node
var path := ""
func check(value: bool, label: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(label)
func reports_match(actual: Dictionary, expected: Dictionary) -> bool:
	for field in expected:
		if field == "probability":
			if not is_equal_approx(actual[field], expected[field]): return false
		elif actual[field] != expected[field]:
			return false
	return true
func _initialize() -> void:
	_run.call_deferred()
func frames() -> void:
	await physics_frame
	await process_frame
func fresh() -> Node:
	var result = load("res://scenes/main.tscn").instantiate()
	root.add_child(result)
	result.get_node("MarketClock").set_process(false)
	result.get_node("MarketSession").set_process(false)
	return result
func roundtrip() -> void:
	var data := Snapshot.capture(game)
	check(Snapshot.valid(data), "runtime snapshot satisfies schema")
	check(Store.write_slot(path, data) == OK, "snapshot written successfully")
	var restored := Store.read_file(path)
	check(not restored.is_empty(), "serialized snapshot validates")
	game.queue_free()
	await frames()
	game = fresh()
	Snapshot.apply(game, restored)
	await frames()
func click(button: Control) -> void:
	await frames()
	var point := button.get_global_rect().get_center()
	if button.get_viewport() != root:
		point += Vector2(button.get_viewport().position)
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
func check_closing_shortcut(saves: Node, label: String) -> void:
	var current = saves.game
	var clock = current.get_node("MarketClock")
	var market = current.get_node("MarketSession")
	clock.set_process(false)
	market.set_process(false)
	current.get_node("AreaTravel").travel_to("plaza")
	if not market.can_start():
		clock.finish_day()
		current.get_node("DayCycle")._continue()
	current.get_node("BusinessState").stock = maxi(1, current.get_node("BusinessState").stock)
	market.start_day()
	market.advance_session(60.0)
	saves.notice.text = "Not saved yet"
	var event := InputEventKey.new()
	event.physical_keycode = KEY_F6
	event.pressed = true
	root.push_input(event)
	var saved := Store.read_file(saves.save_path)
	check(saved.market.closing and not saved.market.report_visible and saves.notice.text == "Business saved.", label + " F6 saves during closing notice")
	check(saves.get_node("Toolbar/Save").disabled and saves.get_node("Toolbar/Quit").disabled, label + " closing explicitly disables mouse save controls")
	var before_click := FileAccess.get_file_as_string(saves.save_path)
	await click(saves.get_node("Toolbar/Save"))
	check(FileAccess.get_file_as_string(saves.save_path) == before_click, label + " disabled Save click does not write")
	await click(saves.get_node("Toolbar/Quit"))
	check(FileAccess.get_file_as_string(saves.save_path) == before_click and saves.playing, label + " disabled Save and Quit click leaves the game running")
	market.advance_session(0.7)
	root.push_input(event)
	saved = Store.read_file(saves.save_path)
	check(is_equal_approx(saved.market.transition_elapsed, 0.7), label + " F6 saves during closing fade")
	var bytes := FileAccess.get_file_as_string(saves.save_path)
	saves.notice.text = "Echo must not save"
	event.echo = true
	root.push_input(event)
	check(FileAccess.get_file_as_string(saves.save_path) == bytes and saves.notice.text == "Echo must not save", label + " echoed F6 cannot save repeatedly")
	event.pressed = false
	event.echo = false
	root.push_input(event)
	market.advance_session(2.0)
	check(not saves.get_node("Toolbar/Save").disabled and not saves.get_node("Toolbar/Quit").disabled, label + " closing report re-enables mouse save controls")
	await click(saves.get_node("Toolbar/Save"))
	check(Store.read_file(saves.save_path).market.report_visible, label + " actual Save click writes the closing report")
	market.continue_evening()
	current.get_node("AreaTravel").travel_to("apartment")

func _run() -> void:
	path = "user://save-check-%d/business.json" % OS.get_process_id()
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	check(Store.load_slot(path).data.is_empty(), "missing save is safe")
	game = fresh()
	var state = game.get_node("BusinessState")
	var orders = game.get_node("DeliveryOrders")
	var clock = game.get_node("MarketClock")
	var travel = game.get_node("AreaTravel")
	state.reputation = -7
	orders.place_order(3)
	game.get_node("PlayerPlaceholder").position = Vector2(550, 310)
	game.get_node("PlayerPlaceholder").facing = "side"
	game.get_node("PlayerPlaceholder").facing_left = true
	travel.open_menu("order", null)
	await roundtrip()
	state = game.get_node("BusinessState")
	orders = game.get_node("DeliveryOrders")
	clock = game.get_node("MarketClock")
	travel = game.get_node("AreaTravel")
	check(state.cash == 70 and state.stock == 0 and state.reputation == -7 and orders.pending_quantity() == 3, "paid orders balances and reputation survive reload")
	check(game.get_node("PlayerPlaceholder").position == Vector2(550,310) and game.get_node("PlayerPlaceholder").facing_left, "player position and facing restored")
	check(not travel.panel.visible and not game.get_node("PlayerPlaceholder").movement_locked, "ordinary modal closes without stale movement lock")
	clock.hour = 23.0 + 59.0 / 60.0
	orders.place_order()
	travel.sleep_until_morning()
	var report = state.last_report.duplicate()
	var rng_state: int = state.refund_rng.state
	await roundtrip()
	state = game.get_node("BusinessState")
	clock = game.get_node("MarketClock")
	travel = game.get_node("AreaTravel")
	orders = game.get_node("DeliveryOrders")
	check(reports_match(state.last_report, report) and state.refund_rng.state == rng_state and travel.pending_sleep, "midnight sleep report restores without reroll")
	check(game.get_node("DayCycle").report.visible and not travel.travel_to("plaza"), "restored report owns movement and travel lock")
	await click(game.get_node("DayCycle").continue_button)
	check(clock.day == 2 and clock.hour == 8.0 and state.stock == 4 and orders.pending_quantity() == 0, "sleep resumes and delivers once after report Continue")
	await roundtrip()
	state = game.get_node("BusinessState")
	orders = game.get_node("DeliveryOrders")
	clock = game.get_node("MarketClock")
	travel = game.get_node("AreaTravel")
	orders.check_deliveries()
	check(state.stock == 4 and state.cash == 60, "delivered stock cannot be duplicated by reloading")
	travel.travel_to("plaza")
	clock.hour = 23.75
	travel.travel_to("apartment")
	await roundtrip()
	clock = game.get_node("MarketClock")
	travel = game.get_node("AreaTravel")
	check(travel.pending_travel_minutes == 15 and game.get_node("DayCycle").report.visible, "interrupted travel retains remaining minutes")
	await click(game.get_node("DayCycle").continue_button)
	check(clock.day == 3 and clock.hour == 0.25, "travel Continue applies remaining quarter hour once")
	game.get_node("DayCycle")._continue()
	check(clock.hour == 0.25, "duplicate Continue cannot add travel time")
	orders = game.get_node("DeliveryOrders")
	orders.place_order()
	check(orders.pending[0].day == 4, "after-midnight order retains following-day cutoff")
	clock.hour = 7.0 + 59.0 / 60.0
	await roundtrip()
	clock = game.get_node("MarketClock")
	state = game.get_node("BusinessState")
	orders = game.get_node("DeliveryOrders")
	clock.advance_minutes(1)
	check(state.stock == 4 and orders.pending_quantity() == 1, "08 boundary does not deliver tomorrow's batch")
	# Freeze attendance, countdown and refund generator; do not recreate them on load.
	travel = game.get_node("AreaTravel")
	travel.travel_to("plaza")
	var market = game.get_node("MarketSession")
	state.reputation = 15
	market.traffic_rng.seed = 42
	state.refund_rng.seed = 9184
	market.start_day()
	market.advance_session(0.7)
	market.serve_offer(30, true)
	market.advance_session(12.25)
	var quota: int = market.quota
	var remaining: float = market.remaining_seconds
	var refund_seed: int = state.refund_rng.seed
	rng_state = state.refund_rng.state
	var traffic_rng: int = market.traffic_rng.state
	await roundtrip()
	market = game.get_node("MarketSession")
	state = game.get_node("BusinessState")
	check(market.active and market.quota == quota and market.processed == 1 and is_equal_approx(market.remaining_seconds, remaining), "active market resumes exact quota visitor count and countdown")
	check(not market.can_start() and game.get_node("MarketClock").market_hold, "reload cannot restart or unfreeze active market")
	check(state.misleading_sales == [30] and state.refund_rng.seed == refund_seed and state.refund_rng.state == rng_state and market.traffic_rng.state == traffic_rng, "refund exposure and full 64-bit generators restored")
	var duplicate_rng := RandomNumberGenerator.new()
	duplicate_rng.seed = refund_seed
	duplicate_rng.state = rng_state
	var expected_probability := duplicate_rng.randf_range(state.economy.refund_chance_min, state.economy.refund_chance_max)
	var expected_complaint := duplicate_rng.randf() < expected_probability
	market.advance_session(100)
	var after_penalty: int = state.reputation
	market.advance_session(0.7)
	await roundtrip()
	market = game.get_node("MarketSession")
	state = game.get_node("BusinessState")
	check(market.closing and state.reputation == after_penalty and game.get_node("PlayerPlaceholder").movement_locked, "closing fade restores without duplicate reputation penalty")
	market.advance_session(2)
	await roundtrip()
	market = game.get_node("MarketSession")
	check(market.report.visible and game.get_node("MarketClock").hour == 18, "completed closing report reappears")
	await click(market.get_node("Report/Margin/Rows/Continue"))
	travel = game.get_node("AreaTravel")
	travel.travel_to("apartment")
	travel.travel_to("plaza")
	await roundtrip()
	market = game.get_node("MarketSession")
	state = game.get_node("BusinessState")
	clock = game.get_node("MarketClock")
	check(not market.can_start() and market.finished and state.reputation == after_penalty, "finished market eligibility survives save and round-trip")
	clock.finish_day()
	check(state.last_report.complaints == int(expected_complaint), "reload preserves upcoming refund roll")
	var settled_cash: int = state.cash
	var settled_stock: int = state.stock
	report = state.last_report.duplicate()
	await roundtrip()
	state = game.get_node("BusinessState")
	check(state.cash == settled_cash and state.stock == settled_stock and reports_match(state.settle_day(3), report), "settled refund cannot repay or return stock twice")
	await click(game.get_node("DayCycle").continue_button)
	await roundtrip()
	check(game.get_node("MarketSession").can_start(), "next day remains eligible after reload")
	# Load immediately before a due delivery, then settle a certain nonzero refund.
	clock = game.get_node("MarketClock")
	clock.hour = 7.0 + 59.0 / 60.0
	clock._refresh()
	await roundtrip()
	state = game.get_node("BusinessState")
	settled_stock = state.stock
	game.get_node("MarketClock").advance_minutes(1)
	check(state.stock == settled_stock + 1 and game.get_node("DeliveryOrders").pending_quantity() == 0, "due 07:59 snapshot delivers exactly at 08:00")
	state.economy = state.economy.duplicate()
	state.economy.refund_chance_min = 1.0
	state.economy.refund_chance_max = 1.0
	state.cash = 100
	state.revenue = 30
	state.misleading_sales.append(30)
	game.get_node("MarketClock").finish_day()
	check(state.cash == 70 and state.last_report.complaints == 1 and state.revenue == 0, "certain refund fixture settles one full refund")
	settled_stock = state.stock
	await roundtrip()
	state = game.get_node("BusinessState")
	check(state.cash == 70 and state.stock == settled_stock and state.revenue == 0 and state.last_report.complaints == 1, "nonzero settled refund survives reload without second payout or ring")
	await click(game.get_node("DayCycle").continue_button)
	# Prison is terminal across reload, including a pending paid order and sleep.
	travel = game.get_node("AreaTravel")
	travel.travel_to("apartment")
	state = game.get_node("BusinessState")
	state.economy = state.economy.duplicate()
	state.economy.refund_chance_min = 1.0
	state.economy.refund_chance_max = 1.0
	game.get_node("MarketClock").hour = 18.0
	game.get_node("MarketClock")._refresh()
	state.cash = 10
	game.get_node("DeliveryOrders").place_order()
	state.misleading_sales.append(30)
	travel.sleep_until_morning()
	await roundtrip()
	state = game.get_node("BusinessState")
	settled_stock = state.stock
	game.get_node("DayCycle")._continue()
	game.get_node("DeliveryOrders").check_deliveries()
	check(state.imprisoned and state.stock == settled_stock and game.get_node("DayCycle").restart_button.visible, "prison reload cannot resume sleep or deliver stock")
	# The existing End day shortcut can skip 08:00 before pending goods arrive.
	# Its report legitimately holds today's delivery until Continue starts tomorrow.
	var early = fresh()
	early.get_node("DeliveryOrders").place_order()
	early.get_node("MarketClock").finish_day()
	early.get_node("DayCycle")._continue()
	early.get_node("MarketClock").finish_day()
	var early_path := path + "-early"
	check(Store.write_slot(early_path, Snapshot.capture(early)) == OK, "End day before 08:00 can save today's deferred delivery")
	var early_data := Store.read_file(early_path)
	early.queue_free()
	await frames()
	early = fresh()
	Snapshot.apply(early, early_data)
	check(early.get_node("BusinessState").stock == 0 and early.get_node("DeliveryOrders").pending_quantity() == 1, "early End day report preserves pending paid goods")
	early.get_node("DayCycle")._continue()
	check(early.get_node("MarketClock").day == 3 and early.get_node("BusinessState").stock == 1, "early End day Continue releases deferred goods once")
	early.queue_free()
	DirAccess.remove_absolute(early_path)
	# Reject the entire malformed document before touching live state.
	var good := Store.read_file(path)
	for mutation in ["version", "cash", "rng", "orders", "clock", "report", "market", "player"]:
		var bad := good.duplicate(true)
		match mutation:
			"version": bad.version = 999
			"cash": bad.business.cash = -1
			"rng": bad.business.rng_state = "9223372036854775808"
			"orders": bad.orders = [{"day": "tomorrow", "quantity": 3}]
			"clock": bad.clock.hour = "midnight"
			"report": bad.business.last_report = {}
			"market": bad.market.active = true
			"player": bad.player.x = null
		check(not Snapshot.valid(bad), "invalid " + mutation + " rejected")
	check(Store.write_slot(path, {"version": 999}) == ERR_INVALID_DATA and Store.read_file(path) == good, "invalid write preserves previous save")
	check(Store.write_slot(path + "/missing/file.json", good) != OK and Store.read_file(path) == good, "write failure preserves existing slot")
	Store.write_slot(path, good)
	Store.write_text(path, "{interrupted")
	check(Store.load_slot(path).data == good and "Recovered" in Store.load_slot(path).message, "corrupt primary recovers valid backup")
	Store.write_text(path + ".bak", "not JSON")
	check(Store.load_slot(path).data.is_empty() and FileAccess.get_file_as_string(path) == "{interrupted", "two invalid saves remain untouched")
	game.queue_free()
	await frames()
	# Real entry scene: title, mouse New, cancellation, save shortcut and Continue.
	var wrapper = load("res://scenes/game.tscn").instantiate()
	wrapper.get_node("SaveGame").save_path = path
	root.add_child(wrapper)
	current_scene = wrapper
	await frames()
	var saves = wrapper.get_node("SaveGame")
	check(paused and saves.continue_button.disabled and saves.title.visible, "invalid save keeps title paused and disables Continue")
	await click(saves.get_node("Title/Panel/Margin/Rows/New"))
	check(saves.confirm.visible, "new game requires confirmation before replacing invalid save")
	await click(saves.confirm.get_cancel_button())
	check(paused and FileAccess.get_file_as_string(path) == "{interrupted", "cancel keeps saved bytes and title unchanged")
	await click(saves.get_node("Title/Panel/Margin/Rows/New"))
	await click(saves.confirm.get_ok_button())
	await frames()
	check(saves.playing and not paused and Store.read_file(path).business.cash == 100, "confirmed new game creates valid fresh save")
	await check_closing_shortcut(saves, "New game")
	saves.game.get_node("MarketClock").set_process(false)
	saves.game.get_node("DeliveryOrders").place_order(2)
	var key := InputEventKey.new()
	key.physical_keycode = KEY_F6
	key.pressed = true
	root.push_input(key)
	check(Store.read_file(path).business.cash == 80 and "saved" in saves.notice.text, "physical F6 writes current paid orders and gives feedback")
	wrapper.queue_free()
	await frames()
	wrapper = load("res://scenes/game.tscn").instantiate()
	wrapper.get_node("SaveGame").save_path = path
	root.add_child(wrapper)
	current_scene = wrapper
	await frames()
	saves = wrapper.get_node("SaveGame")
	check(not saves.continue_button.disabled and paused, "valid save enables Continue without advancing time")
	await click(saves.continue_button)
	check(saves.playing and saves.game.get_node("BusinessState").cash == 80 and saves.game.get_node("DeliveryOrders").pending_quantity() == 2, "actual Continue restores saved business")
	await check_closing_shortcut(saves, "Continue")
	var original_path: String = saves.save_path
	saves.save_path = path + "/unwritable/file.json"
	check(not saves.save_now() and "failed" in saves.notice.text, "failed save is visible and not claimed successful")
	saves.save_path = original_path
	state = saves.game.get_node("BusinessState")
	state.economy = state.economy.duplicate()
	state.economy.refund_chance_min = 1.0
	state.economy.refund_chance_max = 1.0
	state.cash = 0
	state.misleading_sales.append(30)
	saves.game.get_node("AreaTravel").sleep_until_morning()
	check(saves.save_now() and state.imprisoned, "prison is saved through the real controller")
	await click(saves.game.get_node("DayCycle").restart_button)
	check(saves.confirm.visible and paused, "prison restart requests confirmation instead of loading the old prison save")
	await click(saves.confirm.get_cancel_button())
	check(not paused and state.imprisoned and saves.game.get_node("DayCycle").report.visible, "cancel prison restart preserves terminal report")
	await click(saves.game.get_node("DayCycle").restart_button)
	await click(saves.confirm.get_ok_button())
	check(saves.game.get_node("BusinessState").cash == 100 and not saves.game.get_node("BusinessState").imprisoned and Store.read_file(path).business.cash == 100, "confirmed prison restart replaces run and disk snapshot")
	await check_closing_shortcut(saves, "Prison restart")
	wrapper.queue_free()
	await frames()
	for suffix in ["", ".bak", ".tmp", ".bak.tmp"]:
		DirAccess.remove_absolute(path + suffix)
	DirAccess.remove_absolute(path.get_base_dir())
	print("Save/continue checks: %d passed, %d failed" % [checks - failures, failures])
	quit(1 if failures else 0)
