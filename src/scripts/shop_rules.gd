extends RefCounted


static func accepts_item(current_shop: String, shops: Dictionary, item: Dictionary) -> bool:
	if current_shop == "" or not shops.has(current_shop):
		return true
	var shop: Dictionary = shops[current_shop]
	if not shop.has("accepted_item_names"):
		return true
	var accepted_names: Variant = shop["accepted_item_names"]
	return accepted_names is Dictionary and accepted_names.has(str(item.get("name", "")))
