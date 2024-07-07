const name : String = 'custom_stats.gd'
const menuname : String = 'Custom Stats'
const stacks = false  #one instance per applied effect, removed instance chosen if equals_args
const trait_types : Array = []
var stat_changes : Dictionary = {}


func _init(args : Array):
	stat_changes = args[1]

func get_saved_variables() :
	return [stat_changes]

func _on_get_stat(statname : String, stat : int) :
	if stat_changes.has(statname) :
		return stat + stat_changes[statname]
	else :
		return stat

func get_info_as_text() -> String :
	return  ''
