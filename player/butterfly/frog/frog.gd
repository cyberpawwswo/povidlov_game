extends CharacterBody2D


var damage := 4.0

@export var SPEED = 300.0
@export var JUMP_VELOCITY = -1000.0
var jumping := false

var player: Butterfly

@onready var tongue := $AnimatedSprite2D/Tongue

@onready var sprite := $AnimatedSprite2D

@onready var cast_tongue := $RayCast2D

var can_jump := true

var _number_unsec_attack = 0

func _ready() -> void:
	sprite.animation = 'idle'
	tongue.hide()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		jumping = false
	elif not jumping:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func jump():
	if is_on_floor():
		sprite.play("jump")
		await sprite.animation_finished
		sprite.animation = 'jump_loop'
		velocity.y = JUMP_VELOCITY
		var direction: float = [-1,1].pick_random()
		if player:
			direction = sign(player.global_position.x - global_position.x)
		sprite.scale.x = direction * abs(sprite.scale.x)
		velocity.x = SPEED * direction


func attack(player_pos: Vector2):
	if player and not jumping:
		tongue.look_at(player_pos)
		tongue.show()
		sprite.animation = 'attack'
		print("attack frog")

		var tween = create_tween()
		tween.tween_property(tongue, 'scale:x', 10, 0.1)
		tween.tween_property(tongue, 'scale:x', 1, 0.1)

		cast_tongue.look_at(player_pos)
		create_tween().tween_callback(test_keep_player).set_delay(0.1)

		var tween_at = create_tween()
		tween_at.tween_callback(tongue.hide).set_delay(0.2)

		await tween_at.finished

		can_jump = true
		sprite.animation = 'idle'
		
		_number_unsec_attack = 0



func test_keep_player():
	if cast_tongue.is_colliding():
		if cast_tongue.get_collider() is Butterfly:
			var target = cast_tongue.get_collider() as Butterfly
			create_tween().tween_property(target, 'global_position', tongue.global_position, 0.1)
			target.health -= damage
		print('hello', cast_tongue.get_collider())



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Butterfly:
		player = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player:
		player = null



func _on_timer_attack_timeout() -> void:
	if player and _number_unsec_attack < 3:
		sprite.animation = 'ready_attack'

		create_tween().tween_callback(attack.bind(player.global_position)).set_delay(randf_range(1, 2))
		print("ready attack frog")
		create_tween().tween_callback($TimerAttack.start).set_delay(randf_range(1, 2))

		can_jump = false
		_number_unsec_attack += 1
	else:
		can_jump = true
		sprite.animation = 'idle'
		_number_unsec_attack = 0

		create_tween().tween_callback($TimerAttack.start).set_delay(randf_range(1, 2))


func _on_timer_jump_timeout() -> void:
	if can_jump:
		jump()
		jumping = true
	create_tween().tween_callback($TimerJump.start).set_delay(randf_range(0, 3))
