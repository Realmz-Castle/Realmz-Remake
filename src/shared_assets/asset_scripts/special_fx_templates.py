from typing import Callable, Dict


def effect(template: str, to_args: Callable[[Dict], Dict]) -> Callable[[Dict], str]:
	return lambda args: template.format(**to_args(args))


def no_args(_: Dict) -> Dict:
	return {}

phase_template = """static func special_effect(_castercrea, _spell, _power, _main_targeted_tile, _effected_tiles, _effected_creas, _add_terrain) :
	var newtpos : Vector2 = _main_targeted_tile
	_castercrea.combat_button.position  = Utils.GRID_SIZE * newtpos
	_castercrea.position = newtpos
	{after_effect}
	return true"""


def phase_args(args: Dict) -> Dict:
	print(args)
	after_effect = ""
	if (args["name"] == "Limited Phase"):
		after_effect = "_castercrea.used_apr = 1000"
	else:
		after_effect = ""

	result = {
		"after_effect": after_effect
	}
	print(result)
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

freefall_template = """static func special_effect(_castercrea, _spell, _power, _main_targeted_tile, _effected_tiles, _effected_creas, _add_terrain) -> bool :
	var duration = 0
	for i in range(_power) :
		duration += 20 + randi()% 21
	GameGlobal.global_effects['FeatherFall']['Duration'] += _power * duration
	UI.ow_hud.updateGlobalEffectsDisplay()
	return true"""

special_fx = {
	6: effect(freefall_template, no_args),
	48: effect(identify_objects_template, no_args),
	56: effect(phase_template, phase_args),
	63: effect(discover_magic_template, no_args),
}
