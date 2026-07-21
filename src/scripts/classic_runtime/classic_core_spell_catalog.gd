class_name ClassicCoreSpellCatalog
extends RefCounted

const CATALOG_PATH := "res://scripts/classic_runtime/classic_core_spell_catalog.json"
const SpellOverrideScript = preload(
	"res://scripts/classic_runtime/classic_spell_override.gd"
)


static func records() -> Array[Dictionary]:
	if not FileAccess.file_exists(CATALOG_PATH):
		return []
	var document: Variant = JSON.parse_string(FileAccess.get_file_as_string(CATALOG_PATH))
	if not (document is Dictionary):
		return []
	var record_values: Variant = document.get("spells", [])
	if not (record_values is Array):
		return []
	var result: Array[Dictionary] = []
	for record_value: Variant in record_values:
		if record_value is Dictionary:
			result.append(record_value)
	result.sort_custom(
		func(left: Dictionary, right: Dictionary) -> bool:
			return int(left.get("packedSpellId", 0)) < int(right.get("packedSpellId", 0))
	)
	return result


static func spell(spell_id: int) -> Variant:
	for record: Dictionary in records():
		if int(record.get("packedSpellId", 0)) != abs(spell_id):
			continue
		return _spell_from_record(record)
	return null


static func merge_into_spell_book(spell_book: Dictionary) -> void:
	for record: Dictionary in records():
		var spell_id := int(record.get("packedSpellId", 0))
		var instance: Variant = _spell_from_record(record)
		if instance == null:
			continue
		var key := resource_key(record)
		spell_book[key] = {
			"name": instance.name,
			"source": "",
			"script": instance,
			"classicSpellId": spell_id,
			"classicSpellIds": [spell_id],
			"classicRecord": record.duplicate(true),
		}


static func merge_metadata(destination: Dictionary) -> void:
	for record: Dictionary in records():
		var spell_id := int(record.get("packedSpellId", 0))
		destination[resource_key(record)] = {
			"resourcePath": CATALOG_PATH,
			"classicSpellIds": [spell_id],
			"classicSpellClass": int(record.get("spellClass", 0)),
			"classicSpellSaveIndex": _save_index(record),
			"classicSpellSaveMode": _save_mode(record),
			"inField": bool(record.get("inCamp", false)),
			"inCombat": bool(record.get("inCombat", false)),
			"sourceRecord": {
				"sourceFile": str(record.get("sourceFile", "Data S")),
				"recordIndex": int(record.get("recordIndex", -1)),
				"byteOffset": int(record.get("byteOffset", -1)),
				"byteLength": int(record.get("byteLength", 30)),
			},
		}


static func resource_key(record: Dictionary) -> String:
	var key := str(record.get("resourceKey", "")).strip_edges()
	if not key.is_empty():
		return key
	var display_name := str(record.get("displayName", "")).strip_edges()
	if not display_name.is_empty():
		return display_name
	return "Classic spell %d" % int(record.get("packedSpellId", 0))


static func _spell_from_record(record: Dictionary) -> Variant:
	var result = SpellOverrideScript.new()
	result.configure(record)
	return result if result.is_generically_executable() else null


static func _save_index(record: Dictionary) -> int:
	var damage_type: int = abs(int(record.get("damageType", 0)))
	var cannot := int(record.get("cannot", 0))
	return damage_type if damage_type in range(1, 8) and cannot <= 1 else -1


static func _save_mode(record: Dictionary) -> String:
	if _save_index(record) < 0:
		return "none"
	for field_name: String in [
		"damage1", "damage2", "powerDamage1", "powerDamage2",
	]:
		if int(record.get(field_name, 0)) != 0:
			return "half_damage"
	return "negate"
