extends RefCounted
class_name Spell

# Base class for class-based spells. See spells/classes/MagicDarts.gd for an example.
# get_X functions are static so subclasses override at the class level — this
# matches the existing pattern from JSON-defined spells. Callers can still
# invoke them on either the class or an instance: GDScript dispatches a static
# call via either.

enum TARGET_TILE { ANY = 0, CREATURE = 1, EMPTY = 2, NOWALL = 3 }



const AoE_2v : Array[Vector2i] = [Vector2i(0,0), Vector2i(0,1)]
const AoE_b1 : Array[Vector2i] = [Vector2i(0,0)]
const AoE_b2 : Array[Vector2i] = [Vector2i(0,0),Vector2i(0,-1),Vector2i(1,0),Vector2i(0,1),Vector2i(-1,0)]
const AoE_b3 : Array[Vector2i] = [Vector2i(0,0),Vector2i(0,-1),Vector2i(1,0),Vector2i(0,1),Vector2i(-1,0),
								  Vector2i(1,-1),Vector2i(1,1),Vector2i(-1,1),Vector2i(-1,-1)]
const AoE_b4 : Array[Vector2i] = [Vector2i(0,0),Vector2i(0,-1),Vector2i(1,0),Vector2i(0,1),Vector2i(-1,0),
								  Vector2i(1,-1),Vector2i(1,1),Vector2i(-1,1),Vector2i(-1,-1),Vector2i(0,-2),
								  Vector2i(2,0),Vector2i(0,2),Vector2i(-2,0)]
const AoE_b5 : Array[Vector2i] = [Vector2i(0,0),Vector2i(0,-1),Vector2i(1,0),Vector2i(0,1),Vector2i(-1,0),
								  Vector2i(1,-1),Vector2i(1,1),Vector2i(-1,1),Vector2i(-1,-1),Vector2i(0,-2),
								  Vector2i(2,0),Vector2i(0,2),Vector2i(-2,0),Vector2i(1,-2),Vector2i(2,-1),
								  Vector2i(2,1),Vector2i(1,2), Vector2i(-1,2),Vector2i(-2,1),Vector2i(-2,-1),
								  Vector2i(-1,-2)]
const AoE_b6 : Array[Vector2i] = [Vector2i(0,0),Vector2i(0,-1),Vector2i(1,0),Vector2i(0,1),Vector2i(-1,0),
								  Vector2i(1,-1),Vector2i(1,1),Vector2i(-1,1),Vector2i(-1,-1),Vector2i(0,-2),
								  Vector2i(2,0),Vector2i(0,2), Vector2i(-2,0),Vector2i(1,-2),Vector2i(2,-1),
								  Vector2i(2,1),Vector2i(1,2), Vector2i(-1,2),Vector2i(-2,1),Vector2i(-2,-1),
								  Vector2i(-1,-2),Vector2i(0,-3),Vector2i(3,0),Vector2i(0,3),Vector2i(-3,0)]
const AoE_b7 : Array[Vector2i] = [Vector2i(0,0),Vector2i(0,-1),Vector2i(1,0),Vector2i(0,1),Vector2i(-1,0),
								  Vector2i(1,-1),Vector2i(1,1),Vector2i(-1,1),Vector2i(-1,-1),Vector2i(0,-2),
								  Vector2i(2,0),Vector2i(0,2), Vector2i(-2,0),Vector2i(1,-2),Vector2i(2,-1),
								  Vector2i(2,1),Vector2i(1,2), Vector2i(-1,2),Vector2i(-2,1),Vector2i(-2,-1),
								  Vector2i(-1,-2),Vector2i(0,-3),Vector2i(3,0),Vector2i(0,3),Vector2i(-3,0),
								  Vector2i(1,-3),Vector2i(2,-2),Vector2i(3,-1), Vector2i(3,1),Vector2i(2,2),Vector2i(1,3), Vector2i(-1,3),Vector2(-2,2),Vector2(-3,1), Vector2(-3,-1),Vector2(-2,-2),Vector2(-1,-3)]

