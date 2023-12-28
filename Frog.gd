extends CharacterBody2D

const SPEED = 80
const JUMP_VELOCITY = -250
const BOUNCE_VELOCITY = -100
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

#Declaro la variable player que me va a servir para programar el chase 
var player: Node
var chase: bool = false 
var direction: Vector2 #Hacia donde se encuentra el player

@onready var anim: Node = get_node("Frog-anim")

func _on_player_detection_body_entered(body):
	if body.name == "Player":
		chase = true

func _on_player_detection_body_exited(body):
	if body.name == "Player":
		chase = false
		$Chase.stop() #Si no persigue, desactiva el timer del salto

func _physics_process(delta):
	#Gravedad
	velocity.y += gravity * delta
	
	player = get_node("../../Player/Player")
	#El normalized transforma el vector original en vector unitario
	direction = (player.position - self.position).normalized() 
	if chase == true:
			if is_on_floor() && $Chase.is_stopped():
				jump() #Como el timer esta apagado por default arranca saltando
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
	else:
		if get_node("Frog-anim").current_animation != "death":
			get_node("Frog-anim").play("idle")
		velocity.x = 0
	move_and_slide()

func _on_timer_timeout(): #cuando el timer se termina salta
	jump()

func jump():
	get_node("Frog-anim").play("jump")
	#Si chase = true entonces salta y persigue
	velocity.y = JUMP_VELOCITY
	velocity.x = direction.x * SPEED #Necesaria para que se mueva en el primer salto

func _on_top_checker_body_entered(body):
	if body.name == "Player":
		chase = false
		$Chase.stop()
		body.bounce()
		gravity = 0
		
		get_node("Frog-anim").play("death")
		set_collision_layer_value(5,false)
		set_collision_mask_value(1,false)
		$side_checker.set_collision_mask_value(1,false)
		$"Player-Detection".set_collision_mask_value(1,false)
		$top_checker.set_collision_mask_value(1,false) #Elimina la collision mask y evita que el pj rebote de mas 
		await get_node("Frog-anim").animation_finished
		self.queue_free()

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
	if is_on_floor():
		$top_checker.set_collision_layer_value(5,true)
		$top_checker.set_collision_mask_value(1,true)
		$damage_player.stop()
