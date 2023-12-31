extends CharacterBody2D

var direction: Vector2
var player: Node
@export var gravity = 3000
@export var motion: int = 1 #para poder modificarla en cada uno de los mobs

func _physics_process(delta):
	player = get_node("../../Player/Player")
	direction = (player.position - self.position).normalized()
	velocity.x = 0
	
	if get_node("Eagle-anim").current_animation != "death":
		$"Eagle-anim".play("idle")
	
	if direction.x > 0: 
		get_node("AnimatedSprite2D").flip_h = true
	else :
		get_node("AnimatedSprite2D").flip_h = false
	
	if motion == 1:
		velocity.y = gravity * delta
	else:
		velocity.y = -(gravity) * delta
	
	move_and_slide()


func _on_idle_timeout():
	motion = -(motion)

func _on_top_checker_body_entered(body):
	if body.name == "Player":
		body.bounce()
		gravity = 0 #Para que no caiga hasta el piso al morir
		velocity.y = 0
		
		get_node("Eagle-anim").play("death")
		set_collision_layer_value(5,false)
		set_collision_mask_value(1,false)
		$side_checker.set_collision_mask_value(1,false)
		$top_checker.set_collision_mask_value(1,false) #Elimina la collision mask y evita que el pj rebote de mas 
		await get_node("Eagle-anim").animation_finished
		self.queue_free()

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


