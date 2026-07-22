"""Scaffold thin native resources for audited Classic direct-damage spells."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Any

import audit_classic_spell_parity as audit


def _slug(value: str) -> str:
    return re.sub(r"[^a-z0-9]+", "_", value.casefold()).strip("_")


def _script_source(spell_id: int, display_name: str) -> str:
    escaped_name = display_name.replace("\\", "\\\\").replace('"', '\\"')
    return (
        'extends "res://scripts/classic_runtime/classic_core_damage_spell.gd"\n'
        "\n\n"
        "func _init() -> void:\n"
        f'\tname = "{escaped_name}"\n'
        f"\tclassic_spell_ids = [{spell_id}]\n"
        f"\tconfigure_core_damage_spell({spell_id})\n"
    )


def build_scaffold(
    inventory_document: dict[str, Any], report: dict[str, Any]
) -> tuple[dict[str, Any], dict[str, str]]:
    inventory_by_id = {
        int(spell["packedSpellId"]): spell
        for spell in inventory_document.get("spells", [])
        if isinstance(spell, dict)
    }
    rows = [
        row
        for row in report.get("spells", [])
        if row.get("implementationLane") == "direct-damage"
        and (
            row.get("supportStatus") != "supported"
            or row.get("classification") == "native-parameterized-damage"
        )
    ]
    rows.sort(key=lambda row: int(row["classicSpellId"]))
    scripts: dict[str, str] = {}
    entries: list[dict[str, Any]] = []
    for row in rows:
        spell_id = int(row["classicSpellId"])
        inventory = inventory_by_id[spell_id]
        display_name = str(inventory["displayName"])
        file_name = f"classic_core_{spell_id}_{_slug(display_name)}.gd"
        resource_path = f"res://shared_assets/spells/{file_name}"
        scripts[file_name] = _script_source(spell_id, display_name)
        entries.append(
            {
                "classicSpellId": spell_id,
                "displayName": display_name,
                "implementationLane": "direct-damage",
                "resource": resource_path,
                "sourceRecord": inventory.get("sourceRecord", {}),
                "matrixDraft": {
                    "classicSpellId": spell_id,
                    "displayName": display_name,
                    "classification": "native-parameterized-damage",
                    "supportStatus": "review-required",
                    "resource": resource_path,
                    "sourceRecord": inventory.get("sourceRecord", {}),
                },
            }
        )
    return (
        {
            "schemaVersion": 1,
            "generator": "asset_scripts/scaffold_classic_damage_spells.py",
            "implementationLane": "direct-damage",
            "count": len(entries),
            "entries": entries,
        },
        scripts,
    )


def write_scaffold(output_directory: Path, manifest: dict[str, Any], scripts: dict[str, str]) -> None:
    output_directory.mkdir(parents=True, exist_ok=True)
    for file_name, source in sorted(scripts.items()):
        (output_directory / file_name).write_text(source, encoding="utf-8", newline="\n")
    (output_directory / "review-manifest.json").write_text(
        json.dumps(manifest, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
        newline="\n",
    )


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Scaffold the audited Classic immediate-damage spell family."
    )
    repo_root = Path(__file__).resolve().parents[1]
    parser.add_argument("--repo-root", type=Path, default=repo_root)
    parser.add_argument("--output-directory", type=Path)
    return parser


def main(argv: list[str] | None = None) -> int:
    args = _parser().parse_args(argv)
    repo_root = args.repo_root.resolve()
    inventory_path = repo_root / "src/scripts/classic_runtime/classic_core_spell_inventory.json"
    matrix_path = repo_root / "src/scripts/classic_runtime/classic_spell_support_matrix.json"
    native_directory = repo_root / "src/shared_assets/spells"
    legacy_directory = repo_root / "asset_scripts/spell_scripts"
    inventory = audit._load_json(inventory_path)
    report = audit.build_report(
        inventory,
        audit._load_json(matrix_path),
        audit.read_native_resources(native_directory, repo_root),
        audit.read_legacy_scripts(legacy_directory, repo_root),
    )
    if report["validationErrors"]:
        for error in report["validationErrors"]:
            print(f"ERROR: {error}")
        return 1
    manifest, scripts = build_scaffold(inventory, report)
    output_directory = (
        args.output_directory or repo_root / "tmp/classic-damage-spell-scaffold"
    ).resolve()
    write_scaffold(output_directory, manifest, scripts)
    print(f"Scaffolded {manifest['count']} direct-damage spells in {output_directory}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
