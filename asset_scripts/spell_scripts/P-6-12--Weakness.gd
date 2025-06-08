var name : String = 'Weakness'

var attributes : Array = ['Magical','Special']
var tags : Array = ['Magical']

var schools : Array = ['Priest']

# Fuction of target type, effect (phase), and line of sight
var targettile : int = 3  #0=anywhere 1=creature 2=empty 3=nowall

var school_levels : Dictionary = {"Sorcerer": 0, "Priest": 6, "Enchanter": 0}
var selection_costs : Dictionary = {"Sorcerer": 0, "Priest": 21, "Enchanter": 0}
var max_plevel : int = 7 # Is this ever not 7?
var in_field : bool = false
var in_combat : bool = true
var description : String = 'Weakness:  Drains a large amount of spell points from the target.'

var resist : int = 0 #ignores resistances and dodge 
var los : bool = true # line of sight
var ray : bool = true
var rot : bool = false
var proj_tex : String = 'Ball'
var proj_hit : String = 'Spinny'
var sounds : Array = ['spell launch 8.wav', 'hit effect 3.wav']
var max_focus_loss : int = 0 # Where does this come from?

# Is this number of targets?
static func get_targets(_power : int, __casterchar)->int :
	return 1

static func get_min_duration(_power : int, __casterchar) -> int :
	return 30

static func get_duration_roll(_power : int, __casterchar) -> int:
	var base_duration = randi_range(30, 50)
	return base_duration

static func get_max_duration(_power : int, __casterchar) -> int :
	return 50

static func get_range(_power : int, __casterchar) -> int :
	return 2 * _power

static func get_min_damage(_power:int, _casterchar) :
	return 0

static func get_max_damage(_power:int, _casterchar) :
	return 0

static func get_damage_roll(_power : int, _casterchar) :
	return 0

static func get_accuracy(_casterchar, _power : int) :
	return 100 #= infinite wiith resist==0 anyway

static func get_sp_cost(_power : int, _casterchar) :
	return _power*40

# How is this different from get_targets
static func get_target_number(_power : int, _casterchar) :
	return 1

# Area of effect (the shape of the spell target)
static func get_aoe(_power : int, _casterchar) :
	return 'b1'




