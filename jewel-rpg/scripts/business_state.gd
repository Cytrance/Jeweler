extends Node

signal changed

@export var economy: Resource
var cash: int = 0
var stock: int = 0
var revenue: int = 0
var reputation: int = 0
var pending_refunds: Array[int] = []

func reserved_cash() -> int:
	var total := 0
	for amount in pending_refunds:
		total += amount
	return total

func available_cash() -> int:
	return cash - reserved_cash()

func serve_customer(price: int, misleading: bool) -> Dictionary:
	# Price and claim are independent. Actual materials never change.
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
		pending_refunds.append(price)
	else:
		reputation += economy.truthful_reputation_gain
	changed.emit()
	var message := "Mina: A little sparkle for my commute! Sold for %d credits. Reputation +%d." % [price, economy.truthful_reputation_gain]
	if misleading:
		message = "Mina: Real gold? What a deal! Sold for %d credits. A complaint is scheduled; %d credits are held for its refund." % [price, price]
	return {"sold": true, "message": message}


func _ready() -> void:
	if economy == null:
		push_warning("BusinessState needs an economy resource.")
		return
	cash = economy.starting_cash

func purchase_one() -> bool:
	# The state owns the transaction: UI cannot subtract cash or create stock.
	if economy == null or economy.unit_cost <= 0 or available_cash() < economy.unit_cost:
		return false
	cash -= economy.unit_cost
	stock += 1
	changed.emit()
	return true
