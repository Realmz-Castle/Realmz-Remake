extends Spell

const ConfusionRules = preload(
	"res://scripts/classic_runtime/classic_confusion.gd"
)

func _init() -> void :
	name = "Daze"
	elements = [GameGlobal.ELEMENTS.MAGICAL, GameGlobal.ELEMENTS.MENTAL]
	tags = ["Magical"]
	schools = ["Enchanter"]
	classic_spell_class = 0
	classic_spell_ids = [3202]
	classic_spell_save_index = 0
	classic_spell_save_mode = "negate"
	classic_save_bonus = -15
	targettile = TARGET_TILE.NOWALL
	school_levels = {"Sorcerer": 0, "Priest": 0, "Enchanter": 2}
	selection_costs = {"Sorcerer": 0, "Priest": 0, "Enchanter": 3}
	in_combat = true
	description = "Daze: Creatures caught in the ray become confused."
	resist = RESIST_TYPE.IGNORE_DODGE
	# Classic's negative power-range coefficient lets this ray pass LOS blockers.
	los = false
	ray = true
	proj_tex = GFX.BALL
	proj_hit = GFX.SPINNY
	sounds = ["bloomp.wav", "hit effect 4.wav"]


func get_min_duration(_power : int, _caster) -> int :
	return 1

func get_duration_roll(_power : int, _caster) -> int :
	return randi_range(1, 4)

func get_max_duration(_power : int, _caster) -> int :
	return 4

func get_range(power : int, _caster) -> int :
	return power * 3

func get_sp_cost(power : int, _caster) -> int :
	return power * 7

func add_traits_to_creature(caster, target, power : int) -> void :
	if ConfusionRules.has_permanent_condition(target):
		return
	var trait_script = load("res://shared_assets/traits/t_classic_confused.gd")
	target.add_trait(trait_script, [get_duration_roll(power, caster)])
