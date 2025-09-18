#!/usr/bin/env python3
"""
generate_expansion_preview.py
=============================

Purpose:
    Generate 3×3 expansion preview images (individual tiles and/or a sprite sheet) from a
    tileset metadata JSON, tileset image PNG, and an expansions JSON produced by
    tileset_txt_to_json.py (or compatible structure).

Key Features:
    - Robust CLI configuration.
    - Supports expansions JSON in two shapes:
        1) { "meta": {...}, "tiles": { "0": [[...],[...],[...]], ... } }
        2) { "0": [[...],[...],[...]], ... }
    - Optional per-expansion key shifting (--key-shift) if previous pipeline phases introduced offsets.
    - Optional reference ID remapping from a JSON mapping (--ref-map) then uniform reference shift (--ref-shift).
    - Subset selection (e.g. --subset "1,2,5-10") to limit which expansions are rendered.
    - Heuristic analysis with toggle (--no-heuristics) and output file (--analysis).
    - Placeholder tiles for out-of-range or negative tile references (magenta w/ diagonal markers).
    - Strict mode to fail on any invalid reference (--strict-ids).
    - Generates:
        * Individual 3x3 PNGs (unless --no-individual).
        * An optional sprite sheet collating expansions (unless --no-sheet).
    - Sheet layout configurable with --sheet-cols and optional max rows.
    - Warning aggregation + optional warning file.
    - Extensive summary stats.

Typical Usage:
    Basic:
        python3 generate_expansion_preview.py \\
            --exp-json asset_scripts/tileset_outdoor.json \\
            --tileset-json src/shared_assets/tiles/ForestDay/ForestDay.json \\
            --tileset-png  src/shared_assets/tiles/ForestDay/ForestDay.png \\
            --output-dir   asset_scripts/expansion_tiles

    Apply remapping + reference shift:
        python3 generate_expansion_preview.py --ref-map ref_map.json --ref-shift 2 ...

    Only analyze (skip writing individual images):
        python3 generate_expansion_preview.py --no-individual --analysis analysis.txt ...

Exit Codes:
    0 success
    1 failure (fatal errors or strict violations)

Mapping File Format (ref-map):
    {
        "60": 58,
        "61": 59
    }
    Keys may be strings or ints; values must be ints.

Heuristic Flags / Criteria:
    - Uniform tile (all 9 identical).
    - Very repetitive (<= 2 unique tiles).
    - Water + mountain mix.
    - Water mixed with disallowed types (not shore/water).
    - Too many unique tile "template" types (> --max-types).
    These can be disabled with --no-heuristics.

Author:
    Rewritten for robustness and clarity.
"""

from __future__ import annotations

import argparse
import json
import math
import os
import sys
from dataclasses import dataclass, asdict
from typing import Dict, List, Optional, Tuple, Iterable, Any, Set

try:
    from PIL import Image
except ImportError:
    print("FATAL: Pillow (PIL) not installed. Install with 'pip install Pillow'.", file=sys.stderr)
    sys.exit(1)


# ---------------------------------------------------------------------------
# Data Classes
# ---------------------------------------------------------------------------

@dataclass
class Config:
    exp_json: str
    tileset_json: str
    tileset_png: str
    output_dir: str
    sheet_output: Optional[str]
    analysis_output: Optional[str]
    warn_file: Optional[str]

    ref_map_path: Optional[str]
    ref_shift: int
    key_shift: int
    strict_ids: bool
    subset: Optional[str]

    no_individual: bool
    no_sheet: bool
    sheet_cols: int
    sheet_max_rows: Optional[int]
    image_format: str

    placeholder_transparent: bool
    quiet: bool
    echo_config: bool
    no_heuristics: bool
    max_types: int

    tile_border: int  # optional border between tiles in sheet
    fail_on_warning: bool  # escalate warnings to failure
    include_meta_in_sheet: bool


@dataclass
class Stats:
    expansions_total: int = 0
    expansions_rendered: int = 0
    expansions_analyzed: int = 0
    invalid_references: int = 0
    placeholders_used: int = 0
    mapped_refs: int = 0
    shifted_refs: int = 0
    warnings: int = 0
    errors: int = 0
    problematic_heuristics: int = 0


