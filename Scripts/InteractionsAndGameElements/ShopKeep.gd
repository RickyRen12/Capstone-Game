extends CharacterBody2D

signal shop_opened
var has_opened_store = false

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite = $AnimatedSprite2D
@onready var speech_sound = preload("res://Assets/Level/sound/cha-ching-alert-new-sale-jam-fx-1-00-04.wav")

var open = false
const lines: Array[String] = ["What would you like to purchase?"]

func _unhandled_input(event):
	if event.is_action_pressed("interact"):
		if interaction_area.get_overlapping_bodies().size() > 0:
			DialogManager.start_dialog(global_position, lines, speech_sound	)

func _ready():
	interaction_area.interact = Callable(self, "_on_interact")
	
func _on_interact():
	DialogManager.start_dialog(global_position, lines, speech_sound)
	sprite.flip_h = true if interaction_area.get_overlapping_bodies()[0].global_position.x < global_position.x else false
	await DialogManager.dialog_finished
	emit_signal("shop_opened", self)
	open = true
	
	
func check_open_shop():
	return open
