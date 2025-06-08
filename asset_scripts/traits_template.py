traits_template = """static func add_traits_to_target(_casterchar : Creature, _targetcbbutton, _power):
\tvar traitscript = load('res://shared_assets/traits/'+'{trait_filename}')
\tvar trait_array : Array = [_power]
\t_targetcbbutton.creature.add_trait(traitscript , trait_array)"""

traits_template_level = """static func add_traits_to_target(_casterchar : Creature, _targetcbbutton, _power):
\tvar traitscript = load('res://shared_assets/traits/'+'{trait_filename}')
\tvar trait_array : Array = [_power, {level}]
\t_targetcbbutton.creature.add_trait(traitscript , trait_array)"""