extends ParallaxLayer

func _process(delta) -> void:
	motion_offset.x = round(motion_offset.x)
	
