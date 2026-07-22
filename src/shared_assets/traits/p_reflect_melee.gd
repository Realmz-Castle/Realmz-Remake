const name := "p_reflect_melee.gd"
const menuname := "Melee Reflection"
const stacks := false
const trait_types: Array = []
const permanent := true
const AttackReflection = preload(
	"res://scripts/classic_runtime/classic_attack_reflection.gd"
)

var chara
var trait_source := ""


func _init(args: Array) -> void:
	chara = args[0]


func get_saved_variables() -> Array:
	return []


func _on_melee_reflection_check(attacker, _weapon: Dictionary, roll: int) -> bool:
	return AttackReflection.should_reflect(chara, attacker, roll)


func get_info_as_text() -> String:
	var source_text := "" if trait_source.is_empty() else " (source: %s)" % trait_source
	return "Permanent Melee Reflection (33%%)%s" % source_text


func equals_args(_traits_array: Array) -> bool:
	return true
