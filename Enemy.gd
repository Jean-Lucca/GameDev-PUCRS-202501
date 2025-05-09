extends Area2D

# Exported variables for customization
@export var move_speed : float = 100.0
@export var attack_range : float = 50.0
@export var health : int = 1
@export var attack_direction : String = "left"  # Can be "left" or "right"

# Internal variables
var player : Node = null
var is_alive : bool = true

# Signals
signal enemy_defeated

func _ready():
    player = get_node("/root/Player")  # Adjust path as necessary
    set_position_based_on_side()

func _process(delta: float) -> void:
    if is_alive:
        move_towards_player(delta)

func set_position_based_on_side():
    if attack_direction == "left":
        position = Vector2(-attack_range, randf_range(100, 500))
    elif attack_direction == "right":
        position = Vector2(attack_range, randf_range(100, 500))

func move_towards_player(delta: float):
    if player:
        var direction = (player.position - position).normalized()
        var velocity = direction * move_speed
        position += velocity * delta

        # Check if the enemy is within attack range
        if position.distance_to(player.position) < attack_range:
            attack_player()

func attack_player():
    if is_alive:
        # Trigger attack animation
        $AnimatedSprite2D.play("attack")
        # Check for collision with player's attack area
        if $CollisionShape2D.get_overlapping_bodies().has(player):
            player.take_damage(1)  # Assuming the player has a take_damage method

func take_damage(amount: int):
    health -= amount
    if health <= 0:
        die()

func die():
    is_alive = false
    queue_free()  # Remove the enemy from the scene
    emit_signal("enemy_defeated")
