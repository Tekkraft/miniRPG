extends ScrollContainer

const max_rows = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#FIND OPTIMIZATION???
	resize()


func resize():
	var grid = get_node("AbilityGrid") as GridContainer
	if grid.get_child_count() / float(grid.columns) > max_rows:
		set_custom_minimum_size(Vector2(grid.size.x + get_v_scroll_bar().size.x, grid.get_child(0).size.y * max_rows))
	else:
		set_custom_minimum_size(Vector2(grid.size.x, grid.size.y))
	
