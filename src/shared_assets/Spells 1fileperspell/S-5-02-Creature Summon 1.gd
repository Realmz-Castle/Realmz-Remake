var name : String = 'Creature Summon 1'
var attributes : Array = []
var tags : Array = ['Magical', 'Summon']
var schools : Array = ['Enchanter','Sorcerer']
var targettile : int = 2  #0=anywhere 1=creature 2=empty 3=nowall 

var level : int = 5
var selection_cost : int = 15
var max_plevel : int = 7
var in_field : bool = false
var in_combat : bool = true
var description : String = 'Will cause creatures to appear from the void and fight for the caster.'
var resist : int = 2 #ignores evasion
#var aoe : String = 'b1'
var los : bool = false
var ray : bool = false
var rot : bool = false
var proj_tex : String = 'Ball'
var proj_hit : String = 'Sphere'
var sounds : Array = ['pinball bumper.wav','jump.wav']
var max_focus_loss : int = 0

const ixi : Array = [Vector2i.ZERO]
const ixii : Array = [Vector2i.ZERO, Vector2i.DOWN]
const iixi : Array = [Vector2i.ZERO, Vector2i.RIGHT]
const iixii : Array = [Vector2i.ZERO, Vector2i.DOWN, Vector2i.RIGHT, Vector2i.ONE]



static func get_targets(_power : int, __casterchar)->int :
	return _power

static func get_min_duration(_power : int, __casterchar) -> int :
	return 0

static func get_max_duration(_power : int, __casterchar) -> int :
	return 0

static func get_range(_power : int, __casterchar) -> int :
	return 24
	
static func get_min_damage(_power:int, _casterchar) :
	return 0
	
static func get_max_damage(_power:int, _casterchar) :
	return 0
	
static func get_damage_roll(_power : int, _casterchar) :
	return 0

static func get_accuracy(_casterchar, _power : int) :
	return 1.0

static func get_sp_cost(_power : int, _casterchar) :
	return 1*_power

static func get_target_number(_power : int, _casterchar) :
	return _power

static func get_aoe(_power : int, _casterchar) :
	return [ixi, ixii, iixi, iixii].pick_random()

static func special_effect(_castercrea, _spell, _power, _main_targeted_tile, _effected_tiles, _effected_creas, _add_terrain) :
	print('CREATURE SUMMON1 SPECIAL')
	var newpos : Vector2 = _main_targeted_tile
	var CreatureGD : GDScript = load('res://Creature/Creature.gd')
	var creascript = CreatureGD.new()
	var aoe_shape : Array = GameGlobal.map.targetingLayer.aoe_shape
	var creature_name : String = ''
	match aoe_shape :
		ixi :
			creature_name = ScriptHelperFuncs.get_random_creature_of_size(Vector2i.ONE, false, 3)
		ixii :
			creature_name = ScriptHelperFuncs.get_random_creature_of_size(Vector2i(1,2), false, 3)
		iixi :
			creature_name = ScriptHelperFuncs.get_random_creature_of_size(Vector2i(2,1), false, 3)
		iixii :
			creature_name = ScriptHelperFuncs.get_random_creature_of_size(Vector2i(2,2), false, 3)
		_ :
			creature_name = ScriptHelperFuncs.get_random_creature_of_size(Vector2i.ONE, false, 3)
	creascript.initialize_from_bestiary_dict(creature_name)
	print('SPECIAL aftre init from bestiary')
	creascript.position = newpos
	creascript.is_summoned = true
	creascript.summoner_name = _castercrea.name
	creascript.summoner = _castercrea
	creascript.baseFaction = _castercrea.baseFaction
	creascript.curFaction = _castercrea.curFaction
	StateMachine.combat_state.add_pc_or_npc_ally_to_battle_map(creascript, newpos)
	return true
