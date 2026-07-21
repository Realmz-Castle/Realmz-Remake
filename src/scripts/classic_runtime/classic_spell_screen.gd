class_name ClassicSpellScreen
extends RefCounted

const META_KEY := "classic_spell_screen_level"
const BESTIARY_FIELD := "classicSpellScreenLevel"
const FIRST_CONDITION_INDEX := 16
const LAST_CONDITION_INDEX := 20


static func supports_condition(condition_index: int, value: int) -> bool:
	# Realmz decrements only positive condition values at a round boundary.
	return (
		condition_index >= FIRST_CONDITION_INDEX
		and condition_index <= LAST_CONDITION_INDEX
		and value < 0
	)


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


static func level(character: Object) -> int:
	if character == null or not character.has_meta(META_KEY):
		return 0
	return clampi(int(character.get_meta(META_KEY)), 0, 5)


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
