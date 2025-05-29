import re
import csv
from typing import Dict, Any

# Function to process each spell block
def process_spell_block(block: str) -> Dict[str, Any]:
    spell_data = {}
    
    # Extract spell id, code, and details from the header
    header_match = re.match(r'===== SPELL id=(\d+) \[(SPL\d+)\] \(\((.+)\/(?:L(\d+)|([^L]+))\) (.+)\)', block)
    if header_match:
        spell_data['id'] = header_match.group(1)
        spell_data['code'] = header_match.group(2)
        spell_data['caster_class'] = header_match.group(3)
        spell_data['level'] = header_match.group(4)
        spell_data['name'] = header_match.group(6)
       # Check if group 5 starts with "Special" and append it to group 3
        if header_match.group(5) and header_match.group(3).startswith("Special"):
            spell_data['caster_class'] += '/' + header_match.group(5)
            print(spell_data['caster_class'])


    # Extract other fields
    for line in block.split('\n'):
        match = re.match(r'  (\w+)\s+(.+)', line)
        if match:
            key, value = match.group(1), match.group(2)
            spell_data[key] = value

    return spell_data

# Read the input file
with open('spells.txt', 'r') as file:
    content = file.read()

# Split the content into blocks for each spell
blocks = content.strip().split('===== SPELL ')[1:]
blocks = ['===== SPELL ' + block for block in blocks]

# Process each block and store the data
data = []
for block in blocks:
    spell_data = process_spell_block(block)
    if spell_data.get('caster_class'):
      data.append(spell_data)

# Get all unique keys for CSV header
keys = set()
for d in data:
    keys.update(d.keys())
keys = sorted(keys)

# Write to CSV file
with open('spells2.csv', 'w', newline='') as csvfile:
    writer = csv.DictWriter(csvfile, fieldnames=keys)
    writer.writeheader()
    writer.writerows(data)

print("Conversion complete. Data saved to spells2.csv.")