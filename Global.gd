extends Node

var max_lives: int = 3
var lives: int = max_lives
var hud: Node

func lose_life():
	lives -= 1 
	hud.load_hearts()
	if lives <= 0:
		print("game over")

func gain_life():
	if lives > 0 && lives < max_lives:
		lives += 1
	elif lives == max_lives:
		max_lives += 1
		lives += 1
	hud.load_hearts()
