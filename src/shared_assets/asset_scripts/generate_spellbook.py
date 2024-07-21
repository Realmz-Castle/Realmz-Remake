import os
import json

# Define the source and target directories
SOURCE_DIR = '../Spells 1fileperspell'
TARGET_DIR = '../spells'
JSON_FILENAME = 'spells_book.json'

# Ensure target directory exists
os.makedirs(TARGET_DIR, exist_ok=True)

# Initialize a dictionary to hold file names and contents
gd_files_content = {}

# Iterate through all files in the source directory
for filename in os.listdir(SOURCE_DIR):
	if filename.endswith('.gd'):
		# Construct the full path to the file
		file_path = os.path.join(SOURCE_DIR, filename)
		# Modify the filename to remove everything before '--' and the '.gd' extension
		modified_filename = filename.split('--')[-1].replace('.gd', '')
		# Read the content of the file
		with open(file_path, 'r', encoding='utf-8') as file:
			gd_files_content[modified_filename] = file.read()

# Construct the full path to the target JSON file
json_file_path = os.path.join(TARGET_DIR, JSON_FILENAME)

# Write the dictionary to a JSON file in the target directory
with open(json_file_path, 'w', encoding='utf-8') as json_file:
	json.dump(gd_files_content, json_file)

print(f"GD files have been successfully saved to {json_file_path}")