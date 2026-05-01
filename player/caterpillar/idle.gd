extends CaterpillarState
@onready var canvas_group: CanvasGroup = $"../../../CanvasGroup"
@onready var container: Node2D = $"../../.."

func enter_state():
	pass

func update(delta):
	player.handle_gravity(delta)
	if player.is_on_floor():
		if Input.is_action_pressed("ui_right"):
			player.change_state(states.stretch_right)
		elif Input.is_action_pressed("ui_left"):
			player.change_state(states.stretch_left)
		elif Input.is_action_pressed("ui_up"):
			player.change_state(states.stretch_up)
	if !player.is_on_floor():
		player.change_state(states.fall)
