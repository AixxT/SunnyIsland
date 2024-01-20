extends CharacterBody2D

const SPEED = 170.0
const JUMP_VELOCITY = -300.0

enum States {AIR, FLOOR, LADDER, CROUCH}

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var state: int = States.FLOOR
var hurt: bool = false
var hurt_control: int = 0
var on_ladder: bool = false
var in_crouching_area:bool = false

var standing_cshape = preload("res://Player/standing-cshape.tres")
var crouching_cshape = preload("res://Player/crouching-cshape.tres")

@onready var anim = get_node("AnimationPlayer")

signal game_over

func _physics_process(delta):
	match state:
		States.AIR:
			velocity.y += gravity * delta
			if not hurt:
				velocity.x = side_direction() * SPEED
				# Para que la altura del salto dependa de cuanto se presiona la barra
				if Input.is_action_just_released("jump") && velocity.y < 0:
					velocity.y = 0
				
				if velocity.y < 0:
					anim.play("jump")
				elif velocity.y > 0:
					anim.play("fall")
			
				if is_on_floor():
					state = States.FLOOR
				elif should_climb_ladder():
					state = States.LADDER
			else:
				if is_on_floor():
					state = States.FLOOR
					
			move_and_slide()
		
		States.FLOOR:
			velocity.y += gravity * delta
			
			if not is_on_floor():
				state = States.AIR
			elif should_climb_ladder():
				state = States.LADDER
			elif is_on_floor() and Input.is_action_pressed("down") and not should_climb_ladder():
				state = States.CROUCH
			
			#Handle jump
			if Input.is_action_just_pressed("jump"):
				jump()
			
			if not hurt:
				move_and_slide()
				#Handle movement
				if side_direction():
					velocity.x = side_direction() * SPEED
					anim.play("run")
				else:
					velocity.x = move_toward(velocity.x, 0, SPEED)
					anim.play("idle")
		
		States.LADDER:
			if Input.is_action_just_pressed("jump"):
				jump()
				state = States.AIR
			elif not on_ladder:
				state = States.AIR
			elif is_on_floor() and Input.is_action_pressed("down") and velocity.y == 0:
				Input.action_release("down")
				Input.action_release("up")
				state = States.FLOOR
			
			
			if Input.is_action_pressed("down") or Input.is_action_pressed("up") or Input.is_action_pressed("left") or Input.is_action_pressed("right"):
				$AnimationPlayer.play("climb")
			else:
				$AnimationPlayer.play("climb-idle")
			
			if Input.is_action_pressed("up"):
				velocity.y = -SPEED * 0.5
			elif Input.is_action_pressed("down"):
				velocity.y = SPEED * 0.5
			else:
				velocity.y = 0
			
			if Input.is_action_pressed("left"):
				velocity.x = -SPEED * 0.3
			elif Input.is_action_pressed("right"):
				velocity.x = SPEED * 0.3
			else:
				velocity.x = 0
			
			move_and_slide()
		
		States.CROUCH:
			if Input.is_action_just_pressed("jump") and not in_crouching_area:
				Input.action_release("down")
				stand()
				jump()
				state = States.AIR
			elif not is_on_floor() and not in_crouching_area:
				stand()
				state = States.AIR
			
			if Input.is_action_pressed("down") and is_on_floor():
				crouch()
				crouch_walk()
			elif not in_crouching_area:
				stand() 
				state = States.FLOOR
			else:
				crouch_walk()
			move_and_slide()

func crouch_walk():
	if side_direction():
		velocity.x = side_direction() * SPEED * 0.3
		$AnimationPlayer.play("crouch-walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		$AnimationPlayer.play("crouch")

func stand():
	$CollisionShape2D.shape = standing_cshape
	$CollisionShape2D.position.y = 7

func crouch():
	$CollisionShape2D.shape = crouching_cshape
	$CollisionShape2D.position.y = 10

func should_climb_ladder() -> bool:
	var control = false
	if on_ladder and (Input.is_action_pressed("up") or Input.is_action_pressed("down")):
		control = true
	return control

func side_direction():
	#Controla la direccion de las animaciones
	var direction = Input.get_axis("left", "right")
	if direction == -1:
		get_node("AnimatedSprite2D").flip_h = true
	elif direction == 1: 
		get_node("AnimatedSprite2D").flip_h = false
	return direction

func jump():
	state = States.AIR
	velocity.y = JUMP_VELOCITY
	$Sounds/Sound_jump.play()

func bounce():
	velocity.y = JUMP_VELOCITY * 0.7
	state = States.AIR

func ouch(enemy_direction: float):
	hurt = true
	state = States.AIR
	GLOBAL.lose_life()
	set_collision_layer_value(1,false)
	
	if GLOBAL.lives <= 0:
		self.death()
	else:
		$hurt_timer.start()
		$Sounds/Sound_hurt.play()
		anim.play("hurt")
		set_modulate(Color(1,0.3,0.3,0.7))
		set_collision_mask_value(5,false)
		velocity.y = JUMP_VELOCITY * 0.6
		
		if enemy_direction > 0:
			velocity.x = 100
		elif enemy_direction < 0:
			velocity.x = -100
		
		Input.action_release("left") 
		Input.action_release("right")
		Input.action_release("up")

func _on_hurt_timer_timeout():
	set_modulate(Color(1,1,1,1))
	hurt = false
	if is_on_floor():
		state = States.FLOOR
		set_collision_mask_value(5,true)
		set_collision_layer_value(1,true)
		$hurt_timer.stop()
		velocity.x = 0

func death():
	get_tree().paused = true
	
	velocity.x = 0
	$Sounds/Sound_death.play()
	anim.play("death")
	await get_node("AnimationPlayer").animation_finished
	emit_signal("game_over")

func _on_ladder_checker_body_entered(body):
	if body.name == "Tile-ladders":
		on_ladder = true

func _on_ladder_checker_body_exited(body):
	if body.name == "Tile-ladders":
		on_ladder = false

func _on_areacrouchonly_body_entered(body):
	in_crouching_area = true

func _on_areacrouchonly_body_exited(body):
	in_crouching_area = false

func danger_zone():
	hurt = true
	GLOBAL.lose_life()
	set_collision_layer_value(1,false)
	
	if GLOBAL.lives <= 0:
		self.death()
	else:
		bounce()
		$hurt_timer.start()
		$Sounds/Sound_hurt.play()
		$AnimationPlayer.play("danger-zone")
		set_modulate(Color(1,0.3,0.3,0.7))
		self.set_position(Vector2(547,628))
		set_collision_mask_value(5,false)
		
		Input.action_release("left") 
		Input.action_release("right")
		Input.action_release("up")

func _on_dangerzones_body_entered(body):
	danger_zone()
