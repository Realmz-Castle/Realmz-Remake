extends "res://scripts/classic_runtime/classic_spell_point_condition_trait.gd"

const name := "t_classic_power_wither.gd"
const menuname := "Power Withering (Classic)"


func get_info_as_text() -> String:
	return "Losing %d spell points next round" % _remaining_duration()


func _spell_point_change(condition: int) -> int:
	return -condition
