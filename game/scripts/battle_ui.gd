class_name BattleUI
extends CanvasLayer

signal buttonSelected
signal actionCanceled
signal basicAttackSelected
signal skillMenuSelected
signal skillSelected

var unit_hp_bar = preload("res://scenes/ui/health_indicator.tscn")
var action_button = preload("res://scenes/ui/action_button.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
	#TEMP TEST
	#if get_parent().current_state == BattleHandler.BattleState.SKILL:
	#	get_node("MainUI/ActionsContainer/AbilityActions/AbilityContainer").resize()


# Creates a new health bar and links it with the unit
func create_hp_bar(unit):
	var new_hp_bar = unit_hp_bar.instantiate()
	new_hp_bar.setup(unit)
	get_node("MainUI/UnitHealthContainer/UnitHealthList").add_child(new_hp_bar)


func add_skills(skills):
	var grid = get_node("MainUI/ActionsContainer/AbilityActions/AbilityContainer/AbilityGrid") as GridContainer
	# Clear any previous skills
	for i in grid.get_child_count():
		var node = grid.get_child(0)
		grid.remove_child(node)
		node.queue_free()
		
	
	# Only add new skills after all nodes freed
	var skill_list = []
	for skill in skills:
		var new_skill_button = action_button.instantiate() as ActionButton
		new_skill_button.setup(skill)
		grid.add_child(new_skill_button)
		skill_list.append([skill, new_skill_button])
		new_skill_button.actionSelected.connect(_on_skill_selected)



func show_cancel_actions():
	hide_all_actions()
	get_node("MainUI/ActionsContainer/CancelActions").show()


func show_combat_actions():
	hide_all_actions()
	get_node("MainUI/ActionsContainer/CombatActions").show()


func show_extra_actions():
	hide_all_actions()
	get_node("MainUI/ActionsContainer/ExtraActions").show()


func show_skill_actions():
	hide_all_actions()
	get_node("MainUI/ActionsContainer/AbilityActions").show()
	# FIX SPAGHETTI LATER
	var active_unit = get_parent().active_unit as Unit
	if active_unit == null:
		return
	add_skills(active_unit.unit_class.skills)


func hide_all_actions():
	get_node("MainUI/ActionsContainer/CancelActions").hide()
	get_node("MainUI/ActionsContainer/CombatActions").hide()
	get_node("MainUI/ActionsContainer/ExtraActions").hide()
	get_node("MainUI/ActionsContainer/AbilityActions").hide()


func update_ui(battle_state : BattleHandler.BattleState):
	match battle_state:
		BattleHandler.BattleState.IDLE:
			hide_all_actions()
		BattleHandler.BattleState.AI:
			hide_all_actions()
		BattleHandler.BattleState.COMBAT:
			show_combat_actions()
		BattleHandler.BattleState.EXTRA:
			show_extra_actions()
		BattleHandler.BattleState.TARGET:
			show_cancel_actions()
		BattleHandler.BattleState.RESOLVE:
			hide_all_actions()
		BattleHandler.BattleState.CLEANUP:
			hide_all_actions()
		BattleHandler.BattleState.SKILL:
			show_skill_actions()
		BattleHandler.BattleState.ITEM:
			hide_all_actions()


# Dynamic actions
func _on_skill_selected(skill):
	emit_signal("skillSelected", skill)


# Preset action buttons
func _on_cancel_button_pressed():
	emit_signal("actionCanceled")
	


func _on_ultimate_button_pressed():
	pass # Replace with function body.


func _on_attack_button_pressed():
	emit_signal("basicAttackSelected")


func _on_skill_button_pressed():
	emit_signal("skillMenuSelected")


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
