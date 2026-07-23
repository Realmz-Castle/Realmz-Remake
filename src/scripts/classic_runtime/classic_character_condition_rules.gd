extends RefCounted

const RegenerationScript = preload(
	"res://scripts/classic_runtime/classic_regeneration.gd"
)
const SpellScreenScript = preload(
	"res://scripts/classic_runtime/classic_spell_screen.gd"
)
const REGENERATION_TRAIT := "res://shared_assets/traits/t_classic_regeneration.gd"
const TEMPORARY_SPELL_SCREEN_TRAIT := (
	"res://shared_assets/traits/t_classic_spell_screen.gd"
)
const DISEASE_CONDITION_INDEX := 28
const DISEASE_TRAIT := "res://shared_assets/traits/t_classic_disease.gd"
const CONDITION_NAMES := [
	"Fleeing",
	"Helpless",
	"Tangled",
	"Cursed",
	"Magic Aura",
	"Dumb",
	"Slow",
	"Shield from Hits",
	"Shield from Projectiles",
	"Poisoned",
	"Regenerating",
	"Fire Protection",
	"Cold Protection",
	"Electrical Protection",
	"Chemical Protection",
	"Mental Protection",
	"Level 1 Spell Screen",
	"Level 2 Spell Screen",
	"Level 3 Spell Screen",
	"Level 4 Spell Screen",
	"Level 5 Spell Screen",
	"Strong",
	"Protection from Evil",
	"Speedy",
	"Invisible",
	"Animated",
	"Turned to Stone",
	"Blind",
	"Diseased",
	"Confused",
	"Reflecting Spells",
	"Reflecting Attacks",
	"Attack Bonus",
	"Power Gathering",
	"Power Withering",
	"Spell Energy Absorption",
	"Hindered Attacks",
	"Hindered Defense",
	"Defense Bonus",
	"Silenced",
]
const CONDITION_TRAITS := {
	0: {
		"name": "Fleeing",
		"temporary": "res://shared_assets/traits/t_classic_fleeing.gd",
		"permanent": "res://shared_assets/traits/p_classic_fleeing.gd",
	},
	1: {
		"name": "Helpless",
		"temporary": "res://shared_assets/traits/t_classic_helpless.gd",
		"permanent": "res://shared_assets/traits/p_classic_helpless.gd",
	},
	2: {
		"name": "Tangled",
		"temporary": "res://shared_assets/traits/t_classic_tangled.gd",
		"permanent": "res://shared_assets/traits/p_classic_tangled.gd",
	},
	3: {
		"name": "Cursed",
		"temporary": "res://shared_assets/traits/t_classic_cursed.gd",
		"permanent": "res://shared_assets/traits/p_cursed.gd",
	},
	4: {
		"name": "Magic Aura",
		"temporary": "res://shared_assets/traits/t_aura.gd",
		"permanent": "res://shared_assets/traits/p_aura.gd",
	},
	5: {
		"name": "Dumb",
		"temporary": "res://shared_assets/traits/t_dumb.gd",
		"permanent": "res://shared_assets/traits/p_dumb.gd",
	},
	6: {
		"name": "Slow",
		"temporary": "res://shared_assets/traits/t_classic_slow.gd",
		"permanent": "res://shared_assets/traits/p_slow.gd",
	},
	7: {
		"name": "Shield from Hits",
		"temporary": "res://shared_assets/traits/t_pro_hits.gd",
		"permanent": "res://shared_assets/traits/p_pro_hits.gd",
	},
	8: {
		"name": "Shield from Projectiles",
		"temporary": "res://shared_assets/traits/t_pro_proj.gd",
		"permanent": "res://shared_assets/traits/p_pro_proj.gd",
	},
	9: {
		"name": "Poisoned",
		"temporary": "res://shared_assets/traits/t_poison.gd",
		"permanent": "res://shared_assets/traits/p_poison.gd",
	},
	11: {
		"name": "Fire Protection",
		"temporary": "res://shared_assets/traits/t_classic_prot_fire.gd",
		"permanent": "res://shared_assets/traits/p_prot_fire.gd",
	},
	12: {
		"name": "Cold Protection",
		"temporary": "res://shared_assets/traits/t_classic_prot_ice.gd",
		"permanent": "res://shared_assets/traits/p_prot_ice.gd",
	},
	13: {
		"name": "Electrical Protection",
		"temporary": "res://shared_assets/traits/t_classic_prot_elect.gd",
		"permanent": "res://shared_assets/traits/p_prot_elect.gd",
	},
	14: {
		"name": "Chemical Protection",
		"temporary": "res://shared_assets/traits/t_classic_prot_chem.gd",
		"permanent": "res://shared_assets/traits/p_prot_chem.gd",
	},
	15: {
		"name": "Mental Protection",
		"temporary": "res://shared_assets/traits/t_classic_prot_mental.gd",
		"permanent": "res://shared_assets/traits/p_prot_mental.gd",
	},
	21: {
		"name": "Strong",
		"temporary": "res://shared_assets/traits/t_classic_strong.gd",
		"permanent": "res://shared_assets/traits/p_classic_strong.gd",
	},
	22: {
		"name": "Protection from Evil",
		"temporary": (
			"res://shared_assets/traits/t_classic_protection_from_foe.gd"
		),
		"permanent": (
			"res://shared_assets/traits/p_classic_protection_from_foe.gd"
		),
	},
	23: {
		"name": "Speedy",
		"temporary": "res://shared_assets/traits/t_classic_speedy.gd",
		"permanent": "res://shared_assets/traits/p_classic_speedy.gd",
	},
	24: {
		"name": "Invisible",
		"temporary": "res://shared_assets/traits/t_classic_invisible.gd",
		"permanent": "res://shared_assets/traits/p_classic_invisible.gd",
	},
	25: {
		"name": "Animated",
		"temporary": "res://shared_assets/traits/t_classic_animated.gd",
		"permanent": "res://shared_assets/traits/p_classic_animated.gd",
	},
	26: {
		"name": "Turned to Stone",
		"temporary": "res://shared_assets/traits/t_classic_petrified.gd",
		"permanent": "res://shared_assets/traits/p_classic_petrified.gd",
	},
	27: {
		"name": "Blind",
		"temporary": "res://shared_assets/traits/t_classic_blind.gd",
		"permanent": "res://shared_assets/traits/p_classic_blind.gd",
	},
	29: {
		"name": "Confused",
		"temporary": "res://shared_assets/traits/t_classic_confused.gd",
		"permanent": "res://shared_assets/traits/p_classic_confused.gd",
	},
	30: {
		"name": "Reflecting Spells",
		"temporary": "res://shared_assets/traits/t_reflect_spells.gd",
		"permanent": "res://shared_assets/traits/p_reflect_spells.gd",
	},
	31: {
		"name": "Reflecting Attacks",
		"temporary": "res://shared_assets/traits/t_reflect_melee.gd",
		"permanent": "res://shared_assets/traits/p_reflect_melee.gd",
	},
	32: {
		"name": "Attack Bonus",
		"temporary": "res://shared_assets/traits/t_classic_attack_bonus.gd",
		"permanent": "res://shared_assets/traits/p_classic_attack_bonus.gd",
	},
	33: {
		"name": "Power Gathering",
		"temporary": "res://shared_assets/traits/t_classic_power_gather.gd",
		"permanent": "res://shared_assets/traits/p_classic_power_gather.gd",
	},
	34: {
		"name": "Power Withering",
		"temporary": "res://shared_assets/traits/t_classic_power_wither.gd",
		"permanent": "res://shared_assets/traits/p_classic_power_wither.gd",
	},
	35: {
		"name": "Spell Energy Absorption",
		"temporary": "res://shared_assets/traits/t_sp_absorb.gd",
		"permanent": "res://shared_assets/traits/p_sp_absorb.gd",
	},
	36: {
		"name": "Hindered Attacks",
		"temporary": "res://shared_assets/traits/t_hindered_atk.gd",
		"permanent": "res://shared_assets/traits/p_classic_hindered_atk.gd",
	},
	37: {
		"name": "Hindered Defense",
		"temporary": "res://shared_assets/traits/t_hindered_def.gd",
		"permanent": "res://shared_assets/traits/p_classic_hindered_def.gd",
	},
	38: {
		"name": "Defense Bonus",
		"temporary": "res://shared_assets/traits/t_classic_defense_bonus.gd",
		"permanent": "res://shared_assets/traits/p_classic_defense_bonus.gd",
	},
	39: {
		"name": "Silenced",
		"temporary": "res://shared_assets/traits/t_silenced.gd",
		"permanent": "res://shared_assets/traits/p_silenced.gd",
	},
}


