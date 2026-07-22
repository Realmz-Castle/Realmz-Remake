extends RefCounted

const CONDITION_TRAITS := {
	9: {
		"name": "Poisoned",
		"temporary": "res://shared_assets/traits/t_poison.gd",
		"permanent": "res://shared_assets/traits/p_poison.gd",
	},
	28: {
		"name": "Diseased",
		"temporary": "res://shared_assets/traits/t_disease.gd",
		"permanent": "res://shared_assets/traits/p_disease.gd",
	},
	39: {
		"name": "Silenced",
		"temporary": "res://shared_assets/traits/t_silenced.gd",
		"permanent": "res://shared_assets/traits/p_silenced.gd",
	},
}


static func apply_condition(
	party: Array,
	selected: Array,
	target_mode: String,
	condition_index: int,
	duration: int
) -> Dictionary:
	if not CONDITION_TRAITS.has(condition_index):
		return _error("Classic character condition %d has no Remake trait mapping" % condition_index)
	if not ["party", "selected", "living"].has(target_mode):
		return _error("Classic character condition has an invalid target mode")
	if party.is_empty():
		return _error("Classic character condition has no party members")
	for character_value: Variant in party:
		var validation := _validate_character(character_value)
		if not validation.is_empty():
			return validation

	var definition: Dictionary = CONDITION_TRAITS[condition_index]
	var temporary_trait: GDScript = load(str(definition["temporary"]))
	var permanent_trait: GDScript = load(str(definition["permanent"]))
	if temporary_trait == null or permanent_trait == null:
		return _error("Classic character condition traits could not be loaded")

	# Give Condition first clears a positive value from every party member,
	# including characters outside the selected target set.
	for character_value: Variant in party:
		if condition_value(character_value, condition_index) > 0:
			_set_condition_value(character_value, definition, 0, temporary_trait, permanent_trait)

	var affected_characters := _targets(party, selected, target_mode)
	for character_value: Variant in affected_characters:
		var new_value := condition_value(character_value, condition_index) + duration
		_set_condition_value(
			character_value,
			definition,
			new_value,
			temporary_trait,
			permanent_trait
		)
	return {
		"conditionName": str(definition["name"]),
		"affectedCharacters": affected_characters,
		"affectedCount": affected_characters.size(),
	}


static func condition_value(character: Object, condition_index: int) -> int:
	if not CONDITION_TRAITS.has(condition_index):
		return 0
	var definition: Dictionary = CONDITION_TRAITS[condition_index]
	var temporary_name := str(definition["temporary"]).get_file()
	var permanent_name := str(definition["permanent"]).get_file()
	var value := 0
	var traits: Variant = character.get("traits")
	if not (traits is Array):
		return 0
	for trait_value: Variant in traits:
		if not (trait_value is Object):
			continue
		var trait_name := str(trait_value.get("name"))
		var condition_power: int = abs(int(trait_value.get("power")))
		if trait_name == temporary_name:
			value += condition_power
		elif trait_name == permanent_name:
			value -= condition_power
	return value


static func _set_condition_value(
	character: Object,
	definition: Dictionary,
	value: int,
	temporary_trait: GDScript,
	permanent_trait: GDScript
) -> void:
	var temporary_name := str(definition["temporary"]).get_file()
	var permanent_name := str(definition["permanent"]).get_file()
	var traits: Array = character.get("traits")
	for trait_value: Variant in traits.duplicate():
		if trait_value is Object \
		and str(trait_value.get("name")) in [temporary_name, permanent_name]:
			character.remove_trait(trait_value)
	if value > 0:
		character.add_trait(temporary_trait, [value])
	elif value < 0:
		character.add_trait(permanent_trait, [abs(value)])


static func _targets(party: Array, selected: Array, target_mode: String) -> Array:
	var targets: Array = []
	for character_value: Variant in party:
		if target_mode == "party" \
		or (target_mode == "selected" and selected.has(character_value)) \
		or (target_mode == "living" and int(character_value.get("life_status")) < 3):
			targets.append(character_value)
	return targets


static func _validate_character(character_value: Variant) -> Dictionary:
	if not (character_value is Object):
		return _error("Classic character condition target is not a character")
	var traits: Variant = character_value.get("traits")
	if not (traits is Array):
		return _error("Classic character condition target has no trait state")
	if not character_value.has_method("add_trait") or not character_value.has_method("remove_trait"):
		return _error("Classic character condition target cannot change traits")
	return {}


static func _error(message: String) -> Dictionary:
	return {
		"status": "error",
		"message": message,
	}
