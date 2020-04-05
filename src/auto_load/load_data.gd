extends Node

"""
Loads all data that is stored in the data folder

TODO: Error if file doesn't load correctley 
"""

const DATA_PATH = "res://assets/data/"
const LVL_PATH = DATA_PATH + "lvl/"
const UNIT_FILE = DATA_PATH + "unit_data.json"
const TRENCH_FILE = DATA_PATH + "trench_data.json"

func load_lvl_data(lvl: int) -> Dictionary:
	var lvl_file = LVL_PATH + "%03d" % lvl + ".json"
	
	var file = File.new()
	file.open(lvl_file, file.READ)
	var text = file.get_as_text()
	var json_result = JSON.parse(text)
	file.close()
	
	if json_result.error == OK:  # If parse OK
		return json_result.result
	else:  # If parse has errors
		print("Error: ", json_result.error)
		print("Error Line: ", json_result.error_line)
		print("Error String: ", json_result.error_string)
		return {}
	
func load_unit_data() -> Dictionary:
	var file = File.new()
	file.open(UNIT_FILE, file.READ)
	var text = file.get_as_text()
	var json_result = JSON.parse(text)
	file.close()
	
	if json_result.error == OK:  # If parse OK
		return json_result.result
	else:  # If parse has errors
		print("Error: ", json_result.error)
		print("Error Line: ", json_result.error_line)
		print("Error String: ", json_result.error_string)
		return {}
	
func load_trench_data() -> Dictionary:
	var file = File.new()
	file.open(TRENCH_FILE, file.READ)
	var text = file.get_as_text()
	var json_result = JSON.parse(text)
	file.close()
	
	if json_result.error == OK:  # If parse OK
		return json_result.result
	else:  # If parse has errors
		print("Error: ", json_result.error)
		print("Error Line: ", json_result.error_line)
		print("Error String: ", json_result.error_string)
		return {}
