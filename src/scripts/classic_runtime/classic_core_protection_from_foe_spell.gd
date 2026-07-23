class_name ClassicCoreProtectionFromFoeSpell
extends "res://scripts/classic_runtime/classic_core_timed_condition_spell.gd"

const TemporaryProtectionTrait = preload(
	"res://shared_assets/traits/t_classic_protection_from_foe.gd"
)


func configure_core_protection_from_foe_spell(spell_id: int) -> bool:
	return configure_core_timed_condition_spell(
		spell_id,
		23,
		TemporaryProtectionTrait,
		[
			"p_classic_protection_from_foe.gd",
			"p_prot_evil.gd",
			"t_pro_evil.gd",
		],
		[0, 3],
		[4],
		"Adds 10 percentage points to hit chance against evil foes and subtracts 10 from their hit chance",
		["Protection", "Evil"]
	)
