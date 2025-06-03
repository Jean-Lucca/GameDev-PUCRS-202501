extends Node2D

@onready var chao_meio = $"Road&lamps"
@onready var chao_direita = $"Road&lamps2"
@onready var chao_esquerda = $"Road&lamps3"

@onready var collision = $StaticBody2D2/CollisionShape2D
@onready var collision2 = $StaticBody2D3/CollisionShape2D

@onready var player = Globals.player  # supondo que o player está exposto em Globals

var blocos = []
var bloco_largura = 0
var collision_width = 0

func _ready():
	blocos = [chao_esquerda, chao_meio, chao_direita]
	bloco_largura = chao_meio.texture.get_size().x * 0.6
	collision_width = collision.shape.extents.x * 2
	print("bloco_largura:", bloco_largura)
	print("collision_width:", collision_width)

func _process(delta):
	for bloco in blocos:		
		# Se o player passou do bloco + largura, reposiciona o bloco na frente
		if player.global_position.x - bloco.global_position.x > bloco_largura:
			var max_x = get_max_bloco_x()
			bloco.global_position.x = max_x + bloco_largura
		elif bloco.global_position.x - player.global_position.x > bloco_largura:
			# Reposiciona para trás
			var min_x = get_min_bloco_x()
			bloco.global_position.x = min_x - bloco_largura

	
	# Repetição da colisão
	move_collision_if_needed(collision)
	move_collision_if_needed(collision2)

func move_collision_if_needed(col):
	var col_center_x = col.global_position.x
	var player_x = player.global_position.x
	
	if abs(player_x - col_center_x) > collision_width:
		if player_x > col_center_x:
			# Move a colisão para frente do player
			col.global_position.x = player_x + collision_width / 2
		else:
			# Move a colisão para trás do player
			col.global_position.x = player_x - collision_width / 2

func get_max_bloco_x():
	var max_x = -INF
	for bloco in blocos:
		if bloco.global_position.x > max_x:
			max_x = bloco.global_position.x
	return max_x

func get_min_bloco_x():
	var min_x = INF
	for bloco in blocos:
		if bloco.global_position.x < min_x:
			min_x = bloco.global_position.x
	return min_x
