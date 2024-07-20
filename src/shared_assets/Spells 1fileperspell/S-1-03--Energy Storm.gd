var name : String = 'Energy Storm'
var attributes : Array = ['Magical', 'Electric']
var tags : Array = ['Magical', 'Electric']
var schools : Array = ['Sorcerer']

var targettile : int = 3  #0=anywhere 1=creature 2=empty 3=nowall 

var level : int = 1
var selection_cost : int = 1
var max_plevel : int = 7
var in_field : bool = false
var in_combat : bool = true
var description : String = 'Damage : 1-3 x Power\\n  Range : 6\\n  Target : Fixed Size, Large\\n   Sight : Yes\\nDuration : NA'
var resist : int = 3 #protected with resistances and dodge
#var aoe : String = 'b1'
var los : bool = true
var ray : bool = false
var rot : bool = false
var proj_tex : String = 'Spark'
var proj_hit : String = 'Spark'
var sounds : Array = ['spell launch 1.wav','electric energize.wav']
var max_focus_loss : int = 0

static func get_targets(_power : int, __casterchar)->int :
	return 1

#static func get_hits(_power : int, __casterchar)->int :
#	return 1

static func get_min_duration(_power : int, __casterchar) -> int :
	return 0

static func get_max_duration(_power : int, __casterchar) -> int :
	return 0

#static func get_duration_roll(_power : int, __casterchar) -> int :
#	return 0

static func get_range(_power : int, __casterchar) -> int :
	return 6
	
static func get_min_damage(_power:int, _casterchar) :
	return _power
	
static func get_max_damage(_power:int, _casterchar) :
	return _power * 3
	
static func get_damage_roll(_power : int, _casterchar) :
	var dmg = 0
	var mindmg = 1
	var maxdmg = 3
	for i in range(_power) :
		dmg += mindmg+ randi()%maxdmg
	return dmg

static func get_accuracy(_casterchar, _power : int) :
	return 0

static func get_sp_cost(_power : int, _casterchar) :
	return _power*10

static func get_target_number(_power : int, _casterchar) :
	return 1

static func get_aoe(_power : int, _casterchar) :
	return 'b5'
