extends CanvasLayer

var gems_collected: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$gems.text = str(gems_collected)
	load_hearts()
	GLOBAL.hud = self

func _on_gem_collected():
	gems_collected += 1
	_ready()

func load_hearts():
	$hearts_full.size.x = GLOBAL.lives * 15
	$hearts_empty.size.x = (GLOBAL.max_lives - GLOBAL.lives) * 15
	$hearts_empty.position.x = $hearts_full.position.x + ($hearts_full.size.x * $hearts_full.scale.x)
