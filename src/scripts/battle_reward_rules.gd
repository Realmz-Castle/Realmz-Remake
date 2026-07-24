class_name BattleRewardRules
extends RefCounted


static func collect(defeated_enemies: Array, experience_only := false) -> Dictionary:
	var rewards := {
		"treasure": [],
		"experience": 0,
		"money": [0, 0, 0],
	}
	for creature: Variant in defeated_enemies:
		if not (creature is Object or creature is Dictionary):
			continue
		rewards["experience"] += int(creature.get("experience"))
		if experience_only:
			continue
		var creature_money: Variant = creature.get("money")
		if creature_money is Array:
			for money_index: int in mini(rewards["money"].size(), creature_money.size()):
				rewards["money"][money_index] += int(creature_money[money_index])
		var creature_inventory: Variant = creature.inventory_instances() \
			if creature is Object and creature.has_method("inventory_instances") \
			else creature.get("inventory")
		if creature_inventory is Array:
			for item_value: Variant in creature_inventory:
				if item_value is ItemInstance:
					var definition := NodeAccess.__Resources().get_item_definition(
						item_value
					)
					var drops := bool(item_value.state_value(
						"dropsOnDefeat",
						definition.drops_on_defeat if definition != null else true,
					))
					if not drops:
						continue
				elif item_value is Dictionary \
						and not bool(item_value.get("drops_on_defeat", true)):
					# Imported pre-M6 creature records are converted when their
					# inventory enters a live Creature.
					continue
				rewards["treasure"].append(item_value)
	return rewards
