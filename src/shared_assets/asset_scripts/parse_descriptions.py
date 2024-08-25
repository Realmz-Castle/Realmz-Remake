import argparse
import os
import json


def parse_file(file_path):
    result_dict = {}
    with open(file_path, 'r') as file:
        lines = file.readlines()
    for line in lines:
        if '=' in line:
            key, value = line.split('=', 1)
            key = key.strip().strip('"')
            value = value.strip().strip('";')
            # Extract the key from the value before the colon
            if r'\n\n' in value:
                new_key, v = value.split(r'\n\n', 1)
                new_key = new_key.strip()
                result_dict[new_key] = value
            elif ':' in value:
                new_key, _ = value.split(':', 1)
                new_key = new_key.strip()
                result_dict[new_key] = value
    return result_dict


def merge_dicts(dict1, dict2):
    for key, value in dict2.items():
        if key in dict1:
            dict1[key] += f"; {value}"
        else:
            dict1[key] = value
    return dict1


def replace_single_quotes(data):
    if isinstance(data, dict):
        return {k: replace_single_quotes(v) for k, v in data.items()}
    elif isinstance(data, list):
        return [replace_single_quotes(i) for i in data]
    elif isinstance(data, str):
        return data.replace("'", "\\'")
    return data


def main():
    parser = argparse.ArgumentParser(description='Parse and merge files.')
    parser.add_argument('directory', type=str,
                        help='Directory containing the files to parse')
    args = parser.parse_args()

    general_results = {}
    sorcerer_results = {}
    enchanter_results = {}
    priest_results = {}

    for filename in os.listdir(args.directory):
        file_path = os.path.join(args.directory, filename)
        if os.path.isfile(file_path) and filename.startswith('-'):
            file_results = parse_file(file_path)

            if "Sorcerer" in filename:
                sorcerer_results = merge_dicts(sorcerer_results, file_results)
            elif "Enchanter" in filename:
                enchanter_results = merge_dicts(
                    enchanter_results, file_results)
            elif "Priest" in filename:
                priest_results = merge_dicts(priest_results, file_results)
            else:
                general_results = merge_dicts(general_results, file_results)

    all_results = {
        "Sorcerer": sorcerer_results,
        "Enchanter": enchanter_results,
        "Priest": priest_results
    }

    # Replace single quotes with escaped single quotes
    all_results = replace_single_quotes(all_results)

    with open('descriptions.json', 'w') as json_file:
        json.dump(all_results, json_file, indent=4, ensure_ascii=False)


if __name__ == "__main__":
    main()
