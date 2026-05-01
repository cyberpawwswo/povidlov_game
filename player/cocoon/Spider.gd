extends CharacterBody2D

enum State { DESCENDING, WALKING, ATTACKING, FALLING }

@export var descend_speed := 140.0
@export var walk_speed := 120.0
@export var gravity := 1400.0
@export var attack_speed := 220.0
@export var attack_distance := 34.0
@export var direct_attack_x_tolerance := 18.0

var state: State = State.DESCENDING

var anchor_point: Vector2
var platform_top_y := 0.0
var target: Node2D

var _web_cut := false
var _web_line: Line2D


func _ready() -> void:
	add_to_group("spider")
	if anchor_point == Vector2.ZERO:
		anchor_point = global_position

	_web_line = Line2D.new()
	_web_line.width = 2.0
	_web_line.default_color = Color(0.95, 0.95, 0.95, 1.0)
	_web_line.z_index = -10
	add_child(_web_line)
	_update_web_line()


func _physics_process(delta: float) -> void:
	if target != null and state == State.DESCENDING and not _web_cut:
		if abs(global_position.x - target.global_position.x) <= direct_attack_x_tolerance:
			state = State.ATTACKING

	match state:
		State.DESCENDING:
			velocity = Vector2(0.0, descend_speed)
			_update_web_line()
			global_position += velocity * delta
			if global_position.y >= platform_top_y:
				global_position.y = platform_top_y
				state = State.WALKING

		State.WALKING:
			_web_line.visible = true
			_update_web_line()
			if target != null:
				var dx := target.global_position.x - global_position.x
				if abs(dx) <= attack_distance:
					state = State.ATTACKING
				else:
					global_position.x += sign(dx) * walk_speed * delta
			global_position.y = platform_top_y

		State.ATTACKING:
			_web_line.visible = true
			_update_web_line()
			if target == null:
				state = State.WALKING
				return
			var to_t := target.global_position - global_position
			if to_t.length() <= attack_distance:
				velocity = Vector2.ZERO
			else:
				velocity = to_t.normalized() * attack_speed
				global_position += velocity * delta

		State.FALLING:
			if not _web_cut:
				_web_cut = true
				_web_line.visible = false
			velocity.y += gravity * delta
			global_position += velocity * delta


func cut_web() -> void:
	if state == State.FALLING:
		return
	state = State.FALLING


func _update_web_line() -> void:
	if _web_line == null:
		return
	_web_line.clear_points()
	_web_line.add_point(to_local(anchor_point))
	_web_line.add_point(Vector2.ZERO)
