class_name ItemSerialization
extends RefCounted

const ItemInstanceScript = preload("res://scripts/items/item_instance.gd")

const FORMAT := "realmz-remake-item-instance"
const FORMAT_VERSION := 1
const VERSIONED_ROOT_FIELDS := [
	"format",
	"formatVersion",
	"instanceId",
	"definitionId",
	"state",
	"embeddedDefinition",
]
const EMBEDDED_ROOT_FIELDS := [
	"definitionId",
	"digest",
	"catalogKey",
	"source",
	"name",
	"unidentifiedName",
	"description",
	"type",
	"imageKey",
	"soundKey",
	"defaultIdentified",
	"gameplay",
	"hooks",
	"classic",
	"media",
]
const RUNTIME_ONLY_FIELDS := [
	"texture",
	"script",
	"_item_instance",
	"_on_equipping",
	"_on_unequipping",
	"_on_field_use",
	"_on_combat_use",
	"_on_drop",
	"_calculate_melee_attack",
	"_calculate_melee_accuracy",
]
const LEGACY_DEFINITION_FIELDS := [
	"definitionId",
	"instanceId",
	"stateData",
	"KEY",
	"name",
	"unidentified_name",
	"description",
	"type",
	"img_ptr",
	"sound",
	"is_magical",
	"hands",
	"unique",
	"is_unique",
	"delete_on_empty",
	"slots",
	"equippable",
	"equipped",
	"drops_on_defeat",
	"only_usable_by_classes",
	"not_usable_by_classes",
	"only_usable_by_races",
	"not_usable_by_races",
	"stats",
	"stats_mini",
	"charges",
	"charges_max",
	"is_identified",
	"identified",
	"tradeable",
	"weight",
	"price",
	"charges_weight",
	"splittable",
	"ammo_type",
	"weapon_dmg",
	"melee_atk_anim_icon",
	"weapon_tag_bonus_dmg",
	"extra_data",
	"traits",
	"melee_inflicted_traits",
	"custom_spell_source",
	"_on_equipping_source",
	"on_equipping_source",
	"_on_unequipping_source",
	"on_unequipping_source",
	"_on_field_use_source",
	"_on_combat_use_source",
	"_on_drop_source",
	"_calculate_melee_attack_source",
	"_calculate_melee_accuracy_source",
	"_on_field_use_spell",
	"_on_combat_use_spell",
	"classicItemId",
	"classicItemIds",
	"classicItemCategory",
	"classicRecordId",
	"classicRecord",
	"classicMaterialization",
	"classicItemType",
	"classicIconId",
	"classicSoundId",
	"classicMagicResistance",
	"imgdata",
	"imgdatasize",
]
const HOOK_SOURCE_ALIASES := {
	"_on_equipping_source": ["_on_equipping_source", "on_equipping_source"],
	"_on_unequipping_source": ["_on_unequipping_source", "on_unequipping_source"],
	"_on_field_use_source": ["_on_field_use_source"],
	"_on_combat_use_source": ["_on_combat_use_source"],
	"_on_drop_source": ["_on_drop_source"],
	"_calculate_melee_attack_source": ["_calculate_melee_attack_source"],
	"_calculate_melee_accuracy_source": ["_calculate_melee_accuracy_source"],
	"custom_spell_source": ["custom_spell_source"],
}
const LEGACY_IDENTITY_STATE_KEY := "legacyDefinitionIdentity"
const LEGACY_MUTABLE_FIELDS_STATE_KEY := "legacyMutableFields"
const LEGACY_IDENTITY_FIELDS := [
	"classicItemId",
	"classicItemIds",
	"classicItemCategory",
	"classicRecordId",
	"classicRecord",
	"classicMaterialization",
	"classicItemType",
	"classicIconId",
	"classicSoundId",
	"classicMagicResistance",
]

var last_errors: Array[String] = []
var last_diagnostics: Array[String] = []

var _catalog: ItemCatalog


func _init(catalog: ItemCatalog) -> void:
	_catalog = catalog


func serialize_item(instance: ItemInstance) -> Dictionary:
	last_errors.clear()
	last_diagnostics.clear()
	return _serialize_item(instance, "item")


func _serialize_item(instance: ItemInstance, context: String) -> Dictionary:
	if instance == null:
		_error(context, "must be an ItemInstance")
		return {}
	var definition := _catalog.get_definition(instance.definition_id)
	if definition == null:
		_error(
			"%s.definitionId" % context,
			"%s does not resolve in the item catalog" % instance.definition_id,
		)
		return {}
	var state_data := instance.state_data()
	if not _is_json_compatible(state_data):
		_error(
			"%s.state.data" % context,
			"must contain JSON-compatible string-keyed data",
		)
		return {}
	var serialized := {
		"format": FORMAT,
		"formatVersion": FORMAT_VERSION,
		"instanceId": instance.instance_id,
		"definitionId": instance.definition_id,
		"state": {
			"charges": instance.charges,
			"equipped": instance.equipped,
			"identified": instance.identified,
			"data": state_data,
		},
	}
	if definition.source_scope == "embedded":
		serialized["embeddedDefinition"] = definition.to_dictionary()
	return serialized


