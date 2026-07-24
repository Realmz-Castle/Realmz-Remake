extends RefCounted


static func take_party_currency(
	party: Array,
	pooled_money: Array,
	currency: int,
	amount: int
) -> Dictionary:
	if not [0, 1].has(currency):
		return _error("Classic payment currency %d is invalid" % currency)
	if amount < 0:
		return _error("Classic payment amount cannot be negative")
	var validation := _validate_party_wealth(party, pooled_money)
	if not validation.is_empty():
		return validation
	# Check affordability before changing any balance so failure stays atomic.
	var available := int(pooled_money[currency])
	for character_value: Variant in party:
		var money: Array = character_value.get("money")
		available += int(money[currency])
	if available < amount:
		return {
			"paid": false,
			"currency": currency,
			"amount": amount,
			"available": available,
		}

	var remaining := amount
	var pooled_spent: int = min(int(pooled_money[currency]), remaining)
	pooled_money[currency] -= pooled_spent
	remaining -= pooled_spent
	var carried_spent := 0
	var character_index := 0
	# Classic drains carried currency one unit at a time in party order.
	while remaining > 0:
		var character: Object = party[character_index]
		var money: Array = character.get("money")
		if int(money[currency]) > 0:
			money[currency] -= 1
			remaining -= 1
			carried_spent += 1
		character_index = (character_index + 1) % party.size()
	return {
		"paid": true,
		"currency": currency,
		"amount": amount,
		"pooledSpent": pooled_spent,
		"carriedSpent": carried_spent,
	}


static func party_has_named_item(party: Array, item_names: Array) -> bool:
	var names := _normalized_names(item_names)
	for character_value: Variant in party:
		if not (character_value is Object):
			continue
		for item_value: Variant in _character_inventory_items(character_value):
			if _item_matches(character_value, item_value, {}, names):
				return true
	return false


static func party_has_classic_item(party: Array, item_ids: Array) -> bool:
	var normalized_ids := _normalized_ids(item_ids)
	for character_value: Variant in party:
		if not (character_value is Object):
			continue
		for item_value: Variant in _character_inventory_items(character_value):
			if _item_matches(character_value, item_value, normalized_ids, {}):
				return true
	return false


static func alter_named_items(
	party: Array,
	item_names: Array,
	max_matches: int,
	operation: int,
	charge_delta: int,
	replacement_item: Variant = null,
	replacement_factory: Callable = Callable(),
) -> Dictionary:
	return _alter_items(
		party,
		{},
		_normalized_names(item_names),
		max_matches,
		operation,
		charge_delta,
		replacement_item,
		replacement_factory,
	)


static func alter_classic_items(
	party: Array,
	item_ids: Array,
	max_matches: int,
	operation: int,
	charge_delta: int,
	replacement_item: Variant = null,
	replacement_factory: Callable = Callable(),
) -> Dictionary:
	return _alter_items(
		party,
		_normalized_ids(item_ids),
		{},
		max_matches,
		operation,
		charge_delta,
		replacement_item,
		replacement_factory,
	)


