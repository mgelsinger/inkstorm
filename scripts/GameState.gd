extends Node

signal run_started
signal run_ended

var run_time: float = 0.0
var difficulty_stage: int = 0
var player_ref: WeakRef = null

func _ready() -> void:
	print("GameState initialized")

func start_run() -> void:
	run_time = 0.0
	difficulty_stage = 0
	emit_signal("run_started")
	print("Run started")

func end_run() -> void:
	emit_signal("run_ended")
	print("Run ended - Time survived: %.2f seconds" % run_time)

func reset() -> void:
	run_time = 0.0
	difficulty_stage = 0
	player_ref = null
	print("GameState reset")

func set_player(player: Node) -> void:
	if player:
		player_ref = weakref(player)
		print("Player reference set")
	else:
		player_ref = null

func get_player() -> Node:
	if player_ref:
		return player_ref.get_ref()
	return null

func update_run_time(delta: float) -> void:
	run_time += delta
