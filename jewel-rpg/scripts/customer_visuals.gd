extends Node2D

const ACTOR = preload("res://scenes/market_customer.tscn")
const SHEET = preload("res://assets/customers/customer_sheet.png")
const REGIONS = [Rect2(225, 45, 341, 599), Rect2(662, 47, 282, 598), Rect2(257, 663, 285, 612), Rect2(649, 670, 300, 605)]
var actors: Array[Node2D] = []
var portraits: Array[Texture2D] = []
var bodies: Array[Texture2D] = []
@onready var session = get_node_or_null("../../MarketSession")

func _ready() -> void:
	for region in REGIONS:
		var texture := AtlasTexture.new()
		texture.atlas = SHEET
		texture.region = region
		texture.margin = Rect2(Vector2((360 - region.size.x) / 2, 612 - region.size.y), Vector2(360, 612) - region.size)
		bodies.append(texture)
		var portrait := AtlasTexture.new()
		portrait.atlas = SHEET
		portrait.region = Rect2(region.position, Vector2(region.size.x, 280))
		portraits.append(portrait)
	if session != null:
		session.customer_changed.connect(_update_customers)

func portrait_for(index: int) -> Texture2D:
	return portraits[index % portraits.size()]

func body_for(index: int) -> Texture2D:
	return bodies[index % bodies.size()]

func _update_customers() -> void:
	for actor in actors:
		actor.depart()
	actors.clear()
	if not session.active:
		return
	for index in mini(3, session.quota - session.processed):
		var actor = ACTOR.instantiate()
		actor.get_node("Visual").texture = body_for(session.processed + index)
		actor.get_node("Visual").scale = Vector2.ONE * (96.0 / 612.0)
		actor.get_node("Name").text = session.NAMES[(session.processed + index) % 4]
		add_child(actor)
		actor.arrive(Vector2(25 + index * 45, 150 + index * 32))
		actors.append(actor)
