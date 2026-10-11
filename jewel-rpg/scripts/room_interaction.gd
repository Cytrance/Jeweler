extends Area2D

@export_enum("travel", "order", "sleep") var interaction := "travel"
@export var prompt_text := "E • Use"
var nearby := false
var world: Node
@onready var prompt: Label = $Prompt

func _ready() -> void:
	world = self
	while world.get_node_or_null("PlayerPlaceholder") == null and world.get_parent() != null:
		world = world.get_parent()
	if world.get_node_or_null("PlayerPlaceholder") == null or world.get_node_or_null("AreaTravel") == null:
		prompt.hide()
		set_process_unhandled_input(false)
		return
	prompt.text = prompt_text
	prompt.hide()
	body_entered.connect(func(body):
		if body == world.get_node("PlayerPlaceholder"):
			nearby = true
			prompt.show())
	body_exited.connect(func(body):
		if body == world.get_node("PlayerPlaceholder"):
			nearby = false
			prompt.hide())

func _unhandled_input(event: InputEvent) -> void:
	if nearby and event.is_action_pressed("interact", false):
		if world.get_node("AreaTravel").open_menu(interaction, self):
			get_viewport().set_input_as_handled()

func set_area_active(_enabled: bool) -> void:
	# Teleports invalidate proximity immediately; physics will establish the new overlap.
	nearby = false
	prompt.hide()
