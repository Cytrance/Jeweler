extends CanvasLayer

signal delivered(quantity: int)
var pending: Array[Dictionary] = []
@onready var state = get_node("../BusinessState")
@onready var clock = get_node("../MarketClock")
@onready var notice: Label = $Notice
var notice_seconds := 0.0

func _ready() -> void:
	clock.time_changed.connect(check_deliveries)
	notice.hide()

func place_order(quantity: int = 1) -> bool:
	if quantity <= 0 or state.imprisoned or state.day_closed or clock.awaiting_report or clock.hour >= 24.0:
		return false
	var cost: int = quantity * state.economy.unit_cost
	if cost <= 0 or state.cash < cost:
		return false
	state.cash -= cost
	pending.append({"quantity": quantity, "day": clock.day + 1})
	state.changed.emit()
	return true

func pending_quantity() -> int:
	var total := 0
	for order in pending:
		total += int(order.quantity)
	return total

func check_deliveries() -> void:
	if state.imprisoned or state.day_closed or clock.awaiting_report:
		return
	var total := 0
	for index in range(pending.size() - 1, -1, -1):
		var order: Dictionary = pending[index]
		if clock.day > int(order.day) or clock.day == int(order.day) and clock.hour >= 8.0:
			total += int(order.quantity)
			pending.remove_at(index)
	if total > 0:
		state.stock += total
		state.changed.emit()
		notice.text = "Delivery at your apartment: %d rings added to your inventory!" % total
		notice.show()
		notice_seconds = 7.0
		delivered.emit(total)

func _process(delta: float) -> void:
	if notice_seconds > 0.0:
		notice_seconds -= delta
		if notice_seconds <= 0.0:
			notice.hide()
