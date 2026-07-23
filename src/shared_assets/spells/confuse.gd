extends Spell

const ConfusionRules = preload(
	"res://scripts/classic_runtime/classic_confusion.gd"
)

func _init() -> void :
	name = "Confuse"
	elements = [GameGlobal.ELEMENTS.MAGICAL, GameGlobal.ELEMENTS.MENTAL]
	tags = ["Magical"]
	schools = ["Priest"]
	classic_spell_class = 5
	classic_spell_ids = [2301]
	classic_spell_save_index = 5
	classic_spell_save_mode = "negate"
	targettile = TARGET_TILE.NOWALL
	school_levels = {"Sorcerer": 0, "Priest": 3, "Enchanter": 0}
	selection_costs = {"Sorcerer": 0, "Priest": 6, "Enchanter": 0}
	in_combat = true
	description = "Confuse: Those affected may flee, attack friend or foe, or stand idle."
	resist = RESIST_TYPE.IGNORE_DODGE
	proj_tex = GFX.BALL
	proj_hit = GFX.SPINNY
	sounds = ["hit effect 4.wav", "prout.wav"]


func get_range(_power : int, _caster) -> int :
	return 9

func get_min_duration(power : int, _caster) -> int :
	return power

func get_duration_roll(power : int, _caster) -> int :
	return power

func get_max_duration(power : int, _caster) -> int :
	return power

func get_sp_cost(power : int, _caster) -> int :
	return power * 15

func get_aoe(_power : int, _caster) -> Array[Vector2i] :
	return AoE_b7

func add_traits_to_creature(caster, target, power : int) -> void :
	if ConfusionRules.has_permanent_condition(target):
		return
	var trait_script = load("res://shared_assets/traits/t_classic_confused.gd")
	target.add_trait(trait_script, [get_duration_roll(power, caster)])
