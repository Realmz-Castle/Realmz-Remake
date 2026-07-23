class_name ClassicConditionCure
extends RefCounted

const TRAIT_NAMES_BY_CONDITION := {
	3: ["t_cursed.gd", "p_cursed.gd"],
	9: ["t_poison.gd", "p_poison.gd"],
	26: [
		"t_classic_petrified.gd",
		"p_classic_petrified.gd",
		"p_petrified.gd",
	],
	27: [
		"t_classic_blind.gd",
		"t_blind.gd",
		"p_blind.gd",
		"p_classic_blind.gd",
	],
	28: ["t_classic_disease.gd", "t_disease.gd", "p_disease.gd"],
}


static func clear_condition(character: Object, condition_index: int) -> int:
	if character == null or not TRAIT_NAMES_BY_CONDITION.has(condition_index) \
			or not character.has_method("remove_trait"):
		return 0
	var traits: Variant = character.get("traits")
	if not (traits is Array):
		return 0
	var trait_names: Array = TRAIT_NAMES_BY_CONDITION[condition_index]
	var removed := 0
	for trait_value: Variant in traits.duplicate():
		if trait_value is Object and str(trait_value.get("name")) in trait_names:
			character.remove_trait(trait_value)
			removed += 1
	return removed


static func has_condition(character: Object, condition_index: int) -> bool:
	if character == null or not TRAIT_NAMES_BY_CONDITION.has(condition_index):
		return false
	var traits: Variant = character.get("traits")
	if not (traits is Array):
		return false
	var trait_names: Array = TRAIT_NAMES_BY_CONDITION[condition_index]
	for trait_value: Variant in traits:
		if trait_value is Object and str(trait_value.get("name")) in trait_names:
			return true
	return false
