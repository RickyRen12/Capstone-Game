extends Area2D

@export var speed: float = 300.0
@export var damage_amount_player: int = 1
var direction: Vector2 = Vector2.RIGHT  # Default rightward, will be rotated

func _ready():
	set_as_top_level(true)
	await get_tree().create_timer(5).timeout  # Auto-destroy after 5 sec
	queue_free()

func _process(delta):
	position += direction.rotated(rotation) * speed * delta

func set_direction(dir: Vector2):
	direction = dir.normalized()

func _on_visible_on_screen_enabler_2d_screen_exited():
	queue_free()

func get_damage_amount_player() -> int:
	return damage_amount_player	

func _on_area_entered(area: Area2D):
	print("area")

func _on_body_entered(body: Node2D):
	if body.is_in_group("walls"):
		queue_free()
	elif body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage_amount_player)
		elif "health_amount" in body:
			body.health_amount -= damage_amount_player
		queue_free()
