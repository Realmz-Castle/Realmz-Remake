var name : String = 'Frozen Palm'
var attributes : Array = ['Magical',]
var tags : Array = ['Magical', 'Melee']
var schools : Array = ['Sorcerer']

var targettile : int = 1  #0=anywhere 1=creature 2=empty 3=nowall 

var level : int = 2
var selection_cost : int = 3
var max_plevel : int = 7
var in_field : bool = false
var in_combat : bool = true
var description : String = 'Damage : 2-6 x Power\\n  Range : Touch\\n  Target : Single\\n   Sight : Yes\\nIgnores Evasion'
var resist : int = 1 #ignores dodge
#var aoe : String = 'b1'
var los : bool = true
var ray : bool = false
var rot : bool = false
var proj_tex : String = 'Spinny'
var proj_hit : String = 'Sphere'
var sounds : Array = ['bwabble.wav','door slam.wav']
var max_focus_loss : int = 1

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
	return 1
	
static func get_min_damage(_power:int, _casterchar) :
	return _power *2
	
static func get_max_damage(_power:int, _casterchar) :
	return _power * 6
	
static func get_damage_roll(_power : int, _casterchar) :
	var dmg = 0
	var mindmg = 2
	var maxdmg = 6
	for i in range(_power) :
		dmg += mindmg+ randi()%(maxdmg-mindmg+1)
	return dmg

static func get_accuracy(_casterchar, _power : int) :
	return 1.0

static func get_sp_cost(_power : int, _casterchar) :
	return _power*4

static func get_target_number(_power : int, _casterchar) :
	return 1

static func get_aoe(_power : int, _casterchar) :
	return 'b1'
