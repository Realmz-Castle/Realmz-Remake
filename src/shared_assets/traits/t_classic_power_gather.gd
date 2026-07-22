extends "res://scripts/classic_runtime/classic_spell_point_condition_trait.gd"

const name := "t_classic_power_gather.gd"
const menuname := "Power Gathering (Classic)"


func get_info_as_text() -> String:
	return "Gathering %d spell points next round" % _remaining_duration()


func _spell_point_change(condition: int) -> int:
	return condition


func _monster_effect_precedes_decay() -> bool:
	# getup.c reads the adjacent drain condition here; use the described
	# absorbing-energy value while retaining the party branch's ordering.
	return true
