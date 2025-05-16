extends Label

@onready var vida := 3

func update_vida():
	vida -= 1
	text = "Vida: " + str(vida)
