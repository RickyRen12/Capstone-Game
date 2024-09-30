class_name BaseEnemy
extends CharacterBody2D


var target: CharacterBody2D = null
@onready var _ray := $RayCast2D

func _physics_process(delta: float) -> void:
	
