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
