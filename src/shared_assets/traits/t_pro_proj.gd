extends "res://scripts/classic_runtime/classic_timed_condition_trait.gd"

const name := "t_pro_proj.gd"
const menuname := "Protection from Projectiles (T)"


func get_info_as_text() -> String:
	var remaining := ceili(float(duration_seconds) / SECONDS_PER_ROUND)
	return "Projectile protection for %d rounds" % remaining


func _on_spell_hit_chara(_caster, spell, _power: int, damage: int) -> Array:
	var attributes: Variant = spell.get("attributes") if spell != null else []
	if attributes is Array and "Projectile" in attributes:
		return [false, 0, []]
	return [true, damage, []]