static func _alter_items(
	party: Array,
	classic_ids: Dictionary,
	names: Dictionary,
	max_matches: int,
	operation: int,
	charge_delta: int,
	replacement_item: Variant,
	replacement_factory: Callable,
) -> Dictionary:
	if max_matches < 0:
		return _error("Classic item mutation count cannot be negative")
	if not [1, 2, 3].has(operation):
		return _error("Classic item mutation operation %d is invalid" % operation)
	if operation == 3 and replacement_item == null:
		return _error("Classic replacement item is unavailable")
	if names.is_empty() and classic_ids.is_empty():
		return _error("Classic item mutation has no item identity")

	var changed := 0
	var reequip_failures := 0
	for character_value: Variant in party:
		if changed >= max_matches:
			break
		if not (character_value is Object):
			return _error("Classic item mutation target is not a character")
		var inventory := _character_inventory_items(character_value)
		if inventory.is_empty() and not _character_has_inventory(character_value):
			return _error("Classic item mutation target has no inventory")
		for item_value: Variant in inventory:
			if changed >= max_matches:
				break
			if not _item_matches(character_value, item_value, classic_ids, names):
				continue
			var item_index := _character_inventory_items(character_value).find(
				item_value
			)
			var item_name := _item_display_name(character_value, item_value)
			var was_equipped := _item_is_equipped(item_value)
			if operation != 2 and was_equipped \
					and not _unequip_item(character_value, item_value):
				return _error(
					"Classic item mutation could not unequip '%s'" % item_name
				)
			match operation:
				1:
					if character_value.has_method("remove_inventory_item"):
						if not character_value.remove_inventory_item(item_value, true):
							return _error(
								"Classic item mutation could not remove '%s'"
								% item_name
							)
					else:
						var legacy_inventory: Array = character_value.get("inventory")
						legacy_inventory.remove_at(item_index)
				2:
					_set_item_charges(
						item_value,
						_item_charges(item_value) + charge_delta,
					)
					_sync_character_inventory(character_value, item_value)
				3:
					var replacement: Variant = _replacement_copy(
						replacement_item,
						replacement_factory,
					)
					if replacement == null:
						return _error(
							"Classic item mutation could not create its replacement"
						)
					_set_item_equipped(replacement, false)
					_set_item_identified(replacement, false)
					if character_value.has_method("remove_inventory_item") \
							and character_value.has_method("add_inventory_item"):
						if not character_value.remove_inventory_item(item_value, true):
							return _error(
								"Classic item mutation could not remove '%s'"
								% item_name
							)
						if not character_value.add_inventory_item(
							replacement,
							item_index,
							true,
						):
							character_value.add_inventory_item(
								item_value,
								item_index,
								true,
							)
							if was_equipped:
								_equip_item(character_value, item_value)
							return _error(
								"Classic item mutation could not add its replacement"
							)
						replacement = _character_inventory_items(
							character_value
						)[item_index]
					else:
						var legacy_inventory: Array = character_value.get("inventory")
						legacy_inventory[item_index] = replacement
					if was_equipped and not _equip_item(character_value, replacement):
						reequip_failures += 1
			changed += 1
	return {
		"changed": changed,
		"reequipFailures": reequip_failures,
	}


static func remove_equipped_cursed_items(character: Object) -> Dictionary:
	if character == null:
		return _error("Classic curse removal target is unavailable")
	if not _character_has_inventory(character):
		return _error("Classic curse removal target has no inventory")

	var unequipped := 0
	for item_value: Variant in _character_inventory_items(character):
		if not _item_is_equipped(item_value) \
				or not _item_is_cursed(character, item_value):
			continue
		# Passing false is Remake's equivalent of Classic's force flag: it skips
		# an item's normal unequip veto while retaining equipment bookkeeping.
		if not _unequip_item(character, item_value):
			return _error(
				"Classic curse removal could not unequip '%s'"
				% _item_display_name(character, item_value)
			)
		unequipped += 1
	return {"status": "applied", "unequipped": unequipped}


