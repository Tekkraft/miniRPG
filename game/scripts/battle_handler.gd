class_name BattleHandler
extends Node2D

enum BattleState {
	IDLE,
	AI,
	COMBAT,
	EXTRA,
	TARGET,
	RESOLVE,
	CLEANUP,
	SKILL,
	ITEM
}

signal targetSelected

var state_history = []
var current_state : BattleState

var unit_obj = preload("res://scenes/game/unit.tscn")
var test_stats = preload("res://units/default.tres")
var test_stats1 = preload("res://units/tank.tres")
var test_stats2 = preload("res://units/attacker.tres")
var basic_attack = preload("res://abilities/basic_attack.tres")

var active_unit : Unit
var selected_unit : Unit
var active_ability : Ability

var selection_targets = []

var camera : Camera2D

# Called when the node enters the scene tree for the first time.
func _ready():
	camera = get_node("GameCamera")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if current_state == BattleState.TARGET:
		var target = find_closest_unit()
		if not target == null:
			mark_selector(target)
	
	# ADD CAMERA STUFF IF POSSIBLE


func _input(event):
	pass


func setup(encounter : Encounter):
	load_party()
	
	for enemy in encounter.enemy_list:
		var new_enemy = enemy.duplicate(true)
		var target_level = encounter.encounter_level
		target_level += randi_range(-1 * encounter.encounter_level_variance, encounter.encounter_level_variance)
		target_level = max(target_level, 1)
		new_enemy.autolevel_unit(target_level)
		load_unit(new_enemy, false)
	
	space_units(get_node("PlayerUnits"))
	space_units(get_node("EnemyUnits"))
	
	change_state(BattleState.IDLE)



func _unhandled_input(event):
	if current_state == BattleState.TARGET and event.is_action_pressed("battle_cancel"):
		revert_state()
	
	if current_state == BattleState.TARGET and event.is_action_pressed("battle_select"):
		var target = find_closest_unit()
		if not target == null:
			selected_unit = target
			change_state(BattleState.RESOLVE)
			emit_signal("targetSelected")


func find_closest_unit():
	var mouse_pos = get_viewport().get_mouse_position()
	var distance = max(get_viewport_rect().size.x, get_viewport_rect().size.y) * 2 
	var closest = null
	for unit : Unit in selection_targets:
		if unit.is_dead():
			continue
		var target_distance = mouse_pos.distance_to(unit.global_position)
		if target_distance <= distance:
			closest = unit
			distance = target_distance
	
	return closest


# Create new units and assign them to the correct teams
func load_party():
	var party = PlayerParty.party_units
	for unit in party:
		var new_unit = (load("res://scenes/game/unit.tscn") as PackedScene).instantiate()
		new_unit.setup(unit, true)
		get_node("PlayerUnits").add_child(new_unit)
		get_node("BattleUI").create_hp_bar(new_unit)
		(get_node("InitativeQueue") as InitiativeQueue).add_to_initiative(new_unit)


# Create new units and assign them to the correct teams
func load_unit(stats : UnitData, player : bool):
	var new_unit = unit_obj.instantiate() as Unit
	new_unit.setup(stats, player)
	if player:
		get_node("PlayerUnits").add_child(new_unit)
		get_node("BattleUI").create_hp_bar(new_unit)
	else:
		get_node("EnemyUnits").add_child(new_unit)
		new_unit.apply_scale(Vector2(-1,1))
		new_unit.get_node("StatusBox").apply_scale(Vector2(-1,1))
		new_unit.get_node("QuickDataBox").apply_scale(Vector2(-1,1))
	(get_node("InitativeQueue") as InitiativeQueue).add_to_initiative(new_unit)
	return new_unit


func space_units(unit_list : Node2D):
	var unit_count = unit_list.get_child_count()
	for i in unit_count:
		var unit = unit_list.get_child(i)
		# We do this to avoid having to rely on floats - may change
		(unit as Node2D).position = Vector2(0, (256 * (i * 2 - unit_count) / 2))


func kill_unit(unit : Unit):
	(get_node("InitativeQueue") as InitiativeQueue).remove_from_initiative(unit)
	if not unit.is_player():
		for player in PlayerParty.party_units:
			player.current_exp += (unit.unit_data as EnemyData).calculate_exp_gain(player.current_level)
		for player in PlayerParty.reserve_units:
			player.current_exp += (unit.unit_data as EnemyData).calculate_exp_gain(player.current_level) / 2
	#var parent_list = unit.get_parent()
	#parent_list.remove_child(unit)
	#unit.queue_free()
	#space_units(parent_list)


func victory_check():
	for enemy : Unit in get_node("EnemyUnits").get_children():
		if not enemy.is_dead():
			return false
	return true


func defeat_check():
	for enemy : Unit in get_node("PlayerUnits").get_children():
		if not enemy.is_dead():
			return false
	return true


