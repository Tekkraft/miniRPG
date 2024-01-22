extends PanelContainer

signal encounterSelected

var encounter : Encounter

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func setup(encounter : Encounter):
	self.encounter = encounter
	get_node("EncounterDetailContainer/EncounterSelect").text = encounter.encounter_name
	get_node("EncounterDetailContainer/EncounterLevel").text = "LV: " + str(max(encounter.encounter_level - encounter.encounter_level_variance, 1)) + " - " + str(encounter.encounter_level + encounter.encounter_level_variance)

func _on_encounter_select_pressed():
	emit_signal("encounterSelected", encounter)
