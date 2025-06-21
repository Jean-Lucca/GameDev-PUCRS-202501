extends CharacterBody2D
var target: Node2D
var player: CharacterBody2D
var camera: Camera2D
@onready var Explosion = preload("res://mobs/bloodFX/Explosion.tscn")
@export var speed: float = Globals.speed  # Speed at which the mob chases the player
@export var attack_range: float = 80.0  # Distance to stop and attack
var stop = false	
var barras = 10
var sequencia_barras = []  
var barraAtual = 0
var fase = 0
var lado_atual = ""  # vazio inicialmente

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
	if Globals.bossSpawnado == 1:
		barras = 5
		fase = 2
		print("primeiro boss")	
	if Globals.bossSpawnado == 2:
		barras = 7
		fase = 1
		print("segundo boss")	
	if Globals.bossSpawnado == 2:
		barras = 10
		fase = 0
		print("terceiro boss")	
		
	gerar_sequencia_barras(barras)
	mostrar_sequencia()
	
func getStart():
	return sequencia_barras[0]

func mostrar_sequencia():
	var uis = get_tree().get_nodes_in_group("HUD")
	if uis.size() > 0:
		var hud = uis[0]
		hud.fill_grid_with_arrows(sequencia_barras, barraAtual)
		
func popa_sequencia():
	var uis = get_tree().get_nodes_in_group("HUD")
	if uis.size() > 0:
		var hud = uis[0]
		hud.pop_first_arrow(barraAtual)

func gerar_sequencia_barras(qtd):
	sequencia_barras.clear()
	
	for i in range(qtd):
		if i == 0:
			if global_position.x < player.global_position.x:
				sequencia_barras.append("esquerda")
			else:
				sequencia_barras.append("direita")
		else:	
			if(randi() % 2 == 0):
				sequencia_barras.append("esquerda")		
			else:
				sequencia_barras.append("direita")
	print(sequencia_barras)
func _physics_process(delta):
	if not player or not is_instance_valid(player):
		return		
	move()
		
func stopMoving():
	pass
func startMoving():
	pass
	
func resetAttack():
	var sprite = $AnimatedSprite2D
	sprite.frame = 0
	
		
func move():
	var sprite = $AnimatedSprite2D
	var direction = player.global_position - global_position
	var distance = direction.length()
	var separation = Vector2.ZERO
	var min_distance_between_enemies = 100
	var enemies = get_tree().get_nodes_in_group("Enemies")
	
	for other in enemies:
		if other != self:
			var diff = global_position - other.global_position
			var dist = diff.length()
			if dist < min_distance_between_enemies and dist > 0:
				separation += diff.normalized() * ((min_distance_between_enemies - dist) / min_distance_between_enemies)

	if !stop:
		speed = Globals.speed
		if distance > attack_range:
			direction = direction.normalized()
			velocity = direction * speed				
			velocity += separation * speed  # força de separação proporcional	
			if velocity.x < 0:
				sprite.animation = "walk"
				sprite.flip_h = true
			elif velocity.x > 0:
				sprite.animation = "walk"
			sprite.play()
			move_and_slide()
		else:
			velocity = Vector2.ZERO
			move_and_slide()
			sprite.animation = "attack"
			sprite.play()			
			if(sprite.frame == 9):
				player.take_damage()		
	else:
		speed = 0
	global_position.y = Globals.player.position.y  - 90
		
func die(wind_slash = false):
	var sprite = $AnimatedSprite2D
	camera.shake()
	var count = player.getAttacks()		
	if wind_slash:
		queue_free()
	
	if sistema_barra(sprite):		
		return
	if fase < 2 && barraAtual >= 9:
		fase += 1
		print(fase)
		barraAtual = 0
		barras = 10
		gerar_sequencia_barras(barras)
		mostrar_sequencia()
		return
	else:
		if Globals.bossSpawnado == 3:
			get_tree().call_deferred("change_scene_to_file", "res://Levels/YouWin.tscn")
			return
		
	var explosion1 = Explosion.instantiate()  # Preload this scene
	get_parent().add_child(explosion1)
	explosion1.global_position = global_position  # Match position
	explosion1.pop_explosion()
	queue_free()
	get_tree().call_group("HUD", "update_score")
	get_tree().call_group("HUD", "update_double_score")
	
		
func sistema_barra(sprite):		
	var tweenRodou = false
	if barras > 1:	
		resetAttack()
		if sequencia_barras[barraAtual + 1] == "direita":  #direita			
			pop_tween(Vector2(player.position.x + 30, self.position.y - 40 * 2), 0.3)			
			tweenRodou = true		
			print("deve ir para a direita")
		elif  sequencia_barras[barraAtual + 1] == "esquerda":
			pop_tween(Vector2(player.position.x - 280, self.position.y - 40 * 2), 0.3)
			tweenRodou = true
			print("deve ir para a esquerda")

		sprite.flip_h = !sprite.flip_h
		popa_sequencia()
		barraAtual += 1
		barras = barras - 1				
		return true
	popa_sequencia()
	return false
	
func pop_tween(move_target, move_duration):
	var distance = global_position.distance_to(move_target)
	var floatymove_duration = distance / 400
	stopMoving()
	var tween := get_tree().create_tween()	
	tween.set_ignore_time_scale(true)
	tween.tween_property(self, "global_position", move_target, floatymove_duration)\
		.set_trans(Tween.TRANS_LINEAR)
	
	await get_tree().create_timer(0.2).timeout	
	startMoving()
			
	
func _on_progress_finished():
	queue_free()  # if you want to remove the instance after explosion
			
func _on_visible_on_screen_notifier_2d_screen_exited():	
	queue_free()
