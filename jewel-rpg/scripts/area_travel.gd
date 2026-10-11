extends CanvasLayer

signal area_changed(area: String)
@export var starting_area := "apartment"
var current_area := "plaza"
var pending_sleep := false
var pending_travel_minutes := 0.0
@onready var player = get_node("../PlayerPlaceholder")
@onready var clock = get_node("../MarketClock")
@onready var state = get_node("../BusinessState")
@onready var session = get_node("../MarketSession")
@onready var panel: PanelContainer = $Panel
@onready var heading: Label = $Panel/Margin/Rows/Heading
@onready var action: Button = $Panel/Margin/Rows/Action
@onready var feedback: Label = $Panel/Margin/Rows/Feedback
@onready var quantity: SpinBox = $Panel/Margin/Rows/OrderQuantity
var mode := "travel"
var source: Node = null

func _ready() -> void:
	panel.hide()
	action.pressed.connect(_act)
	quantity.value_changed.connect(func(_value: float):
		if mode == "order":
			_refresh())
	$Panel/Margin/Rows/Close.pressed.connect(close_menu)
	set_area(starting_area)

func blocked() -> bool:
	return session.active or session.closing or clock.awaiting_report or state.imprisoned or state.day_closed

func open_menu(kind: String, owner: Node) -> bool:
	if blocked() or player.movement_locked:
		return false
	mode = kind
	quantity.value = 1
	source = owner
	panel.show()
	player.movement_locked = true
	feedback.text = ""
	_refresh()
	return true

func _refresh() -> void:
	quantity.visible = mode == "order"
	action.disabled = false
	if mode == "order":
		heading.text = "Budget Sparkle Online • Stock orders"
		var count := int(quantity.value)
		var cost: int = count * state.economy.unit_cost
		action.text = "Order %d rings • Total %d credits (B)" % [count, cost]
		action.disabled = state.cash < cost
		feedback.text = "%s\n%s\nCash: %d | Inventory: %d | On order: %d\nPaid now. Delivery day %d at 08:00.\nOrders arrive the following day; order before midnight for tomorrow morning." % [state.economy.product_name, state.economy.materials, state.cash, state.stock, get_node("../DeliveryOrders").pending_quantity(), clock.day + 1]
	elif mode == "sleep":
		heading.text = "A mattress with ambition"
		action.text = "Sleep until 8am"
		feedback.text = "Tonight’s refunds must be settled before morning."
	else:
		heading.text = "Where would you like to go?"
		action.text = "Plaza — 30 minutes" if current_area == "apartment" else "Apartment — 30 minutes"

func close_menu() -> void:
	if panel.visible:
		panel.hide()
		player.movement_locked = false
		source = null

func _unhandled_input(event: InputEvent) -> void:
	if not panel.visible:
		return
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("interact"):
		close_menu()
	elif mode == "order" and event.is_action_pressed("buy_stock", false):
		_act()
	else:
		return
	get_viewport().set_input_as_handled()

func _act() -> void:
	if not panel.visible or blocked():
		return
	if mode == "order":
		var success: bool = get_node("../DeliveryOrders").place_order(int(quantity.value))
		_refresh()
		feedback.text += "\nOrder confirmed." if success else "\nNot enough cash to place this order."
	elif mode == "sleep":
		close_menu()
		sleep_until_morning()
	else:
		var destination := "plaza" if current_area == "apartment" else "apartment"
		close_menu()
		travel_to(destination)

func travel_to(destination: String) -> bool:
	if destination == current_area or destination not in ["plaza", "apartment"] or blocked() or player.movement_locked:
		return false
	set_area(destination)
	# Crossing midnight stops at the existing refund report. No report is bypassed.
	pending_travel_minutes = maxf(0.0, 30.0 - (24.0 - clock.hour) * 60.0)
	clock.advance_minutes(30.0)
	return true

func sleep_until_morning() -> bool:
	if blocked() or player.movement_locked or current_area != "apartment":
		return false
	if clock.hour < 8.0:
		clock.advance_minutes((8.0 - clock.hour) * 60.0)
	else:
		pending_sleep = true
		clock.finish_day()
	return true

func resume_after_report() -> void:
	if state.imprisoned:
		pending_sleep = false
		pending_travel_minutes = 0.0
		return
	if pending_travel_minutes > 0.0:
		var minutes := pending_travel_minutes
		pending_travel_minutes = 0.0
		clock.advance_minutes(minutes)
	if pending_sleep and not state.imprisoned:
		pending_sleep = false
		clock.advance_minutes((8.0 - clock.hour) * 60.0)

func set_area(area: String) -> void:
	current_area = area
	var root := get_parent()
	for node in root.get_children():
		if node.has_meta("playable_area"):
			_set_enabled(node, String(node.get_meta("playable_area")) == area)
	# The old instant supplier is retained only for isolated historical fixtures.
	_set_enabled(root.get_node("SupplierCounter"), false)
	player.position = safe_player_position(Vector2(610, 390) if area == "apartment" else Vector2(380, 430))
	clock.indoors = area == "apartment"
	clock._refresh()
	area_changed.emit(area)

func safe_player_position(point: Vector2) -> Vector2:
	if current_area == "plaza":
		return get_node("../Market/Boundaries").safe_position(point)
	return point

func _set_enabled(node: Node, enabled: bool) -> void:
	if node.has_method("set_area_active"):
		node.set_area_active(enabled)
	if not node.has_meta("original_process_mode"):
		node.set_meta("original_process_mode", node.process_mode)
	node.process_mode = int(node.get_meta("original_process_mode")) if enabled else Node.PROCESS_MODE_DISABLED
	if node is CanvasItem or node is CanvasLayer:
		if not node.has_meta("original_visible"):
			node.set_meta("original_visible", node.visible)
		node.visible = bool(node.get_meta("original_visible")) if enabled else false
	if node is CollisionObject2D:
		if not node.has_meta("original_layer"):
			node.set_meta("original_layer", node.collision_layer)
			node.set_meta("original_mask", node.collision_mask)
		node.collision_layer = int(node.get_meta("original_layer")) if enabled else 0
		node.collision_mask = int(node.get_meta("original_mask")) if enabled else 0
	for child in node.get_children():
		_set_enabled(child, enabled)
