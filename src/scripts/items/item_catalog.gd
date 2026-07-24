class_name ItemCatalog
extends RefCounted

const ItemDefinitionScript = preload("res://scripts/items/item_definition.gd")
const ItemInstanceScript = preload("res://scripts/items/item_instance.gd")

const SOURCE_SCOPES := ["shared", "campaign"]
const DEFINITION_REQUIRED_STRINGS := ["name", "type", "img_ptr", "sound"]
const ARRAY_FIELDS := [
	"slots",
	"only_usable_by_classes",
	"not_usable_by_classes",
	"only_usable_by_races",
	"not_usable_by_races",
	"traits",
	"melee_inflicted_traits",
	"classicItemIds",
]
const DICTIONARY_FIELDS := [
	"stats",
	"weapon_dmg",
	"weapon_tag_bonus_dmg",
	"extra_data",
	"classicRecord",
	"classicMaterialization",
]
const INTEGER_FIELDS := [
	"is_magical",
	"hands",
	"unique",
	"delete_on_empty",
	"equippable",
	"is_identified",
	"equipped",
	"charges",
	"charges_max",
	"tradeable",
	"weight",
	"price",
	"charges_weight",
	"splittable",
	"classicItemId",
	"classicItemCategory",
	"classicRecordId",
	"classicItemType",
	"classicIconId",
	"classicSoundId",
	"classicMagicResistance",
]
const SOURCE_HOOK_ALIASES := {
	"_on_equipping_source": ["_on_equipping_source", "on_equipping_source"],
	"_on_unequipping_source": ["_on_unequipping_source", "on_unequipping_source"],
	"_on_field_use_source": ["_on_field_use_source"],
	"_on_combat_use_source": ["_on_combat_use_source"],
	"_on_drop_source": ["_on_drop_source"],
	"_calculate_melee_attack_source": ["_calculate_melee_attack_source"],
	"_calculate_melee_accuracy_source": ["_calculate_melee_accuracy_source"],
	"custom_spell_source": ["custom_spell_source"],
}
const INSTANCE_OVERRIDE_FIELDS := [
	"instanceId",
	"charges",
	"equipped",
	"identified",
	"stateData",
]

var last_errors: Array[String] = []

var _definitions: Dictionary = {}
var _shared_by_key: Dictionary = {}
var _campaign_by_key: Dictionary = {}
var _active_by_key: Dictionary = {}
var _classic_shared: Dictionary = {}
var _classic_by_campaign: Dictionary = {}
var _legacy_templates: Dictionary = {}
var _issued_instance_ids: Dictionary = {}
var _active_campaign_id := ""


func clear() -> void:
	last_errors.clear()
	_definitions.clear()
	_shared_by_key.clear()
	_campaign_by_key.clear()
	_active_by_key.clear()
	_classic_shared.clear()
	_classic_by_campaign.clear()
	_legacy_templates.clear()
	_issued_instance_ids.clear()
	_active_campaign_id = ""


func definition_count() -> int:
	return _definitions.size()


func definition_ids() -> Array[String]:
	var result: Array[String] = []
	for value: Variant in _definitions:
		result.append(str(value))
	result.sort()
	return result


func get_definition(definition_id: String) -> ItemDefinition:
	return _definitions.get(definition_id)


func active_campaign_id() -> String:
	return _active_campaign_id


func has_issued_instance_id(instance_id: String) -> bool:
	return _issued_instance_ids.has(instance_id)


func resolve_legacy_name(display_name: String) -> String:
	var matched_definition_id := ""
	for definition_id_value: Variant in _legacy_templates:
		var definition_id := str(definition_id_value)
		var definition := get_definition(definition_id)
		if definition == null:
			continue
		if definition.source_scope == "campaign" \
				and definition.campaign_id != _active_campaign_id:
			continue
		var template_value: Variant = _legacy_templates[definition_id_value]
		if not (template_value is Dictionary) \
				or str(template_value.get("name", "")) != display_name:
			continue
		if not matched_definition_id.is_empty() \
				and matched_definition_id != definition_id:
			return ""
		matched_definition_id = definition_id
	return matched_definition_id


