extends Area2D

var control:int = 0

signal crank_activated

func _ready():
	$AnimatedSprite2D.play("default")

func _on_body_entered(body):
	if body.name == "Player" and control == 0:
		control += 1
		$"Sound-crank".play()
		$AnimatedSprite2D.play("activated")
		emit_signal("crank_activated")