func damage_step(attacker : Unit, defender : Unit, ability_step : AbilityStep, boost : int):
	if ability_step.independent_hit:
		if not check_hit(attacker, defender, ability_step.hit_rate, true):
			return
	
	var unit_atk = 0
	var unit_def = 0
	
	if not ability_step.damage_type == DamageCalculator.DamageType.PHYSICAL:
		unit_atk = attacker.get_stat("INT")
		unit_def = defender.get_stat("RES")
	else:
		unit_atk = attacker.get_stat("STR")
		unit_def = defender.get_stat("DEF")
	
	var base_dmg = unit_atk + ability_step.damage
	var attack_multiplier = attacker.get_damage_dealt_multiplier()
	base_dmg *= attack_multiplier
	var defense_multiplier = defender.get_damage_taken_multiplier()
	base_dmg *= defense_multiplier
	print("*" + str(defense_multiplier))
	
	var calc_dmg = base_dmg - unit_def
	calc_dmg = floori(max(calc_dmg, 0))
	
	# NOTE: Possibly add ability/step crit rates?
	if check_crit(attacker, defender, 0):
		calc_dmg *= 3
	
	defender.unit_data.take_damage(calc_dmg)
	
	print(attacker.unit_data.unit_name)
	print(">>" + str(attacker.unit_data.get_stat("STR") + ability_step.damage))
	print(">" + str(calc_dmg))
	
	if defender.is_dead():
		kill_unit(defender)


func healing_step(healer : Unit, target : Unit, ability_step : AbilityStep, boost : int):
	if ability_step.independent_hit:
		if not check_hit(healer, target, ability_step.hit_rate, true):
			return
		
	var base_heal = healer.unit_data.get_stat("INT") + ability_step.healing
	
	target.unit_data.take_healing(base_heal)


func charge_step(origin : Unit, target : Unit, ability_step : AbilityStep):
	if ability_step.independent_hit:
		if not check_hit(origin, target, ability_step.hit_rate, true):
			return
		
	var base_charge = ability_step.charge
	
	target.unit_data.gain_energy(base_charge)


func status_step(origin : Unit, target : Unit, ability_step : AbilityStep):
	if ability_step.independent_hit:
		if not check_hit(origin, target, ability_step.hit_rate, true):
			return
	
	if ability_step.temp_status:
		target.add_temp_status(ability_step.status)
	else:
		target.add_status(ability_step.status, ability_step.status_duration)


#NOTE: POSSIBLE CHANGE TO INDEPENDENT HIT RATES
func check_hit(origin : Unit, target : Unit, hit_rate : int, independent : bool):
	var hit_roll = randi_range(1, 100)
	var hit_value = hit_rate
	if not independent:
		hit_value += origin.get_calc_stat("HIT")
		hit_value -= target.get_calc_stat("AVO")
	return hit_roll <= hit_value


func check_crit(origin : Unit, target : Unit, crit_rate : int):
	var crit_roll = randi_range(1, 100)
	var crit_value = crit_rate
	crit_value += origin.get_calc_stat("CRT")
	crit_value -= target.get_calc_stat("EVA")
	return crit_roll <= crit_value


func resolve_action(origin : Unit, target : Unit, ability : Ability):
	var ability_boost = 0
	# Check for nulls
	if origin == null:
		change_state(BattleState.IDLE)
		return
	if target == null:
		change_state(BattleState.TARGET)
		return
	if ability == null:
		revert_state_until([BattleState.AI, BattleState.COMBAT, BattleState.EXTRA, BattleState.SKILL])
		return
	
	#Check energy requirements:
	if ability.energy_cost > origin.unit_data.energy:
		revert_state_until([BattleState.AI, BattleState.COMBAT, BattleState.EXTRA, BattleState.SKILL])
		return
	
	origin.unit_data.use_energy(ability.energy_cost)
	
	# Check accuracy
	if check_hit(origin, target, ability.hit, false):
		for ability_step in ability.effects:
			# Check conditions:
			if not is_ability_step_valid(origin, target, ability_step):
				continue
			
			var effect_target = target
			if ability_step.step_target == AbilityStep.StepTarget.USER:
				effect_target = origin
			
			match ability_step.step_type:
				AbilityStep.StepType.DAMAGE:
					damage_step(origin, effect_target, ability_step, ability_boost)
				AbilityStep.StepType.HEALING:
					healing_step(origin, effect_target, ability_step, ability_boost)
				AbilityStep.StepType.CHARGE:
					charge_step(origin, effect_target, ability_step)
				AbilityStep.StepType.STATUS:
					status_step(origin, effect_target, ability_step)
	
	
	change_state(BattleState.CLEANUP)


