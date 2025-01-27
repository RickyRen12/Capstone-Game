extends AnimatedSprite2D
@onready var player_node = null

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("JWHBHBDJHJHDWJHBDWHW")
	if player_node == null:
		player_node = get_tree().current_scene.get_node("Player")
		
	if player_node == null:
		print("Player node not found!")
		return
	print(player_node.return_currency_amt())
	
	if(body.is_in_group("player")):
		player_node.change_currency_amt(1)
		print(player_node.return_currency_amt())

		queue_free()
