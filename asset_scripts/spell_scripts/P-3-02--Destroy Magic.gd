var name : String = 'Destroy Magic'

var attributes : Array = ['Magical','Misc']
var tags : Array = ['Magical']

var schools : Array = ['Priest', 'Sorcerer', 'Enchanter']

# Fuction of target type, effect (phase), and line of sight
var targettile : int = 1  #0=anywhere 1=creature 2=empty 3=nowall

var school_levels : Dictionary = {"Sorcerer": 3, "Priest": 3, "Enchanter": 5}
var selection_costs : Dictionary = {"Sorcerer": 6, "Priest": 6, "Enchanter": 15}
var max_plevel : int = 7 # Is this ever not 7?
var in_field : bool = true
var in_combat : bool = true
var description : String = 'Destroy Magic:  This spell will remove all non-permanent spell effects on those it is cast on.'

var resist : int = 0 #ignores resistances and dodge 
var los : bool = false # line of sight
var ray : bool = false
var rot : bool = false
var proj_tex : String = 'Ball'
var proj_hit : String = 'Whirl'
var sounds : Array = ['spell launch 8.wav', 'hit effect 3.wav']
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
	return 10

static func get_min_damage(_power:int, _casterchar) :
	return 0

static func get_max_damage(_power:int, _casterchar) :
	return 0

static func get_damage_roll(_power : int, _casterchar) :
	return 0

static func get_accuracy(_casterchar, _power : int) :
	return 100 #= infinite wiith resist==0 anyway

static func get_sp_cost(_power : int, _casterchar) :
	return _power*15

# How is this different from get_targets
static func get_target_number(_power : int, _casterchar) :
	return 1

# Area of effect (the shape of the spell target)
static func get_aoe(_power : int, _casterchar) :
	return 'b1'



static func special_effect(_castercrea, _spell, _power, _main_targeted_tile, _effected_tiles, _effected_creas, _add_terrain) :
	for c : Creature in _effected_creas :
		var removed : Array = []
		for t in c .traits :
			if t.permanent : removed.append(t)
		for t in removed :
			c.remove_trait(t)
	return true

