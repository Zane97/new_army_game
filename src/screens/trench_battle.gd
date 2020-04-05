extends Node2D

"""
Responsible for spawning all the objects, soldiers and trenches that are going
to apear on the battlefield.
"""

const UNIT_SCN = preload("res://src/units/unit.tscn")
const TRENCH_SCN = preload("res://src/objects/trench.tscn")

var battle_data: Dictionary
var screen_x: float

func _ready():
	#TODO
	#restrict camera movement to screen_x
	#change map background to map type
	#spawn objects
	#set trench_battle_ready to true
	
	# TESTING
	randomize()
	GlobalVaribles.set_lvl_data(0) 
	
	battle_data = GlobalVaribles.lvl_data
	screen_x = battle_data["map_size"] * GlobalVaribles.SECTION
	
	GlobalVaribles.trench_pos = []
	for i in range(battle_data["map_size"]):
		var temp = GlobalVaribles.trench_pos
		temp.append(false)
		GlobalVaribles.trench_pos = temp
	
	load_trenches()
	load_units()
	
	GlobalVaribles.trench_battle_ready = true

func trench_at(index:int):
	if index >= GlobalVaribles.trench_pos.size():
		return false
	elif index < 0:
		return false
	return GlobalVaribles.trench_pos[index]

# Instance a child of unit to the trench_battle sceen
func spawn_unit(unit_id: int, is_ally: bool, pos: Array = []):
	if pos.size() == 0:
		pos = [randf() * GlobalVaribles.SCREEN_Y, randf() * screen_x]
	elif pos.size() == 1:
		pos = [randf() * GlobalVaribles.SCREEN_Y, pos[0]]
	
	var inst_unit = UNIT_SCN.instance()
	inst_unit.translate(Vector2(pos[0], pos[1]))
	$battle_field.add_child(inst_unit)
	inst_unit.init(unit_id, is_ally)

# Instance a trench in the correct sector
func spawn_trench(trench_id: int, section: int):
	var inst_unit = TRENCH_SCN.instance()
	var pos_x = section * GlobalVaribles.SECTION + GlobalVaribles.OFFSET
	var pos_y = GlobalVaribles.SCREEN_Y / 2
	inst_unit.translate(Vector2(pos_x, pos_y))
	$battle_field.add_child(inst_unit)
	inst_unit.init(trench_id)

# Load units from the lvl data
func load_units():
	var units = battle_data["units"]
	for index in range(units.size()):
		var current_unit = units[str(index)]
		var type_id = current_unit["unit_type_ID"]
		var is_ally = current_unit["is_ally"]
		var pos = current_unit["unit_position"]
		spawn_unit(type_id, is_ally, pos)

# Loads trenches from lvl data
func load_trenches():
	var trenches = battle_data["trenches"]
	for index in range(trenches.size()):
		var current_trench = trenches[str(index)]
		var type_id = current_trench["trench_type_ID"]
		var section = current_trench["trench_section"]
		
		GlobalVaribles.trench_pos[section] = true
		spawn_trench(type_id, section)