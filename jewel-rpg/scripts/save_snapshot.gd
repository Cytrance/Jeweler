extends RefCounted
# Versioned, data-only snapshots. No nodes, resources, or executable objects are loaded.
const VERSION := 1
const LIMIT := 1000000000
const BUSINESS := ["cash", "stock", "revenue", "reputation", "imprisoned", "day_closed", "last_settled_day"]
const CLOCK := ["day", "hour", "awaiting_report"]
const MARKET := ["session_day", "quota", "processed", "remaining_seconds", "arrival_remaining", "active", "closing", "finished", "unserved", "reputation_penalty", "transition_elapsed", "evening_reached"]
const TRAVEL := ["current_area", "pending_sleep", "pending_travel_minutes"]

static func properties(node: Node, names: Array) -> Dictionary:
	var result := {}
	for field in names:
		result[field] = node.get(field)
	return result

static func capture(game: Node) -> Dictionary:
	var state = game.get_node("BusinessState")
	var market = game.get_node("MarketSession")
	var player = game.get_node("PlayerPlaceholder")
	var business := properties(state, BUSINESS)
	business.misleading_sales = state.misleading_sales.duplicate()
	business.last_report = state.last_report.duplicate()
	# JSON numbers cannot preserve every 64-bit RNG state. Decimal strings can.
	business.rng_seed = str(state.refund_rng.seed)
	business.rng_state = str(state.refund_rng.state)
	var session := properties(market, MARKET)
	session.rng_seed = str(market.traffic_rng.seed)
	session.rng_state = str(market.traffic_rng.state)
	session.report_visible = market.report.visible
	return {"version": VERSION, "business": business,
		"clock": properties(game.get_node("MarketClock"), CLOCK),
		"market": session, "travel": properties(game.get_node("AreaTravel"), TRAVEL),
		"orders": game.get_node("DeliveryOrders").pending.duplicate(true),
		"player": {"x": player.position.x, "y": player.position.y,
			"facing": player.facing, "left": player.facing_left},
		"offer": {"price": game.get_node("Obstacle").price_choice.selected,
			"claim": game.get_node("Obstacle").claim_choice.selected}}

static func number(value: Variant, low: float, high: float, integer := false) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and value >= low and value <= high and (not integer or float(value) == floorf(float(value)))

static func integers(data: Dictionary, fields: Array, low := 0, high := LIMIT) -> bool:
	for field in fields:
		if not number(data.get(field), low, high, true):
			return false
	return true

static func booleans(data: Dictionary, fields: Array) -> bool:
	for field in fields:
		if not data.get(field) is bool:
			return false
	return true

static func rng_valid(data: Dictionary) -> bool:
	for field in ["rng_seed", "rng_state"]:
		var value = data.get(field)
		if not value is String or not value.is_valid_int() or str(value.to_int()) != value:
			return false
	return true