@dataclass
class HeuristicResult:
    tile_ids: List[int]
    unique_tiles: int
    type_counts: Dict[str, int]
    issues: List[str]
    problematic: bool


# ---------------------------------------------------------------------------
# Utilities
# ---------------------------------------------------------------------------

def parse_args(argv: Optional[Iterable[str]] = None) -> Config:
    p = argparse.ArgumentParser(description="Generate 3x3 expansion previews from tileset + expansions JSON.")

    p.add_argument("--exp-json", required=True, help="Path to expansions JSON (from tileset_txt_to_json.py).")
    p.add_argument("--tileset-json", required=True, help="Tileset metadata JSON (e.g. ForestDay.json).")
    p.add_argument("--tileset-png", required=True, help="Tileset image PNG.")
    p.add_argument("--output-dir", required=True, help="Directory for individual expansion images.")

    p.add_argument("--sheet-output", help="Optional path for a sprite sheet image.")
    p.add_argument("--analysis", dest="analysis_output", help="Optional path to write analysis / heuristics report.")
    p.add_argument("--warn-file", help="Optional path to write warnings.")

    p.add_argument("--ref-map", dest="ref_map_path", help="JSON file mapping original expansion references.")
    p.add_argument("--ref-shift", type=int, default=0, help="Uniform shift applied after mapping to each ref (default 0).")
    p.add_argument("--key-shift", type=int, default=0, help="Apply shift to expansion keys (after reading JSON).")
    p.add_argument("--strict-ids", action="store_true", help="Fail on any out-of-range tile ID reference.")
    p.add_argument("--subset", help='Subset of expansions (e.g. "1,2,10-15"). Applied after key shift.')

    p.add_argument("--no-individual", action="store_true", help="Skip writing individual expansion images.")
    p.add_argument("--no-sheet", action="store_true", help="Skip writing sprite sheet.")
    p.add_argument("--sheet-cols", type=int, default=20, help="Number of expansions per row in sheet (default 20).")
    p.add_argument("--sheet-max-rows", type=int, help="Optional maximum sheet rows (excess ignored).")
    p.add_argument("--image-format", default="png", help="Image format for individual images (default png).")

    p.add_argument("--placeholder-transparent", action="store_true", help="Transparent placeholder instead of opaque magenta.")
    p.add_argument("--quiet", action="store_true", help="Reduce console output.")
    p.add_argument("--echo-config", action="store_true", help="Echo effective configuration.")
    p.add_argument("--no-heuristics", action="store_true", help="Disable heuristic analysis.")
    p.add_argument("--max-types", type=int, default=4, help="Heuristic: max acceptable unique types before flagging (default 4).")

    p.add_argument("--tile-border", type=int, default=0, help="Pixels of spacing between expansions in sheet.")
    p.add_argument("--fail-on-warning", action="store_true", help="Return non-zero if any warnings encountered.")
    p.add_argument("--sheet-meta-label", action="store_true",
                   help="Embed expansion ID text label onto each cell (requires pillow default font).")

    args = p.parse_args(argv)

    return Config(
        exp_json=args.exp_json,
        tileset_json=args.tileset_json,
        tileset_png=args.tileset_png,
        output_dir=args.output_dir,
        sheet_output=args.sheet_output,
        analysis_output=args.analysis_output,
        warn_file=args.warn_file,
        ref_map_path=args.ref_map_path,
        ref_shift=args.ref_shift,
        key_shift=args.key_shift,
        strict_ids=args.strict_ids,
        subset=args.subset,
        no_individual=args.no_individual,
        no_sheet=args.no_sheet,
        sheet_cols=args.sheet_cols,
        sheet_max_rows=args.sheet_max_rows,
        image_format=args.image_format.lower(),
        placeholder_transparent=args.placeholder_transparent,
        quiet=args.quiet,
        echo_config=args.echo_config,
        no_heuristics=args.no_heuristics,
        max_types=args.max_types,
        tile_border=args.tile_border,
        fail_on_warning=args.fail_on_warning,
        include_meta_in_sheet=args.sheet_meta_label
    )


def log(msg: str, cfg: Config, *, stderr: bool = False):
    if not cfg.quiet:
        (sys.stderr if stderr else sys.stdout).write(msg + "\n")


