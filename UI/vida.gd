extends Label

@onready var vida := 10

func update_vida():
	vida -= 1
	text = "Vida: " + str(vida)
