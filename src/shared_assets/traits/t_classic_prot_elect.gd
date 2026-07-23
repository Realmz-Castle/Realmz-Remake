extends "res://scripts/classic_runtime/classic_elemental_protection_condition_trait.gd"

const name := "t_classic_prot_elect.gd"
const menuname := "Electrical Protection (Classic)"


func _condition_label() -> String:
	return "Electrical Protection"


func _multiplier_stat() -> String:
	return "MultiplierElect"
