extends HBoxContainer

var tex_left = preload("res://UI/imagens/esquerda.png")
var tex_right = preload("res://UI/imagens/direita.png")

@onready var grid_container = self  

# Fill the grid with arrows based on the sequence
func fill_grid_with_arrows(sequence: Array, index: int):
	clear_grid()
	
	for i in range(sequence.size()):
		var dir = sequence[i]
		var icon = TextureRect.new()
		if dir == "esquerda":
			icon.texture = tex_left
		else : 
			icon.texture = tex_right
		icon.expand = true
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.custom_minimum_size = Vector2(64, 64)
		
		icon.set_meta("sequence_index", i)  # Marca o índice
		grid_container.add_child(icon)

# Remove exatamente o item que corresponde ao índice
func pop_first_arrow(index: int):
	for child in get_children():
		if child.has_meta("sequence_index") and child.get_meta("sequence_index") == index:
			var tween = create_tween()
			tween.tween_property(child, "modulate:a", 0.0, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			tween.tween_callback(Callable(child, "queue_free"))
			return  # sai após encontrar e iniciar remoção

# Clears all arrows
func clear_grid():
	for child in get_children():
		child.queue_free()
