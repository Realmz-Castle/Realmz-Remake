var name : String = 'Limited Phase'
var attributes : Array = ['Magical']
var tags : Array = ['Magical', 'Teleportation']
var schools : Array = ['Sorcerer']
var targettile : int = 2  #0=anywhere 1=creature 2=empty 3=nowall 
var level : int = 2
var selection_cost : int = 3
var max_plevel : int = 7
var in_field : bool = false
var in_combat : bool = true
var description : String = 'Allows the user to teleport during combat. The user move is over after the phase.\\nSP cost : Power * 10'
var resist : int = 0 #ignores resistances and dodge
#var aoe : String = 'b1'
var los : bool = false
var ray : bool = false
var rot : bool = false
var proj_tex : String = 'Cloud'
var proj_hit : String = 'Sphere'
var sounds : Array = ['prout.wav','prout.wav']

static func get_targets(_power : int, _casterchar)->int :
	return 1

static func get_hits(_power : int, _casterchar)->int :
	return 0

static func get_min_duration(_power : int, _casterchar) -> int :
	return 0

static func get_max_duration(_power : int, _casterchar) -> int :
	return 0

static func get_duration_roll(_power : int, _casterchar) -> int :
	return 0

static func get_range(_power : int, _casterchar) -> int :
	return _power*2
	
static func get_min_damage(_power:int, _casterchar) :
	return 0
	
static func get_max_damage(_power:int, _casterchar) :
	return 0
	
static func get_damage_roll(_power : int, _casterchar) :
	return 0

static func get_accuracy(_casterchar, _power : int) :
	return -7777777 #= infinite

static func get_sp_cost(_power : int, _casterchar) :
	return _power*10

static func get_target_number(_power : int, _casterchar) :
	return 1

static func get_aoe(_power : int, _casterchar) :
	return 'b1'

static func special_effect(_castercrea, _spell, _power, _main_targeted_tile, _effected_tiles, _effected_creas, _add_terrain) :
	var newtpos : Vector2 = _main_targeted_tile
	_castercrea.combat_button.position  = Utils.GRID_SIZE * newtpos
	_castercrea.position = newtpos
	_castercrea.used_apr = 1000
	return true
