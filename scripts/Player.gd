extends CharacterBody2D

const SPEED: float = 300.0
const DASH_SPEED: float = 600.0
const DASH_DURATION: float = 0.2

var is_dashing: bool = false
var dash_timer: float = 0.0

func _ready() -> void:
	# Register with GameState
	GameState.set_player(self)

func _physics_process(delta: float) -> void:
	var input_vector := Vector2.ZERO

	# Get input
	input_vector.x = Input.get_axis("move_left", "move_right")
	input_vector.y = Input.get_axis("move_up", "move_down")

	# Normalize diagonal movement
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()

	# Handle dash
	if Input.is_action_just_pressed("dash") and not is_dashing:
		is_dashing = true
		dash_timer = DASH_DURATION

	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
			dash_timer = 0.0

	# Apply movement
	var current_speed = DASH_SPEED if is_dashing else SPEED
	velocity = input_vector * current_speed

	move_and_slide()
