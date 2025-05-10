extends CharacterBody2D

@export var speed := 300.0
@export var jump_speed := -1000.0
@export var gravity := 2500.0

@onready var sprite = $PlayerSprite
@onready var jump_sound = $JumpSound
@export var bullet : PackedScene
@export var enemy_indicator: PackedScene  # Cena do indicador
@export var attack_range := 300.0
@onready var line_indicator = Line2D.new()  # Create the Line2D node
var indicators = {}  # Dicionário para rastrear indicadores por inimigo
var facing_dir := 1  # 1 = right, -1 = left
@onready var hit_sound = $HitSound


func _ready():
	add_to_group("AnimPlayer")
	line_indicator.visible = true

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
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		
		var to_enemy = enemy.global_position - global_position
		var horizontal_ok = (dir == 1 and to_enemy.x > 0) or (dir == -1 and to_enemy.x < 0)
		var vertical_ok = abs(to_enemy.y) < 50  # Tolerable vertical margin
		var range_ok = to_enemy.length() < attack_range

		if horizontal_ok and vertical_ok and range_ok:
			# If conditions are met, draw a line to the enemy
			line_indicator.visible = true  # Show the line
			line_indicator.clear_points()  # Clear any previous lines
			line_indicator.add_point(global_position)  # Start point (player)
			line_indicator.add_point(enemy.global_position)  # End point (enemy)
			return enemy  # Return the first enemy that matches the criteria

	# If no enemy found, hide the line
	line_indicator.visible = false
	return null

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
	# move_8way(delta)
	move_side(delta)
	
	#if position.y >= 1200:
		#get_tree().change_scene_to_file("res://scenes/GameOver.tscn")


func _on_area_2d_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Levels/GameOver.tscn")
	pass # Replace with function body.