# Checks validity of conditions if present
func is_ability_step_valid(origin : Unit, target : Unit, ability_step : AbilityStep):
	if ability_step.conditions.size() == 0:
		return true
	
	var scan_target
	
	for condition in ability_step.conditions:
		if condition.check_user:
			scan_target = origin
		else:
			scan_target = target
		
		match condition.condition_type:
			EffectCondition.ConditionType.STATUS:
				if condition.has_status:
					var valid = false
					for status in condition.statuses:
						if scan_target.statuses.has(status):
							valid = true
							break
					if not valid:
						return false
				else:
					for status in condition.statuses:
						if scan_target.statuses.has(status):
							return false
			EffectCondition.ConditionType.HP_THRESHOLD:
				if condition.above_threshold:
					if scan_target.unit_data.get_hp_perc() < condition.hp_percent:
						return false
				else:
					if scan_target.unit_data.get_hp_perc() > condition.hp_percent:
						return false
	
	return true


# NOTE: The targeting state is only used by players
func start_targeting(ability : Ability):
	match ability.ability_target:
		Ability.AbilityTargets.SELF:
			selection_targets = [active_unit]
		Ability.AbilityTargets.ALLY:
			selection_targets = get_node("PlayerUnits").get_children()
		Ability.AbilityTargets.ENEMY:
			selection_targets = get_node("EnemyUnits").get_children()
		Ability.AbilityTargets.ALL_ALLY:
			selection_targets = get_node("PlayerUnits").get_children()
		Ability.AbilityTargets.ALL_ENEMY:
			selection_targets = get_node("EnemyUnits").get_children()
		Ability.AbilityTargets.EVERYONE:
			selection_targets = []
			selection_targets.append_array(get_node("PlayerUnits").get_children())
			selection_targets.append_array(get_node("EnemyUnits").get_children())


func mark_selector(unit):
	var selector = get_node("Selector") as Node2D
	selector.show()
	selector.position = unit.get_node("PositionFlags/SelectorPosition").global_position
	selected_unit = unit


func hide_selector():
	(get_node("Selector") as Node2D).hide()


func set_active_unit(unit : Unit):
	if unit.is_dead():
		change_state(BattleState.CLEANUP)
		return
	
	active_unit = unit
	var marker = get_node("ActivationMarker") as Node2D
	marker.show()
	marker.position = unit.get_node("PositionFlags/ActivationPosition").global_position
	start_turn()
	if unit.is_player():
		change_state(BattleState.COMBAT)
	else:
		change_state(BattleState.AI)


func ai_step():
	await get_tree().create_timer(1).timeout
	active_ability = basic_attack
	selected_unit = get_node("PlayerUnits").get_children().pick_random()
	change_state(BattleState.RESOLVE)


func cleanup_turn():
	if not active_unit == null:
		end_turn()
	
	# Victory and defeat checks
	if victory_check():
		SceneHandler.change_state(SceneHandler.GameState.AFTER_BATTLE, null)
	
	if defeat_check():
		var game_over_data = {}
		for enemy : Unit in get_node("EnemyUnits").get_children():
			if enemy.is_dead():
				game_over_data[enemy.unit_data.unit_name] = "Defeated"
			else:
				game_over_data[enemy.unit_data.unit_name] = str(enemy.unit_data.hp) + "/" + str(enemy.unit_data.max_hp)
		SceneHandler.change_state(SceneHandler.GameState.GAME_OVER, game_over_data)
	
	selected_unit = null
	active_ability = null
	active_unit = null
	selection_targets.clear()
	change_state(BattleState.IDLE)


func start_turn():
	pass


func end_turn():
	active_unit.tick_down_status()


func change_state(new_state : BattleState):
	#print(new_state)
	state_history.append(current_state)
	current_state = new_state
	
	(get_node("BattleUI") as BattleUI).update_ui(current_state)
	
	match current_state:
		BattleState.IDLE:
			(get_node("InitativeQueue") as InitiativeQueue).step_until_ready()
		BattleState.AI:
			ai_step()
		BattleState.COMBAT:
			pass
		BattleState.EXTRA:
			pass
		BattleState.TARGET:
			start_targeting(active_ability)
		BattleState.RESOLVE:
			hide_selector()
			resolve_action(active_unit, selected_unit, active_ability)
		BattleState.CLEANUP:
			cleanup_turn()
		BattleState.SKILL:
			pass
		BattleState.ITEM:
			pass


func revert_state():
	if not state_history.is_empty():
		current_state = state_history.pop_back()
	(get_node("BattleUI") as BattleUI).update_ui(current_state)


func revert_state_until(valid_states : Array):
	current_state = state_history.pop_back()
	while not valid_states.has(current_state) and not state_history.is_empty():
		current_state = state_history.pop_back()
	(get_node("BattleUI") as BattleUI).update_ui(current_state)


func _on_action_canceled():
	selected_unit = null
	revert_state()
	hide_selector()


func _on_basic_attack():
	active_ability = basic_attack
	change_state(BattleState.TARGET)


func _on_skill_menu_selected():
	change_state(BattleState.SKILL)


func _on_extra_menu_selected():
	change_state(BattleState.EXTRA)


func _on_combat_menu_selected():
	change_state(BattleState.COMBAT)


func _on_skill_selected(skill : Ability):
	active_ability = skill
	change_state(BattleState.TARGET)

