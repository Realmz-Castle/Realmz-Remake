var name : String = 'Plague'
var attributes : Array = ['Magical', 'Disease']
var tags : Array = ['Magical', 'Disease', 'Terrain', 'Nature']
var schools : Array = ['Sorcerer']

var targettile : int = 3  #0=anywhere 1=creature 2=empty 3=nowall 

var level : int = 3
var selection_cost : int = 6
var max_plevel : int = 7
var in_field : bool = false
var in_combat : bool = true
var description : String = 'Damage : 1-20\\n  Range : 8\\n  Target : Larger x Power\\n   Sight : Yes\\nDuration : 2-5\\n SP Cost : Power x 35'
var resist : int = 3 #protected with resistances and dodge
#var aoe : String = 'b1'
var los : bool = true
var ray : bool = false
var rot : bool = false
var proj_tex : String = 'Thorns'
var proj_hit : String = 'Thorns'
var sounds : Array = ['spell launch 5.wav','bite.wav']
var max_focus_loss : int = 0
var places_terrain : bool = true
var terrain_tex : String = 'Thn'
var terrain_walk_type : int = 0 #0=on entry and re entry this turn 1=every step

static func get_targets(_power : int, __casterchar)->int :
	return 1

#static func get_hits(_power : int, __casterchar)->int :
#	return 1

static func get_min_duration(_power : int, __casterchar) -> int :
	return 2

static func get_max_duration(_power : int, __casterchar) -> int :
	return 5

#static func get_duration_roll(_power : int, __casterchar) -> int :
#	return 0

static func get_range(_power : int, __casterchar) -> int :
	return 8
	
static func get_min_damage(_power:int, _casterchar) :
	return 1
	
static func get_max_damage(_power:int, _casterchar) :
	return 16
	
static func get_damage_roll(_power : int, _casterchar) :
	return 5+ randi()%11

static func get_accuracy(_casterchar, _power : int) :
	return 1.0

static func get_sp_cost(_power : int, _casterchar) :
	return _power*35

static func get_target_number(_power : int, _casterchar) :
	return 1

static func get_aoe(_power : int, _casterchar) :
	return ["b1","b2","b3","b4","b5","b6","b7"][_power]
