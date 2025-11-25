extends Node2D

var current_scene: Node = null

func _ready() -> void:
	load_scene("res://scenes/MainMenu.tscn")

func load_scene(scene_path: String) -> void:
	if current_scene:
		current_scene.queue_free()
		current_scene = null

	var scene = load(scene_path)
	if scene:
		current_scene = scene.instantiate()
		add_child(current_scene)

		# Connect signals if available
		if current_scene.has_signal("play_pressed"):
			current_scene.play_pressed.connect(_on_play_pressed)
		if current_scene.has_signal("quit_pressed"):
			current_scene.quit_pressed.connect(_on_quit_pressed)
		if current_scene.has_signal("return_to_menu"):
			current_scene.return_to_menu.connect(_on_return_to_menu)
	else:
		print("ERROR: Failed to load scene: ", scene_path)

func _on_play_pressed() -> void:
	load_scene("res://scenes/Game.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_return_to_menu() -> void:
	load_scene("res://scenes/MainMenu.tscn")
