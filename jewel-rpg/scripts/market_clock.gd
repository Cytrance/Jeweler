extends Node

signal time_changed
signal day_ended(day_id: int)

@export var seconds_per_day: float = 480.0
@export var starting_hour: float = 8.0
@export var player_path: NodePath
@export var business_state_path: NodePath
@export var tint_path: NodePath
@onready var player = get_node(player_path)
@onready var state = get_node(business_state_path)
@onready var tint: CanvasModulate = get_node(tint_path)
var day := 1
var hour := 8.0
var awaiting_report := false
var market_hold := false

func _ready() -> void:
	hour = starting_hour
	_refresh()

func _process(delta: float) -> void:
	advance_time(delta)

func advance_time(delta: float) -> void:
	if market_hold or awaiting_report or state.imprisoned or player.movement_locked or seconds_per_day <= 0:
		return
	hour = minf(24.0, hour + maxf(0.0, delta) * 24.0 / seconds_per_day)
	_refresh()
	if hour >= 24.0:
		finish_day()

func finish_day() -> void:
	if market_hold or awaiting_report or state.imprisoned or player.movement_locked:
		return
	awaiting_report = true
	hour = 24.0
	_refresh()
	day_ended.emit(day)

func next_day() -> void:
	if not awaiting_report or state.imprisoned:
		return
	day += 1
	hour = 0.0
	awaiting_report = false
	_refresh()

func time_label() -> String:
	var minutes := mini(1439, int(hour * 60.0))
	return "Day %d  •  %02d:%02d" % [day, minutes / 60, minutes % 60]

func color_at_hour(value: float) -> Color:
	var night := Color(0.38, 0.42, 0.64)
	var dawn := Color(1.0, 0.80, 0.77)
	var daylight := Color.WHITE
	var dusk := Color(0.92, 0.64, 0.64)
	if value < 5.0:
		return night
	if value < 7.0:
		return night.lerp(dawn, (value - 5.0) / 2.0)
	if value < 9.0:
		return dawn.lerp(daylight, (value - 7.0) / 2.0)
	if value < 17.0:
		return daylight
	if value < 19.0:
		return daylight.lerp(dusk, (value - 17.0) / 2.0)
	if value < 21.0:
		return dusk.lerp(night, (value - 19.0) / 2.0)
	return night

func _refresh() -> void:
	tint.color = color_at_hour(hour)
	time_changed.emit()

func skip_to_evening() -> void:
	hour = 18.0
	_refresh()
