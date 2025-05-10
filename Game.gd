extends Node2D

@export var player: CharacterBody2D
@export var scene_limit: Marker2D
@export var mob_scene: PackedScene
@export var current_scene: Node2D = null
var spawn_timer : float = 0.0
var spawn_interval : float = 2.0  # Spawn mobs every 5 seconds

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().call_group("Player","print_position")
	current_scene = get_child(1)
	player = current_scene.get_node("AnimPlayer")
	scene_limit = current_scene.get_node("SceneLimit")
	
	#$BackgroundMusic.play()
	AudioServer.set_bus_volume_linear(1, 0.3)
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if scene_limit == null:
		player = current_scene.get_node("AnimPlayer")
		scene_limit = current_scene.get_node("SceneLimit")
	
	if player.position.y > scene_limit.position.y:
		get_tree().change_scene_to_file("res://Levels/GameOver.tscn")
		
	if Input.is_action_just_pressed("go_to_level_2"):
		call_deferred("goto_scene", "res://Levels/Level2.tscn")
		
func goto_scene(path: String) -> void:
	print("Total children: " + str(get_child_count()))
	current_scene.free()
	var res := load(path)
	current_scene = res.instantiate()
	add_child(current_scene)
	player = current_scene.get_node("AnimPlayer")
	scene_limit = current_scene.get_node("SceneLimit")
	
func _process(delta):
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_mobs()
		spawn_timer =0.0
	pass
	#$MobLeft/MobPath.progress += 100 * delta  # Adjust speed
	#$MobRight/MobPath.progress += 100 * delta  # Adjust speed
	
func spawn_mobs():
	var screen_size = get_viewport_rect().size
	var screen_half_width = screen_size.x / 2
	var camera_pos = player.global_position
	var initial_y_position = 450  # Or store once if fixed
	
	# LEFT MOB
	var mob = mob_scene.instantiate()
	mob.add_to_group("Enemies")
	var left_spawn_pos = Vector2(camera_pos.x - screen_half_width + 50, initial_y_position)
	mob.global_position = left_spawn_pos
	current_scene.add_child(mob)
	
	var sprite = mob.get_node("AnimatedSprite2D")
	sprite.animation = "walk_right"
	sprite.play()

	# RIGHT MOB
	var mob2 = mob_scene.instantiate()
	mob2.add_to_group("Enemies")
	var right_spawn_pos = Vector2(camera_pos.x + screen_half_width - 50, initial_y_position)
	mob2.global_position = right_spawn_pos

	var sprite2 = mob2.get_node("AnimatedSprite2D")
	sprite2.animation = "walk_left"
	sprite2.play()
	current_scene.add_child(mob2)
