var name : String = 'Radiate'
var attributes : Array = ['Magical', 'Buff']
var tags : Array = ['Magical', 'Melee', 'Buff']
var schools : Array = ['Sorcerer']

var targettile : int = 1  #0=anywhere 1=creature 2=empty 3=nowall 

var level : int = 4
var selection_cost : int = 10
var max_plevel : int = 7
var in_field : bool = true
var in_combat : bool = true
var description : String = 'Renders the target completely immune to 2nd Level Spells.'
var resist : int = 0 # ignores dodge and drvs
#var aoe : String = 'b1'
var los : bool = false
var ray : bool = false
var rot : bool = false
var proj_tex : String = 'Whirl'
var proj_hit : String = 'Sphere'
var sounds : Array = ['teleport.wav','door slam.wav']
var max_focus_loss : int = 1

static func get_targets(_power : int, __casterchar)->int :
	return 1

#static func get_hits(_power : int, __casterchar)->int :
#	return 1

static func get_min_duration(_power : int, __casterchar) -> int :
	return _power *1

static func get_max_duration(_power : int, __casterchar) -> int :
	return _power *2

#static func get_duration_roll(_power : int, __casterchar) -> int :
#	return 0

static func get_range(_power : int, __casterchar) -> int :
	return 0
	
static func get_min_damage(_power:int, _casterchar) :
	return 0
	
static func get_max_damage(_power:int, _casterchar) :
	return 0
	
static func get_damage_roll(_power : int, _casterchar) :
	return 0

static func get_accuracy(_casterchar, _power : int) :
	return 1.0

static func get_sp_cost(_power : int, _casterchar) :
	return _power*25

static func get_target_number(_power : int, _casterchar) :
	return 1

static func get_aoe(_power : int, _casterchar) :
	return 'rd' #radiate, all adjacent

static func add_traits_to_target(_castercrea, c,_power) :
	var min_duration : int = get_min_duration(_power, _castercrea)
	var max_duration : int = get_max_duration(_power, _castercrea)
	var duration : int = min_duration + randi() % (max_duration - min_duration +1)
	var traitscript = load('res://shared_assets/traits/'+'t_spell_lvl_prot.gd')
	c.add_trait(traitscript,[duration, 2])
