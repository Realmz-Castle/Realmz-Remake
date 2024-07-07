const name : String = 'reflect_melee.gd'
const menuname : String = 'Melee Reflection'
const stacks : bool = false
const trait_types : Array = []
var chara
const permanent : int = 1
var trait_source : String = ''

func _init(args : Array):
	#[chara]
	chara = args[0]
	UI.ow_hud.creatureRect.logrect.log_other_text(chara, ' gets Permanent Melee Reflection !', null,'')

func get_saved_variables() :
	return []

func _on_evasion_check(crea, evasion_stats_used : Array, attacker, spellornull, power : int) -> Array :
	#return array : [ proceed_with_atatack_on_self : bool, added_actions_queue : Array]
	print('Melee Reflection Trait : _on_evasion_check attacker = '+attacker.name+', crea = '+crea.name)
	if is_instance_valid(spellornull) :	#null if melee
		#print('   spellornull is instance valid so nothing happens')
		return [true, []]
	if (not is_instance_valid(attacker.combat_button)) or (not is_instance_valid(chara.combat_button)) :
		#print('    on e of the cmbat buton is nt instance_valid so nothing happens')
		return [true, []]
	var used_weapon : Dictionary = crea.current_melee_weapons[0]
	var action_msg : Dictionary = {'type' : 'MeleeAttack', 'attacker' : crea.combat_button, 'defender' : attacker.combat_button, 'weapon': used_weapon }
	return [false,[action_msg]]
	
func get_info_as_text() -> String :
	return 'Permanent Melee Reflection'+' (source : '+trait_source+')'

func equals_args(traits_array : Array) :
	return true
