extends Node2D
@onready var animator: AnimationPlayer = $AnimationPlayer

var open:bool = false
func switch():
	if open:
		animator.play("close")
	else:
		animator.play("open")
