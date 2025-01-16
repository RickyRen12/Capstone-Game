extends Node

var current_scene = null
var previous_scene = null  # Store the previous scene

func _ready() -> void:
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	print_debug(current_scene)

func switch_scene(res_path):
	call_deferred("_deferred_switch_scene", res_path)

func _deferred_switch_scene(res_path):
	# Remove the current scene from the tree instead of freeing it
	if current_scene:
		get_tree().root.remove_child(current_scene)
		previous_scene = current_scene  # Keep reference to the previous scene
	
	# Load and add the new scene
	var temp = load(res_path)
	current_scene = temp.instantiate()
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene
	
func return_to_previous_scene():
	if previous_scene:
		# Remove the current scene from the tree
		get_tree().root.remove_child(current_scene)
		
		# Swap the scenes
		var temp = current_scene
		current_scene = previous_scene
		previous_scene = temp
		
		# Add the previous scene back to the tree
		get_tree().root.add_child(current_scene)
		get_tree().current_scene = current_scene
	else:
		print_debug("No previous scene to return to.")
