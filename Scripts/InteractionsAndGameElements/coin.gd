extends CharacterBody2D

@onready var player_node = null
var friction = 1000

func set_initial_velocity(v: Vector2):
	velocity = v  # Use the built-in velocity property

func _physics_process(delta):
	# Apply friction
	if velocity.length() > 0:
		var friction_force = velocity.normalized() * friction * delta
		if friction_force.length() > velocity.length():
			velocity = Vector2.ZERO
		else:
			velocity -= friction_force

	# Move with built-in velocity
	move_and_slide()


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
