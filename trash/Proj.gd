extends Node2D

@onready var main = get_tree().get_root().get_node("main")
@onready var projectile = load("res://Scenes/proj.tscn")

func _ready():
	pass

func shoot():
	var instance = projectile.instansiate() 
	instance.dir = rotation
	instance.spawnPos = global_position
	instance.spawnRot = rotation
	main.add_child.call_deffered(instance)
