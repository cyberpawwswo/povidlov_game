extends Node2D

@onready var parallax_back: Parallax2D = $ParallaxBack
@onready var parallax_midlle: Parallax2D = $ParallaxMidlle
@onready var parrallax_forward: Parallax2D = $ParrallaxForward


func _process(delta: float) -> void:
	parallax_back.scroll_offset.x += delta*10
	parallax_midlle.scroll_offset.x -= delta*30
	parrallax_forward.scroll_offset.x += delta*60
