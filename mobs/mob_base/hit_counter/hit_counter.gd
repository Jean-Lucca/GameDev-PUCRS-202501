extends Node2D

@onready var esquerda = $ColorRect
@onready var Esquerda = $Esquerda

func _ready():
	var players = get_tree().get_nodes_in_group("Player")
	esquerda.add_to_group("hit_bar")
	
func on_hit():
	esquerda.hide()
	Esquerda.hide()
