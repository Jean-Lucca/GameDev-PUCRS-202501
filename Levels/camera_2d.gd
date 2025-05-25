extends Camera2D

@export var shake_intensity := 4.0
@export var shake_duration := 0.2

var _shake_time_left := 0.0
var _original_offset := Vector2.ZERO

func _ready():
	_original_offset = offset
	

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

func zoom(vector):
	Camera2D.zoom = vector

func shake():
	_shake_time_left = shake_duration
