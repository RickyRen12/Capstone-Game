extends CharacterBody2D

var target_player: Node2D = null
var attraction_speed = 400  # how fast the coin moves toward the player
var pickup_distance = 8  # how close before pickup
@onready var player_node = null
var friction = 1000

func set_initial_velocity(v: Vector2):
	velocity = v  # Use the built-in velocity property

func _physics_process(delta):
	if target_player and is_instance_valid(target_player):
		var dir = (target_player.global_position - global_position).normalized()
		velocity = dir * attraction_speed
		move_and_slide()

		# pickup if very close
		if global_position.distance_to(target_player.global_position) <= pickup_distance:
			if target_player.has_method("change_currency_amt"):
				target_player.change_currency_amt(1)
			queue_free()
	else:
		# friction-based deceleration
		if velocity.length() > 0:
			var friction_force = velocity.normalized() * friction * delta
			if friction_force.length() > velocity.length():
				velocity = Vector2.ZERO
			else:
				velocity -= friction_force
		move_and_slide()


#actual box area
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

#pick up area
func _on_area_2d_2_body_entered(body):
	if body.is_in_group("player"):
		target_player = body
