extends Node2D

@export var targets:Array[Node2D]
@onready var collision: CollisionShape2D = $Area2D/CollisionShape2D




func _on_area_2d_area_entered(area: Area2D) -> void:
	for target in targets:
		if target and target.has_method("switch"):
			target.switch()
			collision.set_deferred_thread_group("disabled", true)
	modulate = Color.GRAY
