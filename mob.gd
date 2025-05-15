extends CharacterBody2D
var target: Node2D
#@onready var animation_player = $mob
#@onready var sprite = $Sprite2D
var player: CharacterBody2D
var camera: Camera2D
@export var speed: float = 200.0  # Speed at which the mob chases the player
@export var attack_range: float = 35.0  # Distance to stop and attack
var stop = false	

func _ready():
	var players = get_tree().get_nodes_in_group("Player")
	var cameras = get_tree().get_nodes_in_group("Camera")
	if players.size() > 0:
		player = players[0]
	if cameras.size() > 0:
		camera = cameras[0]
		
		
func _physics_process(delta):
	if not player or not is_instance_valid(player):
		return
	move()
	
func stopMoving():
	stop = true
func startMoving():
	stop = true
		
func move():
	var sprite = $AnimatedSprite2D
	var direction = player.global_position - global_position
	var distance = direction.length()
	
	if !stop:
		speed = 300
		if distance > attack_range:
			direction = direction.normalized()
			velocity = direction * speed		
			move_and_slide()
		else:
			velocity = Vector2.ZERO
			move_and_slide()
			sprite.animation = "attack"
			sprite.play()
			print(sprite.frame)
			if(sprite.frame == 5):
				player.take_damage()
	else:
		speed = 0
	
func _on_body_entered(body: Node) -> bool:	
	if body.name == "Anim_Player":  
		print("Collided with Player!")
		queue_free() 
		return true;
	return false
		
func die():
	camera.shake()	
	_on_visible_on_screen_notifier_2d_screen_exited()
			
func _on_visible_on_screen_notifier_2d_screen_exited():	
	queue_free()
