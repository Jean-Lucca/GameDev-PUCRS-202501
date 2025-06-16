extends HBoxContainer

var tex_left = preload("res://UI/imagens/esquerda.png")
var tex_right = preload("res://UI/imagens/direita.png")

@onready var grid_container = self  

# Fill the grid with arrows based on the sequence
func fill_grid_with_arrows(sequence: Array):
	clear_grid()
	
	for dir in sequence:
		var icon = TextureRect.new()
		if dir == "esquerda":
			icon.texture = tex_left
		else : 
			icon.texture = tex_right
		icon.expand = true
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.custom_minimum_size = Vector2(64, 64)
		grid_container.add_child(icon)

# Removes the first arrow and lets HBoxContainer shift others automatically
func pop_first_arrow():
	if get_child_count() == 0:
		return

	var first = get_child(0)

	# Optional animation (fade out)
	var tween = create_tween()
	tween.tween_property(first, "modulate:a", 0.0, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(Callable(first, "queue_free"))

# Clears all arrows
func clear_grid():
	for child in get_children():
		child.queue_free()