func register_embedded_definition(
	normalized_definition: Dictionary,
	legacy_template: Dictionary = {},
) -> bool:
	last_errors.clear()
	if not _is_json_compatible(normalized_definition):
		_error(
			"",
			"",
			"embeddedDefinition",
			"must contain only JSON-compatible string-keyed data",
		)
		return false
	var definition_id := str(
		normalized_definition.get("definitionId", "")
	).strip_edges()
	var digest := str(normalized_definition.get("digest", "")).strip_edges()
	if not definition_id.begins_with("embedded:sha256:") \
			or digest.length() != 64 \
			or not digest.is_valid_hex_number(false) \
			or definition_id != "embedded:sha256:%s" % digest:
		_error(
			"",
			definition_id,
			"definitionId",
			"must match embedded:sha256:<digest>",
		)
		return false
	var source_value: Variant = normalized_definition.get("source", {})
	if not (source_value is Dictionary) \
			or str(source_value.get("scope", "")) != "embedded":
		_error(
			"",
			definition_id,
			"source.scope",
			"must be embedded",
		)
		return false
	for field_name: String in [
		"catalogKey",
		"name",
		"unidentifiedName",
		"description",
		"type",
		"imageKey",
		"soundKey",
	]:
		if not (normalized_definition.get(field_name) is String):
			_error(
				"",
				definition_id,
				field_name,
				"must be a string",
			)
	for field_name: String in ["gameplay", "hooks", "classic"]:
		if not (normalized_definition.get(field_name) is Dictionary):
			_error(
				"",
				definition_id,
				field_name,
				"must be an object",
			)
	if not (normalized_definition.get("defaultIdentified") is bool):
		_error(
			"",
			definition_id,
			"defaultIdentified",
			"must be a boolean",
		)
	if not last_errors.is_empty():
		return false
	var existing := get_definition(definition_id)
	if existing != null:
		if existing.to_dictionary() != normalized_definition:
			_error(
				"",
				definition_id,
				"embeddedDefinition",
				"conflicts with the previously registered digest",
			)
			return false
		if not legacy_template.is_empty() \
				and not _legacy_templates.has(definition_id):
			_legacy_templates[definition_id] = legacy_template.duplicate(true)
		return true
	_definitions[definition_id] = ItemDefinitionScript.new(normalized_definition)
	if not legacy_template.is_empty():
		_legacy_templates[definition_id] = legacy_template.duplicate(true)
	return true


