extends "res://scripts/classic_runtime/classic_timed_condition_trait.gd"

const name := "t_sp_absorb.gd"
const menuname := "Spell Energy Absorption (T)"
const AbsorptionRules = preload(
	"res://scripts/classic_runtime/classic_spell_absorption.gd"
)


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
	return "Spell energy absorption for %d rounds" % ceili(
		float(duration_seconds) / SECONDS_PER_ROUND
	)
