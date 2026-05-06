class_name Spell
extends RefCounted

# Base class for class-based spells. See spells/classes/MagicDarts.gd for an example.
# get_X functions are static so subclasses override at the class level — this
# matches the existing pattern from JSON-defined spells. Callers can still
# invoke them on either the class or an instance: GDScript dispatches a static
# call via either.

enum TargetTile { ANY = 0, CREATURE = 1, EMPTY = 2, NOWALL = 3 }

var name : String = ""
var attributes : Array = []
var tags : Array = []
var schools : Array = []

var targettile : int = TargetTile.NOWALL
var school_levels : Dictionary = {"Sorcerer": 0, "Priest": 0, "Enchanter": 0}
var selection_costs : Dictionary = {"Sorcerer": 0, "Priest": 0, "Enchanter": 0}
var max_plevel : int = 7
var in_field : bool = false
var in_combat : bool = false
var description : String = ""

var resist : int = 0
var los : bool = true
var ray : bool = false
var rot : bool = false
var proj_tex : String = ""
var proj_hit : String = ""
var sounds : Array = []
var max_focus_loss : int = 0


static func get_targets(_power : int, _caster) -> int :
	return 1

static func get_min_duration(_power : int, _caster) -> int :
	return 0

static func get_duration_roll(_power : int, _caster) -> int :
	return 0

static func get_max_duration(_power : int, _caster) -> int :
	return 0

static func get_range(_power : int, _caster) -> int :
	return 0

static func get_min_damage(_power : int, _caster) -> int :
	return 0

static func get_max_damage(_power : int, _caster) -> int :
	return 0

static func get_damage_roll(_power : int, _caster) -> int :
	return 0

static func get_accuracy(_caster, _power : int) -> int :
	return 100

static func get_sp_cost(_power : int, _caster) -> int :
	return 0

static func get_target_number(_power : int, _caster) -> int :
	return 1

static func get_aoe(_power : int, _caster) -> String :
	return "b1"


# Returns this spell's source code as a string, suitable for storing in a
# character or item save file. GDScript surfaces source via the script
# object, so we have to step through get_script() rather than `self`.
func generate_json_string() -> String :
	var s : Script = get_script()
	if s == null :
		return ""
	return s.source_code