static func supports_condition(condition_index: int) -> bool:
	return condition_index == RegenerationScript.CONDITION_INDEX \
		or condition_index == DISEASE_CONDITION_INDEX \
		or SpellScreenScript.condition_level(condition_index) > 0 \
		or CONDITION_TRAITS.has(condition_index)


static func grant_permanent_condition(
	character: Variant,
	condition_index: int
) -> Dictionary:
	if not supports_condition(condition_index):
		return _error(
			"Classic character condition %d has no Remake trait mapping"
			% condition_index
		)
	var validation := _validate_character(character)
	if not validation.is_empty():
		return validation

	var current_value := condition_value(character, condition_index)
	var new_value := -1 if current_value >= 0 else current_value - 1
	var set_result := set_condition_value(character, condition_index, new_value)
	if str(set_result.get("status", "")) == "error":
		return set_result
	return {
		"status": "ok",
		"conditionIndex": condition_index,
		"conditionName": condition_name(condition_index),
		"value": new_value,
	}


static func apply_condition(
	party: Array,
	selected: Array,
	target_mode: String,
	condition_index: int,
	duration: int
) -> Dictionary:
	if not supports_condition(condition_index):
		return _error("Classic character condition %d has no Remake trait mapping" % condition_index)
	if not ["party", "selected", "living"].has(target_mode):
		return _error("Classic character condition has an invalid target mode")
	if party.is_empty():
		return _error("Classic character condition has no party members")
	for character_value: Variant in party:
		var validation := _validate_character(character_value)
		if not validation.is_empty():
			return validation

	# Give Condition first clears a positive value from every party member,
	# including characters outside the selected target set.
	for character_value: Variant in party:
		if condition_value(character_value, condition_index) > 0:
			var clear_result := set_condition_value(
				character_value,
				condition_index,
				0
			)
			if str(clear_result.get("status", "")) == "error":
				return clear_result

	var affected_characters := _targets(party, selected, target_mode)
	for character_value: Variant in affected_characters:
		var new_value := condition_value(character_value, condition_index) + duration
		var set_result := set_condition_value(
			character_value,
			condition_index,
			new_value
		)
		if str(set_result.get("status", "")) == "error":
			return set_result
	return {
		"conditionName": condition_name(condition_index),
		"affectedCharacters": affected_characters,
		"affectedCount": affected_characters.size(),
	}


