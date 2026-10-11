@tool
extends Node2D

## Cutaway room edges: visible plaster and collision share the same rectangles.
## Coordinates are local so this shell can be reused in other indoor scenes.
@export var floor_bounds := Rect2(144, 152, 672, 352):
	set(value):
		floor_bounds = value
		queue_redraw()
		var trim_node := get_node_or_null("RearTrim")
		if trim_node:
			trim_node.floor_bounds = value
@export var thickness := 24.0:
	set(value):
		thickness = value
		queue_redraw()
		var trim_node := get_node_or_null("RearTrim")
		if trim_node:
			trim_node.thickness = value
const WallProfile = preload("res://scripts/interior_wall_profile.gd")
@export var wood: Texture2D:
	set(value):
		wood = value
		queue_redraw()
		var trim_node := get_node_or_null("RearTrim")
		if trim_node:
			trim_node.wood = value
@export var plaster: Texture2D:
	set(value):
		plaster = value
		queue_redraw()

func rectangles() -> Array[Rect2]:
	var r := floor_bounds
	return [
		Rect2(r.position - Vector2(thickness / 2, 0), Vector2(thickness, r.size.y)),
		Rect2(Vector2(r.end.x - thickness / 2, r.position.y), Vector2(thickness, r.size.y)),
		Rect2(Vector2(r.position.x, r.end.y - thickness / 2), Vector2(r.size.x, thickness)),
		Rect2(r.position - Vector2(0, thickness / 2), Vector2(r.size.x, thickness)),
	]

func _ready() -> void:
	$RearTrim.floor_bounds = floor_bounds
	$RearTrim.thickness = thickness
	$RearTrim.wood = wood
	if Engine.is_editor_hint():
		return
	for index in rectangles().size():
		var rect := rectangles()[index]
		var body := StaticBody2D.new()
		body.name = ["Left", "Right", "Bottom", "Top"][index]
		body.position = rect.get_center()
		var collision := CollisionShape2D.new()
		collision.name = "Collision"
		var shape := RectangleShape2D.new()
		shape.size = rect.size
		collision.shape = shape
		body.add_child(collision)
		add_child(body)

func _draw() -> void:
	var r := floor_bounds
	# Continuous rectangular profiles share endpoints; corners contain no end caps.
	WallProfile.side(self, Rect2(r.position.x - thickness / 2, r.position.y, thickness, r.size.y), wood, plaster)
	WallProfile.side(self, Rect2(r.end.x - thickness / 2, r.position.y, thickness, r.size.y), wood, plaster)
	WallProfile.front(self, Rect2(r.position.x - thickness / 2, r.end.y - thickness + 4, r.size.x + thickness, thickness + 8), wood, plaster)
