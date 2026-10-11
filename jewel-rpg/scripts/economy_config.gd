extends Resource

# Dummy business values; tune here, not in UI code.
@export var starting_cash: int = 100
@export var unit_cost: int = 10
@export var product_name: String = "Imitation ring"
@export var materials: String = "Plated brass • simulated stone"

@export var sale_prices: PackedInt32Array = PackedInt32Array([15, 20, 30])
@export var default_sale_price: int = 20
@export var truthful_customer_max: int = 20
@export var misleading_customer_max: int = 30
@export var truthful_claim: String = "Gold-tone plated brass; simulated stone"
@export var misleading_claim: String = "Solid gold; genuine gemstone"
@export var truthful_reputation_gain: int = 1

@export_range(0.0, 1.0) var refund_chance_min: float = 0.10
@export_range(0.0, 1.0) var refund_chance_max: float = 0.25
@export var complaint_reputation_loss: int = 5
