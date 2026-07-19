extends RefCounted


static func party_has_named_item(party: Array, item_names: Array) -> bool:
	var names := _normalized_names(item_names)
	for character_value: Variant in party:
		if not (character_value is Object):
			continue
		var inventory: Variant = character_value.get("inventory")
		if not (inventory is Array):
			continue
		for item_value: Variant in inventory:
			if item_value is Dictionary and _item_matches(item_value, names):
				return true
	return false


static func alter_named_items(
	party: Array,
	item_names: Array,
	max_matches: int,
	operation: int,
	charge_delta: int,
	replacement_item: Dictionary = {}
) -> Dictionary:
	if max_matches < 0:
		return _error("Classic item mutation count cannot be negative")
	if not [1, 2, 3].has(operation):
		return _error("Classic item mutation operation %d is invalid" % operation)
	if operation == 3 and replacement_item.is_empty():
		return _error("Classic replacement item is unavailable")
	var names := _normalized_names(item_names)
	if names.is_empty():
		return _error("Classic item mutation has no item names")

	var changed := 0
	var reequip_failures := 0
	for character_value: Variant in party:
		if changed >= max_matches:
			break
		if not (character_value is Object):
			return _error("Classic item mutation target is not a character")
		var inventory_value: Variant = character_value.get("inventory")
		if not (inventory_value is Array):
			return _error("Classic item mutation target has no inventory")
		var inventory: Array = inventory_value
		var item_index := 0
		while item_index < inventory.size() and changed < max_matches:
			var item_value: Variant = inventory[item_index]
			if not (item_value is Dictionary) or not _item_matches(item_value, names):
				item_index += 1
				continue
			var item: Dictionary = item_value
			var was_equipped := int(item.get("equipped", 0)) == 1
			if operation != 2 and was_equipped and not _unequip_item(character_value, item):
				return _error("Classic item mutation could not unequip '%s'" % item.get("name", "item"))
			match operation:
				1:
					inventory.remove_at(item_index)
				2:
					item["charges"] = int(item.get("charges", 0)) + charge_delta
					item_index += 1
				3:
					var replacement := replacement_item.duplicate(true)
					replacement["equipped"] = 0
					replacement["is_identified"] = 0
					inventory[item_index] = replacement
					if was_equipped and not _equip_item(character_value, replacement):
						reequip_failures += 1
					item_index += 1
			changed += 1
	return {
		"changed": changed,
		"reequipFailures": reequip_failures,
	}


static func capture_party_equipment(party: Array, pooled_money: Array) -> Dictionary:
	var validation := _validate_party_storage(party, pooled_money)
	if not validation.is_empty():
		return validation
	var stored_inventories: Array = []
	var stored_wealth := [int(pooled_money[0]), int(pooled_money[1]), int(pooled_money[2])]
	var item_count := 0
	for character_value: Variant in party:
		var inventory: Array = character_value.get("inventory")
		var money: Array = character_value.get("money")
		stored_inventories.append(inventory.duplicate(true))
		item_count += inventory.size()
		for currency: int in 3:
			stored_wealth[currency] += int(money[currency])
		for item_value: Variant in inventory:
			if item_value is Dictionary and int(item_value.get("equipped", 0)) == 1:
				if not _unequip_item(character_value, item_value):
					return _error("Classic equipment capture could not unequip an item")
		inventory.clear()
		for currency: int in 3:
			money[currency] = 0
	for currency: int in 3:
		pooled_money[currency] = 0
	return {
		"active": true,
		"inventories": stored_inventories,
		"wealth": stored_wealth,
		"itemCount": item_count,
	}


