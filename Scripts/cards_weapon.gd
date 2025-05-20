extends StaticBody2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite = $AnimatedSprite2D
@onready var player_node = null
const lines: Array[String] = ["Come back with more money next time buddy"]
@onready var speech_sound = preload("res://Assets/Level/sound/cha-ching-alert-new-sale-jam-fx-1-00-04.wav")


var is_empty = false

func _ready():
	interaction_area.interact = Callable(self, "_on_interact")
	
func _on_interact():
	if player_node == null:
		player_node = get_tree().current_scene.get_node("Player")
		
	if player_node == null:
		print("Player node not found!")
		return
		
	if player_node.return_currency_amt() - 17 < 0:
		DialogManager.start_dialog(global_position, lines, speech_sound)
		sprite.flip_h = true if interaction_area.get_overlapping_bodies()[0].global_position.x < global_position.x else false
		await DialogManager.dialog_finished
		
	else:
		player_node.change_currency_amt(-17)
		player_node.set_active_weapon("cards")
		print("wow")
		is_empty = true
		queue_free()
