extends CharacterBody2D
class_name Butterfly

const SPEED = 100.0
const JUMP_VELOCITY = -200.0

var tween : Tween

@export var blur_max := 1
@export var minimun_velosity_blur := 0.8
@export var blur_curve: Curve
@export var blur_samples = 32
@onready var blur_component := $Blur
@onready var blur_mat = blur_component.material as ShaderMaterial

var is_pollinates := false

func _ready() -> void:
	blur_mat.set_shader_parameter('samples', blur_samples)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor() and not is_pollinates:
		velocity += get_gravity() * delta
		pass

	var direction := signf(get_local_mouse_position().x)

	if Input.is_action_just_pressed("ui_accept"):
		global_position *= 0 

	# Handle jump.
	if Input.is_action_just_pressed("but_fly_up"):
		tween = create_tween()
		tween.set_trans(Tween.TRANS_QUINT)
		tween.tween_property($Camera2D, 'zoom', Vector2(0.95, 0.95), 0.05)
		tween.tween_property($Camera2D, 'zoom', Vector2(1, 1), 0.1)

		velocity.y = JUMP_VELOCITY
		rotation = randf_range(-PI/5, PI/5)
		if direction:
			velocity.x = direction * SPEED

	if not direction:
		velocity.x = move_toward(velocity.x, 0, SPEED)

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