func serialize_inventory(instances: Array) -> Dictionary:
	last_errors.clear()
	last_diagnostics.clear()
	var values: Array = []
	var seen_instance_ids := {}
	for index: int in instances.size():
		var instance_value: Variant = instances[index]
		if not (instance_value is ItemInstance):
			_error("inventory[%d]" % index, "must be an ItemInstance")
			continue
		var instance: ItemInstance = instance_value
		if seen_instance_ids.has(instance.instance_id):
			_error(
				"inventory[%d].instanceId" % index,
				"%s is duplicated in this inventory" % instance.instance_id,
			)
			continue
		seen_instance_ids[instance.instance_id] = true
		var serialized := _serialize_item(instance, "inventory[%d]" % index)
		if not serialized.is_empty():
			values.append(serialized)
	if not last_errors.is_empty():
		return _result(false)
	return _result(true, {"value": values})


func import_item(value: Variant, campaign_id := "") -> Dictionary:
	var result := import_inventory([value], campaign_id)
	if not bool(result.get("ok", false)):
		return result
	return _result(
		true,
		{
			"instance": result.get("instances", [])[0],
			"legacyView": result.get("legacyViews", [])[0],
		},
	)


func import_inventory(
	values: Array,
	campaign_id := "",
	defer_unresolved := false,
) -> Dictionary:
	last_errors.clear()
	last_diagnostics.clear()
	var plans: Array[Dictionary] = []
	var seen_instance_ids := {}
	var pending_embedded := {}
	for index: int in values.size():
		var value: Variant = values[index]
		if value is ItemInstance:
			var existing_instance: ItemInstance = value
			if _catalog.get_definition(existing_instance.definition_id) == null:
				_error(
					"inventory[%d].definitionId" % index,
					"%s does not resolve in the item catalog"
					% existing_instance.definition_id,
				)
				continue
			if seen_instance_ids.has(existing_instance.instance_id):
				_error(
					"inventory[%d].instanceId" % index,
					"%s is duplicated in this inventory"
					% existing_instance.instance_id,
				)
				continue
			seen_instance_ids[existing_instance.instance_id] = true
			plans.append({
				"index": index,
				"existingInstance": existing_instance,
				"definitionId": existing_instance.definition_id,
			})
			continue
		if not (value is Dictionary):
			_error("inventory[%d]" % index, "must be an item object")
			continue
		var item_value: Dictionary = value
		var plan: Dictionary
		if item_value.has("format"):
			plan = _plan_versioned_item(
				item_value,
				index,
				defer_unresolved,
			)
		else:
			plan = _plan_legacy_item(item_value, index, campaign_id)
		if plan.is_empty():
			continue
		var instance_id := str(plan.get("instanceId", ""))
		if seen_instance_ids.has(instance_id):
			_error(
				"inventory[%d].instanceId" % index,
				"%s is duplicated in this inventory" % instance_id,
			)
			continue
		seen_instance_ids[instance_id] = true
		plan["reissuedInstanceId"] = _catalog.has_issued_instance_id(instance_id)
		var embedded_value: Variant = plan.get("embeddedDefinition")
		if embedded_value is Dictionary:
			var embedded: Dictionary = embedded_value
			var embedded_id := str(embedded.get("definitionId", ""))
			if pending_embedded.has(embedded_id) \
					and pending_embedded[embedded_id] != embedded:
				_error(
					"inventory[%d].embeddedDefinition" % index,
					"%s conflicts with another item in this inventory" % embedded_id,
				)
				continue
			pending_embedded[embedded_id] = embedded
		plans.append(plan)
	if not last_errors.is_empty():
		return _result(false)

	var registered_embedded_ids: Array[String] = []
	for embedded_id_value: Variant in pending_embedded:
		var embedded_id := str(embedded_id_value)
		var definition: Dictionary = pending_embedded[embedded_id_value]
		var existed := _catalog.get_definition(embedded_id) != null
		if not _catalog.register_embedded_definition(
			definition,
			_legacy_template_from_definition(definition),
		):
			for message: String in _catalog.last_errors:
				_error("embeddedDefinition", message)
			_catalog.rollback_import([], registered_embedded_ids)
			return _result(false)
		if not existed:
			registered_embedded_ids.append(embedded_id)

	var instances: Array[ItemInstance] = []
	var deferred: Array[Dictionary] = []
	var issued_instance_ids: Array[String] = []
	for plan: Dictionary in plans:
		var deferred_value: Variant = plan.get("deferredValue")
		if deferred_value is Dictionary:
			deferred.append(deferred_value.duplicate(true))
			continue
		var existing_value: Variant = plan.get("existingInstance")
		if existing_value is ItemInstance:
			instances.append(existing_value)
			continue
		var instance := _catalog.create_restored_instance(
			str(plan.get("definitionId", "")),
			str(plan.get("instanceId", "")),
			int(plan.get("charges", 0)),
			bool(plan.get("equipped", false)),
			bool(plan.get("identified", true)),
			plan.get("stateData", {}),
			bool(plan.get("legacy", false)),
			bool(plan.get("reissuedInstanceId", false)),
		)
		if instance == null:
			for message: String in _catalog.last_errors:
				_error("inventory[%d]" % int(plan.get("index", -1)), message)
			_catalog.rollback_import(issued_instance_ids, registered_embedded_ids)
			return _result(false)
		instances.append(instance)
		if not bool(plan.get("reissuedInstanceId", false)):
			issued_instance_ids.append(instance.instance_id)

	var legacy_views: Array[Dictionary] = []
	for instance: ItemInstance in instances:
		var view := legacy_view(instance)
		if view.is_empty():
			_catalog.rollback_import(issued_instance_ids, registered_embedded_ids)
			return _result(false)
		legacy_views.append(view)
	return _result(
		true,
		{
			"instances": instances,
			"legacyViews": legacy_views,
			"deferred": deferred,
		},
	)


