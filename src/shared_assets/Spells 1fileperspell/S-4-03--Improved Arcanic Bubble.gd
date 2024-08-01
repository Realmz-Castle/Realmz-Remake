var name : String = 'Improved Arcanic Bubble'
var attributes : Array = []
var tags : Array = ['Magical', 'Buff', 'Improved']
var schools : Array = ['Sorcerer']
var targettile : int = 0  #0=anywhere 1=creature 2=empty 3=nowall 

var level : int = 4
var selection_cost : int = 10
var max_plevel : int = 7
var in_field : bool = true
var in_combat : bool = true
var description : String = 'Allows the Target to absorb Spell Points from spells that affect the Target.'
var resist : int = 0 #ignores resistances and dodge
#var aoe : String = 'b1'
var los : bool = false
var ray : bool = false
var rot : bool = false
var proj_tex : String = 'Cloud'
var proj_hit : String = 'Sphere'
var sounds : Array = ['spell launch 3.wav','club.wav']
var max_focus_loss : int = 0

static func get_targets(_power : int, __casterchar)->int :
	return _power

static func get_min_duration(_power : int, __casterchar) -> int :
	return 2 *5

static func get_max_duration(_power : int, __casterchar) -> int :
	return 6 *5

static func get_range(_power : int, __casterchar) -> int :
	return 4
	
static func get_min_damage(_power:int, _casterchar) :
	return 0
	
static func get_max_damage(_power:int, _casterchar) :
	return 0
	
static func get_damage_roll(_power : int, _casterchar) :
	return 0

static func get_accuracy(_casterchar, _power : int) :
	return -7777777 #= infinite wiith resist==0 anyway

static func get_sp_cost(_power : int, _casterchar) :
	return 30*_power

static func get_target_number(_power : int, _casterchar) :
	return _power

static func get_aoe(_power : int, _casterchar) :
	return 'b1' #1 tile

static func add_traits_to_target(_castercrea, c,_power) :
	var min_duration : int = get_min_duration(_power, _castercrea)
	var max_duration : int = get_max_duration(_power, _castercrea)
	var duration : int = min_duration + randi() % (max_duration - min_duration +1)
	var traitscript = load('res://shared_assets/traits/'+'t_sp_absorb.gd')
	c.add_trait(traitscript,[duration])

