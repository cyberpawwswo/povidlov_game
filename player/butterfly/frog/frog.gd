extends CharacterBody2D


@export var SPEED = 300.0
@export var JUMP_VELOCITY = -1000.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if Input.is_action_just_pressed("but_fly_up"):
		jump()

	move_and_slide()


func jump():
	velocity.y = JUMP_VELOCITY

	var direction: float = [-1,1].pick_random()

	velocity.x = SPEED * direction
