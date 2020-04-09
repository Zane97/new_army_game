extends Control

"""
Generate a row of buttons for all the units to display in.
when a button is pressed emits a signal for unit to spawn
"""

onready var unit_data: Dictionary = GlobalVaribles.unit_data

func _ready():
	load_buttons()


func load_buttons():
	for index in range(unit_data.size()):
		var unit_id = index
		var unit = unit_data[str(unit_id)]
		var unit_type = unit["unit_type"].to_upper()
		var cost = unit["cost"]
		add_button(unit_type, unit_id, cost)

func add_button(disp_text: String, signal_code: int, cost: int):
	var butt = Button.new()
	butt.text = disp_text
	butt.rect_size = Vector2(100, GlobalVaribles.BUTT_HEIGHT)
	butt.size_flags_horizontal = SIZE_EXPAND_FILL
	butt.connect("pressed", self, "_on_butt_pressed", [signal_code, cost])
	$h_box.add_child(butt)

func _on_butt_pressed(signal_code: int, cost: int):
	GlobalVaribles.emit_signal("unit_spawn", signal_code, true, cost)
