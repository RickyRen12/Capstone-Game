extends RayCast2D

var target: CharacterBody2D = null

func _physics_process(_delta: float) -> void:
	if is_colliding():
		if get_collider() is CharacterBody2D:
			print("poggers")
