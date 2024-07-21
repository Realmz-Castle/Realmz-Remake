import os
import json
import argparse

# Set up argument parser
parser = argparse.ArgumentParser(description='Collect .gd files into a JSON file.')
parser.add_argument('--source_dir', default='../Spells 1fileperspell', help='Source directory containing .gd files')
parser.add_argument('--target_dir', default='../spells', help='Target directory for the JSON file')
parser.add_argument('--json_filename', default='spells_book.json', help='Name of the JSON file to create')

# Parse arguments
args = parser.parse_args()

# Use arguments
source_dir = args.source_dir
target_dir = args.target_dir
json_filename = args.json_filename

# Ensure target directory exists
os.makedirs(target_dir, exist_ok=True)

# Initialize a dictionary to hold file names and contents
gd_files_content = {}

# Iterate through all files in the source directory
for filename in os.listdir(source_dir):
	if filename.endswith('.gd'):
		# Construct the full path to the file
		file_path = os.path.join(source_dir, filename)
		# Modify the filename to remove everything before '--' and the '.gd' extension
		modified_filename = filename.split('--')[-1].replace('.gd', '')
		# Read the content of the file
		with open(file_path, 'r', encoding='utf-8') as file:
			gd_files_content[modified_filename] = file.read()

# Construct the full path to the target JSON file
json_file_path = os.path.join(target_dir, json_filename)

# Write the dictionary to a JSON file in the target directory
with open(json_file_path, 'w', encoding='utf-8') as json_file:
	json.dump(gd_files_content, json_file)

print(f"Your spellbook is in {json_file_path}")