const name : String = 't_druidmorph.gd'
const menuname : String = 'Shapeshifted (T)'
const stacks : bool = true #effect is progressive , extra  applications  buff effect
const trait_types : Array = []
var power : float = 0
var duration : int = 0
var chara

#var original_icon : Texture2D

#var saved_variables : Array = [power, duration]

func _init(args : Array):
	#[chara, texture, duration]
	print("druidmotph init : ",args)
	chara = args[0]
	var texture = args[1]
	duration = args[2]
	#original_icon = character.textureL
	chara.combat_button.set_icon( texture, chara.size)

func stack(args : Array) :
	duration += args[1]

func unstack(args : Array) :
	duration -= args[1]
	if duration==0 :
		chara.combat_button.set_icon( chara.icon, chara.size )
		chara.remove_trait(self)

func get_saved_variables() :
	print('trait  druidmorph.gd  shouldnt be active out of combat, get_saved_variables should never happen')
	return []

func _on_new_round(chara) :
	if duration==0 :
		chara.combat_button.set_icon( chara.icon, chara.size )
		chara.remove_trait(self)
	duration -=1

func _on_battle_end(chara) :
	chara.combat_button.set_icon( chara.icon, chara.size )
	chara.remove_trait(self)

func get_info_as_text() -> String :
	return 'turned into a bear for '+str(duration)+' turns'
