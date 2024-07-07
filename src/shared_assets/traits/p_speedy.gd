const name : String = 'p_speedy.gd'
const menuname : String = 'Speedy (P)'
const stacks : bool = false
const trait_types : Array = []
var chara
const permanent : int = 1
var trait_source : String = ''

func _init(args : Array):
	#[chara]
	chara = args[0]
	UI.ow_hud.creatureRect.logrect.log_other_text(chara, ' is Permanently Speedy !', null,'')

func get_saved_variables() :
	return []

func _on_get_stat(statname : String, stat : int) :
	if statname == 'MaxMovement' :
		return stat*2  #1  stat = 5% chance
	if statname == 'MaxActions' :
		return ceil(stat*1.5)
	return stat

func get_info_as_text() -> String :
	return 'Permanently Speedy'+' (source : '+trait_source+')'

func equals_args(traits_array : Array) :
	return true
