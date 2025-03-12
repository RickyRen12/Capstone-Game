extends CharacterBody2D

var EnemyDeath = preload("res://Scenes/EnemyDeath.tscn")
var coin = preload("res://Scenes/UI/coin.tscn")
var proj = preload("res://Scenes/enemyProj.tscn") 
@onready var HealthBar = $Healthbar
@onready var hit_flash_animation = $Hit_flash_animation

var rng = RandomNumberGenerator.new()
var player_chase = false
var will_shoot = false
var gun_cooldown = true
var player = null
var health_amount : int = 10
var chase_speed = 100
var knockback_power = 1200
#if you wanna make the enemy run away when hit make the knockback decay smaller
var knockback_decay = 600
var is_knocked_back = false  # Track knockback state
var knockback = Vector2.ZERO


func _ready():
	HealthBar.init_health(health_amount)


func _physics_process(delta):
	if player_chase and player:
		var direction = (player.position - position).normalized()
		knockback = knockback.move_toward(Vector2.ZERO, knockback_decay * delta)
		velocity = velocity.move_toward(direction * chase_speed + knockback, 200 * delta)
	else:
		velocity = Vector2.ZERO
	move_and_collide(velocity * delta)

	if player:
		$Marker2D.look_at(player.position)
	#enemy shooting
	if will_shoot and gun_cooldown and player:
		gun_cooldown = false
		var proj_instance = proj.instantiate()
		proj_instance.rotation = $Marker2D.rotation
		proj_instance.global_position = $Marker2D.global_position
		add_child(proj_instance)
		
		await get_tree().create_timer(1.4).timeout
		gun_cooldown = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	player = body
	player_chase = true
	will_shoot = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		player_chase = false
		will_shoot = false


func _on_hurt_box_area_entered(area: Area2D):
	#damaging enemy
	if area.has_method("get_damage_amount"):
		var node = area as Node
		health_amount = health_amount - node.get_damage_amount()
		HealthBar.health = health_amount
		print(health_amount)
		hit_flash_animation.play("hit_flash")
		var knockback_direction = (global_position - area.global_position).normalized()
		knockback = knockback_direction * knockback_power
		
	#kills enemy
	if health_amount <= 0:
		var EnemyDeath_instance = EnemyDeath.instantiate() as Node2D
		EnemyDeath_instance.global_position = global_position
		get_parent().add_child(EnemyDeath_instance)
		
		var my_random_number = rng.randf_range(0, 10.0)
		
		if(my_random_number < 5):
			var coin_instance = coin.instantiate() as Node2D
			coin_instance.global_position = global_position
			get_parent().add_child(coin_instance)
		
		queue_free()