class WarningSink:
    def __init__(self, cfg: Config, stats: Stats):
        self.cfg = cfg
        self.stats = stats
        self._messages: List[str] = []

    def warn(self, msg: str):
        self._messages.append(msg)
        self.stats.warnings += 1
        if not self.cfg.quiet:
            print(f"[WARN] {msg}", file=sys.stderr)

    def error(self, msg: str):
        self._messages.append("ERROR: " + msg)
        self.stats.errors += 1
        print(f"[ERR ] {msg}", file=sys.stderr)

    def flush(self):
        if self.cfg.warn_file and self._messages:
            try:
                with open(self.cfg.warn_file, "w", encoding="utf-8") as f:
                    for m in self._messages:
                        f.write(m + "\n")
            except OSError as e:
                print(f"FATAL: Could not write warnings file '{self.cfg.warn_file}': {e}", file=sys.stderr)


def parse_subset(spec: str) -> Set[int]:
    """
    Parse a subset spec like "1,2,10-15,20" into a set of ints.
    """
    out: Set[int] = set()
    for part in spec.split(","):
        part = part.strip()
        if not part:
            continue
        if "-" in part:
            a, b = part.split("-", 1)
            try:
                start = int(a)
                end = int(b)
            except ValueError:
                continue
            if start > end:
                start, end = end, start
            out.update(range(start, end + 1))
        else:
            try:
                out.add(int(part))
            except ValueError:
                continue
    return out


def load_json(path: str, desc: str) -> Any:
    try:
        with open(path, "r", encoding="utf-8") as f:
            return json.load(f)
    except FileNotFoundError:
        print(f"FATAL: {desc} file not found: {path}", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"FATAL: {desc} JSON decode error in {path}: {e}", file=sys.stderr)
        sys.exit(1)
    except OSError as e:
        print(f"FATAL: Could not read {desc} file {path}: {e}", file=sys.stderr)
        sys.exit(1)


def normalize_expansions(data: Any, cfg: Config, sink: WarningSink) -> Dict[int, list]:
    """
    Accept only flat 9-element lists and return dict[int, flat list].
    Applies key_shift if provided.
    """
    tiles_section = None
    if isinstance(data, dict) and "tiles" in data and isinstance(data["tiles"], dict):
        tiles_section = data["tiles"]
    elif isinstance(data, dict):
        tiles_section = data
    else:
        sink.error("Expansions JSON has unexpected top-level structure.")
        return {}

    result: Dict[int, list] = {}
    for k, v in tiles_section.items():
        try:
            key_int = int(k) + cfg.key_shift
        except (ValueError, TypeError):
            sink.warn(f"Skipping non-integer key: {k!r}")
            continue

        if isinstance(v, list) and len(v) == 9 and all(isinstance(x, int) for x in v):
            result[key_int] = v
        else:
            sink.warn(f"Key {k}: value not recognized as flat list of length 9.")
            continue
    return result


def load_mapping(path: Optional[str], sink: WarningSink) -> Dict[int, int]:
    if not path:
        return {}
    raw = load_json(path, "mapping")
    mapping: Dict[int, int] = {}
    if not isinstance(raw, dict):
        sink.warn("Mapping file root is not a JSON object.")
        return mapping
    for k, v in raw.items():
        try:
            ki = int(k)
            vi = int(v)
        except (ValueError, TypeError):
            sink.warn(f"Ignoring invalid mapping entry: {k!r}: {v!r}")
            continue
        mapping[ki] = vi
    return mapping


def build_tile_metadata(tileset_meta: dict) -> Tuple[int, int, int, Dict[int, str], Dict[int, str]]:
    """
    Extract (tile_width, tile_height, columns, tile_type_by_id, tile_name_by_id)
    """
    tile_width = tileset_meta.get("tilewidth")
    tile_height = tileset_meta.get("tileheight")
    columns = tileset_meta.get("columns")
    if not all(isinstance(x, int) and x > 0 for x in (tile_width, tile_height, columns)):
        raise ValueError("Tileset metadata missing or invalid 'tilewidth', 'tileheight', or 'columns'.")

    type_map: Dict[int, str] = {}
    name_map: Dict[int, str] = {}
    for tile_entry in tileset_meta.get("tiles", []):
        tid = tile_entry.get("id")
        if not isinstance(tid, int):
            continue
        template = "unknown"
        name = f"tile_{tid}"
        for prop in tile_entry.get("properties", []):
            if prop.get("name") == "template":
                template = prop.get("value", template)
            elif prop.get("name") == "name":
                name = prop.get("value", name)
        type_map[tid] = template
        name_map[tid] = name
    return tile_width, tile_height, columns, type_map, name_map


