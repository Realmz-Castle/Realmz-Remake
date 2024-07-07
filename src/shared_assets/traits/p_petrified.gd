const name : String = 'p_petrified.gd'
const menuname : String = 'Petrified (P)'
const stacks : bool = false
const trait_types : Array = ['crea_bg_blue']
const permanent = true
var trait_source : String = ''
var chara

func _init(args : Array):
	#[character]
	chara = args[0]
	UI.ow_hud.creatureRect.logrect.log_other_text(chara, ' is rendered Helpless !', null,'')


func get_saved_variables() :
	return []

func _on_new_round(_character : Creature) :
	chara.used_apr = chara.get_apr_left()
	chara.used_movepoints = chara.get_movement_left()


func _on_get_stat(statname : String, stat : int) :
	if ['EvasionMelee','EvasionRanged'].has(statname) :
		return 0
	if statname.begins_with('Multiplier') :
		return 0.25*stat
	else :
		return stat

func _on_remove_trait(character : Creature, traitscript) :
	if traitscript == self :
		if is_instance_valid(character.combat_button) :
			character.combat_button.set_creature_represented(character)
	
func get_info_as_text() -> String :
	return 'Petrified (Permanent)'+' (source : '+trait_source+')'

func equals_args(traits_array : Array) :
	return true
