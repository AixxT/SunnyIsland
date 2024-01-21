extends Control

signal play

func _ready():
	$Panel/AnimatedSprite2D.play("default")

func _on_texture_button_pressed():
	self.visible = false
	emit_signal("play")
