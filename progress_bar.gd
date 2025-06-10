extends ProgressBar

# Velocidade atual
var speed := 0

# Valor máximo para o ProgressBar (pode ser configurado no editor)
@export var speed_max := 400

func _ready():
	# Configura o valor máximo da barra de progresso
	max_value = speed_max
	add_to_group("HUD")
	# Assume que existe um singleton chamado Globals com a variável "speed"
	speed = Globals.speed

	# Inicializa o valor da barra
	update_speed()

func update_speed():
	# Atualiza o valor da barra com a velocidade atual
	print("chamou speed")
	value = Globals.speed
