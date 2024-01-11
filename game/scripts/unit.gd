class_name Unit
extends Node2D

@export var unit_stats : UnitStats

var player_unit = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func setup(stats : UnitStats, player : bool):
	unit_stats = stats
	player_unit = player


func is_player():
	return player_unit


func is_dead():
	return unit_stats.get_current_hp() <= 0
