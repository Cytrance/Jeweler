@tool
extends Node2D

## Opaque straight wall profiles. Texture rectangles meet without alpha end caps.
@export var profile_size := Vector2(96, 32):
	set(value):
		profile_size = value
		queue_redraw()
@export_enum("Front", "Side", "Corner left", "Corner right", "Rear", "Plaster") var kind := 0:
	set(value):
		kind = value
		queue_redraw()
@export var wood: Texture2D:
	set(value):
		wood = value
		queue_redraw()
@export var plaster: Texture2D:
	set(value):
		plaster = value
		queue_redraw()

static func fill(target: CanvasItem, texture: Texture2D, rect: Rect2, tint: Color) -> void:
	target.draw_rect(rect, tint)
	if not texture:
		return
	# A 64px world patch samples 512px of source in both axes: no stretching.
	# Clip the last patch rather than squeezing it into a shorter wall section.
	const PATCH := 64.0
	const SCALE := 0.125
	# Translation-only modules share the same material phase across instances.
	# Rotated/scaled modules retain their local profile but not world UV alignment.
	var world_offset := (target as Node2D).global_position
	var world_start := rect.position + world_offset
	var first := Vector2(floorf(world_start.x / PATCH), floorf(world_start.y / PATCH)) * PATCH - world_offset
	for row in range(int(ceil((rect.end.y - first.y) / PATCH))):
		for column in range(int(ceil((rect.end.x - first.x) / PATCH))):
			var origin := first + Vector2(column, row) * PATCH
			var part := rect.intersection(Rect2(origin, Vector2(PATCH, PATCH)))
			var source := Rect2((part.position - origin) / SCALE, part.size / SCALE)
			target.draw_texture_rect_region(texture, part, source)

static func front(target: CanvasItem, rect: Rect2, wood_texture: Texture2D, plaster_texture: Texture2D) -> void:
	# Identical top/face/base heights let adjacent segments join on straight edges.
	fill(target, wood_texture, rect, Color("755039"))
	fill(target, plaster_texture, Rect2(rect.position + Vector2(0, 9), Vector2(rect.size.x, maxf(1, rect.size.y - 15))), Color("cdbc9e"))
	target.draw_line(rect.position + Vector2(0, 9), Vector2(rect.end.x, rect.position.y + 9), Color("63482f"), 2)
	target.draw_line(Vector2(rect.position.x, rect.end.y - 6), rect.end - Vector2(0, 6), Color("63482f"), 2)

static func side(target: CanvasItem, rect: Rect2, wood_texture: Texture2D, plaster_texture: Texture2D) -> void:
	fill(target, wood_texture, rect, Color("755039"))
	fill(target, plaster_texture, Rect2(rect.position + Vector2(7, 0), Vector2(maxf(1, rect.size.x - 14), rect.size.y)), Color("cdbc9e"))
	target.draw_line(rect.position + Vector2(7, 0), Vector2(rect.position.x + 7, rect.end.y), Color("63482f"), 2)
	target.draw_line(rect.position + Vector2(rect.size.x - 7, 0), rect.end - Vector2(7, 0), Color("63482f"), 2)

func _draw() -> void:
	var rect := Rect2(Vector2(-profile_size.x / 2, -profile_size.y), profile_size)
	if kind == 0:
		front(self, rect, wood, plaster)
	elif kind == 1:
		side(self, rect, wood, plaster)
	elif kind == 5:
		fill(self, plaster, rect, Color("cdbc9e"))
	elif kind == 4:
		fill(self, wood, rect, Color("755039"))
		fill(self, plaster, Rect2(rect.position + Vector2(0, 16), rect.size - Vector2(0, 36)), Color("cdbc9e"))
	else:
		var x := rect.position.x if kind == 2 else rect.end.x - 24
		side(self, Rect2(x, rect.position.y, 24, rect.size.y), wood, plaster)
		front(self, Rect2(rect.position.x, rect.end.y - 32, rect.size.x, 32), wood, plaster)
