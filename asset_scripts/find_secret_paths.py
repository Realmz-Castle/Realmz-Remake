import json

def read_json_array(filename):
    with open(filename, 'r') as f:
        return json.load(f)

def find_occurrences(array, targets, xsize):
    positions = {target: [] for target in targets}
    for idx, value in enumerate(array):
        if value in positions:
            positions[value].append(coordinatify(idx, xsize))
    return positions

def coordinatify(index: int, xsize : int) -> list[int] :
    quotient, remainder = divmod(index, xsize)
    return [remainder, quotient, 0]

def write_positions(filename, positions):
    with open(filename, 'w') as f:
        for target, indices in positions.items():
            if indices:
                f.write(f"{target}: {indices}\n")
            else:
                f.write(f"{target}: Not found\n")
        f.write("\n\n")
        biglist = []
        for target, indices in positions.items():
            if indices :
                biglist = biglist + indices
        f.write(str(biglist))

def main():
    print("Code to find the tile index of secret paths inside a map tiles dump")
    input_file = 'input.txt'
    output_file = 'output_positions.txt'

    try:
        array = read_json_array(input_file)
    except (json.JSONDecodeError, FileNotFoundError) as e:
        print(f"Error reading input file: {e}")
        input("\nPress Enter to exit...")
        return

    
    try:
        map_size_x =int(input("Enter horizontal size of the map : "))
    except ValueError:
        print("Invalid input. Please enter a single integer.")
        input("\nPress Enter to exit...")
        return
    
    try:
        map_size_y =int(input("Enter vertical size of the map : "))
    except ValueError:
        print("Invalid input. Please enter a single integer.")
        input("\nPress Enter to exit...")
        return

    try:
        user_input = input("Enter integers to look for (space-separated), for Forest 169 180 181 182 183 184 185 : ")
        targets = list(map(int, user_input.strip().split()))
    except ValueError:
        print("Invalid input. Please enter space-separated integers.")
        input("\nPress Enter to exit...")
        return

    positions = find_occurrences(array, targets, map_size_x)
    write_positions(output_file, positions)
    print(f"Results written to {output_file}")
    input("\nPress Enter to exit...")

if __name__ == "__main__":
    main()