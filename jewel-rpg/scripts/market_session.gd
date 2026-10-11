extends CanvasLayer

signal changed
signal customer_changed
signal session_closing

@export var business_state_path: NodePath
@export var clock_path: NodePath
@export var player_path: NodePath
@export var sales_path: NodePath
@export var supplier_path: NodePath
@export var sign_path: NodePath
@onready var state = get_node(business_state_path)
@onready var clock = get_node(clock_path)
@onready var player = get_node(player_path)
@onready var fade: ColorRect = $Fade
@onready var report: PanelContainer = $Report
@onready var details: Label = $Report/Margin/Rows/Details
var traffic_rng := RandomNumberGenerator.new()
var session_day := 0
var quota := 0
var processed := 0
var remaining_seconds := 0.0
var arrival_remaining := 0.0
var active := false
var closing := false
var finished := false
var unserved := 0
var reputation_penalty := 0
var transition_elapsed := 0.0
var evening_reached := false
const NOTICE_SECONDS := 0.5
const FADE_SECONDS := 0.45
const ARRIVAL_SECONDS := 0.65
const NAMES := ["Mina", "Jo", "Noor", "Bea"]

func _ready() -> void:
	traffic_rng.randomize()
	report.hide()
	fade.hide()
	$Report/Margin/Rows/Continue.pressed.connect(continue_evening)
	clock.time_changed.connect(_on_clock_changed)

func _on_clock_changed() -> void:
	if session_day != 0 and clock.day != session_day:
		session_day = 0
		quota = 0
		processed = 0
		finished = false
		changed.emit()

func can_start() -> bool:
	return start_block_reason().is_empty()

func start_block_reason() -> String:
	# Check calendar/state gates before stock, so an empty inventory does not hide closing.
	if active or closing:
		return "Today’s market is already in progress."
	if session_day == clock.day:
		return "Market finished today. Refunds settle at midnight."
	if clock.awaiting_report or state.imprisoned or state.day_closed:
		return "Settle the day before opening the market."
	if clock.hour >= 18.0:
		return "Too late to open today. Come back before 6pm."
	if state.stock <= 0:
		return "No stock to sell. Order at your apartment computer and wait for morning delivery."
	return ""

func start_day() -> bool:
	if not can_start():
		return false
	var config = state.economy
	var reputation_bonus := floori(float(state.reputation) / maxi(1, config.reputation_per_customer))
	var variation: int = maxi(0, config.daily_customer_variation)
	quota = clampi(config.daily_customer_base + reputation_bonus + traffic_rng.randi_range(-variation, variation), config.minimum_daily_customers, config.maximum_daily_customers)
	session_day = clock.day
	processed = 0
	remaining_seconds = maxf(0.1, config.market_session_seconds)
	arrival_remaining = ARRIVAL_SECONDS
	active = true
	finished = false
	clock.market_hold = true
	clock.hour = maxf(8.0, clock.hour)
	clock._refresh()
	customer_changed.emit()
	changed.emit()
	return true

func current_name() -> String:
	return NAMES[processed % NAMES.size()]

func customer_ready() -> bool:
	return active and remaining_seconds > 0.0 and processed < quota and arrival_remaining <= 0.0

func serve_offer(price: int, misleading: bool) -> Dictionary:
	if active and processed >= quota:
		return {"sold": false, "message": "All today’s visitors have been served. Wait for closing time."}
	if not customer_ready():
		return {"sold": false, "message": "Wait for the next customer." if active and processed < quota else "Start today's market before serving customers."}
	var customer := current_name()
	var result: Dictionary = state.serve_customer(price, misleading)
	result.message = result.message.replace("Mina:", customer + ":")
	# Missing stock or invalid configuration does not spend a customer's visit.
	if state.stock <= 0 and not result.sold or not price in state.economy.sale_prices or state.imprisoned or state.day_closed:
		return result
	processed += 1
	arrival_remaining = ARRIVAL_SECONDS
	customer_changed.emit()
	changed.emit()
	return result

func _process(delta: float) -> void:
	advance_session(delta)

func advance_session(delta: float) -> void:
	var elapsed := maxf(0.0, delta)
	if active:
		remaining_seconds = maxf(0.0, remaining_seconds - elapsed)
		arrival_remaining = maxf(0.0, arrival_remaining - elapsed)
		if remaining_seconds <= 0.0:
			_end_session()
		changed.emit()
	elif closing and not report.visible:
		transition_elapsed += elapsed
		var fade_elapsed := maxf(0.0, transition_elapsed - NOTICE_SECONDS)
		$ClosingNotice.visible = transition_elapsed < NOTICE_SECONDS
		if fade_elapsed >= FADE_SECONDS and not evening_reached:
			clock.skip_to_evening()
			evening_reached = true
		if fade_elapsed < FADE_SECONDS:
			fade.color.a = fade_elapsed / FADE_SECONDS
		elif fade_elapsed < FADE_SECONDS * 2.0:
			fade.color.a = 1.0 - (fade_elapsed - FADE_SECONDS) / FADE_SECONDS
		else:
			fade.hide()
			report.show()
			changed.emit()

func _end_session() -> void:
	active = false
	closing = true
	finished = true
	unserved = quota - processed
	reputation_penalty = ceili(float(unserved) / maxi(1, state.economy.unserved_customers_per_reputation_loss))
	state.reputation -= reputation_penalty
	state.changed.emit()
	# Existing interactions release only their own locks, before this modal owns it.
	get_node(sales_path)._set_open(false)
	get_node(supplier_path)._set_open(false)
	get_node(sign_path)._set_dialogue(false)
	player.movement_locked = true
	transition_elapsed = 0.0
	evening_reached = false
	fade.color.a = 0.0
	fade.show()
	$ClosingNotice.show()
	_refresh_report()
	session_closing.emit()
	customer_changed.emit()

func _input(_event: InputEvent) -> void:
	if closing and not report.visible:
		get_viewport().set_input_as_handled()

func continue_evening() -> void:
	if not closing or not report.visible:
		return
	report.hide()
	closing = false
	clock.market_hold = false
	player.movement_locked = false
	changed.emit()

func _refresh_report() -> void:
	details.text = "6PM • MARKET CLOSED\nServed: %d / %d customers\nWent home: %d   •   Reputation lost: %d\n\nYour sale proceeds remain available.\nExplore or order tomorrow’s stock this evening.\nMidnight: refund requests are settled separately." % [processed, quota, unserved, reputation_penalty]

func restore_presentation(show_report: bool) -> void:
	_refresh_report()
	report.visible = show_report
	fade.visible = closing and not show_report
	$ClosingNotice.visible = closing and transition_elapsed < NOTICE_SECONDS
	if closing and not show_report:
		# Rebuild the fade without running closing's penalties a second time.
		advance_session(0.0)
