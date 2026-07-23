extends "res://scripts/classic_runtime/classic_permanent_spell_point_condition_trait.gd"

const name := "p_classic_power_gather.gd"
const menuname := "Power Gathering (Classic, Permanent)"


func _spell_point_change(condition_power: int) -> int:
	return condition_power


func get_info_as_text() -> String:
	var source_text := "" if trait_source.is_empty() \
		else " (source: %s)" % trait_source
	return "Permanently gathering %d spell points per round%s" % [
		power,
		source_text,
	]
