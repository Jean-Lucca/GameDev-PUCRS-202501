extends CharacterBody2D
var target: Node2D
var player: CharacterBody2D
var camera: Camera2D
@export var speed: float = 200.0  # Speed at which the mob chases the player
@export var attack_range: float = 50.0  # Distance to stop and attack
var stop = false	

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
	stop = true
func startMoving():
	stop = false
		
func move():
	var sprite = $AnimatedSprite2D
	var direction = player.global_position - global_position
	var distance = direction.length()
	
	if !stop:
		speed = 300
		if distance > attack_range:
			direction = direction.normalized()
			velocity = direction * speed					
			if velocity.x < 0:
				sprite.animation = "walk_left"
			elif velocity.x > 0:
				sprite.animation = "walk_right"
			sprite.play()
			move_and_slide()
		else:
			velocity = Vector2.ZERO
			move_and_slide()
			sprite.animation = "attack"
			sprite.play()			
			if(sprite.frame == 5):
				player.take_damage()		
	else:
		speed = 0
		
func die():
	var sprite = $AnimatedSprite2D
	camera.shake()
	
	if sprite.material is ShaderMaterial:
		sprite.material.set_shader_parameter("progress", 0.0)
		var tween = create_tween()
		tween.tween_property(sprite.material, "shader_parameter/progress", 1.0, 0.3)
		tween.connect("finished", Callable(self, "_on_progress_finished"))		
			
func _on_progress_finished():
	queue_free()  # if you want to remove the instance after explosion
			
func _on_visible_on_screen_notifier_2d_screen_exited():	
	queue_free()
