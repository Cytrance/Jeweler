extends CanvasLayer

@export var clock_path: NodePath
@export var business_state_path: NodePath
@export var player_path: NodePath
@onready var session = get_node("../MarketSession")
@onready var clock = get_node(clock_path)
@onready var state = get_node(business_state_path)
@onready var player = get_node(player_path)
@onready var clock_label: Label = $ClockPanel/Margin/Time
@onready var report: PanelContainer = $Report
@onready var heading: Label = $Report/Margin/Rows/Heading
@onready var details: Label = $Report/Margin/Rows/Details
@onready var continue_button: Button = $Report/Margin/Rows/Continue
@onready var restart_button: Button = $Report/Margin/Rows/Restart

func _ready() -> void:
	clock.time_changed.connect(_refresh_clock)
	session.changed.connect(_refresh_clock)
	clock.day_ended.connect(_show_report)
	continue_button.pressed.connect(_continue)
	restart_button.pressed.connect(_restart)
	report.hide()
	_refresh_clock()

func _refresh_clock() -> void:
	clock_label.text = clock.time_label()
	if session.active:
		clock_label.text += "\nMarket: %ds | %d/%d served" % [ceili(session.remaining_seconds), session.processed, session.quota]

func end_day() -> void:
	clock.finish_day()

func _show_report(day_id: int) -> void:
	var result: Dictionary = state.settle_day(day_id)
	player.movement_locked = true
	report.show()
	continue_button.visible = not state.imprisoned
	restart_button.visible = state.imprisoned
	heading.text = "Prison: the sparkle stops here" if state.imprisoned else "Day %d • Closing the books" % day_id
	details.text = "Misleading sales: %d | Refund requests: %d\nRefunds due: %d credits | Cash before refunds: %d credits\n" % [result.misleading_count, result.complaints, result.refund_total, result.cash_before]
	if state.imprisoned:
		details.text += "You cannot cover tonight’s refunds. Your jewellery empire has traded its stall for a cell.\n\nThis run has ended. Start again to try a different strategy."
	else:
		details.text += "Refunds paid. Rings returned to stock: %d.\nCash remaining: %d | Reputation: %+d\n\nCustomers who did not complain keep their rings. Tomorrow is another opportunity to sparkle." % [result.complaints, state.cash, state.reputation]

func _continue() -> void:
	if not report.visible or state.imprisoned:
		return
	report.hide()
	player.movement_locked = false
	state.begin_day()
	clock.next_day()

func _restart() -> void:
	if report.visible and state.imprisoned:
		get_tree().reload_current_scene()
