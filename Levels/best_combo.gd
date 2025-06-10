extends Label

func _ready():
	text = "Score: %d" % [Globals.cumulativescore]
