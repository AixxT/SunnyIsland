extends CharacterBody2D


const SPEED = 60.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var initial_motion:int
var direction: Vector2

@onready var player = get_node("../../Player/Player")

## Inicio del movimiento. 
## En 1 empieza caminando hacia la derecha, en -1 hacia la izquierda
@export_range(-1,1,2) var motion:int
@export var initial_position: Vector2

func _physics_process(delta):
	#gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	direction = (player.position - self.position).normalized()
	
	if get_node("AnimationPlayer").current_animation != "death" && $Respawn.is_stopped():
		$AnimationPlayer.play("patrol")
		if motion > 0:
			velocity.x = SPEED
			get_node("AnimatedSprite2D").flip_h = true
		else:
			velocity.x = -(SPEED)
			get_node("AnimatedSprite2D").flip_h = false
	
	move_and_slide()

#Almacena el valor inicial del motion para poder utilizarla al respawn
func _on_motion_assignation_timeout():
	initial_motion = motion

#Damage the player
func _on_side_checker_body_entered(body):
	if body.name == "Player":
		$damage_player.start()
		body.ouch(direction.x)
		set_collision_layer_value(5,false)
		set_collision_mask_value(1,false)
		$top_checker.set_collision_mask_value(5,false)
		$top_checker.set_collision_mask_value(1,false)
	elif body.name == "Map_borders" or body.name == "patrol_borders":
		motion = -(motion)

#Trigger death animation
func _on_top_checker_body_entered(body):
	if body.name == "Player" && $damage_player.is_stopped():
		$"Sound-killed".play()
		velocity.x = 0
		body.bounce()
		get_node("AnimationPlayer").play("death")
		set_collision_mask_value(1,false)
		set_collision_layer_value(5,false)
		
		$side_checker.set_collision_mask_value(1,false)
		$top_checker.set_collision_mask_value(1,false) #Elimina la collision mask y evita que el pj rebote de mas 
		await get_node("AnimationPlayer").animation_finished
		self.visible = false
		$Respawn.start()

func _on_respawn_timeout():
	motion = initial_motion
	
	self.visible = true
	self.set_position(initial_position)
	get_node("AnimationPlayer").play("respawn")
	
	await get_node("AnimationPlayer").animation_finished
	set_collision_mask_value(1,true)
	set_collision_layer_value(5,true)
	$side_checker.set_collision_mask_value(1,true)
	$top_checker.set_collision_mask_value(1,true)
	
	$Respawn.stop()


func _on_damage_player_timeout():
	set_collision_layer_value(5,true)
	set_collision_mask_value(1,true)
	if get_node("../../Player/Player").is_on_floor():
		$top_checker.set_collision_layer_value(5,true) 
		$top_checker.set_collision_mask_value(1,true)
		$side_checker.set_collision_mask_value(1,true)
		$damage_player.stop()
