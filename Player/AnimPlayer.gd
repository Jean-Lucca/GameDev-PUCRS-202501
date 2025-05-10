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
		facing_dir = sign(vel)  # Update facing direction based on input
		print(facing_dir)
	if Input.is_action_just_pressed("left") || Input.is_action_just_pressed("right"):		
		var enemy_hit = detect_enemy_in_direction(facing_dir)
		setAnim(facing_dir)
		if enemy_hit:
			print("Hit enemy: ", enemy_hit.name)
			get_tree().call_group("HUD", "update_score")
			hit_sound.play()
			enemy_hit.die()  # Supondo que seu inimigo tenha esse método
		else:
			print("No enemy hit")	

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
	var enemies = get_tree().get_nodes_in_group("Enemies")
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
