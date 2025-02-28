extends Node
#owdkapidiaedwuhjhbsv

var player: Node = null
var progress_bar : ProgressBar = null
#number all of the abilities
enum Ability_nums
{
	none, double_or_nothing
}

var current_ability = Ability_nums.none

#Dictionary for cooldowns, this is basically a hasmap, ITS JUST LIKE DATA STRUCTURES FR
var ability_cooldowns = {
	Ability_nums.double_or_nothing: 0.0
}

var ability_cooldown_durations = {
	Ability_nums.double_or_nothing: 10.0
}

# Called when the node enters the scene tree for the first time.
func _ready():
	progress_bar = get_node("CanvasLayer/ProgressBar")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for Ability_nums in ability_cooldowns.keys():
		if ability_cooldowns[Ability_nums] > 0:
			ability_cooldowns[Ability_nums] = max(0, ability_cooldowns[Ability_nums] - delta)
			

func use_ability(ability):
	if current_ability == Ability_nums.none and ability_cooldowns[ability] <= 0:
		current_ability = ability
		if progress_bar:
			print("WOW")
			progress_bar.bar_fill_up(int(ability_cooldown_durations[ability]))
		match ability:
			Ability_nums.double_or_nothing:
				double_or_nothing()
		ability_cooldowns[ability] = ability_cooldown_durations[ability]
	else:
		print("on cooldown")

func end_ability():
	current_ability = Ability_nums.none


#Ability definitions start here(what the abilities gonne do fr fr no capppppppp)
func double_or_nothing():
	if player:
		#how much damage player is doing
		player.change_damage_amt_player(player.return_damage_amt_player() * 2)
		#how much damage player is taking
		player.change_damage_taken_mult_player(player.return_damage_taken_mult_player() * 4)
		print("dmg " + str(player.return_damage_amt_player()))
		print("dmg taken " + str(player.return_damage_taken_mult_player()))
		
		await get_tree().create_timer(5.0).timeout
		
		#how much damage player is doing
		player.change_damage_amt_player(player.return_damage_amt_player() / 2)
		#how much damage player is taking
		player.change_damage_taken_mult_player(player.return_damage_taken_mult_player() / 4)
		print("dmg " + str(player.return_damage_amt_player()))
		print("dmg taken " + str(player.return_damage_taken_mult_player()))
	end_ability()
