extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("Cherry-anim").play("default")

func _on_body_entered(body):
	if body.name == "Player":
		$Sound_gain_life.play()
		get_node("Cherry-anim").play("collected")
		GLOBAL.gain_life()
		set_collision_layer_value(4,false)
		set_collision_mask_value(1,false)

func _on_sound_gain_life_finished():
	self.queue_free()

func _on_cherryanim_animation_finished(anim_name):
	self.visible = false
