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
	unit.unit_data.hpChanged.connect(_on_hp_changed)
	unit.unit_data.energyChanged.connect(_on_energy_changed)
	(get_node("UnitDataBox/UnitIcon") as TextureRect).texture = unit.unit_data.unit_icon
	(get_node("UnitDataBox/UnitName") as Label).text = unit.unit_data.unit_name
	var hp_bar = get_node("UnitDataBox/BarBox/HealthBar") as TextureProgressBar
	hp_bar.max_value = unit.unit_data.get_max_hp()
	hp_bar.value = unit.unit_data.get_current_hp()
	(get_node("UnitDataBox/BarBox/HealthBar/HealthLabel") as Label).text = str(unit.unit_data.get_current_hp()) + "/" + str(unit.unit_data.get_max_hp())


func _on_hp_changed(new_value):
	var hp_bar = get_node("UnitDataBox/BarBox/HealthBar") as TextureProgressBar
	hp_bar.value = new_value
	(get_node("UnitDataBox/BarBox/HealthBar/HealthLabel") as Label).text = str(linked_unit.unit_data.get_current_hp()) + "/" + str(linked_unit.unit_data.get_max_hp())


func _on_energy_changed(new_value):
	var energy_bar = get_node("UnitDataBox/BarBox/EnergyBar") as TextureProgressBar
	energy_bar.value = new_value
