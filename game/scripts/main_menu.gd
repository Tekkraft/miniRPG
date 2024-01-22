extends Node2D

@export var encounter_table : Array[Encounter]

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	EncounterTable.encounter_table = encounter_table
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func setup(data):
	pass


func _on_start_button_pressed():
	PlayerParty.clear_party()
	var unit_0 = load("res://units/player_units/player_0.tres").duplicate(true)
	PlayerParty.new_unit(unit_0, true)
	var unit_1 = load("res://units/player_units/player_1.tres").duplicate(true)
	PlayerParty.new_unit(unit_1, true)
	var unit_2 = load("res://units/player_units/player_2.tres").duplicate(true)
	PlayerParty.new_unit(unit_2, true)
	var unit_3 = load("res://units/player_units/player_3.tres").duplicate(true)
	PlayerParty.new_unit(unit_3, false)
	var unit_4 = load("res://units/player_units/player_4.tres").duplicate(true)
	PlayerParty.new_unit(unit_4, false)
	var unit_5 = load("res://units/player_units/player_5.tres").duplicate(true)
	PlayerParty.new_unit(unit_5, false)
	SceneHandler.change_state(SceneHandler.GameState.ENCOUNTER_SELECT, EncounterTable.encounter_table)