func load_book(
	book_value: Variant,
	source_scope: String,
	campaign_id: String,
	source_path: String,
	image_keys: Dictionary = {},
) -> bool:
	last_errors.clear()
	if source_scope not in SOURCE_SCOPES:
		_error(source_path, "", "source.scope", "must be shared or campaign")
		return false
	if source_scope == "campaign" and campaign_id.strip_edges().is_empty():
		_error(source_path, "", "source.campaignId", "must not be empty")
		return false
	if not (book_value is Dictionary):
		_error(source_path, "", "", "item book must be a JSON object")
		return false
	var book: Dictionary = book_value
	var normalized_definitions: Array[ItemDefinition] = []
	var batch_ids := {}
	var batch_classic_ids := {}
	for catalog_key_value: Variant in book:
		if not (catalog_key_value is String):
			_error(source_path, str(catalog_key_value), "", "catalog key must be a string")
			continue
		var catalog_key := str(catalog_key_value)
		var source_value: Variant = book[catalog_key_value]
		var definition := _normalize_definition(
			catalog_key,
			source_value,
			source_scope,
			campaign_id,
			source_path,
			image_keys,
		)
		if definition == null:
			continue
		if batch_ids.has(definition.definition_id):
			_error(
				source_path,
				catalog_key,
				"definitionId",
				"duplicates %s in this item book" % definition.definition_id,
			)
			continue
		batch_ids[definition.definition_id] = catalog_key
		for item_id: int in definition.classic_item_ids():
			var classic_key := "%s:%d" % [campaign_id if source_scope == "campaign" else "", item_id]
			if batch_classic_ids.has(classic_key):
				_error(
					source_path,
					catalog_key,
					"classic.itemIds",
					"Classic item ID %d also belongs to %s" % [
						item_id,
						batch_classic_ids[classic_key],
					],
				)
			else:
				batch_classic_ids[classic_key] = catalog_key
		normalized_definitions.append(definition)
	if not last_errors.is_empty():
		return false

	var staged_definitions := _definitions.duplicate()
	var staged_shared_by_key := _shared_by_key.duplicate()
	var staged_campaign_by_key := _campaign_by_key.duplicate()
	var staged_active_by_key := _active_by_key.duplicate()
	var staged_classic_shared := _classic_shared.duplicate()
	var staged_classic_by_campaign := _classic_by_campaign.duplicate(true)
	var staged_active_campaign_id := _active_campaign_id
	if source_scope == "campaign":
		staged_active_campaign_id = campaign_id

	for definition: ItemDefinition in normalized_definitions:
		var existing: ItemDefinition = staged_definitions.get(definition.definition_id)
		if existing != null and (
			existing.catalog_key != definition.catalog_key
			or existing.source().get("path") != definition.source().get("path")
		):
			_error(
				source_path,
				definition.catalog_key,
				"definitionId",
				"%s is already owned by %s" % [
					definition.definition_id,
					existing.source().get("path", "another source"),
				],
			)
			continue
		staged_definitions[definition.definition_id] = definition
		if source_scope == "shared":
			staged_shared_by_key[definition.catalog_key] = definition.definition_id
			var campaign_key := _campaign_key(
				staged_active_campaign_id,
				definition.catalog_key,
			)
			if staged_active_campaign_id.is_empty() \
					or not staged_campaign_by_key.has(campaign_key):
				staged_active_by_key[definition.catalog_key] = definition.definition_id
		else:
			var campaign_key := _campaign_key(campaign_id, definition.catalog_key)
			staged_campaign_by_key[campaign_key] = definition.definition_id
			staged_active_by_key[definition.catalog_key] = definition.definition_id
		for item_id: int in definition.classic_item_ids():
			if source_scope == "shared":
				var owner := str(staged_classic_shared.get(item_id, ""))
				if not owner.is_empty() and owner != definition.definition_id:
					_error(
						source_path,
						definition.catalog_key,
						"classic.itemIds",
						"Classic item ID %d is already owned by %s" % [item_id, owner],
					)
				else:
					staged_classic_shared[item_id] = definition.definition_id
			else:
				if not staged_classic_by_campaign.has(campaign_id):
					staged_classic_by_campaign[campaign_id] = {}
				var campaign_index: Dictionary = staged_classic_by_campaign[campaign_id]
				var owner := str(campaign_index.get(item_id, ""))
				if not owner.is_empty() and owner != definition.definition_id:
					_error(
						source_path,
						definition.catalog_key,
						"classic.itemIds",
						"Classic item ID %d is already owned by %s" % [item_id, owner],
					)
				else:
					campaign_index[item_id] = definition.definition_id
	if not last_errors.is_empty():
		return false

	_definitions = staged_definitions
	_shared_by_key = staged_shared_by_key
	_campaign_by_key = staged_campaign_by_key
	_active_by_key = staged_active_by_key
	_classic_shared = staged_classic_shared
	_classic_by_campaign = staged_classic_by_campaign
	_active_campaign_id = staged_active_campaign_id
	return true


func resolve_catalog_key(
	source_scope: String,
	campaign_id: String,
	catalog_key: String,
	allow_shared_fallback := false,
) -> String:
	if source_scope == "shared":
		return str(_shared_by_key.get(catalog_key, ""))
	if source_scope != "campaign":
		return ""
	var definition_id := str(_campaign_by_key.get(
		_campaign_key(campaign_id, catalog_key),
		"",
	))
	if definition_id.is_empty() and allow_shared_fallback:
		definition_id = str(_shared_by_key.get(catalog_key, ""))
	return definition_id


func resolve_active_catalog_key(catalog_key: String) -> String:
	return str(_active_by_key.get(catalog_key, ""))


func resolve_classic_item(campaign_id: String, item_id: int) -> String:
	var normalized_id: int = abs(item_id)
	var campaign_index: Dictionary = _classic_by_campaign.get(campaign_id, {})
	var definition_id := str(campaign_index.get(normalized_id, ""))
	if definition_id.is_empty():
		definition_id = str(_classic_shared.get(normalized_id, ""))
	return definition_id


