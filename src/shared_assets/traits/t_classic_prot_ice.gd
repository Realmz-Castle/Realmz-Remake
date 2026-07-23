extends "res://scripts/classic_runtime/classic_elemental_protection_condition_trait.gd"

const name := "t_classic_prot_ice.gd"
const menuname := "Cold Protection (Classic)"


func _condition_label() -> String:
	return "Cold Protection"


func _multiplier_stat() -> String:
	return "MultiplierIce"