static func condition_value(character: Object, condition_index: int) -> int:
	if not supports_condition(condition_index):
		return 0
	if character.has_method("has_classic_conditions") \
			and bool(character.call("has_classic_conditions")) \
			and character.has_method("get_classic_condition"):
		var stored_value := int(
			character.call("get_classic_condition", condition_index)
		)
		# Permanent values do not count down, so the exact compatibility slot
		# remains authoritative. Positive durations are read from their live
		# traits instead.
		if stored_value < 0:
			return stored_value
	var screen_level := SpellScreenScript.condition_level(condition_index)
	if screen_level > 0:
		var temporary_duration := SpellScreenScript.temporary_duration(
			character,
			screen_level
		)
		if temporary_duration > 0:
			return temporary_duration
		return -1 if int(
			character.get_meta(SpellScreenScript.META_KEY, 0)
		) == screen_level else 0
	if condition_index == RegenerationScript.CONDITION_INDEX:
		var permanent_amount := RegenerationScript.amount(character)
		if permanent_amount > 0:
			return -permanent_amount
		return _temporary_regeneration_value(character)
	if condition_index == DISEASE_CONDITION_INDEX:
		return _disease_value(character)
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
		var condition_power := _trait_condition_power(trait_value)
		if trait_name == temporary_name:
			value += condition_power
		elif trait_name == permanent_name:
			value -= condition_power
	return value


