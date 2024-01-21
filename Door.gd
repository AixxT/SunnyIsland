extends Area2D

@export var target: NodePath 

var is_over_door:bool = false
var door_unlocked:bool = false
var player

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play("closed")

func _physics_process(delta):
	if is_over_door and door_unlocked and Input.is_action_just_pressed("up"):
		Input.action_release("up")
		player.position = get_node(target).position 
		$"Sound-closed".play()
	elif is_over_door and door_unlocked:
		$AnimatedSprite2D.play("open")
		$"Sound-open".play()
	
func can_use_door():
	var control:bool = false
	if is_over_door and door_unlocked:
		control = true
	return control

func _on_body_entered(body):
	if body.name == "Player":
		is_over_door = true
		player = body


func _on_body_exited(body):
	if body.name == "Player":
		is_over_door = false
		_ready()

func _on_crank_activated():
	door_unlocked = true

func _on_crank_activated_Door2():
	door_unlocked = true
