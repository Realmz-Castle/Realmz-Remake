extends RefCounted

const SpellIdentityScript = preload("res://scripts/classic_runtime/classic_spell_identity.gd")
const SpellScript = preload("res://Creature/Spell.gd")

const CLASSIC_SCHOOLS := {
	1: "Sorcerer",
	2: "Priest",
	3: "Enchanter",
}


static func resolve_spell_levels(
	saved_levels: Array,
	spell_book: Dictionary,
	spell_id_mapping: Dictionary,
	school_evidence: String = ""
) -> Dictionary:
	var resolved_levels: Array = []
	var diagnostics: Array[String] = []
	for level_index: int in saved_levels.size():
		var saved_level_value: Variant = saved_levels[level_index]
		var resolved_level: Array = []
		if saved_level_value is Array:
			for saved_entry_value: Variant in saved_level_value:
				if not (saved_entry_value is Dictionary):
					continue
				var resolution := resolve_entry(
					saved_entry_value,
					spell_book,
					spell_id_mapping,
					school_evidence,
					level_index + 1
				)
				resolved_level.append(resolution.get(
					"entry",
					saved_entry_value.duplicate(false)
				))
				var diagnostic := str(resolution.get("diagnostic", ""))
				if not diagnostic.is_empty():
					diagnostics.append(diagnostic)
		resolved_levels.append(resolved_level)
	return {
		"spellLevels": resolved_levels,
		"diagnostics": diagnostics,
	}


static func resolve_entry(
	saved_entry: Dictionary,
	spell_book: Dictionary,
	spell_id_mapping: Dictionary,
	school_evidence: String = "",
	learned_level: int = 0
) -> Dictionary:
	var spell_id: int = abs(int(saved_entry.get("classicSpellId", 0)))
	if spell_id != 0:
		return _resolve_exact_id(saved_entry, spell_id, spell_book, spell_id_mapping)

	var display_name: String = str(saved_entry.get("name", "")).strip_edges()
	if display_name.is_empty():
		return {
			"status": "missing-name",
			"entry": saved_entry.duplicate(false),
			"diagnostic": "A learned spell has neither a native name nor a Classic spell ID.",
		}

	var candidates: Array[int] = candidate_ids_for_name(display_name, spell_id_mapping)
	if candidates.size() == 1:
		return _resolve_exact_id(
			saved_entry,
			candidates[0],
			spell_book,
			spell_id_mapping,
			"inferred-exact-id"
		)
	if candidates.size() > 1 and (not school_evidence.is_empty() or learned_level > 0):
		var evidenced_candidates: Array[int] = []
		for candidate: int in candidates:
			if not school_evidence.is_empty() \
			and school_for_spell_id(candidate) != school_evidence:
				continue
			if learned_level > 0 and level_for_spell_id(candidate) != learned_level:
				continue
			evidenced_candidates.append(candidate)
		if evidenced_candidates.size() == 1:
			return _resolve_exact_id(
				saved_entry,
				evidenced_candidates[0],
				spell_book,
				spell_id_mapping,
				"inferred-exact-id"
			)

	if candidates.size() > 1:
		return {
			"status": "ambiguous-legacy-name",
			"entry": saved_entry.duplicate(false),
			"diagnostic": (
				"Learned spell '%s' matches Classic IDs %s; no single caster school "
				+ "and learned level established one identity, so its saved "
				+ "implementation was left unchanged."
			) % [display_name, str(candidates)],
		}

	var resource_name: String = str(saved_entry.get("resourceName", display_name))
	if spell_book.has(resource_name):
		var native_entry: Dictionary = _copy_resource_entry(spell_book[resource_name])
		native_entry["name"] = display_name
		native_entry["resourceName"] = resource_name
		return {"status": "native-name", "entry": native_entry}
	return {
		"status": "preserved-source",
		"entry": saved_entry.duplicate(false),
		"diagnostic": (
			"Learned spell '%s' has no loaded native resource; its saved implementation "
			+ "was preserved."
		) % display_name,
	}


