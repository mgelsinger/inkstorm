extends Area2D

@export var lifetime: float = 0.5
@export var initial_alpha: float = 0.8
@export var ink_damage: int = 1
@export var damage_interval: float = 0.2

var age: float = 0.0
var enemies_in_trail: Dictionary = {}  # enemy: last_damage_time

@onready var visual: Node2D = $Visual

func _ready() -> void:
	# Set initial alpha
	if visual:
		visual.modulate.a = initial_alpha

	# Connect signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	age += delta

	# Fade out over lifetime
	if visual:
		var fade_progress = age / lifetime
		visual.modulate.a = initial_alpha * (1.0 - fade_progress)

	# Damage enemies in trail
	var current_time = Time.get_ticks_msec() / 1000.0
	for enemy in enemies_in_trail.keys():
		if is_instance_valid(enemy):
			var last_damage_time = enemies_in_trail[enemy]
			if current_time - last_damage_time >= damage_interval:
				if enemy.has_method("take_damage"):
					enemy.take_damage(ink_damage)
					enemies_in_trail[enemy] = current_time
		else:
			enemies_in_trail.erase(enemy)

	# Auto-destroy when lifetime expires
	if age >= lifetime:
		queue_free()

func set_lifetime(new_lifetime: float) -> void:
	lifetime = new_lifetime

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		enemies_in_trail[body] = 0.0  # Will damage immediately on next frame

func _on_body_exited(body: Node2D) -> void:
	if body in enemies_in_trail:
		enemies_in_trail.erase(body)
