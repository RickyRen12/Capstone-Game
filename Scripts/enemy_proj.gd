extends Area2D

var speed = 300
var damage_amount_player : int = 1

func _ready():
	set_as_top_level(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += (Vector2.RIGHT*speed).rotated(rotation) * delta


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()

func get_damage_amount_player() -> int:
	return damage_amount_player	

func _on_area_entered(area: Area2D) -> void:
	print("area")
	
func _on_body_entered(body: Node2D) -> void:
	if(body.is_in_group("walls")):
		queue_free()
	if(body.is_in_group("player")):
		queue_free()


func holder():
	print("please")
