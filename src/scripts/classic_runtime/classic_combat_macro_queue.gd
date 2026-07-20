class_name ClassicCombatMacroQueue
extends RefCounted


static func death_macro_entry(creature: Variant) -> Dictionary:
	if not (creature is Object) or not creature.has_meta("classic_death_macro"):
		return {}
	var macro_id := int(creature.get_meta("classic_death_macro"))
	if macro_id <= 0:
		return {}
	var context := {"queuedMacro": true}
	if _has_property(creature, "position"):
		context["actorPosition"] = creature.get("position")
	if _has_property(creature, "curFaction"):
		context["actorFaction"] = int(creature.get("curFaction"))
	if creature.has_meta("classic_monster_id"):
		context["actorMonsterId"] = int(creature.get_meta("classic_monster_id"))
	if creature.has_meta("classic_monster_name_id"):
		context["actorMonsterNameId"] = int(
			creature.get_meta("classic_monster_name_id")
		)
	return {
		"triggerId": "Data ED3:macro:%d" % macro_id,
		"context": context,
	}


static func enqueue_death_macro(queue: Array, creature: Variant) -> bool:
	var entry := death_macro_entry(creature)
	if entry.is_empty():
		return false
	queue.append(entry)
	return true


static func _has_property(value: Object, property_name: String) -> bool:
	for property: Dictionary in value.get_property_list():
		if str(property.get("name", "")) == property_name:
			return true
	return false
