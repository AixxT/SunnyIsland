extends StaticBody2D

var above_ladder: bool = false

func _physics_process(delta):
	if Input.is_action_pressed("down") and above_ladder:
		$Ladder.rotation_degrees = 180
	else:
		$Ladder.rotation_degrees = 0

func _on_above_checker_body_entered(body):
	above_ladder = true

func _on_above_checker_body_exited(body):
	above_ladder = false
