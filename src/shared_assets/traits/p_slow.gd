const name : String = 'p_slow.gd'
const menuname : String = 'Slow (P)'
const stacks : bool = false
const trait_types : Array = []
const SlowTrait = preload("res://shared_assets/traits/t_slow.gd")
var chara
const permanent : int = 1
var trait_source : String = ''

func _init(args : Array):
	#[chara]
	chara = args[0]
	SlowTrait.log_status(chara, ' is Permanently Slowed !')

func get_saved_variables() :
	return []

func _on_get_stat(statname : String, stat : int) :
	return SlowTrait.adjust_stat(statname, stat)

func get_info_as_text() -> String :
	return 'Permanently Slow'+' (source : '+trait_source+')'
	
func equals_args(traits_array : Array) :
	return true