func create_instance(
	definition_id: String,
	overrides: Dictionary = {},
) -> ItemInstance:
	last_errors.clear()
	var definition := get_definition(definition_id)
	if definition == null:
		_error("", definition_id, "definitionId", "does not resolve in the item catalog")
		return null
	for field_name: Variant in overrides:
		if str(field_name) not in INSTANCE_OVERRIDE_FIELDS:
			_error(
				"",
				definition_id,
				"overrides.%s" % field_name,
				"is not a supported instance field",
			)
	if not last_errors.is_empty():
		return null

	var instance_id := str(overrides.get("instanceId", "")).strip_edges()
	if instance_id.is_empty():
		instance_id = _new_instance_id()
	if _issued_instance_ids.has(instance_id):
		_error("", definition_id, "instanceId", "%s has already been issued" % instance_id)
		return null
	var gameplay := definition.gameplay()
	var charges_value: Variant = overrides.get(
		"charges",
		gameplay.get("initialCharges", 0),
	)
	if not _is_integer(charges_value):
		_error("", definition_id, "charges", "must be an integer")
		return null
	var charges := int(charges_value)
	var maximum_charges := int(gameplay.get("maxCharges", 0))
	if charges < 0 or (maximum_charges > 0 and charges > maximum_charges):
		_error(
			"",
			definition_id,
			"charges",
			"%d is outside the supported range 0..%d" % [charges, maximum_charges],
		)
		return null
	var equipped_value: Variant = overrides.get("equipped", false)
	var identified_value: Variant = overrides.get(
		"identified",
		definition.default_identified,
	)
	if not (equipped_value is bool):
		_error("", definition_id, "equipped", "must be a boolean")
	if not (identified_value is bool):
		_error("", definition_id, "identified", "must be a boolean")
	var state_data_value: Variant = overrides.get("stateData", {})
	if not (state_data_value is Dictionary) or not _is_json_compatible(state_data_value):
		_error(
			"",
			definition_id,
			"stateData",
			"must contain JSON-compatible string-keyed data",
		)
	if not last_errors.is_empty():
		return null
	_issued_instance_ids[instance_id] = true
	return ItemInstanceScript.new(
		instance_id,
		definition_id,
		charges,
		bool(equipped_value),
		bool(identified_value),
		state_data_value,
	)


func create_restored_instance(
	definition_id: String,
	instance_id: String,
	charges: int,
	equipped: bool,
	identified: bool,
	state_data: Dictionary = {},
	allow_legacy_charge_range := false,
	allow_reissued_instance_id := false,
) -> ItemInstance:
	last_errors.clear()
	var definition := get_definition(definition_id)
	if definition == null:
		_error("", definition_id, "definitionId", "does not resolve in the item catalog")
		return null
	var normalized_instance_id := instance_id.strip_edges()
	if normalized_instance_id.is_empty():
		_error("", definition_id, "instanceId", "must not be empty")
	if _issued_instance_ids.has(normalized_instance_id) \
			and not allow_reissued_instance_id:
		_error(
			"",
			definition_id,
			"instanceId",
			"%s has already been issued" % normalized_instance_id,
		)
	if not _is_json_compatible(state_data):
		_error(
			"",
			definition_id,
			"stateData",
			"must contain JSON-compatible string-keyed data",
		)
	var maximum_charges := int(definition.gameplay_value("maxCharges", 0))
	if not allow_legacy_charge_range \
			and (charges < 0 or (maximum_charges > 0 and charges > maximum_charges)):
		_error(
			"",
			definition_id,
			"charges",
			"%d is outside the supported range 0..%d" % [charges, maximum_charges],
		)
	if not last_errors.is_empty():
		return null
	_issued_instance_ids[normalized_instance_id] = true
	return ItemInstanceScript.new(
		normalized_instance_id,
		definition_id,
		charges,
		equipped,
		identified,
		state_data,
	)


func create_instance_for_catalog_key(
	catalog_key: String,
	overrides: Dictionary = {},
) -> ItemInstance:
	last_errors.clear()
	var definition_id := resolve_active_catalog_key(catalog_key)
	if definition_id.is_empty():
		_error("", catalog_key, "catalogKey", "does not resolve in the active item catalog")
		return null
	return create_instance(definition_id, overrides)


func bind_legacy_template(definition_id: String, template: Dictionary) -> bool:
	last_errors.clear()
	if not _definitions.has(definition_id):
		_error("", definition_id, "definitionId", "cannot bind an unknown definition")
		return false
	_legacy_templates[definition_id] = template.duplicate(true)
	return true


