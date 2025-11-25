extends CharacterBody2D

@export var max_hp: int = 2
@export var move_speed: float = 100.0
@export var contact_damage: int = 1
@export var damage_cooldown: float = 1.0

const INK_SPLATTER = preload("res://scenes/InkSplatter.tscn")
const XP_PICKUP = preload("res://scenes/XPPickup.tscn")

var hp: int
var last_damage_time: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	hp = max_hp
	# Set collision layers: Enemy is on layer 2, detects layer 1 (Player)
	collision_layer = 2
	collision_mask = 1

func _physics_process(delta: float) -> void:
	var player = GameState.get_player()
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * move_speed

		var collision = move_and_slide()

		# Check for player collision
		for i in get_slide_collision_count():
			var collision_info = get_slide_collision(i)
			var collider = collision_info.get_collider()
			if collider and collider.has_method("take_damage"):
				# Apply damage to player with cooldown
				var current_time = Time.get_ticks_msec() / 1000.0
				if current_time - last_damage_time >= damage_cooldown:
					if not collider.has_method("is_player_invulnerable") or not collider.is_player_invulnerable():
						collider.take_damage(contact_damage)
						last_damage_time = current_time

func take_damage(amount: int) -> void:
	hp -= amount

	# Visual feedback - flash white and scale pulse
	if sprite:
		var original_scale = scale
		sprite.modulate = Color(2.0, 2.0, 2.0, 1.0)
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(self, "scale", original_scale * 1.2, 0.05)
		tween.tween_callback(func():
			var tween2 = create_tween()
			tween2.tween_property(self, "scale", original_scale, 0.05)
		).set_delay(0.05)

		await get_tree().create_timer(0.1).timeout
		if is_instance_valid(self):
			sprite.modulate = Color(1, 0, 0, 1)

	if hp <= 0:
		die()

func die() -> void:
	# Spawn ink splatter effect
	var splatter = INK_SPLATTER.instantiate()
	get_parent().add_child(splatter)
	splatter.global_position = global_position

	# Spawn XP pickup
	var xp = XP_PICKUP.instantiate()
	get_parent().add_child(xp)
	xp.global_position = global_position

	# Death animation - scale down and fade out
	if sprite:
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(self, "scale", Vector2.ZERO, 0.2)
		tween.tween_property(sprite, "modulate:a", 0.0, 0.2)
		await tween.finished

	queue_free()
