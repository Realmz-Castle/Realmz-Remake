import csv
import os

from spell_template import gdscript_template
from spell_utils import generate_filename
from build_data import build_data
from lookups import level_spellpoint_lookup

# Define main schools (excluding Special schools)
MAIN_SCHOOLS = [
    "Sorcerer",
    "Priest", 
    "Enchanter"
]

# Define the path to your CSV file
csv_file_path = 'spells2.csv'
# Define the directory where the GDScript files will be saved
output_dir = 'gd_scripts'

# Ensure the output directory exists
os.makedirs(output_dir, exist_ok=True)

# Dictionary to hold rows by caster class
caster_class_rows = {}

# Open the CSV file and read data
with open(csv_file_path, mode='r', encoding='utf-8') as csv_file:
    csv_reader = csv.DictReader(csv_file)
    for row in csv_reader:
        caster_class = row['caster_class']
        if caster_class not in caster_class_rows:
            caster_class_rows[caster_class] = []
        caster_class_rows[caster_class].append(row)

# List to hold the merged rows
csv_rows = []

# Merge the rows by taking one spell from each caster class each cycle
while any(caster_class_rows.values()):
    for caster_class in list(caster_class_rows.keys()):
        if caster_class_rows[caster_class]:
            csv_rows.append(caster_class_rows[caster_class].pop(0))

# Dictionary to hold all the data by spell name
all_spells = {}

# Process the rows to build the data
for row in csv_rows:
    spell_name = row['name']
    if spell_name in all_spells:
        # Add the caster_class to the school array if the spell already exists
        print(
            f"Spell {spell_name} already exists. Adding {row['caster_class']} to schools array."
        )
        all_spells[spell_name][1]['schools'].append(row['caster_class'])
        # Add the school level to the school_levels dictionary (only for main schools)
        if row['caster_class'] in MAIN_SCHOOLS:
            school_level = int(row['level']) if row['level'] else 0
            all_spells[spell_name][1]['school_levels'][row['caster_class']] = school_level
    else:
        data = build_data(row)
        all_spells[spell_name] = (row, data)

# Write the GDScript files
for spell_name, (row, data) in all_spells.items():
    # Ensure all main schools have entries in school_levels (0 for schools that don't have the spell)
    complete_school_levels = {}
    for school in MAIN_SCHOOLS:
        complete_school_levels[school] = data['school_levels'].get(school, 0)
    
    # Format as GDScript dictionary syntax
    gdscript_school_levels = "{"
    school_entries = []
    for school, level in complete_school_levels.items():
        school_entries.append(f'"{school}": {level}')
    gdscript_school_levels += ", ".join(school_entries) + "}"
    data['school_levels'] = gdscript_school_levels
    
    # Ensure all main schools have entries in selection_costs
    complete_selection_costs = {}
    for school in MAIN_SCHOOLS:
        school_level = complete_school_levels[school]
        if school_level > 0:
            complete_selection_costs[school] = level_spellpoint_lookup.get(str(school_level), 0)
        else:
            complete_selection_costs[school] = 0
    
    # Format as GDScript dictionary syntax
    gdscript_selection_costs = "{"
    cost_entries = []
    for school, cost in complete_selection_costs.items():
        cost_entries.append(f'"{school}": {cost}')
    gdscript_selection_costs += ", ".join(cost_entries) + "}"
    data['selection_costs'] = gdscript_selection_costs
    
    gdscript_content = gdscript_template.format(**data)
    filename = generate_filename(row['caster_class'], row['code'], spell_name)
    with open(os.path.join(output_dir, filename), 'w', encoding='utf-8') as gdscript_file:
        gdscript_file.write(gdscript_content)
    print(f"Generated GDScript file for spell: {spell_name}")