func legacy_view(instance: ItemInstance) -> Dictionary:
	if instance == null:
		_error("item", "must be an ItemInstance")
		return {}
	var definition := _catalog.get_definition(instance.definition_id)
	if definition == null:
		_error(
			"item.definitionId",
			"%s does not resolve in the item catalog" % instance.definition_id,
		)
		return {}
	var result := _catalog.legacy_template(instance.definition_id)
	if result.is_empty():
		result = _legacy_template_from_definition(definition.to_dictionary())
	if result.is_empty():
		_error(
			"item.definitionId",
			"%s cannot be projected to a legacy runtime view" % instance.definition_id,
		)
		return {}
	var legacy_identity: Variant = instance.state_value(
		LEGACY_IDENTITY_STATE_KEY,
		{},
	)
	if legacy_identity is Dictionary:
		for field_name: String in LEGACY_IDENTITY_FIELDS:
			if legacy_identity.has(field_name):
				result[field_name] = _duplicate_portable_value(
					legacy_identity[field_name]
				)
	result["definitionId"] = instance.definition_id
	result["instanceId"] = instance.instance_id
	result["charges"] = instance.charges
	result["equipped"] = 1 if instance.equipped else 0
	result["is_identified"] = 1 if instance.identified else 0
	result["stateData"] = instance.state_data()
	return result


func sync_instance_from_legacy_view(
	instance: ItemInstance,
	legacy_view_value: Dictionary,
) -> bool:
	last_errors.clear()
	last_diagnostics.clear()
	if instance == null:
		_error("item", "must be an ItemInstance")
		return false
	var charges_value: Variant = legacy_view_value.get("charges", instance.charges)
	if not _is_integer(charges_value):
		_error("item.charges", "must be an integer")
	var equipped_value: Variant = legacy_view_value.get(
		"equipped",
		instance.equipped,
	)
	if not (equipped_value is bool) and not _is_integer(equipped_value):
		_error("item.equipped", "must be a boolean or integer")
	var identified_value: Variant = legacy_view_value.get(
		"is_identified",
		legacy_view_value.get("identified", instance.identified),
	)
	if not (identified_value is bool) and not _is_integer(identified_value):
		_error("item.is_identified", "must be a boolean or integer")
	var state_data_value: Variant = legacy_view_value.get(
		"stateData",
		instance.state_data(),
	)
	if not (state_data_value is Dictionary) \
			or not _is_json_compatible(state_data_value):
		_error(
			"item.stateData",
			"must contain JSON-compatible string-keyed data",
		)
	if not last_errors.is_empty():
		return false
	instance.charges = int(charges_value)
	instance.equipped = bool(equipped_value)
	instance.identified = bool(identified_value)
	for key: Variant in instance.state_data():
		instance.erase_state_value(str(key))
	for key: Variant in state_data_value:
		instance.set_state_value(str(key), state_data_value[key])
	var definition := _catalog.get_definition(instance.definition_id)
	if definition != null:
		var mutable_fields: Dictionary = {}
		var definition_data := definition.to_dictionary()
		for field_name: String in ["name", "description"]:
			if not legacy_view_value.has(field_name):
				continue
			var field_value := str(legacy_view_value[field_name])
			if field_value != str(definition_data.get(field_name, "")):
				mutable_fields[field_name] = field_value
		if mutable_fields.is_empty():
			instance.erase_state_value(LEGACY_MUTABLE_FIELDS_STATE_KEY)
		else:
			instance.set_state_value(
				LEGACY_MUTABLE_FIELDS_STATE_KEY,
				mutable_fields,
			)
	return true


