var name : String = 'Enchanted Blade'
var attributes : Array = []
var tags : Array = ['Magical', 'Buff']
var schools : Array = ['Enchanter', 'Sorcerer']

var targettile : int = 1  #0=anywhere 1=creature 2=empty 3=nowall 

var level : int = 1
var selection_cost : int = 1
var max_plevel : int = 7
var in_field : bool = true
var in_combat : bool = true
var description : String = 'Will cause the target to do more damage during combat.\\A weapon is not required.\\nSP cost : Power * 2'
var resist : int = 0 #ignores resistances and dodge
#var aoe : String = 'b1'
var los : bool = true
var ray : bool = false
var rot : bool = false
var proj_tex : String = 'Ball'
var proj_hit : String = 'Target'
var sounds : Array = ['spell launch 5.wav','clash.wav']
var max_focus_loss : int = 0

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
	return 5
	
static func get_min_damage(_power:int, _casterchar) :
	return 0
	
static func get_max_damage(_power:int, _casterchar) :
	return 0
	
static func get_damage_roll(_power : int, _casterchar) :
	return 0

static func get_accuracy(_casterchar, _power : int) :
	return 100 #= infinite wiith resist==0 anyway

static func get_sp_cost(_power : int, _casterchar) :
	return _power*2

static func get_target_number(_power : int, _casterchar) :
	return 1

static func get_aoe(_power : int, _casterchar) :
	return 'b1'

static func add_traits_to_target(_casterchar : Creature, _targetcbbutton : CombatCreaButton, _power : int) :
	var traitscript = load('res://shared_assets/traits/'+'t_phys_dmg_bonus.gd')
	var trait_array : Array = [_power]  #no need to add teh character at index 0, done in creaure.gd add_trait
	_targetcbbutton.creature.add_trait(traitscript , trait_array)
