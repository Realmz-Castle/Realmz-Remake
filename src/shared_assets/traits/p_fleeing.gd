const name : String = 'p_fleeing.gd'  #Name of the script file
const menuname : String = 'Fleeing (P)' #The name displayed in game
const stacks : bool = false #whether the status efefct is  affected by re applying it
const trait_types : Array = []
var chara  #don't initialize it,  poinsts to afflicetd  character
const permanent : int = 1
var trait_source : String = ''
var chara_was_controlled : int  = 0  #bool, 0= fals 1=true

func _init(args : Array): 
	#arg 0 is chara
	# argument 1 : if-1, init chara_was_controlled to  the character, esle bool 0 1
	chara = args[0]
	var firstapply : int = args[1]
	if firstapply == -1 :
		if chara.is_player_controlled :
			chara_was_controlled = 1
	else :
		chara_was_controlled = firstapply==1
	chara.is_player_controlled = false

func get_saved_variables() :
	return [chara_was_controlled]

func _on_get_stat(statname : String, stat : int) :
	if ['AccuracyMelee','AccuracyRanged'].has(statname) :
		return stat-25  
	else :
		return stat

func _on_get_creature_script() :
	return GameGlobal.cmp_resources.creascripts_book['runningaway.gd']

func get_info_as_text() -> String :
	return 'Permanently Fleeing'+' (source : '+trait_source+')'

func equals_args(traits_array : Array) :
	return true
