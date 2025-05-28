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
	for passive in active_passives:
		if player.dash_cooldown == true:
			player.speed = base_speed
		player.coin_mult = 1
		match passive:
			"health_regen":
				_apply_regen(delta)
			"extra_speed":
				player.speed += 150  # just an example
			"double_loot":
				player.coin_mult = player.coin_mult * 2

func _apply_regen(delta):
	if player.health_amount < player.max_health - 10:
		player.health_amount = player.health_amount + 1
		player.HealthBar.health = player.health_amount
