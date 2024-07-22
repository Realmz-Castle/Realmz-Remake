var name : String = 'Plane of Force'
var attributes : Array = ['Magical']
var tags : Array = ['Magical', 'Terrain', 'Wall']
var schools : Array = ['Sorcerer']
var targettile : int = 4  #0=anywhere 1=creature 2=empty 3=nowall 4=anywhere

var level : int = 3
var selection_cost : int = 6
var max_plevel : int = 7
var in_field : bool = false
var in_combat : bool = true
var description : String = 'Creates icy hurty terrain'
var resist : int = 3 #ignores dodge
#var aoe : String = 'wh'
var los : bool = true
var ray : bool = false
var rot : bool = true
var proj_tex : String = 'Target'
var proj_hit : String = 'Sphere'
var sounds : Array = ['hit effect 3.wav','prout.wav']
var places_terrain : bool = true
var terrain_tex : String = 'Orb'
var terrain_walk_type : int = 0 #0=on entry and re entry this turn 1=every step

static func get_range(_power : int, _casterchar) -> int :
	return 8

static func get_targets(_power : int, _casterchar)->int :
	return 1  #i this ever used ?

static func get_target_number(_power : int, _casterchar) :
	return 1

static func get_hits(_power : int, _casterchar)->int :
	return 1

static func get_min_duration(_power : int, _casterchar) -> int :
	return 1

static func get_max_duration(_power : int, _casterchar) -> int :
	return 4

static func get_duration_roll(_power : int, _casterchar) -> int :
	return 1+randi()%4

static func get_sp_cost(_power : int, _casterchar) :
	return _power*25

static func get_aoe(_power : int, _casterchar) :
	return 'wh'

static func get_min_damage(_power:int, _casterchar) :
	return 2*_power
	
static func get_max_damage(_power:int, _casterchar) :
	return 8*_power

static func get_accuracy(_casterchar, _power : int) :
	return 1.0

static func get_damage_roll(_power : int, _casterchar) :
	var dmg = 0
	var mindmg = 2
	var maxdmg = 8
	for i in range(_power) :
		dmg += mindmg+ randi()%(maxdmg-mindmg+1)
	return dmg
