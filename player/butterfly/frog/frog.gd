extends CharacterBody2D


@export var SPEED = 300.0
@export var JUMP_VELOCITY = -1000.0
var jumping := false

var player: Butterfly

@onready var tongue := $AnimatedSprite2D/Tongue

@onready var sprite := $AnimatedSprite2D

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
	sprite.scale.x = direction * abs(sprite.scale.x)
	velocity.x = SPEED * direction

func attack(player_pos):
	if player:
		tongue.look_at(player_pos)
		sprite.animation = 'attack'
		create_tween().tween_callback(sprite.set_animation.bind('idle')).set_delay(0.2)
		print("attack frog")

	var tween = create_tween()
	tween.tween_property(tongue, 'scale:x', 34, 0.1)
	tween.tween_property(tongue, 'scale:x', 1, 0.1)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Butterfly:
		player = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player:
		player = null

func _on_timer_attack_timeout() -> void:
	if player:
		sprite.animation = 'ready_attack'

		create_tween().tween_callback(attack.bind(player.global_position)).set_delay(randf_range(1, 2))
		print("ready attack frog")
		create_tween().tween_callback($TimerAttack.start).set_delay(randf())
		


func _on_timer_jump_timeout() -> void:
	jump()
	jumping = true
	create_tween().tween_callback($TimerJump.start).set_delay(randf_range(0, 3))
