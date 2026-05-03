extends Node2D

@export var is_final:bool = false
const LEAVES_DIE_PARTICLES = preload("uid://83ymxxcmoity")
@export var audio:AudioStreamPlayer2D
@export var sprite:Sprite2D





#func _on_area_2d_body_entered(body: Node2D) -> void:
	#CaterpillarGlobal.add_leaf(1)
	#if body.is_in_group("caterpillar"):
		#die()

func die():
	if sprite:
		sprite.visible = false
	$Area2D/CollisionShape2D.set_deferred("disabled",true)
	var inst = LEAVES_DIE_PARTICLES.instantiate()
	inst.emitting = true
	inst.get_child(0).emitting = true
	inst.global_position = global_position
	get_tree().current_scene.add_child(inst)
	if audio:
		await audio.finished
		queue_free()
	else:
		queue_free()


func _on_area_2d_area_entered(area: Area2D) -> void:
	if audio:
		audio.pitch_scale = randf_range(0.8,1.2)
		audio.play()
	if !is_final:
		CaterpillarGlobal.add_leaf(1)
		die()
	else:
		CaterpillarGlobal.caterpillar.pupa()
		die()
