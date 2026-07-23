class_name ClassicCoreStrongSpell
extends "res://scripts/classic_runtime/classic_core_timed_condition_spell.gd"

const TemporaryStrongTrait = preload(
	"res://shared_assets/traits/t_classic_strong.gd"
)


func configure_core_strong_spell(spell_id: int) -> bool:
	return configure_core_timed_condition_spell(
		spell_id,
		22,
		TemporaryStrongTrait,
		["p_classic_strong.gd", "p_strong.gd", "t_strong.gd"],
		[0],
		[4],
		"Adds 15 percentage points to physical accuracy and 3 damage",
		["Enhancement", "Strong"]
	)
