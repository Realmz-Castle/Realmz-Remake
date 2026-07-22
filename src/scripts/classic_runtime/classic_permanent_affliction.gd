class_name ClassicPermanentAffliction
extends RefCounted

const ConditionCureScript = preload(
	"res://scripts/classic_runtime/classic_condition_cure.gd"
)
const PermanentBlindTrait = preload(
	"res://shared_assets/traits/p_classic_blind.gd"
)
const PetrifiedTrait = preload("res://shared_assets/traits/p_petrified.gd")


static func apply_blindness(target: Object) -> bool:
	if target == null or not target.has_method("add_trait"):
		return false
	if not ConditionCureScript.has_condition(target, 27):
		target.add_trait(PermanentBlindTrait, [])
	return true


static func apply_petrification(target: Object) -> bool:
	if target == null or not target.has_method("add_trait") \
			or not target.has_method("change_cur_hp"):
		return false
	var stats: Variant = target.get("stats")
	if not (stats is Dictionary):
		return false
	if not ConditionCureScript.has_condition(target, 26):
		target.add_trait(PetrifiedTrait, [])
	var current_health := int(stats.get("curHP", 0))
	# Classic forces zero stamina and immediately follows its normal death path.
	# Remake uses -10 as the stable fully-dead health value.
	if current_health != -10:
		target.change_cur_hp(-10 - current_health)
		stats["curHP"] = -10
	target.set("life_status", 3)
	return true
