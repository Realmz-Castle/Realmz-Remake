class_name ClassicCoreSpellcastingBlockSpell
extends "res://scripts/classic_runtime/classic_core_timed_condition_spell.gd"

const DumbTrait = preload("res://shared_assets/traits/t_dumb.gd")

var _shared_duration := 0
var _has_shared_duration := false


func configure_core_spellcasting_block_spell(spell_id: int) -> bool:
	var configured := configure_core_timed_condition_spell(
		spell_id,
		6,
		DumbTrait,
		["p_dumb.gd"],
		[0, 1],
		[0],
		"Prevents affected creatures from casting spells",
		["Mental", "Spellcasting Block"],
		5,
		5,
		false
	)
	if configured:
		attributes = ["Magical", "Mental"]
	return configured


# Target type zero selects one creature per power. Classic rolls its duration
# once before resolving the individual resistance and save checks.
func uses_classic_group_effect() -> bool:
	return false


func begin_classic_target_resolution(caster, power: int) -> void:
	_shared_duration = get_duration_roll(power, caster)
	_has_shared_duration = true


func end_classic_target_resolution() -> void:
	_shared_duration = 0
	_has_shared_duration = false


func apply_classic_scaled_effect(
	caster,
	target,
	power: int,
	effect_scale: float
) -> int:
	if effect_scale <= 0.0:
		return 0
	var duration := _shared_duration if _has_shared_duration \
		else get_duration_roll(power, caster)
	return duration if _apply_duration(target, duration) else 0
