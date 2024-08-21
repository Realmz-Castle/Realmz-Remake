import csv
import os
import re
from lookups import level_spellpoint_lookup
from spell_utils import (
    generate_filename,
    get_proj_tex,
    get_proj_hit,
    get_sounds,
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
)
from spell_template import gdscript_template

# Define the path to your CSV file
csv_file_path = 'spells.csv'
# Define the directory where the GDScript files will be saved
output_dir = 'gd_scripts'

# Ensure the output directory exists
os.makedirs(output_dir, exist_ok=True)

# Note: You'll need to adjust the code that fills in the template to include the new fields and logic.
# For example, `sp_cost_formula` should be set to `_power*2` for spells like "Enchanted Blade",
# and `special_effect_function` should include the logic for `add_traits_to_target` when applicable.

# Open the CSV file and read data
with open(csv_file_path, mode='r', encoding='utf-8') as csv_file:
    csv_reader = csv.DictReader(csv_file)
    for row in csv_reader:
        # Prepare the content for the GDScript file
        damage = parse_damage(row['damage'])
        duration = parse_duration(row['duration'])
        range = parse_range(row['range'])
        
        gdscript_content = gdscript_template.format(
            name=row['name'],
            target_type=row['target_type'],
            base_cost=row['base_cost'],
            usable_in_camp='true' if row['usable_in_camp'] == '1' else 'false',
            usable_in_combat='true' if row['usable_in_combat'] == '1' else 'false',
            description=get_description(row),
            resist_adjust=row['resist_adjust'],
            can_rotate='true' if row['can_rotate'] == '1' else 'false',
            range=get_range(range),
            tags=[],
            schools=[row['caster_class']],
            proj_tex=get_proj_tex(row['cast_media']),
            proj_hit=get_proj_hit(row['resolution_media']),
            sounds=get_sounds(row['cast_media'], row['resolution_media']),
            special_effect_function='# Implement special effects here',
            min_damage=get_min_damage(damage),
            max_damage=get_max_damage(damage),
            damage_roll=get_damage_roll(damage),
            min_duration=get_min_duration(duration),
            max_duration=get_max_duration(duration),
            duration_roll=get_duration_roll(duration),
            selection_cost=level_spellpoint_lookup[row['level']],
            add_traits_to_target=get_traits(row["effect"]),
            is_ray='true' if row['target_type'] == '6' else 'false',
            is_los=get_los(row),
            level=row['level'],
            targets=get_targets(row['target_type']),
        )

        # Define the file name for the GDScript file
        filename = generate_filename(
            row['caster_class'], row['code'], row['name'])
        # Save the GDScript file
        with open(os.path.join(output_dir, filename), 'w', encoding='utf-8') as gdscript_file:
            gdscript_file.write(gdscript_content)

        print(f"Generated GDScript file for spell: {row['name']}")
