class_name ClassicSummoning
extends RefCounted

const MAX_MONSTER_SLOTS := 100
const MAX_CLASSIC_MONSTER_ID := 200
const PREFERRED_ATTEMPTS := 101
const TOTAL_ATTEMPTS := 401


static func resolved_tier(spell_id: int, source_tier: int) -> int:
	# Creature Summon 5 is the only break in an otherwise exact 1-6 sequence.
	# Its Data S row contains zero, which makes the original lookup miss until
	# Realmz widens the search after 100 attempts. Treat it as the described and
	# structurally evident fifth tier instead of retaining that data-entry error.
	return 5 if spell_id == 3604 and source_tier == 0 else source_tier


static func hit_dice_bounds(tier: int) -> Vector2i:
	var rolled_upper := 6 * maxi(1, tier)
	var lower := maxi(1, rolled_upper / 2 - 1)
	var upper := rolled_upper
	if upper > 27:
		upper = 200
	return Vector2i(lower, upper)


static func candidate_pool(bestiary: Dictionary, tier: int) -> Dictionary:
	var preferred: Array[String] = []
	var fallback: Array[String] = []
	var classic_by_id: Dictionary = {}
	var has_classic_set := false
	var bounds := hit_dice_bounds(tier)
	for key_value: Variant in bestiary:
		var entry: Variant = bestiary[key_value]
		if not (entry is Dictionary):
			continue
		var monster_id := _classic_monster_id(entry)
		if monster_id >= 0:
			has_classic_set = true
			classic_by_id[monster_id] = str(key_value)

	# Campaign records replace the shared bestiary as Classic's active Data MD
	# set. Mixing the two would allow monsters from outside the current scenario.
	for key_value: Variant in bestiary:
		var entry: Variant = bestiary[key_value]
		if not (entry is Dictionary):
			continue
		if has_classic_set and _classic_monster_id(entry) < 0:
			continue
		if not _is_summonable(entry):
			continue
		var hit_dice := _hit_dice(entry)
		if hit_dice <= 0:
			continue
		var key := str(key_value)
		fallback.append(key)
		if hit_dice >= bounds.x and hit_dice <= bounds.y:
			preferred.append(key)
	preferred.sort()
	fallback.sort()
	return {
		"preferred": preferred,
		"fallback": fallback,
		"classicById": classic_by_id,
		"hasClassicSet": has_classic_set,
		"minimumHitDice": bounds.x,
		"maximumHitDice": bounds.y,
	}


static func choose_candidate(
	bestiary: Dictionary,
	tier: int,
	selection_index := -1
) -> Dictionary:
	var pool := candidate_pool(bestiary, tier)
	var preferred: Array = pool["preferred"]
	var fallback: Array = pool["fallback"]
	if fallback.is_empty():
		return {
			"status": "missing-summonable-creature",
			"minimumHitDice": pool["minimumHitDice"],
			"maximumHitDice": pool["maximumHitDice"],
		}

	# Tests and audits can select deterministically without changing the runtime
	# path. The fallback also describes what Classic does after 100 misses.
	if selection_index >= 0:
		var candidates: Array = preferred if not preferred.is_empty() else fallback
		return {
			"status": "selected",
			"bestiaryKey": str(candidates[selection_index % candidates.size()]),
			"usedFallback": preferred.is_empty(),
			"minimumHitDice": pool["minimumHitDice"],
			"maximumHitDice": pool["maximumHitDice"],
		}

	if bool(pool["hasClassicSet"]):
		var classic_by_id: Dictionary = pool["classicById"]
		for attempt: int in range(TOTAL_ATTEMPTS):
			var monster_id := randi_range(0, MAX_CLASSIC_MONSTER_ID)
			if not classic_by_id.has(monster_id):
				continue
			var key := str(classic_by_id[monster_id])
			var candidates: Array = preferred if attempt < PREFERRED_ATTEMPTS else fallback
			if key in candidates:
				return {
					"status": "selected",
					"bestiaryKey": key,
					"usedFallback": attempt >= PREFERRED_ATTEMPTS,
					"attempts": attempt + 1,
					"minimumHitDice": pool["minimumHitDice"],
					"maximumHitDice": pool["maximumHitDice"],
				}
		return {
			"status": "selection-exhausted",
			"minimumHitDice": pool["minimumHitDice"],
			"maximumHitDice": pool["maximumHitDice"],
		}

	var candidates: Array = preferred if not preferred.is_empty() else fallback
	return {
		"status": "selected",
		"bestiaryKey": str(candidates.pick_random()),
		"usedFallback": preferred.is_empty(),
		"minimumHitDice": pool["minimumHitDice"],
		"maximumHitDice": pool["maximumHitDice"],
	}


static func apply_summon_identity(creature: Object, caster: Object) -> void:
	_set_property(creature, "is_summoned", true)
	_set_property(creature, "summoner", caster)
	_set_property(creature, "summoner_name", str(caster.get("name")))
	if _has_property(caster, "baseFaction"):
		_set_property(creature, "baseFaction", int(caster.get("baseFaction")))
	if _has_property(caster, "curFaction"):
		_set_property(creature, "curFaction", int(caster.get("curFaction")))


static func _classic_monster_id(entry: Dictionary) -> int:
	if entry.has("classicMonsterId"):
		var monster_id := int(entry["classicMonsterId"])
		if monster_id >= 0 and monster_id < MAX_CLASSIC_MONSTER_ID:
			return monster_id
	var ids: Variant = entry.get("classicMonsterIds", [])
	if ids is Array:
		for id_value: Variant in ids:
			var monster_id := int(id_value)
			if monster_id >= 0 and monster_id < MAX_CLASSIC_MONSTER_ID:
				return monster_id
	return -1


static func _is_summonable(entry: Dictionary) -> bool:
	if entry.has("classicCanSummon"):
		return int(entry["classicCanSummon"]) == 1
	var data: Variant = entry.get("data", {})
	return data is Dictionary and int(data.get("summonable", 0)) == 1


static func _hit_dice(entry: Dictionary) -> int:
	if entry.has("classicHitDice"):
		return int(entry["classicHitDice"])
	var data: Variant = entry.get("data", {})
	return int(data.get("level", 0)) if data is Dictionary else 0


static func _set_property(target: Object, property_name: String, value: Variant) -> void:
	if _has_property(target, property_name):
		target.set(property_name, value)


static func _has_property(target: Object, property_name: String) -> bool:
	for property: Dictionary in target.get_property_list():
		if str(property.get("name", "")) == property_name:
			return true
	return false
