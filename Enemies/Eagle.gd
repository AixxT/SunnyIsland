extends CharacterBody2D

## Controla la velocidad del mob.
## A mayor gravedad mayor distancia recorre en el eje y
@export var gravity: int = 3000
## Controla el movimiento inicial del mob. 
## Si es 1 se eleva y si es -1 desciende
@export_range(-1,1,2) var initial_motion: int 
## Coordenadas de la posicion inicial del mob.
## Es necesaria para que respawnee en el mismo lugar de inicio
@export var initial_position: Vector2

var direction: Vector2
var player: Node
var motion: int = initial_motion
var initial_gravity: int #almacena el valor original de la gravedad

func _physics_process(delta):
	player = get_node("../../Player/Player")
	direction = (player.position - self.position).normalized()
	velocity.x = 0
	
	if get_node("Eagle-anim").current_animation != "death" && $Respawn.is_stopped():
		$"Eagle-anim".play("idle")
	
	if direction.x > 0: 
		get_node("AnimatedSprite2D").flip_h = true
	else :
		get_node("AnimatedSprite2D").flip_h = false
	
	if motion == 1:
		velocity.y = gravity * delta
	else:
		velocity.y = -(gravity) * delta
	
	if ($Respawn.is_stopped() && get_node("Eagle-anim").current_animation != "death") && gravity == 0:
		gravity = initial_gravity
		
	move_and_slide()


func _on_idle_timeout():
	motion = -(motion)
	if gravity == 0:
		gravity = initial_gravity

func _on_top_checker_body_entered(body):
	if body.name == "Player" && $damage_player.is_stopped():
		$"Sound-killed".play()
		body.bounce()
		initial_gravity = gravity 
		gravity = 0 #Para que no caiga hasta el piso al morir
		velocity.y = 0
		
		$idle.stop()
		get_node("Eagle-anim").play("death")
		set_collision_layer_value(5,false)
		set_collision_mask_value(1,false)
		$side_checker.set_collision_mask_value(1,false)
		$top_checker.set_collision_mask_value(1,false) #Elimina la collision mask y evita que el pj rebote de mas 
		await get_node("Eagle-anim").animation_finished
		self.visible = false
		$Respawn.start()

func _on_respawn_timeout():
	velocity.y = 0
	motion = initial_motion
	
	self.visible = true
	self.set_position(initial_position)
	get_node("Eagle-anim").play("respawn")
	
	await get_node("Eagle-anim").animation_finished
	gravity = initial_gravity #Espera a que termine el respawn antes de moverse
	set_collision_mask_value(1,true)
	$side_checker.set_collision_mask_value(1,true)
	$top_checker.set_collision_mask_value(1,true)
	set_collision_layer_value(5,true)
	
	$Respawn.stop()
	$idle.start()

#Damage the player
func _on_side_checker_body_entered(body):
	if body.name == "Player":
		body.ouch(direction.x)
		$damage_player.start() 
		set_collision_layer_value(5,false)
		set_collision_mask_value(1,false)
		$top_checker.set_collision_layer_value(5,false)
		$top_checker.set_collision_mask_value(1,false)

func _on_damage_player_timeout():
	set_collision_layer_value(5,true)
	set_collision_mask_value(1,true)
	if get_node("../../Player/Player").is_on_floor():
		$top_checker.set_collision_layer_value(5,true) 
		$top_checker.set_collision_mask_value(1,true)
		$damage_player.stop()

func _on_motion_assignation_timeout():
	motion = initial_motion
