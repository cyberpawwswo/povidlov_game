extends Node2D


const LEAVES_DIE_PARTICLES = preload("uid://83ymxxcmoity")





#func _on_area_2d_body_entered(body: Node2D) -> void:
	#CaterpillarGlobal.add_leaf(1)
	#if body.is_in_group("caterpillar"):
		#die()

func die():
	var inst = LEAVES_DIE_PARTICLES.instantiate()
	inst.emitting = true
	inst.get_child(0).emitting = true
	inst.global_position = global_position
	get_tree().current_scene.add_child(inst)
	queue_free()


func _on_area_2d_area_entered(area: Area2D) -> void:
	
	if area.is_in_group("caterpillar"):
		CaterpillarGlobal.add_leaf(1)
		die()
