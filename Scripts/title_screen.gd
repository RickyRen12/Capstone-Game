extends Control

func _on_StartButton_pressed():
	SceneSwitcher.switch_scene("res://Scenes/Level/main.tscn")
	pass

func _on_QuitButton_pressed():
	get_tree().quit()
	pass

func _on_OptionsButton_pressed():
	pass
