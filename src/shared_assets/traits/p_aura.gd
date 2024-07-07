const name : String = 'p_aura.gd'
const menuname : String = 'Magic Aura (P)'
const stacks : bool = false

const trait_types : Array = []
var chara
var permanent : int = 0
var trait_source : String = ''

func _init(args : Array):
	#[chara]
	chara = args[0]
	UI.ow_hud.creatureRect.logrect.log_other_text(chara, ' gets a Magic Aura !', null,'')

func get_saved_variables() :
	return []


func _on_get_stat(statname : String, stat : int) :
	if ['EvasionMelee','EvasionRanged','AccuracyMelee','AccuracyRanged'].has(statname) :
		return stat+5  #1  stat = 1% chance
	else :
		return stat

func get_info_as_text() -> String :
	return 'Permanent Magic Aura'+' (source : '+trait_source+')'

func equals_args(traits_array : Array) :
	return true
