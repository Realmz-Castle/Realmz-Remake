extends "res://scripts/classic_runtime/classic_elemental_protection_condition_trait.gd"

const name := "t_classic_prot_fire.gd"
const menuname := "Fire Protection (Classic)"


func _condition_label() -> String:
	return "Fire Protection"


func _multiplier_stat() -> String:
	return "MultiplierFire"
