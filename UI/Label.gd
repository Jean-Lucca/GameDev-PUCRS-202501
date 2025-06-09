extends Label

@onready var score := 0

func update_score():
	score += 1
	#text = "Score: " + str(score)
	show_combo_popup(str(score) + "x combo")

func reset_score():
	score = 0

func show_combo_popup(combo_text: String):
	# Create a new Label for the combo popup
	var combo_label = Label.new()
	combo_label.text = combo_text
	combo_label.set("theme_override_font_sizes/font_size", 28) # Larger font size
	combo_label.set("theme_override_colors/font_color", Color(1, 0.8, 0, 1)) # Brighter yellow
	combo_label.position = Vector2(50, -50) # Higher starting position
	
	add_child(combo_label)

	# Create a Tween for animation
	var tween = create_tween()
	tween.set_parallel(true) # Run animations in parallel

	# Scale animation (more dramatic pop-in)
	combo_label.scale = Vector2(0.3, 0.3) # Start smaller
	tween.tween_property(combo_label, "scale", Vector2(1.5, 1.5), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(combo_label, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_LINEAR)

	# Upward movement
	tween.tween_property(combo_label, "position:y", combo_label.position.y - 20, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# Fade out animation
	tween.tween_property(combo_label, "modulate:a", 0.0, 0.6).set_delay(0.4).set_trans(Tween.TRANS_LINEAR)

	# Remove the label after animation
	tween.tween_callback(combo_label.queue_free).set_delay(1.2)
