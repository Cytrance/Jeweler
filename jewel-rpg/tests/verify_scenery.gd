extends SceneTree

var checks := 0
var failures := 0

func _initialize() -> void:
	_run.call_deferred()

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + label)

func frames(count: int) -> void:
	for index in count:
		await physics_frame
		await process_frame

# Exercise the actual reusable scene, away from other level props.
func check_prop(path: String, label: String, height: float, footprint: Vector2) -> void:
	var fixture := Node2D.new()
	root.add_child(fixture)
	var prop = load(path).instantiate()
	fixture.add_child(prop)
	var template = load("res://scenes/main.tscn").instantiate()
	var player = template.get_node("PlayerPlaceholder").duplicate()
	template.free()
	fixture.add_child(player)
	await frames(3)
	var visual := prop.get_node("Visual") as Sprite2D
	var bounds := visual.transform * visual.get_rect()
	check(prop is StaticBody2D and prop.get_node("CollisionShape2D").shape.size == footprint, label + " scene includes intended solid footprint")
	check(absf(bounds.size.y - height) < 0.01 and absf(bounds.end.y - footprint.y / 2.0) < 0.01, label + " artwork is sized and grounded at footprint bottom")
	check(visual.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST and is_equal_approx(visual.scale.x, visual.scale.y), label + " preserves aspect ratio and nearest filtering")
	check(Rect2(Vector2.ZERO, visual.texture.get_size()).encloses(visual.region_rect), label + " crop lies inside source image")
	var half_size: Vector2 = (footprint + player.get_node("CollisionShape2D").shape.size) / 2.0
	var approaches := {"move_right": Vector2.LEFT, "move_left": Vector2.RIGHT, "move_down": Vector2.UP, "move_up": Vector2.DOWN}
	for action in approaches:
		var side: Vector2 = approaches[action]
		player.position = side * 100.0
		await frames(2)
		Input.action_press(action)
		await frames(45)
		Input.action_release(action)
		check(player.position.distance_to(side * half_size) < 0.2, label + " blocks " + action + " through engine physics")
	var contact: Vector2 = player.position
	Input.action_press("move_down")
	await frames(15)
	Input.action_release("move_down")
	check(player.position.y > contact.y + 40.0, label + " allows walking away from base")
	var copy = load(path).instantiate()
	copy.position = Vector2(300, 0)
	fixture.add_child(copy)
	await frames(2)
	player.position = Vector2(200, 0)
	await frames(2)
	Input.action_press("move_right")
	await frames(45)
	Input.action_release("move_right")
	check(absf(player.position.x - (copy.position.x - half_size.x)) < 0.2, label + " new instance inherits collision")
	fixture.queue_free()
	await frames(2)

func _run() -> void:
	await check_prop("res://scenes/props/flowering_tree.tscn", "flowering tree", 240.0, Vector2(80, 40))
	await check_prop("res://scenes/props/streetlamp.tscn", "streetlamp", 150.0, Vector2(24, 24))
	var scene = load("res://scenes/main.tscn").instantiate()
	var player = scene.get_node("PlayerPlaceholder")
	var spawn: Vector2 = player.position
	root.add_child(scene)
	await frames(3)
	check(scene.y_sort_enabled, "main sorts tall scenery against player by base position")
	for node_name in ["TreeLeft", "TreeRight", "LampLeft", "LampRight"]:
		var prop = scene.get_node(node_name)
		var visual := prop.get_node("Visual") as Sprite2D
		var bounds := visual.global_transform * visual.get_rect()
		check(Rect2(0, 0, 960, 540).encloses(bounds), node_name + " artwork fits initial viewport")
	await frames(5)
	check(player.position.is_equal_approx(spawn), "spawn stays stable without collision recovery")
	Input.action_press("move_right")
	await frames(12)
	Input.action_release("move_right")
	check(player.position.distance_to(spawn + Vector2(40, 0)) < 0.2, "player can leave spawn without blocking scenery")
	# Sweep the player's real collider along approaches to the two existing gameplay props.
	player.position = Vector2(480, 350)
	await frames(2)
	check(player.move_and_collide(Vector2(170, 0), true) == null, "central route beneath stall remains clear")
	player.position = scene.get_node("Sign").position + Vector2(-90, 0)
	await frames(2)
	check(player.move_and_collide(Vector2(35, 0), true) == null, "board approach from left remains clear")
	scene.queue_free()
	await process_frame
	print("Scenery checks: ", checks, "; failures: ", failures)
	quit(1 if failures else 0)
