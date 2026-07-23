class_name ClassicCoreMissileSpell
extends "res://scripts/classic_runtime/classic_core_damage_spell.gd"

const MISSILE_BONUS_CASTES := ["Archer", "Marksman"]
const MISSILE_BONUS_META_KEY := "classic_gets_missile_bonus"


func configure_core_missile_spell(spell_id: int) -> bool:
	if not configure_core_damage_spell(spell_id, 9):
		return false
	attributes = ["Magical", "Projectile"]
	if not tags.has("Projectile"):
		tags.append("Projectile")
	return true


func get_damage_roll(power: int, caster) -> int:
	var result := super.get_damage_roll(power, caster)
	var bonus_range := classic_missile_bonus_range(caster)
	if bonus_range.y > 0:
		result += randi_range(bonus_range.x, bonus_range.y)
	return result


func classic_missile_bonus_range(caster) -> Vector2i:
	if not _caster_gets_missile_bonus(caster):
		return Vector2i.ZERO
	var level := maxi(1, int(caster.get("level")))
	return Vector2i(1, maxi(1, floori(level / 2.0)))


func _caster_gets_missile_bonus(caster) -> bool:
	if caster == null:
		return false
	var profile: Variant = caster.get("classic_rule_profile")
	if profile is Dictionary:
		var caste_runtime: Variant = profile.get("casteRuntime", {})
		if caste_runtime is Dictionary \
				and caste_runtime.has("getsMissileBonus"):
			return bool(caste_runtime["getsMissileBonus"])
	if caster.has_meta(MISSILE_BONUS_META_KEY):
		return bool(caster.get_meta(MISSILE_BONUS_META_KEY))
	var class_script: Variant = caster.get("classgd")
	if class_script == null:
		return false
	return str(class_script.get("classrace_name")) in MISSILE_BONUS_CASTES
