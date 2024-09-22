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

special_fx = {
    3: effect(discover_secret_template),
    6: effect(freefall_template, feather_fall_args),
    48: effect(identify_objects_template),
    50: effect(shine_template),
    56: effect(phase_template, phase_args),
    63: effect(discover_magic_template),
}
