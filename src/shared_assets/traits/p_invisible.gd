const name : String = 'p_invisible.gd'
const menuname : String = 'Invisible (P)'
const stacks : bool = false
const trait_types : Array = ['AoO_imm'] #immune to atatcks of opportunity
var chara
const permanent : int = 1
var trait_source : String = ''

func _init(args : Array):
	#[chara]
	chara = args[0]
	UI.ow_hud.creatureRect.logrect.log_other_text(chara, ' is Permanently Invisible !', null,'')

func get_saved_variables() :
	return []

func _on_get_stat(statname : String, stat : int) :
	if ['EvasionMelee','EvasionRanged'].has(statname) :
		return stat+10  #1  stat = 1% chance
	else :
		return stat

func get_info_as_text() -> String :
	return 'Permanent Invisibility'+' (source : '+trait_source+')'

func equals_args(traits_array : Array) :
	return true
