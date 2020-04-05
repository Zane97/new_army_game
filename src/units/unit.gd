extends Node2D

"""
Note: Gets instanced, should never be placed
	: init() should be called imediatley after sceen gets added to tree

Controll all the features of a unit like: shooting, moving, waiting at a trench

Each unit has variation in its movment, firing range, firing speed and firing_acrcy 
detirmend by a once generated random number(salt)
"""

const SALT_STRENGTH = 0.1

export var own_data: Dictionary
export var has_own_data: bool = false
export var is_ally:bool
export var is_shooting:bool = false
export var current_pos: int = -1
export var target_pos: int = 1

var trench_range: bool = false
var shooting_at
var salt: float = randf() - 0.5

func init(unit_id: int, ally: bool):
	own_data = GlobalVaribles.get_unit_data_indexed(unit_id).duplicate()
	is_ally = ally
	add_salt()
	current_pos = get_current_pos()
	setup_fov()
	has_own_data = true

func _process(delta):
	# TODO:
	# Check if unit is shooting
	
	if not GlobalVaribles.trench_battle_ready:
		pass
	elif not has_own_data:
		pass
	elif is_shooting:
		is_shooting = shoot_at_enemy()
		pass
	elif current_pos == -1 or current_pos != target_pos:
		move(own_data["movement_speed"], delta)
		current_pos = get_current_pos()
	
	# apply buffs is at trench
	if current_pos >= 0 and not trench_range:	
		trench_range = true
		var range_buff = get_range_buff()
		set_fow_shape(range_buff)
		
	elif current_pos < 0 and trench_range:
		trench_range = false
		var range_buff = get_range_buff()
		set_fow_shape(range_buff)
	
func _ready():
	randomize()
	GlobalVaribles.connect("unit_shoot", self, "shot")

func shot(shot_at, enmy_firing_acrcy):
	if shot_at == $detection:
		if enmy_firing_acrcy > randf():
			var armour = own_data["armour"]
			armour += armour * get_armour_buff()
			if armour < randf():
				queue_free()

func _on_shoot_timer_timeout():
	GlobalVaribles.emit_signal("unit_shoot", shooting_at, own_data["firing_acrcy"])

func _on_fow_area_entered(area):
	is_shooting = true

func shoot_at_enemy() -> bool:
	var areas = $fow.get_overlapping_areas()
	print(areas)
	if areas.size() > 0:
		if $shoot_timer.is_stopped():
			shooting_at = areas[randi()%areas.size()]
			print(shooting_at)
			$shoot_timer.start(own_data["firing_speed"])
		return true
	return false

# Return the next trench to which the unit can go
func get_next_trench(cur_pos: int) -> int:
	var trench_pos = GlobalVaribles.trench_pos
	if is_ally:
		for index in range(cur_pos+1, trench_pos.size()):
			if trench_pos[index]:
				return index
		return trench_pos.size()
	else:
		for index in range(cur_pos-1, -1, -1):
			if trench_pos[index]:
				return index
		return -1

# Return current trench position if at a trench else -1
func get_current_pos() -> int:
	var trench_pos = GlobalVaribles.trench_pos
	var trench_index = 0
	
	for index in range(trench_pos.size()):
		if trench_pos[index]:
			var trench_translation = index * GlobalVaribles.SECTION
			trench_translation += GlobalVaribles.OFFSET
			
			if GlobalVaribles.within_tollerance(trench_translation, global_position.x):
				return trench_index
			
			trench_index += 1
	return -1

func move(speed: float, delta):
	if is_ally:
		global_position.x += speed * delta
	else:
		global_position.x -= speed * delta

# Randomize some stats of the unit
func add_salt():
	own_data["movement_speed"] += own_data["movement_speed"] * salt * SALT_STRENGTH
	own_data["firing_range"] += own_data["firing_range"] * salt * SALT_STRENGTH
	own_data["firing_speed"] += own_data["firing_speed"] * salt * SALT_STRENGTH
	own_data["firing_acrcy"] += own_data["firing_acrcy"] * salt * SALT_STRENGTH

func setup_fov():
	if is_ally:
		$fow.set_collision_mask_bit(1, true)
		$detection.set_collision_layer_bit(0, true)
	if not is_ally:
		$fow.set_collision_mask_bit(0, true)
		$detection.set_collision_layer_bit(1, true)
	
	var range_buff = get_range_buff()
	set_fow_shape(range_buff)

func set_fow_shape(range_buff: float = 0.0):
	var unit_range = own_data["firing_range"] + range_buff

	var min_range_shape = RectangleShape2D.new()
	$fow/min_range.set_shape(min_range_shape)
	min_range_shape.set_extents(Vector2(unit_range/2,GlobalVaribles.SCREEN_Y))
	
	var range_shape = CircleShape2D.new()
	$fow/range.set_shape(range_shape)
	range_shape.set_radius(unit_range)

# returns a arour buff if unit is at trench
func get_armour_buff() -> float:
	if trench_range:
		var lvl_data = GlobalVaribles.lvl_data
		var trenches = lvl_data["trenches"]
		var trench = trenches[str(current_pos)]
		var trench_id = trench["trench_type_ID"]
		
		var curr_trench = GlobalVaribles.get_trench_data_indexed(trench_id)
		var armour_buff = curr_trench["armour_buff"]
		return armour_buff
	return 0.0

func get_range_buff() -> float:
	if trench_range:
		var lvl_data = GlobalVaribles.get_lvl_data()
		var trenches = lvl_data["trenches"]
		var trench = trenches[str(current_pos)]
		var trench_id = trench["trench_type_ID"]
		
		var cur_trench = GlobalVaribles.get_trench_data_indexed(trench_id)
		var range_buff = cur_trench["range_buff"]
		return range_buff
	return 0.0

func get_bomb_resistance_buff() -> float:
	if trench_range:
		var lvl_data = GlobalVaribles.get_lvl_data()
		var trenches = lvl_data["trenches"]
		var trench = trenches[str(current_pos)]
		var trench_id = trench["trench_type_ID"]
		
		var cur_trench = GlobalVaribles.get_trench_data_indexed(trench_id)
		var bomb_resistance_buff = cur_trench["bomb_resistance_buff"]
		return bomb_resistance_buff
	return 0.0













