const name : String = 't_phys_dmg_bonus.gd'
const menuname : String = 'Physical Damage Bonus (T)'
const stacks = false  #one instance per applied effect, removed instance chosen if equals_args
var chara
var power : float = 0
const trait_types : Array = []
var trait_source : String = ''

func _init(args : Array):
	#npower : float
	chara = args[0]
	power = args[1]

func get_saved_variables() :
	return [power]

func _on_get_stat(statname : String, stat : int) :
	if statname == "Bonus_Physical_dmg" :
		return stat + power
	else :
		return stat



func get_info_as_text() -> String :
	return 'Permanent  Phys. Dmg. Bonus + '+str(power)