func legacy_template(definition_id: String) -> Dictionary:
	var template_value: Variant = _legacy_templates.get(definition_id)
	return template_value.duplicate(true) if template_value is Dictionary else {}


func legacy_dictionary_for_instance(instance: ItemInstance) -> Dictionary:
	last_errors.clear()
	if instance == null:
		_error("", "", "instance", "must not be null")
		return {}
	var definition := get_definition(instance.definition_id)
	if definition == null:
		_error(
			"",
			instance.definition_id,
			"definitionId",
			"does not resolve in the item catalog",
		)
		return {}
	var result := legacy_template(instance.definition_id)
	if result.is_empty():
		_error(
			"",
			instance.definition_id,
			"legacyTemplate",
			"has not been bound",
		)
		return {}
	result["definitionId"] = instance.definition_id
	result["instanceId"] = instance.instance_id
	result["charges"] = instance.charges
	result["equipped"] = 1 if instance.equipped else 0
	result["is_identified"] = 1 if instance.identified else 0
	result["stateData"] = instance.state_data()
	return result


func rollback_import(
	instance_ids: Array[String],
	embedded_definition_ids: Array[String],
) -> void:
	for instance_id: String in instance_ids:
		_issued_instance_ids.erase(instance_id)
	for definition_id: String in embedded_definition_ids:
		var definition := get_definition(definition_id)
		if definition == null or definition.source_scope != "embedded":
			continue
		_definitions.erase(definition_id)
		_legacy_templates.erase(definition_id)


func create_legacy_item(
	definition_id: String,
	overrides: Dictionary = {},
) -> Dictionary:
	last_errors.clear()
	var instance := create_instance(definition_id, overrides)
	if instance == null:
		return {}
	var template_value: Variant = _legacy_templates.get(definition_id)
	if not (template_value is Dictionary):
		_error("", definition_id, "legacyTemplate", "has not been bound")
		return {}
	var result: Dictionary = template_value.duplicate(true)
	result["charges"] = instance.charges
	result["equipped"] = 1 if instance.equipped else 0
	result["is_identified"] = 1 if instance.identified else 0
	return result


func create_legacy_item_for_catalog_key(
	catalog_key: String,
	overrides: Dictionary = {},
) -> Dictionary:
	last_errors.clear()
	var definition_id := resolve_active_catalog_key(catalog_key)
	if definition_id.is_empty():
		_error("", catalog_key, "catalogKey", "does not resolve in the active item catalog")
		return {}
	return create_legacy_item(definition_id, overrides)


static func encode_identity_component(value: String) -> String:
	var encoded := ""
	for byte_value: int in value.to_utf8_buffer():
		var is_unreserved := (
			(byte_value >= 65 and byte_value <= 90)
			or (byte_value >= 97 and byte_value <= 122)
			or (byte_value >= 48 and byte_value <= 57)
			or byte_value in [45, 46, 95, 126]
		)
		if is_unreserved:
			encoded += String.chr(byte_value)
		else:
			encoded += "%%%02X" % byte_value
	return encoded


