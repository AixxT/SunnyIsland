extends Area2D

signal gem_collected

func _on_shine_timeout():
	get_node("Gem-anim").play("shine")

func _on_body_entered(body):
	if body.name == "Player":
		emit_signal("gem_collected") #emito la signal que recibe el hud para incrementar el contador
		set_collision_mask_value(1,false)
		$shine.stop()
		get_node("Gem-anim").play("collected")
		await get_node("Gem-anim").animation_finished
		self.queue_free()


