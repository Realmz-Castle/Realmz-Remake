#!/usr/bin/env python3
"""
tileset_txt_to_json.py
======================

Purpose:
    Convert the legacy Realmz-style tileset text file (e.g. tileset_outdoor.txt) into a structured
    JSON format that downstream tooling (preview generators, editors, etc.) can consume.

Key Concepts (Original File Layout Assumptions):
    The legacy file contains (at minimum) the following pipe-delimited columns (based on prior analysis):
        0: HEX tile ID (ignored by default)
        1: DEC tile ID (authoritative logical ID)
        ...
       12: HEX 3x3 expansion (ignored by default)
       13: DEC 3x3 expansion (authoritative expansion reference IDs)
    Lines may contain separators (===...), blank lines, or other noise after the header.

    A header line containing the substring "ID |  ID |" is used to detect the start of data.

Default Behavior:
    - Uses decimal ID column index 1 as the source tile ID (skips row where that value == 0).
    - Applies a default key shift of -1 (legacy compatibility) so that source ID 1 -> JSON key "0".
    - Uses decimal expansion column index 13; expects exactly 9 integers split by whitespace.
    - Leaves expansion reference numbers unchanged (no shift) unless mapping / ref-shift options are applied.
    - Outputs a JSON object containing:
        {
          "meta": { ... contextual info ... },
          "tiles": {
              "0": [[a,b,c],[d,e,f],[g,h,i]],
              ...
          }
        }
      You can suppress the "meta" object via --no-meta.

Advanced Features:
    - --id-shift N           : shift applied to non-zero source tile IDs when forming JSON keys.
    - --ref-shift N          : uniform shift applied to each expansion reference AFTER mapping (if any).
    - --ref-map path.json    : JSON file mapping original reference IDs -> new IDs (applied before ref-shift).
                               Shape: { "60": 58, "155": 154, ... } (keys may be str or int).
    - --validate-range MIN MAX : ensure every expansion reference (post mapping & shifting) lies in [MIN, MAX].
    - --no-skip-zero         : do NOT skip the placeholder ID 0 row (default is to skip).
    - --strict               : treat parsing/validation issues as fatal (non-zero exit).
    - --warn-file path       : also write warnings to specified file.
    - --no-meta              : omit meta block.
    - --raw-output           : output only the tiles dict (no meta, overrides --no-meta).
    - --id-col N             : override the ID column index (default 1).
    - --exp-col N            : override the expansion column index (default 13).
    - --hex-expansion        : interpret expansion column as hex values (instead of decimal).
    - --indent N             : indentation for JSON output (default 2).
    - --no-sort              : preserve insertion order of parsed tiles (default sorts by key).
    - --limit N              : only parse first N data rows (post-header) for debugging.
    - --echo-config          : print resolved configuration before processing.
    - --quiet                : minimize stdout (only critical errors if any).

Warnings & Validation:
    The script will collect warnings (e.g., malformed lines, invalid token counts, out-of-range references)
    and either:
      * Print them (default)
      * Also write them to a warning file (--warn-file)
      * Fail if --strict

Exit Codes:
    0 on success; 1 on fatal error (e.g., file not found, parse failure under --strict).

Example Usage:
    Basic (legacy-compatible):
        python3 tileset_txt_to_json.py -i tileset_outdoor.txt -o tileset_outdoor.json

    Apply per-key shift +2 and shift all references by -1:
        python3 tileset_txt_to_json.py --id-shift 2 --ref-shift -1 -i tileset_outdoor.txt -o out.json

    Apply a mapping file and validate reference range:
        python3 tileset_txt_to_json.py --ref-map mapping.json --validate-range 0 239 -i tileset_outdoor.txt -o mapped.json

    Output only tiles dict (no meta):
        python3 tileset_txt_to_json.py --raw-output -i tileset_outdoor.txt -o tiles_only.json

Mapping File Format (mapping.json):
    {
        "60": 58,
        "61": 59,
        "155": 152
    }

    Keys can be strings or integers; values must be integers.

Safety Checks:
    - Ensures expansion tokens count == 9.
    - Optionally ensures all references are within a specified inclusive range.
    - Gracefully handles unexpected lines.
"""

from __future__ import annotations
import argparse
import json
import sys
from dataclasses import dataclass, asdict
from typing import Dict, List, Tuple, Optional, Iterable


# ---------------------------------------------------------------------------
# Data Classes
# ---------------------------------------------------------------------------

