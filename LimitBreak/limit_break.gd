extends Node2D

@onready var limit_bar: ProgressBar = $ProgressBar

func _ready():
	if limit_bar != null:
		add_to_group("LimitBreak")
		limit_bar.min_value = 0
		limit_bar.max_value = 100
		limit_bar.value = 0
		
		
func add_limit_break():
	if limit_bar:
		limit_bar.value = min(limit_bar.value + 1.5, limit_bar.max_value)
		#limit_bar.value = 100
		update_bar_color()
		
func zero_limit_break():
	if limit_bar.value == 100:
		limit_bar.value = 0	
		
func is_full():
	return limit_bar.value == 100

func update_bar_color():
	var fill_style = limit_bar.get("theme_override_styles/fill")
	if fill_style:
		if limit_bar.value >= limit_bar.max_value:
			fill_style.bg_color = Color(0.0, 1.0, 0.0, 1.0) 
		else:
			fill_style.bg_color = Color(0.5, 0.5, 0.5, 1.0) # Gray
