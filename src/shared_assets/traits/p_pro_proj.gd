const name := "p_pro_proj.gd"
const menuname := "Protection from Projectiles (P)"
const stacks := false
const permanent := true
const trait_types: Array = []
var chara
var trait_source := ""


func _init(args: Array) -> void:
	chara = args[0]


func get_saved_variables() -> Array:
	return []


func get_info_as_text() -> String:
	var source_text := "" if trait_source.is_empty() else " (source: %s)" % trait_source
	return "Permanent projectile protection%s" % source_text


func _on_spell_hit_chara(_caster, spell, _power: int, damage: int) -> Array:
	var attributes: Variant = spell.get("attributes") if spell != null else []
	if attributes is Array and "Projectile" in attributes:
		return [false, 0, []]
	return [true, damage, []]


func equals_args(_traits_array: Array) -> bool:
	return true
