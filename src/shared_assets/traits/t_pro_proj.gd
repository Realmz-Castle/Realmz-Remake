const name : String = 't_pro_proj.gd'
const menuname : String = 'Protection from Projectiles (T)'
const stacks : bool = false
const trait_types : Array = []
var chara
var duration : int #in seconds, 1 round = 5s

func _init(args : Array):
	#[chara, duration]
	chara = args[0]
	duration = 5*args[1]
	UI.ow_hud.creatureRect.logrect.log_other_text(chara, ' is Protected from Projectiles !', null,'')

func stack(args : Array) :
	duration += 5*args[1]

func unstack(args : Array) :
	duration -= 5*args[1]

func get_saved_variables() :
	return [ceil(duration/5)]

func _on_spell_hit_chara(caster : Creature, spell, damage : int ):
	#[has_effect, applied_damage, [{added_to_action_queue}] ]
	if spell.attributes.has('Projectile') :
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
	return 'Missile Protection for '+str(ceil(duration/5))+' rounds'