static func valid(data: Variant) -> bool:
	if not data is Dictionary or not number(data.get("version"), VERSION, VERSION, true):
		return false
	for section in ["business", "clock", "market", "travel", "player", "offer"]:
		if not data.get(section) is Dictionary:
			return false
	var b: Dictionary = data.business
	var c: Dictionary = data.clock
	var m: Dictionary = data.market
	var t: Dictionary = data.travel
	var p: Dictionary = data.player
	if not integers(b, ["cash", "stock", "last_settled_day"]) or not integers(b, ["revenue", "reputation"], -LIMIT):
		return false
	if not booleans(b, ["imprisoned", "day_closed"]) or not rng_valid(b):
		return false
	if not b.get("misleading_sales") is Array or b.misleading_sales.size() > 10000 or not b.get("last_report") is Dictionary:
		return false
	for price in b.misleading_sales:
		if not number(price, 1, LIMIT, true):
			return false
	if not integers(c, ["day"], 1) or not number(c.get("hour"), 0, 24) or not booleans(c, ["awaiting_report"]):
		return false
	if c.awaiting_report != b.day_closed or (c.hour == 24) != c.awaiting_report or b.last_settled_day != c.day - (0 if b.day_closed else 1):
		return false
	if b.imprisoned and not b.day_closed:
		return false
	var report: Dictionary = b.last_report
	if b.last_settled_day > 0:
		if not integers(report, ["day", "complaints", "refund_total", "cash_before", "misleading_count"]) or not number(report.get("probability"), 0, 1) or not booleans(report, ["imprisoned"]):
			return false
		if report.day != b.last_settled_day or report.complaints > report.misleading_count or report.imprisoned != b.imprisoned:
			return false
	elif not report.is_empty():
		return false
	if b.day_closed and (not b.misleading_sales.is_empty() or report.imprisoned != (report.refund_total > report.cash_before)):
		return false
	if not integers(m, ["session_day", "quota", "processed", "unserved", "reputation_penalty"]) or not booleans(m, ["active", "closing", "finished", "evening_reached", "report_visible"]) or not rng_valid(m):
		return false
	for field in ["remaining_seconds", "arrival_remaining", "transition_elapsed"]:
		if not number(m.get(field), 0, LIMIT):
			return false
	if m.session_day > c.day or m.quota > 30 or m.processed > m.quota or (m.finished and m.unserved > m.quota) or m.remaining_seconds > 60 or m.arrival_remaining > 0.65:
		return false
	if (m.active or m.closing or m.finished) and (m.session_day != c.day or m.quota < 3):
		return false
	if m.active and (m.closing or m.finished or m.remaining_seconds <= 0):
		return false
	if (m.active or m.closing) and (c.awaiting_report or m.session_day != c.day or t.get("current_area") != "plaza"):
		return false
	if m.closing and (not m.finished or m.remaining_seconds != 0):
		return false
	if m.report_visible and (not m.closing or not m.evening_reached):
		return false
	if t.get("current_area") not in ["apartment", "plaza"] or not booleans(t, ["pending_sleep"]) or not number(t.get("pending_travel_minutes"), 0, 30):
		return false
	if (t.pending_sleep or t.pending_travel_minutes > 0) and not c.awaiting_report:
		return false
	if t.pending_sleep and (t.current_area != "apartment" or t.pending_travel_minutes > 0):
		return false
	if not data.get("orders") is Array or data.orders.size() > 10000:
		return false
	for order in data.orders:
		if not order is Dictionary or not integers(order, ["quantity", "day"], 1):
			return false
		if order.day < c.day or order.day > c.day + 1 or (order.day == c.day and c.hour >= 8 and not c.awaiting_report):
			return false
	if not number(p.get("x"), -LIMIT, LIMIT) or not number(p.get("y"), -LIMIT, LIMIT) or p.get("facing") not in ["up", "down", "side"] or not booleans(p, ["left"]):
		return false
	return integers(data.offer, ["price"], 0, 2) and integers(data.offer, ["claim"], 0, 1)

static func assign_properties(node: Node, data: Dictionary, names: Array) -> void:
	for field in names:
		# JSON parses numbers as floats; retain each declared property's original type.
		node.set(field, int(data[field]) if node.get(field) is int else data[field])

static func apply(game: Node, data: Dictionary) -> void:
	# Caller validates the whole document before touching any live state.
	var state = game.get_node("BusinessState")
	var clock = game.get_node("MarketClock")
	var market = game.get_node("MarketSession")
	var travel = game.get_node("AreaTravel")
	var orders = game.get_node("DeliveryOrders")
	var player = game.get_node("PlayerPlaceholder")
	assign_properties(state, data.business, BUSINESS)
	state.misleading_sales.clear()
	for price in data.business.misleading_sales:
		state.misleading_sales.append(int(price))
	state.last_report = data.business.last_report.duplicate()
	for field in ["day", "complaints", "refund_total", "cash_before", "misleading_count"]:
		if state.last_report.has(field):
			state.last_report[field] = int(state.last_report[field])
	state.refund_rng.seed = data.business.rng_seed.to_int()
	state.refund_rng.state = data.business.rng_state.to_int()
	assign_properties(clock, data.clock, CLOCK)
	assign_properties(market, data.market, MARKET)
	market.traffic_rng.seed = data.market.rng_seed.to_int()
	market.traffic_rng.state = data.market.rng_state.to_int()
	assign_properties(travel, data.travel, TRAVEL)
	orders.pending.clear()
	for order in data.orders:
		orders.pending.append({"quantity": int(order.quantity), "day": int(order.day)})
	clock.market_hold = market.active or market.closing
	# Area activation emits time_changed; all business, clock and queue fields are ready first.
	travel.set_area(data.travel.current_area)
	player.position = Vector2(data.player.x, data.player.y)
	player.facing = data.player.facing
	player.facing_left = data.player.left
	player.movement_locked = clock.awaiting_report or market.closing
	player._update_visual(false)
	game.get_node("Obstacle").price_choice.select(int(data.offer.price))
	game.get_node("Obstacle").claim_choice.select(int(data.offer.claim))
	if clock.awaiting_report:
		game.get_node("DayCycle").present_report(state.last_report)
	market.restore_presentation(data.market.report_visible)
	state.changed.emit()
	market.changed.emit()
	market.customer_changed.emit()
