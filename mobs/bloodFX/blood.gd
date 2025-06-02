extends Node2D

@onready var bloodsplatter = $CPUParticles2D2

func pop_explosion():
	$CPUParticles2D.emitting = true
	if bloodsplatter:
		bloodsplatter.get_direction_()
