import sys
import json
from PIL import Image
import numpy as np

def load_image(path):
    return Image.open(path).convert('RGBA')

def slice_tiles(img, tile_size):
    tiles = []
    w, h = img.size
    for y in range(0, h, tile_size):
        for x in range(0, w, tile_size):
            tile = img.crop((x, y, x+tile_size, y+tile_size))
            tiles.append(np.array(tile))
    return tiles

def mse(a, b):
    # Ensure both tiles are the same shape
    if a.shape != b.shape:
        # Pad the smaller tile with zeros
        max_shape = (
            max(a.shape[0], b.shape[0]),
            max(a.shape[1], b.shape[1]),
            max(a.shape[2], b.shape[2])
        )
        a_padded = np.zeros(max_shape, dtype=a.dtype)
        b_padded = np.zeros(max_shape, dtype=b.dtype)
        a_padded[:a.shape[0], :a.shape[1], :a.shape[2]] = a
        b_padded[:b.shape[0], :b.shape[1], :b.shape[2]] = b
        a, b = a_padded, b_padded
    return np.mean((a.astype(float) - b.astype(float)) ** 2)

def compute_cost_matrix(tiles1, tiles2):
    cost = []
    for t1 in tiles1:
        row = []
        for t2 in tiles2:
            row.append(mse(t1, t2))
        cost.append(row)
    return cost

DEFAULT_COST_CUTOFF = 200

def greedy_mapping(cost_matrix, cost_cutoff):
    mapping = []
    used = set()
    for i, row in enumerate(cost_matrix):
        unused = [j for j in range(len(row)) if j not in used]
        if not unused:
            mapping.append(None)
            continue
        min_j = min(unused, key=lambda j: row[j])
        min_cost = row[min_j]
        if min_cost < cost_cutoff:
            mapping.append(min_j)
            used.add(min_j)
        else:
            mapping.append(None)
    return mapping

def main(img1_path, img2_path, tile_size, output_path, cost_cutoff):
    img1 = load_image(img1_path)
    img2 = load_image(img2_path)
    tiles1 = slice_tiles(img1, tile_size)
    tiles2 = slice_tiles(img2, tile_size)
    if len(tiles1) == 0 or len(tiles2) == 0:
        print("Error: One or both images do not contain any tiles with the given tile size.")
        sys.exit(1)
    cost_matrix = compute_cost_matrix(tiles1, tiles2)
    mapping = greedy_mapping(cost_matrix, cost_cutoff)
    # Output as dict: original id -> remake id or null, with original ids starting at 1
    out_map = {str(i+1): (v if v is not None else None) for i, v in enumerate(mapping)}
    with open(output_path, 'w') as f:
        json.dump(out_map, f, indent=2)
    print(f"Mapping written to {output_path}")

    # Generate report for mappings with cost > 1


    # Generate full report for every original tile
    full_report = []
    for i, v in enumerate(mapping):
        if v is not None:
            cost = cost_matrix[i][v]
            remake_tile = v
        else:
            # No match, report minimum cost and null remake_tile
            costs = cost_matrix[i]
            cost = min(costs) if costs else None
            remake_tile = None
        full_report.append({
            "original_tile": i+1,
            "remake_tile": remake_tile,
            "cost": cost
        })
    full_report_path = output_path.replace(".json", "_full_report.json")
    with open(full_report_path, 'w') as f:
        json.dump(full_report, f, indent=2)
    print(f"Full mapping report written to {full_report_path}")

    # Save unmatched (null) tiles as PNGs for inspection
    unmatched_dir = "asset_scripts/unmatched_tiles"
    import os
    os.makedirs(unmatched_dir, exist_ok=True)
    for i, v in enumerate(mapping):
        if v is None:
            img = Image.fromarray(tiles1[i])
            img.save(os.path.join(unmatched_dir, f"unmatched_{i+1}.png"))
    print(f"Unmatched tile PNGs written to {unmatched_dir}/")

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Map original image tiles to remake tiles by similarity.")
    parser.add_argument("img1", help="Path to original image")
    parser.add_argument("img2", help="Path to remake image")
    parser.add_argument("tile_size", type=int, help="Tile size (square)")
    parser.add_argument("output", help="Output mapping JSON file")
    parser.add_argument("--cutoff", type=float, default=DEFAULT_COST_CUTOFF, help="Cost cutoff for matching (default: 200)")
    args = parser.parse_args()
    main(args.img1, args.img2, args.tile_size, args.output, args.cutoff)
