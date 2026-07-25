extends Spell

var breath_range := 6
var damage_minimum := 1
var damage_maximum := 2


func get_range(_power: int, _caster) -> int:
	return breath_range


func get_min_damage(power: int, _caster) -> int:
	return damage_minimum * power


func get_max_damage(power: int, _caster) -> int:
	return damage_maximum * power


func get_damage_roll(power: int, _caster) -> int:
	var damage := 0
	for _roll: int in range(power):
		damage += randi_range(damage_minimum, damage_maximum)
	return damage


func get_sp_cost(_power: int, _caster) -> int:
	return 0
