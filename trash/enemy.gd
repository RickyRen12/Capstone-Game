class_name BaseEnemy
extends CharacterBody2D

var angle_cone_of_vision := deg_to_rad(30.0)
var max_view_distance := 800.0
var angle_between_rays := deg_to_rad(5.0)

var target: CharacterBody2D = null
@onready var _ray := $RayCast2D

func _physics_process(_delta: float) -> void:
	var cast_count := int(angle_cone_of_vision / angle_between_rays) + 1
	
	for index in cast_count:
		var angle_offset := angle_between_rays * (index - cast_count / 2.0)
		var cast_vector := Vector2(max_view_distance, 0).rotated(angle_offset)
		
		#_ray.cast_to = cast_vector
		_ray.force_raycast_update()
		
		if _ray.is_colliding() and _ray.get_collider() is Player:
			target = _ray.get_collider()
			break
var does_see_player := target != null

#var _cast_coordinates := _precalculate_ray_coordinates()

func _precalculate_ray_coordinates() -> Array:
	var cast_vectors := []
	var cast_count := int(angle_cone_of_vision / angle_between_rays) + 1
	for index in cast_count:
		var cast_vector := (
				max_view_distance * Vector2.UP.rotated(angle_between_rays * (index - cast_count / 2.0))
		)
		cast_vectors.append(cast_vector)
	return cast_vectors
