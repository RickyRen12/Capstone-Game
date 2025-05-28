extends CharacterBody2D

var EnemyDeath = preload("res://Scenes/EnemyDeath.tscn")
var coin = preload("res://Scenes/UI/coin.tscn")
var proj = preload("res://Scenes/enemyProj.tscn") 
@onready var HealthBar = $Healthbar
@onready var player: Node2D
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
@onready var hit_flash_animation = $Hit_flash_animation
@onready var raycast1 = $RayCast2D
@onready var raycast2 = $RayCast2D2
@onready var raycast3 = $RayCast2D3
@onready var raycast4 = $RayCast2D4
@onready var raycast5 = $RayCast2D5
@onready var raycast6 = $RayCast2D6
@onready var raycast7 = $RayCast2D7
@onready var raycast8 = $RayCast2D8

var rng = RandomNumberGenerator.new()
var player_chase = false
var will_shoot = false
var gun_cooldown = true
var health_amount : int = 15
var coin_range_center = 5
var chase_speed = 100
var knockback_power = 400
#if you wanna make the enemy run away when hit make the knockback decay smaller
var knockback_decay = 1000
var is_knocked_back = false  # Track knockback state
var knockback = Vector2.ZERO
var direction = 0


func _ready():
	rng.randomize()
	print("hai")
	HealthBar.init_health(health_amount)
	player = get_tree().get_first_node_in_group("player")
	make_path()
	
	nav_agent.path_desired_distance = 100  # pixels away from walls
	nav_agent.target_desired_distance = 4  # how close to get to the target before stopping

func _enemy_tracker():
	var simpleVectorX = [0,1,1, 1, 0,-1,-1,-1]
	var simpleVectorY = [1,1,0,-1,-1,-1, 0, 1]
	var simpleVectors = [simpleVectorX, simpleVectorY]
	
	var localPosX = self.position.x - player.position.x
	var localPosY = self.position.y - player.position.y

	var normalizedX = localPosX / sqrt((localPosX*localPosX) + (localPosY*localPosY))
	var normalizedY = localPosY / sqrt((localPosX*localPosX) + (localPosY*localPosY))
	
	
	var interestVector = [(normalizedY), (normalizedX*1 + normalizedY*1), (normalizedX), (normalizedX - normalizedY), (-normalizedY), (-1*normalizedX - normalizedY), (-normalizedX), (-normalizedX + normalizedY)]
	var contextVector = [0, 0, 0, 0, 0, 0, 0, 0]

	if ($RayCast2D1.is_colliding()):
		contextVector = [50, 20, 0, 0, 0, 0, 0, 20]
	elif ($RayCast2D2.is_colliding()):
		contextVector = [20, 50, 20, 0, 0, 0, 0, 0]
	elif ($RayCast2D3.is_colliding()):
		contextVector = [0, 20, 50, 20, 0, 0, 0, 0]
	elif ($RayCast2D4.is_colliding()):
		contextVector = [0, 0, 20, 50, 20, 0, 0, 0]
	elif ($RayCast2D5.is_colliding()):
		contextVector = [0, 0, 0, 20, 50, 20, 0, 0]
	elif ($RayCast2D6.is_colliding()):
		contextVector = [0, 0, 0, 0, 20, 50, 20, 0]
	elif ($RayCast2D7.is_colliding()):
		contextVector = [20, 0, 0, 0, 0, 0, 50, 20]
	elif ($RayCast2D8.is_colliding()):
		contextVector = [20, 0, 0, 0, 0, 0, 20, 50]

	var contextMap = []
	for x in range(0, interestVector.size() - 1):
		contextMap.insert(x, interestVector[x] - contextVector[x])

	var largest = 0
	for x in range(0, contextMap.size() - 1):
		if contextMap[x] > contextMap[largest]:
			largest = x
	var veloVectorY = simpleVectorY[largest]
	var veloVectorX = simpleVectorX[largest]
	print(largest)
	self.velocity = Vector2(veloVectorX*-100, veloVectorY*-100)
	
func _physics_process(delta):
	if player_chase and player:
		if nav_agent.is_navigation_finished():
			velocity = Vector2.ZERO

		else:
			var next_path_pos := nav_agent.get_next_path_position()
			direction = global_position.direction_to(next_path_pos)
			_enemy_tracker()
			knockback = knockback.move_toward(Vector2.ZERO, knockback_decay * delta)
			#velocity = direction * chase_speed
			move_and_collide((velocity + knockback) * delta)
		
	#enemy shooting
	if will_shoot and gun_cooldown and player:
		gun_cooldown = false
		$Marker2D.look_at(player.global_position)
		var proj_instance = proj.instantiate()
		proj_instance.rotation = $Marker2D.rotation
		proj_instance.global_position = $Marker2D.global_position
		get_parent().add_child(proj_instance)
		
		await get_tree().create_timer(1.4).timeout
		gun_cooldown = true

func make_path() -> void:
	if player:
		nav_agent.target_position = player.global_position

func _on_timer_timeout():
	make_path()

#shooting radius
func _on_area_2d_body_entered(body: Node2D) -> void:
	player = body
	will_shoot = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player:
		will_shoot = false



#chasing radius
func _on_chasing_area_body_entered(body):
	player = body
	player_chase = true

func _on_chasing_area_body_exited(body):
	if body == player:
		player = null
		player_chase = false


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
		area.queue_free()
		
	#kills enemy
	if health_amount <= 0:
		var EnemyDeath_instance = EnemyDeath.instantiate() as Node2D
		EnemyDeath_instance.global_position = global_position
		get_parent().add_child(EnemyDeath_instance)
		
		if player:
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

		
		queue_free()
