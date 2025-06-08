var name : String = 'Heat Ray'

var attributes : Array = ['Magical','Fire']
var tags : Array = ['Magical']

var schools : Array = ['Enchanter']

# Fuction of target type, effect (phase), and line of sight
var targettile : int = 3  #0=anywhere 1=creature 2=empty 3=nowall

var school_levels : Dictionary = {"Sorcerer": 0, "Priest": 0, "Enchanter": 2}
var selection_costs : Dictionary = {"Sorcerer": 0, "Priest": 0, "Enchanter": 3}
var max_plevel : int = 7 # Is this ever not 7?
var in_field : bool = false
var in_combat : bool = true
var description : String = 'Heat Ray\n\n Damage: 2-8\n    Range: 2 x Power\n    Target: Ray\n      Sight: Yes\nDuration: NA'

var resist : int = 0 #ignores resistances and dodge 
var los : bool = true # line of sight
var ray : bool = true
var rot : bool = false
var proj_tex : String = 'Fire'
var proj_hit : String = 'Fire'
var sounds : Array = ['spell launch 1.wav', 'small explode.wav']
var max_focus_loss : int = 0 # Where does this come from?

# Is this number of targets?
static func get_targets(_power : int, __casterchar)->int :
	return 1

static func get_min_duration(_power : int, __casterchar) -> int :
	return 0

static func get_duration_roll(_power : int, __casterchar) -> int:
	return 0
static func get_max_duration(_power : int, __casterchar) -> int :
	return 0

static func get_range(_power : int, __casterchar) -> int :
	return 2 * _power

static func get_min_damage(_power:int, _casterchar) :
	return 2

static func get_max_damage(_power:int, _casterchar) :
	return 8

static func get_damage_roll(_power : int, _casterchar) :
	var base_damage = randi_range(2, 8)
	return base_damage

static func get_accuracy(_casterchar, _power : int) :
	return 100 #= infinite wiith resist==0 anyway

static func get_sp_cost(_power : int, _casterchar) :
	return _power*10

# How is this different from get_targets
static func get_target_number(_power : int, _casterchar) :
	return 1

# Area of effect (the shape of the spell target)
static func get_aoe(_power : int, _casterchar) :
	return 'b1'




