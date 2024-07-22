var name : String = 'Slug'
var attributes : Array = []
var tags : Array = ['Magical', 'Debuff']
var schools : Array = ['Priest','Sorcerer']
var targettile : int = 3  #0=anywhere 1=creature 2=empty 3=nowall 
var level : int = 3
var selection_cost : int = 6
var max_plevel : int = 7
var in_field : bool = false
var in_combat : bool = true
var description : String = 'This spell adds a magical substance to the bloodstream. All those affected will move slower and have fewer Actions per Round than normal.'
var resist : int = 3 #dodgeable and  drvsablle
#var aoe : String = 'b1'
var los : bool = true
var ray : bool = false
var rot : bool = false
var proj_tex : String = 'Web'
var proj_hit : String = 'Web'
var sounds : Array = ['spell launch 4.wav','hit effect 1.wav']
var max_focus_loss : int = 0

var places_terrain : bool = true
var terrain_tex : String = 'Web'
var terrain_walk_type : int = 0 #0=on entry and re entry this turn 1=every step



static func get_targets(_power : int, __casterchar)->int :
	return 1

static func get_min_duration(_power : int, __casterchar) -> int :
	return _power * 1

static func get_max_duration(_power : int, __casterchar) -> int :
	return _power * 2

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
	return 20*_power

static func get_target_number(_power : int, _casterchar) :
	return 1

static func get_aoe(_power : int, _casterchar) :
	return 'cr'

static func add_traits_to_target(_castercrea, c,_power) :
	var duration = 0
	for i in range(_power) :
		duration += 1 + randi()% 2
	var traitscript = load('res://shared_assets/traits/'+'t_slow.gd')
	c.add_trait(traitscript,[duration])

