extends Node2D

@export var room_width_tiles := 21
@export var floor_height_tiles := 11
@export var wall_sections := 7

func _ready() -> void:
	# Manually painted layers win; empty starter layers receive reusable material cells.
	if $FloorTiles.get_used_cells().is_empty():
		for x in range(room_width_tiles):
			for y in range(floor_height_tiles):
				$FloorTiles.set_cell(Vector2i(x, y), 0, Vector2i(0, (x + y) % 2))
	if $WallTiles.get_used_cells().is_empty():
		# The continuous underlay supplies plaster; only window inserts are painted.
		# Source 0 drywall and source 2 doorway remain available for manual layouts.
		for x in [1, 5]:
			if x < wall_sections:
				$WallTiles.set_cell(Vector2i(x, 0), 1, Vector2i.ZERO)
