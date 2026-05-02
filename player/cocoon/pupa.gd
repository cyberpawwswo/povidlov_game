extends Node2D

signal hp_changed(current: int, max_hp: int)
signal damaged(amount: int, current: int, max_hp: int)

@export var max_hp := 100

var hp := 100


func _ready() -> void:
	hp = max_hp
	hp_changed.emit(hp, max_hp)


func take_damage(amount: int) -> void:
	if amount <= 0:
		return
	hp -= amount
	if hp < 0:
		hp = 0
	damaged.emit(amount, hp, max_hp)
	hp_changed.emit(hp, max_hp)
