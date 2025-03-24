extends Node2D

var Room = preload("res://Scenes/Level/character_body_2d.tscn")

var tile_size = 32
var num_rooms = 50
var min_size  = 4
var max_size = 10
var hspread = 0
var cull = 0.5 # chance to cull room
var path  # AStar pathfinding object
var start_room = null
var end_room = null

@onready var Map = $TileMap

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
		var w = min_size + randi() % (max_size - min_size)
		var h = min_size + randi() % (max_size - min_size)
		r.make_room(pos, Vector2(w,h) * tile_size) 
		$Rooms.add_child(r)
		#wait for rooms to stop moving
	print("POOOOOOOOOOOOOO")
	await get_tree().create_timer(1.1).timeout
	print("POOOOOO")
	#kill rooms
	var room_positions = []
	for room in $Rooms.get_children():
		if randf() < cull:
			room.queue_free()
		else:
			room.freeze = true
			room_positions.append(Vector2(room.position.x, room.position.y))
	await get_tree().process_frame
	# generate spanning tree (path)
	path = find_mst(room_positions)



func make_map():
	print("Generating map...")
	# Clear the TileMap
	#find_start_room()
	#find_start_room()
	Map.clear()

	# Fill TileMap with walls and carve out empty spaces
	var full_rect = Rect2()
	for room in $Rooms.get_children():
		var collision_shape = room.get_node("CollisionShape2D")
		if collision_shape and collision_shape.shape:
			# Calculate the room's bounding rectangle in world coordinates
			var room_size = collision_shape.shape.size * 2
			var room_rect = Rect2(room.position - room.size, room_size)
			full_rect = full_rect.merge(room_rect)
		else:
			print("Warning: Room missing CollisionShape2D or shape:", room.name)

	# Convert world coordinates to tilemap coordinates
	var topleft = Map.local_to_map(full_rect.position)
	var bottomright = Map.local_to_map(full_rect.end)

	# Fill the TileMap with walls (tile ID 1)
	for x in range(topleft.x, bottomright.x + 1):
		for y in range(topleft.y, bottomright.y + 1):
			Map.set_cell(0, Vector2i(x, y), 1, Vector2i(0, 0))

	# Carve rooms and corridors
	var corridors = []  # Track carved corridors to avoid duplicates
	for room in $Rooms.get_children():
		var collision_shape = room.get_node("CollisionShape2D")
		if collision_shape and collision_shape.shape:
			# Scale up the room size (e.g., 1.5x bigger)
			var scale_factor = 1.75  # Adjust this value to make rooms bigger or smaller
			var scaled_room_size = room.size * scale_factor
			
			# Calculate room size in tiles
			var room_size_tiles = (scaled_room_size / tile_size).floor()
			
			# Convert room_size_tiles to Vector2i
			var room_size_tiles_int = Vector2i(room_size_tiles)

			# Calculate the room's top-left corner in tile coordinates
			var room_center_tile = Map.local_to_map(room.position)
			var room_top_left_tile = room_center_tile - room_size_tiles_int

			# Carve out the room (tile ID 0)
			for x in range(room_top_left_tile.x, room_top_left_tile.x + room_size_tiles_int.x * 2):
				for y in range(room_top_left_tile.y, room_top_left_tile.y + room_size_tiles_int.y * 2):
					Map.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))

			# Carve out corridors
			var closest_point = path.get_closest_point(Vector2(room.position.x, room.position.y))
			for connection in path.get_point_connections(closest_point):
				if not connection in corridors:
					var start = Map.local_to_map(Vector2(path.get_point_position(closest_point).x, path.get_point_position(closest_point).y))
					var end = Map.local_to_map(Vector2(path.get_point_position(connection).x, path.get_point_position(connection).y))
					carve_path(start, end)
					corridors.append(connection)
		else:
			print("Warning: Room missing CollisionShape2D or shape:", room.name)

	print("Map generation complete.")


func carve_path(start: Vector2i, end: Vector2i):
	# Carves a path between two points
	var x_diff = sign(end.x - start.x)
	var y_diff = sign(end.y - start.y)
	
	# Handle cases where x_diff or y_diff is 0
	if x_diff == 0:
		x_diff = 1  # Default to moving right
	if y_diff == 0:
		y_diff = 1  # Default to moving down

	# Carve along the x-axis
	for x in range(start.x, end.x + x_diff, x_diff):
		Map.set_cell(0, Vector2i(x, start.y), 0, Vector2i(0, 0))  # Carve the main path
		Map.set_cell(0, Vector2i(x, start.y + y_diff), 0, Vector2i(0, 0))  # Widen the path

	# Carve along the y-axis
	for y in range(start.y, end.y + y_diff, y_diff):
		Map.set_cell(0, Vector2i(end.x, y), 0, Vector2i(0, 0))  # Carve the main path
		Map.set_cell(0, Vector2i(end.x + x_diff, y), 0, Vector2i(0, 0))  # Widen the path

#
#func find_start_room():
	#var min_x = INF
	#for room in $Rooms.get_children():
		#if room.position.x < min_x:
			#start_room = room
			#min_x = room.position.x
#
#func find_end_room():
	#var max_x = -INF
	#for room in $Rooms.get_children():
		#if room.position.x > max_x:
			#end_room = room
			#max_x = room.position.x


func find_mst(nodes):
	#Prim's algorithm
	path = AStar2D.new()
	path.add_point(path.get_available_point_id(), nodes.pop_front())
	
	#repeat until no more node remains
	while nodes:
		var minD = INF #minimum distance so far
		var minP = null #position of that node
		var p = null #current position
		#loop through all points in the path
		for p1 in path.get_point_ids():
			var p3
			p3 = path.get_point_position(p1)
			#loop though the remaining nodes
			for p2 in nodes:
				if p3.distance_to(p2) < minD:
					minD = p3.distance_to(p2)
					minP = p2
					p = p3
		var n = path.get_available_point_id()
		path.add_point(n, minP)
		path.connect_points(path.get_closest_point(p), n)
		nodes.erase(minP)
	return path


#func _draw():
	#for room in $Rooms.get_children():
		#draw_rect(Rect2(room.position - room.size, room.size * 2),
			#Color(0, 1, 0), false)
	#if path:
		#for p in path.get_point_ids():
			#for c in path.get_point_connections(p):
				#var pp = path.get_point_position(p)
				#var cp = path.get_point_position(c)
				#draw_line(Vector2(pp.x, pp.y),
					#Vector2(cp.x, cp.y),
					#Color(1, 1, 0, 1), 15, true)



func _input(event):
	if event.is_action_pressed('ui_select'):
		for n in $Rooms.get_children():
			n.queue_free()
		make_rooms()
	if event.is_action_pressed('ui_focus_next'):
		make_map()
