const name : String = 'guarding.gd'
const menuname : String = 'Guarding'
const trait_types : Array = ['Guard']
const stacks : bool = false
var power : int = 0
var chara

func _init(args : Array):
	#npower : float, nduration : int
	chara = args[0]
	power = chara.get_apr_left()
	UI.ow_hud.creatureRect.logrect.log_other_text(chara, ' goes  in guarding stance', null,'')

func stack(args : Array) :
	pass

func unstack(args : Array) :
	pass

func get_saved_variables() :
	print('trait  guarding.gd  shouldnt be active out of combat, get_saved_variables should never happen')
	return [power]

func _on_new_round(chara) :
	chara.remove_trait(self)

func _on_battle_end(chara) :
	chara.remove_trait(self)

func _on_other_creature_walked(othercreabutton : CombatCreaButton) -> Array :
	print('guard.gd trait : _on_other_creature_walked')
	if othercreabutton.creature.curFaction == chara.curFaction or chara.get_apr_left()<=0 :
		return []
	var otherpos : Vector2 = othercreabutton.creature.position
	var nextto : bool = false
	for x in range(chara.size.x) :
		for y in range(chara.size.y) :
			for d in [Vector2(-1,-1), Vector2.UP, Vector2(1,-1), Vector2.RIGHT, Vector2(1,1), Vector2.DOWN, Vector2(-1,1), Vector2.LEFT] :
				var diff : Vector2 = otherpos+d-chara.position
				print('guard.gd trait : diff is ', diff)
				if abs(diff.x)<=1 and abs(diff.y)<=1 :
					nextto = true
					break
	if nextto :
		print('guard.gd trait : _on_other_creature_walked :  ATTACK  !')
		power = max(0,chara.get_apr_left()-1)
		#{'type' : 'MeleeAttack', 'attacker' : Crea, 'defender' : Crea, 'weapon': {} }
		var act_msg : Dictionary = {'type' : 'MeleeAttack', 'attacker' : chara.combat_button, 'defender' : othercreabutton, 'weapon': chara.current_melee_weapons[0] }
		print("GUARDING TRAIT  SENDS EXTRA ATTACK")
		return [act_msg]  #uses 1 apr
	return []

func get_info_as_text() -> String :
	return 'guarding, '+str(power)+' hits left'
