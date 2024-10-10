extends CharacterBody2D

var speed =90
var player_chase = false
var player = null
var health_amount : int = 3

func _physics_process(delta):
	if player_chase:
		position += (player.position - position)/speed
	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	player = body
	player_chase = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	player = null
	player_chase = false


func _on_hurt_box_area_entered(area: Area2D):
	print("HURTTTTTTTTTT", health_amount)
	if area.get_parent().has_method("get_damage_amount"):
		var node = area.get_parent() as Node
		health_amount -= node.get_damage_amount
		print("AHHH", health_amount)
