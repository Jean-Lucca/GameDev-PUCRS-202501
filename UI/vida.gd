extends ProgressBar

@onready var vida := 10
@export var vida_max := 10

func _ready():
	max_value = vida_max
	value = vida

func update_vida():
	vida -= 1
	value = vida
