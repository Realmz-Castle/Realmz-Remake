import json

def read_json_array(filename):
    with open(filename, 'r') as f:
        return json.load(f)

def addoffset(array, offset):
    newarray = []
    for i in array :
        if i > offset:
            newarray.append(i+1)
        else :
            newarray.append(i)
    return newarray


def write_array(filename, array):
    with open(filename, 'w') as f:

        f.write(str(array))

def main():
    print("Code to offset all numbers above X  by +1 in an array")
    input_file = 'input_mapdata.txt'
    output_file = 'output_mapdata.txt'

    try:
        array = read_json_array(input_file)
    except (json.JSONDecodeError, FileNotFoundError) as e:
        print(f"Error reading input file: {e}")
        input("\nPress Enter to exit...")
        return

    
    try:
        insertedat =int(input("Enter tileID (starts at 1) of inserted tile position : "))
    except ValueError:
        print("Invalid input. Please enter a single integer.")
        input("\nPress Enter to exit...")
        return
    

    arr = addoffset(array, insertedat)
    write_array(output_file, arr)
    print(f"Results written to {output_file}")
    input("\nPress Enter to exit...")

if __name__ == "__main__":
    main()
