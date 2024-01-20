extends Path2D

##Determina si el path es closed o no
@export var loop:bool = true
##Velocidad de la platforma cuando el path es closed (loop: true)
@export var speed:float = 2.0
##Velocidad de la platforma cuando el path es open (loop: false)
@export var speed_scale: float = 1.0

var activated:bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if not loop:
		$AnimationPlayer.play("move")
		$AnimationPlayer.speed_scale = speed_scale
		set_process(false) #si el path es open no hay necesidad de que se ejecute _process(delta)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$PathFollow2D.progress += speed
