from typing import Dict, Any
from lookups import level_spellpoint_lookup, TargetType
from spell_utils import (
    get_proj_tex,
    get_proj_hit,
    get_sounds,
    get_special_effect_function,
    parse_damage,
    get_description,
    get_los,
    get_min_damage,
    get_max_damage,
    get_damage_roll,
    get_min_duration,
    get_max_duration,
    get_duration_roll,
    parse_duration,
    parse_range,
    get_range,
    get_traits,
    get_targets,
    get_aoe,
    get_attributes,
    get_target_type,
    get_tags
)

# Define main schools (excluding Special schools)
MAIN_SCHOOLS = [
    "Sorcerer",
    "Priest",
    "Enchanter"
]

def build_data(row: Dict[str, str]) -> Dict[str, Any]:
    damage = parse_damage(row['damage'])
    duration = parse_duration(row['duration'])
    range = parse_range(row['range'])

    return {
        'name': row['name'].replace("'", "\\'"),
        'target_type': get_target_type(row),
        'base_cost': row['base_cost'],
        'usable_in_camp': 'true' if row['usable_in_camp'] == '1' else 'false',
        'usable_in_combat': 'true' if row['usable_in_combat'] == '1' else 'false',
        'description': get_description(row),
        'resist_adjust': row['resist_adjust'],
        'can_rotate': 'true' if row['can_rotate'] == '1' else 'false',
        'range': get_range(range),
        'tags': get_tags(row),
        'schools': [row['caster_class']],
        'school_levels': {row['caster_class']: int(row['level']) if row['level'] else 0} if row['caster_class'] in MAIN_SCHOOLS else {},
        'proj_tex': get_proj_tex(row['cast_media']),
        'proj_hit': get_proj_hit(row['resolution_media']),
        'sounds': get_sounds(row['cast_media'], row['resolution_media']),
        'special_effect_function': get_special_effect_function(row),
        'min_damage': get_min_damage(damage),
        'max_damage': get_max_damage(damage),
        'damage_roll': get_damage_roll(damage, int(row['effect'])),
        'min_duration': get_min_duration(duration),
        'max_duration': get_max_duration(duration),
        'duration_roll': get_duration_roll(duration),
        'selection_costs': {},
        'add_traits_to_target': get_traits(row["effect"]),
        'is_ray': 'true' if row['target_type'] == '6' else 'false',
        'is_los': get_los(row),
        'targets': get_targets(TargetType(row['target_type'])),
        'aoe': get_aoe(TargetType(row['target_type']), int(row['size'])),
        'attributes': get_attributes(row)
    }
