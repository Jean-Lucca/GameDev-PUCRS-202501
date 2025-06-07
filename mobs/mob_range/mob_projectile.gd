extends Node2D

@export var speed := 200
@export var direction := Vector2.RIGHT
@onready var area = $Area2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	self.add_to_group("purple_arrow")
	area.connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	print("checkbody")
	if body.is_in_group("AnimPlayer"):
		body.take_damage()
		queue_free()

func die(diefr):
	queue_free()

func _physics_process(delta):
	position += direction.normalized() * speed * delta
	
func _on_visible_on_screen_notifier_2d_screen_exited():	
	queue_free()	
