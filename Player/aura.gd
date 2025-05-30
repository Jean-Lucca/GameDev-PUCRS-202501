extends Node2D

func pop_aura():
	$CPUParticles2D.emitting = true
	
func unpop_aura():
	$CPUParticles2D.emitting = false


func _on_timer_timeout() -> void:
	pass # Replace with function body.
