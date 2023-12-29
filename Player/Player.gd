extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -300.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var hurt: bool = false
var hurt_control: int = 0
@onready var anim = get_node("AnimationPlayer")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if not hurt:
		# Handle jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			anim.play("jump")
		
		# Para que la altura del salto dependa de cuanto se presiona la barra
		if Input.is_action_just_released("ui_accept") && velocity.y < 0:
			velocity.y = 0

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction = Input.get_axis("ui_left", "ui_right")
		
		if direction == -1:
			get_node("AnimatedSprite2D").flip_h = true
		elif direction == 1: 
			get_node("AnimatedSprite2D").flip_h = false
	
		if direction:
			velocity.x = direction * SPEED
			if velocity.y == 0 && is_on_floor():
				anim.play("run")
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			if velocity.y == 0:
				anim.play("idle")
			elif velocity.y > 0:
				anim.play("fall")
	
	move_and_slide()

func bounce():
	velocity.y = JUMP_VELOCITY * 0.7

func ouch(enemy_direction: float):
	hurt = true
	$hurt_timer.start()
	anim.play("hurt")
	set_modulate(Color(1,0.3,0.3,0.7))
	set_collision_mask_value(5,false)
	velocity.y = JUMP_VELOCITY * 0.6
	
	if enemy_direction > 0:
		velocity.x = 100
	elif enemy_direction < 0:
		velocity.x = -100
	
	Input.action_release("ui_left") 
	Input.action_release("ui_right")
	Input.action_release("ui_up")

func _on_hurt_timer_timeout():
	set_modulate(Color(1,1,1,1))
	hurt = false
	if is_on_floor():
		set_collision_mask_value(5,true)
		$hurt_timer.stop()
		velocity.x = 0

