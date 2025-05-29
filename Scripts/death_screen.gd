extends Control

func _on_ReloadButton_pressed():
	var reload = get_tree().change_scene_to_file("res://Scenes/Level/main.tscn")
	pass

func _on_QuitButton_pressed():
	get_tree().quit()
	pass
