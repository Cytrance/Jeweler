@tool
extends Node2D

const WallProfile = preload("res://scripts/interior_wall_profile.gd")
@export var floor_bounds := Rect2(144, 152, 672, 352):
	set(value):
		floor_bounds = value
		queue_redraw()
@export var thickness := 24.0:
	set(value):
		thickness = value
		queue_redraw()
@export var wood: Texture2D:
	set(value):
		wood = value
		queue_redraw()

func _draw() -> void:
	var r := floor_bounds
	# Rear trim belongs behind furniture, unlike the foreground cutaway edges.
	WallProfile.fill(self, wood, Rect2(r.position.x - thickness / 2, r.position.y - 96, r.size.x + thickness, 16), Color("755039"))
	WallProfile.fill(self, wood, Rect2(r.position.x - thickness / 2, r.position.y - 8, r.size.x + thickness, 20), Color("755039"))
	WallProfile.fill(self, wood, Rect2(r.position.x - thickness / 2, r.position.y - 80, thickness / 2, 72), Color("755039"))
	WallProfile.fill(self, wood, Rect2(r.end.x, r.position.y - 80, thickness / 2, 72), Color("755039"))
