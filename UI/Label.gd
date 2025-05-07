extends Label

@onready var score := 0

func update_score():
	score += 1
	text = "Score: " + str(score)
