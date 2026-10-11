extends Node2D

# Player anchor limits account for the 32x48 collider and the taller, bobbing sprite.
# Configure this reusable scene for other maps without changing movement/save code.
@export var player_bounds := Rect2(40, 80, 880, 434)
@export var collider_half_size := Vector2(16, 24)
@export var wall_thickness := 128.0

func _ready() -> void:
	var edges := player_bounds.grow_individual(collider_half_size.x, collider_half_size.y, collider_half_size.x, collider_half_size.y)
	var t := wall_thickness
	var walls := [
		Rect2(edges.position - Vector2(t, t), Vector2(t, edges.size.y + 2 * t)),
		Rect2(Vector2(edges.end.x, edges.position.y - t), Vector2(t, edges.size.y + 2 * t)),
		Rect2(Vector2(edges.position.x, edges.position.y - t), Vector2(edges.size.x, t)),
		Rect2(Vector2(edges.position.x, edges.end.y), Vector2(edges.size.x, t)),
	]
	for index in walls.size():
		var body := StaticBody2D.new()
		body.name = ["Left", "Right", "Top", "Bottom"][index]
		body.position = walls[index].get_center()
		var collision := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = walls[index].size
		collision.shape = shape
		body.add_child(collision)
		add_child(body)

func safe_position(point: Vector2) -> Vector2:
	return Vector2(clampf(point.x, player_bounds.position.x, player_bounds.end.x), clampf(point.y, player_bounds.position.y, player_bounds.end.y))
