extends Node2D

var Room = preload("res://Scenes/Level/character_body_2d.tscn")
var Player = preload("res://Scenes/player.tscn")


var tile_size = 32
var num_rooms = 50
var min_size  = 15
var max_size = 20
var hspread = 70
var path_thickness = 7  # Set this to control the thickness of the paths (e.g., 2 for 2 tiles wide)
var cull = 0.5 # chance to cull room
var path  # AStar pathfinding object

var start_room = null
var end_room = null
var play_mode = false
var player = null

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
	find_start_room()
	find_end_room()
	# Clear the TileMap
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
	var carved_connections = {}  # Track which connections have already been carved
	for room in $Rooms.get_children():
		var collision_shape = room.get_node("CollisionShape2D")
		if collision_shape and collision_shape.shape:
			# Scale up the room size (e.g., 1.75x bigger)
			var scale_factor = 1.75  # Adjust this value to make rooms bigger or smaller
			var scaled_room_size = room.size * scale_factor
			
			# Calculate room size in tiles (scaled)
			var room_size_tiles = (scaled_room_size / tile_size).floor()
			var room_size_tiles_int = Vector2i(room_size_tiles)

			# Calculate the room's top-left corner in tile coordinates
			var room_center_tile = Map.local_to_map(room.position)
			var room_top_left_tile = room_center_tile - room_size_tiles_int

			# Carve out the INNER part of the room (leaving a 2-tile border)
			for x in range(room_top_left_tile.x + 2, room_top_left_tile.x + room_size_tiles_int.x * 2 - 2):
				for y in range(room_top_left_tile.y + 2, room_top_left_tile.y + room_size_tiles_int.y * 2 - 2):
					Map.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))

			# Carve out corridors (unchanged)
			var closest_point = path.get_closest_point(room.position)
			for connection in path.get_point_connections(closest_point):
				var key = str(min(closest_point, connection)) + "-" + str(max(closest_point, connection))
				if not carved_connections.has(key):
					var start = Map.local_to_map(path.get_point_position(closest_point))
					var end = Map.local_to_map(path.get_point_position(connection))
					carve_path(start, end)
					carved_connections[key] = true
		else:
			print("Warning: Room missing CollisionShape2D or shape:", room.name)

	print("Map generation complete.")




func carve_path(pos1, pos2):
	# Carve a straight horizontal or vertical path between two points
	var x1 = pos1.x
	var y1 = pos1.y
	var x2 = pos2.x
	var y2 = pos2.y
	
	# Carve horizontally first, then vertically
	if x1 != x2:
		# Horizontal path
		var step = 1 if x2 > x1 else -1
		for x in range(x1, x2 + step, step):
			# Carve a path_thickness x path_thickness area to widen the corridor
			for i in range(path_thickness):
				for j in range(path_thickness):
					Map.set_cell(0, Vector2i(x + i, y1 + j), 0, Vector2i(0, 0))
	
	if y1 != y2:
		# Vertical path
		var step = 1 if y2 > y1 else -1
		for y in range(y1, y2 + step, step):
			# Carve a path_thickness x path_thickness area to widen the corridor
			for i in range(path_thickness):
				for j in range(path_thickness):
					Map.set_cell(0, Vector2i(x2 + i, y + j), 0, Vector2i(0, 0))


func find_start_room():
	var min_x = INF  # Initialize with a very large value
	start_room = null  # Reset the start_room variable
	
	# Loop through all rooms to find the leftmost room
	for room in $Rooms.get_children():
		if room.position.x < min_x:
			start_room = room
			min_x = room.position.x
	
	# Ensure the start_room is valid
	if start_room:
		print("Start Room Found: ", start_room.name)
		print("Start Room Position: ", start_room.position)
		print("Start Room Size: ", start_room.size)
		
		# Calculate the center of the start room
		var start_room_center = start_room.position + (start_room.size / 2)
		print("Start Room Center: ", start_room_center)
	else:
		print("Error: No start room found!")

func find_end_room():
	var max_x = -INF
	for room in $Rooms.get_children():
		if room.position.x > max_x:
			end_room = room
			max_x = room.position.x


func find_mst(nodes):
	# Prim's algorithm to generate a Minimum Spanning Tree (MST)
	path = AStar2D.new()
	path.add_point(path.get_available_point_id(), nodes.pop_front())
	
	# Repeat until no more nodes remain
	while nodes:
		var minD = INF  # Minimum distance so far
		var minP = null  # Position of the closest node
		var p = null  # Current position in the path
		
		# Loop through all points in the path
		for p1 in path.get_point_ids():
			var p3 = path.get_point_position(p1)
			# Loop through the remaining nodes
			for p2 in nodes:
				if p3.distance_to(p2) < minD:
					minD = p3.distance_to(p2)
					minP = p2
					p = p3
		
		# Add the closest node to the path
		var n = path.get_available_point_id()
		path.add_point(n, minP)
		
		# Ensure no duplicate connections
		if not path.are_points_connected(path.get_closest_point(p), n):
			path.connect_points(path.get_closest_point(p), n)
		
		nodes.erase(minP)
	
	return path


func _draw():
	for room in $Rooms.get_children():
		draw_rect(Rect2(room.position - room.size, room.size * 2),
			Color(0, 1, 0), false)
	if path:
		for p in path.get_point_ids():
			for c in path.get_point_connections(p):
				var pp = path.get_point_position(p)
				var cp = path.get_point_position(c)
				draw_line(Vector2(pp.x, pp.y),
					Vector2(cp.x, cp.y),
					Color(1, 1, 0, 1), 15, true)



func _input(event):
	if event.is_action_pressed('ui_select'):
		for n in $Rooms.get_children():
			n.queue_free()
		make_rooms()
		
	if event.is_action_pressed('ui_focus_next'):
		make_map()
		
	if event.is_action_pressed("ui_cancel"):
		var player = Player.instantiate()  # Instantiate the player scene
		add_child(player)  # Add the player to the scene tree
		
		# Ensure the start_room is valid
		if start_room:
			# Calculate the center of the start room
			var start_room_center = start_room.position + (start_room.size / 2)
			player.position = start_room_center  # Set the player's position to the center of the start room
		else:
			print("Error: No start room found!")
		
		# Switch to the player's camera
		if player.has_node("Camera2D"):  # Ensure the player has a Camera2D node
			print("Player Position: ", player.position) 
			var player_camera = player.get_node("Camera2D")
			player_camera.make_current()  # Set the player's camera as the active camera
		
		play_mode = true  # Enable play mode