func _plan_versioned_item(
	value: Dictionary,
	index: int,
	defer_unresolved := false,
) -> Dictionary:
	var context := "inventory[%d]" % index
	for field_name_value: Variant in value:
		var field_name := str(field_name_value)
		if field_name not in VERSIONED_ROOT_FIELDS:
			_error(
				"%s.%s" % [context, field_name],
				"is not supported by item format version %d" % FORMAT_VERSION,
			)
	if value.get("format") != FORMAT:
		_error("%s.format" % context, "must be %s" % FORMAT)
	var version_value: Variant = value.get("formatVersion")
	if not _is_integer(version_value) or int(version_value) != FORMAT_VERSION:
		_error(
			"%s.formatVersion" % context,
			"unsupported item format version %s" % str(version_value),
		)
	var instance_id := str(value.get("instanceId", "")).strip_edges()
	if instance_id.is_empty():
		_error("%s.instanceId" % context, "must not be empty")
	var definition_id := str(value.get("definitionId", "")).strip_edges()
	if definition_id.is_empty():
		_error("%s.definitionId" % context, "must not be empty")
	var state_value: Variant = value.get("state")
	if not (state_value is Dictionary):
		_error("%s.state" % context, "must be an object")
		return {}
	var state: Dictionary = state_value
	for field_name: String in ["charges", "equipped", "identified", "data"]:
		if not state.has(field_name):
			_error("%s.state.%s" % [context, field_name], "is required")
	for field_name_value: Variant in state:
		if str(field_name_value) not in ["charges", "equipped", "identified", "data"]:
			_error(
				"%s.state.%s" % [context, field_name_value],
				"is not supported",
			)
	var charges_value: Variant = state.get("charges")
	if not _is_integer(charges_value):
		_error("%s.state.charges" % context, "must be an integer")
	var equipped_value: Variant = state.get("equipped")
	if not (equipped_value is bool):
		_error("%s.state.equipped" % context, "must be a boolean")
	var identified_value: Variant = state.get("identified")
	if not (identified_value is bool):
		_error("%s.state.identified" % context, "must be a boolean")
	var data_value: Variant = state.get("data")
	if not (data_value is Dictionary) or not _is_json_compatible(data_value):
		_error(
			"%s.state.data" % context,
			"must contain JSON-compatible string-keyed data",
		)

	var embedded_value: Variant = value.get("embeddedDefinition")
	if embedded_value != null:
		if not (embedded_value is Dictionary):
			_error("%s.embeddedDefinition" % context, "must be an object")
		elif not _validate_embedded_definition(
			embedded_value,
			definition_id,
			"%s.embeddedDefinition" % context,
		):
			pass
	var installed_definition := _catalog.get_definition(definition_id)
	if installed_definition == null and not (embedded_value is Dictionary):
		if not defer_unresolved:
			_error(
				"%s.definitionId" % context,
				"%s does not resolve and no embedded definition was provided"
				% definition_id,
			)
	elif installed_definition != null and embedded_value is Dictionary \
			and installed_definition.to_dictionary() != embedded_value:
		_error(
			"%s.embeddedDefinition" % context,
			"conflicts with the installed definition %s" % definition_id,
		)
	if not last_errors.is_empty() \
			and _errors_for_context(context):
		return {}
	var plan := {
		"index": index,
		"legacy": false,
		"instanceId": instance_id,
		"definitionId": definition_id,
		"charges": int(charges_value),
		"equipped": bool(equipped_value),
		"identified": bool(identified_value),
		"stateData": data_value.duplicate(true),
		"embeddedDefinition": embedded_value.duplicate(true) \
			if embedded_value is Dictionary else null,
	}
	if installed_definition == null and not (embedded_value is Dictionary):
		plan["deferredValue"] = value.duplicate(true)
	return plan


func _plan_legacy_item(
	value: Dictionary,
	index: int,
	campaign_id: String,
) -> Dictionary:
	var context := "inventory[%d]" % index
	var definition_id := _resolve_legacy_definition(value, campaign_id, context)
	var instance_id := str(value.get("instanceId", "")).strip_edges()
	if instance_id.is_empty():
		instance_id = _new_instance_id()
		_diagnostic(
			"%s.instanceId: generated a stable ID for the legacy item" % context
		)
	var charges_value: Variant = value.get("charges", 0)
	if not _is_integer(charges_value):
		_error("%s.charges" % context, "must be an integer")
	var equipped_value: Variant = value.get("equipped", 0)
	if not (equipped_value is bool) and not _is_integer(equipped_value):
		_error("%s.equipped" % context, "must be a boolean or integer")
	var identified_value: Variant = value.get(
		"is_identified",
		value.get("identified", null),
	)
	var state_data_value: Variant = value.get("stateData", {})
	if not (state_data_value is Dictionary) \
			or not _is_json_compatible(state_data_value):
		_error(
			"%s.stateData" % context,
			"must contain JSON-compatible string-keyed data",
		)
	var embedded_definition: Variant = null
	if definition_id.is_empty():
		var embedded_result := _embedded_definition_from_legacy(value, context)
		if not bool(embedded_result.get("ok", false)):
			return {}
		embedded_definition = embedded_result["definition"]
		definition_id = str(embedded_definition.get("definitionId", ""))
	var definition := _catalog.get_definition(definition_id)
	if definition == null and embedded_definition is Dictionary:
		definition = ItemDefinition.new(embedded_definition)
	if definition == null:
		_error(
			"%s.definitionId" % context,
			"%s does not resolve in the item catalog" % definition_id,
		)
		return {}
	if identified_value == null:
		identified_value = definition.default_identified
	if not (identified_value is bool) and not _is_integer(identified_value):
		_error("%s.is_identified" % context, "must be a boolean or integer")
	var maximum_charges := int(definition.gameplay_value("maxCharges", 0))
	if _is_integer(charges_value) and (
		int(charges_value) < 0 \
		or (maximum_charges > 0 and int(charges_value) > maximum_charges)
	):
		_diagnostic(
			(
				"%s.charges: retained legacy value %d outside definition range 0..%d"
				% [context, int(charges_value), maximum_charges]
			)
		)
	if state_data_value is Dictionary:
		state_data_value = _state_data_with_legacy_identity(
			value,
			state_data_value,
		)
	if not last_errors.is_empty() \
			and _errors_for_context(context):
		return {}
	return {
		"index": index,
		"legacy": true,
		"instanceId": instance_id,
		"definitionId": definition_id,
		"charges": int(charges_value),
		"equipped": bool(equipped_value),
		"identified": bool(identified_value),
		"stateData": state_data_value.duplicate(true),
		"embeddedDefinition": embedded_definition,
	}


