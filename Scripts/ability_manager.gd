extends Node

var current_ability = Ability.none
var player: Node = null

#number all of the abilities
enum Ability
{
	none, double_or_nothing
}

#Dictionary for cooldowns, this is basically a hasmap, ITS JUST LIKE DATA STRUCTURES FR
var ability_cooldowns = {
	Ability.double_or_nothing: 0.0
}

var ability_cooldown_duration = {
	Ability.double_or_nothing: 10
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for Ability in ability_cooldowns.keys():
		if ability_cooldowns[Ability] > 0:
			ability_cooldowns[Ability] -= delta
			

func use_ability(ability):
	if current_ability == Ability.none and ability_cooldowns[ability] <= 0:
		current_ability = ability
		match ability:
			Ability.double_or_nothing:
				double_or_nothing()

func end_ability():
	current_ability = Ability.none


#Ability definitions start here(what the abilities gonne do fr fr no capppppppp)
func double_or_nothing():
	if player:
		player.chnage_damage_amount_player(player.get_damager_amount_player() * 2)
		await get_tree().create_timer(5.0).timeout
		player.chnage_damage_amount(player.get_damager_amount() / 2)
	end_ability()
