class_name ClassicCoreArcanicBubbleSpell
extends "res://scripts/classic_runtime/classic_core_timed_condition_spell.gd"

const AbsorptionTrait = preload(
	"res://shared_assets/traits/t_sp_absorb.gd"
)


func configure_core_arcanic_bubble_spell(spell_id: int) -> bool:
	return configure_core_timed_condition_spell(
		spell_id,
		36,
		AbsorptionTrait,
		["p_sp_absorb.gd"],
		[0, 5],
		[4],
		"Absorbs the selected power of hostile Classic spells before resistance",
		["Spell Point Absorption"]
	)
