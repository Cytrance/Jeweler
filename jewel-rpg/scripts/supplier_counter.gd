extends Area2D

@export var player_path: NodePath
@export var business_state_path: NodePath
@onready var player = get_node_or_null(player_path) if not player_path.is_empty() else null
@onready var state = get_node_or_null(business_state_path) if not business_state_path.is_empty() else null
@onready var panel: PanelContainer = $UILayer/Panel
@onready var prompt: Label = $Prompt
@onready var details: Label = $UILayer/Panel/Margin/Rows/Details
@onready var feedback: Label = $UILayer/Panel/Margin/Rows/Feedback
@onready var buy_button: Button = $UILayer/Panel/Margin/Rows/Buy
var player_nearby := false
var configured := false

func _ready() -> void:
	panel.hide()
	prompt.hide()
	configured = player != null and state != null and state.economy != null
	if not configured:
		push_warning("SupplierCounter needs player_path and business_state_path linked to configured nodes.")
		return
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	state.changed.connect(_refresh)
	buy_button.pressed.connect(_buy)
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
	elif panel.visible and event.is_action_pressed("buy_stock", false):
		_buy()
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
		feedback.text = "Small beginnings. Very shiny ambitions."
		_refresh()

func _buy() -> void:
	if not configured or not panel.visible or not player_nearby:
		return
	if state.purchase_one():
		feedback.text = "Bought one imitation ring. Your empire now fits in a pocket."
	else:
		feedback.text = "Not enough cash: you need %d credits for one ring." % state.economy.unit_cost

func _refresh() -> void:
	details.text = "%s\n%s\nCost: %d credits each\nCash: %d credits   |   Stock: %d rings" % [state.economy.product_name, state.economy.materials, state.economy.unit_cost, state.cash, state.stock]
	buy_button.text = "Buy 1 ring — %d credits (B)" % state.economy.unit_cost
