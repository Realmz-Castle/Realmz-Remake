var name : String = 'Heal Large Wounds'

var attributes : Array = ['Magical','Misc']
var tags : Array = ['Magical','Healing']

var schools : Array = ['Priest', 'Sorcerer']

# Fuction of target type, effect (phase), and line of sight
var targettile : int = 3  #0=anywhere 1=creature 2=empty 3=nowall

var school_levels : Dictionary = {"Sorcerer": 7, "Priest": 4, "Enchanter": 0}
var selection_costs : Dictionary = {"Sorcerer": 28, "Priest": 10, "Enchanter": 0}
var max_plevel : int = 7 # Is this ever not 7?
var in_field : bool = true
var in_combat : bool = true
var description : String = 'Heal Large Wounds:  Heals damage.'

var resist : int = 0 #ignores resistances and dodge 
var los : bool = true # line of sight
var ray : bool = false
var rot : bool = false
var proj_tex : String = 'Ball'
var proj_hit : String = 'Cloud'
var sounds : Array = ['dididup.wav', 'hit effect 4.wav']
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
	return 1

static func get_min_damage(_power:int, _casterchar) :
	return 3 * _power

static func get_max_damage(_power:int, _casterchar) :
	return 24 * _power

static func get_damage_roll(_power : int, _casterchar) :
	var scaled_damage = 0
	for i in range(_power) :
		scaled_damage += randi_range(3, 24)
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




