extends Control


func _ready():
	$transition.play("fade_in_win")
	$Music_menu.play()

func _on_play_again_pressed():
	get_tree().change_scene_to_file("res://Level/world.tscn")
