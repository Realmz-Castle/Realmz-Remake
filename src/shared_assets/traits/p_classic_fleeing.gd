extends "res://scripts/classic_runtime/classic_fleeing_condition_trait.gd"

const name := "p_classic_fleeing.gd"
const menuname := "Fleeing (Classic, Permanent)"
const stacks := false
const permanent := true
const trait_types: Array = []


func get_saved_variables() -> Array:
	return []


func get_info_as_text() -> String:
	var source_text := "" if trait_source.is_empty() \
		else " (source: %s)" % trait_source
	return "Permanently Fleeing%s" % source_text


func equals_args(_traits_array: Array) -> bool:
	return true
