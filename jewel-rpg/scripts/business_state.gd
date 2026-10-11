extends Node

signal changed

@export var economy: Resource
var cash: int = 0
var stock: int = 0
var revenue: int = 0
var reputation: int = 0
var misleading_sales: Array[int] = []
var imprisoned := false
var day_closed := false
var last_settled_day := 0
var last_report: Dictionary = {}
var refund_rng := RandomNumberGenerator.new()

func _ready() -> void:
	refund_rng.randomize()
	if economy == null:
		push_warning("BusinessState needs an economy resource.")
		return
	cash = economy.starting_cash

func purchase_one() -> bool:
	if imprisoned or day_closed or economy == null or economy.unit_cost <= 0 or cash < economy.unit_cost:
		return false
	cash -= economy.unit_cost
	stock += 1
	changed.emit()
	return true

func serve_customer(price: int, misleading: bool) -> Dictionary:
	if imprisoned or day_closed:
		return {"sold": false, "message": "Business is closed for the day."}
	if economy == null or not price in economy.sale_prices:
		return {"sold": false, "message": "Choose one of the listed prices first."}
	if stock <= 0:
		return {"sold": false, "message": "Mina: Lovely display. Does the invisible ring come in my size? Buy stock first."}
	var maximum: int = economy.misleading_customer_max if misleading else economy.truthful_customer_max
	if price > maximum:
		return {"sold": false, "message": "Mina: %d credits? My lunch budget objects! At most %d for that description. No sale." % [price, maximum]}
	stock -= 1
	cash += price
	revenue += price
	if misleading:
		misleading_sales.append(price)
	else:
		reputation += economy.truthful_reputation_gain
	changed.emit()
	var message := "Mina: A little sparkle for my commute! Sold for %d credits. Reputation +%d." % [price, economy.truthful_reputation_gain]
	if misleading:
		message = "Mina: Real gold? What a deal! Sold for %d credits. All proceeds are spendable; complaints may arrive tonight." % price
	return {"sold": true, "message": message}

func settle_day(day_id: int) -> Dictionary:
	# Idempotent: reopening a report cannot roll again or pay twice.
	if imprisoned or day_id <= last_settled_day:
		return last_report.duplicate()
	var probability := refund_rng.randf_range(economy.refund_chance_min, economy.refund_chance_max)
	var refund_total := 0
	var complaints := 0
	for amount in misleading_sales:
		if refund_rng.randf() < probability:
			complaints += 1
			refund_total += amount
	day_closed = true
	last_settled_day = day_id
	last_report = {"day": day_id, "complaints": complaints, "refund_total": refund_total,
		"cash_before": cash, "probability": probability, "misleading_count": misleading_sales.size(),
		"imprisoned": refund_total > cash}
	misleading_sales.clear()
	if refund_total > cash:
		# Insolvency is atomic: no partial refunds, no negative cash, run ends.
		imprisoned = true
	else:
		cash -= refund_total
		stock += complaints
		revenue -= refund_total
		reputation -= complaints * economy.complaint_reputation_loss
	changed.emit()
	return last_report.duplicate()

func begin_day() -> void:
	if not imprisoned:
		day_closed = false
