extends Control


func _on_quit_pressed():
	get_tree().quit()
	
func _on_play_pressed():
	$Instructions.visible = true

func _on_instructions_play():
	$transition.play("fade_out")
	await $transition.animation_finished
	get_tree().change_scene_to_file("res://Level/world.tscn")