func _normalize_definition(
	catalog_key: String,
	source_value: Variant,
	source_scope: String,
	campaign_id: String,
	source_path: String,
	image_keys: Dictionary,
) -> ItemDefinition:
	if catalog_key.is_empty():
		_error(source_path, catalog_key, "catalogKey", "must not be empty")
		return null
	if not (source_value is Dictionary):
		_error(source_path, catalog_key, "", "definition must be a JSON object")
		return null
	var source: Dictionary = source_value
	var error_count := last_errors.size()
	for field_name: String in DEFINITION_REQUIRED_STRINGS:
		if not source.has(field_name):
			_error(source_path, catalog_key, field_name, "is required")
		elif not (source[field_name] is String):
			_error(source_path, catalog_key, field_name, "must be a string")
		elif field_name != "sound" and str(source[field_name]).strip_edges().is_empty():
			_error(source_path, catalog_key, field_name, "must not be empty")
	if source.has("img_ptr") and source["img_ptr"] is String \
			and not image_keys.is_empty() \
			and not image_keys.has(str(source["img_ptr"])):
		_error(
			source_path,
			catalog_key,
			"img_ptr",
			"references missing image key %s" % source["img_ptr"],
		)
	for field_name: String in ARRAY_FIELDS:
		if source.has(field_name) and not (source[field_name] is Array):
			_error(source_path, catalog_key, field_name, "must be an array")
	if source.get("classicItemIds", []) is Array:
		for alias_index: int in source.get("classicItemIds", []).size():
			var alias_value: Variant = source["classicItemIds"][alias_index]
			if not _is_integer(alias_value) or int(alias_value) == 0:
				_error(
					source_path,
					catalog_key,
					"classicItemIds[%d]" % alias_index,
					"must be a non-zero integer",
				)
	for field_name: String in DICTIONARY_FIELDS:
		if source.has(field_name) and not (source[field_name] is Dictionary):
			_error(source_path, catalog_key, field_name, "must be an object")
	if source.get("stats", {}) is Dictionary:
		var source_stats: Dictionary = source.get("stats", {})
		if source_stats.has("ClassicMagicResistance") \
				and not _is_integer(source_stats["ClassicMagicResistance"]):
			_error(
				source_path,
				catalog_key,
				"stats.ClassicMagicResistance",
				"must be an integer",
			)
	for field_name: String in INTEGER_FIELDS:
		if source.has(field_name) and not _is_integer(source[field_name]):
			_error(source_path, catalog_key, field_name, "must be an integer")
	for field_name: String in ["drops_on_defeat"]:
		if source.has(field_name) \
				and not (source[field_name] is bool) \
				and not _is_integer(source[field_name]):
			_error(source_path, catalog_key, field_name, "must be a boolean or integer")
	if source.has("charges") != source.has("charges_max"):
		_error(
			source_path,
			catalog_key,
			"charges",
			"charges and charges_max must be authored together",
		)
	var known_source_fields := {}
	for canonical_name: String in SOURCE_HOOK_ALIASES:
		var first_source_value: Variant = null
		var first_source_field := ""
		for alias_value: Variant in SOURCE_HOOK_ALIASES[canonical_name]:
			var alias := str(alias_value)
			known_source_fields[alias] = true
			if not source.has(alias):
				continue
			if not (source[alias] is String):
				_error(source_path, catalog_key, alias, "must be a source string")
				continue
			if first_source_field.is_empty():
				first_source_field = alias
				first_source_value = source[alias]
			elif source[alias] != first_source_value:
				_error(
					source_path,
					catalog_key,
					alias,
					"conflicts with %s for canonical hook %s"
					% [first_source_field, canonical_name],
				)
	for collection_name: String in ["traits", "melee_inflicted_traits"]:
		var descriptors_value: Variant = source.get(collection_name, [])
		if not (descriptors_value is Array):
			continue
		for descriptor_index: int in descriptors_value.size():
			var descriptor_value: Variant = descriptors_value[descriptor_index]
			if not (descriptor_value is Array) or descriptor_value.size() < 2:
				_error(
					source_path,
					catalog_key,
					"%s[%d]" % [collection_name, descriptor_index],
					"must be an array containing a trait name and arguments",
				)
				continue
			if not (descriptor_value[0] is String) \
					or str(descriptor_value[0]).strip_edges().is_empty():
				_error(
					source_path,
					catalog_key,
					"%s[%d][0]" % [collection_name, descriptor_index],
					"must be a non-empty trait resource or source name",
				)
				continue
			var trait_name := str(descriptor_value[0])
			if not trait_name.ends_with(".gd"):
				var trait_source_field := "%s_source" % trait_name
				known_source_fields[trait_source_field] = true
				if not source.has(trait_source_field):
					_error(
						source_path,
						catalog_key,
						trait_source_field,
						"is required by scripted trait %s" % trait_name,
					)
				elif not (source[trait_source_field] is String):
					_error(
						source_path,
						catalog_key,
						trait_source_field,
						"must be a source string",
					)
	for field_name_value: Variant in source:
		var field_name := str(field_name_value)
		if field_name.ends_with("_source") and not known_source_fields.has(field_name):
			_error(
				source_path,
				catalog_key,
				field_name,
				"is not a recognized item hook or scripted-trait source field",
			)
	if last_errors.size() != error_count:
		return null

	var classic_ids := _classic_ids(source)
	for item_id: int in classic_ids:
		if item_id <= 0:
			_error(
				source_path,
				catalog_key,
				"classicItemId",
				"Classic item IDs must be non-zero integers",
			)
	if last_errors.size() != error_count:
		return null

	var definition_id := ""
	if source_scope == "campaign" and not classic_ids.is_empty():
		definition_id = "classic:%s:%d" % [
			encode_identity_component(campaign_id),
			classic_ids[0],
		]
	elif source_scope == "campaign":
		definition_id = "campaign:%s:%s" % [
			encode_identity_component(campaign_id),
			encode_identity_component(catalog_key),
		]
	else:
		definition_id = "shared:%s" % encode_identity_component(catalog_key)

	var unidentified_name := str(source.get("unidentified_name", source["name"]))
	var default_identified := bool(source.get(
		"is_identified",
		not source.has("unidentified_name"),
	))
	var extra_data: Dictionary = source.get("extra_data", {}).duplicate(true)
	if source.has("notraits"):
		var legacy_fields: Dictionary = extra_data.get(
			"legacyDefinitionFields", {}
		).duplicate(true)
		legacy_fields["notraits"] = source["notraits"].duplicate(true) \
			if source["notraits"] is Array or source["notraits"] is Dictionary \
			else source["notraits"]
		extra_data["legacyDefinitionFields"] = legacy_fields
	var normalized_stats: Dictionary = source.get("stats", {}).duplicate(true)
	if source.has("classicMagicResistance"):
		extra_data["classicMagicResistance"] = int(source["classicMagicResistance"])
		normalized_stats.erase("ClassicMagicResistance")
	elif normalized_stats.has("ClassicMagicResistance"):
		extra_data["classicMagicResistance"] = int(
			normalized_stats["ClassicMagicResistance"]
		)
		normalized_stats.erase("ClassicMagicResistance")
	for field_name: String in [
		"classicItemType",
		"classicIconId",
		"classicSoundId",
	]:
		if source.has(field_name):
			extra_data[field_name] = source[field_name]
	var weapon_damage: Dictionary = source.get("weapon_dmg", {}).duplicate(true)
	var melee_animation := str(source.get(
		"melee_atk_anim_icon",
		"ATK_HTH" if not weapon_damage.is_empty() else "",
	))
	var normalized := {
		"definitionId": definition_id,
		"catalogKey": catalog_key,
		"source": {
			"scope": source_scope,
			"campaignId": campaign_id if source_scope == "campaign" else "",
			"path": source_path,
		},
		"name": str(source["name"]),
		"unidentifiedName": unidentified_name,
		"description": str(source.get("description", "")),
		"type": str(source["type"]),
		"imageKey": str(source["img_ptr"]),
		"soundKey": str(source["sound"]),
		"defaultIdentified": default_identified,
		"gameplay": {
			"magical": int(source.get("is_magical", 0)),
			"hands": int(source.get("hands", 0)),
			"unique": int(source.get("unique", 0)),
			"deleteOnEmpty": int(source.get("delete_on_empty", 0)),
			"slots": source.get("slots", []).duplicate(true),
			"equippable": int(source.get("equippable", 0)),
			"dropsOnDefeat": bool(source.get("drops_on_defeat", false)),
			"onlyUsableByClasses": source.get(
				"only_usable_by_classes", []
			).duplicate(true),
			"notUsableByClasses": source.get(
				"not_usable_by_classes", []
			).duplicate(true),
			"onlyUsableByRaces": source.get(
				"only_usable_by_races", []
			).duplicate(true),
			"notUsableByRaces": source.get(
				"not_usable_by_races", []
			).duplicate(true),
			"stats": normalized_stats,
			"statsSummary": str(source.get("stats_mini", "")),
			"initialCharges": int(source.get("charges", 0)),
			"maxCharges": int(source.get("charges_max", 0)),
			"tradeable": int(source.get("tradeable", 1)),
			"baseWeight": int(source.get("weight", 0)),
			"price": int(source.get("price", 0)),
			"weightPerCharge": int(source.get("charges_weight", 0)),
			"splittable": int(source.get("splittable", 0)),
			"ammoType": str(source.get("ammo_type", "cantuse")),
			"weaponDamage": weapon_damage,
			"meleeAnimation": melee_animation,
			"taggedWeaponDamage": source.get(
				"weapon_tag_bonus_dmg", {}
			).duplicate(true),
			"extraData": extra_data,
		},
		"hooks": {
			"sources": _hook_sources(source),
			"spellUses": _spell_uses(source),
			"traits": source.get("traits", []).duplicate(true),
			"meleeInflictedTraits": source.get(
				"melee_inflicted_traits", []
			).duplicate(true),
		},
		"classic": {
			"itemIds": classic_ids,
			"itemCategory": source.get("classicItemCategory"),
			"recordId": source.get("classicRecordId"),
			"record": source.get("classicRecord", {}).duplicate(true),
			"materialization": source.get(
				"classicMaterialization", {}
			).duplicate(true),
		},
	}
	if not _is_json_compatible(normalized):
		_error(
			source_path,
			catalog_key,
			"",
			"normalized definition must contain only JSON-compatible data",
		)
		return null
	return ItemDefinitionScript.new(normalized)


