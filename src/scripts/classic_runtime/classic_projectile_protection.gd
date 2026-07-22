class_name ClassicProjectileProtection
extends RefCounted

const TRAIT_NAMES := ["t_pro_proj.gd", "p_pro_proj.gd"]


static func is_active(character: Object) -> bool:
	if character == null:
		return false
	var traits: Variant = character.get("traits")
	if not (traits is Array):
		return false
	for trait_value: Variant in traits:
		if trait_value is Object and str(trait_value.get("name")) in TRAIT_NAMES:
			return true
	return false


static func spell_is_projectile(spell: Object) -> bool:
	if spell == null:
		return false
	return absi(int(spell.get("classic_spell_class"))) == 9


static func spell_resolution(character: Object, spell: Object) -> Dictionary:
	var checks := spell_is_projectile(spell)
	return {
		"checksProjectileProtection": checks,
		"resisted": checks and is_active(character),
	}
