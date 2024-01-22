extends Node2D

const stat_key = ["STR", "DEF", "INT", "RES", "DEX", "AGI"]

var unit_list = []
var leveling_up = false

var stat_points = 0

var active_unit : UnitData
var old_stats = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("UILayer/AfterBattleUI/LevelUpUI").hide()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if leveling_up and stat_points <= 0:
		close_level_up()


func setup(data):
	active_unit = null
	
	for unit in PlayerParty.party_units:
		unit_list.append(unit)
	
	for unit in PlayerParty.reserve_units:
		unit_list.append(unit)
	
	update_unit_data()


func update_unit_data():
	var party_container = get_node("UILayer/AfterBattleUI/BaseUI/PartyContainer")
	
	for i in unit_list.size():
		var active_panel = party_container.get_child(i)
		var active_unit = unit_list[i] as UnitData
		active_panel.get_node("DataContainer/UnitName").text = active_unit.unit_name
		active_panel.get_node("DataContainer/HPBar").max_value = active_unit.max_hp
		active_panel.get_node("DataContainer/HPBar").value = active_unit.hp
		active_panel.get_node("DataContainer/HPBar/HPLabel").text = str(active_unit.hp) + "/" + str(active_unit.max_hp)
		active_panel.get_node("DataContainer/EXPBar").value = active_unit.current_exp
		active_panel.get_node("DataContainer/LevelUpButton").disabled = active_unit.current_exp < 100



func level_up_unit(unit_data : UnitData):
	active_unit = unit_data
	leveling_up = true
	for stat in stat_key:
		var stat_button = get_node("UILayer/AfterBattleUI/LevelUpUI/StatContainer/" + stat + "/BoostButton") as Button
		stat_button.disabled = false
	
	
	old_stats = unit_data.stat_dict.duplicate(true)
	while unit_data.current_exp >= 100:
		stat_points += 1
		for stat in unit_data.stat_dict.keys():
			unit_data.stat_dict[stat] += unit_data.personal_growths_dict[stat]
		unit_data.max_hp += unit_data.stat_dict["DEF"] + unit_data.stat_dict["RES"]/2
		unit_data.hp = unit_data.max_hp
		unit_data.current_exp -= 100
		unit_data.current_level += 1
	
	change_stat_text(unit_data.stat_dict)
	update_unit_data()
	
	get_node("UILayer/AfterBattleUI/LevelUpUI").show()
	get_node("UILayer/AfterBattleUI/BaseUI/VictoryText").hide()
	


func close_level_up():
	for stat in stat_key:
		var stat_button = get_node("UILayer/AfterBattleUI/LevelUpUI/StatContainer/" + stat + "/BoostButton") as Button
		stat_button.disabled = true
	await get_tree().create_timer(1).timeout
	get_node("UILayer/AfterBattleUI/LevelUpUI").hide()
	get_node("UILayer/AfterBattleUI/BaseUI/VictoryText").show()
	active_unit = null
	old_stats = {}
	leveling_up = false
	update_unit_data()


func change_stat_text(new_stats):
	for stat in stat_key:
		var stat_label = get_node("UILayer/AfterBattleUI/LevelUpUI/StatContainer/" + stat + "/StatLabel") as Label
		stat_label.text = stat + ": " + str(old_stats[stat]) + " > " + str(new_stats[stat])


func _on_level_up_button_pressed(unit_index):
	level_up_unit(unit_list[unit_index])


func _on_boost_button_pressed(stat):
	if active_unit == null:
		return
	active_unit.stat_dict[stat] += 1
	change_stat_text(active_unit.stat_dict)
	stat_points -= 1


func _on_encounter_button_pressed():
	SceneHandler.change_state(SceneHandler.GameState.ENCOUNTER_SELECT, EncounterTable.encounter_table)

