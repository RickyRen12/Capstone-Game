extends StaticBody2D


@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite = $AnimatedSprite2D
@onready var speech_sound = preload("res://Assets/Level/sound/cha-ching-alert-new-sale-jam-fx-1-00-04.wav")
@onready var end_teleporter_scene = preload("res://Scenes/Level/end_teleporter.tscn")  # Preload the end teleporter scene


const lines: Array[String] = ["You are being teleported..."]

func _unhandled_input(event):
	if event.is_action_pressed("interact"):
		if interaction_area.get_overlapping_bodies().size() > 0:
			DialogManager.start_dialog(global_position, lines, speech_sound	)

func _ready():
	interaction_area.interact = Callable(self, "_on_interact")
	
func _on_interact():
	DialogManager.start_dialog(global_position, lines, speech_sound)
	await DialogManager.dialog_finished
	emit_signal("shop_opened", self)
	teleport_player()

func teleport_player():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var end_teleporters = get_tree().get_nodes_in_group("end_teleporter")
		if end_teleporters.size() > 0:
			var end_teleporter_instance = end_teleporters[0]
			player.global_position = end_teleporter_instance.global_position
