extends Area2D

@export var player_path: NodePath
@export var business_state_path: NodePath
@export var market_session_path: NodePath
@onready var session = get_node_or_null(market_session_path) if not market_session_path.is_empty() else null
@export var day_cycle_path: NodePath
@onready var day_cycle = get_node_or_null(day_cycle_path) if not day_cycle_path.is_empty() else null
@onready var player = get_node_or_null(player_path) if not player_path.is_empty() else null
@onready var state = get_node_or_null(business_state_path) if not business_state_path.is_empty() else null
@onready var panel: PanelContainer = $UILayer/Panel
@onready var prompt: Label = $Prompt
@onready var details: Label = $UILayer/Panel/Margin/Rows/Details
@onready var feedback: Label = $UILayer/Panel/Margin/Rows/Feedback
@onready var serve_button: Button = $UILayer/Panel/Margin/Rows/Serve
@onready var price_choice: OptionButton = $UILayer/Panel/Margin/Rows/Price
@onready var claim_choice: OptionButton = $UILayer/Panel/Margin/Rows/Claim
var player_nearby := false
var configured := false

func _ready() -> void:
	panel.hide()
	prompt.hide()
	configured = player != null and state != null and state.economy != null and session != null
	if not configured:
		push_warning("SalesCounter needs player_path and business_state_path linked to configured nodes.")
		return
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	state.changed.connect(_refresh)
	session.changed.connect(_refresh)
	session.customer_changed.connect(_refresh_customer)
	$UILayer/Panel/Margin/Rows/Start.pressed.connect(_start_day)
	serve_button.pressed.connect(_serve)
	$UILayer/Panel/Margin/Rows/EndDay.pressed.connect(_end_day)
	for price in state.economy.sale_prices:
		price_choice.add_item("Asking price: %d credits" % price, price)
		if price == state.economy.default_sale_price:
			price_choice.select(price_choice.item_count - 1)
	claim_choice.add_item("Truthful: " + state.economy.truthful_claim)
	claim_choice.add_item("Misleading: " + state.economy.misleading_claim)
	_refresh.call_deferred()

func _on_body_entered(body: Node2D) -> void:
	if body == player:
		player_nearby = true
		prompt.visible = not panel.visible

func _on_body_exited(body: Node2D) -> void:
	if body == player:
		player_nearby = false
		_set_open(false)
		prompt.hide()

func _unhandled_input(event: InputEvent) -> void:
	if not configured:
		return
	if event.is_action_pressed("interact", false):
		if panel.visible:
			_set_open(false)
		elif player_nearby and not player.movement_locked:
			_set_open(true)
		else:
			return
	elif panel.visible and event.is_action_pressed("ui_cancel", false):
		_set_open(false)
	elif panel.visible and event.is_action_pressed("cycle_price", false):
		price_choice.select((price_choice.selected + 1) % price_choice.item_count)
	elif panel.visible and event.is_action_pressed("toggle_claim", false):
		claim_choice.select(1 - claim_choice.selected)
	elif panel.visible and event.is_action_pressed("start_market", false):
		_start_day()
	elif panel.visible and event.is_action_pressed("end_day", false):
		_end_day()
	elif panel.visible and event.is_action_pressed("serve_customer", false):
		_serve()
	else:
		return
	get_viewport().set_input_as_handled()

func _set_open(open: bool) -> void:
	var owned_lock := panel.visible
	if not open:
		price_choice.get_popup().hide()
		claim_choice.get_popup().hide()
	panel.visible = open
	if is_instance_valid(player) and (open or owned_lock):
		player.movement_locked = open
	prompt.visible = player_nearby and not open
	if open:
		feedback.text = "Order stock at your apartment computer and collect morning delivery before starting a one-minute market day. Cheaper truthful offers earn more reputation."
		_refresh()

func _serve() -> void:
	if not configured or not panel.visible or not player_nearby:
		return
	var price := price_choice.get_selected_id()
	var result: Dictionary = session.serve_offer(price, claim_choice.selected == 1)
	feedback.text = result.message

func _refresh() -> void:
	if not configured:
		return
	details.text = "Actual materials: %s\nCash: %d | Stock: %d | Revenue: %d | Rep: %+d" % [state.economy.materials, state.cash, state.stock, state.revenue, state.reputation]
	var rows = $UILayer/Panel/Margin/Rows
	rows.get_node("Start").visible = not session.active and not session.closing and session.session_day != session.clock.day and session.clock.hour < 18.0
	rows.get_node("Start").disabled = not session.can_start()
	rows.get_node("EndDay").visible = not session.active and not session.closing
	price_choice.visible = session.active
	claim_choice.visible = session.active
	serve_button.visible = session.active
	serve_button.disabled = not session.customer_ready()
	serve_button.text = "Serve customer (N)" if session.processed < session.quota else "Everyone served!"
	if session.active:
		rows.get_node("SessionStatus").text = "Time left: %02d:%02d | Served: %d / %d" % [ceili(session.remaining_seconds) / 60, ceili(session.remaining_seconds) % 60, session.processed, session.quota]
	elif session.finished:
		rows.get_node("SessionStatus").text = "Market finished today. Refunds settle at midnight."
	elif session.can_start():
		rows.get_node("SessionStatus").text = "Ready to open. More reputation brings more visitors."
	else:
		rows.get_node("SessionStatus").text = session.start_block_reason()
	_refresh_customer()

func _refresh_customer() -> void:
	if not configured:
		return
	var row = $UILayer/Panel/Margin/Rows/CustomerRow
	row.visible = session.active and session.processed < session.quota
	row.get_node("Name").text = session.current_name() + (" • choosing some sparkle" if session.customer_ready() else " • arriving…")
	row.get_node("Portrait").texture = $CustomerVisuals.portrait_for(session.processed)

func _start_day() -> void:
	if not panel.visible or not player_nearby:
		return
	if session.start_day():
		feedback.text = "The queue is open! One minute to serve your visitors. The timer continues while menus are open."
	else:
		feedback.text = session.start_block_reason()
	_refresh()

func _end_day() -> void:
	if day_cycle != null and panel.visible and not session.active and not session.closing:
		_set_open(false)
		day_cycle.end_day()
