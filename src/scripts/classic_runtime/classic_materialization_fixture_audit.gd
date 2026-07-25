class_name ClassicMaterializationFixtureAudit
extends RefCounted

const CAPABILITY_SHOP_ITEM := "scenarioLocalShopItem"
const CAPABILITY_EQUIPPED_ITEM := "carriedEquippedItem"
const CAPABILITY_BATTLE_MONSTER := "battleMonster"
const CAPABILITY_ALLY := "ally"
const REQUIRED_CAPABILITIES := [
	CAPABILITY_SHOP_ITEM,
	CAPABILITY_EQUIPPED_ITEM,
	CAPABILITY_BATTLE_MONSTER,
	CAPABILITY_ALLY,
]


static func inspect(documents: Dictionary) -> Dictionary:
	var content: Dictionary = documents.get("content", {})
	var encounters: Dictionary = documents.get("encounters", {})
	var scenario_items := _records_by_id(content.get("scenarioItems", []), "itemId")
	var monster_ids := _records_by_id(content.get("monsters", []), "id")
	var shop_item := _find_shop_item(encounters, scenario_items)
	var equipped_item := _find_equipped_item(content, scenario_items)
	var battle_monster := _find_battle_monster(encounters, monster_ids)
	var ally := _find_ally(documents, monster_ids)
	var capabilities := {
		CAPABILITY_SHOP_ITEM: _capability(shop_item),
		CAPABILITY_EQUIPPED_ITEM: _capability(equipped_item),
		CAPABILITY_BATTLE_MONSTER: _capability(battle_monster),
		CAPABILITY_ALLY: _capability(ally),
	}
	var missing: Array[String] = []
	for capability_name: String in REQUIRED_CAPABILITIES:
		if not bool(capabilities[capability_name].get("covered", false)):
			missing.append(capability_name)
	return {
		"accepted": missing.is_empty(),
		"capabilities": capabilities,
		"missingCapabilities": missing,
	}


static func _records_by_id(records_value: Variant, field_name: String) -> Dictionary:
	var result := {}
	if not (records_value is Array):
		return result
	for record_value: Variant in records_value:
		if not (record_value is Dictionary):
			continue
		var record_id := int(record_value.get(field_name, 0))
		if record_id > 0:
			result[record_id] = record_value
	return result


static func _find_shop_item(encounters: Dictionary, items_by_id: Dictionary) -> Dictionary:
	for shop_value: Variant in encounters.get("shops", []):
		if not (shop_value is Dictionary):
			continue
		for item_value: Variant in shop_value.get("itemIds", []):
			var item_id := int(item_value)
			if items_by_id.has(item_id):
				return {"shopId": int(shop_value.get("id", -1)), "itemId": item_id}
	return {}


static func _find_equipped_item(content: Dictionary, items_by_id: Dictionary) -> Dictionary:
	for monster_value: Variant in content.get("monsters", []):
		if not (monster_value is Dictionary):
			continue
		var weapon_id := int(monster_value.get("weapon", 0))
		if weapon_id <= 0 or not items_by_id.has(weapon_id):
			continue
		var item_record: Dictionary = items_by_id[weapon_id]
		# Only a scenario-local melee record exercises the monster's native
		# carried-and-equipped weapon path.
		if abs(int(item_record.get("type", 0))) != 2:
			continue
		for item_value: Variant in monster_value.get("items", []):
			if int(item_value) == weapon_id:
				return {
					"monsterId": int(monster_value.get("id", 0)),
					"itemId": weapon_id,
				}
	return {}


static func _find_battle_monster(encounters: Dictionary, monster_ids: Dictionary) -> Dictionary:
	for battle_value: Variant in encounters.get("battles", []):
		if not (battle_value is Dictionary):
			continue
		if not _producer_marks_callable(battle_value):
			continue
		for monster_value: Variant in battle_value.get("grid", []):
			var monster_id: int = abs(int(monster_value))
			if monster_ids.has(monster_id):
				return {
					"battleId": int(battle_value.get("id", -1)),
					"monsterId": monster_id,
				}
	return {}


static func _find_ally(documents: Dictionary, monster_ids: Dictionary) -> Dictionary:
	var scripts: Dictionary = documents.get("scripts", {})
	for trigger_value: Variant in scripts.get("triggers", []):
		if not (trigger_value is Dictionary):
			continue
		if not bool(trigger_value.get("active", true)):
			continue
		if trigger_value.has("callable") and not bool(trigger_value.get("callable")):
			continue
		var trigger_match := _find_ally_action(
			trigger_value.get("actions", []),
			monster_ids
		)
		if not trigger_match.is_empty():
			trigger_match["triggerId"] = str(trigger_value.get("id", ""))
			return trigger_match

	var encounters: Dictionary = documents.get("encounters", {})
	for collection_name: String in [
		"simpleEncounters",
		"complexEncounters",
		"thiefEncounters",
		"timedEncounters",
	]:
		for encounter_value: Variant in encounters.get(collection_name, []):
			if encounter_value is Dictionary and not _producer_marks_callable(
				encounter_value
			):
				continue
			var encounter_match := _find_ally_action(encounter_value, monster_ids)
			if not encounter_match.is_empty():
				encounter_match["encounterCollection"] = collection_name
				return encounter_match
	return {}


static func _producer_marks_callable(record: Dictionary) -> bool:
	if record.has("callable"):
		return bool(record["callable"])
	return true


static func _find_ally_action(value: Variant, monster_ids: Dictionary) -> Dictionary:
	if value is Array:
		for child: Variant in value:
			var child_match := _find_ally_action(child, monster_ids)
			if not child_match.is_empty():
				return child_match
		return {}
	if not (value is Dictionary):
		return {}
	if value.has("slot") and (value.has("code") or value.has("rawCode")):
		var code: int = abs(int(value.get("code", value.get("rawCode", 0))))
		var monster_id := int(value.get("id", 0))
		if code == 89 and monster_ids.has(monster_id):
			return {"monsterId": monster_id, "slot": int(value.get("slot", -1))}
	for child: Variant in value.values():
		var child_match := _find_ally_action(child, monster_ids)
		if not child_match.is_empty():
			return child_match
	return {}


static func _capability(details: Dictionary) -> Dictionary:
	return {
		"covered": not details.is_empty(),
		"details": details,
	}
