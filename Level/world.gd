extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$transition.play("fade_in")
	$"Music-transition".play("volume_in")
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _on_player_game_over():
	$transition.play("fade_out_death")
	
	await get_node("transition").animation_finished
	$Music_level.playing = false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Menu/game_over.tscn")

func _on_key_you_win():
	$transition.play("fade_out_win")
	await $transition.animation_finished
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file("res://Menu/you_win.tscn")