static func _trait_condition_power(trait_value: Object) -> int:
	if trait_value.has_method("get_saved_variables"):
		var saved_variables: Variant = trait_value.call("get_saved_variables")
		if saved_variables is Array \
				and not saved_variables.is_empty() \
				and not (saved_variables[0] is Array):
			return maxi(1, absi(int(saved_variables[0])))
	var power: Variant = trait_value.get("power")
	return maxi(1, absi(int(power))) if power != null else 1


static func condition_name(condition_index: int) -> String:
	if condition_index >= 0 and condition_index < CONDITION_NAMES.size():
		return CONDITION_NAMES[condition_index]
	return "Condition %d" % condition_index


static func snapshot(character: Object) -> Array[int]:
	var result: Array[int] = []
	for condition_index: int in range(CONDITION_NAMES.size()):
		result.append(condition_value(character, condition_index))
	return result


static func set_condition_value(
	character: Object,
	condition_index: int,
	value: int
) -> Dictionary:
	if not supports_condition(condition_index):
		return _error(
			"Classic character condition %d has no Remake trait mapping"
			% condition_index
		)
	var validation := _validate_character(character)
	if not validation.is_empty():
		return validation
	_ensure_condition_state(character)
	if condition_index == RegenerationScript.CONDITION_INDEX:
		var regeneration_result := _set_regeneration_value(character, value)
		if str(regeneration_result.get("status", "")) == "error":
			return regeneration_result
	elif condition_index == DISEASE_CONDITION_INDEX:
		var disease_result := _set_disease_value(character, value)
		if str(disease_result.get("status", "")) == "error":
			return disease_result
	elif SpellScreenScript.condition_level(condition_index) > 0:
		var screen_result := _set_spell_screen_value(
			character,
			condition_index,
			value
		)
		if str(screen_result.get("status", "")) == "error":
			return screen_result
	else:
		var definition: Dictionary = CONDITION_TRAITS[condition_index]
		var temporary_trait: GDScript = load(str(definition["temporary"]))
		var permanent_trait: GDScript = load(str(definition["permanent"]))
		if temporary_trait == null or permanent_trait == null:
			return _error("Classic character condition traits could not be loaded")
		_set_trait_condition_value(
			character,
			definition,
			value,
			temporary_trait,
			permanent_trait
		)
	_store_condition_value(character, condition_index, value)
	return {
		"status": "ok",
		"conditionIndex": condition_index,
		"conditionName": condition_name(condition_index),
		"value": value,
	}


static func _set_spell_screen_value(
	character: Object,
	condition_index: int,
	value: int
) -> Dictionary:
	var screen_level := SpellScreenScript.condition_level(condition_index)
	var screen_trait: Variant = SpellScreenScript.temporary_trait(character)
	if screen_trait != null:
		if not screen_trait.has_method("set_duration_for_level"):
			return _error("Classic spell-screen trait cannot set an exact duration")
		screen_trait.call(
			"set_duration_for_level",
			screen_level,
			maxi(0, value)
		)
	elif value > 0:
		var temporary_trait: GDScript = load(TEMPORARY_SPELL_SCREEN_TRAIT)
		if temporary_trait == null:
			return _error("Classic spell-screen trait could not be loaded")
		character.add_trait(temporary_trait, [screen_level, value])

	var permanent_level := _permanent_spell_screen_level(
		character,
		condition_index,
		value
	)
	if permanent_level > 0:
		character.set_meta(SpellScreenScript.META_KEY, permanent_level)
	else:
		character.remove_meta(SpellScreenScript.META_KEY)
	return {"status": "ok"}