const AoE_ROUND : Array[Vector2i] = AoE_b5  #For Energy Storm, Adrenalin, etc.

const AoE_WALL_H : Array[Vector2i] = [Vector2i(0,0),Vector2i(-1,0),Vector2i(1,0),Vector2i(-2,0),Vector2i(2,0),Vector2i(-3,0),Vector2i(3,0),
									  Vector2i(0,-1),Vector2i(-1,-1),Vector2i(1,-1),Vector2i(-2,-1),Vector2i(2,-1),Vector2i(-3,-1),Vector2i(3,-1)]
const AoE_WALL_V : Array[Vector2i] = [Vector2i(0,0),Vector2i(0,-1),Vector2i(0,1),Vector2i(0,-2),Vector2i(0,2),Vector2i(0,-3),Vector2i(0,3),
									  Vector2i(1,0),Vector2i(1,-1),Vector2i(1,1),Vector2i(1,-2),Vector2i(1,2),Vector2i(1,-3),Vector2i(1,3) ]
const AoE_WALL_J : Array[Vector2i] = [Vector2i(0,0),Vector2i(-1,-1),Vector2i(1,1),Vector2i(-2,-2),Vector2i(2,2),Vector2i(-3,-3),Vector2i(3,3),
									  Vector2i(0,1),Vector2i(-1,-0),Vector2i(1,2),Vector2i(-2,-1),Vector2i(2,3),Vector2i(-3,-2)]
const AoE_WALL_L : Array[Vector2i] = [Vector2i(0,0),Vector2i(1,-1),Vector2i(-1,1),Vector2i(2,-2),Vector2i(-2,2),Vector2i(3,-3),Vector2i(-3,3),
									  Vector2i(0,1),Vector2i(1,-0),Vector2i(-1,2),Vector2i(2,-1),Vector2i(-2,3),Vector2i(3,-2)]
const AoE_CROWN : Array[Vector2i] = [Vector2i(1,-1),Vector2i(1,1),Vector2i(-1,1),Vector2i(-1,-1) , Vector2i(0,-2),Vector2i(2,0),Vector2i(0,2),Vector2i(-2,0)]#b3+b4
const AoE_RADIANT : Array[Vector2i] = [Vector2i(0,-1),Vector2i(1,0),Vector2i(0,1),Vector2i(-1,0) , Vector2i(1,-1),Vector2i(1,1),Vector2i(-1,1),Vector2i(-1,-1)]

const AoE_b_SCALING : Array[Array] = [AoE_b1, AoE_b1,AoE_b2,AoE_b3,AoE_b4,AoE_b5,AoE_b6,AoE_b7] #b1 repeated so index = power level can start at 1


enum GFX {NONE=-1, ARROW=0, DART=1, AXE=2, WEB=3, TARGET=4, FIRE=5, MIASMA=6, CLOUD=7, ICE=8, SPARK=9, SPINNY=10,SLIME=11, WHIRL=12, BALL=13, SPHERE=14, THORNS=15}

enum RESIST_TYPE {IGNORE_MRES_DODGE = 0, IGNORE_MRES = 1, IGNORE_DODGE = 2, IGNORE_NOTHING = 3}

var name : String = ""
var description : String = ""
# Combat traits use these broad delivery attributes independently from damage
# elements. Projectile protection, for example, should not depend on whether a
# missile deals fire or physical damage.
var attributes : Array = []
var elements : Array[GameGlobal.ELEMENTS] = []
var tags : Array = []
var schools : Array = []
# Classic spells also carry an effect class. Complex encounters can match
# classes 1-6 instead of a packed spell-table ID.
var classic_spell_class : int = 0
# Classic targeting modes 9, 10, and 12 bypass spell reflection. Native
# spells retain zero, which follows Remake's ordinary targeted-spell behavior.
var classic_target_type : int = 0
# A non-empty list limits this resource to Classic table entries whose
# mechanics it represents. Empty lists retain the existing name-based fallback.
var classic_spell_ids : Array[int] = []
# Response aliases let one native learned spell answer equivalent Classic
# caster-list entries without claiming that their casting mechanics are equal.
var classic_spell_response_ids : Array[int] = []
# Classic field spells use a damage-type save from 0-7. A value of -1 means
# the spell has no out-of-combat save. Successful saves either negate the
# effect or halve its damage, matching resolvespell.c.
var classic_spell_save_index : int = -1
var classic_spell_save_mode : String = "none"
var classic_save_bonus : int = 0
var classic_save_adjust : int = 0
# Negative non-missile damage types in Classic run a target-versus-caster
# level check before other resistance and save stages. Native resources opt in
# to that behavior directly without reproducing the signed byte encoding.
var classic_opposed_level_check : bool = false
# Classic general magic resistance is a separate all-or-nothing roll. Native
# spells leave this at zero; mapped and compiled Classic spells may override it.
var classic_resist_adjust : int = 0