func _classic_ids(source: Dictionary) -> Array[int]:
	var result: Array[int] = []
	if source.has("classicItemId"):
		var primary_id: int = abs(int(source["classicItemId"]))
		if not result.has(primary_id):
			result.append(primary_id)
	var aliases_value: Variant = source.get("classicItemIds", [])
	if aliases_value is Array:
		for alias_value: Variant in aliases_value:
			if not _is_integer(alias_value):
				continue
			var alias_id: int = abs(int(alias_value))
			if not result.has(alias_id):
				result.append(alias_id)
	return result


func _hook_sources(source: Dictionary) -> Dictionary:
	var result := {}
	for canonical_name: String in SOURCE_HOOK_ALIASES:
		for alias_value: Variant in SOURCE_HOOK_ALIASES[canonical_name]:
			var alias := str(alias_value)
			if source.has(alias):
				result[canonical_name] = source[alias]
				break
	for collection_name: String in ["traits", "melee_inflicted_traits"]:
		var descriptors_value: Variant = source.get(collection_name, [])
		if not (descriptors_value is Array):
			continue
		for descriptor_value: Variant in descriptors_value:
			if not (descriptor_value is Array) or descriptor_value.is_empty():
				continue
			var trait_name := str(descriptor_value[0])
			var source_field := "%s_source" % trait_name
			if not trait_name.ends_with(".gd") and source.has(source_field):
				result[source_field] = source[source_field]
	return result


