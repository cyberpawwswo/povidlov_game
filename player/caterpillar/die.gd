extends CaterpillarState



func enter_state():
	#$"../../..".process_mode = Node.PROCESS_MODE_ALWAYS
	#get_tree().paused = true
	player.velocity.y -= 15
	
	%CollisionShape2D.set_deferred("disabled", true)
func update(delta: float):
	$"../../../CanvasGroup".rotate(delta*2)
	player.handle_gravity(delta*2.5)