def create_placeholder(tile_w: int, tile_h: int, transparent: bool) -> Image.Image:
    img = Image.new("RGBA", (tile_w, tile_h), (0, 0, 0, 0) if transparent else (255, 0, 255, 255))
    # Diagonal cross
    for i in range(min(tile_w, tile_h)):
        img.putpixel((i, i), (0, 0, 0, 255))
        img.putpixel((tile_w - 1 - i, i), (0, 0, 0, 255))
    return img


def get_tile_crop(tileset_img: Image.Image, tile_id: int, tile_w: int, tile_h: int, columns: int) -> Image.Image:
    x = tile_id % columns
    y = tile_id // columns
    left = x * tile_w
    top = y * tile_h
    return tileset_img.crop((left, top, left + tile_w, top + tile_h))


def apply_mapping_and_shift(flat: list, mapping: Dict[int, int], ref_shift: int,
                            stats: Stats) -> list:
    new_flat: list = []
    for cid in flat:
        mapped = mapping.get(cid, cid)
        if mapped != cid:
            stats.mapped_refs += 1
        shifted = mapped + ref_shift
        if ref_shift != 0:
            stats.shifted_refs += 1
        new_flat.append(shifted)
    return new_flat


def analyze_expansion(matrix: List[List[int]],
                      tile_types: Dict[int, str],
                      max_types: int,
                      no_heuristics: bool) -> HeuristicResult:
    tile_ids = [t for row in matrix for t in row]
    types = [tile_types.get(t, "unknown") for t in tile_ids]
    type_counts: Dict[str, int] = {}
    for t in types:
        type_counts[t] = type_counts.get(t, 0) + 1

    unique_tiles = len(set(tile_ids))
    issues: List[str] = []
    problematic = False

    if no_heuristics:
        return HeuristicResult(tile_ids, unique_tiles, type_counts, issues, False)

    # Heuristics:
    if unique_tiles == 1:
        problematic = True
        issues.append("Uniform (one tile repeated 9x)")
    elif unique_tiles <= 2:
        problematic = True
        issues.append(f"Highly repetitive ({unique_tiles} unique tiles)")

    types_set = set(types)
    if "water" in types_set and "mountain" in types_set:
        problematic = True
        issues.append("Contains both water and mountain")
    if "water" in types_set:
        disallowed = types_set - {"water", "shore", "unknown"}
        if disallowed:
            problematic = True
            issues.append(f"Water mixed with {', '.join(sorted(disallowed))}")
    if len(types_set) > max_types:
        problematic = True
        issues.append(f"Too many different types ({len(types_set)})")

    return HeuristicResult(tile_ids, unique_tiles, type_counts, issues, problematic)


def embed_label(image: Image.Image, text: str):
    """
    Simple label embedding using Pillow's default font (no heavy dependencies).
    Writes small black text at top-left with white shadow for contrast.
    """
    from PIL import ImageDraw, ImageFont
    draw = ImageDraw.Draw(image)
    try:
        font = ImageFont.load_default()
    except Exception:
        font = None
    shadow_pos = (2, 2)
    text_pos = (1, 1)
    if font:
        draw.text(shadow_pos, text, fill=(0, 0, 0, 180), font=font)
        draw.text(text_pos, text, fill=(255, 255, 255, 255), font=font)
    else:
        draw.text(shadow_pos, text, fill=(0, 0, 0, 180))
        draw.text(text_pos, text, fill=(255, 255, 255, 255))


# ---------------------------------------------------------------------------
# Main Processing
# ---------------------------------------------------------------------------

