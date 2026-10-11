extends SceneTree

const Snapshot = preload("res://scripts/save_snapshot.gd")
var checks := 0
var failures := 0

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + label)

func _initialize() -> void:
	_run.call_deferred()

func frames(count: int = 3) -> void:
	for index in count:
		await physics_frame
		await process_frame

func key(code: int) -> void:
	for pressed in [true, false]:
		var event := InputEventKey.new()
		event.physical_keycode = code
		event.keycode = code
		event.pressed = pressed
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
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await frames()
	var state = game.get_node("BusinessState")
	var clock = game.get_node("MarketClock")
	var market = game.get_node("MarketSession")
	var travel = game.get_node("AreaTravel")
	var orders = game.get_node("DeliveryOrders")
	var player = game.get_node("PlayerPlaceholder")
	var stall = game.get_node("Obstacle")
	var boundary = game.get_node("Market/Boundaries")
	clock.set_process(false)
	market.set_process(false)
	check(state.stock == 0 and travel.current_area == "apartment", "fresh game starts with no delivered inventory")
	player.position = Vector2(540,285)
	await frames()
	key(KEY_E)
	key(KEY_B)
	check(orders.pending_quantity() == 1 and state.stock == 0, "actual computer order remains pending")
	key(KEY_ESCAPE)
	check(travel.travel_to("plaza"), "fresh ordered game can travel to plaza")
	player.position = stall.position + Vector2(0,80)
	await frames()
	key(KEY_E)
	check(stall.panel.visible, "actual E opens stall")
	var start = stall.get_node("UILayer/Panel/Margin/Rows/Start")
	check(start.visible and start.disabled and "No stock" in stall.get_node("UILayer/Panel/Margin/Rows/SessionStatus").text, "empty stock has visible disabled Start and delivery explanation")
	var rng_state: int = market.traffic_rng.state
	var before := Snapshot.capture(game)
	await click(start)
	key(KEY_S)
	check(not market.start_day() and not market.can_start(), "mouse, S and direct API cannot start with pending inventory")
	check(market.traffic_rng.state == rng_state and market.session_day == 0 and market.quota == 0 and market.remaining_seconds == 0 and not clock.market_hold and not market.active, "rejected opening preserves RNG, entitlement, quota and timers")
	check(state.reputation == before.business.reputation and state.cash == before.business.cash and clock.day == before.clock.day and clock.hour == before.clock.hour and stall.get_node("CustomerVisuals").actors.is_empty(), "rejected opening changes no finances, time, reputation or queue")
	key(KEY_ESCAPE)
	check(not player.movement_locked, "Escape releases stall lock after rejected opening")
	player.position = Vector2(50,420)
	await frames()
	key(KEY_E)
	check(travel.panel.visible and travel.mode == "travel", "plaza exit remains reachable at left border")
	await click(travel.action)
	check(travel.current_area == "apartment" and not player.movement_locked, "plaza exit actually returns player home without waiting")
	clock.hour = 18
	check("Too late" in market.start_block_reason(), "late-day reason takes precedence over no-stock reason")
	clock.hour = 8
	state.stock = -1
	check(not market.start_day(), "negative inventory also rejects opening")
	state.stock = 0
	clock.finish_day()
	game.get_node("DayCycle")._continue()
	clock.advance_minutes(480)
	check(state.stock == 1 and orders.pending_quantity() == 0, "morning delivery provides real inventory")
	travel.travel_to("plaza")
	check(market.can_start() and market.start_day(), "delivered stock unlocks opening and uses same entitlement")
	market.advance_session(0.7)
	check(market.serve_offer(20,false).sold and state.stock == 0, "last delivered ring can be sold")
	var remaining: float = market.remaining_seconds
	market.advance_session(1)
	check(market.active and market.remaining_seconds == remaining - 1 and not travel.travel_to("apartment"), "running out during active session retains existing countdown and travel gate")
	market.active = false
	clock.market_hold = false
	# Use clear paths near each wall to exercise real CharacterBody2D movement.
	for entry in [[Vector2(80,360), "move_left", 0], [Vector2(890,330), "move_right", 1], [Vector2(560,120), "move_up", 2], [Vector2(560,470), "move_down", 3]]:
		player.position = entry[0]
		Input.action_press(entry[1])
		await frames(40)
		Input.action_release(entry[1])
		check(boundary.safe_position(player.position).distance_to(player.position) < 0.05, "physical boundary prevents leaving edge %d" % entry[2])
		var wall_reached: bool = [absf(player.position.x-40)<0.1, absf(player.position.x-920)<0.1, absf(player.position.y-80)<0.1, absf(player.position.y-514)<0.1][entry[2]]
		check(wall_reached, "movement actually reaches and stops at wall %d" % entry[2])
	player.position = Vector2(880,470)
	Input.action_press("move_right")
	Input.action_press("move_down")
	await frames(50)
	Input.action_release("move_right")
	Input.action_release("move_down")
	check(player.position.distance_to(Vector2(920,514)) < 0.1, "diagonal movement cannot escape bottom-right corner")
	var data := Snapshot.capture(game)
	data.player.x = -200
	data.player.y = -200
	check(Snapshot.valid(data), "legacy outside position remains valid save data")
	Snapshot.apply(game,data)
	check(player.position == Vector2(40,80) and market.session_day == data.market.session_day and state.cash == data.business.cash, "plaza restore clips legacy position without resetting run")
	data.player.x = 2000
	data.player.y = 2000
	Snapshot.apply(game,data)
	check(player.position == Vector2(920,514), "plaza restore clips opposite outside corner")
	travel.set_area("apartment")
	var all_disabled := true
	for body in boundary.get_children():
		all_disabled = all_disabled and body.collision_layer == 0 and body.collision_mask == 0
	check(all_disabled, "inactive plaza walls disable collision layer and mask")
	player.position = Vector2(560,95)
	Input.action_press("move_up")
	await frames(25)
	Input.action_release("move_up")
	check(player.position.y < 80, "inactive plaza top wall produces no ghost collision indoors")
	data = Snapshot.capture(game)
	data.player.x = 550
	data.player.y = 65
	Snapshot.apply(game,data)
	check(player.position == Vector2(550,65), "apartment saved positions are not clamped to plaza")
	travel.set_area("plaza")
	var all_enabled := true
	for body in boundary.get_children():
		all_enabled = all_enabled and body.collision_layer == 1 and body.collision_mask == 1
	check(all_enabled and player.position == Vector2(380,430), "return to plaza restores physical walls and safe arrival point")
	game.queue_free()
	await frames()
	print("Stock and boundary checks: %d passed, %d failed" % [checks-failures,failures])
	quit(1 if failures else 0)
