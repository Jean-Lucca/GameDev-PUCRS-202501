extends Node2D

@onready var chao_meio = $"Road&lamps"
@onready var chao_direita = $"Road&lamps2"
@onready var chao_esquerda = $"Road&lamps3"

@onready var player = Globals.player  # supondo que o player está exposto em Globals

var blocos = []
var bloco_largura = 0

func _ready():
	blocos = [chao_esquerda, chao_meio, chao_direita]
	bloco_largura = chao_meio.texture.get_size().x  # ou tamanho fixo se for TileMap
	# Se for Node2D, talvez: chao_meio.get_node("Sprite2D").texture.get_size().x
	

func _process(delta):
	for bloco in blocos:		
		# Se o player passou do bloco + largura, reposiciona o bloco na frente
		if player.global_position.x - bloco.global_position.x > bloco_largura * 1:
			var max_x = get_max_bloco_x()
			bloco.global_position.x = max_x + bloco_largura
			

func get_max_bloco_x():
	var max_x = -INF
	for bloco in blocos:
		if bloco.global_position.x > max_x:
			max_x = bloco.global_position.x
	return max_x
