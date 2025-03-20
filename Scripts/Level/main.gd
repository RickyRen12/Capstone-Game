extends Node2D

var Room = preload("res://Scenes/Level/character_body_2d.tscn")

var tile_size = 32
var num_rooms = 75
var min_size  = 4
var max_size = 10
var hspread = 0
var cull = 0.5 # chance to cull room
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	make_rooms()

func _process(delta):
	queue_redraw()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func make_rooms():
	for i in range(num_rooms):
		var pos = Vector2(randf_range(-hspread, hspread), 0)
		var r = Room.instantiate()
		var w = min_size + randi() % (max_size  - min_size)
		var h = min_size + randi() % (max_size  - min_size)
		r.make_room(pos, Vector2(w,h) * tile_size) 
		$Rooms.add_child(r)
		#wait for rooms to stop moving
	print("POOOOOOOOOOOOOO")
	await get_tree().create_timer(1.1).timeout
	print("POOOOOO")
	#kill rooms
	for room in $Rooms.get_children():
		if randf() < cull:
			room.queue_free()
		else:
			room.set_deferred("body_mode", RigidBody2D.FREEZE_MODE_STATIC)
func _draw():
	for room in $Rooms.get_children():
		draw_rect(Rect2(room.position - room.size, room.size * 2), Color(252, 255, 255), false)

func _input(event):
	if event.is_action_pressed('ui_select'):
		for n in $Rooms.get_children():
			n.queue_free()
		make_rooms()
