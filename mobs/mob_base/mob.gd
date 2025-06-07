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
	speed = 0
func startMoving():
	var sprite = $AnimatedSprite2D
	stop = false
	sprite.play()
	speed = 200
		
func move():
	var sprite = $AnimatedSprite2D
	var direction = player.global_position - global_position
	var distance = direction.length()
	var separation = Vector2.ZERO
	var min_distance_between_enemies = 100
	var enemies = get_tree().get_nodes_in_group("Enemies")
	
	for other in enemies:
		if other != self:
			var diff = global_position - other.global_position
			var dist = diff.length()
			if dist < min_distance_between_enemies and dist > 0:
				separation += diff.normalized() * ((min_distance_between_enemies - dist) / min_distance_between_enemies)

	if !stop:
		speed = 200
		if distance > attack_range:
			direction = direction.normalized()
			velocity = direction * speed				
			velocity += separation * speed  # força de separação proporcional	
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
	global_position.y = Globals.player.position.y  - 90
		
func die(wind_slash = false):
	var sprite = $AnimatedSprite2D
	camera.shake()
	var count = player.getAttacks()	
	
	if wind_slash:
		queue_free()
	
	if sistema_barra(sprite):
		return
		
	var explosion1 = Explosion.instantiate()  # Preload this scene
	get_parent().add_child(explosion1)
	explosion1.global_position = global_position  # Match position
	explosion1.pop_explosion()
	queue_free()
	get_tree().call_group("HUD", "update_score")
		
func sistema_barra(sprite):		
	if barras > 0:	
		barras = barras - 1				
		if global_position.x < player.global_position.x:  #direita			
			pop_tween(Vector2(player.position.x, self.position.y - 40 * 2), 0.3)					
		else:
			pop_tween(Vector2(player.position.x - 160, self.position.y - 40 * 2), 0.3)
		sprite.flip_h = !sprite.flip_h
		HitCounter.on_hit()
		return true
	return false
	
func pop_tween(move_target, move_duration):
	var distance = global_position.distance_to(move_target)
	var floatymove_duration = distance / 400
	stopMoving()
	var tween := get_tree().create_tween()	
	tween.set_ignore_time_scale(true)
	tween.tween_property(self, "global_position", move_target, floatymove_duration)\
		.set_trans(Tween.TRANS_LINEAR)
	
	await get_tree().create_timer(0.2).timeout	
	startMoving()
			
	
func _on_progress_finished():
	queue_free()  # if you want to remove the instance after explosion
			
func _on_visible_on_screen_notifier_2d_screen_exited():	
	queue_free()
