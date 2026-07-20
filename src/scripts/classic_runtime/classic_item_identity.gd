extends RefCounted

const SHARED_ITEM_ALIASES := {
	98: "Quarter Staff",
	610: "Waterworld",
	611: "Heal Small Wounds",
}


static func candidate_names(
	item_id: int,
	item_id_mapping: Dictionary,
	item_texts: Array,
	item_book: Dictionary = {}
) -> Array[String]:
	var names: Array[String] = []
	for item_key: Variant in item_book:
		var item_value: Variant = item_book[item_key]
		if item_value is Dictionary and resource_ids(item_value).has(item_id):
			names.append(str(item_key))
	var mapped_name := str(item_id_mapping.get(
		item_id,
		item_id_mapping.get(str(item_id), "")
	))
	if not mapped_name.is_empty() and not names.has(mapped_name):
		names.append(mapped_name)
	var alias_name := str(SHARED_ITEM_ALIASES.get(item_id, ""))
	if not alias_name.is_empty() and not names.has(alias_name):
		names.append(alias_name)
	for item_text_value: Variant in item_texts:
		if not (item_text_value is Dictionary) \
				or abs(int(item_text_value.get("itemId", 0))) != item_id:
			continue
		for field_name: String in ["identifiedName", "unidentifiedName"]:
			var item_text_name := str(item_text_value.get(field_name, "")).strip_edges()
			if not item_text_name.is_empty() and not names.has(item_text_name):
				names.append(item_text_name)
	return names


static func resource_key(
	item_id: int,
	item_id_mapping: Dictionary,
	item_texts: Array,
	item_book: Dictionary
) -> String:
	for item_name: String in candidate_names(
		item_id,
		item_id_mapping,
		item_texts,
		item_book
	):
		if item_book.has(item_name):
			return item_name
	return ""


static func resource_ids(item: Dictionary) -> Array[int]:
	var ids: Array[int] = []
	if item.has("classicItemId"):
		ids.append(abs(int(item["classicItemId"])))
	var plural_value: Variant = item.get("classicItemIds", [])
	if plural_value is Array:
		for id_value: Variant in plural_value:
			var item_id: int = abs(int(id_value))
			if not ids.has(item_id):
				ids.append(item_id)
	return ids
