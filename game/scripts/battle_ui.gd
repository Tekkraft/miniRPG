class_name BattleUI
extends CanvasLayer

signal buttonSelected
signal actionCanceled
signal basicAttackSelected
signal abilityAttackSelected

var unit_hp_bar = preload("res://scenes/ui/health_indicator.tscn")
var action_button = preload("res://scenes/ui/action_button.tscn")

var last_menu_state = MenuState.COMBAT

enum MenuState {
	COMBAT,
	EXTRA,
	SKILL,
	ITEM
}

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


func add_abilities(abilities):
	var abilities_list = []
	for ability in abilities:
		var new_ability_button = action_button.instantiate() as ActionButton
		new_ability_button.setup(ability)
		get_node("MainUI/ActionsContainer/AbilityContainer/AbilityGrid").add_child(new_ability_button)
		abilities_list.append([ability, new_ability_button])
	return abilities_list


func show_cancel_actions():
	hide_all_actions()
	get_node("MainUI/ActionsContainer/CancelActions").show()


func show_combat_actions():
	last_menu_state = MenuState.COMBAT
	hide_all_actions()
	get_node("MainUI/ActionsContainer/CombatActions").show()


func show_extra_actions():
	last_menu_state = MenuState.EXTRA
	hide_all_actions()
	get_node("MainUI/ActionsContainer/ExtraActions").show()


func hide_all_actions():
	get_node("MainUI/ActionsContainer/CancelActions").hide()
	get_node("MainUI/ActionsContainer/CombatActions").hide()
	get_node("MainUI/ActionsContainer/ExtraActions").hide()
	get_node("MainUI/ActionsContainer/AbilityContainer").hide()


# Preset action buttons

func _on_cancel_button_pressed():
	emit_signal("actionCanceled")
	match last_menu_state:
		MenuState.COMBAT:
			show_combat_actions()
		MenuState.EXTRA:
			show_extra_actions()
		MenuState.SKILL:
			pass
		MenuState.ITEM:
			pass
	


func _on_ultimate_button_pressed():
	pass # Replace with function body.


func _on_attack_button_pressed():
	emit_signal("basicAttackSelected")
	show_cancel_actions()


func _on_skill_button_pressed():
	pass # Replace with function body.


func _on_defend_button_pressed():
	pass # Replace with function body.


func _on_more_button_pressed():
	pass # Replace with function body.


func _on_fight_button_pressed():
	pass # Replace with function body.


func _on_item_button_pressed():
	pass # Replace with function body.


func _on_wait_button_pressed():
	pass # Replace with function body.


func _on_escape_button_pressed():
	pass # Replace with function body.
