extends Node

"""
all trench positions will be stored here, all target positions will only be
calculated once per lvl load and passed to the units when requested
"""

var trench_battle_ready: bool setget set_trench_battle_ready, get_trench_battle_ready

export var trench_pos: Array
export var trench_size: int
export var map_sections: int
export var map_size: float

func init(set_map_sections: int, trenches: Dictionary):
	map_sections = set_map_sections
	map_size = GlobalVaribles.OFFSET + GlobalVaribles.SECTION * map_sections
	
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
	return GlobalVaribles.within_tollerance(trench_pos[trench_index], current_pos)

#######################
###     SET GET     ###
#######################

func set_trench_battle_ready (value: bool):
	trench_battle_ready = value

func get_trench_battle_ready() -> bool:
	return trench_battle_ready








