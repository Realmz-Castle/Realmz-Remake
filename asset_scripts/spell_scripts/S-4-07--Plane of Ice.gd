var name : String = 'Plane of Ice'

var attributes : Array = ['Magical','Ice']
var tags : Array = ['Magical']

var schools : Array = ['Sorcerer']

# Fuction of target type, effect (phase), and line of sight
var targettile : int = 3  #0=anywhere 1=creature 2=empty 3=nowall

var school_levels : Dictionary = {"Sorcerer": 4, "Priest": 0, "Enchanter": 0}
var selection_costs : Dictionary = {"Sorcerer": 10, "Priest": 0, "Enchanter": 0}
var max_plevel : int = 7 # Is this ever not 7?
var in_field : bool = false
var in_combat : bool = true
var description : String = 'Plane of Ice\n\n Damage: 2-10 x Power\n    Range: 10\n    Target: Can Rotate\n      Sight: Yes\nDuration: 1-4 rounds'

var resist : int = 0 #ignores resistances and dodge 
var los : bool = true # line of sight
var ray : bool = false
var rot : bool = true
var proj_tex : String = 'Ice'
var proj_hit : String = 'Ice'
var sounds : Array = ['spell launch 5.wav', 'electric energize.wav']
var max_focus_loss : int = 0 # Where does this come from?

# Is this number of targets?
static func get_targets(_power : int, __casterchar)->int :
	return 1

static func get_min_duration(_power : int, __casterchar) -> int :
	return 1

static func get_duration_roll(_power : int, __casterchar) -> int:
	var base_duration = randi_range(1, 4)
	return base_duration

static func get_max_duration(_power : int, __casterchar) -> int :
	return 4

static func get_range(_power : int, __casterchar) -> int :
	return 10

static func get_min_damage(_power:int, _casterchar) :
	return 2 * _power

static func get_max_damage(_power:int, _casterchar) :
	return 10 * _power

static func get_damage_roll(_power : int, _casterchar) :
	var scaled_damage = 0
	for i in range(_power) :
		scaled_damage += randi_range(2, 10)
	return scaled_damage

static func get_accuracy(_casterchar, _power : int) :
	return 100 #= infinite wiith resist==0 anyway

static func get_sp_cost(_power : int, _casterchar) :
	return _power*30

# How is this different from get_targets
static func get_target_number(_power : int, _casterchar) :
	return 1

# Area of effect (the shape of the spell target)
static func get_aoe(_power : int, _casterchar) :
	return 'b1'




