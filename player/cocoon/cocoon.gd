extends Node2D

@export var spider_scene: PackedScene = preload("res://player/cocoon/spider.tscn")
@export var bee_scene: PackedScene = preload("res://player/cocoon/bee.tscn")

@export var spider_spawn_y := -50.0
@export var bee_spawn_margin := 60.0

@export var spider_spawn_interval_start := 1.2
@export var bee_spawn_interval_start := 1.0
@export var min_spawn_interval := 0.25
@export var difficulty_ramp := 0.02 # seconds/second

@export var spray_radius := 500.0
@export var spray_strength := 900.0

@onready var pupa: Node2D = $Pupa
@onready var platform: Node2D = $Platform

var _spider_spawn_interval := 1.2
var _bee_spawn_interval := 1.0
var _spider_spawn_acc := 0.0
var _bee_spawn_acc := 0.0

var _cut_prev_mouse: Vector2
var _cut_has_prev := false

var _platform_top_y := 0.0

func _ready() -> void:
	_spider_spawn_interval = spider_spawn_interval_start
	_bee_spawn_interval = bee_spawn_interval_start
	_platform_top_y = _compute_platform_top_y()
	_cut_prev_mouse = get_global_mouse_position()
	_cut_has_prev = false


func _process(delta: float) -> void:
	_ramp_difficulty(delta)
	_tick_spawns(delta)
	_handle_web_cutting()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_RIGHT and mb.pressed and not mb.is_echo():
			_spray(mb.global_position)


func _ramp_difficulty(delta: float) -> void:
	_spider_spawn_interval = max(min_spawn_interval, _spider_spawn_interval - difficulty_ramp * delta)
	_bee_spawn_interval = max(min_spawn_interval, _bee_spawn_interval - difficulty_ramp * delta)


func _tick_spawns(delta: float) -> void:
	_spider_spawn_acc += delta
	while _spider_spawn_acc >= _spider_spawn_interval:
		_spider_spawn_acc -= _spider_spawn_interval
		_spawn_spider()

	_bee_spawn_acc += delta
	while _bee_spawn_acc >= _bee_spawn_interval:
		_bee_spawn_acc -= _bee_spawn_interval
		_spawn_bee()


func _spawn_spider() -> void:
	if spider_scene == null:
		return

	var vp := get_viewport_rect()
	var x := randf_range(0.0, vp.size.x)
	var spawn_pos := Vector2(x, spider_spawn_y)
	var spider := spider_scene.instantiate() as CharacterBody2D
	if spider == null:
		return
	add_child(spider)
	spider.global_position = spawn_pos

	# contract expected by Spider.gd (duck-typed to keep it minimal)
	spider.set("anchor_point", Vector2(x, spider_spawn_y))
	spider.set("platform_top_y", _platform_top_y)
	spider.set("target", pupa)


func _spawn_bee() -> void:
	if bee_scene == null:
		return

	var vp := get_viewport_rect()
	var y := randf_range(0.0, vp.size.y)
	var from_left := randf() < 0.5
	var x := (-bee_spawn_margin) if from_left else (vp.size.x + bee_spawn_margin)

	var bee := bee_scene.instantiate() as CharacterBody2D
	if bee == null:
		return
	add_child(bee)
	bee.global_position = Vector2(x, y)

	# contract expected by Bee.gd
	bee.set("target", pupa)


func _spray(cursor: Vector2) -> void:
	var bees := get_tree().get_nodes_in_group("Bee")
	for n in bees:
		var bee := n as Node2D
		if bee == null:
			continue
		var delta := bee.global_position - cursor
		var dist := delta.length()
		if dist > spray_radius or dist <= 0.001:
			continue
		var t := 1.0 - (dist / spray_radius)
		var push_dir := delta / dist
		var impulse_add := push_dir * (spray_strength * t)

		# Bee.gd owns movement; only add to Bee.impulse
		if bee.has_method("add_impulse"):
			bee.call("add_impulse", impulse_add)


func _handle_web_cutting() -> void:
	var pressed := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	var mouse := get_global_mouse_position()

	if not pressed:
		_cut_has_prev = false
		return

	if not _cut_has_prev:
		_cut_prev_mouse = mouse
		_cut_has_prev = true
		return

	if mouse == _cut_prev_mouse:
		return

	var spiders := get_tree().get_nodes_in_group("spider")
	for n in spiders:
		var spider := n as Node2D
		if spider == null:
			continue
		if not spider.has_method("cut_web"):
			continue

		var a := spider.get("anchor_point") as Vector2
		var b := spider.global_position
		if Geometry2D.segment_intersects_segment(_cut_prev_mouse, mouse, a, b) != null:
			spider.call("cut_web")

	_cut_prev_mouse = mouse


func _compute_platform_top_y() -> float:
	if platform == null:
		return 0.0

	var top_y := platform.global_position.y
	var cs := platform.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if cs != null and cs.shape is RectangleShape2D:
		var rect := cs.shape as RectangleShape2D
		top_y = platform.global_position.y - rect.size.y * 0.5
	return top_y
