extends CanvasLayer

@export var business_state_path: NodePath
@onready var state = get_node_or_null(business_state_path) if not business_state_path.is_empty() else null
@onready var summary: Label = $Panel/Margin/Summary

func _ready() -> void:
	if state == null:
		push_warning("BusinessHUD needs business_state_path.")
		return
	state.changed.connect(_refresh)
	_refresh()

func _refresh() -> void:
	summary.text = "Cash: %d credits\nRings in stock: %d\nRevenue: %d | Rep: %+d" % [state.cash, state.stock, state.revenue, state.reputation]
