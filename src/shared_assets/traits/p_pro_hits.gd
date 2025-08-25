const name : String = 't_pro_hits.gd'
const menuname : String = 'Protection from Hits (T)'
const stacks : bool = true
const trait_types : Array = []
var chara
var power : int #in seconds, 1 round = 5s

func _init(args : Array):
	#[chara, power]
	chara = args[0]
	power = args[1]
	UI.ow_hud.creatureRect.logrect.log_other_text(chara, ' gets Protection from Hits !', null,'')

func stack(args : Array) :
	power += args[0]

func unstack(args : Array) :
	power -= args[0]

func get_saved_variables() :
	return [ceil(power)]


func _on_get_stat(statname : String, stat : int) :
	if ['EvasionMelee'].has(statname) :
		return stat+2*ceil(power/2)  #1  stat = 5% chance
	else :
		return stat


	
func get_info_as_text() -> String :
	return 'Protection from Hits : '+str(power)
