extends Node2D

@export var room_width_tiles := 21
@export var floor_height_tiles := 11
@export var wall_height_tiles := 3

func _ready() -> void:
	# Manually painted layers win; empty starter layers receive reusable material cells.
	if $FloorTiles.get_used_cells().is_empty():
		for x in range(room_width_tiles):
			for y in range(floor_height_tiles):
				$FloorTiles.set_cell(Vector2i(x, y), 0, Vector2i(0, (x + y) % 2))
	if $WallTiles.get_used_cells().is_empty():
		for x in range(room_width_tiles):
			for y in range(wall_height_tiles):
				$WallTiles.set_cell(Vector2i(x, y), 0, Vector2i(1, (x + y) % 2))
