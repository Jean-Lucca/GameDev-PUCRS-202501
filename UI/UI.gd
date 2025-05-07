extends Node2D

var total: float = 0
const SPEED : int = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_score(total)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	total += delta
	update_score(total)
	
func update_score(current_score: float) -> void:
	$Score.text = str(current_score) 

func _on_timer_timeout() -> void:
	pass
	# $Score.visible = !$Score.visible
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("right"):
		print("Right action!")
		
func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("right"):
		position.x += SPEED * delta
	elif Input.is_action_pressed("left"):
		position.x -= SPEED * delta
	if Input.is_action_pressed("down"):
		position.y += SPEED * delta
	elif Input.is_action_pressed("up"):
		position.y -= SPEED * delta
