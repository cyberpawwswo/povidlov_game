extends CharacterBody2D


@export var SPEED = 300.0
@export var JUMP_VELOCITY = -1000.0
var jumping := false

var player: Butterfly

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		jumping = false
	elif not jumping:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	#if Input.is_action_just_pressed("but_fly_up"):
		#jump()

	move_and_slide()


func jump():
	if is_on_floor():
		velocity.y = JUMP_VELOCITY
	var direction: float = [-1,1].pick_random()
	if player:
		direction = sign(player.global_position.x - global_position.x)
	velocity.x = SPEED * direction

func attack():
	$Tongue.look_at(player.global_position)

	var tween = create_tween()
	tween.tween_property($Tongue, 'scale:x', 34, 0.1)
	tween.tween_property($Tongue, 'scale:x', 1, 0.1)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Butterfly:
		player = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player:
		player = null

func _on_timer_attack_timeout() -> void:
	if player:
		create_tween().tween_callback(attack).set_delay(randf_range(0.5, 2))
	create_tween().tween_callback($TimerAttack.start).set_delay(randf())


func _on_timer_jump_timeout() -> void:
	jump()
	jumping = true
	create_tween().tween_callback($TimerJump.start).set_delay(randf_range(0, 3))
