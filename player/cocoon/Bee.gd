extends CharacterBody2D

@export var speed := 220.0
@export var impulse_decay := 1200.0
@export var max_impulse := 1600.0
@export var despawn_margin := 120.0
@export var attack_range := 44.0
@export var attack_damage := 5
@export var first_attack_delay := 0.2
@export var attack_interval := 0.8

var target: Node2D
var impulse: Vector2 = Vector2.ZERO
var _despawn_when_offscreen := false

var _attack_cd := 0.0
var _attack_first_pending := true


func _ready() -> void:
	add_to_group("Bee")


func add_impulse(v: Vector2) -> void:
	impulse += v
	_despawn_when_offscreen = true


func _physics_process(delta: float) -> void:
	impulse = impulse.move_toward(Vector2.ZERO, impulse_decay * delta)
	if impulse.length() > max_impulse:
		impulse = impulse.normalized() * max_impulse

	var base_velocity := Vector2.ZERO
	var can_attack := false
	if target != null:
		var to_t := target.global_position - global_position
		var dist := to_t.length()
		can_attack = dist <= attack_range
		if dist > 0.001:
			base_velocity = to_t.normalized() * speed

	velocity = base_velocity + impulse
	move_and_slide()

	if target != null:
		if can_attack:
			if _attack_first_pending and _attack_cd <= 0.000001:
				_attack_cd = first_attack_delay
				_attack_first_pending = false
			_tick_attack(delta)
		else:
			_reset_attack_schedule()

	if _despawn_when_offscreen:
		var r := get_viewport().get_visible_rect()
		r = r.grow(despawn_margin)
		if not r.has_point(global_position):
			print("Bee despawned (offscreen): ", name, " at ", global_position)
			queue_free()


func _reset_attack_schedule() -> void:
	_attack_first_pending = true
	_attack_cd = 0.0


func _tick_attack(delta: float) -> void:
	if target == null:
		return
	if not target.has_method("take_damage"):
		return

	_attack_cd -= delta
	if _attack_cd > 0.0:
		return

	target.call("take_damage", attack_damage)
	_attack_cd = attack_interval
