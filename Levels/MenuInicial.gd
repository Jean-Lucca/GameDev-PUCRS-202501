extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ColorRect/CenterContainer/VBoxContainer/HBoxContainer/StartButton.pressed.connect(_on_start_button_pressed)
	$ColorRect/CenterContainer/VBoxContainer/HBoxContainer2/InstructionsButton.pressed.connect(_on_instructions_button_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Main.tscn")

func _on_instructions_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/Instructions.tscn")
