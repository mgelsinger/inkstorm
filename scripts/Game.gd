extends Node2D

signal return_to_menu

const UPGRADE_CHOICE = preload("res://scenes/UpgradeChoice.tscn")

@onready var hud: CanvasLayer = $HUD

var upgrade_choice_instance = null

func _ready() -> void:
	# Start the game run
	GameState.start_run()

	# Get player reference (should be set by Player.gd when it's ready)
	var player = $Player
	if player:
		GameState.set_player(player)
		# Connect to level up signal
		player.level_up.connect(_on_player_level_up)

func _process(delta: float) -> void:
	# Update run time in GameState
	GameState.update_run_time(delta)

func _on_player_level_up(new_level: int) -> void:
	print("Player leveled up to level ", new_level)

	# Pause the game
	get_tree().paused = true

	# Get 3 random upgrades from the database
	var random_upgrades = UpgradeDatabase.get_random_upgrades(3)

	# Instance the upgrade choice UI
	upgrade_choice_instance = UPGRADE_CHOICE.instantiate()
	add_child(upgrade_choice_instance)

	# Set the upgrades to display
	upgrade_choice_instance.set_upgrades(random_upgrades)

	# Connect to the upgrade chosen signal
	upgrade_choice_instance.upgrade_chosen.connect(_on_upgrade_chosen)

func _on_upgrade_chosen(upgrade_id: String) -> void:
	print("Upgrade chosen: ", upgrade_id)

	# Apply the upgrade to the player
	var player = GameState.get_player()
	if player:
		UpgradeDatabase.apply_upgrade(upgrade_id, player)

	# Remove the upgrade choice UI
	if upgrade_choice_instance:
		upgrade_choice_instance.queue_free()
		upgrade_choice_instance = null

	# Unpause the game
	get_tree().paused = false

func _exit_tree() -> void:
	# Clean up when leaving the game scene
	GameState.end_run()
	GameState.reset()
