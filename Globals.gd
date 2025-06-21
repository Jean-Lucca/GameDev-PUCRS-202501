extends Node

var player = null
var bestscore = null
var cumulativescore = null
var speed = 250.0
var timer = null
var inimigosMax = 8
var bossSpawnado = 0
	
func kill_all_enemies():
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		if enemy.has_method("die"):
			enemy.die(true)
