const name : String = 'p_slow.gd'
const menuname : String = 'Slow (P)'
const stacks : bool = false
const trait_types : Array = []
var chara
const permanent : int = 1
var trait_source : String = ''

func _init(args : Array):
	#[chara]
	chara = args[0]
	UI.ow_hud.creatureRect.logrect.log_other_text(chara, ' is Permanently Slowed !', null,'')

func get_saved_variables() :
	return []

func _on_get_stat(statname : String, stat : int) :
	if ['EvasionMelee5','EvasionRanged','AccuracyMelee','AccuracyRanged'].has(statname) :
		return stat-3  #1  stat = 5% chance
	if statname == 'MaxMovement' :
		return ceil(stat/2)
	return stat

func get_info_as_text() -> String :
	return 'Permanently Slow'+' (source : '+trait_source+')'
	
func equals_args(traits_array : Array) :
	return true
