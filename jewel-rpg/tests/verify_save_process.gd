extends SceneTree
# Run three separate processes in order: -- --phase=write, --phase=read, --phase=finish.
# This isolated slot never touches the player's business-save.json.
const TEST_PATH := "user://process-verification/business.json"
const Store = preload("res://scripts/save_store.gd")
func _initialize() -> void:
	_run.call_deferred()
func _run() -> void:
	var phase := ""
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--phase="):
			phase = argument.trim_prefix("--phase=")
	if phase not in ["write", "read", "finish"]:
		push_error("Choose --phase=write, read, or finish")
		quit(1)
		return
	DirAccess.make_dir_recursive_absolute(TEST_PATH.get_base_dir())
	if phase == "write":
		for suffix in ["", ".bak", ".tmp", ".bak.tmp"]:
			DirAccess.remove_absolute(TEST_PATH + suffix)
	var wrapper = load("res://scenes/game.tscn").instantiate()
	wrapper.get_node("SaveGame").save_path = TEST_PATH
	root.add_child(wrapper)
	current_scene = wrapper
	var saves = wrapper.get_node("SaveGame")
	if phase == "write":
		saves.start_new_game()
		saves.game.get_node("MarketClock").set_process(false)
		saves.game.get_node("DeliveryOrders").place_order(3)
		saves.game.get_node("AreaTravel").sleep_until_morning()
		print("PROCESS write: window close while midnight report interrupts sleep")
		saves._notification(Node.NOTIFICATION_WM_CLOSE_REQUEST)
		return
	if saves.loaded.is_empty():
		push_error("Previous process did not write a valid snapshot")
		quit(1)
		return
	saves.continue_game()
	var game = saves.game
	game.get_node("MarketClock").set_process(false)
	var state = game.get_node("BusinessState")
	if phase == "read":
		if state.cash != 70 or state.stock != 0 or not game.get_node("DayCycle").report.visible or not game.get_node("AreaTravel").pending_sleep:
			push_error("Interrupted sleep did not survive a fresh process")
			quit(1)
			return
		game.get_node("DayCycle")._continue()
		if state.stock != 3 or game.get_node("MarketClock").day != 2 or game.get_node("MarketClock").hour != 8.0:
			push_error("Sleep did not finish with one delivery")
			quit(1)
			return
		game.get_node("AreaTravel").travel_to("plaza")
		var market = game.get_node("MarketSession")
		market.set_process(false)
		market.start_day()
		market.advance_session(60)
		market.advance_session(2)
		await process_frame
		var button = saves.get_node("Toolbar/Quit")
		var point: Vector2 = button.get_global_rect().get_center()
		var motion := InputEventMouseMotion.new()
		motion.position = point
		root.push_input(motion, true)
		for pressed in [true, false]:
			var event := InputEventMouseButton.new()
			event.position = point
			event.button_index = MOUSE_BUTTON_LEFT
			event.pressed = pressed
			root.push_input(event, true)
		print("PROCESS read: restored sleep, delivered once, mouse Save & Quit after market closing")
		return
	game.get_node("DeliveryOrders").check_deliveries()
	if state.stock != 3 or state.cash != 70 or game.get_node("DeliveryOrders").pending_quantity() != 0 or not game.get_node("MarketSession").report.visible:
		push_error("Second process duplicated or lost the delivery")
		quit(1)
		return
	saves.save_path = TEST_PATH + "/missing/file.json"
	saves.quit_game()
	# quit_game must leave the process running when writing fails.
	await process_frame
	if not "failed" in saves.notice.text or Store.read_file(TEST_PATH).business.stock != 3:
		push_error("Failed quit did not preserve the last save and show an error")
		quit(1)
		return
	for suffix in ["", ".bak", ".tmp", ".bak.tmp"]:
		DirAccess.remove_absolute(TEST_PATH + suffix)
	DirAccess.remove_absolute(TEST_PATH.get_base_dir())
	print("PROCESS finish: no duplicate delivery; failed quit stays open and preserves save")
	quit(0)
