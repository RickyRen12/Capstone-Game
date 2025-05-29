extends StaticBody2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite = $AnimatedSprite2D


func _ready():
	interaction_area.interact = Callable(self, "_start_gambling")
	
func _start_gambling():
	SceneSwitcher.switch_scene("res://Scenes/UI/win_screen.tscn")
	
