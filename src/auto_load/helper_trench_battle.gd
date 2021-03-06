extends Node

"""
all trench positions will be stored here, all target positions will only be
calculated once per lvl load and passed to the units when requested
"""

const SALT_STRENGTH = 0.1
const NUMBER_OF_SHAPES: int = 10

var trench_battle_ready: bool setget set_trench_battle_ready, get_trench_battle_ready

export var trench_pos: Array
export var trench_size: int
export var map_sections: int
export var map_size: float

var shapes: Array

func init(set_map_sections: int, trenches: Dictionary):
	map_sections = set_map_sections
	map_size = GlobalVaribles.OFFSET * 2 + GlobalVaribles.SECTION * map_sections
	
	trench_pos = calc_trench_pos(trenches)
	trench_size = trench_pos.size()

# Calculate the float position for each trench in lvl_data
func calc_trench_pos(trenches: Dictionary) -> Array:
	var out: Array
	for i in range(trenches.size()):
		var trench = trenches[str(i)]
		var location: float = GlobalVaribles.OFFSET
		location += GlobalVaribles.SECTION * trench["trench_section"]
		out.append(location)
	return out

# Get the next index of trench avalible
func next_target_pos(current_pos: int, forward: bool) -> int:
	if current_pos > trench_size:
		return trench_size if forward else trench_size - 1
	elif trench_size < 0:
		return 0 if forward else -1
	else:
		return current_pos + 1 if forward else current_pos - 1

# Get the float value of a trench
func get_trench_location(trench_index: int) -> float:
	if trench_index > trench_size:
		return map_size
	elif trench_index < 0:
		return 0.0
	else:
		return trench_pos[trench_index]

# Check if unit is within target location
func is_at_target(trench_index: int, current_pos: float) -> bool:
	print (str(trench_size) + " " + str(trench_index) + " " + str(current_pos))
	if trench_index >= trench_size:
		return GlobalVaribles.within_tollerance(map_size, current_pos)
	if trench_index < 0:
		return GlobalVaribles.within_tollerance(0, current_pos)
	return GlobalVaribles.within_tollerance(trench_pos[trench_index], current_pos)

# Generates all the shapes that will be used in this battle
func gen_shapes():
	# [[shape_min, shape_rand_n, ...]
	#  [shape_min, shape_rand_n, ...]]
	#
	# First shape is the minimum range for a unit
	# Next shapes are the random variations
	shapes = []
	var total_units = GlobalVaribles.unit_data.size()
	
	for unit_index in range(total_units):
		var unit_shapes: Array = []
		var unit_data = GlobalVaribles.get_unit_data_indexed(unit_index)
		
		# Minimum distance shape
		var min_shape = RectangleShape2D.new()
		var extents = Vector2(
			unit_data["firing_range"] * GlobalVaribles.MIN_RANGE_MULTI,
			GlobalVaribles.BATTLEFIELD_HEIGHT)
		min_shape.set_extents(extents)
		unit_shapes.append(min_shape)
		
		# Random distance shapes
		for i in range(NUMBER_OF_SHAPES):
			var salt = randf() - 0.5
			var radius = unit_data["firing_range"] 
			radius += radius * salt * HelperTrenchBattle.SALT_STRENGTH
			var shape = CircleShape2D.new()
			shape.set_radius(radius)
			unit_shapes.append(shape)
		
		shapes.append(unit_shapes)

func get_shape(unit_id: int, salt: float) -> Array:
	var out: Array = [shapes[unit_id][0]]
	var rand: int = NUMBER_OF_SHAPES * salt
	out.append(shapes[unit_id][rand])
	return out


#######################
###     SET GET     ###
#######################

func set_trench_battle_ready (value: bool):
	trench_battle_ready = value

func get_trench_battle_ready() -> bool:
	return trench_battle_ready








