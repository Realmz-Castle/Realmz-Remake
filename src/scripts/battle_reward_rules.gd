class_name BattleRewardRules
extends RefCounted

const CLASSIC_MONSTER_GENERATION_SCRIPT = preload(
	"res://scripts/classic_runtime/classic_monster_generation.gd"
)


static func collect(defeated_enemies: Array, experience_only := false) -> Dictionary:
	var rewards := {
		"treasure": [],
		"experience": 0,
		"money": [0, 0, 0],
	}
	var classic_money: Array[int] = [0, 0, 0]
	var classic_difficulty := 0
	var has_classic_money := false
	for creature: Variant in defeated_enemies:
		if not (creature is Object or creature is Dictionary):
			continue
		rewards["experience"] += int(creature.get("experience"))
		if experience_only:
			continue
		var creature_money := money_for(creature)
		if creature is Object and creature.has_meta("classic_monster_generation"):
			var generated: Variant = creature.get_meta(
				"classic_monster_generation",
				{}
			)
			if generated is Dictionary:
				classic_difficulty = int(generated.get("difficulty", 0))
			has_classic_money = true
			for money_index: int in classic_money.size():
				classic_money[money_index] += creature_money[money_index]
		else:
			for money_index: int in rewards["money"].size():
				rewards["money"][money_index] += creature_money[money_index]
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
	if has_classic_money:
		var scaled_classic_money := CLASSIC_MONSTER_GENERATION_SCRIPT.scale_money(
			classic_money,
			classic_difficulty
		)
		for money_index: int in rewards["money"].size():
			rewards["money"][money_index] += scaled_classic_money[money_index]
	return rewards


static func money_for(creature: Variant, rolls := []) -> Array[int]:
	var maximums: Variant = creature.get("money") \
		if creature is Object or creature is Dictionary else []
	var exact: Array[int] = [0, 0, 0]
	if maximums is Array:
		for money_index: int in mini(exact.size(), maximums.size()):
			exact[money_index] = int(maximums[money_index])
	if creature is Object and creature.has_meta("classic_monster_generation"):
		return CLASSIC_MONSTER_GENERATION_SCRIPT.roll_money(exact, rolls)
	return exact
