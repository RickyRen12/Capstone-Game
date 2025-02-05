extends CharacterBody2D

var EnemyDeath = preload("res://Scenes/EnemyDeath.tscn")
var coin = preload("res://Scenes/UI/coin.tscn")
var proj = preload("res://Scenes/enemyProj.tscn") 
@onready var HealthBar = $Healthbar

var rng = RandomNumberGenerator.new()
var speed = 200
var player_chase = false
var will_shoot = false
var gun_cooldown = true
var player = null
var health_amount : int = 100

func _ready():
	HealthBar.init_health(health_amount)


func _physics_process(delta):
	if player_chase and player:
		position += (player.position - position)/speed
	else:
		speed = 10000
	move_and_collide(velocity * delta)

	if player:
		$Marker2D.look_at(player.position)
	#enemy shooting
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	player = body
	speed = 200
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


	
