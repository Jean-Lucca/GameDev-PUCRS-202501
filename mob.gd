extends CharacterBody2D
var target: Node2D
#@onready var animation_player = $mob
#@onready var sprite = $Sprite2D
var player: CharacterBody2D
@export var speed: float = 200.0  # Speed at which the mob chases the player
@export var attack_range: float = 50.0  # Distance to stop and attack

func _ready():
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0]
		
		
func _physics_process(delta):
	if not player or not is_instance_valid(player):
		return

	var sprite = $AnimatedSprite2D
	var direction = player.global_position - global_position
	var distance = direction.length()

	if distance > attack_range:
		direction = direction.normalized()
		velocity = direction * speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		move_and_slide()
		#sprite.animation = "attack"
		sprite.play()
	
func _on_body_entered(body: Node) -> void:	
	if body.name == "Anim_Player":  
		print("Collided with Player!")
		queue_free() 
		
func die():
	_on_visible_on_screen_notifier_2d_screen_exited()
			
func _on_visible_on_screen_notifier_2d_screen_exited():	
	queue_free()
