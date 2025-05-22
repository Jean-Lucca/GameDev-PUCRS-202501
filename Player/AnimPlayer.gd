extends CharacterBody2D

@export var gravity := 2500.0
@onready var sprite = $PlayerSprite
@onready var buster_left = $Buster_left
@onready var buster_right = $Buster_right
@export var attack_range := 150.0
@export var wind_slash: PackedScene
@onready var camera = $Camera2D
var facing_dir := 1  # 1 = right, -1 = left
@onready var hit_sound = $HitSound
@onready var life = 300000000
var is_invincible = false
var invincibility_time = 0.0
const INVINCIBILITY_DURATION = 1.5
var is_attacking = false
var nodes = null


func _ready():
	add_to_group("AnimPlayer")
	wind_slash = preload("res://Player/wind_slash.tscn")

func animate_side():
	if is_attacking && sprite.frame != 6:	
		return
		
	is_attacking = false
	
	if !is_attacking:
		sprite.frame = 0
		sprite.stop()	
		
func get_side_input(delta):
	if is_attacking:
		return
	
	velocity.x = 0
	var vel := Input.get_axis("left", "right")
	
	if vel != 0:
		facing_dir = sign(vel)
		#print(facing_dir)
	
	if Input.is_action_just_pressed("left") || Input.is_action_just_pressed("right"):
		var enemy_hit = detect_enemy_in_direction(facing_dir)
		setAnim(facing_dir)
		is_attacking = true
		hit_sound.play()
		pop_limit_break()
		
		if enemy_hit:
			get_tree().call_group("HUD", "update_score")													
			basic_attack(enemy_hit)													
			get_tree().call_group("LimitBreak", "add_limit_break")

func pop_limit_break():
	nodes = get_tree().get_nodes_in_group("LimitBreak")
	if nodes.size() > 0:
		if nodes[0].is_full():
			get_tree().call_group("LimitBreak", "zero_limit_break")
			launch_wind_slash()
			print("is full")		

func basic_attack(enemy_hit):
	if enemy_hit == null:
		return
	
	var enemy_x = enemy_hit.global_position.x
	push_enemies_back(enemy_x)
	
	# Enemy dies (you can delay this if you want animation)
	enemy_hit.die()

	# Smoothly move player toward the enemy
	var move_duration := 0.3
	var move_target := Vector2(enemy_x, global_position.y)	

	var tween := get_tree().create_tween()
	tween.tween_property(self, "global_position", move_target, move_duration)\
		.set_trans(Tween.TRANS_QUINT)\
		.set_ease(Tween.EASE_OUT)


func launch_wind_slash():
	if wind_slash:
		var projectile = wind_slash.instantiate()
		projectile.add_to_group("wind_slash")
		projectile.position = global_position
		if facing_dir == 1:
			projectile.direction = Vector2.RIGHT  
			projectile.get_node("AnimatedSprite2D").flip_h = false
		if facing_dir == -1:
			projectile.direction = Vector2.LEFT
			projectile.get_node("AnimatedSprite2D").flip_h = true
		get_tree().current_scene.add_child(projectile) 


func push_enemies_back(origin_x: float):
	var push_distance = 100.0
	var duration = 0.1
	var max_distance = 100.0  # Só empurra inimigos próximos ao origin_x

	for enemy in get_tree().get_nodes_in_group("Enemies"):
		if enemy == null:
			continue

		if not enemy.has_method("stopMoving") or not enemy.has_method("startMoving"):
			push_warning("Enemy %s does not implement required methods." % enemy.name)
			continue

		var enemy_pos = enemy.global_position
		var distance_to_origin = abs(enemy_pos.x - origin_x)
		if distance_to_origin > max_distance:
			continue  # Pula inimigos muito distantes

		enemy.stopMoving()

		var target_x = enemy_pos.x - push_distance if enemy_pos.x < origin_x else enemy_pos.x + push_distance
		var target_position = Vector2(target_x, enemy_pos.y)

		var tween := get_tree().create_tween()
		tween.tween_property(enemy, "global_position", target_position, duration)\
			.set_trans(Tween.TRANS_BACK)\
			.set_ease(Tween.EASE_OUT)

		tween.finished.connect(func():
			if is_instance_valid(enemy): 
				enemy.startMoving()
		)


func move_side(delta):
	velocity.y += gravity * delta
	get_side_input(delta)
	animate_side()
	move_and_slide()

func detect_enemy_in_direction(dir: int) -> Node2D:
	var enemies = get_tree().get_nodes_in_group("Enemies")
	var found_enemy = null

	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue

		var to_enemy = enemy.global_position - global_position
		var horizontal_ok = (dir == 1 and to_enemy.x > 0) or (dir == -1 and to_enemy.x < 0)
		var vertical_ok = abs(to_enemy.y) < 50  # margem vertical
		var range_ok = to_enemy.length() < attack_range

		if horizontal_ok and vertical_ok and range_ok:
			found_enemy = enemy
			break
	return found_enemy

func detect_enemy_in_direction_delta() -> void:
	if get_tree() == null:
		return
	var enemies = get_tree().get_nodes_in_group("Enemies")
	if enemies.is_empty():
		return  # No enemies to push
	var right_detected = false
	var left_detected = false

	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue

		var to_enemy = enemy.global_position - global_position
		var vertical_ok = abs(to_enemy.y) < 50
		var range_ok = to_enemy.length() < attack_range

		if vertical_ok and range_ok:
			if to_enemy.x > 0:
				right_detected = true
			elif to_enemy.x < 0:
				left_detected = true

	# Atualiza cor da barra da direita
	if right_detected:
		buster_right.play("golden_right")
	else:
		buster_right.play("normal_right")

	# Atualiza cor da barra da esquerda
	if left_detected:
		buster_left.play("red_left")
	else:
		buster_left.play("normal_left")

func animate():
	if detect_enemy_in_direction(facing_dir):
		if is_attacking && sprite.frame != 6:	
			return
	if !is_attacking:
		sprite.frame = 0
		Engine.time_scale = 1
		sprite.stop()	
		
func setAnim(dir: int):
	if !is_attacking:
		if dir == -1:
			sprite.play("left")
			sprite.flip_h = true
		if dir == 1: 
			sprite.play("right")		
			sprite.flip_h = false
		
func _physics_process(delta):
	if is_invincible:
		invincibility_time -= delta
		if invincibility_time <= 0:
			is_invincible = false
			$PlayerSprite.modulate = Color(1, 1, 1)  # volta ao normal
			
	move_side(delta)
	detect_enemy_in_direction_delta()

func take_damage():
	if is_invincible:
		return  # ignora dano
	life -= 1
	get_tree().call_group("HUD", "update_vida")
	is_invincible = true
	invincibility_time = INVINCIBILITY_DURATION
	$PlayerSprite.modulate = Color(1, 1, 1, 0.5)  # visual: fica meio transparente
	hit_sound.play()

	if life <= 0:
		get_tree().change_scene_to_file("res://Levels/GameOver.tscn")

#chamar essa func a cada 4 ataques(?) variar de 4 a mais		
func attack_zoom():
	if is_attacking:
		if is_instance_valid(camera):
			camera.zoom = Vector2(1.8,1.8)		
			Engine.time_scale = 0.3
	else:
		if is_instance_valid(camera):
			camera.zoom = Vector2(1.0,1.0)		
			Engine.time_scale = 1

func _on_area_2d_body_entered() -> void:
	get_tree().change_scene_to_file("res://Levels/GameOver.tscn")
	pass # Replace with function body.
