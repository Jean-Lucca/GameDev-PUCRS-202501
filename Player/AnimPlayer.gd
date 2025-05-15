extends CharacterBody2D

@export var gravity := 2500.0
@onready var sprite = $PlayerSprite
@export var attack_range := 200.0
@onready var range_bar = $EnemyRangeBar
@onready var range_bar_left = $EnemyRangeBarLeft
var facing_dir := 1  # 1 = right, -1 = left
@onready var hit_sound = $HitSound
@onready var life = 300000000
var is_invincible = false
var invincibility_time = 0.0
const INVINCIBILITY_DURATION = 1.5
var is_attacking = false

func _ready():
	add_to_group("AnimPlayer")

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

		if enemy_hit:
			get_tree().call_group("LimitBreak", "add_limit_break")
			get_tree().call_group("HUD", "update_score")
			hit_sound.play()
			var old_x = global_position.x
			var enemy_x = enemy_hit.global_position.x			
			enemy_hit.die()			
			global_position.x = move_toward(global_position.x, enemy_x, 1500 * delta) 
						
			var delta_x = enemy_x + old_x
			push_enemies_back(enemy_x, delta_x)
		else:
			print("No enemy hit")
				

func push_enemies_back(origin_x: float, delta_x: float):
	for enemy in get_tree().get_nodes_in_group("Enemies"):		
		var enemy_pos = enemy.global_position
		var enemy_x = enemy_pos.x
		
		enemy.stopMoving()
				
		var push_distance = 100.0
		if enemy_x < origin_x:			
			enemy.global_position.x -= push_distance
		else:		
			enemy.global_position.x += push_distance
				
		enemy.startMoving()


func move_side(delta):
	velocity.y += gravity * delta
	get_side_input(delta)
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

func animate():
	if detect_enemy_in_direction(facing_dir):
		if is_attacking && sprite.frame != 6:	
			return
	if !is_attacking:
		sprite.frame = 0
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

func _on_area_2d_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Levels/GameOver.tscn")
	pass # Replace with function body.
