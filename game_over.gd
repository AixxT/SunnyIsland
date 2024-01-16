extends Control

func _on_ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_try_again_pressed():
	get_tree().change_scene_to_file("res://world.tscn")
	Global.lives = 3

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://main.tscn")

