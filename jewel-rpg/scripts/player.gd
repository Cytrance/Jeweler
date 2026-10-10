extends CharacterBody2D

# Movement speed in pixels per second; adjustable in the Inspector.
@export var speed: float = 200.0


func _physics_process(_delta: float) -> void:
	# get_vector limits diagonal input to the same speed as straight input.
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	# move_and_slide applies the physics timestep and handles solid obstacles.
	move_and_slide()
