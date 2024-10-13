const name : String = 'reflect_spells.gd'
const menuname : String = 'Spell Reflection'
const stacks : bool = false
const trait_types : Array = []
var chara
var power : int #chance in %
const permanent : int = 1
var trait_source : String = ''

func _init(args : Array):
	#[chara]
	chara = args[0]
	UI.ow_hud.creatureRect.logrect.log_other_text(chara, ' gets Spell Reflection !', null,'')

func get_saved_variables() :
	return []

func _on_evasion_check(crea, evasion_stats_used : Array, attacker, spellornull, power : int) -> Array :
	#return array : [ proceed_with_atatack_on_self : bool, added_actions_queue : Array]
	if not is_instance_valid(spellornull) or (not is_instance_valid(attacker.combat_button)) or (not is_instance_valid(chara.combat_button)):
		return [true, []]
	if spellornull.attributes.has('Magical'):
		var act_msg : Dictionary = {'type' : 'Spell', 'caster' : chara.combat_button, 'spell' : spellornull, 's_plvl' : power, 'used_item' : {'charges_max'=100, 'charges'=100} , 'add_terrain' : true, 'override_aoe' : [Vector2.ZERO], 'from_terrain' : false }
		act_msg['Effected Tiles'] = [attacker.position]
		act_msg['Effected Creas'] = [attacker.combat_button]
		act_msg["Targeted Tiles"] = [attacker.position]
		act_msg['Main Targeted Tile'] = attacker.position
		return [false,[act_msg]]
	return [true, []]

func get_info_as_text() -> String :
	return 'Permanent Spell Reflection'+str(power)+'% (source : '+trait_source+')'

func equals_args(traits_array : Array) :
	return true
