class_name ClassicCoreSpeedySpell
extends "res://scripts/classic_runtime/classic_core_timed_condition_spell.gd"

const TemporarySpeedyTrait = preload(
	"res://shared_assets/traits/t_classic_speedy.gd"
)


func configure_core_speedy_spell(spell_id: int) -> bool:
	return configure_core_timed_condition_spell(
		spell_id,
		24,
		TemporarySpeedyTrait,
		["p_classic_speedy.gd", "p_speedy.gd", "t_speedy.gd"],
		[3],
		[4],
		"Doubles movement and grants two additional actions",
		["Enhancement", "Speedy"]
	)
