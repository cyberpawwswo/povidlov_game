extends Node2D

@onready var parallax_back: Parallax2D = $ParallaxBack
@onready var parallax_midlle: Parallax2D = $ParallaxMidlle
@onready var parrallax_forward: Parallax2D = $ParrallaxForward

@onready var ui_anim: AnimationPlayer = $"CanvasLayer/UI Anim"


func _ready() -> void:
	CaterpillarGlobal.reset()
	ui_anim.play("app")

func _process(delta: float) -> void:
	parallax_back.scroll_offset.x += delta*10
	parallax_midlle.scroll_offset.x -= delta*30
	parrallax_forward.scroll_offset.x += delta*60


func _on_area_2d_area_entered(area: Area2D) -> void:
	ui_anim.play("disap")
	await ui_anim.animation_finished
	UI.open_lose_ui()
