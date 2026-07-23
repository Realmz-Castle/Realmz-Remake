class_name ClassicProtectionFromFoe
extends RefCounted

const TRAIT_NAMES := [
	"t_classic_protection_from_foe.gd",
	"p_classic_protection_from_foe.gd",
]
const HIT_CHANCE_BONUS := 0.10


static func adjust_melee_accuracy(
	base_accuracy: float,
	attacker: Object,
	defender: Object
) -> float:
	var adjustment := 0.0
	if is_protected(attacker) and is_evil(defender):
		adjustment += HIT_CHANCE_BONUS
	if is_protected(defender) and is_evil(attacker):
		adjustment -= HIT_CHANCE_BONUS
	if is_zero_approx(adjustment):
		return base_accuracy
	return clampf(base_accuracy + adjustment, 0.0, 1.0)


static func is_protected(character: Object) -> bool:
	if character == null:
		return false
	var traits: Variant = character.get("traits")
	if not (traits is Array):
		return false
	for trait_value: Variant in traits:
		if trait_value is Object \
				and str(trait_value.get("name")) in TRAIT_NAMES:
			return true
	return false


static func is_evil(character: Object) -> bool:
	if character == null:
		return false
	var tags: Variant = character.get("tags")
	if not (tags is Array):
		return false
	for tag_value: Variant in tags:
		if str(tag_value).to_lower().contains("evil"):
			return true
	return false
