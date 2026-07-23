extends "res://scripts/classic_runtime/classic_elemental_protection_condition_trait.gd"

const name := "t_classic_prot_mental.gd"
const menuname := "Mental Protection (Classic)"


func _condition_label() -> String:
	return "Mental Protection"


func _multiplier_stat() -> String:
	return "MultiplierMental"
