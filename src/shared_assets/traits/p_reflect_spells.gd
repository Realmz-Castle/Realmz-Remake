const name := "p_reflect_spells.gd"
const menuname := "Spell Reflection"
const stacks := false
const trait_types: Array = []
const ReflectionRules = preload(
	"res://scripts/classic_runtime/classic_spell_reflection.gd"
)
var chara
const permanent := true
var trait_source := ""

func _init(args: Array) -> void:
	chara = args[0]

func get_saved_variables() -> Array:
	return []

func _on_classic_spell_targeted(attacker, spell, power: int, roll: int) -> Array:
	return ReflectionRules.resolve_target(chara, attacker, spell, power, roll)

func _on_evasion_check(
	_creature,
	_evasion_stats_used: Array,
	attacker,
	spell,
	power: int
) -> Array:
	if ReflectionRules.is_classic_spell(spell):
		return [true, []]
	return ReflectionRules.resolve_target(
		chara,
		attacker,
		spell,
		power,
		randi_range(1, 100)
	)

func get_info_as_text() -> String:
	var source_text := "" if trait_source.is_empty() else " (source: %s)" % trait_source
	return "Permanent Spell Reflection (33%%)%s" % source_text


func equals_args(_traits_array: Array) -> bool:
	return true
