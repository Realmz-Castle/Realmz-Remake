class_name ClassicMonsterAttackSequence
extends RefCounted


static func weapon_for_attack(
	active_weapon: Dictionary,
	attack_rows: Array,
	attacks_used: int
) -> Dictionary:
	if attack_rows.is_empty():
		return active_weapon
	var row_value: Variant = attack_rows[posmod(attacks_used, attack_rows.size())]
	if not (row_value is Dictionary):
		return active_weapon
	var attack_row: Dictionary = row_value
	if str(active_weapon.get("name", "")) == "NO_MELEE_WEAPON":
		return attack_row

	# Classic takes ordinary damage from an equipped weapon but still applies
	# the special attached to the monster's current attack row.
	var effective_weapon: Dictionary = active_weapon.duplicate(true)
	_apply_special_metadata(effective_weapon, attack_row)
	_apply_elemental_damage(effective_weapon, attack_row)
	return effective_weapon


static func _apply_special_metadata(
	effective_weapon: Dictionary,
	attack_row: Dictionary
) -> void:
	var row_extra: Variant = attack_row.get("extra_data", {})
	if not (row_extra is Dictionary) or not row_extra.has("classicSpecialAttack"):
		return
	var weapon_extra: Variant = effective_weapon.get("extra_data", {})
	if weapon_extra is Dictionary:
		weapon_extra = weapon_extra.duplicate(true)
	else:
		weapon_extra = {}
	weapon_extra["classicSpecialAttack"] = int(row_extra["classicSpecialAttack"])
	effective_weapon["extra_data"] = weapon_extra


static func _apply_elemental_damage(
	effective_weapon: Dictionary,
	attack_row: Dictionary
) -> void:
	var row_damage: Variant = attack_row.get("weapon_dmg", {})
	if not (row_damage is Dictionary):
		return
	var weapon_damage: Variant = effective_weapon.get("weapon_dmg", {})
	if weapon_damage is Dictionary:
		weapon_damage = weapon_damage.duplicate(true)
	else:
		weapon_damage = {}
	for damage_type: String in row_damage:
		if damage_type == "Physical":
			continue
		var row_bounds := _damage_bounds(row_damage[damage_type])
		var weapon_bounds := _damage_bounds(weapon_damage.get(damage_type, [0, 0]))
		weapon_damage[damage_type] = [
			weapon_bounds[0] + row_bounds[0],
			weapon_bounds[1] + row_bounds[1],
		]
	effective_weapon["weapon_dmg"] = weapon_damage


static func _damage_bounds(value: Variant) -> Array:
	if value is Array and value.size() >= 2:
		return [value[0], value[1]]
	return [0, 0]
