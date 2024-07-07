const name : String = 'p_strong.gd'
const menuname : String = 'Strong (P)'
const stacks : bool = false
const trait_types : Array = []
var chara
const permanent : int = 1
var trait_source : String = ''

func _init(args : Array):
	#[chara]
	chara = args[0]
	UI.ow_hud.creatureRect.logrect.log_other_text(chara, ' is Permanently Strong !', null,'')


func get_saved_variables() :
	return []

func _on_get_stat(statname : String, stat : int) :
	if statname == 'Bonus_Physical_dmg' :
		return stat+3  #1  stat = 1% chance
	if statname == 'AccuracyMelee' :
		return stat+15
	else :
		return stat

func get_info_as_text() -> String :
	return 'Permanently Strong'+' (source : '+trait_source+')'

func equals_args(traits_array : Array) :
	return true
