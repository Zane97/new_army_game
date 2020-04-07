extends Node2D

"""
Note: Gets instanced, should never be placed
	: init() should be called imediatley after sceen gets added to tree

responsible for all the funcunality of the trench like, charge, fallback
"""

export var own_data: Dictionary
export var own_index: int

func init(trench_id: int, index: int):
	own_index = index
	own_data = GlobalVaribles.get_trench_data_indexed(trench_id)


func _on_carge_butt_pressed():
	GlobalVaribles.emit_signal("trench_skip", own_index, true, false)


func _on_fallback_butt_pressed():
	GlobalVaribles.emit_signal("trench_skip", own_index, true, true)


func _on_skip_butt_toggled(button_pressed):
	pass # Replace with function body.
