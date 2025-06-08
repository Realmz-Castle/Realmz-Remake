var name : String = 'Daze'

var attributes : Array = ['Magical','Charm']
var tags : Array = ['Magical']

var schools : Array = ['Enchanter']

# Fuction of target type, effect (phase), and line of sight
var targettile : int = 3  #0=anywhere 1=creature 2=empty 3=nowall

var school_levels : Dictionary = {"Sorcerer": 0, "Priest": 0, "Enchanter": 2}
var selection_costs : Dictionary = {"Sorcerer": 0, "Priest": 0, "Enchanter": 3}
var max_plevel : int = 7 # Is this ever not 7?
var in_field : bool = false
var in_combat : bool = true
var description : String = 'Daze: Will cause those affected to do one of several things.  They may attack their enemies, their friends, or run away.'

var resist : int = 0 #ignores resistances and dodge 
var los : bool = true # line of sight
var ray : bool = true
var rot : bool = false
var proj_tex : String = 'Ball'
var proj_hit : String = 'Spinny'
var sounds : Array = ['bloomp.wav', 'hit effect 4.wav']
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
	return 3 * _power

static func get_min_damage(_power:int, _casterchar) :
	return 0

static func get_max_damage(_power:int, _casterchar) :
	return 0

static func get_damage_roll(_power : int, _casterchar) :
	return 0

static func get_accuracy(_casterchar, _power : int) :
	return 100 #= infinite wiith resist==0 anyway

static func get_sp_cost(_power : int, _casterchar) :
	return _power*7

# How is this different from get_targets
static func get_target_number(_power : int, _casterchar) :
	return 1

# Area of effect (the shape of the spell target)
static func get_aoe(_power : int, _casterchar) :
	return 'b1'

static func add_traits_to_target(_casterchar : Creature, _targetcbbutton, _power):
	var traitscript = load('res://shared_assets/traits/'+'t_confused.gd')
	var trait_array : Array = [_power]
	_targetcbbutton.creature.add_trait(traitscript , trait_array)


