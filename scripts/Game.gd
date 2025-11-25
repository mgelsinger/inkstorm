extends Node2D

signal return_to_menu

func _ready() -> void:
	# Start the game run
	GameState.start_run()

	# Get player reference (should be set by Player.gd when it's ready)
	var player = $Player
	if player:
		GameState.set_player(player)

func _process(delta: float) -> void:
	# Update run time in GameState
	GameState.update_run_time(delta)

func _exit_tree() -> void:
	# Clean up when leaving the game scene
	GameState.end_run()
	GameState.reset()