static func restore_party_equipment(
	party: Array,
	pooled_money: Array,
	stored_equipment: Dictionary
) -> Dictionary:
	if not bool(stored_equipment.get("active", false)):
		return {"restored": false, "extraItems": []}
	var validation := _validate_party_storage(party, pooled_money)
	if not validation.is_empty():
		return validation
	var stored_inventories: Variant = stored_equipment.get("inventories", [])
	var stored_wealth: Variant = stored_equipment.get("wealth", [])
	if not (stored_inventories is Array) or stored_inventories.size() != party.size():
		return _error("Classic equipment storage does not match the current party")
	if not (stored_wealth is Array) or stored_wealth.size() < 3:
		return _error("Classic equipment storage has invalid wealth")

	# Classic shares captured wealth before it replaces items acquired in the interim.
	for currency: int in 3:
		pooled_money[currency] += int(stored_wealth[currency])
	_share_pooled_money(party, pooled_money)
	var extra_items: Array = []
	var restored_count := 0
	var reequip_failures := 0
	for character_index: int in party.size():
		var character: Object = party[character_index]
		var inventory: Array = character.get("inventory")
		for item_value: Variant in inventory:
			if not (item_value is Dictionary):
				continue
			if int(item_value.get("equipped", 0)) == 1 and not _unequip_item(character, item_value):
				return _error("Classic equipment restore could not unequip an interim item")
			extra_items.append(item_value.duplicate(true))
		inventory.clear()
		var saved_inventory: Variant = stored_inventories[character_index]
		if not (saved_inventory is Array):
			return _error("Classic equipment storage contains an invalid inventory")
		for stored_item_value: Variant in saved_inventory:
			if not (stored_item_value is Dictionary):
				continue
			var restored_item: Dictionary = stored_item_value.duplicate(true)
			var was_equipped := int(restored_item.get("equipped", 0)) == 1
			restored_item["equipped"] = 0
			inventory.append(restored_item)
			if was_equipped and not _equip_item(character, restored_item):
				reequip_failures += 1
			restored_count += 1
	return {
		"restored": true,
		"restoredCount": restored_count,
		"extraItems": extra_items,
		"reequipFailures": reequip_failures,
	}


static func _share_pooled_money(party: Array, pooled_money: Array) -> void:
	# Classic shares jewels, gems, then coins in party order until carrying limits stop it.
	for currency: int in [2, 1, 0]:
		var unit_weight := 15 if currency == 2 else 1
		while int(pooled_money[currency]) > 0:
			var eligible: Array = []
			var minimum_capacity := 2147483647
			for character_value: Variant in party:
				var carried_weight := _classic_carried_weight(character_value)
				var weight_limit := int(character_value.get_stat("Weight_Limit"))
				var capacity := ceili(
					float(weight_limit - carried_weight) / float(unit_weight)
				)
				if capacity < 1:
					continue
				eligible.append(character_value)
				minimum_capacity = min(minimum_capacity, capacity)
			if eligible.is_empty():
				break
			if int(pooled_money[currency]) < eligible.size():
				for character_value: Variant in eligible:
					if int(pooled_money[currency]) == 0:
						break
					var money: Array = character_value.get("money")
					money[currency] += 1
					pooled_money[currency] -= 1
				continue
			var rounds: int = min(
				floori(float(pooled_money[currency]) / float(eligible.size())),
				minimum_capacity
			)
			for character_value: Variant in eligible:
				var money: Array = character_value.get("money")
				money[currency] += rounds
			pooled_money[currency] -= rounds * eligible.size()


static func _classic_carried_weight(character: Object) -> int:
	var carried_weight := 0
	var inventory: Array = character.get("inventory")
	for item_value: Variant in inventory:
		if item_value is Dictionary:
			carried_weight += int(item_value.get("weight", 0))
			carried_weight += int(item_value.get("charges_weight", 0)) \
				* int(item_value.get("charges", 0))
	var money: Array = character.get("money")
	return carried_weight + int(money[0]) + int(money[1]) + 15 * int(money[2])


static func _validate_party_storage(party: Array, pooled_money: Array) -> Dictionary:
	if pooled_money.size() < 3:
		return _error("Classic equipment storage requires three pooled wealth values")
	for character_value: Variant in party:
		if not (character_value is Object):
			return _error("Classic equipment storage target is not a character")
		if not (character_value.get("inventory") is Array):
			return _error("Classic equipment storage target has no inventory")
		var money: Variant = character_value.get("money")
		if not (money is Array) or money.size() < 3:
			return _error("Classic equipment storage target has invalid wealth")
		if not character_value.has_method("get_stat"):
			return _error("Classic equipment storage target has no carrying limit")
	return {}


static func _unequip_item(character: Object, item: Dictionary) -> bool:
	if int(item.get("equipped", 0)) != 1:
		return true
	if character.has_method("unequip_item"):
		return bool(character.unequip_item(item, false))
	item["equipped"] = 0
	return true


static func _equip_item(character: Object, item: Dictionary) -> bool:
	if character.has_method("equip_item"):
		return bool(character.equip_item(item))
	item["equipped"] = 1
	return true


static func _item_matches(item: Dictionary, normalized_names: Dictionary) -> bool:
	return normalized_names.has(str(item.get("name", "")).strip_edges().to_lower())


static func _normalized_names(item_names: Array) -> Dictionary:
	var normalized: Dictionary = {}
	for item_name_value: Variant in item_names:
		var item_name := str(item_name_value).strip_edges().to_lower()
		if not item_name.is_empty():
			normalized[item_name] = true
	return normalized


static func _error(message: String) -> Dictionary:
	return {"status": "error", "message": message}
