class_name ClassicCorePowerGatherSpell
extends "res://scripts/classic_runtime/classic_core_timed_condition_spell.gd"

const PowerGatherTrait = preload(
	"res://shared_assets/traits/t_classic_power_gather.gd"
)


func configure_core_power_gather_spell(spell_id: int) -> bool:
	return configure_core_timed_condition_spell(
		spell_id,
		34,
		PowerGatherTrait,
		["p_classic_power_gather.gd"],
		[1],
		[4],
		"Restores spell points equal to its remaining duration at each round or hour",
		["Spell Point Regeneration"],
		7,
		7
	)
