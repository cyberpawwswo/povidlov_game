extends Node2D

@onready var collision: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

func switch():
	if !collision.disabled:
		collision.set_deferred("disabled",true)
		sprite.set_deferred("visible",false)
		$leaves_die_particles.emitting = true
