extends CharacterBody2D

@onready var Explosion = preload("res://Player/aura.tscn")
@export var gravity := 2500.0
@onready var sprite = $PlayerSprite
@onready var buster_right = $Buster_interface
@onready var current_action = $CurrentAction
@export var attack_range :=  200.0
@export var wind_slash: PackedScene
@onready var camera = $Camera2D
var facing_dir := 1  # 1 = right, -1 = left
@onready var hit_sound = $HitSound
@onready var life = 5
var shader_material;
var is_invincible = false
var invincibility_time = 0.0
const INVINCIBILITY_DURATION = 1.5
var is_attacking = false
var nodes = null
var count_attacks = 0
@onready var slow_motion_timer = $Timer
@onready var miss_timer = $MissTimer
var can_attack := true
@onready var attack_cooldown_timer := Timer.new()
@onready var stop_timer = Timer.new()	

func _ready():
	shader_material = sprite.material as ShaderMaterial
	add_to_group("AnimPlayer")	
	var explosion1 = Explosion.instantiate()  # Preload this scene
	explosion1.global_position = global_position  # Match position
	explosion1.pop_aura()
	Globals.player = self
	buster_right.self_modulate.a = 0.5
	
func start_slow_motion():
	# Coloca o jogo em slow motion
	Engine.time_scale = 0.7  # Ajuste conforme o quanto quer deixar lento	
	slow_motion_timer.start()
	
func start_miss_timer():
	# Coloca o jogo em slow motion
	can_attack = false
	current_action.play("block")
	current_action.show()
	get_tree().call_group("HUD", "reset_score")
	miss_timer.start()

func _on_timer_timeout():
	# Retorna ao tempo normal após o tempo do timer
	Engine.time_scale = 1

func getAttacks():
	return count_attacks

func animate_side():
	if is_attacking:
		if sprite.frame != 6:
			return
		
	is_attacking = false
	
	if !is_attacking:
		sprite.frame = 0
		sprite.stop()	
		
func get_side_input(delta):
	if !can_attack:
		return
	#stop_timer.stop()
	velocity.x = 0
	var vel := Input.get_axis("left", "right")
	
	if vel != 0:
		sprite.flip_h = facing_dir == -1
		facing_dir = sign(vel)
	
	if Input.is_action_just_pressed("left") || Input.is_action_just_pressed("right"):
		startAllEnemy()
		var enemy_hit = detect_enemy_in_direction(facing_dir)
		setAnim(facing_dir)
		var pitch := randf_range(0.9, 1.3)
		hit_sound.pitch_scale = pitch
		hit_sound.play()
		
		if !enemy_hit:
			print("enemy not hit")
			current_action.play("block")
			# Começa o cooldown de ataque
			start_miss_timer()
			return
		
		if enemy_hit:														
			basic_attack(enemy_hit)													
			is_attacking = true
			get_tree().call_group("LimitBreak", "add_limit_break")
			count_attacks += 1			
		can_attack = false
		await get_tree().create_timer(0.05).timeout
		can_attack = true
func pop_limit_break():
	nodes = get_tree().get_nodes_in_group("LimitBreak")
	if nodes.size() > 0:
		if nodes[0].is_full():
			if Input.is_action_just_pressed("special"):
				get_tree().call_group("LimitBreak", "zero_limit_break")
				launch_wind_slash()
				print("is full")
				return true
	return false
		

func is_limit_break_full():
	nodes = get_tree().get_nodes_in_group("LimitBreak")
	if nodes.size() > 0:
		if nodes[0].is_full():
			$PlayerSprite.material.set_shader_parameter("aura_enabled", true)
		else:
			$PlayerSprite.material.set_shader_parameter("aura_enabled", false)

func basic_attack(enemy_hit):
	if enemy_hit == null:
		return	
		
	var enemy_x = 0;	
	if facing_dir == 1:
		enemy_x = enemy_hit.global_position.x - 10
	else:
		enemy_x = enemy_hit.global_position.x + 10
	
	#aposentado até chegar o inimigo boss
	#push_enemies_back(enemy_x)
	
	enemy_hit.die(false)

	var move_duration := 0.2
	var move_target := Vector2(enemy_x, global_position.y)	
	
	start_slow_motion()

	var tween := get_tree().create_tween()
	tween.tween_property(self, "global_position", move_target, move_duration)\
		.set_trans(Tween.TRANS_QUINT)\
		.set_ease(Tween.EASE_OUT)
	
	velocity = Vector2.ZERO	


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
	var push_distance = 150.0
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
		
		var direction = (enemy_pos - origin_x).normalized()
		var target_position = enemy_pos + direction * push_distance
		var target_x = enemy_pos.x - push_distance if enemy_pos.x < origin_x else enemy_pos.x + push_distance
		#var target_position = Vector2(target_x, enemy_pos.y)

		var tween := get_tree().create_tween()
		tween.tween_property(enemy, "global_position", target_position, duration)\
			.set_trans(Tween.TRANS_BACK)\
			.set_ease(Tween.EASE_OUT)

		tween.finished.connect(func():
			if is_instance_valid(enemy): 
				enemy.startMoving()
		)

