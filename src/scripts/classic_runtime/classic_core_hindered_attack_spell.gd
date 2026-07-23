class_name ClassicCoreHinderedAttackSpell
extends "res://scripts/classic_runtime/classic_core_timed_condition_spell.gd"

const HinderedAttackTrait = preload(
	"res://shared_assets/traits/t_hindered_atk.gd"
)

var _shared_duration := 0
var _has_shared_duration := false


func configure_core_hindered_attack_spell(spell_id: int) -> bool:
	return configure_core_timed_condition_spell(
		spell_id,
		37,
		HinderedAttackTrait,
		["p_classic_hindered_atk.gd", "p_hindered_atk.gd"],
		[10],
		[0],
		"Reduces melee and ranged accuracy by its remaining percentage points",
		["Attack Hindrance"],
		5,
		5,
		false
	)


# The duration is shared by the cast, but each target still gets its own save.
func uses_classic_group_effect() -> bool:
	return false


func begin_classic_target_resolution(caster, power: int) -> void:
	_shared_duration = get_duration_roll(power, caster)
	_has_shared_duration = true


func end_classic_target_resolution() -> void:
	_shared_duration = 0
	_has_shared_duration = false


func apply_classic_scaled_effect(
	_caster,
	target,
	power: int,
	effect_scale: float
) -> int:
	if effect_scale <= 0.0:
		return 0
	var duration := _shared_duration if _has_shared_duration \
		else get_duration_roll(power, _caster)
	return duration if _apply_duration(target, duration) else 0
