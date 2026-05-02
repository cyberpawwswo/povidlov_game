extends Camera2D
@onready var caterpillar: Caterpillar = $"../caterpillar_container/caterpillar"





func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("caterpillar"):
		var tw = create_tween()
		tw.tween_property(self, "global_position", Vector2(442, 434),0.3)
		tw.parallel().tween_property(self, "zoom", Vector2(2,2),0.3)

func _on_second_body_entered(body: Node2D) -> void:
	if body.is_in_group("caterpillar"):
		var tw = create_tween()
		tw.tween_property(self, "global_position", Vector2(920, 295.0),0.3)
		tw.parallel().tween_property(self, "zoom", Vector2(2,2),0.3)

func _on_third_body_entered(body: Node2D) -> void:
	if body.is_in_group("caterpillar"):
		var tw = create_tween()
		tw.tween_property(self, "global_position", Vector2(1581, 102.0),0.3)
		tw.parallel().tween_property(self, "zoom", Vector2(2,2),0.3)

func _on_fourth_body_entered(body: Node2D) -> void:
	if body.is_in_group("caterpillar"):
		var tw = create_tween()
		tw.tween_property(self, "global_position", Vector2(1808.0, -106.0),0.3)
		tw.parallel().tween_property(self, "zoom", Vector2(3,3),0.3)
