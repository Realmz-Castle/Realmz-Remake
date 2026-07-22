class_name ClassicSpellPointMutation
extends RefCounted


static func drain(target: Object, rolled_amount: int, effect_scale := 1.0) -> int:
	if not is_instance_valid(target) \
			or not target.has_method("get_stat") \
			or not target.has_method("change_cur_sp"):
		return 0
	var available := maxi(0, int(target.get_stat("curSP")))
	var drained := mini(
		available,
		floori(maxi(0, rolled_amount) * maxf(0.0, effect_scale))
	)
	target.change_cur_sp(-drained)
	return drained


static func gain(target: Object, rolled_amount: int, effect_scale := 1.0) -> int:
	if not is_instance_valid(target) \
			or not target.has_method("get_stat") \
			or not target.has_method("change_cur_sp"):
		return 0
	var current_sp := maxi(0, int(target.get_stat("curSP")))
	var gained := floori(maxi(0, rolled_amount) * maxf(0.0, effect_scale))
	var player_character := _is_player_character(target)
	if player_character:
		var maximum_sp := int(target.get_stat("maxSP"))
		gained = mini(gained, maximum_sp - current_sp)
	if gained <= 0:
		return 0
	if player_character:
		target.change_cur_sp(gained)
		return int(target.get_stat("curSP")) - current_sp

	var stats: Variant = target.get("stats")
	if stats is Dictionary and stats.has("curSP"):
		stats["curSP"] = current_sp + gained
		return gained
	target.change_cur_sp(gained)
	return int(target.get_stat("curSP")) - current_sp


static func _is_player_character(target: Object) -> bool:
	return target is PlayerCharacter or bool(target.get("is_player_controlled"))
