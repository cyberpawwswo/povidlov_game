extends CharacterBody2D

@export var speed := 220.0
@export var impulse_decay := 1200.0
@export var max_impulse := 1600.0

var target: Node2D
var impulse: Vector2 = Vector2.ZERO


func _ready() -> void:
	add_to_group("Bee")


func add_impulse(v: Vector2) -> void:
	impulse += v


func _physics_process(delta: float) -> void:
	impulse = impulse.move_toward(Vector2.ZERO, impulse_decay * delta)
	if impulse.length() > max_impulse:
		impulse = impulse.normalized() * max_impulse

	var base_velocity := Vector2.ZERO
	if target != null:
		var to_t := target.global_position - global_position
		if to_t.length() > 0.001:
			base_velocity = to_t.normalized() * speed

	velocity = base_velocity + impulse
	move_and_slide()
