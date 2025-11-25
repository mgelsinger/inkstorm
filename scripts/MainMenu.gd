extends Node2D

signal play_pressed
signal quit_pressed

func _ready() -> void:
	var play_button = $UI/VBoxContainer/PlayButton
	var quit_button = $UI/VBoxContainer/QuitButton

	play_button.pressed.connect(_on_play_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

func _on_play_button_pressed() -> void:
	emit_signal("play_pressed")

func _on_quit_button_pressed() -> void:
	emit_signal("quit_pressed")
