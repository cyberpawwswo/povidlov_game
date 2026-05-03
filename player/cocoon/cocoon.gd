extends Node2D

@export var spider_scene: PackedScene = preload("res://player/cocoon/spider.tscn")
@export var bee_scene: PackedScene = preload("res://player/cocoon/bee.tscn")
@export var pshik_scene: PackedScene = preload("res://player/cocoon/Pshik.tscn")
@export var scissors_scene: PackedScene = preload("res://player/cocoon/scissors.tscn")

@export var spider_spawn_y := -50.0
@export var bee_spawn_margin := 60.0

@export var spider_spawn_interval_start := 1.5
@export var bee_spawn_interval_start := 1.8
@export var min_spawn_interval := 0.25
@export var difficulty_ramp := 0.02 # seconds/second

@export var spray_radius := 650.0
@export var spray_strength := 1050.0

## Survive this long; then spawning stops and clearing all bees/spiders wins the level.
@export var survival_seconds := 150.0
@export var victory_scene: PackedScene = preload("res://player/butterfly/tutorial_map.tscn")
@export var victory_fade_out_duration := 1.0
@export var countdown_hide_duration := 0.6
@export var start_help_delay := 1.0
@export var start_help_fade_in_duration := 0.8
@export var start_help_pulse_duration := 5.0
@export var start_help_fade_out_duration := 0.8

@onready var pupa: Node2D = $Pupa
@onready var platform: Node2D = $Platform
@onready var _bgm_player: AudioStreamPlayer = $BgmPlayer
@onready var _pshik_sfx_player: AudioStreamPlayer = $PshikSfxPlayer
@onready var _scissors_sfx_player: AudioStreamPlayer = $ScissorsSfxPlayer

var _scissors: Node2D
var _scissors_sprite: Sprite2D
var _scissors_prev_mouse: Vector2
var _scissors_has_prev := false

var _spider_spawn_interval := 1.0
var _bee_spawn_interval := 1.0
var _spider_spawn_acc := 0.0
var _bee_spawn_acc := 0.0

var _cut_prev_mouse: Vector2
var _cut_has_prev := false

var _platform_top_y := 0.0
var _fade_layer: CanvasLayer
var _fade_rect: ColorRect

var _survival_left: float
var _spawn_stopped := false
var _level_ended := false
var _countdown_layer: CanvasLayer
var _countdown_label: Label

var _help_hint_started := false
var _help_pulse_tween: Tween

var _countdown_hide_started := false
var _start_help_started := false
var _music_enabled := true
var _sfx_enabled := true

func _ready() -> void:
	_survival_left = survival_seconds
	_spider_spawn_interval = spider_spawn_interval_start
	_bee_spawn_interval = bee_spawn_interval_start
	_platform_top_y = _compute_platform_top_y()
	_cut_prev_mouse = get_global_mouse_position()
	_cut_has_prev = false
	_setup_scissors()
	_setup_countdown_ui()
	if pupa.has_signal("died"):
		pupa.died.connect(_on_pupa_died)
	var pause_menu_button := get_node_or_null("pauseButton/Button") as Button
	if pause_menu_button != null:
		pause_menu_button.pressed.connect(_on_pause_menu_button_pressed)
	var music_button := get_node_or_null("pauseButton/MusicButton") as Button
	if music_button != null:
		music_button.pressed.connect(_on_music_button_pressed)
	var sfx_button := get_node_or_null("pauseButton/SfxButton") as Button
	if sfx_button != null:
		sfx_button.pressed.connect(_on_sfx_button_pressed)
	_update_audio_toggle_buttons()
	if _bgm_player != null:
		_bgm_player.play()
	_play_fade_in()
	_play_start_help_hint()


func _process(delta: float) -> void:
	if _level_ended:
		return
	_tick_survival(delta)
	if not _spawn_stopped:
		_ramp_difficulty(delta)
		_tick_spawns(delta)
	_handle_web_cutting()
	_update_scissors()
	_try_complete_victory()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_RIGHT and mb.pressed and not mb.is_echo():
			_play_pshik(mb.global_position)
			_spray(mb.global_position)


func _ramp_difficulty(delta: float) -> void:
	_spider_spawn_interval = max(min_spawn_interval, _spider_spawn_interval - difficulty_ramp * delta)
	_bee_spawn_interval = max(min_spawn_interval, _bee_spawn_interval - difficulty_ramp * delta)


func _tick_survival(delta: float) -> void:
	if not _spawn_stopped:
		_survival_left -= delta
		if _survival_left <= 0.0:
			_survival_left = 0.0
			_spawn_stopped = true
			_start_help_hint()
			_hide_countdown_timer()
	_update_countdown_label()


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
	spider.set("walking_after_platform_touch", true)
	spider.set("platform_area", platform)
	spider.set("max_descend_y", platform.global_position.y + 3000.0)


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


func _setup_countdown_ui() -> void:
	_countdown_layer = CanvasLayer.new()
	_countdown_layer.layer = 45
	add_child(_countdown_layer)

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_countdown_layer.add_child(root)

	_countdown_label = Label.new()
	_countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_countdown_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_countdown_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_countdown_label.offset_top = 12.0
	_countdown_label.offset_bottom = 96.0
	_countdown_label.add_theme_font_size_override("font_size", 64)
	root.add_child(_countdown_label)
	_update_countdown_label()


func _update_countdown_label() -> void:
	if _countdown_label == null:
		return
	if _countdown_layer != null and not _countdown_layer.visible:
		return
	var secs := maxi(0, int(ceilf(_survival_left)))
	var m: int = int(secs / 60.0)
	var s: int = secs % 60
	_countdown_label.text = "%d:%02d" % [m, s]


