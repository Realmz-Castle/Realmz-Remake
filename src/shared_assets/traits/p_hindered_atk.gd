const name : String = 't_hindered_atk.gd'
const menuname : String = 'Hindered Attack (P)'
const stacks : bool = false
const trait_types : Array = []
var chara
power : int
var trait_source : String = ''

func _init(args : Array):
	#npower : float, nduration : int
	chara = args[0]
	power = args[1]
	UI.ow_hud.creatureRect.logrect.log_other_text(chara, 's attack is Hindered !', null,'')



func get_saved_variables() :
	return []


func _on_get_stat(statname : String, stat : int) :
	if ['AccuracyMelee','AccuracyRanged'].has(statname) :
		return stat-power
	else :
		return stat

	
func get_info_as_text() -> String :
	return 'Hindered Attack (Permanent)'
