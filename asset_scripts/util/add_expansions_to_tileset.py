#!/usr/bin/env python3
"""
add_expansions_to_tileset.py

Adds a JSON array property "expansion" to each tile in a Tiled tileset JSON (e.g., ForestDay.json),
using expansion data from a remapped expansions file (e.g., tileset_outdoor_remapped.json).

Usage:
    python add_expansions_to_tileset.py \
        --tileset src/shared_assets/tiles/ForestDay/ForestDay.json \
        --expansions asset_scripts/tileset_outdoor_remapped.json \
        --output src/shared_assets/tiles/ForestDay/ForestDay_with_expansions.json

- Only tiles with a matching expansion will get the property.
- The "expansion" property will be a JSON array of 9 integers.
"""

import json
import argparse
import sys
from typing import Dict, List, Any

def load_json(path: str) -> Any:
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)

def save_json(obj: Any, path: str):
    with open(path, "w", encoding="utf-8") as f:
        json.dump(obj, f, indent=2)
        f.write("\n")

def add_expansions_to_tileset(tileset: Dict, expansions: Dict[str, List[int]]) -> Dict:
    # Defensive: ensure 'tiles' exists and is a list
    tiles = tileset.get("tiles", [])
    for tile in tiles:
        tile_id = str(tile.get("id"))
        if tile_id in expansions:
            # Remove any existing "expansion" property
            props = tile.get("properties", [])
            props = [p for p in props if p.get("name") != "expansion"]
            # Add new expansion property as a JSON array
            props.append({
                "name": "expansion",
                "type": "object",  # Tiled doesn't have "array", but "object" is accepted for arbitrary JSON
                "value": expansions[tile_id]
            })
            tile["properties"] = props
    return tileset

def main():
    parser = argparse.ArgumentParser(description="Add expansion arrays to each tile in a Tiled tileset JSON.")
    parser.add_argument("--tileset", required=True, help="Path to the Tiled tileset JSON (input).")
    parser.add_argument("--expansions", required=True, help="Path to the remapped expansions JSON.")
    parser.add_argument("--output", required=True, help="Path to write the updated tileset JSON.")
    args = parser.parse_args()

    tileset = load_json(args.tileset)
    expansions = load_json(args.expansions)

    # If expansions file has a "tiles" key, use that
    if "tiles" in expansions:
        expansions = expansions["tiles"]

    # Validate expansions: must be dict of str -> list of 9 ints
    for k, v in expansions.items():
        if not (isinstance(v, list) and len(v) == 9 and all(isinstance(x, int) for x in v)):
            print(f"Warning: Expansion for key {k} is not a 9-element int array. Skipping.", file=sys.stderr)
            expansions[k] = None

    expansions = {k: v for k, v in expansions.items() if v is not None}

    updated_tileset = add_expansions_to_tileset(tileset, expansions)
    save_json(updated_tileset, args.output)
    print(f"Updated tileset written to {args.output}")

if __name__ == "__main__":
    main()
