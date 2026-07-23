extends "res://scripts/classic_runtime/classic_animated_condition_trait.gd"

const name := "p_classic_animated.gd"
const menuname := "Animated (Classic)"
const stacks := false
const permanent := 1

func _init(args: Array) -> void:
	super(args)
	if args.size() == 1:
		trait_source = "Puppet Master"


func get_saved_variables() -> Array:
	return []


func get_info_as_text() -> String:
	var source_text := "" if trait_source.is_empty() \
		else " (source: %s)" % trait_source
	return "Permanently Animated%s" % source_text


func equals_args(_traits_array: Array) -> bool:
	return true
