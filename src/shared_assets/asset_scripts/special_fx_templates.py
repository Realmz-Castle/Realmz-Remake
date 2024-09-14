from typing import Callable, Dict


def effect(template: str, to_args: Callable[[Dict], Dict]) -> Callable[[Dict], str]:
	return lambda args: template.format(**to_args(args))


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

special_fx = {
	56: effect(phase_template, phase_args),
}