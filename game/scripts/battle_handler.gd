class_name BattleHandler
extends Node2D

signal targetSelected

var unit_obj = preload("res://scenes/game/unit.tscn")
var test_stats = preload("res://units/default.tres")
var basic_attack = preload("res://abilities/basic_attack.tres")

var active_unit = null
var selected_unit = null

var selecting = false

var selection_targets = []

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	active_unit = load_unit(test_stats, true)
	load_unit(test_stats, false)
	load_unit(test_stats, false)
	load_unit(test_stats, false)
	space_units(get_node("PlayerUnits"))
	space_units(get_node("EnemyUnits"))
	(get_node("BattleUI") as BattleUI).create_standard_actions()
	(get_node("BattleUI") as BattleUI).basicAttackSelected.connect(_on_basic_attack)
	(get_node("BattleUI") as BattleUI).buttonSelected.connect(_on_battle_action_selected)
	
	(get_node("BattleUI") as BattleUI).hide_actions()
	
	# Start the initative queue
	(get_node("InitativeQueue") as InitiativeQueue).step_until_ready()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if selecting:
		var target = find_closest_unit()
		if not target == null:
			mark_selector(target)


func _input(event):
	if selecting and event.is_action_pressed("battle_select"):
		var target = find_closest_unit()
		if not target == null:
			selected_unit = target
			selecting = false
			emit_signal("targetSelected")


func find_closest_unit():
	var mouse_pos = get_viewport().get_mouse_position()
	var distance = max(get_viewport_rect().size.x, get_viewport_rect().size.y) * 2 
	var closest = null
	for unit in selection_targets:
		var target_distance = mouse_pos.distance_to(unit.global_position)
		if target_distance <= distance:
			closest = unit
			distance = target_distance
	
	return closest


# Create new units and assign them to the correct teams
func load_unit(stats : UnitStats, player : bool):
	var new_unit = unit_obj.instantiate() as Unit
	new_unit.setup(stats, player)
	if player:
		get_node("PlayerUnits").add_child(new_unit)
		get_node("BattleUI").create_hp_bar(new_unit)
	else:
		get_node("EnemyUnits").add_child(new_unit)
		new_unit.apply_scale(Vector2(-1,1))
	(get_node("InitativeQueue") as InitiativeQueue).add_to_initiative(new_unit)
	return new_unit


func space_units(unit_list : Node2D):
	var unit_count = len(unit_list.get_children())
	for i in unit_count:
		var unit = unit_list.get_child(i)
		# We do this to avoid having to rely on floats - may change
		(unit as Node2D).position = Vector2(0, (192 * (i * 2 - unit_count) / 2))


func kill_unit(unit : Unit):
	(get_node("InitativeQueue") as InitiativeQueue).remove_from_initiative(unit)
	var parent_list = unit.get_parent()
	parent_list.remove_child(unit)
	unit.queue_free()
	space_units(parent_list)


func damage_step(attacker : Unit, defender : Unit, ability : Ability, crit : bool):
	var base_dmg = attacker.unit_stats.get_stat("STR") + ability.damage
	var calc_dmg = base_dmg - defender.unit_stats.get_stat("DEF")
	calc_dmg = max(calc_dmg, 0)
	if crit:
		calc_dmg *= 3
	defender.unit_stats.take_damage(calc_dmg)
	if defender.is_dead():
		kill_unit(defender)


func attack(attacker : Unit, defender : Unit, ability : Ability):
	var hit_roll = randi_range(1, 100)
	var hit_value = ability.hit
	if hit_roll <= hit_value:
		print("hit")
		var crit_roll = randi_range(1, 100)
		var crit_value = 10
		damage_step(attacker, defender, ability, crit_roll <= crit_value)
	else:
		print("miss")


func set_targets(player : bool):
	selecting = true
	if player:
		selection_targets = get_node("PlayerUnits").get_children()
	else:
		selection_targets = get_node("EnemyUnits").get_children()


func mark_selector(unit):
	var selector = get_node("Selector") as Node2D
	selector.show()
	selector.position = unit.get_node("PositionFlags/SelectorPosition").global_position
	selected_unit = unit


func hide_selector():
	(get_node("Selector") as Node2D).hide()
	selected_unit = null


func set_active_unit(unit : Unit):
	active_unit = unit
	var marker = get_node("ActivationMarker") as Node2D
	#marker.show()
	marker.position = unit.get_node("PositionFlags/ActivationPosition").global_position
	if unit.is_player():
		(get_node("BattleUI") as BattleUI).show_standard_actions()
	else:
		ai_step()


func ai_step():
	await get_tree().create_timer(1).timeout
	attack(active_unit, get_node("PlayerUnits").get_children().pick_random(), basic_attack)
	#wait for everything to be done first
	_on_action_activated()


func _on_action_activated():
	selected_unit = null
	hide_selector()
	(get_node("InitativeQueue") as InitiativeQueue).step_until_ready()


func _on_basic_attack(data):
	set_targets(false)
	await targetSelected
	attack(active_unit, selected_unit, basic_attack)
	_on_action_activated()


func _on_battle_action_selected(data):
	_on_action_activated()
	
	
