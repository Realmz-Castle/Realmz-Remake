extends "res://scripts/classic_runtime/classic_timed_condition_trait.gd"

const ConditionLog = preload(
	"res://scripts/classic_runtime/classic_condition_log.gd"
)
const name := "t_classic_cursed.gd"
const menuname := "Cursed (Classic)"


func _init(args: Array) -> void:
	super(args)
	ConditionLog.write(chara, " is Cursed!")


func _on_get_stat(stat_name: String, stat: int) -> int:
	if stat_name in [
		"EvasionMelee",
		"EvasionRanged",
		"AccuracyMelee",
		"AccuracyRanged",
	]:
		return stat - 1
	return stat


func get_info_as_text() -> String:
	return "Cursed for %d rounds" % ceili(
		float(duration_seconds) / SECONDS_PER_ROUND
	)
