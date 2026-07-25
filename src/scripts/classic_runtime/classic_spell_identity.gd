extends RefCounted

const RESOURCE_ALIASES := {
	"Discover Magic I": "Discover Magic",
}


static func is_valid_packed_id(spell_id: int) -> bool:
	if spell_id < 1101:
		return false
	var caster_class := int(spell_id / 1000)
	var remainder := spell_id % 1000
	var spell_level := int(remainder / 100)
	var spell_slot := remainder % 100
	return (
		caster_class >= 1
		and caster_class <= 5
		and spell_level >= 1
		and spell_level <= 7
		and spell_slot >= 1
		and spell_slot <= 15
	)


static func mapping_key(spell_id: int) -> String:
	if spell_id < 1101:
		return ""
	# Subtracting Classic's 1101 base exposes zero-based caster, level, and
	# slot values. The inherited Remake table stores those parts as a key.
	var packed := spell_id - 1101
	var caster_class := int(packed / 1000) + 1
	var remainder := packed % 1000
	var spell_level := int(remainder / 100)
	var spell_slot := remainder % 100
	return "%d%d%d" % [caster_class * 100, spell_level, spell_slot]


static func mapped_name(spell_id: int, spell_id_mapping: Dictionary) -> String:
	var name := str(spell_id_mapping.get(
		mapping_key(spell_id),
		spell_id_mapping.get(spell_id, "")
	))
	return str(RESOURCE_ALIASES.get(name, name))


static func resource_key(
	spell_id: int,
	spell_id_mapping: Dictionary,
	spell_book: Dictionary
) -> String:
	var resource_names: Array = spell_book.keys()
	resource_names.sort()
	for resource_name_value: Variant in resource_names:
		var resource_name := str(resource_name_value)
		if spell_id in resource_ids(spell_book[resource_name_value]):
			return resource_name
	var spell_name := mapped_name(spell_id, spell_id_mapping)
	if spell_name.is_empty() or not spell_book.has(spell_name):
		return ""
	return spell_name if resource_supports_id(spell_book[spell_name], spell_id) else ""


static func resource_supports_id(resource: Variant, spell_id: int) -> bool:
	if resource is Dictionary and resource.has("classicSpellIds"):
		var declared_ids := resource_ids(resource)
		return declared_ids.is_empty() or spell_id in declared_ids
	var spell: Variant = resource.get("script") if resource is Dictionary else resource
	if not (spell is Object):
		return false
	if not spell.has_method("supports_classic_spell_id"):
		return true
	return bool(spell.supports_classic_spell_id(spell_id))


static func resource_ids(resource: Variant) -> Array[int]:
	var raw_ids: Variant = resource.get("classicSpellIds", []) \
		if resource is Dictionary else []
	var spell: Variant = resource.get("script") if resource is Dictionary else resource
	var ids: Array[int] = []
	if raw_ids is Array and not raw_ids.is_empty():
		for id_value: Variant in raw_ids:
			var spell_id: int = abs(int(id_value))
			if not ids.has(spell_id):
				ids.append(spell_id)
		return ids
	if spell is Object:
		raw_ids = spell.get("classic_spell_ids")
	if raw_ids is Array:
		for id_value: Variant in raw_ids:
			var spell_id: int = abs(int(id_value))
			if not ids.has(spell_id):
				ids.append(spell_id)
	return ids


static func native_resolution(
	spell_id: int,
	spell_id_mapping: Dictionary,
	spell_book: Dictionary
) -> Dictionary:
	var mapped_spell_name := mapped_name(spell_id, spell_id_mapping)
	var resolution := {"mappedName": mapped_spell_name}
	if spell_book.is_empty():
		resolution["status"] = "not-audited"
		return resolution
	if mapped_spell_name.is_empty():
		resolution["status"] = "unmapped-identity"
		return resolution
	var resolved_key := resource_key(spell_id, spell_id_mapping, spell_book)
	if resolved_key.is_empty():
		if not spell_book.has(mapped_spell_name):
			resolution["status"] = "missing-native-resource"
			return resolution
		resolution["resourceName"] = mapped_spell_name
		var mapped_ids := resource_ids(spell_book[mapped_spell_name])
		resolution["status"] = "name-only-resource" \
			if mapped_ids.is_empty() else "unsupported-native-variant"
		return resolution
	resolution["resourceName"] = resolved_key
	var metadata: Variant = spell_book[resolved_key]
	if not (metadata is Dictionary):
		resolution["status"] = "name-only-resource"
		return resolution
	var declared_ids: Variant = metadata.get("classicSpellIds", [])
	if declared_ids is Array and not declared_ids.is_empty():
		resolution["status"] = (
			"exact-id-resource" if spell_id in declared_ids else "unsupported-native-variant"
		)
	else:
		resolution["status"] = "name-only-resource"
	for field_name: String in [
		"resourcePath",
		"classicSpellClass",
		"classicSpellIds",
		"classicSpellSaveIndex",
		"classicSpellSaveMode",
		"inField",
		"inCombat",
	]:
		if metadata.has(field_name):
			resolution[field_name] = metadata[field_name]
	return resolution