static func capture_party_equipment(party: Array, pooled_money: Array) -> Dictionary:
	var validation := _validate_party_storage(party, pooled_money)
	if not validation.is_empty():
		return validation
	var stored_inventories: Array = []
	var stored_wealth := [int(pooled_money[0]), int(pooled_money[1]), int(pooled_money[2])]
	var item_count := 0
	for character_value: Variant in party:
		var inventory := _character_inventory_items(character_value)
		var money: Array = character_value.get("money")
		var stored_inventory := inventory.duplicate()
		var equipped_states: Array[bool] = []
		for item_value: Variant in inventory:
			equipped_states.append(_item_is_equipped(item_value))
		stored_inventories.append(stored_inventory)
		item_count += inventory.size()
		for currency: int in 3:
			stored_wealth[currency] += int(money[currency])
		for item_value: Variant in inventory:
			if _item_is_equipped(item_value):
				if not _unequip_item(character_value, item_value):
					return _error("Classic equipment capture could not unequip an item")
		if character_value.has_method("clear_inventory_items"):
			character_value.clear_inventory_items()
		else:
			var legacy_inventory: Array = character_value.get("inventory")
			legacy_inventory.clear()
		for item_index: int in stored_inventory.size():
			_set_item_equipped(
				stored_inventory[item_index],
				equipped_states[item_index],
			)
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
		var inventory := _character_inventory_items(character)
		for item_value: Variant in inventory:
			if _item_is_equipped(item_value) and not _unequip_item(
				character,
				item_value,
			):
				return _error("Classic equipment restore could not unequip an interim item")
			extra_items.append(
				item_value if item_value is ItemInstance \
				else item_value.duplicate(true)
			)
		if character.has_method("clear_inventory_items"):
			character.clear_inventory_items()
		else:
			var legacy_inventory: Array = character.get("inventory")
			legacy_inventory.clear()
		var saved_inventory: Variant = stored_inventories[character_index]
		if not (saved_inventory is Array):
			return _error("Classic equipment storage contains an invalid inventory")
		for stored_item_value: Variant in saved_inventory:
			if not (
				stored_item_value is ItemInstance
				or stored_item_value is Dictionary
			):
				continue
			var restored_item: Variant = stored_item_value \
				if stored_item_value is ItemInstance \
				else stored_item_value.duplicate(true)
			var was_equipped := _item_is_equipped(restored_item)
			_set_item_equipped(restored_item, false)
			if character.has_method("add_inventory_item"):
				if not character.add_inventory_item(restored_item, -1, true):
					return _error(
						"Classic equipment restore could not add a stored item"
					)
				if not (restored_item is ItemInstance):
					restored_item = character.inventory.back()
			else:
				var legacy_inventory: Array = character.get("inventory")
				legacy_inventory.append(restored_item)
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
	for item_value: Variant in _character_inventory_items(character):
		if item_value is ItemInstance:
			var definition := _item_definition(character, item_value)
			if definition != null:
				carried_weight += definition.total_weight(item_value)
		elif item_value is Dictionary:
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
		if not _character_has_inventory(character_value):
			return _error("Classic equipment storage target has no inventory")
		var money: Variant = character_value.get("money")
		if not (money is Array) or money.size() < 3:
			return _error("Classic equipment storage target has invalid wealth")
		if not character_value.has_method("get_stat"):
			return _error("Classic equipment storage target has no carrying limit")
	return {}


static func _validate_party_wealth(party: Array, pooled_money: Array) -> Dictionary:
	if pooled_money.size() < 2:
		return _error("Classic payment requires pooled gold and gems")
	if party.is_empty():
		return _error("Classic payment requires at least one party member")
	for character_value: Variant in party:
		if not (character_value is Object):
			return _error("Classic payment target is not a character")
		var money: Variant = character_value.get("money")
		if not (money is Array) or money.size() < 2:
			return _error("Classic payment target has invalid wealth")
	return {}


static func _character_inventory_items(character: Object) -> Array:
	if character != null and character.has_method("inventory_instances"):
		return character.inventory_instances()
	var inventory_value: Variant = character.get("inventory") \
		if character != null else []
	return inventory_value if inventory_value is Array else []


static func _character_has_inventory(character: Object) -> bool:
	return character != null and (
		character.has_method("inventory_instances")
		or character.get("inventory") is Array
	)


static func _item_is_equipped(item: Variant) -> bool:
	if item is ItemInstance:
		return item.equipped
	return (
		item is Dictionary
		and int(item.get("equipped", 0)) == 1
	)


static func _set_item_equipped(item: Variant, equipped: bool) -> void:
	if item is ItemInstance:
		item.equipped = equipped
	elif item is Dictionary:
		item["equipped"] = 1 if equipped else 0


static func _unequip_item(character: Object, item: Variant) -> bool:
	if not _item_is_equipped(item):
		return true
	if character.has_method("unequip_item"):
		return bool(character.unequip_item(item, false))
	_set_item_equipped(item, false)
	return true


static func _equip_item(character: Object, item: Variant) -> bool:
	if character.has_method("equip_item"):
		return bool(character.equip_item(item))
	_set_item_equipped(item, true)
	return true