@dataclass
class Config:
    input_path: str
    output_path: str
    id_col: int
    exp_col: int
    skip_zero: bool
    id_shift: int
    ref_shift: int
    hex_expansion: bool
    map_path: Optional[str]
    validate_range: Optional[Tuple[int, int]]
    strict: bool
    no_sort: bool
    indent: int
    limit_rows: Optional[int]
    quiet: bool
    warn_file: Optional[str]


@dataclass
class ParseStats:
    lines_total: int = 0
    data_rows_processed: int = 0
    tiles_written: int = 0
    warnings: int = 0
    errors: int = 0
    skipped_zero: int = 0
    skipped_malformed: int = 0
    mapped_refs: int = 0
    shifted_refs: int = 0
    out_of_range_refs: int = 0


# ---------------------------------------------------------------------------
# Argument Parsing
# ---------------------------------------------------------------------------

def parse_args(argv: Optional[Iterable[str]] = None) -> Config:
    p = argparse.ArgumentParser(
        description="Convert legacy tileset text file into JSON with robust options."
    )
    p.add_argument("-i", "--input", dest="input_path", required=True,
                   help="Input legacy tileset text file.")
    p.add_argument("-o", "--output", dest="output_path", required=True,
                   help="Output JSON file.")
    p.add_argument("--id-col", type=int, default=1,
                   help="Zero-based column index for decimal ID (default 1).")
    p.add_argument("--exp-col", type=int, default=13,
                   help="Zero-based column index for expansion data (default 13).")
    p.add_argument("--no-skip-zero", action="store_true",
                   help="Do not skip ID 0 row (default skips).")
    p.add_argument("--id-shift", type=int, default=-1,
                   help="Shift applied to each non-zero source ID to form JSON key (default -1).")
    p.add_argument("--ref-shift", type=int, default=0,
                   help="Shift applied to each expansion reference AFTER mapping (default 0).")
    p.add_argument("--hex-expansion", action="store_true",
                   help="Treat expansion column values as hex (default decimal).")
    p.add_argument("--ref-map", dest="map_path",
                   help="JSON file mapping expansion reference IDs (before ref-shift).")
    p.add_argument("--validate-range", nargs=2, type=int, metavar=("MIN", "MAX"),
                   help="Require all final expansion references to be within [MIN, MAX].")
    p.add_argument("--strict", action="store_true",
                   help="Fail on any parsing/validation error or warning.")
    p.add_argument("--no-sort", action="store_true",
                   help="Do not sort keys in output JSON.")
    p.add_argument("--indent", type=int, default=2,
                   help="Indentation for JSON output (default 2).")
    p.add_argument("--limit", type=int, dest="limit_rows",
                   help="Only parse the first N data (tile) rows after header.")
    p.add_argument("--quiet", action="store_true",
                   help="Reduce stdout output to essential messages.")
    p.add_argument("--warn-file", dest="warn_file",
                   help="Also write warnings to this file path.")
    args = p.parse_args(argv)

    return Config(
        input_path=args.input_path,
        output_path=args.output_path,
        id_col=args.id_col,
        exp_col=args.exp_col,
        skip_zero=not args.no_skip_zero,
        id_shift=args.id_shift,
        ref_shift=args.ref_shift,
        hex_expansion=args.hex_expansion,
        map_path=args.map_path,
        validate_range=tuple(args.validate_range) if args.validate_range else None,
        strict=args.strict,
        no_sort=args.no_sort,
        indent=args.indent,
        limit_rows=args.limit_rows,
        quiet=args.quiet,
        warn_file=args.warn_file
    )


# ---------------------------------------------------------------------------
# Utility Functions
# ---------------------------------------------------------------------------

def log(msg: str, cfg: Config):
    if not cfg.quiet:
        print(msg)


def load_lines(path: str) -> List[str]:
    try:
        with open(path, "r", encoding="utf-8") as f:
            return f.readlines()
    except FileNotFoundError:
        print(f"FATAL: Input file '{path}' not found.", file=sys.stderr)
        sys.exit(1)
    except OSError as e:
        print(f"FATAL: Unable to read '{path}': {e}", file=sys.stderr)
        sys.exit(1)


def find_header_index(lines: List[str]) -> int:
    """
    Find the index of the header line containing the pattern 'ID |  ID |'.
    Returns -1 if not found.
    """
    for i, line in enumerate(lines):
        if "ID |  ID |" in line:
            return i
    return -1


def parse_int(value: str, hex_mode: bool, warn: callable, ctx: str) -> Optional[int]:
    val = value.strip()
    if not val:
        warn(f"Empty numeric token in {ctx}")
        return None
    base = 16 if hex_mode else 10
    try:
        return int(val, base=base)
    except ValueError:
        warn(f"Non-integer token '{val}' in {ctx}")
        return None


