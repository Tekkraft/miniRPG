class_name Ability
extends Resource

@export var damage: int
@export var hit: int
#@export var effects: Array

func _init(damage = 0, hit = 0):
	self.damage = damage
	self.hit = hit
