extends CharacterBody2D

signal level_up(new_level: int)

# Health properties
@export var max_hp: int = 10
@export var damage_invulnerability_duration: float = 1.0

# Movement properties
@export var move_speed: float = 400.0
@export var acceleration: float = 1500.0
@export var friction: float = 1200.0

# Dash properties
@export var dash_speed_multiplier: float = 2.5
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 0.5
@export var invulnerable_during_dash: bool = true
@export var dash_contact_damage: int = 2
@export var dash_pulse_damage: int = 3
@export var dash_pulse_radius: float = 50.0

# Ink trail properties
@export var trail_spawn_interval: float = 0.05
@export var trail_lifetime: float = 0.5
@export var ink_trail_damage: int = 2

# Progression properties
@export var base_xp_to_level: int = 5
@export var xp_growth_per_level: int = 2

# Preload ink trail scene
const INK_TRAIL_SEGMENT = preload("res://scenes/InkTrailSegment.tscn")

# Health state variables
var hp: int

# Progression state variables
var level: int = 1
var xp: int = 0
var xp_to_next_level: int
var damage_invulnerability_timer: float = 0.0

# State variables
var is_dashing: bool = false
var is_invulnerable: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO
var trail_spawn_timer: float = 0.0
var dash_hit_enemies: Dictionary = {}  # Track enemies hit this dash to avoid multi-hit

# Visual reference
@onready var sprite: Sprite2D = $Sprite2D
@onready var dash_hit_area: Area2D = $DashHitArea

func _ready() -> void:
	hp = max_hp
	xp_to_next_level = base_xp_to_level
	# Set collision layers: Player is on layer 1, detects layer 2 (Enemies)
	collision_layer = 1
	collision_mask = 2
	# Register with GameState
	GameState.set_player(self)

func _physics_process(delta: float) -> void:
	# Update timers
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	if damage_invulnerability_timer > 0:
		damage_invulnerability_timer -= delta
		# Flash sprite during damage invulnerability
		sprite.modulate.a = 0.5 if int(damage_invulnerability_timer * 10) % 2 == 0 else 1.0
	elif not is_dashing:
		sprite.modulate.a = 1.0

	# Handle dash state
	if is_dashing:
		_process_dash(delta)
	else:
		_process_normal_movement(delta)

	# Apply movement
	move_and_slide()

func _process_normal_movement(delta: float) -> void:
	var input_vector := Vector2.ZERO

	# Get input
	input_vector.x = Input.get_axis("move_left", "move_right")
	input_vector.y = Input.get_axis("move_up", "move_down")

	# Normalize diagonal movement
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()

	# Handle dash input
	if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0:
		if input_vector.length() > 0:
			_start_dash(input_vector)
			return

	# Apply acceleration or friction
	if input_vector.length() > 0:
		velocity = velocity.move_toward(input_vector * move_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

func _start_dash(direction: Vector2) -> void:
	is_dashing = true
	is_invulnerable = invulnerable_during_dash
	dash_timer = dash_duration
	dash_direction = direction.normalized()
	velocity = dash_direction * move_speed * dash_speed_multiplier
	trail_spawn_timer = 0.0
	dash_hit_enemies.clear()

	# Enable dash hit area
	if dash_hit_area:
		dash_hit_area.monitoring = true

	# Visual feedback - make slightly transparent during dash
	if sprite:
		sprite.modulate.a = 0.7

func _process_dash(delta: float) -> void:
	dash_timer -= delta

	# Damage enemies in dash hitbox
	if dash_hit_area:
		for body in dash_hit_area.get_overlapping_bodies():
			if body.has_method("take_damage") and body not in dash_hit_enemies:
				body.take_damage(dash_contact_damage)
				dash_hit_enemies[body] = true

	# Spawn ink trail segments
	trail_spawn_timer -= delta
	if trail_spawn_timer <= 0:
		_spawn_ink_trail()
		trail_spawn_timer = trail_spawn_interval

	# Maintain dash velocity
	velocity = dash_direction * move_speed * dash_speed_multiplier

	# Check if dash is complete
	if dash_timer <= 0:
		_end_dash()

func _end_dash() -> void:
	is_dashing = false
	is_invulnerable = false
	dash_cooldown_timer = dash_cooldown

	# Disable dash hit area
	if dash_hit_area:
		dash_hit_area.monitoring = false

	# Create dash end pulse
	_create_dash_pulse()

	# Return velocity to normal range
	if velocity.length() > move_speed:
		velocity = velocity.normalized() * move_speed

	# Restore visual
	if sprite:
		sprite.modulate.a = 1.0

func _spawn_ink_trail() -> void:
	var trail_segment = INK_TRAIL_SEGMENT.instantiate()

	# Add to Game scene (parent's parent should be Game)
	var game_scene = get_parent()
	if game_scene:
		game_scene.add_child(trail_segment)
		trail_segment.global_position = global_position
		trail_segment.rotation = dash_direction.angle()

		# Set lifetime
		if trail_segment.has_method("set_lifetime"):
			trail_segment.set_lifetime(trail_lifetime)
		# Pass damage value to trail
		if trail_segment.has_method("set_damage"):
			trail_segment.set_damage(ink_trail_damage)

func _create_dash_pulse() -> void:
	# Use the dash hit area for a brief pulse check
	if not dash_hit_area:
		return

	# Temporarily enable with larger radius for pulse
	var original_monitoring = dash_hit_area.monitoring
	dash_hit_area.monitoring = true

	# Damage all overlapping enemies
	for body in dash_hit_area.get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(dash_pulse_damage)

	# Restore original state
	dash_hit_area.monitoring = original_monitoring

func is_player_invulnerable() -> bool:
	return is_invulnerable or damage_invulnerability_timer > 0

func take_damage(amount: int) -> void:
	if is_player_invulnerable():
		return

	hp -= amount
	damage_invulnerability_timer = damage_invulnerability_duration

	# Visual feedback
	if sprite:
		sprite.modulate = Color(1.5, 0.5, 0.5, 1.0)

	# Check for death
	if hp <= 0:
		hp = 0
		die()

func die() -> void:
	print("Player died!")
	GameState.end_run()
	# For now, just restart the scene
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()

func collect_xp(amount: int) -> void:
	xp += amount
	check_level_up()

func check_level_up() -> void:
	while xp >= xp_to_next_level:
		xp -= xp_to_next_level
		level += 1
		xp_to_next_level = base_xp_to_level + (level - 1) * xp_growth_per_level
		print("Level up! Now level ", level)
		emit_signal("level_up", level)