var targettile : TARGET_TILE = TARGET_TILE.NOWALL
var school_levels : Dictionary = {"Sorcerer": 0, "Priest": 0, "Enchanter": 0}
var selection_costs : Dictionary = {"Sorcerer": 0, "Priest": 0, "Enchanter": 0}
var max_plevel : int = 7 #1-7
var in_field : bool = false
var in_combat : bool = false


var resist : RESIST_TYPE = 0


var los : bool = true
var ray : bool = false
var rot : bool = false


enum AUTOTARGET_TYPE {NONE, SELF, ALL_ALLIES, ALL_ENEMIES, EVERYONE, PARTY}

var skip_targeting : bool = false
# auto included to the AoE :
var autotarget_type : AUTOTARGET_TYPE = AUTOTARGET_TYPE.NONE


var proj_tex : GFX = -1
var proj_hit : GFX = -1
var sounds : Array = []
var max_focus_loss : int = 0
# Persistent battlefield spells opt into these fields. Keeping them on the
# common spell contract lets the combat runtime distinguish an absent effect
# from a malformed spell resource.
var terrain_tex : String = ""
var terrain_walk_type : int = 0


func get_targets(_power : int, _caster) -> int :
	return 1

func get_min_duration(_power : int, _caster) -> int :
	return 0

func get_duration_roll(_power : int, _caster) -> int :
	return 0

func get_max_duration(_power : int, _caster) -> int :
	return 0

func get_range(_power : int, _caster) -> int :
	return 0

func get_min_damage(_power : int, _caster) -> int :
	return 0

func get_max_damage(_power : int, _caster) -> int :
	return 0

func get_damage_roll(_power : int, _caster) -> int :
	return 0

func get_accuracy(_caster, _power : int) -> int :
	return 100

func get_evasion(_caster, _power : int) -> int :
	return 0

func get_sp_cost(_power : int, _caster) -> int :
	return 0

func get_target_number(_power : int, _caster) -> int :
	return 1

func get_aoe(_power : int, _caster) -> Array[Vector2i] :
	return AoE_b1

func uses_classic_opposed_level_check() -> bool :
	return classic_opposed_level_check

func add_traits_to_creature(_caster : Creature, _target : Creature, _power : int) -> void :
	pass

func supports_classic_spell_id(spell_id : int) -> bool :
	return classic_spell_ids.is_empty() or spell_id in classic_spell_ids


func is_classic_queued_spell() -> bool:
	return false


# Returns this spell's source code as a string, suitable for storing in a
# character or item save file. GDScript surfaces source via the script
# object, so we have to step through get_script() rather than `self`.
func generate_json_string() -> String :
	var s : Script = get_script()
	if s == null :
		return ""
	return s.source_code

func get_element_color(elem : GameGlobal.ELEMENTS) -> Color:
	if GameGlobal.elements_ColorDict.has(elem) :
		return GameGlobal.elements_ColorDict[elem]
	return Color.GRAY

func get_spell_dominant_color() ->Color :
	for elem : GameGlobal.ELEMENTS in elements :
		if GameGlobal.elements_ColorDict.has(elem) :
			return GameGlobal.elements_ColorDict[elem]
	return Color.WHITE