func _hide_countdown_timer() -> void:
	if _countdown_hide_started:
		return
	if _countdown_label == null or _countdown_layer == null:
		return
	_countdown_hide_started = true
	var tween := create_tween()
	tween.tween_property(_countdown_label, "modulate:a", 0.0, countdown_hide_duration)
	tween.finished.connect(func() -> void:
		if is_instance_valid(_countdown_layer):
			_countdown_layer.visible = false
	, CONNECT_ONE_SHOT)


func _start_help_hint() -> void:
	if _help_hint_started:
		return
	var help := get_node_or_null("Help") as Label
	if help == null:
		return
	_help_hint_started = true
	help.scale = Vector2.ONE
	var fade_tween := create_tween()
	fade_tween.tween_property(help, "modulate:a", 1.0, 2.0)
	_help_pulse_tween = create_tween()
	_help_pulse_tween.set_loops()
	_help_pulse_tween.tween_property(help, "scale", Vector2(1.05, 1.05), 0.6)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_help_pulse_tween.tween_property(help, "scale", Vector2(1.0, 1.0), 0.6)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _play_start_help_hint() -> void:
	if _start_help_started:
		return
	var start_help := get_node_or_null("startHelp") as Label
	if start_help == null:
		return
	_start_help_started = true

	start_help.modulate.a = 0.0
	start_help.scale = Vector2.ONE

	var delay_tween := create_tween()
	delay_tween.tween_interval(start_help_delay)
	delay_tween.finished.connect(func() -> void:
		if not is_instance_valid(start_help):
			return
		var tween := create_tween()
		tween.tween_property(start_help, "modulate:a", 1.0, start_help_fade_in_duration)

		var pulse_steps := maxi(1, int(round(start_help_pulse_duration / 0.6)))
		for _i in pulse_steps:
			tween.tween_property(start_help, "scale", Vector2(1.05, 1.05), 0.3)\
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(start_help, "scale", Vector2(1.0, 1.0), 0.3)\
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

		tween.tween_property(start_help, "modulate:a", 0.0, start_help_fade_out_duration)
	, CONNECT_ONE_SHOT)


func _count_hostile_enemies() -> int:
	var n := 0
	for node in get_tree().get_nodes_in_group("Bee"):
		if node is Node2D and is_instance_valid(node) and node.is_inside_tree():
			n += 1
	for node in get_tree().get_nodes_in_group("spider"):
		if node is Node2D and is_instance_valid(node) and node.is_inside_tree():
			n += 1
	return n


func _try_complete_victory() -> void:
	if not _spawn_stopped or _level_ended:
		return
	if _count_hostile_enemies() > 0:
		return
	_level_ended = true
	_play_fade_out_to_scene(victory_scene, "res://player/butterfly/tutorial_map.tscn")


func _on_pause_menu_button_pressed() -> void:
	if _level_ended:
		return
	PauseUi.request_open_pause()


func _on_music_button_pressed() -> void:
	_music_enabled = not _music_enabled
	if _bgm_player != null:
		_bgm_player.stream_paused = not _music_enabled
	_update_audio_toggle_buttons()


func _on_sfx_button_pressed() -> void:
	_sfx_enabled = not _sfx_enabled
	_update_audio_toggle_buttons()


func _update_audio_toggle_buttons() -> void:
	var music_button := get_node_or_null("pauseButton/MusicButton") as Button
	if music_button != null:
		music_button.text = "♫" if _music_enabled else "×♫"
	var sfx_button := get_node_or_null("pauseButton/SfxButton") as Button
	if sfx_button != null:
		sfx_button.text = "🔊" if _sfx_enabled else "🔇"


func _play_pshik_sfx() -> void:
	if not _sfx_enabled or _pshik_sfx_player == null:
		return
	_pshik_sfx_player.play()


func _play_scissors_sfx() -> void:
	if not _sfx_enabled or _scissors_sfx_player == null:
		return
	_scissors_sfx_player.play()


func _on_pupa_died() -> void:
	if _level_ended:
		return
	_level_ended = true
	UI.open_lose_ui()


func _play_fade_out_to_scene(next: PackedScene, fallback_path: String) -> void:
	var layer := CanvasLayer.new()
	layer.layer = 200
	add_child(layer)

	var rect := ColorRect.new()
	rect.color = Color.BLACK
	rect.modulate.a = 0.0
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(rect)

	var tween := create_tween()
	tween.tween_property(rect, "modulate:a", 1.0, victory_fade_out_duration)
	tween.finished.connect(func() -> void:
		if next != null:
			get_tree().change_scene_to_packed(next)
		else:
			get_tree().change_scene_to_file(fallback_path)
	, CONNECT_ONE_SHOT)


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
	_play_pshik_sfx()
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
	var did_cut := false
	for n in spiders:
		var spider := n as Node2D
		if spider == null:
			continue
		if not spider.has_method("cut_web"):
			continue

		var a := spider.get("anchor_point") as Vector2
		var b := spider.global_position
		if Geometry2D.segment_intersects_segment(_cut_prev_mouse, mouse, a, b) != null:
			did_cut = true
			spider.call("cut_web")

	if did_cut:
		_play_scissors_sfx()

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


func _play_fade_in() -> void:
	_fade_layer = CanvasLayer.new()
	_fade_layer.layer = 100
	add_child(_fade_layer)

	_fade_rect = ColorRect.new()
	_fade_rect.color = Color.BLACK
	_fade_rect.modulate.a = 1.0
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_layer.add_child(_fade_rect)

	var tween := create_tween()
	tween.tween_property(_fade_rect, "modulate:a", 0.0, 1.0)
	tween.finished.connect(func() -> void:
		if is_instance_valid(_fade_layer):
			_fade_layer.queue_free()
	)
