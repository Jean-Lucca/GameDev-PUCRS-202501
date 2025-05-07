extends CharacterBody2D

@export var speed := 300.0
@export var jump_speed := -1000.0
@export var gravity := 2500.0

@onready var sprite = $PlayerSprite
@onready var jump_sound = $JumpSound
@export var bullet : PackedScene

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
	var jump := Input.is_action_just_pressed('ui_select')
	
	if is_on_floor() and jump:
		velocity.y = jump_speed
		get_tree().call_group("HUD", "update_score")
		jump_sound.pitch_scale = randf_range(0.8,1.2)
		jump_sound.play()
	velocity.x = vel * speed
	
	if Input.is_action_just_pressed("click"):
		print("Shoot")
		var b := bullet.instantiate()
		b.position = global_position
		owner.add_child(b)

func move_side(delta):
	velocity.y += gravity * delta
	get_side_input()
	animate_side()
	move_and_slide()

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