static func _sync_character_inventory(
	character: Object,
	item: Variant = null,
) -> void:
	if character == null:
		return
	if item != null and character.has_method("sync_item_runtime_state"):
		# Compatibility-only fake characters may still expose a dictionary sync
		# method; live Creature instances carry ItemInstance state directly.
		character.sync_item_runtime_state(item)
	elif character.has_method("inventory_instances"):
		character.inventory_instances()


static func _item_matches(
	character: Object,
	item: Variant,
	classic_ids: Dictionary,
	normalized_names: Dictionary,
) -> bool:
	var definition := _item_definition(character, item)
	if not classic_ids.is_empty():
		if definition == null:
			return false
		for item_id: int in definition.classic_item_ids():
			if classic_ids.has(item_id):
				return true
		return false
	if definition != null:
		return normalized_names.has(
			definition.display_name.strip_edges().to_lower()
		)
	return (
		item is Dictionary
		and normalized_names.has(
			str(item.get("name", "")).strip_edges().to_lower()
		)
	)


static func _item_is_cursed(character: Object, item: Variant) -> bool:
	var definition := _item_definition(character, item)
	if definition != null:
		var classic_record := definition.classic_record()
		if int(classic_record.get("cursedItemId", 0)) != 0:
			return true
		for trait_value: Variant in definition.trait_descriptors():
			if trait_value is Array and not trait_value.is_empty() \
					and str(trait_value[0]).get_file() == "p_cursed.gd":
				return true
		return false
	if not (item is Dictionary):
		return false
	for field_name: String in ["classicCursedItemId", "cursedItemId"]:
		if int(item.get(field_name, 0)) != 0:
			return true
	var classic_record: Variant = item.get("classicRecord", {})
	if classic_record is Dictionary \
			and int(classic_record.get("cursedItemId", 0)) != 0:
		return true
	var item_traits: Variant = item.get("traits", [])
	if not (item_traits is Array):
		return false
	for trait_value: Variant in item_traits:
		if trait_value is Array and not trait_value.is_empty() \
				and str(trait_value[0]).get_file() == "p_cursed.gd":
			return true
	return false


static func _item_definition(
	character: Object,
	item: Variant,
) -> ItemDefinition:
	if character != null and character.has_method("get_item_definition"):
		var definition: Variant = character.get_item_definition(item)
		if definition is ItemDefinition:
			return definition
	return null


static func _item_display_name(character: Object, item: Variant) -> String:
	var definition := _item_definition(character, item)
	if definition != null:
		return definition.display_name_for(item) if item is ItemInstance \
			else definition.display_name
	return str(item.get("name", "item")) if item is Dictionary else "item"


static func _item_charges(item: Variant) -> int:
	return item.charges if item is ItemInstance \
		else int(item.get("charges", 0)) if item is Dictionary else 0


static func _set_item_charges(item: Variant, charges: int) -> void:
	if item is ItemInstance:
		item.charges = charges
	elif item is Dictionary:
		item["charges"] = charges


static func _set_item_identified(item: Variant, identified: bool) -> void:
	if item is ItemInstance:
		item.identified = identified
	elif item is Dictionary:
		item["is_identified"] = 1 if identified else 0


static func _replacement_copy(
	replacement_item: Variant,
	replacement_factory: Callable,
) -> Variant:
	if replacement_item is ItemInstance:
		if not replacement_factory.is_valid():
			return null
		return replacement_factory.call(replacement_item, {
			"equipped": false,
			"identified": false,
		})
	if replacement_item is Dictionary:
		return replacement_item.duplicate(true)
	return null


static func _normalized_names(item_names: Array) -> Dictionary:
	var normalized: Dictionary = {}
	for item_name_value: Variant in item_names:
		var item_name := str(item_name_value).strip_edges().to_lower()
		if not item_name.is_empty():
			normalized[item_name] = true
	return normalized


static func _normalized_ids(item_ids: Array) -> Dictionary:
	var normalized: Dictionary = {}
	for item_id_value: Variant in item_ids:
		var item_id: int = abs(int(item_id_value))
		if item_id != 0:
			normalized[item_id] = true
	return normalized


static func _error(message: String) -> Dictionary:
	return {"status": "error", "message": message}
