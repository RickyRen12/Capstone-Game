extends CharacterBody2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite = $AnimatedSprite2D
@onready var speech_sound = preload("res://Assets/Level/sound/cha-ching-alert-new-sale-jam-fx-1-00-04.wav")

const lines: Array[String] = ["YABA GABAGOOLE"]

func _ready():
	interaction_area.interact = Callable(self, "_on_interact")
	
func _on_interact():
	DialogManager.start_dialog(global_position, lines, speech_sound)
	sprite.flip_h = true if interaction_area.get_overlapping_bodies()[0].global_position.x < global_position.x else f
	await DialogManager.dialog_finished
