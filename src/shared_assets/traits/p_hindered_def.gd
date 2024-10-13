const name : String = 't_hindered_def.gd'
const menuname : String = 'Hindered Evasion (P)'
const stacks : bool = false
const trait_types : Array = []
var chara
var power : int
var trait_source : String = ''

func _init(args : Array):
	#npower : float, nduration : int
	chara = args[0]
	power = args[1]
	UI.ow_hud.creatureRect.logrect.log_other_text(chara, 's attack is Hindered !', null,'')



func get_saved_variables() :
	return []


func _on_get_stat(statname : String, stat : int) :
	if ['EvasionMelee','EvasionRanged'].has(statname) :
		return stat-ceil(power)
	else :
		return stat

	
func get_info_as_text() -> String :
	return 'Hindered Evasion (Permanent)'
