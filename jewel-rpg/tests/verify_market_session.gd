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
	var clock = scene.get_node("MarketClock")
	var session = scene.get_node("MarketSession")
	var player = scene.get_node("PlayerPlaceholder")
	var sales = scene.get_node("Obstacle")
	var supplier = scene.get_node("SupplierCounter")
	var board = scene.get_node("Sign")
	var cycle = scene.get_node("DayCycle")
	session.set_process(false)
	clock.set_process(false)
	state.economy = state.economy.duplicate()
	state.economy.daily_customer_variation = 0
	check(not session.serve_offer(20, false).sold and session.processed == 0, "sales gated before Start")
	for entry in [[0, 12], [10, 14], [-10, 10], [10000, 30], [-10000, 3]]:
		state.reputation = entry[0]
		check(session.start_day() and session.quota == entry[1], "reputation traffic and bounds %d" % entry[0])
		session.active = false
		session.session_day = 0
	state.reputation = 0
	state.economy.daily_customer_variation = 2
	session.traffic_rng.seed = 9184
	var quotas: Array[int] = []
	for index in 20:
		session.start_day()
		quotas.append(session.quota)
		session.active = false
		session.session_day = 0
	check(quotas.min() >= 10 and quotas.max() <= 14 and quotas.min() != quotas.max(), "daily bounded variation is real")
	state.economy.daily_customer_variation = 0
	player.position = sales.position + Vector2(0, 80)
	await frames(4)
	key(KEY_E)
	check(sales.panel.visible and player.movement_locked, "actual E opens stall")
	await frames()
	await click(sales.get_node("UILayer/Panel/Margin/Rows/Start"))
	check(session.active and session.quota == 12 and clock.market_hold, "actual Start click snapshots traffic and holds world clock")
	check(not session.start_day(), "cannot reroll quota by starting twice")
	var quota: int = session.quota
	state.reputation = 100
	key(KEY_ESCAPE)
	key(KEY_E)
	check(session.quota == quota, "reopening menu and changing reputation cannot reroll quota")
	var hour: float = clock.hour
	clock.advance_time(480)
	check(clock.hour == hour and not clock.awaiting_report, "ordinary midnight blocked throughout market")
	key(KEY_T)
	check(session.active and not cycle.report.visible and sales.panel.visible, "manual End day cannot bypass market")
	session.advance_session(0.7)
	key(KEY_N)
	check(session.processed == 0 and state.stock == 0, "missing stock does not spend customer")
	state.stock = 20
	key(KEY_N)
	check(session.processed == 1 and state.cash == 120, "actual N serves exactly one current customer")
	key(KEY_N)
	key(KEY_N, true)
	check(session.processed == 1, "same-frame duplicate and key echo cannot serve next arrival")
	var rep: int = state.reputation
	session.advance_session(0.7)
	sales.price_choice.select(0)
	await click(sales.serve_button)
	check(session.processed == 2 and state.reputation == rep + 2, "real cheap truthful click gains extra reputation")
	session.advance_session(0.7)
	sales.price_choice.select(2)
	var cash: int = state.cash
	var stock: int = state.stock
	key(KEY_N)
	check(session.processed == 3 and state.cash == cash and state.stock == stock, "over-budget visitor leaves without purchase")
	session.advance_session(0.7)
	key(KEY_C)
	key(KEY_N)
	check(session.processed == 4 and state.cash == cash + 30 and state.misleading_sales.size() == 1, "misleading sale full proceeds and midnight risk recorded")
	check(sales.get_node("CustomerVisuals").actors.size() == 3, "only a small visible queue represents remaining visitors")
	check(sales.get_node("CustomerVisuals").body_for(0).get_size() == Vector2(360,612), "customer atlases share a logical canvas")
	key(KEY_ESCAPE)
	player.position = supplier.position + Vector2(106,0)
	await frames(4)
	key(KEY_E)
	check(supplier.panel.visible and player.movement_locked, "restocking panel available during market")
	var remaining: float = session.remaining_seconds
	key(KEY_B)
	session.advance_session(1.0)
	check(session.remaining_seconds == remaining - 1.0 and supplier.panel.visible, "purchase menu does not pause service countdown")
	rep = state.reputation
	session.advance_session(100.0)
	check(not session.active and session.closing and session.processed == 4 and session.unserved == 8 and session.reputation_penalty == 2 and state.reputation == rep - 2, "deadline unserved penalty rounded once")
	check(not supplier.panel.visible and not sales.panel.visible and not board.dialogue.visible and player.movement_locked, "expiry closes all owned menus before modal lock")
	check(clock.hour == hour and state.last_settled_day == 0, "expiry does not settle refunds or skip time before fade")
	var after: int = state.reputation
	session.advance_session(0.951)
	check(clock.hour == 18.0 and session.fade.visible and not session.report.visible and state.last_settled_day == 0, "full-black point skips only to6pm")
	session.advance_session(0.46)
	check(session.report.visible and not session.fade.visible, "completion notification appears after fade")
	key(KEY_E)
	key(KEY_ESCAPE)
	check(session.report.visible and player.movement_locked, "unrelated keys cannot steal completion lock")
	await click(session.get_node("Report/Margin/Rows/Continue"))
	check(not session.closing and not player.movement_locked and not clock.market_hold and not state.day_closed, "Continue enables evening without settling")
	session.advance_session(100.0)
	check(state.reputation == after and not session.start_day(), "same day cannot repeat market or unserved penalty")
	check(not session.serve_offer(20,true).sold, "market sales gated after closing")
	state.cash = 100
	check(state.purchase_one(), "evening cash remains spendable before refunds")
	state.economy.refund_chance_min = 1.0
	state.economy.refund_chance_max = 1.0
	clock.hour = 23.99
	clock.advance_time(1.0)
	check(clock.awaiting_report and state.last_settled_day == 1 and state.last_report.refund_total == 30, "refunds settle at midnight rather than6pm")
	await click(cycle.continue_button)
	check(clock.day == 2 and session.session_day == 0 and not session.finished, "next calendar day resets market entitlement")
	state.reputation = 0
	state.economy.daily_customer_base = 3
	state.economy.minimum_daily_customers = 1
	check(session.start_day() and session.quota == 3, "fresh day can start once")
	state.stock = 3
	for index in 3:
		session.advance_session(0.7)
		session.serve_offer(20,false)
	check(session.processed == 3 and session.active and not session.customer_ready(), "all served waits for full minute; no unlimited visitors")
	session.advance_session(100.0)
	check(session.unserved == 0 and session.reputation_penalty == 0, "all visitors served yields no penalty")
	session.advance_session(10.0)
	check(clock.hour == 18.0 and session.report.visible, "large transition delta still reaches6pm exactly once")
	session.continue_evening()
	clock.finish_day()
	cycle._continue()
	player.position = board.position + Vector2(-60,0)
	await frames(4)
	key(KEY_E)
	check(board.dialogue.visible, "board owns its lock before market expiry fixture")
	session.start_day()
	session.advance_session(100.0)
	check(not board.dialogue.visible and player.movement_locked, "expiry closes board before taking its modal lock")
	session.advance_session(10.0)
	session.continue_evening()
	clock.finish_day()
	cycle._continue()
	player.position = sales.position + Vector2(0,80)
	await frames(4)
	key(KEY_E)
	key(KEY_S)
	sales.price_choice.get_popup().popup()
	check(sales.price_choice.get_popup().visible, "dropdown open at deadline fixture")
	session.advance_session(100.0)
	check(not sales.price_choice.get_popup().visible and player.movement_locked, "expiry dismisses dropdown as well as owner panel")
	scene.queue_free()
	await frames()
	print("Market session checks: %d passed, %d failed" % [checks - failures, failures])
	quit(1 if failures else 0)
