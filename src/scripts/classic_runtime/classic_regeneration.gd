class_name ClassicRegeneration
extends RefCounted

const CONDITION_INDEX := 10
const META_KEY := "classic_regeneration_per_round"
const BESTIARY_FIELD := "classicRegenerationPerRound"


static func supports_condition(condition_index: int, value: int) -> bool:
	# Realmz decrements only positive condition values at a round boundary.
	return condition_index == CONDITION_INDEX and value < 0


static func permanent_amount(conditions: Variant) -> int:
	if not (conditions is Array) or conditions.size() <= CONDITION_INDEX:
		return 0
	var value := int(conditions[CONDITION_INDEX])
	return absi(value) if value < 0 else 0


static func amount(character: Object) -> int:
	if character == null or not character.has_meta(META_KEY):
		return 0
	return maxi(0, int(character.get_meta(META_KEY)))


static func apply_new_round(character: Object) -> int:
	var regeneration := amount(character)
	if regeneration == 0 or not character.has_method("get_stat") \
			or not character.has_method("change_cur_hp"):
		return 0
	var current_hp := int(character.get_stat("curHP"))
	var maximum_hp := int(character.get_stat("maxHP"))
	if current_hp <= 0 or current_hp >= maximum_hp:
		return 0
	var healed := mini(regeneration, maximum_hp - current_hp)
	character.change_cur_hp(healed)
	return healed
