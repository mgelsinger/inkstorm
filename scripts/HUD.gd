extends CanvasLayer

@onready var time_label: Label = $MarginContainer/VBoxContainer/TimeLabel
@onready var hp_label: Label = $MarginContainer/VBoxContainer/HPLabel
@onready var pause_overlay: ColorRect = $PauseOverlay
@onready var resume_button: Button = $PauseOverlay/CenterContainer/VBoxContainer/ResumeButton

func _ready() -> void:
	pause_overlay.visible = false
	resume_button.pressed.connect(_on_resume_button_pressed)

func _process(delta: float) -> void:
	# Update time display
	var time = GameState.run_time
	var minutes = int(time) / 60
	var seconds = int(time) % 60
	var milliseconds = int((time - int(time)) * 100)
	time_label.text = "Time: %02d:%02d.%02d" % [minutes, seconds, milliseconds]

	# Update HP display
	var player = GameState.get_player()
	if player and player.has_method("get") and "hp" in player and "max_hp" in player:
		hp_label.text = "HP: %d/%d" % [player.hp, player.max_hp]
	else:
		hp_label.text = "HP: --"

	# Handle pause input
	if Input.is_action_just_pressed("pause"):
		toggle_pause()

func toggle_pause() -> void:
	var is_paused = get_tree().paused
	get_tree().paused = not is_paused
	pause_overlay.visible = not is_paused

func _on_resume_button_pressed() -> void:
	toggle_pause()
