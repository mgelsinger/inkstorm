extends Node2D

@export var lifetime: float = 0.5
@export var initial_alpha: float = 0.8

var age: float = 0.0

@onready var visual: Node2D = $Visual

func _ready() -> void:
	# Set initial alpha
	if visual:
		visual.modulate.a = initial_alpha

func _process(delta: float) -> void:
	age += delta

	# Fade out over lifetime
	if visual:
		var fade_progress = age / lifetime
		visual.modulate.a = initial_alpha * (1.0 - fade_progress)

	# Auto-destroy when lifetime expires
	if age >= lifetime:
		queue_free()

func set_lifetime(new_lifetime: float) -> void:
	lifetime = new_lifetime
