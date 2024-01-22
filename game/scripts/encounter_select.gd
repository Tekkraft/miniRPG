extends Node2D

var encounter_button = preload("res://scenes/ui/encounter_button.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func setup(data):
	for encounter : Encounter in data:
		var new_button = encounter_button.instantiate()
		new_button.setup(encounter)
		get_node("UILayer/EncounterSelectUI/EncounterContainer/EncounterBox").add_child(new_button)
		new_button.encounterSelected.connect(_on_encounter_selected)

func _on_encounter_selected(encounter):
	SceneHandler.change_state(SceneHandler.GameState.BATTLE, encounter)

