extends Area2D

signal crank_activated

func _ready():
	$AnimatedSprite2D.play("default")

func _on_body_entered(body):
	if body.name == "Player":
		$AnimatedSprite2D.play("activated")
		emit_signal("crank_activated")
