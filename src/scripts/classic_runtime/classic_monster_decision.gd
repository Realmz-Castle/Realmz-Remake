class_name ClassicMonsterDecision
extends RefCounted

const ACTION_ADVANCE := "advance"
const ACTION_CAST := "cast"
const ACTION_MISSILE := "missile"


static func chance_succeeds(percent: int, roll: int) -> bool:
	return roll >= 1 and roll <= clampi(percent, 0, 100)


static func opening_action(
	missile_percent: int,
	cast_percent: int,
	has_adjacent_enemy: bool,
	spellcasting_blocked: bool,
	been_attacked: bool,
	missile_roll: int,
	cast_roll: int
) -> String:
	# Classic checks the missile roll first, but only fires when no enemy is
	# adjacent. A failed or blocked missile check still allows the cast roll.
	if not has_adjacent_enemy and chance_succeeds(missile_percent, missile_roll):
		return ACTION_MISSILE
	if (
		not spellcasting_blocked
		and not been_attacked
		and chance_succeeds(cast_percent, cast_roll)
	):
		return ACTION_CAST
	return ACTION_ADVANCE


static func should_retry_cast(
	cast_percent: int,
	spellcasting_blocked: bool,
	been_attacked: bool,
	did_attack: bool,
	failed_spell_passes: int
) -> bool:
	return (
		cast_percent != 0
		and not spellcasting_blocked
		and not been_attacked
		and not did_attack
		and failed_spell_passes < 2
	)


static func are_opponents(actor: Variant, target: Variant) -> bool:
	var actor_faction: Variant = _faction(actor)
	var target_faction: Variant = _faction(target)
	return actor_faction != null \
		and target_faction != null \
		and int(actor_faction) != int(target_faction)


static func mark_attacked_by_effect(
	target: Variant,
	effect_result: Variant,
	was_hostile: bool
) -> bool:
	if not was_hostile or not _effect_applied(effect_result) \
			or not (target is Object) \
			or not target.has_method("mark_classic_attacked"):
		return false
	target.mark_classic_attacked()
	return true


static func missile_item(
	inventory: Array,
	item_name: String,
	item_slot: int
) -> ItemInstance:
	if item_name.is_empty():
		return null
	for item_value: Variant in inventory:
		if not (item_value is ItemInstance):
			continue
		var item: ItemInstance = item_value
		var definition := NodeAccess.__Resources().get_item_definition(item)
		if definition == null or definition.display_name != item_name:
			continue
		if int(item.state_value("classicItemSlot", -1)) != item_slot:
			continue
		var combat_spell := definition.spell_use("combat")
		if combat_spell.size() < 2:
			return null
		if definition.maximum_charges != 0 and item.charges <= 0:
			return null
		return item
	return null


static func _effect_applied(effect_result: Variant) -> bool:
	match typeof(effect_result):
		TYPE_BOOL:
			return bool(effect_result)
		TYPE_INT, TYPE_FLOAT:
			return float(effect_result) > 0.0
	return false


static func _faction(value: Variant) -> Variant:
	if not (value is Object):
		return null
	for property: Dictionary in value.get_property_list():
		if str(property.get("name", "")) == "curFaction":
			return value.get("curFaction")
	return null
