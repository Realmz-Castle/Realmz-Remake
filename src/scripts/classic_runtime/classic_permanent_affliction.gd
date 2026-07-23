class_name ClassicPermanentAffliction
extends RefCounted

const ConditionCureScript = preload(
	"res://scripts/classic_runtime/classic_condition_cure.gd"
)
const PermanentBlindTrait = preload(
	"res://shared_assets/traits/p_classic_blind.gd"
)
const PetrifiedTrait = preload(
	"res://shared_assets/traits/p_classic_petrified.gd"
)


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
	return int(stats.get("curHP", 0)) == -10 \
		and int(target.get("life_status")) == 3
