extends "res://scripts/classic_runtime/classic_permanent_spell_point_condition_trait.gd"

const name := "p_classic_power_wither.gd"
const menuname := "Power Withering (Classic, Permanent)"


func _spell_point_change(condition_power: int) -> int:
	return -condition_power


func get_info_as_text() -> String:
	var source_text := "" if trait_source.is_empty() \
		else " (source: %s)" % trait_source
	return "Permanently losing %d spell points per round%s" % [
		power,
		source_text,
	]
