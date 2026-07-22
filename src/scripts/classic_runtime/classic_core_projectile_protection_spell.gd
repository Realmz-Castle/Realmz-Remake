class_name ClassicCoreProjectileProtectionSpell
extends "res://scripts/classic_runtime/classic_core_timed_condition_spell.gd"

const ProjectileProtectionTrait = preload(
	"res://shared_assets/traits/t_pro_proj.gd"
)


func configure_core_projectile_protection_spell(spell_id: int) -> bool:
	var required_damage_type := 8
	var required_spell_class := 8
	var required_in_camp := true
	var allowed_target_types: Array[int] = [5]
	if spell_id == 3508:
		required_damage_type = 0
		required_spell_class = 0
		required_in_camp = false
		allowed_target_types = [1]
	return configure_core_timed_condition_spell(
		spell_id,
		9,
		ProjectileProtectionTrait,
		["p_pro_proj.gd"],
		allowed_target_types,
		[4],
		"Makes Classic class-9 missile spells miss",
		["Defense", "Projectile Protection"],
		required_damage_type,
		required_spell_class,
		required_in_camp
	)
