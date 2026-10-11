extends CharacterBody2D

# Movement speed in pixels per second; adjustable in the Inspector.
@export var speed: float = 200.0

var movement_locked := false:
	set(value):
		movement_locked = value
		if value:
			velocity = Vector2.ZERO
			if is_node_ready():
				_update_visual(false)

var facing := "down"
var facing_left := false
@onready var visual: AnimatedSprite2D = $Visual
@onready var visual_rest_position := visual.position


func _physics_process(_delta: float) -> void:
	if movement_locked:
		_update_visual(false)
		return
	# get_vector limits diagonal input to the same speed as straight input.
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction != Vector2.ZERO:
		# Equal diagonal input uses the side view, so facing never flickers.
		if absf(direction.x) >= absf(direction.y):
			facing = "side"
			facing_left = direction.x < 0.0
		else:
			facing = "up" if direction.y < 0.0 else "down"
			facing_left = false
	velocity = direction * speed
	var before := position
	# move_and_slide applies the physics timestep and handles solid obstacles.
	move_and_slide()
	# Pressing into a wall faces it, but only real movement plays the walk loop.
	_update_visual(direction != Vector2.ZERO and position.distance_squared_to(before) > 0.0001)


func _update_visual(walking: bool) -> void:
	visual.flip_h = facing_left
	var animation := StringName(("walk_" if walking else "idle_") + facing)
	if walking:
		visual.play(animation)
		# Two gentle rises per four-frame stride; only the artwork moves.
		var phase := (visual.frame + visual.frame_progress) * PI / 2.0
		visual.position = visual_rest_position + Vector2(0, -2.0 * pow(sin(phase), 2))
	else:
		visual.animation = animation
		visual.stop()
		visual.frame = 0
		visual.position = visual_rest_position