def load_mapping(path: str, warn: callable) -> Dict[int, int]:
    try:
        with open(path, "r", encoding="utf-8") as f:
            raw = json.load(f)
    except FileNotFoundError:
        print(f"FATAL: Mapping file '{path}' not found.", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"FATAL: Mapping file '{path}' invalid JSON: {e}", file=sys.stderr)
        sys.exit(1)
    except OSError as e:
        print(f"FATAL: Unable to read mapping file '{path}': {e}", file=sys.stderr)
        sys.exit(1)

    mapping: Dict[int, int] = {}
    for k, v in raw.items():
        if v is None:
            # Skip null values; these tiles do not exist in the remake and should not be mapped
            continue
        try:
            ki = int(k)
            vi = int(v)
        except (ValueError, TypeError):
            warn(f"Ignoring invalid mapping entry k={k!r} v={v!r}")
            continue
        mapping[ki] = vi
    return mapping


# ---------------------------------------------------------------------------
# Core Parsing Logic
# ---------------------------------------------------------------------------

def process(
    cfg: Config,
    lines: List[str],
    stats: ParseStats,
    warn: callable,
    map_ref: Optional[Dict[int, int]]
) -> Dict[int, List[List[int]]]:
    """
    Parse lines and produce dict of shifted_id -> 3x3 expansion matrix (after mapping & shifting references).
    If a mapping is provided, output remake keys and remake values only, skipping any tile or reference without a mapping.
    """
    header_index = find_header_index(lines)
    if header_index < 0:
        warn("Header line not found (searching for 'ID |  ID |').")
        if cfg.strict:
            stats.errors += 1
            return {}
        # Attempt to proceed from first line
        header_index = -1

    result: Dict[int, List[List[int]]] = {}
    stats.lines_total = len(lines)
    data_lines = lines[header_index + 1:]

    for row_index, raw_line in enumerate(data_lines, start=header_index + 2):
        if cfg.limit_rows is not None and stats.data_rows_processed >= cfg.limit_rows:
            break

        stripped = raw_line.strip()
        if not stripped:
            continue
        if stripped.startswith("="):
            continue

        # Split by pipe. Keep original to preserve alignment issues.
        parts = [p.rstrip().strip() for p in raw_line.split("|")]
        # Basic sanity: require (id_col, exp_col) indices to exist
        if len(parts) <= max(cfg.id_col, cfg.exp_col):
            warn(f"Line {row_index}: insufficient columns ({len(parts)}), needed at least {max(cfg.id_col, cfg.exp_col)+1}")
            stats.skipped_malformed += 1
            if cfg.strict:
                stats.errors += 1
            continue

        id_token = parts[cfg.id_col]
        if not id_token.isdigit():
            warn(f"Line {row_index}: non-decimal ID token '{id_token}' in column {cfg.id_col}")
            stats.skipped_malformed += 1
            if cfg.strict:
                stats.errors += 1
            continue
        src_id = int(id_token)

        if src_id == 0 and cfg.skip_zero:
            stats.skipped_zero += 1
            continue

        # Use src_id directly as the key for mapping or output
        if map_ref is not None:
            if src_id not in map_ref or map_ref[src_id] is None:
                continue
            remake_key = map_ref[src_id]
        else:
            remake_key = src_id

        # Parse expansion
        expansion_col = parts[cfg.exp_col].strip()
        if not expansion_col:
            warn(f"Line {row_index}: missing expansion column {cfg.exp_col}")
            stats.skipped_malformed += 1
            if cfg.strict:
                stats.errors += 1
            continue

        tokens = expansion_col.split()
        if len(tokens) != 9:
            warn(f"Line {row_index}: expansion requires 9 tokens, found {len(tokens)}")
            stats.skipped_malformed += 1
            if cfg.strict:
                stats.errors += 1
            continue

        raw_refs: List[int] = []
        token_fail = False
        for t in tokens:
            val = parse_int(t, cfg.hex_expansion, warn, f"expansion row {row_index}")
            if val is None:
                token_fail = True
                break
            raw_refs.append(val)
        if token_fail:
            stats.skipped_malformed += 1
            if cfg.strict:
                stats.errors += 1
            continue

        # Apply mapping to expansion references if mapping is provided
        # For each row in the 3x3, only include mapped remake IDs, skipping unmapped
        # Remap all references, skip tile if any reference can't be mapped
        mapped_refs_matrix: List[List[int]] = []
        if map_ref is not None:
            all_mapped = True
            remapped_flat: List[int] = []
            for r in raw_refs:
                if r in map_ref and map_ref[r] is not None:
                    remapped_flat.append(map_ref[r])
                else:
                    warn(f"Line {row_index}: reference {r} in expansion for src_id={src_id} could not be mapped; skipping entire tile.")
                    all_mapped = False
                    break
            if not all_mapped:
                stats.skipped_malformed += 1
                if cfg.strict:
                    stats.errors += 1
                continue
            mapped_refs_matrix = [
                remapped_flat[0:3],
                remapped_flat[3:6],
                remapped_flat[6:9]
            ]
        else:
            mapped_refs_matrix = [
                raw_refs[0:3],
                raw_refs[3:6],
                raw_refs[6:9]
            ]

        # Apply reference shift
        if cfg.ref_shift != 0:
            mapped_refs = [r + cfg.ref_shift for r in mapped_refs]
            stats.shifted_refs += len(mapped_refs)

        # Range validation
        if cfg.validate_range:
            mn, mx = cfg.validate_range
            for r in mapped_refs:
                if not (mn <= r <= mx):
                    stats.out_of_range_refs += 1
                    warn(f"Line {row_index}: reference {r} out of range [{mn},{mx}] (src_id={src_id})")

        # Build 3x3 matrix from mapped_refs_matrix
        result[remake_key] = mapped_refs_matrix
        stats.tiles_written += 1
        stats.data_rows_processed += 1

    return result


