extends CPUParticles2D

func _ready():
	get_direction_()
	emitting = true
	
func get_direction_():
	if Globals.player.global_position.x > global_position.x:
		direction.x = -1
	if Globals.player.global_position.x < global_position.x:
		direction.x = 1
		
func _on_timer_timeout():
	queue_free()		
