extends CharacterBody2D
var target: Node2D
var player: CharacterBody2D
var camera: Camera2D
@export var speed: float = 100.0  # Speed at which the mob chases the player
@export var attack_range: float = 350.0  # Distance to stop and attack
var stop = false	
var barras = 1
@export var purple_arrow: PackedScene
var thing_launched = false
var started_launching = false


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
	if !thing_launched:
		if !stop:
			speed = 200
			if started_launching:
				attack_range = 9999
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
				started_launching = true
				move_and_slide()
				sprite.animation = "attack"
				sprite.play()						
				if(sprite.frame == 6):
					if get_tree().get_node_count_in_group("purple_arrow") < 1:
						launch_purple_arrow()
					pass
		else:
			speed = 0
	else:
		var escape_dir = (global_position - player.global_position).normalized()
		velocity = escape_dir * speed
		move_and_slide()
		
		var screen_rect = get_viewport().get_visible_rect()
		if not screen_rect.has_point(global_position):
			queue_free()
		
	global_position.y = Globals.player.position.y  - 90

func launch_purple_arrow():
	if self:
		var projectile = purple_arrow.instantiate()
		projectile.add_to_group("projectile_enemy")
		projectile.position = global_position
		if global_position.x < Globals.player.global_position.x:
			projectile.direction = Vector2.RIGHT  
			projectile.get_node("AnimatedSprite2D").flip_h = false
		else:
			projectile.direction = Vector2.LEFT
			projectile.get_node("AnimatedSprite2D").flip_h = true
		get_tree().current_scene.add_child(projectile) 
		thing_launched = true
		
		
func die():
	var sprite = $AnimatedSprite2D	
	queue_free()	
					
	
func _on_progress_finished():
	queue_free()  # if you want to remove the instance after explosion
			
func _on_visible_on_screen_notifier_2d_screen_exited():	
	if started_launching && get_tree().get_node_count_in_group("purple_arrow") < 1:
		pass	
	else:
		queue_free()
