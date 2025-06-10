extends CharacterBody2D
var target: Node2D
var player: CharacterBody2D
var camera: Camera2D
@export var speed: float = Globals.speed  # Speed at which the mob chases the player
@export var attack_range: float = 50.0  # Distance to stop and attack
var stop = false	
var revived = false
@onready var esquerda = $Esquerda
@onready var direita = $Direita
@export var bones_explosion = preload("res://mobs/mob_double/skeleton.tscn")

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

	if revived && sprite.frame == 11:
		startMoving()
		$".".add_to_group("Enemies")
		print(revived)			
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
		speed = Globals.speed
		if distance > attack_range:
			direction = direction.normalized()
			velocity = direction * speed		
			velocity += separation * speed			
			if velocity.x < 0:
				sprite.animation = "walk"
				sprite.flip_h = true
				esquerda.hide()
			elif velocity.x > 0:
				sprite.animation = "walk"
				direita.hide()
			sprite.play()
			move_and_slide()
		else:
			velocity = Vector2.ZERO
			move_and_slide()
			sprite.animation = "attack"
			sprite.play()			
			if(sprite.frame == 4):
				player.take_damage()		
	else:
		speed = 0
	global_position.y = Globals.player.position.y - 70
		
func die(die):
	var sprite = $AnimatedSprite2D
	camera.shake()
	var count = player.getAttacks()
	queue_free()
	get_tree().call_group("HUD", "update_score")
	get_tree().call_group("HUD", "update_one_score")
	if bones_explosion:
		var explosion1 = bones_explosion.instantiate()
		get_parent().add_child(explosion1)
		explosion1.global_position = global_position  # Match position
		explosion1.pop_explosion()
	
	if !revived:
		#queue_free()
		stopMoving()
		$".".remove_from_group("Enemies")
		sprite.animation = "revive"		
		sprite.play()		
		revived = true
	else:
		queue_free()
			
func _on_progress_finished():
	queue_free()  # if you want to remove the instance after explosion
			
func _on_visible_on_screen_notifier_2d_screen_exited():	
	queue_free()
