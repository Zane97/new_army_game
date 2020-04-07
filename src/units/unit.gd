extends Node2D

"""
Note: Gets instanced, should never be placed
	: init() should be called imediatley after sceen gets added to tree

TODO:
	Rework and move get_(x)_buff to helper_trench_battle

Controll all the features of a unit like: shooting, moving, waiting at a trench

Each unit has variation in its movment, firing range, firing speed and firing_acrcy 
detirmend by a once generated random number(salt)
"""

const SALT_STRENGTH = 0.1

export var own_data: Dictionary
export var has_own_data: bool = false
export var is_ally:bool
export var is_shooting:bool = false
export var target_pos: int
export var at_target: bool
export var fall_back: bool = false

var has_trench_buff: bool = false
var shooting_at
var salt: float = randf() - 0.5

func _ready():
	randomize()
	GlobalVaribles.connect("unit_shoot", self, "shot")
	GlobalVaribles.connect("trench_skip", self, "skip")

func init(unit_id: int, ally: bool, position: int):
	own_data = GlobalVaribles.get_unit_data_indexed(unit_id).duplicate()
	is_ally = ally
	add_salt()
	setup_fov()
	target_pos = position
	at_target = HelperTrenchBattle.is_at_target(target_pos, global_position.x)
	has_own_data = true

func _process(delta):
	
	if not HelperTrenchBattle.trench_battle_ready:
		pass
	elif not has_own_data:
		pass
	elif is_shooting:
		is_shooting = shoot_at_enemy()
		pass
	elif not at_target:
		move(own_data["movement_speed"])
		at_target = HelperTrenchBattle.is_at_target(target_pos, global_position.x)
	
	# Remove fall_back if target trench is reached
	if at_target and fall_back:
		fall_back = false
	
	# apply buffs is at trench
	if at_target and not has_trench_buff:	
		has_trench_buff = true
		var range_buff = get_range_buff()
		set_fow_shape(range_buff)
	# remove buffs on trench exit
	elif not at_target and has_trench_buff:
		has_trench_buff = false
		var range_buff = get_range_buff()
		set_fow_shape(range_buff)

func shot(shot_at, enmy_firing_acrcy):
	if shot_at == $detection:
		if enmy_firing_acrcy > randf():
			var armour = own_data["armour"]
			armour += armour * get_armour_buff()
			if armour < randf():
				queue_free()

func skip(index: int, for_ally: bool, is_fallback: bool = false):
	# Check if unit is in correct army
	# Check if units target_trench is giving the signal
	# Check if unit is at target
	
	if (for_ally == is_ally) and (target_pos == index) and at_target:
		var direction = true if is_ally else false
		direction = not direction if is_fallback else direction
		target_pos = HelperTrenchBattle.next_target_pos(target_pos, direction)

func _on_shoot_timer_timeout():
	GlobalVaribles.emit_signal("unit_shoot", shooting_at, own_data["firing_acrcy"])

func _on_fow_area_entered(area):
	is_shooting = true

func shoot_at_enemy() -> bool:
	var areas = $fow.get_overlapping_areas()
	if areas.size() > 0:
		if $shoot_timer.is_stopped():
			shooting_at = areas[randi()%areas.size()]
			$shoot_timer.start(own_data["firing_speed"])
		return true
	return false

# Move the unit in the correct direction
func move(speed: float):	
	if is_ally:
		if not fall_back: 
			global_position.x += speed
		else:
			global_position.x -= speed
	else:
		if not fall_back:
			global_position.x -= speed
		else:
			global_position.x += speed

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
	if at_target:
		var lvl_data = GlobalVaribles.lvl_data
		var trenches = lvl_data["trenches"]
		var trench = trenches[str(target_pos)]
		var trench_id = trench["trench_type_ID"]
		
		var curr_trench = GlobalVaribles.get_trench_data_indexed(trench_id)
		var armour_buff = curr_trench["armour_buff"]
		return armour_buff
	return 0.0

func get_range_buff() -> float:
	if at_target:
		var lvl_data = GlobalVaribles.lvl_data
		var trenches = lvl_data["trenches"]
		var trench = trenches[str(target_pos)]
		var trench_id = trench["trench_type_ID"]
		
		var cur_trench = GlobalVaribles.get_trench_data_indexed(trench_id)
		var range_buff = cur_trench["range_buff"]
		return range_buff
	return 0.0

func get_bomb_resistance_buff() -> float:
	if at_target:
		var lvl_data = GlobalVaribles.get_lvl_data()
		var trenches = lvl_data["trenches"]
		var trench = trenches[str(target_pos)]
		var trench_id = trench["trench_type_ID"]
		
		var cur_trench = GlobalVaribles.get_trench_data_indexed(trench_id)
		var bomb_resistance_buff = cur_trench["bomb_resistance_buff"]
		return bomb_resistance_buff
	return 0.0