static func candidate_ids_for_name(
	display_name: String,
	spell_id_mapping: Dictionary
) -> Array[int]:
	var candidates: Array[int] = []
	var normalized_name: String = _normalized_name(display_name)
	# Classic's player-spell table is three caster lists of seven levels and
	# twelve slots. Scanning that fixed domain also finds identities whose native
	# implementation is still missing, so a partial resource book cannot hide an
	# ambiguous legacy name.
	for class_index: int in range(3):
		for level_index: int in range(7):
			for slot_index: int in range(12):
				var spell_id: int = 1101 + class_index * 1000 + level_index * 100 + slot_index
				if _normalized_name(
					SpellIdentityScript.mapped_name(spell_id, spell_id_mapping)
				) == normalized_name:
					candidates.append(spell_id)
	return candidates


static func school_for_spell_id(spell_id: int) -> String:
	if spell_id < 1101:
		return ""
	var class_index: int = int((spell_id - 1101) / 1000) + 1
	return str(CLASSIC_SCHOOLS.get(class_index, ""))


static func level_for_spell_id(spell_id: int) -> int:
	if spell_id < 1101:
		return 0
	return int(((spell_id - 1101) % 1000) / 100) + 1


static func school_evidence_for_character(character: Object, class_script: Variant) -> String:
	if class_script == null or not class_script.has_method("can_learn_spell"):
		return ""
	# Ask the native class rule which one of the three Classic schools it accepts.
	# This keeps hybrid class knowledge in its existing owner.
	var supported_schools: Array[String] = []
	for school: String in ["Sorcerer", "Priest", "Enchanter"]:
		var probe = SpellScript.new()
		probe.school_levels = {school: 1}
		var learned_level := int(class_script.can_learn_spell(character, probe))
		if learned_level > 0 and learned_level <= 7:
			supported_schools.append(school)
	return supported_schools[0] if supported_schools.size() == 1 else ""


static func serialize_spell_levels(spell_levels: Array) -> Array:
	var serialized_levels: Array = []
	for spell_level_value: Variant in spell_levels:
		var serialized_level: Array = []
		if spell_level_value is Array:
			for spell_entry_value: Variant in spell_level_value:
				if not (spell_entry_value is Dictionary):
					continue
				var serialized_entry: Dictionary = spell_entry_value.duplicate(false)
				serialized_entry.erase("script")
				serialized_level.append(serialized_entry)
		serialized_levels.append(serialized_level)
	return serialized_levels


static func with_explicit_id(
	spell_entry: Dictionary,
	spell_id: int,
	resource_name: String = ""
) -> Dictionary:
	var learned_entry: Dictionary = spell_entry.duplicate(false)
	var normalized_id: int = abs(spell_id)
	if normalized_id != 0:
		learned_entry["classicSpellId"] = normalized_id
	var stored_resource_name: String = resource_name
	if stored_resource_name.is_empty():
		stored_resource_name = str(spell_entry.get("resourceName", spell_entry.get("name", "")))
	if not stored_resource_name.is_empty():
		learned_entry["resourceName"] = stored_resource_name
	return learned_entry


static func _resolve_exact_id(
	saved_entry: Dictionary,
	spell_id: int,
	spell_book: Dictionary,
	spell_id_mapping: Dictionary,
	status: String = "exact-id"
) -> Dictionary:
	var resource_name: String = SpellIdentityScript.resource_key(
		spell_id,
		spell_id_mapping,
		spell_book
	)
	if resource_name.is_empty():
		return {
			"status": "missing-exact-resource",
			"entry": saved_entry.duplicate(false),
			"diagnostic": (
				"Classic learned spell %d (%s) has no exact loaded native resource; "
				+ "its saved implementation was left unchanged."
			) % [spell_id, str(saved_entry.get("name", "unnamed spell"))],
		}
	var learned_entry: Dictionary = with_explicit_id(
		_copy_resource_entry(spell_book[resource_name]),
		spell_id,
		resource_name
	)
	var mapped_name: String = SpellIdentityScript.mapped_name(spell_id, spell_id_mapping)
	if not mapped_name.is_empty():
		learned_entry["name"] = mapped_name
	return {
		"status": status,
		"entry": learned_entry,
		"classicSpellId": spell_id,
		"resourceName": resource_name,
	}


static func _copy_resource_entry(resource: Variant) -> Dictionary:
	return resource.duplicate(false) if resource is Dictionary else {}


static func _normalized_name(value: String) -> String:
	return value.strip_edges().to_lower()
