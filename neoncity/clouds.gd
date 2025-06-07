extends ParallaxLayer

func _process(delta) -> void:
	var speed = -5
	self.motion_offset.x += speed * delta
	motion_offset.x = round(motion_offset.x)
	
	var texture_width = 576  # substitua pelo tamanho real da textura do parallax
	
	# faz o offset “dar loop” dentro do tamanho da textura
	if self.motion_offset.x <= -texture_width:
		self.motion_offset.x += texture_width
	elif self.motion_offset.x >= texture_width:
		self.motion_offset.x -= texture_width
