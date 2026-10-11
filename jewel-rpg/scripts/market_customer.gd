extends Node2D

var motion: Tween

func arrive(destination: Vector2) -> void:
	position = destination + Vector2(25, 100)
	modulate.a = 0.0
	motion = create_tween().set_parallel()
	motion.tween_property(self, "position", destination, 0.6)
	motion.tween_property(self, "modulate:a", 1.0, 0.4)

func depart() -> void:
	if motion:
		motion.kill()
	motion = create_tween().set_parallel()
	motion.tween_property(self, "position", position + Vector2(110, 30), 0.5)
	motion.tween_property(self, "modulate:a", 0.0, 0.5)
	motion.finished.connect(queue_free)