func _state_data_with_legacy_identity(
	value: Dictionary,
	state_data: Dictionary,
) -> Dictionary:
	var result := state_data.duplicate(true)
	var legacy_identity := {}
	var existing_value: Variant = result.get(LEGACY_IDENTITY_STATE_KEY, {})
	if existing_value is Dictionary:
		legacy_identity = existing_value.duplicate(true)
	for field_name: String in LEGACY_IDENTITY_FIELDS:
		if value.has(field_name) and _is_json_compatible(value[field_name]):
			legacy_identity[field_name] = _duplicate_portable_value(
				value[field_name]
			)
	if not legacy_identity.is_empty():
		result[LEGACY_IDENTITY_STATE_KEY] = legacy_identity
	return result


static func _duplicate_portable_value(value: Variant) -> Variant:
	if value is Array or value is Dictionary:
		return value.duplicate(true)
	return value


func _resolve_legacy_definition(
	value: Dictionary,
	campaign_id: String,
	context: String,
) -> String:
	var explicit_id := str(value.get("definitionId", "")).strip_edges()
	if not explicit_id.is_empty() and _catalog.get_definition(explicit_id) != null:
		return explicit_id
	var classic_ids: Array[int] = []
	if value.has("classicItemId") and _is_integer(value["classicItemId"]):
		classic_ids.append(abs(int(value["classicItemId"])))
	var aliases_value: Variant = value.get("classicItemIds", [])
	if aliases_value is Array:
		for alias_value: Variant in aliases_value:
			if _is_integer(alias_value):
				var alias_id: int = abs(int(alias_value))
				if not classic_ids.has(alias_id):
					classic_ids.append(alias_id)
	var effective_campaign_id := campaign_id \
		if not campaign_id.strip_edges().is_empty() else \
		_catalog.active_campaign_id()
	for item_id: int in classic_ids:
		var classic_definition_id := _catalog.resolve_classic_item(
			effective_campaign_id,
			item_id,
		)
		if not classic_definition_id.is_empty():
			return classic_definition_id
	var catalog_key := str(value.get("KEY", "")).strip_edges()
	if not catalog_key.is_empty():
		var keyed_definition_id := _catalog.resolve_catalog_key(
			"campaign",
			effective_campaign_id,
			catalog_key,
			true,
		)
		if keyed_definition_id.is_empty():
			keyed_definition_id = _catalog.resolve_active_catalog_key(catalog_key)
		if not keyed_definition_id.is_empty():
			_diagnostic(
				"%s: resolved legacy catalog key %s" % [context, catalog_key]
			)
			return keyed_definition_id
	var display_name := str(value.get("name", ""))
	if not display_name.is_empty():
		var named_definition_id := _catalog.resolve_active_catalog_key(display_name)
		if named_definition_id.is_empty():
			named_definition_id = _catalog.resolve_legacy_name(display_name)
		if not named_definition_id.is_empty():
			_diagnostic(
				"%s: resolved the legacy exact-name fallback %s"
				% [context, display_name]
			)
			return named_definition_id
	if not explicit_id.is_empty():
		_diagnostic(
			"%s.definitionId: %s was unavailable; recovering an embedded definition"
			% [context, explicit_id]
		)
	return ""


