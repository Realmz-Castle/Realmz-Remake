import json

# Load the JSON file
with open("ForestDay.json", "r", encoding="utf-8") as f:
    data = json.load(f)

# Ask user for an integer threshold
threshold = int(input("Enter an integer threshold: "))

# Update IDs
for tile in data.get("tiles", []):
    if "id" in tile and isinstance(tile["id"], int):
        if tile["id"] > threshold:
            tile["id"] += 1

# Save the updated JSON back to file
with open("ForestDay_updated.json", "w", encoding="utf-8") as f:
    json.dump(data, f, indent=4, ensure_ascii=False)

print("IDs updated and saved to ForestDay_updated.json")
