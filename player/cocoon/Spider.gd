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
@export var walking_after_platform_touch := false
@export var platform_area: Area2D
@export var platform_touch_shape_names: Array[String] = ["CollisionShape2D", "CollisionShape2D2", "CollisionShape2D3"]
@export var platform_touch_foot_radius := 22.0
@export var max_descend_y := 1000000.0
@export var surface_alignment_offset_y := 0.0


var state: State = State.DESCENDING

var anchor_point: Vector2
var platform_top_y := 0.0
var target: Node2D

var _web_cut := false
var _web_line: Line2D

var _attack_cd := 0.0
var _attack_first_pending := true
@onready var _screen_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
var _last_surface_y := INF


func _ready() -> void:
	add_to_group("spider")
	if anchor_point == Vector2.ZERO:
		anchor_point = global_position

	_web_line = Line2D.new()
	_web_line.width = 2.0
	_web_line.default_color = Color(0.95, 0.95, 0.95, 1.0)
	_web_line.z_index = 200
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
			var prev_y := global_position.y
			global_position += velocity * delta
			if walking_after_platform_touch:
				if _try_land_on_named_platform_shapes(prev_y, global_position.y):
					state = State.WALKING
				elif global_position.y >= max_descend_y:
					global_position.y = max_descend_y
			else:
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
					if dx > 0.0:
						state_machine.travel("walk_right")
					elif dx < 0.0:
						state_machine.travel("walk_left")
					global_position.x += sign(dx) * walk_speed * delta
			if walking_after_platform_touch:
				var surf_y := _surface_y_at_x(global_position.x)
				if is_finite(surf_y):
					var aligned := surf_y + surface_alignment_offset_y
					global_position.y = aligned
					platform_top_y = aligned
					_last_surface_y = aligned
				elif is_finite(_last_surface_y):
					global_position.y = _last_surface_y
					platform_top_y = _last_surface_y
				else:
					global_position.y = platform_top_y
			else:
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
	_web_line.add_point(Vector2(0.0, -22.0))


func _try_land_on_named_platform_shapes(prev_y: float, new_y: float) -> bool:
	if platform_area == null:
		return false
	var foot := _foot_global_polygon()
	var x := global_position.x
	var best_land_y := INF
	for child in platform_area.get_children():
		if not child is CollisionShape2D:
			continue
		var cs := child as CollisionShape2D
		if not platform_touch_shape_names.has(cs.name):
			continue
		if cs.disabled or cs.shape == null:
			continue
		if not cs.shape is RectangleShape2D:
			continue
		var rect_poly := _rectangle_shape_global_polygon(cs)
		var land_y := _first_descend_hit_y(x, prev_y, new_y, rect_poly)
		if is_finite(land_y):
			best_land_y = minf(best_land_y, land_y)
			continue
		if _polygons_overlap(foot, rect_poly):
			var top_y := _top_surface_y_at_x(rect_poly, x)
			if not is_finite(top_y):
				top_y = _polygon_top_y(rect_poly)
			best_land_y = minf(best_land_y, top_y)

	if is_finite(best_land_y):
		var aligned := best_land_y + surface_alignment_offset_y
		global_position.y = aligned
		platform_top_y = aligned
		_last_surface_y = aligned
		return true
	return false


func _foot_global_polygon() -> PackedVector2Array:
	var pts := PackedVector2Array()
	var n := 12
	for i in n:
		var a := TAU * (float(i) / float(n))
		pts.append(global_position + Vector2(cos(a), sin(a)) * platform_touch_foot_radius)
	return pts


func _rectangle_shape_global_polygon(cs: CollisionShape2D) -> PackedVector2Array:
	var rect := cs.shape as RectangleShape2D
	var half := rect.size * 0.5
	var local := PackedVector2Array([
		Vector2(-half.x, -half.y),
		Vector2(half.x, -half.y),
		Vector2(half.x, half.y),
		Vector2(-half.x, half.y),
	])
	var xf := cs.global_transform
	var world := PackedVector2Array()
	for p in local:
		world.append(xf * p)
	return world


func _polygons_overlap(a: PackedVector2Array, b: PackedVector2Array) -> bool:
	var inter := Geometry2D.intersect_polygons(a, b)
	return inter.size() > 0 and inter[0].size() > 0


func _polygon_top_y(poly: PackedVector2Array) -> float:
	var top_y := poly[0].y
	for i in range(1, poly.size()):
		top_y = minf(top_y, poly[i].y)
	return top_y


func _surface_y_at_x(x: float) -> float:
	if platform_area == null:
		return INF
	var best_y := INF
	for child in platform_area.get_children():
		if not child is CollisionShape2D:
			continue
		var cs := child as CollisionShape2D
		if not platform_touch_shape_names.has(cs.name):
			continue
		if cs.disabled or cs.shape == null:
			continue
		if not cs.shape is RectangleShape2D:
			continue
		var poly := _rectangle_shape_global_polygon(cs)
		var y := _top_surface_y_at_x(poly, x)
		if not is_finite(y):
			continue
		best_y = minf(best_y, y)
	return best_y


func _top_surface_y_at_x(poly: PackedVector2Array, x: float) -> float:
	var ys := _vertical_line_polygon_intersections_y(poly, x)
	if ys.is_empty():
		return INF
	var best := ys[0]
	for i in range(1, ys.size()):
		best = minf(best, ys[i])
	return best


func _vertical_line_polygon_intersections_y(poly: PackedVector2Array, x: float) -> Array[float]:
	var out: Array[float] = []
	var n := poly.size()
	if n < 2:
		return out
	for i in n:
		var a: Vector2 = poly[i]
		var b: Vector2 = poly[(i + 1) % n]
		var dx := b.x - a.x
		if absf(dx) <= 0.0001:
			continue
		var t := (x - a.x) / dx
		if t < -0.0001 or t > 1.0001:
			continue
		out.append(a.y + (b.y - a.y) * t)
	return out


func _first_descend_hit_y(x: float, y0: float, y1: float, poly: PackedVector2Array) -> float:
	# Spider descends: y increases. Pick the first surface crossed in (y0, y1].
	if y1 <= y0:
		return INF
	var best := INF
	var n := poly.size()
	if n < 2:
		return INF
	for i in n:
		var a: Vector2 = poly[i]
		var b: Vector2 = poly[(i + 1) % n]
		var p: Variant = _segment_intersection_vertical(Vector2(x, y0), Vector2(x, y1), a, b)
		if p is Vector2:
			best = minf(best, (p as Vector2).y)
	return best


func _segment_intersection_vertical(p1: Vector2, p2: Vector2, q1: Vector2, q2: Vector2) -> Variant:
	var r := p2 - p1
	var s := q2 - q1
	var rxs := r.x * s.y - r.y * s.x
	var qmp := q1 - p1
	if absf(rxs) <= 0.0000001:
		return null
	var t := (qmp.x * s.y - qmp.y * s.x) / rxs
	var u := (qmp.x * r.y - qmp.y * r.x) / rxs
	if t < -0.0001 or t > 1.0001 or u < -0.0001 or u > 1.0001:
		return null
	return p1 + r * t
