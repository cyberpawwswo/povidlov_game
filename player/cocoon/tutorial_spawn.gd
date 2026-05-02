extends Node2D

@export var hang_offset_from_bottom := 300.0
@export var spawn_offset_from_top := 0.0

@onready var label: Label = $LBM
@onready var labelR: Label = $RBM
@export var bee_scene: PackedScene = preload("res://player/cocoon/bee.tscn")
@export var pshik_scene: PackedScene = preload("res://player/cocoon/Pshik.tscn")
@export var scissors_scene: PackedScene = preload("res://player/cocoon/scissors.tscn")
@export var next_scene: PackedScene = preload("res://player/cocoon/Cocoon_defence.tscn")

@export var spray_radius := 650.0
@export var spray_strength := 1050.0
@export var bee_spawn_margin := 80.0
@export var bee_random_area_radius := 150.0

@onready var _spider_scene: PackedScene = preload("res://player/cocoon/spider.tscn")

var _scissors: Node2D
var _scissors_sprite: Sprite2D
var _scissors_prev_mouse: Vector2
var _scissors_has_prev := false

var _cut_prev_mouse: Vector2
var _cut_has_prev := false

var _center_target: Node2D
var _bee_random_area: Area2D
var _tutorial_bees_spawned := false
var _tutorial_bees_alive := 0
var _tutorial_transition_started := false
var _pulse_tween: Tween
var _fade_layer: CanvasLayer
var _fade_rect: ColorRect


func _ready() -> void:
	_setup_center_target()
	_setup_bee_random_area()
	_spawn_tutorial_spider()

	_cut_prev_mouse = get_global_mouse_position()
	_cut_has_prev = false
	_setup_scissors()
	


func _spawn_tutorial_spider() -> void:
	var vr := get_viewport_rect()
	var center_x := vr.position.x + (vr.size.x * 0.5)
	var spawn_pos := Vector2(center_x, vr.position.y + spawn_offset_from_top)

	var spider := _spider_scene.instantiate()
	# Important: set position/anchor BEFORE adding to the tree,
	# because Spider.gd captures anchor_point in _ready().
	spider.global_position = spawn_pos
	spider.set("anchor_point", spawn_pos)

	# Spider.gd stops descending when reaching platform_top_y.
	var hang_y := vr.position.y + vr.size.y - hang_offset_from_bottom
	spider.set("platform_top_y", hang_y)

	add_child(spider)
	spider.tree_exited.connect(_on_tutorial_spider_removed, CONNECT_ONE_SHOT)
	await get_tree().create_timer(1.0).timeout
	var Tween = create_tween()
	Tween.tween_property(label, "modulate:a", 1.0, 2.0)
	_pulse_tween = create_tween()
	_pulse_tween.set_loops()

	_pulse_tween.tween_property(label, "scale", Vector2(1.05, 1.05), 0.6)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	_pulse_tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.6)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	


func _process(_delta: float) -> void:
	_handle_web_cutting()
	_update_scissors()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_RIGHT and mb.pressed and not mb.is_echo():
			_play_pshik(mb.global_position)
			_spray(mb.global_position)


func _setup_scissors() -> void:
	if scissors_scene == null:
		return
	_scissors = scissors_scene.instantiate() as Node2D
	if _scissors == null:
		return
	_scissors.visible = false
	_scissors.z_index = 1000
	add_child(_scissors)
	_scissors_sprite = _scissors.get_node_or_null("Scissors") as Sprite2D


func _update_scissors() -> void:
	if _scissors == null:
		return
	var pressed := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	_scissors.visible = pressed
	var mouse := get_global_mouse_position()
	if not pressed:
		_scissors_has_prev = false
		return

	if _scissors_has_prev and _scissors_sprite != null:
		var dx := mouse.x - _scissors_prev_mouse.x
		if absf(dx) > 0.001:
			# left->right: mirrored; right->left: original
			_scissors_sprite.flip_h = dx > 0.0

	_scissors_prev_mouse = mouse
	_scissors_has_prev = true
	_scissors.global_position = mouse


