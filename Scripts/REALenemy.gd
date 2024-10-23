extends CharacterBody2D

var EnemyDeath = preload("res://Scenes/EnemyDeath.tscn")
var proj = preload("res://Scenes/knife.tscn") 
var speed = 200
var player_chase = false
var will_shoot = false
var gun_cooldown = false
var player = null
var health_amount : int = 3

func _physics_process(delta):
	if player_chase:
		position += (player.position - position)/speed
	else:
		speed = 10000
	move_and_slide()
	if will_shoot and gun_cooldown:
		gun_cooldown = false
		
		await get_tree().create_timer(0.4).timeout
		gun_cooldown = true
		
		


func _on_area_2d_body_entered(body: Node2D) -> void:
	player = body
	speed = 200
	player_chase = true
	will_shoot = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	player = null
	player_chase = false
	will_shoot = false


func _on_hurt_box_area_entered(area: Area2D):
	print("HURTTTTTTTTTT", health_amount)
	if area.has_method("get_damage_amount"):
		var node = area as Node
		health_amount = health_amount - node.get_damage_amount()
		print("AHHH", health_amount)
		
		if health_amount <= 0:
			var EnemyDeath_instance = EnemyDeath.instantiate() as Node2D
			EnemyDeath_instance.global_position = global_position
			get_parent().add_child(EnemyDeath_instance)
			queue_free()
