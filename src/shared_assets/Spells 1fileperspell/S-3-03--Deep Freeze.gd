var name : String = 'Deep Freeze'
var attributes : Array = ['Ice', 'Magical']
var targettile : int = 0  #0=anywhere 1=creature 2=empty 3=nowall 
var schools : Array = ['Sorcerer']
var level : int = 3
var selection_cost : int = 6
var max_plevel : int = 7
var in_field : bool = false
var in_combat : bool = true
var description : String = 'Fires a piercing Ice Ray\\nDamage : 1-10 * Power\\n  Range : 10\\n   Sight : yes\\nSP cost : Power * 15'
var resist : int = 3 #protected with resistances and dodge
#var aoe : String = 'b1'
var los : bool = true
var ray : bool = true
var rot : bool = false
var proj_tex : String = 'Ice'
var proj_hit : String = 'Ice'
var sounds : Array = ['wind.wav','electric energize.wav']

static func get_targets(_power : int, _casterchar)->int :
	return 1

static func get_hits(_power : int, _casterchar)->int :
	return 1

static func get_min_duration(_power : int, _casterchar) -> int :
	return 0

static func get_max_duration(_power : int, _casterchar) -> int :
	return 0

static func get_duration_roll(_power : int, _casterchar) -> int :
	return 0

static func get_range(_power : int, _casterchar) -> int :
	return 10
	
static func get_min_damage(_power:int, _casterchar) :
	return 1
	
static func get_max_damage(_power:int, _casterchar) :
	return 10
	
static func get_damage_roll(_power : int, _casterchar) :
	var dmg = 0
	var mindmg = 1
	var maxdmg = 10
	for i in range(_power) :
		dmg += mindmg+ randi()%(maxdmg-mindmg+1)
	return dmg

static func get_accuracy(_casterchar, _power : int) :
	return 1.0

static func get_sp_cost(_power : int, _casterchar) :
	return _power*15

static func get_target_number(_power : int, _casterchar) :
	return 1

static func get_aoe(_power : int, _casterchar) :
	return 'b1'