func _spell_uses(source: Dictionary) -> Dictionary:
	var result := {}
	for field_name: String in ["_on_field_use_spell", "_on_combat_use_spell"]:
		if source.has(field_name):
			result[field_name] = source[field_name].duplicate(true) \
				if source[field_name] is Array or source[field_name] is Dictionary \
				else source[field_name]
	return result


func _new_instance_id() -> String:
	var bytes := Crypto.new().generate_random_bytes(16)
	bytes[6] = (bytes[6] & 0x0f) | 0x40
	bytes[8] = (bytes[8] & 0x3f) | 0x80
	var value := bytes.hex_encode()
	return "%s-%s-%s-%s-%s" % [
		value.substr(0, 8),
		value.substr(8, 4),
		value.substr(12, 4),
		value.substr(16, 4),
		value.substr(20, 12),
	]


func _campaign_key(campaign_id: String, catalog_key: String) -> String:
	return "%s\n%s" % [campaign_id, catalog_key]


func _error(
	source_path: String,
	catalog_key: String,
	field_path: String,
	message: String,
) -> void:
	var context := source_path if not source_path.is_empty() else "item catalog"
	if not catalog_key.is_empty():
		context += "[%s]" % catalog_key
	if not field_path.is_empty():
		context += ".%s" % field_path
	last_errors.append("%s: %s" % [context, message])


static func _is_integer(value: Variant) -> bool:
	if value is int:
		return true
	if value is float:
		return is_equal_approx(value, float(int(value)))
	return false


static func _is_json_compatible(value: Variant) -> bool:
	if value == null or value is bool or value is String or value is int or value is float:
		return true
	if value is Array:
		for child: Variant in value:
			if not _is_json_compatible(child):
				return false
		return true
	if value is Dictionary:
		for key: Variant in value:
			if not (key is String) or not _is_json_compatible(value[key]):
				return false
		return true
	return false
