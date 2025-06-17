var name : String = 'Multi Regenerate Stamina'

var attributes : Array = ['Magical','Special']
var tags : Array = ['Magical']

var schools : Array = ['Enchanter']

# Fuction of target type, effect (phase), and line of sight
var targettile : int = 1  #0=anywhere 1=creature 2=empty 3=nowall

var school_levels : Dictionary = {"Sorcerer": 0, "Priest": 0, "Enchanter": 7}
var selection_costs : Dictionary = {"Sorcerer": 0, "Priest": 0, "Enchanter": 28}
var max_plevel : int = 7 # Is this ever not 7?
var in_field : bool = true
var in_combat : bool = true
var description : String = 'Multi Regenerate Stamina:  Those affected will regenerate stamina at an accelerate rate.  This spell will even affect those of elven blood.'

var resist : int = 0 #ignores resistances and dodge 
var los : bool = false # line of sight
var ray : bool = false
var rot : bool = false
var proj_tex : String = 'Target'
var proj_hit : String = 'Miasma'
var sounds : Array = ['prout.wav', 'big splat.wav']
var max_focus_loss : int = 0 # Where does this come from?

# Is this number of targets?
static func get_targets(_power : int, __casterchar)->int :
	return 1

static func get_min_duration(_power : int, __casterchar) -> int :
	return 5

static func get_duration_roll(_power : int, __casterchar) -> int:
	var base_duration = randi_range(5, 15)
	return base_duration

static func get_max_duration(_power : int, __casterchar) -> int :
	return 15

static func get_range(_power : int, __casterchar) -> int :
	return 7

static func get_min_damage(_power:int, _casterchar) :
	return 0

static func get_max_damage(_power:int, _casterchar) :
	return 0

static func get_damage_roll(_power : int, _casterchar) :
	return 0

static func get_accuracy(_casterchar, _power : int) :
	return 100 #= infinite wiith resist==0 anyway

static func get_sp_cost(_power : int, _casterchar) :
	return _power*50

# How is this different from get_targets
static func get_target_number(_power : int, _casterchar) :
	return 1

# Area of effect (the shape of the spell target)
static func get_aoe(_power : int, _casterchar) :
	return 'b1'

static func add_traits_to_target(_casterchar : Creature, _targetcbbutton, _power):
	var traitscript = load('res://shared_assets/traits/'+'t_hp_regen.gd')
	var trait_array : Array = [_power]
	_targetcbbutton.creature.add_trait(traitscript , trait_array)