func _embedded_definition_from_legacy(
	value: Dictionary,
	context: String,
) -> Dictionary:
	var name := str(value.get("name", "")).strip_edges()
	var item_type := str(value.get("type", "")).strip_edges()
	if name.is_empty():
		_error("%s.name" % context, "is required for an embedded legacy item")
	if item_type.is_empty():
		_error("%s.type" % context, "is required for an embedded legacy item")
	if not last_errors.is_empty() and _errors_for_context(context):
		return {"ok": false}
	var extra_data: Dictionary = value.get("extra_data", {}).duplicate(true) \
		if value.get("extra_data", {}) is Dictionary else {}
	if not _is_json_compatible(extra_data):
		_diagnostic(
			"%s.extra_data: discarded non-JSON-compatible legacy data" % context
		)
		extra_data = {}
	var retained_unknown := {}
	for field_name_value: Variant in value:
		var field_name := str(field_name_value)
		if field_name in LEGACY_DEFINITION_FIELDS \
				or field_name in RUNTIME_ONLY_FIELDS:
			continue
		var field_value: Variant = value[field_name_value]
		if _is_json_compatible(field_value):
			retained_unknown[field_name] = field_value.duplicate(true) \
				if field_value is Dictionary or field_value is Array else field_value
			_diagnostic(
				"%s.%s: retained unknown legacy definition data"
				% [context, field_name]
			)
		else:
			_diagnostic(
				"%s.%s: discarded runtime-only or non-portable data"
				% [context, field_name]
			)
	if not retained_unknown.is_empty():
		var legacy_fields: Dictionary = extra_data.get(
			"legacyDefinitionFields",
			{},
		).duplicate(true)
		legacy_fields.merge(retained_unknown, true)
		extra_data["legacyDefinitionFields"] = legacy_fields

	var stats: Dictionary = value.get("stats", {}).duplicate(true) \
		if value.get("stats", {}) is Dictionary else {}
	if value.has("classicMagicResistance"):
		extra_data["classicMagicResistance"] = int(
			value["classicMagicResistance"]
		)
		stats.erase("ClassicMagicResistance")
	elif stats.has("ClassicMagicResistance"):
		extra_data["classicMagicResistance"] = int(
			stats["ClassicMagicResistance"]
		)
		stats.erase("ClassicMagicResistance")
	for field_name: String in ["classicItemType", "classicIconId", "classicSoundId"]:
		if value.has(field_name):
			extra_data[field_name] = int(value[field_name])

	var maximum_charges := int(value.get("charges_max", 0)) \
		if _is_integer(value.get("charges_max", 0)) else 0
	var weapon_damage: Dictionary = value.get("weapon_dmg", {}).duplicate(true) \
		if value.get("weapon_dmg", {}) is Dictionary else {}
	var hooks := {
		"sources": _legacy_hook_sources(value),
		"spellUses": _legacy_spell_uses(value),
		"traits": value.get("traits", []).duplicate(true) \
			if value.get("traits", []) is Array else [],
		"meleeInflictedTraits": value.get(
			"melee_inflicted_traits",
			[],
		).duplicate(true) if value.get(
			"melee_inflicted_traits",
			[],
		) is Array else [],
	}
	var classic_ids := _legacy_classic_ids(value)
	var definition := {
		"catalogKey": str(value.get("KEY", name)),
		"source": {
			"scope": "embedded",
			"campaignId": "",
			"path": "",
		},
		"name": name,
		"unidentifiedName": str(value.get("unidentified_name", name)),
		"description": str(value.get("description", "")),
		"type": item_type,
		"imageKey": str(value.get("img_ptr", "embedded")),
		"soundKey": str(value.get("sound", "")),
		"defaultIdentified": bool(value.get(
			"is_identified",
			not value.has("unidentified_name"),
		)),
		"gameplay": {
			"magical": int(value.get("is_magical", 0)),
			"hands": int(value.get("hands", 0)),
			"unique": int(value.get("unique", value.get("is_unique", 0))),
			"deleteOnEmpty": int(value.get("delete_on_empty", 0)),
			"slots": value.get("slots", []).duplicate(true) \
				if value.get("slots", []) is Array else [],
			"equippable": int(value.get("equippable", 0)),
			"dropsOnDefeat": bool(value.get("drops_on_defeat", false)),
			"onlyUsableByClasses": value.get(
				"only_usable_by_classes",
				[],
			).duplicate(true) if value.get(
				"only_usable_by_classes",
				[],
			) is Array else [],
			"notUsableByClasses": value.get(
				"not_usable_by_classes",
				[],
			).duplicate(true) if value.get(
				"not_usable_by_classes",
				[],
			) is Array else [],
			"onlyUsableByRaces": value.get(
				"only_usable_by_races",
				[],
			).duplicate(true) if value.get(
				"only_usable_by_races",
				[],
			) is Array else [],
			"notUsableByRaces": value.get(
				"not_usable_by_races",
				[],
			).duplicate(true) if value.get(
				"not_usable_by_races",
				[],
			) is Array else [],
			"stats": stats,
			"statsSummary": str(value.get("stats_mini", "")),
			"initialCharges": maximum_charges if value.has("charges_max") else 0,
			"maxCharges": maximum_charges,
			"tradeable": int(value.get("tradeable", 1)),
			"baseWeight": int(value.get("weight", 0)),
			"price": int(value.get("price", 0)),
			"weightPerCharge": int(value.get("charges_weight", 0)),
			"splittable": int(value.get("splittable", 0)),
			"ammoType": str(value.get("ammo_type", "cantuse")),
			"weaponDamage": weapon_damage,
			"meleeAnimation": str(value.get(
				"melee_atk_anim_icon",
				"ATK_HTH" if not weapon_damage.is_empty() else "",
			)),
			"taggedWeaponDamage": value.get(
				"weapon_tag_bonus_dmg",
				{},
			).duplicate(true) if value.get(
				"weapon_tag_bonus_dmg",
				{},
			) is Dictionary else {},
			"extraData": extra_data,
		},
		"hooks": hooks,
		"classic": {
			"itemIds": classic_ids,
			"itemCategory": value.get("classicItemCategory"),
			"recordId": value.get("classicRecordId"),
			"record": value.get("classicRecord", {}).duplicate(true) \
				if value.get("classicRecord", {}) is Dictionary else {},
			"materialization": value.get(
				"classicMaterialization",
				{},
			).duplicate(true) if value.get(
				"classicMaterialization",
				{},
			) is Dictionary else {},
		},
	}
	if value.get("imgdata") is String \
			and _is_integer(value.get("imgdatasize")) \
			and int(value.get("imgdatasize", 0)) >= 0:
		definition["media"] = {
			"encoding": "gzip+base64-png",
			"data": str(value["imgdata"]),
			"bytes": int(value["imgdatasize"]),
		}
	if not _is_json_compatible(definition):
		_error(
			"%s.embeddedDefinition" % context,
			"could not normalize non-JSON-compatible legacy data",
		)
		return {"ok": false}
	var canonical_json := JSON.stringify(definition, "", true)
	var hashing_context := HashingContext.new()
	if hashing_context.start(HashingContext.HASH_SHA256) != OK \
			or hashing_context.update(canonical_json.to_utf8_buffer()) != OK:
		_error("%s.embeddedDefinition" % context, "could not compute SHA-256 identity")
		return {"ok": false}
	var digest: String = hashing_context.finish().hex_encode()
	definition["digest"] = digest
	definition["definitionId"] = "embedded:sha256:%s" % digest
	_diagnostic(
		"%s: recovered self-contained item definition %s"
		% [context, definition["definitionId"]]
	)
	return {"ok": true, "definition": definition}


