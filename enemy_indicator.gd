extends Node2D

var target_enemy: Node2D
var max_distance: float = 1000.0  # Distância máxima para mostrar o indicador
var min_distance: float = 200.0   # Distância mínima (inimigo já está próximo)

func _process(delta):
	if not is_instance_valid(target_enemy):
		queue_free()  # Remove o indicador se o inimigo for destruído
		return

	var player = get_tree().get_first_node_in_group("AnimPlayer")
	if not player:
		return

	var direction = (target_enemy.global_position - player.global_position).normalized()
	var distance = player.global_position.distance_to(target_enemy.global_position)

	# Ajustar visibilidade com base na distância
	if distance > max_distance:
		hide()
		return
	else:
		show()

	# Posicionar o indicador na borda da tela
	var screen_size = get_viewport_rect().size
	var margin = 50.0  # Distância da borda da tela
	var screen_pos = player.global_position + direction * min(screen_size.length() / 2 - margin, distance)
	global_position = screen_pos

	# Rotacionar o indicador para apontar para o inimigo
	rotation = direction.angle()

	# Ajustar aparência com base na proximidade
	var t = inverse_lerp(min_distance, max_distance, distance)
	modulate = Color(1, t, t)  # Vermelho (próximo) a branco (longe)
