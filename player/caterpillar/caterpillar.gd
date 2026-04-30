extends CharacterBody2D
class_name Caterpillar
@onready var right_end: Marker2D =%right_end
@onready var left_end: Marker2D = %left_end
@onready var animator: AnimationPlayer = $AnimationPlayer

@onready var body: CollisionShape2D = $CollisionShape2D

var tw: Tween
var body_pos_right = Vector2(30,0)
var body_pos_left = Vector2(-30,0)
@export var speed:float = 10.0
const JUMP_VELOCITY = -400.0
#STATES
@onready var state_machine: Node = $state_machine
var current_state: CaterpillarState = null
var previous_state: CaterpillarState = null
func change_state(next_state):
	if next_state != null:
		previous_state = current_state
		current_state = next_state
		if previous_state:
			previous_state.exit_state()
		current_state.enter_state()

func _ready() -> void:
	for state in state_machine.get_children():
		state.states = state_machine
		state.player = self
	current_state = state_machine.idle
	previous_state = state_machine.idle
func reset_tween():
	if tw:
		tw.kill()
	tw = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC)
func _physics_process(delta: float) -> void:
	# Add the gravity.
	current_state.update(delta)
	#if Input.is_action_pressed("ui_right"):
		#stretch_right(delta)
	#elif Input.is_action_pressed("ui_left"):
		#stretch_left(delta)
	#elif Input.is_action_just_released("ui_right"):
		#move_right()
	#elif Input.is_action_just_released("ui_left"):
		#move_left()
	move_and_slide()

func handle_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
func stretch_right(delta):
	if body.position != body_pos_right:
		body.position = lerp(body.position, body_pos_right, delta)
	scale.x += 0.1 *delta*speed
func stretch_left(delta):
	if body.position != body_pos_left:
		body.position = lerp(body.position, body_pos_left, delta)
	scale.x += 0.1 *delta*speed
func move_right():
	reset_tween()
	tw.tween_property(self, "scale:x", 1.0, 0.5)
	tw.parallel().tween_property(self, "global_position", right_end.global_position, 0.5)
func move_left():
	reset_tween()
	tw.tween_property(self, "scale:x", 1.0, 0.5)
	tw.parallel().tween_property(self, "global_position", left_end.global_position, 0.5)

func stretch_up(delta):
	rotation = 90
	
