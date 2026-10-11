extends Node

signal changed

@export var economy: Resource
var cash: int = 0
var stock: int = 0

func _ready() -> void:
	if economy == null:
		push_warning("BusinessState needs an economy resource.")
		return
	cash = economy.starting_cash

func purchase_one() -> bool:
	# The state owns the transaction: UI cannot subtract cash or create stock.
	if economy == null or economy.unit_cost <= 0 or cash < economy.unit_cost:
		return false
	cash -= economy.unit_cost
	stock += 1
	changed.emit()
	return true
