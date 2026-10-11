extends SceneTree

var checks := 0
var failures := 0

func check(value: bool, label: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(label)

func _initialize() -> void:
	_run.call_deferred()

func frames() -> void:
	await physics_frame
	await process_frame

func walk(player: CharacterBody2D, position: Vector2, direction: String, count := 20) -> Vector2:
	player.position = position
	await frames()
	Input.action_press(direction)
	for i in count:
		await physics_frame
	Input.action_release(direction)
	await frames()
	return player.position

func _run() -> void:
	var scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await frames()
	var player = scene.get_node("PlayerPlaceholder")
	var room = scene.get_node("Apartment")
	var shell = room.get_node("Walls")
	scene.get_node("MarketClock").set_process(false)
	check(shell.rectangles().size() == 4 and shell.get_child_count() == 4, "four visible border rectangles have matching physical bodies")
	for index in 4:
		var rect: Rect2 = shell.rectangles()[index]
		var body = shell.get_child(index)
		check(body.position == rect.get_center() and body.get_node("Collision").shape.size == rect.size, "visible border aligns collider %s" % index)
	check((await walk(player, Vector2(200, 400), "move_left")).x >= 172, "left visible wall blocks player")
	check((await walk(player, Vector2(760, 400), "move_right")).x <= 788, "right visible wall blocks player")
	check((await walk(player, Vector2(610, 440), "move_down")).y <= 492, "lower cutaway wall blocks player")
	check((await walk(player, Vector2(650, 225), "move_up")).y >= 164, "back wall blocks player")
	for target in [Vector2(540, 295), Vector2(255, 380), Vector2(755, 290), Vector2(610, 390)]:
		player.position = target
		await frames()
		check(not player.test_move(player.transform, Vector2(0, 1)), "interaction or spawn remains free %s" % target)
	check((await walk(player, Vector2(670, 290), "move_up")).y >= 240, "sink footprint blocks real player movement")
	check((await walk(player, Vector2(335, 490), "move_up")).y >= 445, "dining table footprint blocks real player movement")
	check((await walk(player, Vector2(185, 350), "move_up")).y >= 300, "lamp base blocks real player movement")
	var rug_crossing := await walk(player, Vector2(550, 405), "move_right", 36)
	check(rug_crossing.x > 655, "rug is walkable across entire visible surface")
	check(room.get_node("FloorMat").z_index < 0, "rug draws underneath player")
	for filename in ["sink", "dining_table", "floor_lamp"]:
		var prop = load("res://scenes/props/%s.tscn" % filename).instantiate()
		check(prop is StaticBody2D and prop.collision_layer == 1 and prop.get_node("Collision").shape is RectangleShape2D, "standalone %s has solid ground footprint without configuration" % filename)
		prop.free()
	# Exercise the clear route from spawn to each interactive station.
	var computer_route := await walk(player, Vector2(610, 390), "move_up", 28)
	check(computer_route.y < 300, "spawn route reaches computer row")
	computer_route = await walk(player, Vector2(610, 295), "move_left", 21)
	check(computer_route.x <= 545, "computer front approach remains clear")
	var door_route := await walk(player, Vector2(610, 390), "move_right", 47)
	check(door_route.x > 750, "spawn route reaches door column")
	door_route = await walk(player, Vector2(755, 390), "move_up", 26)
	check(door_route.y < 310, "door front approach remains clear")
	var bed_route := await walk(player, Vector2(610, 360), "move_left", 105)
	check(bed_route.x < 275, "spawn route reaches bed front without furniture obstruction")
	var walls: TileSet = room.get_node("WallTiles").tile_set
	for source in [0, 1, 2]:
		check(walls.get_source(source).get_tile_data(Vector2i.ZERO, 0).get_custom_data("material") == ["drywall", "window", "doorway"][source], "paintable named wall variant %s" % source)
	for filename in ["wall_drywall", "wall_window", "wall_doorway", "wall_cap_front", "wall_cap_left", "wall_cap_right", "wall_cap_corner_left", "wall_cap_corner_right"]:
		var piece = load("res://scenes/props/%s.tscn" % filename).instantiate()
		check(piece is StaticBody2D and piece.get_node("Collision").shape != null and piece.get_node("Visual").texture != null, "standalone textured wall piece with default collision %s" % filename)
		piece.free()
	var tile_room = load("res://scenes/apartment.tscn").instantiate()
	tile_room.get_node("FloorTiles").set_cell(Vector2i(5, 5), 0, Vector2i(0, 0))
	tile_room.get_node("WallTiles").set_cell(Vector2i(2, 0), 1, Vector2i.ZERO)
	root.add_child(tile_room)
	check(tile_room.get_node("FloorTiles").get_used_cells().size() == 1, "manual floor painting is preserved")
	check(tile_room.get_node("WallTiles").get_used_cells().size() == 1, "manual wall painting is preserved")
	tile_room.queue_free()
	scene.get_node("AreaTravel").set_area("plaza")
	for body in shell.get_children():
		check(body.collision_layer == 0, "inactive room shell collision disabled")
	scene.get_node("AreaTravel").set_area("apartment")
	for body in shell.get_children():
		check(body.collision_layer == 1, "returning restores room shell collision")
	print("Interior kit: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
