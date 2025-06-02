extends CharacterBody2D
var target: Node2D
var player: CharacterBody2D
var camera: Camera2D
@onready var HitCounter = $HitCounter
@onready var Explosion = preload("res://mobs/bloodFX/Explosion.tscn")
@export var speed: float = 100.0  # Speed at which the mob chases the player
@export var attack_range: float = 80.0  # Distance to stop and attack
var stop = false	
var barras = 1


func _ready():
	var players = get_tree().get_nodes_in_group("Player")
	var cameras = get_tree().get_nodes_in_group("Camera")
	if cameras.size() > 0:
		camera = cameras[0]
	if players.size() > 0:
		player = players[0]
	var sprite = $AnimatedSprite2D
	if sprite.material:
		sprite.material = sprite.material.duplicate()  # create a unique copy		
		
func _physics_process(delta):
	if not player or not is_instance_valid(player):
		return		
	move()
		
func stopMoving():
	var sprite = $AnimatedSprite2D
	stop = true
	sprite.stop()
func startMoving():
	var sprite = $AnimatedSprite2D
	stop = false
	sprite.play()
		
func move():
	var sprite = $AnimatedSprite2D
	var direction = player.global_position - global_position
	var distance = direction.length()
	
	if !stop:
		speed = 200
		if distance > attack_range:
			direction = direction.normalized()
			velocity = direction * speed					
			if velocity.x < 0:
				sprite.animation = "walk"
				sprite.flip_h = true
			elif velocity.x > 0:
				sprite.animation = "walk"
			sprite.play()
			move_and_slide()
		else:
			velocity = Vector2.ZERO
			move_and_slide()
			sprite.animation = "attack"
			sprite.play()			
			if(sprite.frame == 9):
				player.take_damage()		
	else:
		speed = 0
		
func die(wind_slash = false):
	var sprite = $AnimatedSprite2D
	camera.shake()
	var count = player.getAttacks()	
	
	if wind_slash:
		queue_free()
	
	if sistema_barra(sprite):
		return
	
	if count == 4:
		if sprite.material is ShaderMaterial:
			stopMoving()
			$".".remove_from_group("Enemies")
			sprite.material.set_shader_parameter("progress", 0.0)
			var tween = create_tween()
			tween.tween_property(sprite.material, "shader_parameter/progress", 1.0, 1)
			tween.connect("finished", Callable(self, "_on_progress_finished"))		
	else:
		var explosion1 = Explosion.instantiate()  # Preload this scene
		get_parent().add_child(explosion1)
		explosion1.global_position = global_position  # Match position
		explosion1.pop_explosion()
		queue_free()
			
func sistema_barra(sprite):		
	if barras > 0:	
		barras = barras - 1				
		if global_position.x < player.global_position.x:  #direita
			$".".position.x = player.position.x + 80 
		else:
			$".".position.x = player.position.x - 80 	  #esquerda			
		sprite.flip_h = !sprite.flip_h
		HitCounter.on_hit()
		return true
	return false
			
func _on_progress_finished():
	queue_free()  # if you want to remove the instance after explosion
			
func _on_visible_on_screen_notifier_2d_screen_exited():	
	queue_free()
