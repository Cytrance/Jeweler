extends Area2D

@export var player_path: NodePath
@export var business_state_path: NodePath
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
	configured = player != null and state != null and state.economy != null
	if not configured:
		push_warning("SalesCounter needs player_path and business_state_path linked to configured nodes.")
		return
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	state.changed.connect(_refresh)
	serve_button.pressed.connect(_serve)
	$UILayer/Panel/Margin/Rows/EndDay.pressed.connect(_end_day)
	for price in state.economy.sale_prices:
		price_choice.add_item("Asking price: %d credits" % price, price)
		if price == state.economy.default_sale_price:
			price_choice.select(price_choice.item_count - 1)
	claim_choice.add_item("Truthful: " + state.economy.truthful_claim)
	claim_choice.add_item("Misleading: " + state.economy.misleading_claim)
	_refresh()

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
	elif panel.visible and event.is_action_pressed("end_day", false):
		_end_day()
	elif panel.visible and event.is_action_pressed("serve_customer", false):
		_serve()
	else:
		return
	get_viewport().set_input_as_handled()

func _set_open(open: bool) -> void:
	var owned_lock := panel.visible
	panel.visible = open
	if is_instance_valid(player) and (open or owned_lock):
		player.movement_locked = open
	prompt.visible = player_nearby and not open
	if open:
		feedback.text = "Customer: Mina, commuter and enthusiastic bargain hunter. Choose a price and claim, then serve her."
		_refresh()

func _serve() -> void:
	if not configured or not panel.visible or not player_nearby:
		return
	var price := price_choice.get_selected_id()
	var result: Dictionary = state.serve_customer(price, claim_choice.selected == 1)
	feedback.text = result.message

func _refresh() -> void:
	details.text = "Actual materials: %s\nStock: %d rings | Sales revenue: %d credits | Reputation: %+d" % [state.economy.materials, state.stock, state.revenue, state.reputation]
	details.text += "\nMisleading sales carry a 10–25% complaint chance.\nRefunds exceed your cash? Prison ends this run."
	serve_button.text = "Serve next customer (N)"

func _end_day() -> void:
	if day_cycle != null and panel.visible:
		_set_open(false)
		day_cycle.end_day()
