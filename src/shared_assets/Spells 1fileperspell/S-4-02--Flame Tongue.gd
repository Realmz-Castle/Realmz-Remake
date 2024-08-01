var name : String = 'Scorched Earth'
var attributes : Array = ['Fire', 'Magical']
var tags : Array = ['Fire', 'Magical', 'Ray']
var schools : Array = ['Sorcerer']
var targettile : int = 0  #0=anywhere 1=creature 2=empty 3=nowall 

var level : int = 4
var selection_cost : int = 10
var max_plevel : int = 7
var in_field : bool = false
var in_combat : bool = true
var description : String = 'Fires a piercing Fire Ray\\nFire : 8-16  \\n   Sight : yes\\nSP cost : Power * 18'
var resist : int = 3 #protected with resistances and dodge
#var aoe : String = 'b1'
var los : bool = true
var ray : bool = true
var rot : bool = false
var proj_tex : String = 'Fire'
var proj_hit : String = 'Fire'
var sounds : Array = ['spell launch 2.wav','small explode.wav']

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
	return _power*2
	
static func get_min_damage(_power:int, _casterchar) :
	return 8
	
static func get_max_damage(_power:int, _casterchar) :
	return 16
	
static func get_damage_roll(_power : int, _casterchar) :
	return 8+ randi()%9

static func get_accuracy(_casterchar, _power : int) :
	return 1.0

static func get_sp_cost(_power : int, _casterchar) :
	return _power*18

static func get_target_number(_power : int, _casterchar) :
	return 1

static func get_aoe(_power : int, _casterchar) :
	return 'b1'
