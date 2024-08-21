import re
import json
from lookups import icon_lookup, sound_lookup, TRAITS
from traits_template import traits_template

# Load descriptions.json
with open('descriptions.json', 'r') as json_file:
    descriptions = json.load(json_file)

def generate_filename(caster_class, spell_id, spell_name):
    """
    Generates a filename based on the caster class, spell ID, and spell name.

    Parameters:
    - caster_class: The class of the caster (e.g., 'Sorcerer').
    - spell_id: The ID of the spell (e.g., '1101').
    - spell_name: The name of the spell (e.g., 'Discover Magic').

    Returns:
    A string representing the filename.
    """
    # Extract the first character of the caster class
    class_initial = caster_class[0].upper()
    # Extract the last three digits of the spell ID and format them as X-XX
    id_format = f"{spell_id[-3:-2]}-{spell_id[-2:]}"

    formatted_name = re.sub(r'[^a-zA-Z0-9 ]', '', spell_name)
    # Combine everything into the final filename

    filename = f"{class_initial}-{id_format}--{formatted_name}.gd"
    return filename


def get_icon_number(s):
    match = re.search(r'icon=(\d+)', s)
    if match:
        return int(match.group(1))
    else:
        return None

def get_proj_tex(s):
    icon_number = get_icon_number(s)
    icon = icon_lookup.get(icon_number)
    if icon_number != 0:
        return f"var proj_tex : String = '{icon}'"
    else:
        return ""

def get_proj_hit(s):
    icon_number = get_icon_number(s)
    icon = icon_lookup.get(icon_number)
    if icon_number != 0:
        return f"var proj_hit : String = '{icon}'"
    else:
        return ""
        

def get_sounds(cast_media, resolution_media):
    sounds = []
    cast_sound_match = re.search(r'sound=(\d+)', cast_media)
    if cast_sound_match:
        sounds.append(sound_lookup.get(int(cast_sound_match.group(1)), cast_sound_match.group(1)))
    resolution_sound_match = re.search(r'sound=(\d+)', resolution_media)
    if resolution_sound_match:
        sounds.append(sound_lookup.get(int(resolution_sound_match.group(1)), resolution_sound_match.group(1)))
    return sounds

def parse_damage(damage_field):
    """
    Parses the damage field to extract minimum and maximum damage values.

    Parameters:
    - damage_field: The damage field string from the CSV.

    Returns:
    A tuple containing (base_min, base_max, scaled_min, scaled_max).
    """
    # Regex to match the damage pattern
    damage_match = re.match(
        r'\[(\d+), (\d+)\] \+ \[(\d+), (\d+)\]/level', damage_field)
    if damage_match:
        base_min = int(damage_match.group(1))
        base_max = int(damage_match.group(2))
        scaled_min = int(damage_match.group(3))
        scaled_max = int(damage_match.group(4))
        return (base_min, base_max, scaled_min, scaled_max)
    else:
        # Return a default value if the pattern does not match
        return (0, 0, 0, 0)
    

def get_description(row):
  name = row['name']
  caste = row['caster_class']
  return descriptions[caste][name] if name in descriptions[caste] else name


def get_los(row):
    if (row['range'].startswith('-')):
        return 'false'
    return 'true'

def get_min_damage(damage):
    base_min, _, scaled_min, _ = damage
    
    if (base_min == 0 and scaled_min == 0):
        return "0"
    if (base_min == 0):
        return f"{scaled_min} * _power"
    if (scaled_min == 0):
        return f"{base_min}"
    return f"{damage[0]} + ({damage[2]} * _power)"

def get_max_damage(damage):
    _, base_max, _, scaled_max = damage
    
    if base_max == 0 and scaled_max == 0:
        return "0"
    if base_max == 0:
        return f"{scaled_max} * _power"
    if scaled_max == 0:
        return f"{base_max}"
    return f"{base_max} + ({scaled_max} * _power)"
 
def get_damage_roll(damage):
    if (damage[0] == 0 and damage[1] == 0 and damage[2] == 0 and damage[3] == 0):
        return  "\treturn 0"
    
    base_string = ""
    if (damage[0] != 0 or damage[1] != 0):
        base_string = f"\tvar base_damage = randi_range({damage[0]}, {damage[1]})\n"
    
    scaled_string = ""
    if (damage[2] != 0 or damage[3] != 0):
        scaled_string = f"\tvar scaled_damage = 0\n\tfor i in range(_power) :\n\t\tscaled_damage += randi_range({damage[2]}, {damage[3]})\n"
    
    return_string = "return 0"
    
    if base_string and scaled_string:
        return_string = "\treturn base_damage + scaled_damage"
    elif base_string:
        return_string = "\treturn base_damage"
    elif scaled_string:
        return_string = "\treturn scaled_damage"
    
    return f"{base_string}{scaled_string}{return_string}"

get_min_duration = get_min_damage
get_max_duration = get_max_damage

def get_duration_roll(duration):
    if (duration[0] == 0 and duration[1] == 0 and duration[2] == 0 and duration[3] == 0):
        return  "\treturn 0"
    
    base_string = ""
    if (duration[0] != 0 or duration[1] != 0):
        base_string = f"\tvar base_duration = randi_range({duration[0]}, {duration[1]})\n"
    
    scaled_string = ""
    if (duration[2] != 0 or duration[3] != 0):
        scaled_string = f"\tvar scaled_duration = 0\n\tfor i in range(_power) :\n\t\tscaled_damage += randi_range({duration[2]}, {duration[3]})\n"
    
    return_string = "return 0"
    
    if base_string and scaled_string:
        return_string = "\treturn base_duration + scaled_duration"
    elif base_string:
        return_string = "\treturn base_duration"
    elif scaled_string:
        return_string = "\treturn scaled_duration"
    
    return f"static func get_duration_roll(_power : int, __casterchar) -> int:\n{base_string}{scaled_string}{return_string}\n"

parse_duration = parse_damage

def parse_range(range_field):
    """
    Parses the range field to extract the range value.

    Parameters:
    - range_field: The range field string from the CSV.

    Returns:
    An integer representing the range value.
    """
    # Regex to match the range pattern
    range_match = re.match(r'(-?\d+) \+ (-?\d+)/level', range_field)
    if range_match:
        base_value = int(range_match.group(1))
        scale_value = int(range_match.group(2))
        return (abs(base_value), abs(scale_value))
    else:
        # Return a default value if the pattern does not match
        return (0, 0)
    
def get_range(range):
    if (range[0] == 0 and range[1] == 0):
        return "0"
    if (range[0] == 0):
        return f"{range[1]} * _power"
    if (range[1] == 0):
        return f"{range[0]}"
    return f"{range[0]} + ({range[1]} * _power)"

def get_traits(effect):
    if(int(effect) in TRAITS):
        return traits_template.format(trait_filename=TRAITS[int(effect)])
    return ""
