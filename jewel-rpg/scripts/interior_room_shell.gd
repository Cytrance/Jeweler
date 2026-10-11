@tool
extends Node2D

## Cutaway room edges: visible plaster and collision share the same rectangles.
## Coordinates are local so this shell can be reused in other indoor scenes.
@export var floor_bounds := Rect2(144, 152, 672, 352):
	set(value):
		floor_bounds = value
		queue_redraw()
@export var thickness := 24.0
@export var front_cap: Texture2D
@export var left_cap: Texture2D
@export var right_cap: Texture2D
@export var left_corner: Texture2D
@export var right_corner: Texture2D
@export var plaster := Color("b9a995")
@export var shadow := Color("655951")
@export var trim := Color("e4d1b5")

func rectangles() -> Array[Rect2]:
	var r := floor_bounds
	return [
		Rect2(r.position - Vector2(thickness / 2, 0), Vector2(thickness, r.size.y)),
		Rect2(Vector2(r.end.x - thickness / 2, r.position.y), Vector2(thickness, r.size.y)),
		Rect2(Vector2(r.position.x, r.end.y - thickness / 2), Vector2(r.size.x, thickness)),
		Rect2(r.position - Vector2(0, thickness / 2), Vector2(r.size.x, thickness)),
	]

func _ready() -> void:
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
	if not front_cap or not left_cap or not right_cap:
		for rect in rectangles():
			draw_rect(rect, shadow)
			draw_rect(rect.grow(-3), plaster)
		return
	var r := floor_bounds
	# Repeat individual atlas pieces, rather than stretching one room backdrop.
	for x in range(int(ceil(r.size.x / 96.0))):
		var width := minf(96, r.end.x - (r.position.x + x * 96))
		draw_texture_rect(front_cap, Rect2(r.position.x + x * 96, r.end.y - 20, width, 32), false)
		draw_texture_rect(front_cap, Rect2(r.position.x + x * 96, r.position.y - 8, width, 16), false)
	for y in range(int(ceil(r.size.y / 96.0))):
		var height := minf(96, r.end.y - (r.position.y + y * 96))
		draw_texture_rect(left_cap, Rect2(r.position.x - 15, r.position.y + y * 96, 30, height), false)
		draw_texture_rect(right_cap, Rect2(r.end.x - 15, r.position.y + y * 96, 30, height), false)
	if left_corner:
		draw_texture_rect(left_corner, Rect2(r.position.x - 16, r.end.y - 44, 60, 56), false)
	if right_corner:
		draw_texture_rect(right_corner, Rect2(r.end.x - 44, r.end.y - 44, 60, 56), false)
