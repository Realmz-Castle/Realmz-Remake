var name : String = 'Open Lock'
var attributes : Array = []
var tags : Array = ['Magical', 'Special Encounter', 'Open Lock']
var schools : Array = ['Enchanter','Sorcerer']

var targettile : int = 0  #0=anywhere 1=creature 2=empty 3=nowall 

var level : int = 1
var selection_cost : int = 1
var max_plevel : int = 1
var in_field : bool = false
var in_combat : bool = false
var description : String = 'Will open a lock. This spell will not always work. It depends on the complexity of the lock.\\nSP cost : 15'
var resist : int = 0 #ignores resistances and dodge
var los : bool = true
var ray : bool = false
var rot : bool = false
var proj_tex : String = 'Ball'
var proj_hit : String = 'Target'
var sounds : Array = ['pops.wav','identify.wav']
var max_focus_loss : int = 0

static func get_targets(_power : int, __casterchar)->int :
	return 0

#static func get_hits(_power : int, __casterchar)->int :
#	return 1

static func get_min_duration(_power : int, __casterchar) -> int :
	return 0

static func get_max_duration(_power : int, __casterchar) -> int :
	return 0

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
	return _power #= infinite wiith resist==0 anyway

static func get_sp_cost(_power : int, _casterchar) :
	return 15

static func get_target_number(_power : int, _casterchar) :
	return 0

static func get_aoe(_power : int, _casterchar) :
	return 'sf'