static func _permanent_spell_screen_level(
	character: Object,
	condition_index: int,
	value: int
) -> int:
	if character.has_method("has_classic_conditions") \
			and bool(character.call("has_classic_conditions")) \
			and character.has_method("get_classic_condition"):
		var conditions: Array[int] = []
		for index: int in range(40):
			conditions.append(int(character.call("get_classic_condition", index)))
		conditions[condition_index] = value
		return SpellScreenScript.permanent_level(conditions)

	var screen_level := SpellScreenScript.condition_level(condition_index)
	var current_level := int(
		character.get_meta(SpellScreenScript.META_KEY, 0)
	)
	if value < 0:
		return maxi(current_level, screen_level)
	return 0 if current_level == screen_level else current_level


static func _ensure_condition_state(character: Object) -> void:
	if not character.has_method("has_classic_conditions") \
			or bool(character.call("has_classic_conditions")) \
			or not character.has_method("set_classic_conditions"):
		return
	var conditions: Array[int] = []
	conditions.resize(40)
	conditions.fill(0)
	character.call("set_classic_conditions", conditions)


static func _set_trait_condition_value(
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


static func _set_regeneration_value(
	character: Object,
	value: int
) -> Dictionary:
	var regeneration_trait: GDScript = load(REGENERATION_TRAIT)
	if regeneration_trait == null:
		return _error("Classic regeneration trait could not be loaded")
	for trait_value: Variant in character.get("traits").duplicate():
		if trait_value is Object \
				and str(trait_value.get("name")) == REGENERATION_TRAIT.get_file():
			character.remove_trait(trait_value)
	character.remove_meta(RegenerationScript.META_KEY)
	if value > 0:
		character.add_trait(regeneration_trait, [value])
	elif value < 0:
		character.set_meta(RegenerationScript.META_KEY, absi(value))
	return {"status": "ok"}


static func _temporary_regeneration_value(character: Object) -> int:
	var traits: Variant = character.get("traits")
	if not (traits is Array):
		return 0
	for trait_value: Variant in traits:
		if trait_value is Object \
				and str(trait_value.get("name")) == REGENERATION_TRAIT.get_file():
			return int(trait_value.get("condition"))
	return 0


static func _disease_value(character: Object) -> int:
	var traits: Variant = character.get("traits")
	if not (traits is Array):
		return 0
	for trait_value: Variant in traits:
		if trait_value is Object \
				and str(trait_value.get("name")) == DISEASE_TRAIT.get_file():
			var saved_variables: Variant = trait_value.call(
				"get_saved_variables"
			)
			if saved_variables is Array and not saved_variables.is_empty():
				return int(saved_variables[0])
	return 0


static func _set_disease_value(character: Object, value: int) -> Dictionary:
	var disease_trait: GDScript = load(DISEASE_TRAIT)
	if disease_trait == null:
		return _error("Classic disease trait could not be loaded")
	for trait_value: Variant in character.get("traits").duplicate():
		if not (trait_value is Object):
			continue
		if str(trait_value.get("name")) in [
			DISEASE_TRAIT.get_file(),
			"t_disease.gd",
			"p_disease.gd",
		]:
			character.remove_trait(trait_value)
	if value != 0:
		character.add_trait(disease_trait, [value])
	return {"status": "ok"}


static func _store_condition_value(
	character: Object,
	condition_index: int,
	value: int
) -> void:
	if character.has_method("has_classic_conditions") \
			and bool(character.call("has_classic_conditions")) \
			and character.has_method("set_classic_condition"):
		character.call("set_classic_condition", condition_index, value)


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
