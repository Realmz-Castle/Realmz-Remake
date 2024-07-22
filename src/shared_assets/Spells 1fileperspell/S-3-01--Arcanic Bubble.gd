var name : String = 'Arcanic Bubble'
var attributes : Array = []
var tags : Array = ['Magical', 'Buff']
var schools : Array = ['Sorcerer']
var targettile : int = 0  #0=anywhere 1=creature 2=empty 3=nowall 

var level : int = 3
var selection_cost : int = 6
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
var sounds : Array = ['spell launch 6.wav','club.wav']
var max_focus_loss : int = 0

static func get_targets(_power : int, __casterchar)->int :
	return 0

static func get_min_duration(_power : int, __casterchar) -> int :
	return _power*5

static func get_max_duration(_power : int, __casterchar) -> int :
	return _power *10

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
	return 20*_power

static func get_target_number(_power : int, _casterchar) :
	return 0

static func get_aoe(_power : int, _casterchar) :
	return 'sf' #self

static func add_traits_to_target(_castercrea, c,_power) :
	var duration : int = 0 # in turns,  =5s
	for i in range(_power) :
		duration += 1+randi()% 2
	var traitscript = load('res://shared_assets/traits/'+'t_sp_absorb.gd')
	c.add_trait(traitscript,[duration])

