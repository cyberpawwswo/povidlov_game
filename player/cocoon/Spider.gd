extends CharacterBody2D

enum State { DESCENDING, WALKING, ATTACKING, FALLING }

@onready var animation_tree: AnimationTree = $AnimationPlayer/AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
@export var descend_speed := 140.0
@export var walk_speed := 120.0
@export var gravity := 1400.0
@export var attack_speed := 220.0
@export var attack_distance := 34.0
@export var direct_attack_x_tolerance := 18.0
@export var attack_damage := 10
@export var first_attack_delay := 0.1
@export var attack_interval := 0.5


var state: State = State.DESCENDING

var anchor_point: Vector2
var platform_top_y := 0.0
var target: Node2D

var _web_cut := false
var _web_line: Line2D

var _attack_cd := 0.0
var _attack_first_pending := true
@onready var _screen_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D


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
	if _screen_notifier != null:
		_screen_notifier.screen_exited.connect(_on_screen_exited)


func _on_screen_exited() -> void:
	if state == State.FALLING:
		queue_free()


func _physics_process(delta: float) -> void:
	var prev_state := state

	match state:
		State.DESCENDING:
			velocity = Vector2(0.0, descend_speed)
			_update_web_line()
			global_position += velocity * delta
			if global_position.y >= platform_top_y:
				global_position.y = platform_top_y
				state = State.WALKING
			state_machine.travel("walk_down")

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
			var in_range := _is_in_attack_range(to_t)
			if not in_range:
				_reset_attack_schedule()
				velocity = to_t.normalized() * attack_speed
				global_position += velocity * delta
			else:
				_tick_attack(delta)
				# keep pressing into range while descending from above
				if global_position.y > target.global_position.y:
					velocity = Vector2(0.0, -absf(attack_speed))
					global_position += velocity * delta
				else:
					velocity = Vector2.ZERO

		State.FALLING:
			if not _web_cut:
				_web_cut = true
				_web_line.visible = false
			velocity.y += gravity * delta
			global_position += velocity * delta
			state_machine.travel("falling")

	if prev_state != state and state == State.ATTACKING:
		_arm_first_attack()


func cut_web() -> void:
	if state == State.FALLING:
		return
	state = State.FALLING


func _is_in_attack_range(to_target: Vector2) -> bool:
	if target == null:
		return false
	if abs(global_position.y - platform_top_y) > 0.5:
		return to_target.length() <= attack_distance
	return absf(to_target.x) <= attack_distance


func _arm_first_attack() -> void:
	_attack_first_pending = true
	_attack_cd = first_attack_delay


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
	if _attack_first_pending:
		_attack_first_pending = false
	_attack_cd = attack_interval


func _update_web_line() -> void:
	if _web_line == null:
		return
	_web_line.clear_points()
	_web_line.add_point(to_local(anchor_point))
	_web_line.add_point(Vector2.ZERO)
