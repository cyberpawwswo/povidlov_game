extends Node
signal leaf_eat
var leaves_eaten:int = 0
var caterpillar:Caterpillar


func add_leaf(value):
	leaves_eaten += value
	emit_signal("leaf_eat")

func reset():
	leaves_eaten = 0
