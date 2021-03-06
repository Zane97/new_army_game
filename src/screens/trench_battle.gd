extends Node2D

"""
Responsible for spawning all the objects, soldiers and trenches that are going
to apear on the battlefield.
"""

const UNIT_SCN = preload("res://src/units/unit.tscn")
const TRENCH_SCN = preload("res://src/objects/trench.tscn")

var battle_data: Dictionary

var battle_timer: float
var _player_cash: int = 500
var _ai_cash: int = 750

func _ready():
	#TODO
	#change map background to map type
	#spawn objects
	
	# TESTING, lvl_data should be set before trenchbatle is instance
	GlobalVaribles.set_lvl_data(0) 
	
	randomize()
	battle_data = GlobalVaribles.lvl_data
	HelperTrenchBattle.init(battle_data["map_size"], battle_data["trenches"])
	HelperTrenchBattle.gen_shapes()
	
	$GCC2D.limit_left = 0
	$GCC2D.limit_right = HelperTrenchBattle.map_size
	
	load_trenches()
	load_units()
	
	GlobalVaribles.connect("unit_spawn", self, "spawn_unit")
	
	battle_timer = 0
	HelperTrenchBattle.trench_battle_ready = true

func _process(delta):
	battle_timer += delta
	$gui/player_data/time.text = "TIME: " + str(int(battle_timer))
	$gui/player_data/cash.text = "CASH: " + str(_player_cash)

# Instance a child of unit to the trench_battle sceen
func spawn_unit(unit_id: int, is_ally: bool, cost: int = 0, pos: Array = []) -> bool:
	if can_unit_spawn(is_ally, cost):
		_player_cash -= cost if is_ally else 0
		_ai_cash -= cost if not is_ally else 0
	else:
		return false
	
	var target_pos: int
	if pos.size() == 0:
		var pos_x = -1 if is_ally else HelperTrenchBattle.trench_size
		pos = [pos_x, randf() * (GlobalVaribles.BATTLEFIELD_HEIGHT)]
		target_pos = 0
	elif pos.size() == 1:
		pos = [pos[0], randf() * (GlobalVaribles.BATTLEFIELD_HEIGHT)]
		target_pos = pos[0]
	else:
		target_pos = pos[0]
	
	var inst_unit = UNIT_SCN.instance()
	var x_translate = HelperTrenchBattle.get_trench_location(pos[0])
	inst_unit.translate(Vector2(x_translate, pos[1]))
	$battle_field.add_child(inst_unit)
	inst_unit.init(unit_id, is_ally, target_pos)
	return true

func trench_at(index:int):
	if index >= GlobalVaribles.trench_pos.size():
		return false
	elif index < 0:
		return false
	return GlobalVaribles.trench_pos[index]

# Instance a trench in the correct sector
func spawn_trench(trench_id: int, trench_pos: int):
	var inst_unit = TRENCH_SCN.instance()
	var pos_x = HelperTrenchBattle.get_trench_location(trench_pos)
	var pos_y = GlobalVaribles.BATTLEFIELD_HEIGHT / 2
	inst_unit.translate(Vector2(pos_x, pos_y))
	$battle_field.add_child(inst_unit)
	inst_unit.init(trench_id, trench_pos)

# Load units from the lvl data
func load_units():
	var units = battle_data["units"]
	for index in range(units.size()):
		var current_unit = units[str(index)]
		var type_id = current_unit["unit_type_ID"]
		var is_ally = current_unit["is_ally"]
		var pos = current_unit["unit_position"]
		spawn_unit(type_id, is_ally, 0, pos)

# Loads trenches from lvl data
func load_trenches():
	var trenches = battle_data["trenches"]
	for index in range(trenches.size()):
		var current_trench = trenches[str(index)]
		var type_id = current_trench["trench_type_ID"]
		
		spawn_trench(type_id, index)

# Check if the unit can be spawend
func can_unit_spawn(for_ally: bool, unit_cost: int) -> bool:
	if for_ally:
		return unit_cost <= _player_cash
	else:
		return unit_cost <= _ai_cash