func stopAllEnemy():
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		if enemy == null:
			continue
		
		enemy.stopMoving()
func startAllEnemy():
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		if enemy == null:
			continue
		enemy.startMoving()
		
func move_side(delta):
	velocity.y += gravity * delta
	get_side_input(delta)
	animate_side()
	pop_limit_break()
	move_and_slide()

func detect_enemy_in_direction(dir: int) -> CharacterBody2D:
	var enemies = get_tree().get_nodes_in_group("Enemies") + get_tree().get_nodes_in_group("purple_arrow")
	var found_enemy: CharacterBody2D = null
	var min_distance_sq = INF  # infinito inicialmente

	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue

		var enemy_body = enemy as CharacterBody2D
		if enemy_body == null:
			continue  # não é do tipo esperado

		var to_enemy = enemy_body.global_position - global_position
		var horizontal_ok = (dir == 1 and to_enemy.x > 0) or (dir == -1 and to_enemy.x < 0)
		var vertical_ok = abs(to_enemy.y) < 50  # margem vertical
		var distance_sq = to_enemy.length_squared()
		var range_ok = distance_sq < attack_range * attack_range

		if horizontal_ok and vertical_ok and range_ok:
			if distance_sq < min_distance_sq:
				min_distance_sq = distance_sq
				found_enemy = enemy_body

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
	
	if can_attack:
		if right_detected:
			current_action.show()
			buster_right.play("red_right")
			current_action.play("direita")
		else:
			if can_attack:
				buster_right.play("normal_right")

		# Atualiza cor da barra da esquerda
		if right_detected and left_detected:
			current_action.show()
			buster_right.play("red_blue")
			current_action.play("ed")
		elif right_detected:
			current_action.show()
			buster_right.play("red_right")
			current_action.play("direita")
		elif left_detected:
			current_action.show()
			buster_right.play("blue_left")
			current_action.play("esquerda")
		else:
			if can_attack:
				buster_right.play("normal_right")
				current_action.hide()
	

func animate():
	if detect_enemy_in_direction(facing_dir):		
		#if sprite.frame != 6:
			#return
		if !is_attacking:
			sprite.frame = 0
			Engine.time_scale = 1
			sprite.stop()	
		
func setAnim(dir: int):
	var animations = ["left","right","right2","right3","right4"]
	var index = randi() % animations.size()
	var random_anim = animations[index]
	if !is_attacking:
		if dir == -1:
			sprite.play(random_anim)
			sprite.flip_h = true
		if dir == 1: 
			sprite.play(random_anim)	
			sprite.flip_h = false
		
func _physics_process(delta):
	iframes(delta)
	#attack_zoom()
	move_side(delta)
	is_limit_break_full()
	detect_enemy_in_direction_delta()
	
func _on_stop_timer_timeout():
	startAllEnemy()  # retoma movimento de todos os inimigos

func take_damage():
	if is_invincible:
		return  # ignora dano
	life -= 1
	get_tree().call_group("HUD", "update_vida")
	is_invincible = true
	invincibility_time = INVINCIBILITY_DURATION
	$PlayerSprite.modulate = Color(1, 1, 1, 0.5)  # visual: fica meio transparente
	stopAllEnemy()  # para todos os inimigos	
	hit_sound.play()
	get_tree().call_group("HUD", "reset_score")
	camera.flash_red()
	if life <= 0:
		get_tree().change_scene_to_file("res://Levels/GameOver.tscn")
	
func heal_damage():
	life += 1
	get_tree().call_group("HUD", "update_vida")

	if life <= 0:
		get_tree().change_scene_to_file("res://Levels/GameOver.tscn")

				
func iframes(delta):
	if is_invincible:
		invincibility_time -= delta
		if invincibility_time <= 0:
			is_invincible = false
			$PlayerSprite.modulate = Color(1, 1, 1)  # volta ao normal

func _on_area_2d_body_entered() -> void:
	get_tree().change_scene_to_file("res://Levels/GameOver.tscn")
	pass # Replace with function body.


func _on_miss_timer_timeout():
	can_attack = true
	current_action.hide()
	pass # Replace with function body.
