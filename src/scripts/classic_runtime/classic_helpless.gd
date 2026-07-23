class_name ClassicHelpless
extends RefCounted

const TRAIT_NAMES := [
	"t_classic_helpless.gd",
	"p_classic_helpless.gd",
]


static func is_helpless(character: Variant) -> bool:
	if not (character is Object):
		return false
	var traits: Variant = character.get("traits")
	if not (traits is Array):
		return false
	for trait_value: Variant in traits:
		if trait_value is Object \
				and str(trait_value.get("name")) in TRAIT_NAMES:
			return true
	return false


static func force_physical_damage(
	damage_detail: Dictionary,
	character: Object
) -> Dictionary:
	var result := damage_detail.duplicate(true)
	if not is_helpless(character) or not character.has_method("get_stat"):
		return result
	result["total"] = maxi(0, int(character.call("get_stat", "curHP")))
	return result
