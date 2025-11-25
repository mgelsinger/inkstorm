extends Control

signal upgrade_chosen(upgrade_id: String)

var upgrades: Array = []

@onready var button1: Button = $Panel/MarginContainer/VBoxContainer/UpgradeButtons/Button1
@onready var button2: Button = $Panel/MarginContainer/VBoxContainer/UpgradeButtons/Button2
@onready var button3: Button = $Panel/MarginContainer/VBoxContainer/UpgradeButtons/Button3

func _ready() -> void:
	# Make this UI ignore pause
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Connect button signals
	button1.pressed.connect(_on_button1_pressed)
	button2.pressed.connect(_on_button2_pressed)
	button3.pressed.connect(_on_button3_pressed)

func set_upgrades(upgrade_list: Array) -> void:
	upgrades = upgrade_list

	# Update button texts
	if upgrades.size() > 0:
		button1.text = upgrades[0].name + "\n" + upgrades[0].description
	if upgrades.size() > 1:
		button2.text = upgrades[1].name + "\n" + upgrades[1].description
	if upgrades.size() > 2:
		button3.text = upgrades[2].name + "\n" + upgrades[2].description

func _on_button1_pressed() -> void:
	if upgrades.size() > 0:
		emit_signal("upgrade_chosen", upgrades[0].id)

func _on_button2_pressed() -> void:
	if upgrades.size() > 1:
		emit_signal("upgrade_chosen", upgrades[1].id)

func _on_button3_pressed() -> void:
	if upgrades.size() > 2:
		emit_signal("upgrade_chosen", upgrades[2].id)
