extends Node

enum GameState {
	MAIN_MENU,
	ENCOUNTER_SELECT,
	PARTY_SELECT,
	BATTLE,
	AFTER_BATTLE,
	GAME_OVER
}

var current_state = GameState.MAIN_MENU


func _load_scene(state, data):
	var root_node = get_tree().root
	var new_scene = null
	
	match state:
		GameState.MAIN_MENU:
			new_scene = load("res://scenes/game/main_menu_scene.tscn")
		GameState.ENCOUNTER_SELECT:
			new_scene = load("res://scenes/game/encounter_select_scene.tscn")
		GameState.PARTY_SELECT:
			new_scene = load("res://scenes/game/party_select_scene.tscn")
		GameState.BATTLE:
			new_scene = load("res://scenes/game/battle_scene.tscn")
		GameState.AFTER_BATTLE:
			new_scene = load("res://scenes/game/after_battle_scene.tscn")
		GameState.GAME_OVER:
			new_scene = load("res://scenes/game/game_over_scene.tscn")
	
	var new_node = new_scene.instantiate()
	root_node.add_child(new_node)
	new_node.setup(data)


func _unload_scene(state):
	var target = null
	
	match state:
		GameState.MAIN_MENU:
			target = get_node("/root/MainMenuScene")
		GameState.ENCOUNTER_SELECT:
			target = get_node("/root/EncounterSelectScene")
		GameState.PARTY_SELECT:
			target = get_node("/root/PartySelectScene")
		GameState.BATTLE:
			target = get_node("/root/BattleScene")
		GameState.AFTER_BATTLE:
			target = get_node("/root/AfterBattleScene")
		GameState.GAME_OVER:
			target = get_node("/root/GameOverScene")
	get_tree().root.remove_child(target)
	target.queue_free()


func change_state(new_state : GameState, data):
	call_deferred("_unload_scene", current_state)
	
	current_state = new_state
	
	call_deferred("_load_scene", current_state, data)
