extends Control

func _on_StartButton_pressed():
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
	pass

func _on_QuitButton_pressed():
	get_tree().quit()
	pass

func _on_OptionsButton_pressed():
	pass
