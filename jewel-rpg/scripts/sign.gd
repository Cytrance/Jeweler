extends Area2D

# This sign owns its proximity prompt and one dialogue, not a general dialogue system.
@export var player_path: NodePath
@onready var player = get_node_or_null(player_path) if not player_path.is_empty() else null
@onready var prompt: Label = $Prompt
@onready var dialogue: PanelContainer = $DialogueLayer/Dialogue
var player_nearby := false


func _ready() -> void:
	if player == null:
		push_warning("Price board needs player_path assigned to a player with movement_locked and velocity.")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	prompt.hide()
	dialogue.hide()


func _on_body_entered(body: Node2D) -> void:
	if body == player:
		player_nearby = true
		prompt.visible = not dialogue.visible


func _on_body_exited(body: Node2D) -> void:
	if body == player:
		player_nearby = false
		prompt.hide()
		_set_dialogue(false)


func _unhandled_input(event: InputEvent) -> void:
	# allow_echo=false prevents holding E from repeatedly opening/closing the panel.
	if event.is_action_pressed("interact", false):
		if dialogue.visible:
			_set_dialogue(false)
		elif player_nearby and is_instance_valid(player) and not player.movement_locked:
			_set_dialogue(true)
		else:
			return
		get_viewport().set_input_as_handled()
	elif dialogue.visible and event.is_action_pressed("ui_cancel", false):
		_set_dialogue(false)
		get_viewport().set_input_as_handled()


func _set_dialogue(open: bool) -> void:
	var was_open := dialogue.visible
	dialogue.visible = open
	if is_instance_valid(player) and (open or was_open):
		player.movement_locked = open
		if open:
			player.velocity = Vector2.ZERO
	prompt.visible = player_nearby and not open
