const name : String = 't_spell_lvl_prot.gd'
const menuname : String = 'Protection from Spell up to Level '
const stacks : bool = true
const trait_types : Array = []
var chara
var duration : int #in seconds, 1 round = 5s
var level : int = 0

func _init(args : Array):
	#[chara, duration,level]
	chara = args[0]
	duration = 5*args[1]
	level = args[2]
	UI.ow_hud.creatureRect.logrect.log_other_text(chara, ' is Immune to spells up tp Lv.+'+str(level)+' !', null,'')

func stack(args : Array) :
	duration += 5*args[0]

func unstack(args : Array) :
	duration -= 5*args[0]

func get_saved_variables() :
	return [ceil(duration/5),level]

func _on_spell_hit_chara(caster : Creature, spell, damage : int ):
	#[has_effect, applied_damage, [{added_to_action_queue}] ]
	if spell.attributes.has('Magical') and spell.level <= level:
		return [false, 0, [{}]]
	else :
		return[true, damage, [{}]]


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
	
func get_info_as_text() -> String :
	return 'Spell Protection Lv.'+str(level)+'for '+str(ceil(duration/5))+' rounds'
