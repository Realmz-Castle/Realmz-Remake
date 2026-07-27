class_name ClassicItemBehaviors
extends RefCounted

const TORCH_ITEM_ID := 805
const SHINE_SPELL_ID := 1110
const DEFAULT_TORCH_POWER := 4
const TORCH_SOUND := "spell launch 2.wav"
const TORCH_SPECIAL_FIELDS := ["special1", "special2"]


static func enrich_item_book(item_book: Dictionary) -> Dictionary:
	var result := item_book.duplicate()
	for item_key: Variant in result:
		var item_value: Variant = result[item_key]
		if item_value is Dictionary:
			result[item_key] = enrich_definition_source(item_value)
	return result


static func enrich_definition_source(source: Dictionary) -> Dictionary:
	var power := classic_torch_power(source)
	if power <= 0:
		return source
	var result := source.duplicate(true)
	var hook_source := torch_field_use_source(power)
	if result.has("_on_field_use_source") \
			and str(result["_on_field_use_source"]) != hook_source:
		return result
	result["_on_field_use_source"] = hook_source
	_update_materialization(result)
	return result


static func classic_torch_power(source: Dictionary) -> int:
	if not _has_classic_item_id(source, TORCH_ITEM_ID):
		return 0
	var record: Variant = source.get("classicRecord", {})
	if record is Dictionary and not record.is_empty():
		return torch_record_power(record)
	return DEFAULT_TORCH_POWER


static func torch_record_power(record: Dictionary) -> int:
	if abs(int(record.get("itemId", 0))) != TORCH_ITEM_ID:
		return 0
	if abs(int(record.get("special2", 0))) != SHINE_SPELL_ID:
		return 0
	return abs(int(record.get("special1", 0)))


static func handles_special_field(record: Dictionary, field_name: String) -> bool:
	return torch_record_power(record) > 0 and TORCH_SPECIAL_FIELDS.has(field_name)


static func find_party_torch(
	characters: Array,
	resources: Object
) -> Dictionary:
	if resources == null \
			or not resources.has_method("item_classic_ids"):
		return {}
	for character_value: Variant in characters:
		if not (character_value is Object) \
				or not character_value.has_method("inventory_instances"):
			continue
		for item_value: Variant in character_value.call("inventory_instances"):
			if not (item_value is ItemInstance) \
					or int(item_value.get("charges")) <= 0:
				continue
			var classic_ids: Variant = resources.call(
				"item_classic_ids",
				item_value
			)
			if classic_ids is Array and classic_ids.has(TORCH_ITEM_ID):
				return {
					"holder": character_value,
					"item": item_value,
				}
	return {}


static func activate_party_torch(
	characters: Array,
	resources: Object
) -> Dictionary:
	var selection := find_party_torch(characters, resources)
	if selection.is_empty():
		return _activation_failure("no-torch", "The party has no usable Torch")
	var holder: Object = selection["holder"]
	var torch: ItemInstance = selection["item"]
	if holder.has_method("can_use_inventory_item") \
			and not bool(holder.call("can_use_inventory_item", torch)):
		return _activation_failure(
			"not-permitted",
			"The Torch holder cannot use this item"
		)
	if not resources.has_method("item_has_hook") \
			or not bool(resources.call("item_has_hook", torch, "field_use")):
		return _activation_failure(
			"missing-behavior",
			"The Torch has no field-use behavior"
		)
	var hook_result: Dictionary = resources.call(
		"run_item_hook",
		torch,
		"field_use",
		[holder]
	)
	if not bool(hook_result.get("ok", false)) \
			or not bool(hook_result.get("value", false)):
		var errors: Array = hook_result.get("errors", [])
		return {
			"ok": false,
			"reason": "use-failed",
			"message": (
				str(errors[0])
				if not errors.is_empty()
				else "The Torch could not be used"
			),
			"errors": errors.duplicate(),
		}
	var removed := false
	var definition: ItemDefinition = resources.call(
		"get_item_definition",
		torch
	)
	if definition != null and definition.delete_on_empty \
			and torch.charges <= 0 \
			and holder.has_method("remove_inventory_item"):
		removed = bool(holder.call("remove_inventory_item", torch))
	return {
		"ok": true,
		"reason": "activated",
		"holder": holder,
		"item": torch,
		"remainingCharges": torch.charges,
		"removed": removed,
		"errors": [],
	}


static func torch_field_use_source(power: int) -> String:
	return (
		"if int(item.get(\"charges\", 0)) <= 0:\n"
		+ "\treturn false\n"
		+ "item[\"charges\"] = int(item[\"charges\"]) - 1\n"
		+ "GameGlobal.add_classic_light_effect(%d)\n" % max(1, power)
		+ "GameGlobal.play_sfx(\"%s\")\n" % TORCH_SOUND
		+ "return true"
	)


static func _has_classic_item_id(source: Dictionary, item_id: int) -> bool:
	if abs(int(source.get("classicItemId", 0))) == item_id:
		return true
	var aliases: Variant = source.get("classicItemIds", [])
	if aliases is Array:
		for alias_value: Variant in aliases:
			if abs(int(alias_value)) == item_id:
				return true
	return false


static func _activation_failure(reason: String, message: String) -> Dictionary:
	return {
		"ok": false,
		"reason": reason,
		"message": message,
		"errors": [],
	}


static func _update_materialization(source: Dictionary) -> void:
	var materialization_value: Variant = source.get("classicMaterialization", {})
	if not (materialization_value is Dictionary) or materialization_value.is_empty():
		return
	var materialization: Dictionary = materialization_value.duplicate(true)
	var unsupported_value: Variant = materialization.get("unsupportedFields", [])
	var unsupported: Array = unsupported_value.duplicate() if unsupported_value is Array else []
	for field_name: String in TORCH_SPECIAL_FIELDS:
		unsupported.erase(field_name)
	materialization["unsupportedFields"] = unsupported
	if unsupported.is_empty():
		var fallbacks: Variant = materialization.get("fidelityFallbacks", [])
		materialization["status"] = (
			"fallback"
			if fallbacks is Array and not fallbacks.is_empty()
			else "complete"
		)
	source["classicMaterialization"] = materialization
