extends Node2D
class_name Flower

@export var name_flower: String
@export var chroma_point := 1.0


func _ready() -> void:
	for i in get_children():
		if i is Sprite2D:
			var random_phase = randf() * 6.28318530718
			i.material.set_shader_parameter("wind_phase", random_phase)
