extends Area2D

signal you_win

func _on_body_entered(body):
	if body.name == "Player":
		$"Sound-win".play()
		set_collision_mask_value(1,false)
		self.visible = false

func _on_soundwin_finished():
	self.queue_free()
	emit_signal("you_win")
