const name : String = 'p_cursed.gd'
const menuname : String = 'Cursed (P)'
const stacks : bool = false
const trait_types : Array = []
const TemporaryCurseTrait = preload("res://shared_assets/traits/t_cursed.gd")
var chara
const permanent = 1
var trait_source : String = ''

func _init(args : Array):
	#[chara]
	chara = args[0]
	TemporaryCurseTrait.log_status(chara, ' is permanently Cursed!')

func get_saved_variables() :
	return []

func _on_get_stat(statname : String, stat : int) :
	if ['EvasionMelee','EvasionRanged','AccuracyMelee','AccuracyRanged'].has(statname) :
		return stat-1  # 1 native point = Classic's 5 percentage points.
	else :
		return stat

func get_info_as_text() -> String :
	return 'Permanently Cursed'+' (source : '+trait_source+')'

func equals_args(traits_array : Array) :
	return true