func _validate_embedded_definition(
	definition: Dictionary,
	expected_definition_id: String,
	context: String,
) -> bool:
	if not _is_json_compatible(definition):
		_error(context, "must contain only JSON-compatible string-keyed data")
		return false
	for field_name_value: Variant in definition:
		if str(field_name_value) not in EMBEDDED_ROOT_FIELDS:
			_error(
				"%s.%s" % [context, field_name_value],
				"is not a supported embedded-definition field",
			)
	for field_name: String in [
		"definitionId",
		"digest",
		"catalogKey",
		"name",
		"unidentifiedName",
		"description",
		"type",
		"imageKey",
		"soundKey",
		"source",
		"defaultIdentified",
		"gameplay",
		"hooks",
		"classic",
	]:
		if not definition.has(field_name):
			_error("%s.%s" % [context, field_name], "is required")
	var definition_id := str(definition.get("definitionId", ""))
	var digest := str(definition.get("digest", ""))
	if definition_id != expected_definition_id:
		_error(
			"%s.definitionId" % context,
			"must match the serialized item definitionId",
		)
	if definition_id != "embedded:sha256:%s" % digest \
			or digest.length() != 64 \
			or not digest.is_valid_hex_number(false):
		_error(
			"%s.definitionId" % context,
			"must match embedded:sha256:<digest>",
		)
	var payload := definition.duplicate(true)
	payload.erase("definitionId")
	payload.erase("digest")
	var canonical_json := JSON.stringify(payload, "", true)
	var hashing_context := HashingContext.new()
	if hashing_context.start(HashingContext.HASH_SHA256) != OK \
			or hashing_context.update(canonical_json.to_utf8_buffer()) != OK:
		_error(context, "could not recompute the embedded SHA-256 digest")
		return false
	var calculated_digest: String = hashing_context.finish().hex_encode()
	if calculated_digest != digest:
		_error(
			"%s.digest" % context,
			"does not match the canonical embedded definition payload",
		)
	var source_value: Variant = definition.get("source")
	if not (source_value is Dictionary) \
			or str(source_value.get("scope", "")) != "embedded":
		_error("%s.source.scope" % context, "must be embedded")
	for field_name: String in ["gameplay", "hooks", "classic"]:
		if not (definition.get(field_name) is Dictionary):
			_error("%s.%s" % [context, field_name], "must be an object")
	if not (definition.get("defaultIdentified") is bool):
		_error("%s.defaultIdentified" % context, "must be a boolean")
	var media_value: Variant = definition.get("media")
	if media_value != null and (
		not (media_value is Dictionary)
		or media_value.get("encoding") != "gzip+base64-png"
		or not (media_value.get("data") is String)
		or not _is_integer(media_value.get("bytes"))
	):
		_error(
			"%s.media" % context,
			"must be gzip+base64-png data with an integer byte count",
		)
	return not _errors_for_context(context)


