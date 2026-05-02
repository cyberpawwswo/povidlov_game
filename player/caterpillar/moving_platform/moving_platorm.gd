extends Node2D
@onready var line_2d: Line2D = $CanvasGroup/Line2D
@onready var sprite_spider: AnimatedSprite2D = $CanvasGroup/SpriteSpider
@onready var static_body_2d: StaticBody2D = %bdy
@export var play_offset:float = 0.0
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	await get_tree().create_timer(play_offset).timeout
	animation_player.play("move")
func update_line():
	line_2d.clear_points()
	line_2d.add_point(static_body_2d.position)
	line_2d.add_point(sprite_spider.position+Vector2(0, -10))

func _process(delta: float) -> void:
	update_line()
