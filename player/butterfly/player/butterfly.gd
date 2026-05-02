extends CharacterBody2D
class_name Butterfly

const SPEED = 150.0
const JUMP_VELOCITY = -200.0

@onready var animation_spite := $Body

var tween : Tween

@export var blur_max := 1
@export var minimun_velosity_blur := 0.8
@export var blur_curve: Curve
@export var blur_samples = 32

@onready var blur_component := $Blur
@onready var blur_mat = blur_component.material as ShaderMaterial

var is_pollinates := false

var chroma_point := 0.0
@export var max_chroma_point := 10.0
@onready var chroma_bar := $CanvasLayer/Control/ChromaPointBar

@export var max_health := 10.0
var health := max_health

@onready var health_bar := $CanvasLayer/Control/HealthBar

func _ready() -> void:
	blur_mat.set_shader_parameter('samples', blur_samples)

	health_bar.max_value = max_health
	chroma_bar.max_value = max_chroma_point

func _physics_process(delta: float) -> void:

	health_bar.value = health
	if health <= 0:
		die()

	chroma_bar.value = chroma_point
	if chroma_point >= max_chroma_point:
		win()

	# Add the gravity.
	if not is_on_floor() and not is_pollinates:
		velocity += get_gravity() * delta
		pass
	elif is_on_floor():
		velocity.x = move_toward(velocity.x, 0, SPEED)

	var direction := signf(get_local_mouse_position().x)

	if Input.is_action_just_pressed("ui_accept"):
		global_position *= 0 

	# Handle jump.
	if Input.is_action_just_pressed("but_fly_up"):
		#tween = create_tween()
		#tween.set_trans(Tween.TRANS_QUINT)
		#tween.tween_property($Camera2D, 'zoom', Vector2(0.95, 0.95), 0.05)
		#tween.tween_property($Camera2D, 'zoom', Vector2(1, 1), 0.1)

		set_frame(0)
		create_tween().tween_callback(set_frame.bind(1)).set_delay(0.1)

		velocity.y = JUMP_VELOCITY# / -velocity.y / 5
		rotation = randf_range(-PI/5, PI/5)
		if direction:
			velocity.x = direction * SPEED
			animation_spite.flip_h = bool(direction-1)

	#if not direction:
		#velocity.x = move_toward(velocity.x, 0, SPEED)


	if get_real_velocity().length() > minimun_velosity_blur*1000:
		var blur_direction = get_real_velocity().normalized()
		var stage = get_real_velocity().length()/(minimun_velosity_blur*1000)* 0.1
		var value = blur_curve.sample(stage)

		blur_mat.set_shader_parameter(
			'blur_direction', 
			blur_direction * value * blur_max
		)
	else:
		blur_mat.set_shader_parameter(
			'blur_direction', 
			Vector2.ZERO
		)


	move_and_slide()

func die():
	print('huh, im die')

func win():
	print('huh, im win')

func set_frame(frame):
	animation_spite.frame = frame
