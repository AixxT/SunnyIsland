extends Control



func _on_quit_pressed():
	get_tree().quit()
	
func _on_play_pressed():
	$transition.play("fade_out")

func _on_transition_animation_finished(anim_name):
	get_tree().change_scene_to_file("res://world.tscn")
