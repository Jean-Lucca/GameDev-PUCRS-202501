extends CharacterBody2D

@export var speed := 300.0
@export var jump_speed := -1000.0
@export var gravity := 2500.0

@onready var sprite = $PlayerSprite
@onready var jump_sound = $JumpSound
@export var bullet : PackedScene
@export var enemy_indicator: PackedScene  # Cena do indicador
@export var attack_range := 200.0
@onready var line_indicator = Line2D.new()  # Create the Line2D node
@onready var range_bar = $EnemyRangeBar
@onready var range_bar_left = $EnemyRangeBarLeft
var indicators = {}  # Dicionário para rastrear indicadores por inimigo
var facing_dir := 1  # 1 = right, -1 = left
@onready var hit_sound = $HitSound
@onready var life = 3
var is_invincible = false
var invincibility_time = 0.0
const INVINCIBILITY_DURATION = 3.0

func _ready():
	add_to_group("AnimPlayer")
	line_indicator.visible = false

func animate_side():
	if velocity.x > 0:
		sprite.play("right")
	elif velocity.x < 0:
		sprite.play("left")
	else:
		sprite.stop()
		
func get_side_input():
	velocity.x = 0
	var vel := Input.get_axis("left", "right")
	if vel != 0:
		facing_dir = sign(vel)
		print(facing_dir)
	
	if Input.is_action_just_pressed("left") || Input.is_action_just_pressed("right"):
		var enemy_hit = detect_enemy_in_direction(facing_dir)
		setAnim(facing_dir)

		if enemy_hit:
			print("Hit enemy: ", enemy_hit.name)
			get_tree().call_group("HUD", "update_score")
			hit_sound.play()

			var old_x = global_position.x
			var enemy_x = enemy_hit.global_position.x
			
			enemy_hit.die()

			# Move player to enemy's X position (only X)
			#global_position.x = enemy_x 

			# Calculate how much the player moved
			var delta_x = enemy_x - old_x
			# Move enemies behind the killed one
			push_enemies_back(enemy_x, delta_x, facing_dir)
		else:
			print("No enemy hit")

func push_enemies_back(origin_x: float, delta_x: float, facing_dir: int):
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		if enemy != null and enemy.is_inside_tree() and enemy.has_method("global_position"):
			var enemy_x = enemy.global_position.x

			# Check if the enemy is behind the origin (based on facing direction)
			if (facing_dir == 1 and enemy_x > origin_x) or (facing_dir == -1 and enemy_x < origin_x):
				continue  # This one is in front of or same as the hit enemy

			# Push the enemy back by delta_x (same distance the player traveled)
			enemy.knockback_offset -= facing_dir * (delta_x + 500)


func move_side(delta):
	velocity.y += gravity * delta
	get_side_input()
	animate_side()
	move_and_slide()

func detect_enemy_in_direction(dir: int) -> Node2D:
	var enemies = get_tree().get_nodes_in_group("Enemies")
	var found_enemy = null
	var found = false

	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue

		var to_enemy = enemy.global_position - global_position
		var horizontal_ok = (dir == 1 and to_enemy.x > 0) or (dir == -1 and to_enemy.x < 0)
		var vertical_ok = abs(to_enemy.y) < 50  # margem vertical
		var range_ok = to_enemy.length() < attack_range

		if horizontal_ok and vertical_ok and range_ok:
			found_enemy = enemy
			found = true
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
		range_bar.color = Color(1, 0, 0, 0.8)  # vermelho
	else:
		range_bar.color = Color(0.5, 0.5, 0.5, 0.5)  # cinza

	# Atualiza cor da barra da esquerda
	if left_detected:
		range_bar_left.color = Color(0, 0.4, 1, 0.8)  # azul
	else:
		range_bar_left.color = Color(0.5, 0.5, 0.5, 0.5)  # cinza


func print_position():
	print(position)

func get_8way_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	
func animate():
	if velocity.x > 0:
		sprite.play("right")
	elif velocity.x < 0:
		sprite.play("left")
	elif velocity.y > 0:
		sprite.play("down")
	elif velocity.y < 0:
		sprite.play("up")
	else:
		sprite.stop()
		
func setAnim(dir: int):
	if dir == -1:
		sprite.play("left")
	if dir == 1: 
		sprite.play("right")		
		
func move_8way(delta): 
	get_8way_input()
	animate()
	var collision_info = move_and_collide(velocity * delta)
	if collision_info:
		velocity = velocity.bounce(collision_info.get_normal())
		move_and_collide(velocity * delta * 10)
	#move_and_slide()

func _physics_process(delta):
	if is_invincible:
		invincibility_time -= delta
		if invincibility_time <= 0:
			is_invincible = false
			$PlayerSprite.modulate = Color(1, 1, 1)  # volta ao normal
	# move_8way(delta)
	move_side(delta)
	check_enemy_collisions()
	detect_enemy_in_direction_delta()
	
	#if position.y >= 1200:
		#get_tree().change_scene_to_file("res://scenes/GameOver.tscn")

func check_enemy_collisions():
	var enemies = get_tree().get_nodes_in_group("Enemies")
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		if global_position.distance_to(enemy.global_position) < 40:
			# Arbitrary hit radius; adjust as needed
			take_damage()
			break

func take_damage():
	if is_invincible:
		return  # ignora dano
	life -= 1
	get_tree().call_group("HUD", "update_vida")
	is_invincible = true
	invincibility_time = INVINCIBILITY_DURATION
	$PlayerSprite.modulate = Color(1, 1, 1, 0.5)  # visual: fica meio transparente
	print("Hit by enemy! Remaining life:", life)
	hit_sound.play()

	if life <= 0:
		get_tree().change_scene_to_file("res://Levels/GameOver.tscn")

func _on_area_2d_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Levels/GameOver.tscn")
	pass # Replace with function body.
