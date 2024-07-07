const name : String = 'p_sp_absorb.gd'
const menuname : String = 'SP Absorb (P)'
const stacks : bool = false
const trait_types : Array = []
var chara
const permanent : int = 1
var trait_source : String = ''


func _init(args : Array):
	#[chara]
	chara = args[0]
	UI.ow_hud.creatureRect.logrect.log_other_text(chara, ' has Permanent SP Absorbtion !', null,'')

func get_saved_variables() :
	return []


			#var returned_array = t._on_spell_hit_chara(caster, spell, power, applied_damage)
			#has_effect = has_effect and returned_array[0]
			#applied_damage = returned_array[1]
			#added_to_action_queue.append(returned_array[2])
func _on_spell_hit_chara(caster : Creature, spell, powerlevel : int, damage : int) -> Array :
	var cost = caster.get_spell_resource_cost(spell, powerlevel)
	chara.change_cur_sp(cost)
	return [true, damage, []]

func get_info_as_text() -> String :
	return 'Permanent SP Absorbtion'+' (source : '+trait_source+')'

func equals_args(traits_array : Array) :
	return true
