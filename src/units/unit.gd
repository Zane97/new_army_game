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

onready var salt: float = randf() - 0.5

export var unit_type: String
export var movement_speed: float
export var firing_range: float
export var firing_acrcy: float
export var firing_speed: float
export var bomb_resistance: float
export var armour: float
export var is_defender: bool

export var has_own_data: bool = false
export var is_ally:bool
export var is_shooting:bool = false
export var target_pos: int
export var at_target: bool
export var fall_back: bool = false

var has_trench_buff: bool = false
var shooting_at


func _ready():
	randomize()
	GlobalVaribles.connect("unit_shoot", self, "shot")
	GlobalVaribles.connect("trench_skip", self, "skip")

func init(unit_id: int, ally: bool, target_position: int):
	var own_data = GlobalVaribles.get_unit_data_indexed(unit_id).duplicate()
	unit_type = own_data["unit_type"]
	movement_speed = own_data["movement_speed"]
	firing_range = own_data["firing_range"]
	firing_acrcy = own_data["firing_acrcy"]
	firing_speed = own_data["firing_speed"]
	bomb_resistance = own_data["bomb_resistance"]
	armour = own_data["armour"]
	is_defender = own_data["is_defender"]
	
	is_ally = ally
	add_salt()
	setup_fov(unit_id)
	target_pos = target_position
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
		move(movement_speed)
		at_target = HelperTrenchBattle.is_at_target(target_pos, global_position.x)
	
	# Remove fall_back if target trench is reached
	if at_target and fall_back:
		fall_back = false
	
	# apply buffs is at trench
	if at_target and not has_trench_buff:	
		has_trench_buff = true
		# TODO: APPLIE BUFFS
	
	# remove buffs on trench exit
	elif not at_target and has_trench_buff:
		has_trench_buff = false
		# TODO: REMOVE BUFFS

func shot(shot_at, enmy_firing_acrcy):
	if shot_at == $detection:
		if enmy_firing_acrcy > randf():
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
		at_target = false
		fall_back = is_fallback

func _on_shoot_timer_timeout():
	GlobalVaribles.emit_signal("unit_shoot", shooting_at, firing_acrcy)

func _on_fow_area_entered(area):
	is_shooting = true

func shoot_at_enemy() -> bool:
	var areas = $fow.get_overlapping_areas()
	if areas.size() > 0:
		if $shoot_timer.is_stopped():
			shooting_at = areas[randi()%areas.size()]
			$shoot_timer.start(firing_speed)
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
	movement_speed += movement_speed * salt * HelperTrenchBattle.SALT_STRENGTH
	firing_range += firing_range * salt * HelperTrenchBattle.SALT_STRENGTH
	firing_speed += firing_speed * salt * HelperTrenchBattle.SALT_STRENGTH
	firing_acrcy += firing_acrcy * salt * HelperTrenchBattle.SALT_STRENGTH

func setup_fov(unit_id: int):
	if is_ally:
		$fow.set_collision_mask_bit(1, true)
		$detection.set_collision_layer_bit(0, true)
	if not is_ally:
		$fow.set_collision_mask_bit(0, true)
		$detection.set_collision_layer_bit(1, true)
	
	var shapes = HelperTrenchBattle.get_shape(unit_id, salt)
	
	$fow/min_range.set_shape(shapes[0])
	$fow/range.set_shape(shapes[1])

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













