extends CharacterBody2D

@export var speed := 220.0
@export var impulse_decay := 1200.0
@export var max_impulse := 1600.0
@export var despawn_margin := 120.0
@export var attack_range := 44.0
@export var attack_damage := 5
@export var first_attack_delay := 0.2
@export var attack_interval := 0.8
@export var random_flight_speed := 180.0
@export var random_turn_interval_min := 0.35
@export var random_turn_interval_max := 0.9
@export var psh_animation_impulse_threshold := 30.0

var target: Node2D
var impulse: Vector2 = Vector2.ZERO
var _despawn_when_offscreen := false
var _random_flight_enabled := false
var _random_flight_direction := Vector2.RIGHT
var _random_turn_timer := 0.0
var _facing_right := true
var _current_anim: StringName = &""

var _attack_cd := 0.0
var _attack_first_pending := true

@onready var _anim_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	add_to_group("Bee")
	_update_animation()


func add_impulse(v: Vector2) -> void:
	impulse += v
	_despawn_when_offscreen = true


func enable_random_flight() -> void:
	target = null
	_reset_attack_schedule()
	_random_flight_enabled = true
	_pick_random_flight_direction()


func _pick_random_flight_direction() -> void:
	var angle := randf_range(0.0, TAU)
	_random_flight_direction = Vector2.RIGHT.rotated(angle)
	_random_turn_timer = randf_range(random_turn_interval_min, random_turn_interval_max)


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
	elif _random_flight_enabled:
		_random_turn_timer -= delta
		if _random_turn_timer <= 0.0:
			_pick_random_flight_direction()
		base_velocity = _random_flight_direction * random_flight_speed

	velocity = base_velocity + impulse
	_update_animation()
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


func _update_animation() -> void:
	var vx := velocity.x
	if absf(vx) > 0.001:
		_facing_right = vx > 0.0

	var anim_name: StringName
	var is_psh := impulse.length() >= psh_animation_impulse_threshold
	if is_psh:
		anim_name = (&"bz_psh_left") if _facing_right else (&"bz_psh_right")
	else:
		anim_name = (&"bz_right") if _facing_right else (&"bz_left")

	_play_anim_if_exists(anim_name)


func _play_anim_if_exists(anim_name: StringName) -> void:
	if _anim_player == null:
		return
	if _current_anim == anim_name and _anim_player.is_playing():
		return
	var resolved := anim_name
	if not _anim_player.has_animation(resolved) and resolved == &"bz_psh_right" and _anim_player.has_animation(&"bz_psh_righ"):
		# Backward compatibility for possible typo in animation name.
		resolved = &"bz_psh_righ"
	if not _anim_player.has_animation(resolved):
		return
	_current_anim = resolved
	_anim_player.play(resolved)


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
