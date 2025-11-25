extends Area2D

@export var xp_value: int = 1
@export var magnet_range: float = 100.0
@export var magnet_speed: float = 200.0

var player: Node = null

func _ready() -> void:
	# Set collision layers: XP on layer 8, detects layer 1 (Player)
	collision_layer = 8
	collision_mask = 1

	# Connect to body entered signal
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	# Get player reference
	if not player:
		player = GameState.get_player()

	if player:
		var distance = global_position.distance_to(player.global_position)
		# Magnet effect when player is nearby
		if distance < magnet_range:
			var direction = (player.global_position - global_position).normalized()
			global_position += direction * magnet_speed * delta

func _on_body_entered(body: Node2D) -> void:
	# Check if it's the player
	if body == player or body.has_method("collect_xp"):
		if body.has_method("collect_xp"):
			body.collect_xp(xp_value)
		queue_free()
