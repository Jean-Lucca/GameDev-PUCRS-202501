extends Node2D

@export var player: CharacterBody2D
@export var camera: Camera2D
@export var scene_limit: Marker2D
@export var mob_scene: PackedScene
@export var current_scene: Node2D = null
@onready var limit_break: Node2D = null
@onready var Spawn_esquerda = $SpawnEsquerda
@onready var Spawn_direita = $SpawnDireita
var mob_boss = load("res://mobs/mob_boss/mob_boss.tscn")
var mob_double = load("res://mobs/mob_double/mob_double.tscn")
var mob_range = load("res://mobs/mob_range/mob_range.tscn")
var spawn_timer : float = 0.0
var spawn_interval : float = 0.0  # Spawn mobs every 5 seconds
var bpm: float = 120.0
var time_left := 0.0 # 300.0
var time_inverval := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().call_group("Player","print_position")
	current_scene = get_child(1)
	player = current_scene.get_node("AnimPlayer")
	camera = player.get_node("Camera2D")
	camera.add_to_group("Camera")
	#camera.zoom = Vector2(0.4,0.4)
	scene_limit = current_scene.get_node("SceneLimit")
	bpm = 120.0  # Set your music's BPM
	spawn_interval = 60.0 / bpm
	spawn_timer = 0.0
	$BackgroundMusic.play()
	AudioServer.set_bus_volume_linear(1, 0.3)
		
func start_spawning():
	spawn_timer = 0.0

func _physics_process(delta: float) -> void:
	if scene_limit == null:
		player = current_scene.get_node("AnimPlayer")
		scene_limit = current_scene.get_node("SceneLimit")
	
	if player.position.y > scene_limit.position.y:
		get_tree().change_scene_to_file("res://Levels/GameOver.tscn")	
		
func goto_scene(path: String) -> void:
	print("Total children: " + str(get_child_count()))
	current_scene.free()
	var res := load(path)
	current_scene = res.instantiate()
	add_child(current_scene)
	player = current_scene.get_node("AnimPlayer")
	scene_limit = current_scene.get_node("SceneLimit")
	
func _process(delta):
	Spawn_esquerda.global_position = Vector2(player.global_position.x - 800, 0)
	Spawn_direita.global_position = Vector2(player.global_position.x + 800, 0)
	time_left -= delta			
	Globals.timer = time_left
	time_inverval += delta
	if (time_left <= 0):
		time_left = 0
		#get_tree().change_scene_to_file("res://Levels/YouWin.tscn")
	
	var time_label = get_node("HUD/TimerLabel")
	if (time_label):
		var minutes = int(time_left) / 60
		var seconds = int(time_left) % 60
		time_label.text = "%02d:%02d" % [minutes, seconds]	
	
	# Increment spawn timer
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_mobs()
		spawn_timer = fmod(spawn_timer, spawn_interval)  # Keep timer in sync with beats
		start_spawning()
		
	
func spawn_mobs() -> void:
	var screen_size = get_viewport_rect().size
	var screen_half_width = screen_size.x / 2
	var camera_pos = player.global_position
	var initial_y_position = 450  
	var count = get_tree().get_node_count_in_group("Enemies")	
	
	if count < Globals.inimigosMax:			
		spawn_enemy(Vector2(Spawn_esquerda.position.x + randf_range(-20, 20), initial_y_position))
		spawn_enemy(Vector2(Spawn_direita.position.x + randf_range(-20, 20), initial_y_position))
		
func spawn_enemy(from_position: Vector2):
	var count = get_tree().get_node_count_in_group("Boss")	
	if(count > 0):
		return		
		
	var mob_instance = null
	
	if time_inverval >= 30:
		mob_instance = mob_range.instantiate()
		time_inverval = 0.0
	else:		
		if randf() < 0.8:
			mob_instance = mob_double.instantiate()
			mob_instance.add_to_group("Enemies")
		else:
			mob_instance = mob_scene.instantiate()
			mob_instance.add_to_group("Enemies")
	
	if time_left <= 0:
		mob_instance = mob_boss.instantiate()
		mob_instance.add_to_group("Enemies")
		mob_instance.add_to_group("Boss")
			
	var spawn_pos = Vector2(from_position.x + randf_range(-20, 20), Globals.player.position.y  - 90)
	mob_instance.global_position = spawn_pos	
	current_scene.add_child(mob_instance)	
	var sprite = mob_instance.get_node("AnimatedSprite2D")
	sprite.play()
