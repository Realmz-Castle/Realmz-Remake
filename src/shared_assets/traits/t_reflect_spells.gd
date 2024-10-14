const name : String = 't_reflect_spells.gd'
const menuname : String = 'Spell Reflection (T)'
const stacks : bool = true
const trait_types : Array = []
var chara
var power : int
var duration : int #in seconds, 1 round = 5s

func _init(args : Array):
	#[chara, duration]
	chara = args[0]
	duration = 5*args[1]
	power = args[2]
	UI.ow_hud.creatureRect.logrect.log_other_text(chara, ' gets Spell Reflection !', null,'')

func stack(args : Array) :
	duration += 5*args[0]

func unstack(args : Array) :
	duration -= 5*args[0]
	if duration <= 0 :
		chara.remove_trait(self)

func get_saved_variables() :
	return [ceil(duration/5)]

func _on_new_round(_character : Creature) :
	if duration <= 0 :
		chara.remove_trait(self)
		return
	duration -= 5



func _on_time_pass(_character, seconds) :
	if duration <= 0 :
		chara.remove_trait(self)
		return
	duration -= seconds

func _on_evasion_check(crea, evasion_stats_used : Array, attacker, spellornull, power : int) -> Array :
	#return array : [ proceed_with_atatack_on_self : bool, added_actions_queue : Array]
	if not is_instance_valid(spellornull) or (not is_instance_valid(attacker.combat_button)) or (not is_instance_valid(chara.combat_button)):
		return [true, []]
	if randf()<0.666 : return [true, []]
	if spellornull.attributes.has('Magical'):
		var act_msg : Dictionary = {'type' : 'Spell', 'caster' : chara.combat_button, 'spell' : spellornull, 's_plvl' : power, 'used_item' : {'charges_max'=100, 'charges'=100} , 'add_terrain' : true, 'override_aoe' : [Vector2.ZERO], 'from_terrain' : false }
		act_msg['Effected Tiles'] = [attacker.position]
		act_msg['Effected Creas'] = [attacker.combat_button]
		act_msg["Targeted Tiles"] = [attacker.position]
		act_msg['Main Targeted Tile'] = attacker.position
		return [false,[act_msg]]
	return [true, []]

func get_info_as_text() -> String :
	return 'Spell Reflection for '+str(ceil(duration/5))+' rounds'
