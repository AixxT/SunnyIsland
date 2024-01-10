extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("Cherry-anim").play("default")

func _on_body_entered(body):
	if body.name == "Player":
		# body.add_life()
		get_node("Cherry-anim").play("collected")
		set_collision_layer_value(4,false)
		set_collision_mask_value(1,false)
		await get_node("Cherry-anim").animation_finished
		self.queue_free()
		
