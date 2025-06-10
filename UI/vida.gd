extends ProgressBar

@onready var vida := 5
@export var vida_max := 5

func _ready():
	max_value = vida_max
	value = vida

func update_vida():
	vida -= 1
	value = vida
