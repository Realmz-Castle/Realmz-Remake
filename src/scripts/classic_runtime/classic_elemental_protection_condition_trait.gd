class_name ClassicElementalProtectionConditionTrait
extends "res://scripts/classic_runtime/classic_timed_condition_trait.gd"

const ConditionLog = preload(
	"res://scripts/classic_runtime/classic_condition_log.gd"
)


func _init(args: Array) -> void:
	super(args)
	ConditionLog.write(chara, " gets %s!" % _condition_label())


func _on_get_stat(stat_name: String, stat: int):
	if stat_name == _multiplier_stat():
		return stat * 0.5
	return stat


func get_info_as_text() -> String:
	return "%s for %d rounds" % [
		_condition_label(),
		ceili(float(duration_seconds) / SECONDS_PER_ROUND),
	]


func _condition_label() -> String:
	return "Elemental Protection"


func _multiplier_stat() -> String:
	return ""
