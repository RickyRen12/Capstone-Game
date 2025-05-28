class_name PassiveAbilityManager

var player: Node = null
var base_speed = 250
var active_passives: Array[String] = []

func add_passive(passive: String) -> void:
	if passive not in active_passives:
		active_passives.append(passive)

func remove_passive(passive: String) -> void:
	active_passives.erase(passive)

func process_passives(delta: float) -> void:
	player.speed = base_speed
	for passive in active_passives:
		match passive:
			"health_regen":
				_apply_regen(delta)
			"extra_speed":
				player.speed += 150  # just an example
			"double_loot":
				pass

func _apply_regen(delta):
	player.health_amount = clamp(player.health_amount + delta * 1.5, 0, player.HealthBar.max_health)
	player.HealthBar.health = player.health_amount
