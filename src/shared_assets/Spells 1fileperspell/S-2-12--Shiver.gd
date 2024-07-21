var name : String = 'Shiver'
var attributes : Array = ['Magical', 'Ice']
var tags : Array = ['Magical', 'Ice']
var schools : Array = ['Sorcerer']

var targettile : int = 1  #0=anywhere 1=creature 2=empty 3=nowall 

var level : int = 2
var selection_cost : int = 3
var max_plevel : int = 7
var in_field : bool = false
var in_combat : bool = true
var description : String = 'Damage : 1-2 x Power (Ice)\\n  Target : All Enemies\\n   Sight : No\\nDuration : NA\\nSP Cost : 25 * power'
var resist : int = 3 #protected with resistances and dodge
#var aoe : String = 'b1'
var los : bool = true
var ray : bool = false
var rot : bool = false
var proj_tex : String = 'Ice'
var proj_hit : String = 'Ice'
var sounds : Array = ['wind.wav','electric energize.wav']
var max_focus_loss : int = 1

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
	return _power
	
static func get_max_damage(_power:int, _casterchar) :
	return _power * 2
	
static func get_damage_roll(_power : int, _casterchar) :
	var dmg = 0
	var mindmg = 1
	var maxdmg = 2
	for i in range(_power) :
		dmg += mindmg+ randi()%maxdmg
	return dmg

static func get_accuracy(_casterchar, _power : int) :
	return 1.0

static func get_sp_cost(_power : int, _casterchar) :
	return _power*20

static func get_target_number(_power : int, _casterchar) :
	return 0

static func get_aoe(_power : int, _casterchar) :
	return 'ae'
