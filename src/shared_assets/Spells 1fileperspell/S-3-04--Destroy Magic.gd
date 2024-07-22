var name : String = 'Destroy Magic'
var attributes : Array = []
var tags : Array = ['Magical', 'Healing', 'Debuff']
var schools : Array = ['Priest','Sorcerer']
var targettile : int = 1  #0=anywhere 1=creature 2=empty 3=nowall 
var level : int = 3
var selection_cost : int = 6
var max_plevel : int = 7
var in_field : bool = true
var in_combat : bool = true
var description : String = 'Removes all non-permanent Magical effects on the target.'
var resist : int = 0 #ignores resistances and dodge
#var aoe : String = 'b1'
var los : bool = true
var ray : bool = false
var rot : bool = false
var proj_tex : String = 'Whirl'
var proj_hit : String = 'Ball'
var sounds : Array = ['spell launch 8.wav','pops.wav']
var max_focus_loss : int = 0

static func get_targets(_power : int, __casterchar)->int :
	return _power

static func get_min_duration(_power : int, __casterchar) -> int :
	return 0

static func get_max_duration(_power : int, __casterchar) -> int :
	return 0

static func get_range(_power : int, __casterchar) -> int :
	return 10
	
static func get_min_damage(_power:int, _casterchar) :
	return 0
	
static func get_max_damage(_power:int, _casterchar) :
	return 0
	
static func get_damage_roll(_power : int, _casterchar) :
	return 0

static func get_accuracy(_casterchar, _power : int) :
	return -7777777 #= infinite wiith resist==0 anyway

static func get_sp_cost(_power : int, _casterchar) :
	return 15*_power

static func get_target_number(_power : int, _casterchar) :
	return _power

static func get_aoe(_power : int, _casterchar) :
	return 'b1' #self

static func add_traits_to_target(_castercrea, c,_power) :
	var duration = 0
	for i in range(_power) :
		duration += 20 + randi()% 31
	var traitscript = load('res://shared_assets/traits/'+'t_invisible.gd')
	c.add_trait(traitscript,[duration])


static func special_effect(_castercrea, _spell, _power, _main_targeted_tile, _effected_tiles, _effected_creas, _add_terrain) :
	for c : Creature in _effected_creas :
		var removed : Array = []
		for t in c .traits :
			if t.permanent : removed.append(t)
		for t in removed :
			c.remove_trait(t)
	return true
