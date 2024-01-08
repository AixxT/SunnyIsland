extends CanvasLayer

var gems_collected: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$gems.text = str(gems_collected)

func _on_gem_collected():
	gems_collected += 1
	_ready()
