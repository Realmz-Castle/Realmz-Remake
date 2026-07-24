extends RefCounted


static func accepts_item(
	current_shop: String,
	shops: Dictionary,
	item: Variant,
) -> bool:
	if current_shop == "" or not shops.has(current_shop):
		return true
	var shop: Dictionary = shops[current_shop]
	if item is ItemInstance and shop.has("classic_accept_ranges"):
		var definition := NodeAccess.__Resources().get_item_definition(item)
		if definition == null:
			return false
		var accept_ranges: Variant = shop["classic_accept_ranges"]
		if not (accept_ranges is Array) or accept_ranges.size() != 4:
			return false
		for item_id: int in definition.classic_item_ids():
			if _classic_id_is_accepted(item_id, accept_ranges):
				return true
		return false
	var item_name := ""
	if item is String:
		item_name = item
	elif item is ItemInstance:
		var definition := NodeAccess.__Resources().get_item_definition(item)
		item_name = definition.display_name if definition != null else ""
	elif item is Dictionary:
		item_name = str(item.get("name", ""))
	return accepts_item_name(current_shop, shops, item_name)


static func accepts_item_name(
	current_shop: String,
	shops: Dictionary,
	item_name: String,
) -> bool:
	if current_shop == "" or not shops.has(current_shop):
		return true
	var shop: Dictionary = shops[current_shop]
	if not shop.has("accepted_item_names"):
		return true
	var accepted_names: Variant = shop["accepted_item_names"]
	return accepted_names is Dictionary and accepted_names.has(item_name)


static func _classic_id_is_accepted(item_id: int, accept_ranges: Array) -> bool:
	var rejected_ranges := 0
	for range_index: int in [0, 2]:
		var low := int(accept_ranges[range_index])
		if low == 0:
			continue
		var high := int(accept_ranges[range_index + 1])
		if item_id < low or item_id > high:
			rejected_ranges += 1
	return rejected_ranges != 2


static func balances_after_purchase(
	character_gold: int,
	pooled_gold: int,
	cost: int
) -> Array[int]:
	var pooled_payment: int = min(pooled_gold, cost)
	return [character_gold - (cost - pooled_payment), pooled_gold - pooled_payment]
