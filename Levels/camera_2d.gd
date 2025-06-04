extends Camera2D

@export var shake_intensity := 5.0
@export var shake_duration := 0.2
@export var red_flash_duration := 0.3

var _shake_time_left := 0.0
var _original_offset := Vector2.ZERO
@onready var red_flash_rect = $CanvasLayer/ColorRect
func _ready():
	_original_offset = offset
	
func flash_red():
	red_flash_rect.visible = true
	red_flash_rect.modulate.a = 0.5  # Starting opacity

	var tween = get_tree().create_tween()
	tween.tween_property(red_flash_rect, "modulate:a", 0.0, red_flash_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.finished.connect(_on_red_flash_finished)

func _on_red_flash_finished():
	red_flash_rect.visible = false

func _process(delta):
	if _shake_time_left > 0:
		_shake_time_left -= delta
		var shake = Vector2(
			randf_range(-1, 1),
			randf_range(-1, 1)
		) * shake_intensity
		offset = _original_offset + shake
		if _shake_time_left <= 0:
			offset = _original_offset

func zoom_in(target_zoom: Vector2, duration: float = 0.5):
	print("caiu aqui")
	var tween = get_tree().create_tween()
	tween.tween_property(self, "zoom", target_zoom, duration)

func zoom(vector):	
	self.set("zoom", vector)

func shake():
	_shake_time_left = shake_duration
