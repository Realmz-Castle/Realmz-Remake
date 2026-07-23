const name := "p_sp_absorb.gd"
const menuname := "Spell Energy Absorption (P)"
const stacks := false
const trait_types: Array = []
const permanent := true
const AbsorptionRules = preload(
	"res://scripts/classic_runtime/classic_spell_absorption.gd"
)

var chara
var trait_source := ""


func _init(args: Array) -> void:
	chara = args[0]

func get_saved_variables() -> Array:
	return []


func _on_classic_spell_targeted_before_resistance(
	attacker,
	spell,
	power: int
) -> void:
	AbsorptionRules.absorb_spell_power(chara, attacker, spell, power)


func _on_spell_hit_chara(caster, spell, power: int, damage: int) -> Array:
	var spell_ids: Variant = spell.get("classic_spell_ids") if spell != null else []
	if spell_ids is Array and not spell_ids.is_empty():
		return [true, damage, []]
	var cost := int(caster.get_spell_resource_cost(spell, power))
	chara.change_cur_sp(cost)
	return [true, damage, []]


func get_info_as_text() -> String:
	var source_text := "" if trait_source.is_empty() else " (source: %s)" % trait_source
	return "Permanent Spell Energy Absorption%s" % source_text


func equals_args(_traits_array: Array) -> bool:
	return true
