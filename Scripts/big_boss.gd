extends CharacterBody2D

var EnemyDeath = preload("res://Scenes/EnemyDeath.tscn")
var coin = preload("res://Scenes/UI/coin.tscn")
var card_proj = preload("res://Scenes/boss_proj.tscn")
var gambling_machine_scene = preload("res://Scenes/GamblingMachine1.tscn")

@onready var HealthBar = $Healthbar


var rng = RandomNumberGenerator.new()
var player = null
var health_amount : int = 120
var attack_timer = 0.0
var attack_interval = 1.0
var gun_cooldown = true
var coin_range_center = 10


func _ready():
	rng.randomize()
	HealthBar.init_health(health_amount)

func _physics_process(delta):
	if player and is_instance_valid(player):
		$Marker2D.look_at(player.global_position)
		attack_timer -= delta
		if attack_timer <= 0:
			attack_timer = attack_interval
			choose_attack()

func choose_attack():
	var attack_type = rng.randi_range(0, 2)
	match attack_type:
		0:
			shoot_card_burst(8)  # Full circle
		1:
			shoot_card_spread(10, 0.2)  # Aimed spread
		2:
			shoot_card_spiral(20, 360, 0.1)  # Spiral spread

func shoot_card_burst(bullet_count):
	if gun_cooldown:
		gun_cooldown = false
		for i in range(bullet_count):
			var angle = PI * 2 * i / bullet_count
			var proj = card_proj.instantiate()
			proj.global_position = global_position
			proj.set_direction(Vector2(cos(angle), sin(angle)))
			if is_instance_valid(get_tree().current_scene):
				get_tree().current_scene.add_child(proj)
		await get_tree().create_timer(1.0).timeout
		gun_cooldown = true

func shoot_card_spread(bullet_count, spread_angle):
	if gun_cooldown and player and is_instance_valid(player):
		gun_cooldown = false
		var base_angle = global_position.angle_to_point(player.global_position)
		for i in range(bullet_count):
			var angle = base_angle - spread_angle * (bullet_count - 1) / 2 + i * spread_angle
			var proj = card_proj.instantiate()
			proj.global_position = global_position
			proj.set_direction(Vector2(cos(angle), sin(angle)))
			if is_instance_valid(get_tree().current_scene):
				get_tree().current_scene.add_child(proj)
		await get_tree().create_timer(1.0).timeout
		gun_cooldown = true

func shoot_card_spiral(bullet_count, total_angle, delay):
	if gun_cooldown:
		gun_cooldown = false
		for i in range(bullet_count):
			var angle = deg_to_rad(total_angle * i / bullet_count)
			var proj = card_proj.instantiate()
			proj.global_position = global_position
			proj.set_direction(Vector2(cos(angle), sin(angle)))
			if is_instance_valid(get_tree().current_scene):
				get_tree().current_scene.add_child(proj)
			await get_tree().create_timer(delay).timeout
		gun_cooldown = true

func _on_hurt_box_area_entered(area: Area2D):
	if area.has_method("get_damage_amount"):
		var node = area as Node
		health_amount = health_amount - node.get_damage_amount()
		HealthBar.health = health_amount
		print(health_amount)
		area.queue_free()
		if health_amount <= 0:
			die()

func die():
	var EnemyDeath_instance = EnemyDeath.instantiate()
	EnemyDeath_instance.global_position = global_position
	get_parent().add_child(EnemyDeath_instance)
	var coin_count = rng.randi_range((coin_range_center - 3) * player.coin_mult, (coin_range_center + 3) * player.coin_mult)
	for i in range(coin_count):
		var coin_instance = coin.instantiate()
		var offset = Vector2(randf_range(-8, 8), randf_range(-8, 8))  # Adjust range as needed
		coin_instance.global_position = global_position + offset
		get_parent().add_child(coin_instance)
		# Give it an initial velocity to simulate spreading
		var angle = TAU * i / float(coin_count)  # evenly spaced around circle
		var speed = randf_range(80, 150)
		var direction = Vector2(cos(angle), sin(angle))
		
		if coin_instance.has_method("set_initial_velocity"):
			coin_instance.set_initial_velocity(direction * speed)
			
	var machine_instance = gambling_machine_scene.instantiate()
	machine_instance.global_position = global_position 
	get_parent().add_child(machine_instance)
	queue_free()

func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		player = body

func _on_detection_area_body_exited(body):
	if body == player:
		player = null
