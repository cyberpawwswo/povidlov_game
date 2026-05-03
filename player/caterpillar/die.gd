extends CaterpillarState


@onready var area_2d: Area2D = $"../../../CanvasGroup/Rsegment/head/Area2D"

func enter_state():
	#$"../../..".process_mode = Node.PROCESS_MODE_ALWAYS
	#get_tree().paused = true
	player.velocity.y += 5
	area_2d.set_collision_layer_value(5,false)
	
	%CollisionShape2D.set_deferred("disabled", true)
func update(delta: float):
	$"../../../CanvasGroup".rotate(delta*2)
	player.handle_gravity(delta)