def generate(cfg: Config) -> int:
    stats = Stats()
    sink = WarningSink(cfg, stats)

    if cfg.echo_config:
        log("Effective Configuration:", cfg)
        for k, v in asdict(cfg).items():
            log(f"  {k}: {v}", cfg)
        log("-" * 60, cfg)

    # Load expansions
    exp_data = load_json(cfg.exp_json, "expansions")
    expansions = normalize_expansions(exp_data, cfg, sink)
    stats.expansions_total = len(expansions)

    if cfg.subset:
        wanted = parse_subset(cfg.subset)
        expansions = {k: v for k, v in expansions.items() if k in wanted}
        log(f"Subset selection active: {len(expansions)} expansions after filtering.", cfg)

    if not expansions:
        sink.error("No expansions to process after normalization/subset.")
        sink.flush()
        return 1

    # Load tileset metadata + image
    tileset_meta = load_json(cfg.tileset_json, "tileset metadata")
    try:
        tile_w, tile_h, columns, tile_types, tile_names = build_tile_metadata(tileset_meta)
    except ValueError as e:
        sink.error(str(e))
        sink.flush()
        return 1

    try:
        tileset_img = Image.open(cfg.tileset_png)
    except FileNotFoundError:
        sink.error(f"Tileset PNG not found: {cfg.tileset_png}")
        sink.flush()
        return 1
    except OSError as e:
        sink.error(f"Failed to open tileset PNG '{cfg.tileset_png}': {e}")
        sink.flush()
        return 1

    total_tiles = (tileset_img.width // tile_w) * (tileset_img.height // tile_h)

    log(f"Tileset: {tile_w}x{tile_h}px tiles, columns={columns}, total_tiles={total_tiles}", cfg)
    log(f"Expansion count (post-filter): {len(expansions)}", cfg)

    mapping = load_mapping(cfg.ref_map_path, sink)
    if mapping:
        log(f"Loaded mapping entries: {len(mapping)}", cfg)

    # Prepare output directory
    if not cfg.no_individual:
        os.makedirs(cfg.output_dir, exist_ok=True)

    placeholder = create_placeholder(tile_w, tile_h, cfg.placeholder_transparent)

    # Storage for analysis and sheet
    expansion_order = sorted(expansions.keys())
    expansion_images: List[Tuple[int, Image.Image]] = []
    analysis_entries: List[Tuple[int, HeuristicResult]] = []

    for exp_id in expansion_order:
        flat = expansions[exp_id]
        # Apply mapping + shift
        flat = apply_mapping_and_shift(flat, mapping, cfg.ref_shift, stats)

        # Validate references
        out_of_range = False
        for r in flat:
            if r < 0 or r >= total_tiles:
                stats.invalid_references += 1
                out_of_range = True
        if out_of_range and cfg.strict_ids:
            sink.error(f"Expansion {exp_id} contains out-of-range tile reference(s).")
            continue  # Skip rendering in strict mode (counts as error)

        # Analysis
        # Reshape flat to 3x3 for analysis and rendering
        matrix = [flat[0:3], flat[3:6], flat[6:9]]
        heur_res = analyze_expansion(matrix, tile_types, cfg.max_types, cfg.no_heuristics)
        analysis_entries.append((exp_id, heur_res))
        stats.expansions_analyzed += 1
        if heur_res.problematic:
            stats.problematic_heuristics += 1

        # Render 3x3 image
        img = Image.new("RGBA", (3 * tile_w, 3 * tile_h))
        for r, row in enumerate(matrix):
            for c, tile_id in enumerate(row):
                if tile_id < 0 or tile_id >= total_tiles:
                    tile_img = placeholder
                    stats.placeholders_used += 1
                else:
                    tile_img = get_tile_crop(tileset_img, tile_id, tile_w, tile_h, columns)
                img.paste(tile_img, (c * tile_w, r * tile_h))
        if cfg.include_meta_in_sheet:
            embed_label(img, str(exp_id))

        # Save individual
        if not cfg.no_individual:
            out_path = os.path.join(cfg.output_dir, f"expansion_{exp_id:03d}.{cfg.image_format}")
            try:
                img.save(out_path)
            except OSError as e:
                sink.warn(f"Failed to save expansion {exp_id} to {out_path}: {e}")
            else:
                stats.expansions_rendered += 1

        expansion_images.append((exp_id, img))

    # Write analysis
    if cfg.analysis_output:
        try:
            with open(cfg.analysis_output, "w", encoding="utf-8") as f:
                f.write("EXPANSION ANALYSIS REPORT\n")
                f.write("=" * 60 + "\n\n")
                for exp_id, heur in analysis_entries:
                    marker = "PROBLEMATIC" if heur.problematic else "OK"
                    f.write(f"{marker} Expansion {exp_id}\n")
                    f.write(f"  Tile IDs: {heur.tile_ids}\n")
                    f.write(f"  Unique tiles: {heur.unique_tiles}\n")
                    f.write(f"  Type counts: {heur.type_counts}\n")
                    if heur.issues:
                        f.write(f"  Issues: {', '.join(heur.issues)}\n")
                    # Show names
                    # (We don't have tile_names passed here; optional extension)
                    f.write("\n")
                # Summary
                f.write("SUMMARY\n")
                f.write("-" * 60 + "\n")
                f.write(f"Total expansions analyzed: {stats.expansions_analyzed}\n")
                f.write(f"Problematic (heuristics): {stats.problematic_heuristics}\n")
                f.write(f"Invalid refs: {stats.invalid_references}\n")
                f.write(f"Placeholders used: {stats.placeholders_used}\n")
        except OSError as e:
            sink.warn(f"Failed to write analysis file '{cfg.analysis_output}': {e}")

    # Build sheet
    if not cfg.no_sheet and expansion_images:
        sheet_cols = max(1, cfg.sheet_cols)
        total = len(expansion_images)
        rows = math.ceil(total / sheet_cols)
        if cfg.sheet_max_rows is not None:
            rows = min(rows, cfg.sheet_max_rows)
            total = min(total, rows * sheet_cols)
            expansion_images = expansion_images[:total]

        cell_w = 3 * tile_w
        cell_h = 3 * tile_h
        bw = cfg.tile_border

        sheet_w = sheet_cols * cell_w + (sheet_cols - 1) * bw
        sheet_h = rows * cell_h + (rows - 1) * bw
        sheet = Image.new("RGBA", (sheet_w, sheet_h), (0, 0, 0, 0))

        for idx, (exp_id, img) in enumerate(expansion_images):
            row = idx // sheet_cols
            col = idx % sheet_cols
            if row >= rows:
                break
            x = col * (cell_w + bw)
            y = row * (cell_h + bw)
            sheet.paste(img, (x, y))

        if cfg.sheet_output:
            try:
                sheet.save(cfg.sheet_output)
                log(f"Saved sprite sheet: {cfg.sheet_output}", cfg)
            except OSError as e:
                sink.warn(f"Failed to save sheet '{cfg.sheet_output}': {e}")
        else:
            # If not provided, auto name in output_dir
            if not cfg.no_individual:
                sheet_path = os.path.join(cfg.output_dir, f"expansion_sheet.{cfg.image_format}")
                try:
                    sheet.save(sheet_path)
                    log(f"Saved sprite sheet: {sheet_path}", cfg)
                except OSError as e:
                    sink.warn(f"Failed to save sheet '{sheet_path}': {e}")

    sink.flush()

    # Summary
    log("", cfg)
    log("SUMMARY:", cfg)
    log(f"  Expansions (input)      : {stats.expansions_total}", cfg)
    log(f"  Expansions analyzed     : {stats.expansions_analyzed}", cfg)
    log(f"  Expansions rendered     : {stats.expansions_rendered}", cfg)
    log(f"  Problematic heuristics  : {stats.problematic_heuristics}", cfg)
    log(f"  Invalid references      : {stats.invalid_references}", cfg)
    log(f"  Placeholders used       : {stats.placeholders_used}", cfg)
    log(f"  Mapped references       : {stats.mapped_refs}", cfg)
    log(f"  Shifted references      : {stats.shifted_refs}", cfg)
    log(f"  Warnings                : {stats.warnings}", cfg)
    log(f"  Errors                  : {stats.errors}", cfg)

    if stats.errors > 0:
        return 1
    if cfg.strict_ids and stats.invalid_references > 0:
        return 1
    if cfg.fail_on_warning and stats.warnings > 0:
        return 1
    return 0


# ---------------------------------------------------------------------------
# Entry Point
# ---------------------------------------------------------------------------

def main():
    cfg = parse_args()
    try:
        return generate(cfg)
    except KeyboardInterrupt:
        print("\nInterrupted.", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
