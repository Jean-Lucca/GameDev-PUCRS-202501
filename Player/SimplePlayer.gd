extends Sprite2D

@export var speed = 300
@export var rot_speed = 1.5

@onready var target = position

func _input(event):
	# Use is_action_pressed to only accept single taps as input instead of mouse drags.
	if event.is_action_pressed("click"):
		target = get_global_mouse_position()

func _physics_process(delta: float):
	# Selecionar um dos tipos de movimentação abaixo:
	move_8_way(delta)
	# move_tank(delta)
	# move_tank_with_mouse(delta)
	# move_with_click(delta)

func move_8_way(delta: float) -> void:
	# Movimento em 8 direções com WASD ou Setas
	var input_direction = Input.get_vector("left", "right", "up", "down")
	position += speed * input_direction.normalized() * delta
	
func move_tank(delta):
	# Movimento estilo tanque: rotação + frente/trás
	var rotation_direction = Input.get_axis("left", "right")
	var velocity = Input.get_axis("down", "up")
	rotation += rotation_direction * rot_speed * delta
	position += Vector2(velocity,0).rotated(rotation) * speed * delta
	
func move_tank_with_mouse(delta: float):
	# Movimento estilo tanque: rotação baseada na posição do mouse + frente/trás
	look_at(get_global_mouse_position())
	var velocity = Input.get_axis("down", "up")
	position += Vector2(velocity,0).rotated(rotation) * speed * delta
	
func move_with_click(delta: float) -> void:
	# Movimentação em direção ao clique do mouse
	var velocity = position.direction_to(target)
	# look_at(target)
	if position.distance_to(target) > 10:
		position += velocity * speed * delta
