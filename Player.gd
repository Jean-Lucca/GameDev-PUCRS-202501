extends Node2D

# Exported variables for customization
@export var attack_range : float = 50.0
@export var attack_cooldown : float = 0.5
@export var attack_damage : int = 10

# Internal variables
var last_attack_time : float = -1.0
var is_attacking : bool = false

# Input actions
enum AttackDirection { LEFT, RIGHT }
@export var left_attack_action : String = "attack_left"
@export var right_attack_action : String = "attack_right"

# Signals
signal attack_hit(direction : AttackDirection)

func _ready():
    # Initialize any necessary components or states
    pass

func _process(delta: float) -> void:
    # Check for attack input and handle accordingly
    if Input.is_action_just_pressed(left_attack_action):
        attempt_attack(AttackDirection.LEFT)
    elif Input.is_action_just_pressed(right_attack_action):
        attempt_attack(AttackDirection.RIGHT)

func attempt_attack(direction: AttackDirection) -> void:
    # Ensure there's no ongoing attack and cooldown has passed
    if is_attacking or (OS.get_ticks_msec() - last_attack_time) < attack_cooldown * 1000:
        return

    is_attacking = true
    last_attack_time = OS.get_ticks_msec()

    # Trigger attack animation (assuming an AnimatedSprite2D node is present)
    match direction:
        AttackDirection.LEFT:
            $AnimatedSprite2D.play("attack_left")
        AttackDirection.RIGHT:
            $AnimatedSprite2D.play("attack_right")

    # Detect and handle collisions with enemies
    var attack_area = get_attack_area(direction)
    var enemies_in_range = attack_area.get_overlapping_bodies()

    for enemy in enemies_in_range:
        if enemy.is_in_group("enemies"):
            enemy.take_damage(attack_damage)
            emit_signal("attack_hit", direction)

    # Reset attack state after animation finishes
    yield($AnimatedSprite2D, "animation_finished")
    is_attacking = false

func get_attack_area(direction: AttackDirection) -> Area2D:
    # Return the appropriate attack area based on direction
    match direction:
        AttackDirection.LEFT:
            return $AttackAreaLeft
        AttackDirection.RIGHT:
            return $AttackAreaRight
