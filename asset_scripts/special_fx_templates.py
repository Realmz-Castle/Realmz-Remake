from typing import Callable, Dict


def no_args(_: Dict) -> Dict:
    return {}


def effect(template: str, to_args: Callable[[Dict], Dict] = no_args) -> Callable[[Dict], str]:
    return lambda args: template.format(**to_args(args))


phase_template = """static func special_effect(_castercrea, _spell, _power, _main_targeted_tile, _effected_tiles, _effected_creas, _add_terrain) :
	var newtpos : Vector2 = _main_targeted_tile
	_castercrea.combat_button.position  = Utils.GRID_SIZE * newtpos
	_castercrea.position = newtpos
	{after_effect}
	return true"""


def phase_args(args: Dict) -> Dict:
    after_effect = ""
    if (args["name"] == "Limited Phase"):
        after_effect = "_castercrea.used_apr = 1000"
    else:
        after_effect = ""

    result = {
        "after_effect": after_effect
    }
    return result

discover_magic_template = """static func special_effect(_castercrea, _spell, _power, _main_targeted_tile, _effected_tiles, _effected_creas, _add_terrain) -> bool :
	var text : String = ''
	for c : Creature in _effected_creas :
		var c_magic_items : Array = []
		for i : Dictionary in c.inventory :
			if i['is_magical'] : c_magic_items.append(i['name'])
		if c_magic_items.is_empty() :
			text += c.name + ' carries no magic item.\\n'
		else :
			text += c.name + ' carries magic items :\\n'
			for i : int in range(c_magic_items.size()) :
				if i < c_magic_items.size() :
					text += c_magic_items[i] +', '
				else :
					text += c_magic_items[i] +'\\n'
	var textRect = UI.ow_hud.textRect
	if StateMachine.is_combat_state() :
		textRect.show()
		UI.ow_hud.creatureRect.hide()
	textRect.set_text(text, true)
	await textRect.interruption_over
	if StateMachine.is_combat_state() :
		textRect.hide()
		UI.ow_hud.creatureRect.show()
	return true"""

identify_objects_template = """static func special_effect(_castercrea, _spell, _power, _main_targeted_tile, _effected_tiles, _effected_creas, _add_terrain) -> bool :
	for c : Creature in _effected_creas :
		for i : Dictionary in c.inventory :
			i['is_identified'] = 1
	return true"""

def feather_fall_args(args: Dict) -> Dict:
    base = 20 if args["name"] == "Free Fall" else 50
    extra = 21 if args["name"] == "Free Fall" else 51
    
    return {
        "base": base,
        "extra": extra
    }

# add arguments to the template to make hover as well
freefall_template = """static func special_effect(_castercrea, _spell, _power, _main_targeted_tile, _effected_tiles, _effected_creas, _add_terrain) -> bool :
	var duration = 0
	for i in range(_power) :
		duration += {base} + randi()% {extra}
	GameGlobal.global_effects['FeatherFall']['Duration'] += _power * duration
	UI.ow_hud.updateGlobalEffectsDisplay()
	return true"""

shine_template = """static func special_effect(_castercrea, _spell, _power, _main_targeted_tile, _effected_tiles, _effected_creas, _add_terrain) -> bool :
	GameGlobal.add_light_effect(_power, 1200*_power)
	return true"""

discover_secret_template = """static func special_effect(_castercrea, _spell, _power, _main_targeted_tile, _effected_tiles, _effected_creas, _add_terrain) -> bool :
	var duration = 0
	for i in range(_power) :
		duration += 100 + randi()% 201
	GameGlobal.global_effects['Awareness']['Duration'] += _power * duration
	UI.ow_hud.updateGlobalEffectsDisplay()
	return true"""
 
destroy_magic_template = """static func special_effect(_castercrea, _spell, _power, _main_targeted_tile, _effected_tiles, _effected_creas, _add_terrain) :
	for c : Creature in _effected_creas :
		var removed : Array = []
		for t in c .traits :
			if t.permanent : removed.append(t)
		for t in removed :
			c.remove_trait(t)
	return true
"""

waterworld_template = """static func special_effect(_castercrea, _spell, _power, _main_targeted_tile, _effected_tiles, _effected_creas, _add_terrain) -> bool :
	var duration = 0
	for i in range(_power) :
		duration += 50 + randi()% 51
	GameGlobal.global_effects['WaterBreath']['Duration'] += _power * duration
	UI.ow_hud.updateGlobalEffectsDisplay()
	return true
"""

death_template = """static func special_effect(_castercrea, _spell, _power, _main_targeted_tile, _effected_tiles, _effected_creas, _add_terrain) :
	#print('Death Special effect _effected_creas size : ', _effected_creas.size())
	#var deathspell = StateMachine.cb_anim_state.cur_action['spell']
	for creab in _effected_creas :
		#print('death : ', creab.creature.name)
		#var accuracyArray : Array = GameGlobal.calculate_spell_accuracy(_castercrea, creab.creature, deathspell, _power)
		#print('Death accuracyArray : ', accuracyArray)
		#var accuracy : float = accuracyArray[0]
		var accuracy = creab.creature.get_stat('EvasionMagic') + (1.0-creab.creature.get_stat('MultiplierMagic')) - 0.1*_power
		if randf()>accuracy :
			UI.ow_hud.creatureRect.logrect.log_other_text(creab.creature, ' survived.', null,'')
		else :
			creab.creature.change_cur_hp(- creab.creature.get_stat('curHP') - 10)
			UI.ow_hud.creatureRect.logrect.log_other_text(creab.creature, ' died.', null,'')
	return true"""

special_fx = {
    1: effect(waterworld_template),
    3: effect(discover_secret_template),
    6: effect(freefall_template, feather_fall_args),
    48: effect(identify_objects_template),
    50: effect(shine_template),
    56: effect(phase_template, phase_args),
    61: effect(destroy_magic_template),
    63: effect(discover_magic_template),
    49: effect(death_template)
}
