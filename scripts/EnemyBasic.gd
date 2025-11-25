extends CharacterBody2D

const SPEED: float = 100.0

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	var player = GameState.get_player()
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * SPEED
		move_and_slide()
