class_name ClassicSpellScreen
extends RefCounted

const META_KEY := "classic_spell_screen_level"
const BESTIARY_FIELD := "classicSpellScreenLevel"
const TEMPORARY_TRAIT_NAME := "t_classic_spell_screen.gd"
const FIRST_CONDITION_INDEX := 16
const LAST_CONDITION_INDEX := 20
const SECONDS_PER_HOUR := 3600


static func supports_condition(condition_index: int, value: int) -> bool:
	return condition_level(condition_index) > 0 and value != 0


static func condition_level(condition_index: int) -> int:
	if condition_index < FIRST_CONDITION_INDEX \
			or condition_index > LAST_CONDITION_INDEX:
		return 0
	return condition_index - FIRST_CONDITION_INDEX + 1


static func permanent_level(conditions: Variant) -> int:
	if not (conditions is Array):
		return 0
	var protected_level := 0
	# Realmz checks every screen from the cast level upward, so the strongest
	# active slot represents the whole protection range.
	for condition_index: int in range(FIRST_CONDITION_INDEX, LAST_CONDITION_INDEX + 1):
		if condition_index >= conditions.size():
			break
		if int(conditions[condition_index]) < 0:
			protected_level = condition_index - FIRST_CONDITION_INDEX + 1
	return protected_level


static func temporary_durations(conditions: Variant) -> Array[int]:
	var durations: Array[int] = [0, 0, 0, 0, 0]
	if not (conditions is Array):
		return durations
	for condition_index: int in range(FIRST_CONDITION_INDEX, LAST_CONDITION_INDEX + 1):
		if condition_index >= conditions.size():
			break
		durations[condition_index - FIRST_CONDITION_INDEX] = maxi(
			0,
			int(conditions[condition_index])
		)
	return durations


static func level(character: Object) -> int:
	if character == null:
		return 0
	var innate_level := clampi(int(character.get_meta(META_KEY, 0)), 0, 5)
	return maxi(innate_level, temporary_level(character))


static func temporary_level(character: Object) -> int:
	var screen_trait: Variant = temporary_trait(character)
	if screen_trait != null and screen_trait.has_method("screen_level"):
		return clampi(int(screen_trait.screen_level()), 0, 5)
	return 0


static func temporary_duration(character: Object, screen_level: int) -> int:
	var screen_trait: Variant = temporary_trait(character)
	if screen_trait != null and screen_trait.has_method("duration_for_level"):
		return maxi(0, int(screen_trait.duration_for_level(screen_level)))
	return 0


static func temporary_trait(character: Object) -> Variant:
	if character == null:
		return null
	var traits: Variant = character.get("traits")
	if not (traits is Array):
		return null
	for trait_value: Variant in traits:
		if trait_value is Object and str(trait_value.get("name")) == TEMPORARY_TRAIT_NAME:
			return trait_value
	return null


static func elapsed_hour_boundaries(previous_time: int, current_time: int) -> int:
	if current_time <= previous_time:
		return 0
	var previous_hour := floori(float(previous_time) / SECONDS_PER_HOUR)
	var current_hour := floori(float(current_time) / SECONDS_PER_HOUR)
	return maxi(0, current_hour - previous_hour)


static func spell_level(spell: Object, caster: Object = null) -> int:
	var learned_level := _caster_spell_level(caster, spell)
	if learned_level > 0:
		return learned_level

	var classic_levels: Array[int] = []
	if spell != null:
		var ids: Variant = spell.get("classic_spell_ids")
		if ids is Array:
			for id_value: Variant in ids:
				var decoded_level := _classic_spell_level(int(id_value))
				if decoded_level > 0 and not classic_levels.has(decoded_level):
					classic_levels.append(decoded_level)
	if classic_levels.size() == 1:
		return classic_levels[0]

	var native_levels: Array[int] = []
	if spell != null:
		var school_levels: Variant = spell.get("school_levels")
		if school_levels is Dictionary:
			for school: Variant in school_levels:
				var native_level := int(school_levels[school])
				if native_level > 0 and not native_levels.has(native_level):
					native_levels.append(native_level)
	return native_levels[0] if native_levels.size() == 1 else 0


static func spell_resolution(
	character: Object,
	spell: Object,
	caster: Object = null
) -> Dictionary:
	var screen_level := level(character)
	var cast_level := spell_level(spell, caster)
	return {
		"checksScreen": screen_level > 0 and cast_level > 0,
		"screenLevel": screen_level,
		"spellLevel": cast_level,
		"resisted": screen_level > 0 and cast_level > 0 and cast_level <= screen_level,
	}


static func _caster_spell_level(caster: Object, spell: Object) -> int:
	if caster == null or spell == null:
		return 0
	var spellbook: Variant = caster.get("spells")
	if not (spellbook is Array):
		return 0
	for level_index: int in range(spellbook.size()):
		var entries: Variant = spellbook[level_index]
		if not (entries is Array):
			continue
		for entry: Variant in entries:
			var candidate: Variant = entry.get("script") if entry is Dictionary else entry
			if candidate == spell:
				return level_index + 1
	return 0


static func _classic_spell_level(spell_id: int) -> int:
	var normalized_id: int = absi(spell_id)
	if normalized_id < 1101:
		return 0
	return int(((normalized_id - 1101) % 1000) / 100) + 1
