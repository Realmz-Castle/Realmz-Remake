class_name ClassicMonsterWeaponRules
extends RefCounted


static func can_hit(
	attacker: Variant,
	defender: Variant,
	weapon: Dictionary
) -> bool:
	var required_name := str(_metadata(
		defender,
		"classic_required_weapon_name",
		""
	))
	var required_id := int(_metadata(
		defender,
		"classic_required_weapon_item_id",
		0
	))
	if not required_name.is_empty() or required_id > 0:
		var weapon_ids := _classic_item_ids(weapon)
		if str(weapon.get("name", "")) != required_name \
				and not weapon_ids.has(required_id):
			return false

	var required_kind := str(_metadata(
		defender,
		"classic_required_weapon_kind",
		""
	))
	if not required_kind.is_empty():
		var extra_data: Variant = weapon.get("extra_data", {})
		if not (extra_data is Dictionary) \
				or str(extra_data.get("classicWeaponKind", "")) != required_kind:
			return false

	var required_magic_plus := int(_metadata(
		defender,
		"classic_required_magic_plus",
		0
	))
	if required_magic_plus <= 0:
		return true
	var weapon_magic_plus := 0
	var extra_data: Variant = weapon.get("extra_data", {})
	if extra_data is Dictionary:
		weapon_magic_plus = int(extra_data.get("classicMagicPlus", 0))
	# Classic lets an unarmed attacker substitute one magic-plus point per
	# eight character levels.
	if _is_unarmed(weapon):
		weapon_magic_plus = int(_value(attacker, "level", 0)) / 8
	return weapon_magic_plus >= required_magic_plus


static func _classic_item_ids(weapon: Dictionary) -> Array[int]:
	var result: Array[int] = []
	if weapon.has("classicItemId"):
		result.append(abs(int(weapon["classicItemId"])))
	var ids: Variant = weapon.get("classicItemIds", [])
	if ids is Array:
		for id_value: Variant in ids:
			var item_id: int = abs(int(id_value))
			if not result.has(item_id):
				result.append(item_id)
	return result


static func _is_unarmed(weapon: Dictionary) -> bool:
	return str(weapon.get("name", "")) == "NO_MELEE_WEAPON" \
		or str(weapon.get("type", "")) == "Unarmed"


static func _metadata(value: Variant, name: String, default_value: Variant) -> Variant:
	if value is Object and value.has_meta(name):
		return value.get_meta(name)
	return _value(value, name, default_value)


static func _value(value: Variant, name: String, default_value: Variant) -> Variant:
	if value is Dictionary:
		return value.get(name, default_value)
	if value is Object:
		var property_value: Variant = value.get(name)
		return default_value if property_value == null else property_value
	return default_value
