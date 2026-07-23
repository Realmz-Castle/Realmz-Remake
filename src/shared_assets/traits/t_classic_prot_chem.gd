extends "res://scripts/classic_runtime/classic_elemental_protection_condition_trait.gd"

const name := "t_classic_prot_chem.gd"
const menuname := "Chemical Protection (Classic)"


func _condition_label() -> String:
	return "Chemical Protection"


func _multiplier_stat() -> String:
	return "MultiplierChemical"
