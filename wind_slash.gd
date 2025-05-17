extends Node2D

@export var speed := 400
@export var direction := Vector2.RIGHT
@onready var area = $Area2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	anim.play("wind_slash") 
	area.connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("Enemies"):
		print("Mob atingido pelo Wind Slash!")
		body.die() 

func _physics_process(delta):
	position += direction.normalized() * speed * delta
