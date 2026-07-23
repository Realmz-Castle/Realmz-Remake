extends "res://scripts/classic_runtime/classic_confusion_condition_trait.gd"

const name := "p_classic_confused.gd"
const menuname := "Confused (Classic, Permanent)"
const stacks := false
const permanent := true


func _on_new_round(character) -> void:
	# reduce.c clears the temporary side change even when the condition is innate.
	_reset_turn(character)


func get_saved_variables() -> Array:
	return []


func get_info_as_text() -> String:
	var source_text := "" if trait_source.is_empty() \
		else " (source: %s)" % trait_source
	return "Permanently Confused%s" % source_text


func equals_args(_traits_array: Array) -> bool:
	return true
