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
		var creature_inventory: Variant = creature.get("inventory")
		if creature_inventory is Array:
			rewards["treasure"].append_array(creature_inventory)
	return rewards
