extends Node2D

@export var player: CharacterBody2D
@export var scene_limit: Marker2D
@export var mob_scene: PackedScene
@export var current_scene: Node2D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().call_group("Player","print_position")
	current_scene = get_child(1)
	player = current_scene.get_node("AnimPlayer")
	scene_limit = current_scene.get_node("SceneLimit")
	
	var mob = mob_scene.instantiate();
	var path_follow = $MobLeft/MobPath
	path_follow.progress = 0  # Or some start point on the path
	path_follow.add_child(mob)
	add_child(mob)
	
	var mob2 = mob_scene.instantiate();
	var path_follow2 = $MobRight/MobPath
	path_follow2.progress = 0  # Or some start point on the path
	path_follow2.add_child(mob2)
	add_child(mob2)
	
	$BackgroundMusic.play()
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
	$MobLeft/MobPath.progress += 100 * delta  # Adjust speed
	$MobRight/MobPath.progress += 100 * delta  # Adjust speed
