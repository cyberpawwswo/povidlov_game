extends Node2D
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D




func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("caterpillar"):
		audio.play()
		var dir
		if body.global_position.x > global_position.x:
			dir = 1
		else:
			dir = -1
		body.hurt(dir)
