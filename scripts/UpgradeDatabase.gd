extends Node

# Upgrade definitions
const UPGRADES = {
	"thicker_stroke": {
		"id": "thicker_stroke",
		"name": "Thicker Stroke",
		"description": "Ink trails are wider and easier to hit enemies with",
		"apply": func(player: Node):
			# Increase ink trail size by scaling InkTrailSegment spawns
			# Note: This is a simplified version - actual implementation would need to modify trail scenes
			player.ink_trail_damage += 1
			print("Applied: Thicker Stroke")
	},
	"longer_ink": {
		"id": "longer_ink",
		"name": "Longer Lasting Ink",
		"description": "Ink trails persist longer on the battlefield",
		"apply": func(player: Node):
			player.trail_lifetime += 0.3
			print("Applied: Longer Lasting Ink")
	},
	"sharper_dash": {
		"id": "sharper_dash",
		"name": "Sharper Dash",
		"description": "Dash attacks deal more damage to enemies",
		"apply": func(player: Node):
			player.dash_contact_damage += 2
			print("Applied: Sharper Dash")
	},
	"ink_shockwave": {
		"id": "ink_shockwave",
		"name": "Ink Shockwave",
		"description": "Dash ending creates a larger, more damaging pulse",
		"apply": func(player: Node):
			player.dash_pulse_damage += 2
			player.dash_pulse_radius += 10.0
			print("Applied: Ink Shockwave")
	},
	"fleet_footed": {
		"id": "fleet_footed",
		"name": "Fleet Footed",
		"description": "Increase movement speed",
		"apply": func(player: Node):
			player.move_speed += 50.0
			print("Applied: Fleet Footed")
	},
	"quick_dash": {
		"id": "quick_dash",
		"name": "Quick Dash",
		"description": "Reduce dash cooldown",
		"apply": func(player: Node):
			player.dash_cooldown = max(0.2, player.dash_cooldown - 0.1)
			print("Applied: Quick Dash")
	},
	"more_ink": {
		"id": "more_ink",
		"name": "More Ink",
		"description": "Spawn ink trails more frequently during dash",
		"apply": func(player: Node):
			player.trail_spawn_interval = max(0.02, player.trail_spawn_interval - 0.01)
			print("Applied: More Ink")
	},
	"health_boost": {
		"id": "health_boost",
		"name": "Health Boost",
		"description": "Increase maximum health and heal to full",
		"apply": func(player: Node):
			player.max_hp += 3
			player.hp = player.max_hp
			print("Applied: Health Boost")
	}
}

# Get a list of random upgrades
func get_random_upgrades(count: int) -> Array:
	var upgrade_keys = UPGRADES.keys()
	upgrade_keys.shuffle()

	var selected = []
	for i in range(min(count, upgrade_keys.size())):
		selected.append(UPGRADES[upgrade_keys[i]])

	return selected

# Apply an upgrade to the player
func apply_upgrade(upgrade_id: String, player: Node) -> void:
	if upgrade_id in UPGRADES:
		var upgrade = UPGRADES[upgrade_id]
		upgrade.apply.call(player)