func _legacy_template_from_definition(definition: Dictionary) -> Dictionary:
	var gameplay: Dictionary = definition.get("gameplay", {})
	var hooks: Dictionary = definition.get("hooks", {})
	var classic: Dictionary = definition.get("classic", {})
	var template := {
		"name": str(definition.get("name", "")),
		"unidentified_name": str(definition.get(
			"unidentifiedName",
			definition.get("name", ""),
		)),
		"description": str(definition.get("description", "")),
		"type": str(definition.get("type", "")),
		"img_ptr": str(definition.get("imageKey", "embedded")),
		"sound": str(definition.get("soundKey", "")),
		"is_magical": int(gameplay.get("magical", 0)),
		"hands": int(gameplay.get("hands", 0)),
		"unique": int(gameplay.get("unique", 0)),
		"delete_on_empty": int(gameplay.get("deleteOnEmpty", 0)),
		"slots": gameplay.get("slots", []).duplicate(true),
		"equippable": int(gameplay.get("equippable", 0)),
		"drops_on_defeat": bool(gameplay.get("dropsOnDefeat", false)),
		"only_usable_by_classes": gameplay.get(
			"onlyUsableByClasses",
			[],
		).duplicate(true),
		"not_usable_by_classes": gameplay.get(
			"notUsableByClasses",
			[],
		).duplicate(true),
		"only_usable_by_races": gameplay.get(
			"onlyUsableByRaces",
			[],
		).duplicate(true),
		"not_usable_by_races": gameplay.get(
			"notUsableByRaces",
			[],
		).duplicate(true),
		"stats": gameplay.get("stats", {}).duplicate(true),
		"stats_mini": str(gameplay.get("statsSummary", "")),
		"charges": int(gameplay.get("initialCharges", 0)),
		"charges_max": int(gameplay.get("maxCharges", 0)),
		"is_identified": 1 if bool(definition.get("defaultIdentified", true)) else 0,
		"tradeable": int(gameplay.get("tradeable", 1)),
		"weight": int(gameplay.get("baseWeight", 0)),
		"price": int(gameplay.get("price", 0)),
		"charges_weight": int(gameplay.get("weightPerCharge", 0)),
		"splittable": int(gameplay.get("splittable", 0)),
		"ammo_type": str(gameplay.get("ammoType", "cantuse")),
		"weapon_dmg": gameplay.get("weaponDamage", {}).duplicate(true),
		"melee_atk_anim_icon": str(gameplay.get("meleeAnimation", "")),
		"weapon_tag_bonus_dmg": gameplay.get(
			"taggedWeaponDamage",
			{},
		).duplicate(true),
		"extra_data": gameplay.get("extraData", {}).duplicate(true),
		"traits": hooks.get("traits", []).duplicate(true),
		"melee_inflicted_traits": hooks.get(
			"meleeInflictedTraits",
			[],
		).duplicate(true),
	}
	var source_hooks: Dictionary = hooks.get("sources", {})
	for field_name_value: Variant in source_hooks:
		template[str(field_name_value)] = source_hooks[field_name_value]
	var spell_uses: Dictionary = hooks.get("spellUses", {})
	for field_name_value: Variant in spell_uses:
		template[str(field_name_value)] = spell_uses[field_name_value].duplicate(true) \
			if spell_uses[field_name_value] is Array \
				or spell_uses[field_name_value] is Dictionary \
			else spell_uses[field_name_value]
	var classic_ids_value: Variant = classic.get("itemIds", [])
	if classic_ids_value is Array and not classic_ids_value.is_empty():
		template["classicItemId"] = int(classic_ids_value[0])
		if classic_ids_value.size() > 1:
			template["classicItemIds"] = classic_ids_value.duplicate()
	for pair: Array in [
		["itemCategory", "classicItemCategory"],
		["recordId", "classicRecordId"],
		["record", "classicRecord"],
		["materialization", "classicMaterialization"],
	]:
		if classic.get(pair[0]) != null:
			template[pair[1]] = classic[pair[0]].duplicate(true) \
				if classic[pair[0]] is Dictionary or classic[pair[0]] is Array \
				else classic[pair[0]]
	var media_value: Variant = definition.get("media")
	if media_value is Dictionary:
		template["imgdata"] = str(media_value.get("data", ""))
		template["imgdatasize"] = int(media_value.get("bytes", 0))
	return template


func _legacy_hook_sources(value: Dictionary) -> Dictionary:
	var result := {}
	for canonical_name: String in HOOK_SOURCE_ALIASES:
		for alias_value: Variant in HOOK_SOURCE_ALIASES[canonical_name]:
			var alias := str(alias_value)
			if value.has(alias) and value[alias] is String:
				result[canonical_name] = value[alias]
				break
	for collection_name: String in ["traits", "melee_inflicted_traits"]:
		var descriptors_value: Variant = value.get(collection_name, [])
		if not (descriptors_value is Array):
			continue
		for descriptor_value: Variant in descriptors_value:
			if not (descriptor_value is Array) or descriptor_value.is_empty():
				continue
			var trait_name := str(descriptor_value[0])
			var source_field := "%s_source" % trait_name
			if value.get(source_field) is String:
				result[source_field] = value[source_field]
	return result


func _legacy_spell_uses(value: Dictionary) -> Dictionary:
	var result := {}
	for field_name: String in ["_on_field_use_spell", "_on_combat_use_spell"]:
		if value.has(field_name) and _is_json_compatible(value[field_name]):
			result[field_name] = value[field_name].duplicate(true) \
				if value[field_name] is Array or value[field_name] is Dictionary \
				else value[field_name]
	return result


func _legacy_classic_ids(value: Dictionary) -> Array[int]:
	var result: Array[int] = []
	if value.has("classicItemId") and _is_integer(value["classicItemId"]):
		var primary_id: int = abs(int(value["classicItemId"]))
		if primary_id > 0:
			result.append(primary_id)
	var aliases_value: Variant = value.get("classicItemIds", [])
	if aliases_value is Array:
		for alias_value: Variant in aliases_value:
			if not _is_integer(alias_value):
				continue
			var alias_id: int = abs(int(alias_value))
			if alias_id > 0 and not result.has(alias_id):
				result.append(alias_id)
	return result


func _errors_for_context(context: String) -> bool:
	for message: String in last_errors:
		if message.begins_with(context):
			return true
	return false


func _result(ok: bool, additions: Dictionary = {}) -> Dictionary:
	var result := {
		"ok": ok,
		"errors": last_errors.duplicate(),
		"diagnostics": last_diagnostics.duplicate(),
	}
	result.merge(additions, true)
	return result


func _error(context: String, message: String) -> void:
	last_errors.append("%s: %s" % [context, message])


func _diagnostic(message: String) -> void:
	last_diagnostics.append(message)


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


static func _new_instance_id() -> String:
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
