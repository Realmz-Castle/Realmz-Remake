var name : String = 'Free Fall'

var attributes : Array = ['Magical','Misc']
var tags : Array = ['Magical']

var schools : Array = ['Priest', 'Sorcerer']

# Fuction of target type, effect (phase), and line of sight
var targettile : int = 3  #0=anywhere 1=creature 2=empty 3=nowall

var school_levels : Dictionary = {"Sorcerer": 1, "Priest": 1, "Enchanter": 0}
var selection_costs : Dictionary = {"Sorcerer": 1, "Priest": 1, "Enchanter": 0}
var max_plevel : int = 7 # Is this ever not 7?
var in_field : bool = false
var in_combat : bool = false
var description : String = 'Free Fall:  Allows the party to descend down pits and cliffs without taking damage.'

var resist : int = 0 #ignores resistances and dodge 
var los : bool = true # line of sight
var ray : bool = false
var rot : bool = false
var proj_tex : String = 'Ball'
var proj_hit : String = 'Target'
var sounds : Array = ['wind.wav', 'boing.wav']
var max_focus_loss : int = 0 # Where does this come from?

# Is this number of targets?
static func get_targets(_power : int, __casterchar)->int :
	return 1

static func get_min_duration(_power : int, __casterchar) -> int :
	return 2 * _power

static func get_duration_roll(_power : int, __casterchar) -> int:
	var scaled_duration = 0
	for i in range(_power) :
		scaled_duration += randi_range(2, 4)
	return scaled_duration

static func get_max_duration(_power : int, __casterchar) -> int :
	return 4 * _power

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
	return _power*10

# How is this different from get_targets
static func get_target_number(_power : int, _casterchar) :
	return 1

# Area of effect (the shape of the spell target)
static func get_aoe(_power : int, _casterchar) :
	return 'b1'

static func add_traits_to_target(_casterchar : Creature, _targetcbbutton, _power):
	var traitscript = load('res://shared_assets/traits/'+'t_dumb.gd')
	var trait_array : Array = [_power]
	_targetcbbutton.creature.add_trait(traitscript , trait_array)

static func special_effect(_castercrea, _spell, _power, _main_targeted_tile, _effected_tiles, _effected_creas, _add_terrain) -> bool :
	var duration = 0
	for i in range(_power) :
		duration += 20 + randi()% 21
	GameGlobal.global_effects['FeatherFall']['Duration'] += _power * duration
	UI.ow_hud.updateGlobalEffectsDisplay()
	return true
