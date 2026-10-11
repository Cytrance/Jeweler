extends CanvasLayer
const Snapshot = preload("res://scripts/save_snapshot.gd")
const Store = preload("res://scripts/save_store.gd")
const GAME = preload("res://scenes/main.tscn")
@export var save_path := "user://business-save.json"
@onready var game = get_node("../Game")
@onready var title: Control = $Title
@onready var message: Label = $Title/Panel/Margin/Rows/Message
@onready var continue_button: Button = $Title/Panel/Margin/Rows/Continue
@onready var toolbar: Control = $Toolbar
@onready var notice: Label = $Toolbar/Notice
@onready var confirm: ConfirmationDialog = $ConfirmNew
var loaded: Dictionary = {}
var playing := false
var notice_seconds := 0.0

func _ready() -> void:
	add_to_group("save_game")
	get_tree().auto_accept_quit = false
	get_tree().paused = true
	toolbar.hide()
	var slot := Store.load_slot(save_path)
	loaded = slot.data
	message.text = slot.message
	continue_button.disabled = loaded.is_empty()
	continue_button.pressed.connect(continue_game)
	$Title/Panel/Margin/Rows/New.pressed.connect(request_new_game)
	$Title/Panel/Margin/Rows/Quit.pressed.connect(func(): get_tree().quit())
	$Toolbar/Save.pressed.connect(save_now)
	$Toolbar/Quit.pressed.connect(quit_game)
	confirm.confirmed.connect(start_new_game)
	confirm.canceled.connect(_cancel_new_game)
	if not loaded.is_empty():
		continue_button.grab_focus()
	else:
		$Title/Panel/Margin/Rows/New.grab_focus()

func continue_game() -> void:
	if playing or loaded.is_empty():
		return
	Snapshot.apply(game, loaded)
	_begin_play("Welcome back. Your business continues where you left it.")

func request_new_game() -> void:
	if playing or FileAccess.file_exists(save_path) or FileAccess.file_exists(save_path + ".bak"):
		get_tree().paused = true
		confirm.popup_centered()
	else:
		start_new_game()

func _cancel_new_game() -> void:
	get_tree().paused = not playing

func start_new_game() -> void:
	# Prepare and save a fresh run before replacing the current one. A failed write
	# leaves both the running game and the previous save available.
	var fresh = GAME.instantiate()
	get_parent().add_child(fresh)
	var error := Store.write_slot(save_path, Snapshot.capture(fresh))
	if error != OK:
		fresh.queue_free()
		_cancel_new_game()
		show_status("Could not start a saved game (%s). Your previous progress is unchanged." % error_string(error))
		return
	game.queue_free()
	game = fresh
	_begin_play("New business started. Save with F6; closing the window also saves.")

func _begin_play(text: String) -> void:
	playing = true
	title.hide()
	toolbar.show()
	get_tree().paused = false
	show_status(text)

func save_now() -> bool:
	if not playing:
		return false
	var error := Store.write_slot(save_path, Snapshot.capture(game))
	show_status("Business saved." if error == OK else "Save failed (%s). Keep the game open and try again; your previous save is safe." % error_string(error))
	return error == OK

func quit_game() -> void:
	if not playing or save_now():
		get_tree().quit()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		quit_game()

func _input(event: InputEvent) -> void:
	if playing and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_F6:
		save_now()
		get_viewport().set_input_as_handled()

func show_status(text: String) -> void:
	if playing:
		notice.text = text
		notice.show()
		notice_seconds = 8.0
	else:
		message.text = text

func _process(delta: float) -> void:
	if notice_seconds > 0:
		notice_seconds -= delta
		if notice_seconds <= 0:
			notice.hide()

func _exit_tree() -> void:
	# Also makes the wrapper safe to dispose in an isolated test scene.
	get_tree().paused = false
	get_tree().auto_accept_quit = true
