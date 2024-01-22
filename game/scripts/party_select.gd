extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_node("CanvasLayer/EncounterSelectUI/AddPartyButton").disabled = PlayerParty.party_units.size() >= PlayerParty.party_limit
	get_node("CanvasLayer/EncounterSelectUI/AddReserveButton").disabled = PlayerParty.party_units.size() <= 1


func setup(data):
	draw_lists()


func draw_lists():
	var active_party = get_node("CanvasLayer/EncounterSelectUI/ActiveParty") as ItemList
	active_party.clear()
	for unit : UnitData in PlayerParty.party_units:
		active_party.add_item(unit.unit_name, unit.unit_icon)
	
	var reserve_party = get_node("CanvasLayer/EncounterSelectUI/ReserveParty") as ItemList
	reserve_party.clear()
	for unit : UnitData in PlayerParty.reserve_units:
		reserve_party.add_item(unit.unit_name, unit.unit_icon)




func _on_add_party_button_pressed():
	var reserve_party = get_node("CanvasLayer/EncounterSelectUI/ReserveParty") as ItemList
	if not reserve_party.is_anything_selected():
		return
	
	PlayerParty.add_party(PlayerParty.reserve_units[reserve_party.get_selected_items()[0]])
	draw_lists()


func _on_add_reserve_button_pressed():
	var active_party = get_node("CanvasLayer/EncounterSelectUI/ActiveParty") as ItemList
	if not active_party.is_anything_selected():
		return
	
	PlayerParty.remove_party(PlayerParty.party_units[active_party.get_selected_items()[0]])
	draw_lists()


func _on_return_button_pressed():
	SceneHandler.change_state(SceneHandler.GameState.ENCOUNTER_SELECT, EncounterTable.encounter_table)
