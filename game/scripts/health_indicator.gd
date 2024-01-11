class_name HealthIndicator
extends PanelContainer

var linked_unit

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func setup(unit : Unit):
	linked_unit = unit
	unit.unit_stats.hpChanged.connect(_on_hp_changed)
	var hp_bar = get_node("UnitDataBox/HealthBar") as ProgressBar
	hp_bar.max_value = unit.unit_stats.get_max_hp()
	hp_bar.value = unit.unit_stats.get_current_hp()
	(get_node("UnitDataBox/HealthBar/HealthLabel") as Label).text = str(unit.unit_stats.get_current_hp()) + "/" + str(unit.unit_stats.get_max_hp())


func _on_hp_changed(new_value):
	var hp_bar = get_node("UnitDataBox/HealthBar") as ProgressBar
	hp_bar.value = new_value
	(get_node("UnitDataBox/HealthBar/HealthLabel") as Label).text = str(linked_unit.unit_stats.get_current_hp()) + "/" + str(linked_unit.unit_stats.get_max_hp())
