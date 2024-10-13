const name : String = 'p_fleeing.gd'  #Name of the script file
const menuname : String = 'Fleeing (P)' #The name displayed in game
const stacks : bool = false #whether the status efefct is  affected by re applying it
const trait_types : Array = []
var chara  #don't initialize it,  poinsts to afflicetd  character
const permanent : int = 1
var trait_source : String = ''


func _init(args : Array): 
	#arg 0 is chara
	# argument 1 : if-1, init chara_was_controlled to  the character, esle bool 0 1
	chara = args[0]

func get_saved_variables() :
	return []

func _on_get_stat(statname : String, stat : int) :
	if ['AccuracyMelee','AccuracyRanged'].has(statname) :
		return stat-25  
	else :
		return stat

func _on_get_player_controlled() :
	return false

func _on_get_creature_script() :
	return GameGlobal.cmp_resources.creascripts_book['runningaway.gd']

func get_info_as_text() -> String :
	return 'Permanently Fleeing'+' (source : '+trait_source+')'

func equals_args(traits_array : Array) :
	return true
