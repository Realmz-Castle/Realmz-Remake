var name : String = 'Shine'

var attributes : Array = ['Magical','Misc']
var tags : Array = ['Magical']

var schools : Array = ['Sorcerer', 'Priest']

# Fuction of target type, effect (phase), and line of sight
var targettile : int = 3  #0=anywhere 1=creature 2=empty 3=nowall

var school_levels : Dictionary = {"Sorcerer": 1, "Priest": 1, "Enchanter": 0}
var selection_costs : Dictionary = {"Sorcerer": 1, "Priest": 1, "Enchanter": 0}
var max_plevel : int = 7 # Is this ever not 7?
var in_field : bool = true
var in_combat : bool = false
var description : String = 'Shine:  Will cause a magical flame to illuminate dark areas.'

var resist : int = 0 #ignores resistances and dodge 
var los : bool = true # line of sight
var ray : bool = false
var rot : bool = false
var proj_tex : String = 'Whirl'
var proj_hit : String = 'Target'
var sounds : Array = ['spell launch 2.wav', 'spell launch 2.wav']
var max_focus_loss : int = 0 # Where does this come from?

# Is this number of targets?
static func get_targets(_power : int, __casterchar)->int :
	return 1

static func get_min_duration(_power : int, __casterchar) -> int :
	return 30 * _power

static func get_duration_roll(_power : int, __casterchar) -> int:
	var scaled_duration = 0
	for i in range(_power) :
		scaled_duration += randi_range(30, 30)
	return scaled_duration

static func get_max_duration(_power : int, __casterchar) -> int :
	return 30 * _power

static func get_range(_power : int, __casterchar) -> int :
	return 0

static func get_min_damage(_power:int, _casterchar) :
	return 0

static func get_max_damage(_power:int, _casterchar) :
	return 0

static func get_damage_roll(_power : int, _casterchar) :
	return 0

static func get_accuracy(_casterchar, _power : int) :
	return 100 #= infinite wiith resist==0 anyway

static func get_sp_cost(_power : int, _casterchar) :
	return _power*3

# How is this different from get_targets
static func get_target_number(_power : int, _casterchar) :
	return 1

# Area of effect (the shape of the spell target)
static func get_aoe(_power : int, _casterchar) :
	return 'b1'



static func special_effect(_castercrea, _spell, _power, _main_targeted_tile, _effected_tiles, _effected_creas, _add_terrain) -> bool :
	GameGlobal.add_light_effect(_power, 1200*_power)
	return true
