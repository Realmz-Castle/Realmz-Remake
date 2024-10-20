var name : String = 'Sparkling Armor'
var attributes : Array = []
var tags : Array = ['Magical', 'Buff']
var schools : Array = ['Sorcerer']
var targettile : int = 0  #0=anywhere 1=creature 2=empty 3=nowall 

var level : int = 1
var selection_cost : int = 1
var max_plevel : int = 7
var in_field : bool = true
var in_combat : bool = true
var description : String = 'Temporary Protection from Physical Attacks.'
var resist : int = 0 #ignores resistances and dodge
#var aoe : String = 'b1'
var los : bool = false
var ray : bool = false
var rot : bool = false
var proj_tex : String = 'Whirl'
var proj_hit : String = 'Target'
var sounds : Array = ['dididup.wav','hit effect 1.wav']
var max_focus_loss : int = 1

static func get_targets(_power : int, __casterchar)->int :
	return 1

static func get_min_duration(_power : int, __casterchar) -> int :
	return _power

static func get_max_duration(_power : int, __casterchar) -> int :
	return _power

static func get_range(_power : int, __casterchar) -> int :
	return 0
	
static func get_min_damage(_power:int, _casterchar) :
	return 0
	
static func get_max_damage(_power:int, _casterchar) :
	return 0
	
static func get_damage_roll(_power : int, _casterchar) :
	return 0

static func get_accuracy(_casterchar, _power : int) :
	return -7777777 #= infinite wiith resist==0 anyway

static func get_sp_cost(_power : int, _casterchar) :
	return 2*_power

static func get_target_number(_power : int, _casterchar) :
	return 1

static func get_aoe(_power : int, _casterchar) :
	return 'sf' #self

static func add_traits_to_target(_castercrea, c,_power) :
	var traitscript = load('res://shared_assets/traits/'+'t_pro_hits.gd')
	c.add_trait(traitscript,[_power])
