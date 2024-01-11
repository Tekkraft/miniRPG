class_name BattleUI
extends CanvasLayer

signal buttonSelected
signal basicAttackSelected
signal abilityAttackSelected

var unit_hp_bar = preload("res://scenes/ui/health_indicator.tscn")
var action_button = preload("res://scenes/ui/action_button.tscn")

var test = 0

var MainActions = [
	"Attack",
	"Skill",
	"Magic",
	"Defend",
	"Wait",
	"Escape"
]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Creates a new health bar and links it with the unit
func create_hp_bar(unit):
	var new_hp_bar = unit_hp_bar.instantiate()
	new_hp_bar.setup(unit)
	get_node("MainUI/UnitHealthContainer/UnitHealthList").add_child(new_hp_bar)


func create_actions(actions):
	var action_list = []
	for action in actions:
		var new_action_button = action_button.instantiate() as ActionButton
		new_action_button.setup(action)
		get_node("MainUI/ActionsContainer/ActionsList").add_child(new_action_button)
		action_list.append([action, new_action_button])
	return action_list


func create_standard_actions():
	var action_list = []
	for action in MainActions:
		var new_action_button = action_button.instantiate() as ActionButton
		new_action_button.setup(action)
		new_action_button.actionSelected.connect(_on_sub_button_pressed)
		get_node("MainUI/ActionsContainer/ActionsList").add_child(new_action_button)
		action_list.append([action, new_action_button])
	return action_list


func show_standard_actions():
	(get_node("MainUI/ActionsContainer") as PanelContainer).show()


func hide_actions():
	(get_node("MainUI/ActionsContainer") as PanelContainer).hide()


# Passes a signal further upstream if needed or change ui if not
# Encode args as [action_type, OTHER_ARGS*]
func _on_sub_button_pressed(data):
	hide_actions()
	if data[0] == "MainAction" and data[1] == "Attack":
		print("basic")
		emit_signal("basicAttackSelected", data)
	else:
		emit_signal("buttonSelected", data)


func _on_cancel_selected():
	pass # Replace with function body.
