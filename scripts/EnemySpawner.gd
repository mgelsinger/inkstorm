extends Node

const ENEMY_SCENE = preload("res://scenes/EnemyBasic.tscn")

@export var spawn_interval: float = 2.0
@export var spawn_distance: float = 600.0

var spawn_timer: float = 0.0

func _ready() -> void:
	spawn_timer = spawn_interval

func _process(delta: float) -> void:
	spawn_timer -= delta
	if spawn_timer <= 0:
		spawn_enemy()
		spawn_timer = spawn_interval

func spawn_enemy() -> void:
	var player = GameState.get_player()
	if not player:
		return

	var enemy = ENEMY_SCENE.instantiate()

	# Spawn at a random position around the player
	var angle = randf() * TAU
	var spawn_pos = player.global_position + Vector2(cos(angle), sin(angle)) * spawn_distance

	enemy.global_position = spawn_pos
	get_parent().add_child(enemy)
