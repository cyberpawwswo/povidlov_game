extends Node2D
class_name Bird

var rotation_attack: float

var SPEED := 1000



func _physics_process(delta: float) -> void:
	var velocity = (Vector2.RIGHT*SPEED).rotated(global_rotation)
	position += velocity*delta