# ---------------------------------------------------------------------------
# Output Assembly
# ---------------------------------------------------------------------------

def build_output_json(cfg: Config, stats: ParseStats, tiles: Dict[int, List[List[int]]]) -> dict:
    # Always output only the tiles object, sorted if requested
    return {str(k): v for k, v in (tiles.items() if cfg.no_sort else sorted(tiles.items()))}


# ---------------------------------------------------------------------------
# Warning Aggregator
# ---------------------------------------------------------------------------

class WarningSink:
    def __init__(self, cfg: Config, stats: ParseStats):
        self._cfg = cfg
        self._stats = stats
        self._messages: List[str] = []

    def warn(self, msg: str):
        self._messages.append(msg)
        self._stats.warnings += 1
        if not self._cfg.quiet:
            print(f"[WARN] {msg}", file=sys.stderr)

    def flush_to_file(self):
        if self._cfg.warn_file and self._messages:
            try:
                with open(self._cfg.warn_file, "w", encoding="utf-8") as f:
                    for m in self._messages:
                        f.write(m + "\n")
            except OSError as e:
                print(f"FATAL: Could not write warning file '{self._cfg.warn_file}': {e}", file=sys.stderr)
                return False
        return True


# ---------------------------------------------------------------------------
# Main Entry
# ---------------------------------------------------------------------------

def main(argv: Optional[Iterable[str]] = None) -> int:
    cfg = parse_args(argv)
    stats = ParseStats()
    sink = WarningSink(cfg, stats)

    # Print config if requested
    # (echo_config removed)

    # Load input lines
    lines = load_lines(cfg.input_path)

    # Load mapping if provided
    mapping = None
    if cfg.map_path:
        mapping = load_mapping(cfg.map_path, sink.warn)
        log(f"Loaded {len(mapping)} reference remap entries from {cfg.map_path}", cfg)

    tiles = process(cfg, lines, stats, sink.warn, mapping)

    # Summarize
    log(f"Parsed data rows: {stats.data_rows_processed}", cfg)
    log(f"Tiles written: {stats.tiles_written}", cfg)
    if mapping:
        log(f"References remapped: {stats.mapped_refs}", cfg)
    if cfg.ref_shift != 0:
        log(f"References shifted: {stats.shifted_refs}", cfg)
    if cfg.validate_range:
        log(f"Out-of-range refs: {stats.out_of_range_refs}", cfg)
    log(f"Warnings: {stats.warnings}  Errors: {stats.errors}", cfg)

    # Strict mode decisions
    if cfg.strict and (stats.errors > 0 or stats.warnings > 0 or stats.out_of_range_refs > 0):
        print("STRICT MODE: Aborting due to warnings/errors.", file=sys.stderr)

    out_obj = build_output_json(cfg, stats, tiles)

    # Attempt write
    try:
        with open(cfg.output_path, "w", encoding="utf-8") as f:
            json.dump(out_obj, f, indent=cfg.indent)
            f.write("\n")
    except OSError as e:
        print(f"FATAL: Unable to write output file '{cfg.output_path}': {e}", file=sys.stderr)
        return 1

    sink.flush_to_file()

    if cfg.strict and (stats.errors > 0 or stats.warnings > 0 or stats.out_of_range_refs > 0):
        return 1

    if not cfg.quiet:
        print(f"SUCCESS: Wrote {stats.tiles_written} tiles to {cfg.output_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
