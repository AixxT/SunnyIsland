extends Control

func _on_ready():
	$transition.play("fade_in_death")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#Restauro los valores de vidas predeterminados
	GLOBAL.lives = 3
	GLOBAL.max_lives = 3

func _on_try_again_pressed():
	get_tree().change_scene_to_file("res://Level/world.tscn")

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://Menu/main.tscn")

