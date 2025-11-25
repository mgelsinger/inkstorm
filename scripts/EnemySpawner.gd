extends Node

const ENEMY_SCENE = preload("res://scenes/EnemyBasic.tscn")

@export var base_spawn_interval: float = 2.0
@export var min_spawn_interval: float = 0.5
@export var spawn_distance: float = 600.0
@export var escalation_time: float = 120.0  # Time to reach min interval (2 minutes)

var spawn_timer: float = 0.0
var enemy_container: Node = null

func _ready() -> void:
	spawn_timer = base_spawn_interval
	# Find or create enemy container
	enemy_container = get_parent().get_node_or_null("Enemies")
	if not enemy_container:
		enemy_container = get_parent()

func _process(delta: float) -> void:
	# Calculate current spawn interval based on run time
	var current_interval = _calculate_spawn_interval()

	spawn_timer -= delta
	if spawn_timer <= 0:
		spawn_enemy()
		spawn_timer = current_interval

func _calculate_spawn_interval() -> float:
	var run_time = GameState.run_time
	# Linear interpolation from base to min over escalation_time
	var progress = clamp(run_time / escalation_time, 0.0, 1.0)
	return lerp(base_spawn_interval, min_spawn_interval, progress)

func spawn_enemy() -> void:
	var player = GameState.get_player()
	if not player:
		return

	var enemy = ENEMY_SCENE.instantiate()

	# Spawn at a random position around the player
	var angle = randf() * TAU
	var spawn_pos = player.global_position + Vector2(cos(angle), sin(angle)) * spawn_distance

	enemy.global_position = spawn_pos

	if enemy_container:
		enemy_container.add_child(enemy)
	else:
		get_parent().add_child(enemy)

func get_enemy_count() -> int:
	if enemy_container:
		return enemy_container.get_child_count()
	return 0
