extends Node2D

@export var lifetime: float = 1.0
@export var fade_start: float = 0.5

var age: float = 0.0

func _ready() -> void:
	# Randomize rotation
	rotation = randf() * TAU
	# Randomize scale slightly
	scale = Vector2.ONE * randf_range(0.8, 1.2)

func _process(delta: float) -> void:
	age += delta

	# Start fading after fade_start time
	if age >= fade_start:
		var fade_progress = (age - fade_start) / (lifetime - fade_start)
		modulate.a = 1.0 - fade_progress

	# Auto-destroy when lifetime expires
	if age >= lifetime:
		queue_free()
