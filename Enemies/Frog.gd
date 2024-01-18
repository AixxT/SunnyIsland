extends CharacterBody2D

const SPEED = 80
const JUMP_VELOCITY = -250
const BOUNCE_VELOCITY = -100
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

#Declaro la variable player que me va a servir para programar el chase 
var player: Node
var chase: bool = false 
var fst_jump: int = 0
var direction: Vector2 #Hacia donde se encuentra el player
@export var initial_position = Vector2(233, 211)

@onready var anim: Node = get_node("Frog-anim")

func _on_player_detection_body_entered(body):
	if body.name == "Player":
		chase = true
		if is_on_floor() && fst_jump == 0: 
			jump()
			fst_jump = 1
			$fst_jump.start() #Impide que salte seguidamente al entrar y salir del area2D

func _on_player_detection_body_exited(body):
	if body.name == "Player":
		$Chase.stop() #Si no persigue, desactiva el timer del salto
		chase = false
		

func _physics_process(delta):
	#Gravedad
	velocity.y += gravity * delta


	player = get_node("../../Player/Player")
	if is_on_floor():
		#El normalized transforma el vector original en vector unitario
		direction = (player.position - self.position).normalized() 

	if chase == true:
			if is_on_floor() && $Chase.is_stopped():
				$Chase.start() #Inicio el timer que regula el salto
			elif not is_on_floor() && velocity.y > 0:
				get_node("Frog-anim").play("fall")
			elif not is_on_floor():
				get_node("Frog-anim").play("jump")
				velocity.x = direction.x * SPEED # Necesaria para que se mueva durante los ciclos de salto
			else:
				get_node("Frog-anim").play("idle")
				velocity.x = 0

			if direction.x > 0: 
				get_node("AnimatedSprite2D").flip_h = true
			else :
				get_node("AnimatedSprite2D").flip_h = false
	elif is_on_floor():
		if get_node("Frog-anim").current_animation != "death" && $Respawn.is_stopped() :
			get_node("Frog-anim").play("idle")
		velocity.x = 0
	else:
		if velocity.y > 0 && $Respawn.is_stopped() :
			get_node("Frog-anim").play("fall")
	move_and_slide()

func _on_chase_timeout():
		jump()

func jump():
	get_node("Frog-anim").play("jump")
	#Si chase = true entonces salta y persigue
	velocity.y = JUMP_VELOCITY
	velocity.x = direction.x * SPEED #Necesaria para que se mueva en el primer salto

func _on_fst_jump_timeout():
	fst_jump = 0 
	$fst_jump.stop()
	
#Death
func _on_top_checker_body_entered(body):
	if body.name == "Player":
		$"Sound-killed".play()
		chase = false
		$Chase.stop()
		body.bounce()
		gravity = 0 #Para que no caiga hasta el piso al morir
		velocity.y = 0
		velocity.x = 0
		
		get_node("Frog-anim").play("death")
		set_collision_layer_value(5,false)
		set_collision_mask_value(1,false)
		$side_checker.set_collision_mask_value(1,false)
		$"Player-Detection".set_collision_mask_value(1,false)
		$top_checker.set_collision_mask_value(1,false) #Elimina la collision mask y evita que el pj rebote de mas 
		await get_node("Frog-anim").animation_finished
		self.visible = false
		$Respawn.start()

func _on_respawn_timeout():
	gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	velocity.y = 0
	
	self.visible = true
	self.set_position(initial_position)
	get_node("Frog-anim").play("respawn")
	await get_node("Frog-anim").animation_finished
	set_collision_layer_value(5,true)
	set_collision_mask_value(1,true)
	$side_checker.set_collision_mask_value(1,true)
	$"Player-Detection".set_collision_mask_value(1,true)
	$top_checker.set_collision_mask_value(1,true)
	
	$Respawn.stop()

#Damage the player
func _on_side_checker_body_entered(body):
	if body.name == "Player":
		body.ouch(direction.x)
		$damage_player.start() #Inicia el timer que evita la doble activacion
		set_collision_layer_value(5,false)
		set_collision_mask_value(1,false)
		$top_checker.set_collision_layer_value(5,false)
		$top_checker.set_collision_mask_value(1,false)

#Activa las collision layer/masks luego del timer
# para dar tiempo a que el player se aleje y no active dos veces las area2D
func _on_damage_player_timeout():
	set_collision_layer_value(5,true)
	set_collision_mask_value(1,true)
	if is_on_floor() && get_node("../../Player/Player").is_on_floor():
		$top_checker.set_collision_layer_value(5,true) 
		$top_checker.set_collision_mask_value(1,true)
		$damage_player.stop()





