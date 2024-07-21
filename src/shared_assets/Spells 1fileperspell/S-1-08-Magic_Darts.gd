var name : String = 'Magic Darts'
var attributes : Array = ['Magical']
var tags : Array = ['Magical']
var schools : Array = ['Sorcerer']
var targettile : int = 1  #0=anywhere 1=creature 2=empty 3=nowall 

var level : int = 1
var selection_cost : int = 1
var max_plevel : int = 7
var in_field : bool = false
var in_combat : bool = true
var description : String = '1-5*Power damage, Power= targets, 15 Range.'
var resist : int = 2 #ignores evasion
#var aoe : String = 'b1'
var los : bool = true
var ray : bool = false
var rot : bool = false
var proj_tex : String = 'Spark'
var proj_hit : String = 'Spark'
var sounds : Array = ['bonk.wav','energy blast.wav']
var max_focus_loss : int = 0

static func get_targets(_power : int, __casterchar)->int :
	return _power

static func get_min_duration(_power : int, __casterchar) -> int :
	return 0

static func get_max_duration(_power : int, __casterchar) -> int :
	return 0

static func get_range(_power : int, __casterchar) -> int :
	return 15
	
static func get_min_damage(_power:int, _casterchar) :
	return 1
	
static func get_max_damage(_power:int, _casterchar) :
	return 5
	
static func get_damage_roll(_power : int, _casterchar) :
	var dmg = 0
	var mindmg = 1
	var maxdmg = 5
	for i in range(_power) :
		dmg += mindmg+ randi()%maxdmg
	return dmg

static func get_accuracy(_casterchar, _power : int) :
	return 1.0

static func get_sp_cost(_power : int, _casterchar) :
	return 4*_power

static func get_target_number(_power : int, _casterchar) :
	return _power

static func get_aoe(_power : int, _casterchar) :
	return 'b1'
