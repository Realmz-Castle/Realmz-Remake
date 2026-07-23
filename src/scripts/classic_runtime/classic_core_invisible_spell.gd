class_name ClassicCoreInvisibleSpell
extends "res://scripts/classic_runtime/classic_core_timed_condition_spell.gd"

const TemporaryInvisibleTrait = preload(
	"res://shared_assets/traits/t_classic_invisible.gd"
)


func configure_core_invisible_spell(spell_id: int) -> bool:
	return configure_core_timed_condition_spell(
		spell_id,
		25,
		TemporaryInvisibleTrait,
		["p_classic_invisible.gd", "p_invisible.gd", "t_invisible.gd"],
		[0, 9],
		[3, 4],
		"Adds 10 percentage points of physical evasion and prevents opportunity attacks",
		["Enhancement", "Invisible"]
	)
