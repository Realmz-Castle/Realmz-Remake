class_name ClassicPetrification
extends RefCounted


static func force_state(character: Object) -> bool:
	if character == null or not character.has_method("get_stat") \
			or not character.has_method("change_cur_hp"):
		return false
	var current_health := int(character.call("get_stat", "curHP"))
	if current_health != -10:
		character.call("change_cur_hp", -10 - current_health)
	var stats: Variant = character.get("stats")
	if stats is Dictionary:
		stats["curHP"] = -10
	character.set("life_status", 3)
	return true
