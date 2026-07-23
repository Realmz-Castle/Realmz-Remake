class_name ClassicAnimation
extends RefCounted

const CONDITION_INDEX := 25
const PERMANENT_TRAIT_NAMES := [
	"p_animated.gd",
	"p_classic_animated.gd",
]


static func supports_condition(condition_index: int, value: int) -> bool:
	return condition_index == CONDITION_INDEX and value < 0


static func has_permanent_condition(conditions: Variant) -> bool:
	return (
		conditions is Array
		and conditions.size() > CONDITION_INDEX
		and supports_condition(CONDITION_INDEX, int(conditions[CONDITION_INDEX]))
	)
const TRAIT_NAMES := [
	"p_animated.gd",
	"t_animated.gd",
	"p_classic_animated.gd",
	"t_classic_animated.gd",
]


static func is_animated(character: Object) -> bool:
	return _has_named_trait(character, TRAIT_NAMES)


static func is_permanently_animated(character: Object) -> bool:
	return _has_named_trait(character, PERMANENT_TRAIT_NAMES)


static func can_receive_experience(character: Object) -> bool:
	if character == null:
		return false
	var traits: Variant = character.get("traits")
	if not (traits is Array):
		return true
	for trait_value: Variant in traits:
		if not (trait_value is Object):
			continue
		var types: Variant = trait_value.get("trait_types")
		if types is Array and types.has("no_exp"):
			return false
	return true


static func remove_animation_traits(character: Object) -> void:
	if character == null or not character.has_method("remove_trait"):
		return
	var traits: Variant = character.get("traits")
	if not (traits is Array):
		return
	for trait_value: Variant in traits.duplicate():
		if trait_value is Object and str(trait_value.get("name")) in TRAIT_NAMES:
			character.remove_trait(trait_value)


static func _has_named_trait(character: Object, names: Array) -> bool:
	if character == null:
		return false
	var traits: Variant = character.get("traits")
	if not (traits is Array):
		return false
	for trait_value: Variant in traits:
		if trait_value is Object and str(trait_value.get("name")) in names:
			return true
	return false
