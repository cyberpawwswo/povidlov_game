extends Camera2D
@onready var caterpillar: Caterpillar = $"../caterpillar_container/caterpillar"





func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("caterpillar"):
		var tw = create_tween()
		tw.tween_property(self, "global_position", Vector2(442, 434),0.2)
		

func _on_second_body_entered(body: Node2D) -> void:
	if body.is_in_group("caterpillar"):
		var tw = create_tween()
		tw.tween_property(self, "global_position", Vector2(815.0, 319.0),0.2)