func _play_pshik(at: Vector2) -> void:
	if pshik_scene == null:
		return
	var fx := pshik_scene.instantiate() as Node2D
	if fx == null:
		return
	add_child(fx)
	fx.global_position = at

	var ap := fx.get_node_or_null("AnimationPlayer") as AnimationPlayer
	if ap == null:
		return
	ap.play("pshik_anim")
	ap.animation_finished.connect(func(_name: StringName) -> void:
		fx.queue_free()
	, CONNECT_ONE_SHOT)


func _setup_center_target() -> void:
	var vr := get_viewport_rect()
	var center := vr.position + (vr.size * 0.5)
	_center_target = Node2D.new()
	_center_target.name = "BeeCenterTarget"
	_center_target.global_position = center
	add_child(_center_target)


func _setup_bee_random_area() -> void:
	if _center_target == null:
		return
	_bee_random_area = Area2D.new()
	_bee_random_area.name = "BeeRandomArea"
	_bee_random_area.monitoring = true
	_bee_random_area.monitorable = true
	_bee_random_area.global_position = _center_target.global_position

	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = bee_random_area_radius
	shape.shape = circle
	_bee_random_area.add_child(shape)
	add_child(_bee_random_area)
	_bee_random_area.body_entered.connect(_on_bee_random_area_body_entered)


func _on_tutorial_spider_removed() -> void:
	if _tutorial_bees_spawned:
		return
	_tutorial_bees_spawned = true
	_spawn_tutorial_bees()
	var Tween = create_tween()
	Tween.tween_property(label, "modulate:a", 0.0, 0.5)
	_pulse_tween = create_tween()
	_pulse_tween.set_loops()

	_pulse_tween.tween_property(labelR, "scale", Vector2(1.05, 1.05), 0.6)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	_pulse_tween.tween_property(labelR, "scale", Vector2(1.0, 1.0), 0.6)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	


func _spawn_tutorial_bees() -> void:
	if bee_scene == null or _center_target == null:
		return

	var vr := get_viewport_rect()
	var center := _center_target.global_position
	var left_pos := Vector2(vr.position.x - bee_spawn_margin, center.y)
	var right_pos := Vector2(vr.position.x + vr.size.x + bee_spawn_margin, center.y)

	_spawn_bee_at(left_pos)
	_spawn_bee_at(right_pos)


func _spawn_bee_at(spawn_pos: Vector2) -> void:
	var bee := bee_scene.instantiate() as CharacterBody2D
	if bee == null:
		return
	bee.global_position = spawn_pos
	bee.set("target", _center_target)
	add_child(bee)
	_tutorial_bees_alive += 1
	bee.tree_exited.connect(_on_tutorial_bee_exited, CONNECT_ONE_SHOT)
	var Tween = create_tween()
	Tween.tween_property(labelR, "modulate:a", 1.0, 2.0)


func _on_tutorial_bee_exited() -> void:
	if _tutorial_transition_started:
		return
	_tutorial_bees_alive = max(0, _tutorial_bees_alive - 1)
	if _tutorial_bees_spawned and _tutorial_bees_alive == 0:
		_start_next_scene()
		#await get_tree().create_timer(1.0).timeout
		#var Tween = create_tween()
		#Tween.tween_property(fade_rect, "modulate:a", 1.0, 1.0)


func _start_next_scene() -> void:
	if _tutorial_transition_started:
		return
	_tutorial_transition_started = true
	if next_scene == null:
		return
	_ensure_fade_overlay()
	var tween := create_tween()
	tween.tween_property(_fade_rect, "modulate:a", 1.0, 1.0)
	await tween.finished
	get_tree().change_scene_to_packed(next_scene)


func _ensure_fade_overlay() -> void:
	if _fade_layer != null:
		return
	_fade_layer = CanvasLayer.new()
	_fade_layer.layer = 100
	add_child(_fade_layer)

	_fade_rect = ColorRect.new()
	_fade_rect.name = "FadeRect"
	_fade_rect.color = Color.BLACK
	_fade_rect.modulate.a = 0.0
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_layer.add_child(_fade_rect)


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


func _on_bee_random_area_body_entered(body: Node) -> void:
	if body == null or not body.is_in_group("Bee"):
		return
	if body.has_method("enable_random_flight"):
		body.call("enable_random_flight")


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
