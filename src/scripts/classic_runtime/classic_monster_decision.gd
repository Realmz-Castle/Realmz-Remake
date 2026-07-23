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


static func missile_item(
	inventory: Array,
	item_name: String,
	item_slot: int
) -> Dictionary:
	if item_name.is_empty():
		return {}
	for item_value: Variant in inventory:
		if not (item_value is Dictionary):
			continue
		var item: Dictionary = item_value
		if str(item.get("name", "")) != item_name:
			continue
		if int(item.get("classic_item_slot", -1)) != item_slot:
			continue
		var combat_spell: Variant = item.get("_on_combat_use_spell")
		if not (combat_spell is Array) or combat_spell.size() < 2:
			return {}
		var maximum_charges := int(item.get("charges_max", 0))
		if maximum_charges != 0 and int(item.get("charges", 0)) <= 0:
			return {}
		return item
	return {}
