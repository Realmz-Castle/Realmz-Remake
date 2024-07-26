import csv
import os
import re
from lookups import level_spellpoint_lookup
from spell_utils import generate_filename, get_proj_tex, get_proj_hit, get_sounds, parse_damage, get_description
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
        gdscript_content = gdscript_template.format(
            name=row['name'],
            target_type=row['target_type'],
            level=row['level'],
            base_cost=row['base_cost'],
            usable_in_camp='true' if row['usable_in_camp'] == '1' else 'false',
            usable_in_combat='true' if row['usable_in_combat'] == '1' else 'false',
            description=get_description(row),
            resist_adjust=row['resist_adjust'],
            can_rotate='true' if row['can_rotate'] == '1' else 'false',
            cast_media=row['cast_media'].split(', ')[1] if 'sound=' in row['cast_media'] else '',
            range=row['range'],
            tags=[],
            schools=[row['caster_class']],
            proj_tex=get_proj_tex(row['cast_media']),
            proj_hit=get_proj_hit(row['resolution_media']),
            sounds=get_sounds(row['cast_media'], row['resolution_media']),
            special_effect_function='# Implement special effects here',
            min_damage=damage[0],
            max_damage=damage[1],
            selection_cost=level_spellpoint_lookup[row['level']]
        )
        
        # Define the file name for the GDScript file
        filename = generate_filename(row['caster_class'], row['code'], row['name'])
        # Save the GDScript file
        with open(os.path.join(output_dir, filename), 'w', encoding='utf-8') as gdscript_file:
            gdscript_file.write(gdscript_content)

        print(f"Generated GDScript file for spell: {row['name']}")