extends Node

"""
All globaly used varibles and signals wil be accesable from here
"""

signal unit_shoot

# getset functions
const SCREEN_Y = 750.0
const SECTION = 200.0
const OFFSET = 300.0
const TOLLERANCE = 5.0

var trench_battle_ready: bool setget set_trench_battle_ready, get_trench_battle_ready
var trench_pos: Array = []

var trench_data: Dictionary setget ,get_trench_data
var unit_data: Dictionary setget ,get_unit_data
var lvl_data: Dictionary setget ,get_lvl_data

func _ready():
	trench_data = LoadData.load_trench_data()
	unit_data = LoadData.load_unit_data()


func get_unit_data_indexed(index: int) -> Dictionary:
	if index >= unit_data.size():
		return {}
	elif index < 0:
		return {}
	return unit_data[str(index)]

func get_trench_data_indexed(index: int):
	if index >= trench_data.size():
		return {}
	elif index < 0:
		return {}
	return trench_data[str(index)]

# Check if two numbers are within tollerance of eachother
func within_tollerance(x: float, y: float) -> bool:
	if abs(x - y) < TOLLERANCE:
		return true
	else:
		return false

#######################
###     SET GET     ###
#######################

func set_trench_battle_ready (value: bool):
	trench_battle_ready = value

func get_trench_battle_ready() -> bool:
	return trench_battle_ready
	
func get_trench_data() -> Dictionary:
	return trench_data
	
func get_unit_data() -> Dictionary:
	return unit_data

func set_lvl_data(lvl: int):
	lvl_data = LoadData.load_lvl_data(lvl)

func get_lvl_data() -> Dictionary:
	return lvl_data
