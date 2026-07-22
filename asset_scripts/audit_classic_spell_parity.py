"""Build a deterministic audit of Classic player-spell parity.

The decoded Data S inventory is authoritative. Existing native and legacy
GDScript files are evidence for review, not proof that a spell is supported.
"""

from __future__ import annotations

import argparse
import ast
import hashlib
import json
import re
from collections import defaultdict
from pathlib import Path
from typing import Any, Iterable


SCHEMA_VERSION = 1

MECHANIC_FIELDS = (
    "range1",
    "range2",
    "toHitBonus",
    "saveBonus",
    "fixedTargetNum",
    "canRotate",
    "saveAdjust",
    "cannot",
    "resistAdjust",
    "cost",
    "damage1",
    "damage2",
    "powerDamage1",
    "powerDamage2",
    "duration1",
    "duration2",
    "powerDuration1",
    "powerDuration2",
    "targetType",
    "size",
    "special",
    "damageType",
    "spellClass",
    "inCombat",
    "inCamp",
)

PRESENTATION_FIELDS = (
    "queueIcon",
    "spellLook1",
    "spellLook2",
    "sound1",
    "sound2",
)

LEGACY_FUNCTION_HINTS = {
    "rangeAtPower1": "get_range",
    "spellPointCostAtPower1": "get_sp_cost",
    "minimumDamageAtPower1": "get_min_damage",
    "maximumDamageAtPower1": "get_max_damage",
    "minimumDurationAtPower1": "get_min_duration",
    "maximumDurationAtPower1": "get_max_duration",
}

ROMAN_SUFFIX = re.compile(r"\s+(?:I|II|III|IV|V|VI|VII|VIII|IX|X)$", re.IGNORECASE)


def _load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as source:
        value = json.load(source)
    if not isinstance(value, dict):
        raise ValueError(f"Expected a JSON object in {path}")
    return value


def _relative_path(path: Path, repo_root: Path) -> str:
    try:
        return path.resolve().relative_to(repo_root.resolve()).as_posix()
    except ValueError:
        return path.resolve().as_posix()


def _canonical_json(value: Any) -> str:
    return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False)


def _mechanic_signature(spell: dict[str, Any]) -> dict[str, int]:
    record = spell.get("record", {})
    return {field: int(record.get(field, 0)) for field in MECHANIC_FIELDS}


def _presentation_signature(spell: dict[str, Any]) -> dict[str, int]:
    record = spell.get("record", {})
    return {field: int(record.get(field, 0)) for field in PRESENTATION_FIELDS}


def mechanic_family_id(spell: dict[str, Any]) -> str:
    digest = hashlib.sha256(_canonical_json(_mechanic_signature(spell)).encode()).hexdigest()
    return f"mechanics-{digest[:12]}"


def _normal_name(value: str) -> str:
    return re.sub(r"[^a-z0-9]+", "", value.casefold())


def _base_name(value: str) -> str:
    return _normal_name(ROMAN_SUFFIX.sub("", value.strip()))


def _parse_int_list(value: str) -> list[int]:
    result: list[int] = []
    for item in value.split(","):
        item = item.strip()
        if re.fullmatch(r"-?\d+", item):
            result.append(int(item))
    return result


def read_native_resources(native_directory: Path, repo_root: Path) -> list[dict[str, Any]]:
    resources: list[dict[str, Any]] = []
    if not native_directory.is_dir():
        return resources
    for path in sorted(native_directory.glob("*.gd"), key=lambda entry: entry.name.casefold()):
        source = path.read_text(encoding="utf-8")
        id_matches = re.findall(r"(?m)^\s*classic_spell_ids\s*=\s*\[([^\]]*)\]", source)
        name_matches = re.findall(r"(?m)^\s*name\s*=\s*([\"'])(.*?)\1", source)
        extends_match = re.search(r"(?m)^\s*extends\s+([^\r\n]+)", source)
        resources.append(
            {
                "path": _relative_path(path, repo_root),
                "name": name_matches[-1][1] if name_matches else "",
                "classicSpellIds": _parse_int_list(id_matches[-1]) if id_matches else [],
                "extends": extends_match.group(1).strip() if extends_match else "",
            }
        )
    return resources


def _safe_integer_expression(expression: str, power: int = 1) -> int | None:
    expression = re.sub(r"\b_?power\b", str(power), expression.strip())
    try:
        tree = ast.parse(expression, mode="eval")
    except SyntaxError:
        return None

    def evaluate(node: ast.AST) -> int:
        if isinstance(node, ast.Expression):
            return evaluate(node.body)
        if isinstance(node, ast.Constant) and isinstance(node.value, int):
            return int(node.value)
        if isinstance(node, ast.UnaryOp) and isinstance(node.op, (ast.UAdd, ast.USub)):
            value = evaluate(node.operand)
            return value if isinstance(node.op, ast.UAdd) else -value
        if isinstance(node, ast.BinOp) and isinstance(
            node.op, (ast.Add, ast.Sub, ast.Mult, ast.FloorDiv, ast.Mod)
        ):
            left = evaluate(node.left)
            right = evaluate(node.right)
            if isinstance(node.op, ast.Add):
                return left + right
            if isinstance(node.op, ast.Sub):
                return left - right
            if isinstance(node.op, ast.Mult):
                return left * right
            if isinstance(node.op, ast.FloorDiv):
                return left // right
            return left % right
        if (
            isinstance(node, ast.Call)
            and isinstance(node.func, ast.Name)
            and node.func.id == "abs"
            and len(node.args) == 1
        ):
            return abs(evaluate(node.args[0]))
        raise ValueError

    try:
        return evaluate(tree)
    except (ValueError, ZeroDivisionError):
        return None


def _function_return_hint(source: str, function_name: str) -> dict[str, Any] | None:
    match = re.search(
        rf"(?ms)^\s*(?:static\s+)?func\s+{re.escape(function_name)}\s*\([^\n]*\).*?:\s*\n"
        rf"(?P<body>.*?)(?=^\s*(?:static\s+)?func\s+|\Z)",
        source,
    )
    if not match:
        return None
    return_match = re.search(r"(?m)^\s*return\s+([^#\r\n]+)", match.group("body"))
    if not return_match:
        return None
    expression = return_match.group(1).strip()
    value = _safe_integer_expression(expression)
    result: dict[str, Any] = {"expression": expression}
    if value is not None:
        result["valueAtPower1"] = value
    return result


def _parse_legacy_script(path: Path, repo_root: Path) -> dict[str, Any]:
    source = path.read_text(encoding="utf-8")
    name_match = re.search(r"(?m)^\s*var\s+name(?:\s*:\s*String)?\s*=\s*([\"'])(.*?)\1", source)
    filename_name = path.stem.split("--", 1)[-1]
    name = name_match.group(2) if name_match else filename_name
    hints: dict[str, Any] = {}
    for hint_name, function_name in LEGACY_FUNCTION_HINTS.items():
        hint = _function_return_hint(source, function_name)
        if hint is not None:
            hints[hint_name] = hint
    for hint_name, variable_name in (("inField", "in_field"), ("inCombat", "in_combat")):
        match = re.search(
            rf"(?mi)^\s*var\s+{variable_name}(?:\s*:\s*bool)?\s*=\s*(true|false)",
            source,
        )
        if match:
            hints[hint_name] = match.group(1).casefold() == "true"
    return {
        "path": _relative_path(path, repo_root),
        "name": name,
        "hints": hints,
    }


def read_legacy_scripts(legacy_directory: Path, repo_root: Path) -> list[dict[str, Any]]:
    if not legacy_directory.is_dir():
        return []
    return [
        _parse_legacy_script(path, repo_root)
        for path in sorted(legacy_directory.glob("*.gd"), key=lambda entry: entry.name.casefold())
    ]


def _classic_high(low: int, high: int) -> int:
    if high == 0 and low != 0:
        return low
    return max(low, high)


def _source_hints(spell: dict[str, Any]) -> dict[str, Any]:
    record = spell.get("record", {})
    damage_low = int(record.get("damage1", 0))
    power_damage_low = int(record.get("powerDamage1", 0))
    duration_low = int(record.get("duration1", 0))
    power_duration_low = int(record.get("powerDuration1", 0))
    return {
        "rangeAtPower1": abs(int(record.get("range1", 0)) + int(record.get("range2", 0))),
        "spellPointCostAtPower1": abs(int(record.get("cost", 0))),
        "minimumDamageAtPower1": damage_low + power_damage_low,
        "maximumDamageAtPower1": (
            _classic_high(damage_low, int(record.get("damage2", 0)))
            + _classic_high(power_damage_low, int(record.get("powerDamage2", 0)))
        ),
        "minimumDurationAtPower1": duration_low + power_duration_low,
        "maximumDurationAtPower1": (
            _classic_high(duration_low, int(record.get("duration2", 0)))
            + _classic_high(power_duration_low, int(record.get("powerDuration2", 0)))
        ),
        "inField": bool(record.get("inCamp", 0)),
        "inCombat": bool(record.get("inCombat", 0)),
    }


def generic_implementation_lane(spell: dict[str, Any]) -> str:
    """Return the narrow implementation lane for a source-generic record.

    A zero ``special`` byte only rules out the named opcode switch. Queued
    terrain, fixed-power field utilities, missiles, and records with no source
    effect still need different runtime treatment from immediate damage.
    """

    record = spell.get("record", {})
    if int(record.get("special", 0)) != 0:
        return "special-handler"
    if int(record.get("queueIcon", 0)) != 0:
        return "queued-area-engine-gap"
    if (
        int(record.get("cost", 0)) <= 0
        or int(record.get("targetType", 0)) in (7, 11)
        or not bool(record.get("inCombat", 0))
    ):
        return "field-utility-review"

    damage_fields = ("damage1", "damage2", "powerDamage1", "powerDamage2")
    if not any(int(record.get(field, 0)) != 0 for field in damage_fields):
        return "no-source-effect-review"
    if abs(int(record.get("spellClass", 0))) == 9:
        return "missile-specialization"

    duration_fields = (
        "duration1",
        "duration2",
        "powerDuration1",
        "powerDuration2",
    )
    if (
        abs(int(record.get("damageType", 0))) in range(1, 8)
        and not any(int(record.get(field, 0)) != 0 for field in duration_fields)
        and int(record.get("targetType", 0)) in (0, 1, 3, 4, 10)
    ):
        return "direct-damage"
    return "generic-mechanic-review"


def compare_legacy_hints(spell: dict[str, Any], legacy: dict[str, Any]) -> dict[str, Any]:
    expected = _source_hints(spell)
    compared: dict[str, dict[str, Any]] = {}
    for hint_name, hint in legacy.get("hints", {}).items():
        if hint_name not in expected:
            continue
        actual = hint.get("valueAtPower1") if isinstance(hint, dict) else hint
        if actual is None:
            continue
        compared[hint_name] = {
            "source": expected[hint_name],
            "legacy": actual,
            "matches": actual == expected[hint_name],
        }
    mismatches = sorted(name for name, values in compared.items() if not values["matches"])
    return {
        "status": (
            "unparsed"
            if not compared
            else "differs-from-source"
            if mismatches
            else "matches-parsed-fields"
        ),
        "comparedFields": compared,
        "mismatchedFields": mismatches,
    }


def _legacy_candidates(
    spell: dict[str, Any],
    exact_names: dict[str, list[dict[str, Any]]],
    base_names: dict[str, list[dict[str, Any]]],
) -> tuple[str, list[dict[str, Any]]]:
    display_name = str(spell.get("displayName", ""))
    candidates = exact_names.get(_normal_name(display_name), [])
    if candidates:
        return "exact-name", candidates
    candidates = base_names.get(_base_name(display_name), [])
    return ("base-name", candidates) if candidates else ("none", [])


def _coverage_status(
    spell: dict[str, Any], matrix_row: dict[str, Any], native_paths: list[str]
) -> str:
    support_status = str(matrix_row.get("supportStatus", "unclassified"))
    if support_status == "supported":
        return "supported" if native_paths else "support-resource-mismatch"
    if support_status != "unclassified":
        return "documented-gap"
    if native_paths:
        return "exact-resource-review"
    if str(spell.get("recordShape", "")) == "generic":
        return "generic-implementation-candidate"
    return "special-implementation-required"


def _native_path_for_matrix_resource(value: str) -> str:
    if value.startswith("res://"):
        return "src/" + value.removeprefix("res://")
    return value.replace("\\", "/")


def _family_action(family: dict[str, Any]) -> str:
    if not family["remainingSpellIds"]:
        return "complete"
    if family["supportedSpellIds"]:
        return "review-supported-family-extension"
    if family["recordShapes"] == ["generic"]:
        return "implement-generic-native-family"
    special_codes = family["specialCodes"]
    if len(special_codes) == 1:
        return f"review-special-handler-{special_codes[0]}"
    return "review-special-behavior-family"


def build_report(
    inventory_document: dict[str, Any],
    matrix_document: dict[str, Any],
    native_resources: list[dict[str, Any]],
    legacy_scripts: list[dict[str, Any]],
    inputs: dict[str, str] | None = None,
) -> dict[str, Any]:
    validation_errors: list[str] = []
    inventory_values = inventory_document.get("spells", [])
    matrix_values = matrix_document.get("spells", [])
    if not isinstance(inventory_values, list):
        raise ValueError("Inventory 'spells' must be an array")
    if not isinstance(matrix_values, list):
        raise ValueError("Support matrix 'spells' must be an array")

    matrix_by_id: dict[int, dict[str, Any]] = {}
    for value in matrix_values:
        if not isinstance(value, dict):
            continue
        spell_id = int(value.get("classicSpellId", 0))
        if spell_id in matrix_by_id:
            validation_errors.append(f"Duplicate support-matrix ID {spell_id}")
        else:
            matrix_by_id[spell_id] = value

    native_by_id: dict[int, list[str]] = defaultdict(list)
    native_by_name: dict[str, list[str]] = defaultdict(list)
    for resource in native_resources:
        path = str(resource.get("path", ""))
        for spell_id in resource.get("classicSpellIds", []):
            native_by_id[abs(int(spell_id))].append(path)
        name = str(resource.get("name", ""))
        if name:
            native_by_name[_normal_name(name)].append(path)

    legacy_exact_names: dict[str, list[dict[str, Any]]] = defaultdict(list)
    legacy_base_names: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for legacy in legacy_scripts:
        legacy_exact_names[_normal_name(str(legacy.get("name", "")))].append(legacy)
        legacy_base_names[_base_name(str(legacy.get("name", "")))].append(legacy)

    spell_rows: list[dict[str, Any]] = []
    families_by_id: dict[str, list[dict[str, Any]]] = defaultdict(list)
    seen_inventory_ids: set[int] = set()
    for value in inventory_values:
        if not isinstance(value, dict):
            continue
        spell_id = int(value.get("packedSpellId", 0))
        if spell_id in seen_inventory_ids:
            validation_errors.append(f"Duplicate inventory ID {spell_id}")
            continue
        seen_inventory_ids.add(spell_id)
        matrix_row = matrix_by_id.get(spell_id, {})
        native_paths = sorted(native_by_id.get(spell_id, []))
        support_status = str(matrix_row.get("supportStatus", "unclassified"))
        if len(native_paths) > 1:
            validation_errors.append(
                f"Classic spell ID {spell_id} is declared by multiple native resources: "
                + ", ".join(native_paths)
            )
        if support_status == "supported" and not native_paths:
            validation_errors.append(
                f"Supported Classic spell ID {spell_id} has no exact native resource"
            )
        matrix_resource = str(matrix_row.get("resource", ""))
        if support_status == "supported" and matrix_resource:
            expected_resource = _native_path_for_matrix_resource(matrix_resource)
            if expected_resource not in native_paths:
                validation_errors.append(
                    f"Supported Classic spell ID {spell_id} names {matrix_resource}, "
                    "but that resource does not declare the ID"
                )
        family_id = mechanic_family_id(value)
        legacy_match_mode, legacy_candidates = _legacy_candidates(
            value, legacy_exact_names, legacy_base_names
        )
        legacy_rows = []
        for legacy in legacy_candidates:
            legacy_rows.append(
                {
                    "path": legacy["path"],
                    "name": legacy["name"],
                    "matchMode": legacy_match_mode,
                    "hints": legacy.get("hints", {}),
                    "comparison": compare_legacy_hints(value, legacy),
                }
            )
        row = {
            "classicSpellId": spell_id,
            "displayName": str(value.get("displayName", "")),
            "casterClass": str(value.get("casterClass", "")),
            "level": int(value.get("level", 0)),
            "slot": int(value.get("slot", 0)),
            "recordShape": str(value.get("recordShape", "")),
            "special": int(value.get("record", {}).get("special", 0)),
            "sourceRecord": value.get("sourceRecord", {}),
            "mechanicFamilyId": family_id,
            "supportStatus": support_status,
            "classification": str(matrix_row.get("classification", "unclassified")),
            "coverageStatus": _coverage_status(value, matrix_row, native_paths),
            "implementationLane": generic_implementation_lane(value),
            "nativeExactResources": native_paths,
            "nativeNameCandidates": sorted(
                native_by_name.get(_normal_name(str(value.get("displayName", ""))), [])
            ),
            "legacyScripts": legacy_rows,
        }
        if matrix_resource:
            row["matrixResource"] = matrix_resource
        spell_rows.append(row)
        families_by_id[family_id].append({"inventory": value, "row": row})

    family_rows: list[dict[str, Any]] = []
    for family_id, entries in families_by_id.items():
        entries.sort(key=lambda entry: entry["row"]["classicSpellId"])
        supported_ids = [
            entry["row"]["classicSpellId"]
            for entry in entries
            if entry["row"]["supportStatus"] == "supported"
        ]
        remaining_ids = [
            entry["row"]["classicSpellId"]
            for entry in entries
            if entry["row"]["supportStatus"] != "supported"
        ]
        presentations = {
            _canonical_json(_presentation_signature(entry["inventory"])) for entry in entries
        }
        family = {
            "familyId": family_id,
            "count": len(entries),
            "spellIds": [entry["row"]["classicSpellId"] for entry in entries],
            "supportedSpellIds": supported_ids,
            "remainingSpellIds": remaining_ids,
            "displayNames": sorted({entry["row"]["displayName"] for entry in entries}),
            "recordShapes": sorted({entry["row"]["recordShape"] for entry in entries}),
            "specialCodes": sorted({entry["row"]["special"] for entry in entries}),
            "presentationVariants": len(presentations),
            "mechanics": _mechanic_signature(entries[0]["inventory"]),
        }
        family["recommendedAction"] = _family_action(family)
        family_rows.append(family)
    family_rows.sort(key=lambda family: min(family["spellIds"]))

    remaining_rows = [row for row in spell_rows if row["supportStatus"] != "supported"]
    supported_by_special: dict[int, list[int]] = defaultdict(list)
    for row in spell_rows:
        if row["supportStatus"] == "supported" and int(row["special"]) != 0:
            supported_by_special[int(row["special"])].append(row["classicSpellId"])

    special_queue: dict[int, dict[str, Any]] = {}
    for row in remaining_rows:
        special = int(row["special"])
        if special == 0:
            continue
        bucket = special_queue.setdefault(
            special,
            {"special": special, "spellIds": [], "displayNames": set(), "familyIds": set()},
        )
        bucket["spellIds"].append(row["classicSpellId"])
        bucket["displayNames"].add(row["displayName"])
        bucket["familyIds"].add(row["mechanicFamilyId"])
    special_rows = []
    for special in sorted(special_queue):
        bucket = special_queue[special]
        special_rows.append(
            {
                "special": special,
                "count": len(bucket["spellIds"]),
                "familyCount": len(bucket["familyIds"]),
                "spellIds": sorted(bucket["spellIds"]),
                "displayNames": sorted(bucket["displayNames"]),
                "supportedExampleIds": sorted(supported_by_special.get(special, [])),
                "recommendedAction": (
                    "review-existing-special-handler"
                    if supported_by_special.get(special)
                    else "implement-special-handler"
                ),
            }
        )

    generic_rows = [row for row in remaining_rows if row["recordShape"] == "generic"]
    recommended_batches = []
    generic_lanes: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for row in generic_rows:
        generic_lanes[row["implementationLane"]].append(row)
    lane_actions = {
        "direct-damage": "implement-parameterized-native-family",
        "missile-specialization": "implement-missile-native-family",
        "no-source-effect-review": "verify-source-no-op-before-implementation",
        "queued-area-engine-gap": "implement-queued-area-runtime",
        "field-utility-review": "review-field-utility-family",
        "generic-mechanic-review": "review-generic-mechanics",
    }
    for lane, lane_rows in generic_lanes.items():
        recommended_batches.append(
            {
                "batchId": f"generic-{lane}",
                "kind": lane,
                "count": len(lane_rows),
                "familyCount": len({row["mechanicFamilyId"] for row in lane_rows}),
                "spellIds": sorted(row["classicSpellId"] for row in lane_rows),
                "displayNames": sorted({row["displayName"] for row in lane_rows}),
                "supportedExampleIds": [],
                "recommendedAction": lane_actions[lane],
            }
        )
    for special in special_rows:
        recommended_batches.append(
            {
                "batchId": f"special-{special['special']}",
                "kind": "special-handler",
                **special,
            }
        )
    recommended_batches.sort(key=lambda batch: (-batch["count"], batch["batchId"]))

    name_groups: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for row in remaining_rows:
        name_groups[_normal_name(row["displayName"])].append(row)
    duplicate_names = [
        {
            "displayName": sorted({row["displayName"] for row in rows})[0],
            "count": len(rows),
            "spellIds": sorted(row["classicSpellId"] for row in rows),
            "mechanicFamilyIds": sorted({row["mechanicFamilyId"] for row in rows}),
        }
        for rows in name_groups.values()
        if len(rows) > 1
    ]
    duplicate_names.sort(key=lambda group: (-group["count"], group["displayName"].casefold()))

    legacy_comparisons = [
        legacy["comparison"]["status"]
        for row in spell_rows
        for legacy in row["legacyScripts"]
    ]
    remaining_families = [family for family in family_rows if family["remainingSpellIds"]]
    family_extensions = [
        family
        for family in remaining_families
        if family["recommendedAction"] == "review-supported-family-extension"
    ]
    totals = {
        "identities": len(spell_rows),
        "supportedIdentities": sum(row["supportStatus"] == "supported" for row in spell_rows),
        "remainingIdentities": len(remaining_rows),
        "genericCandidates": sum(
            row["recordShape"] == "generic" for row in remaining_rows
        ),
        "genericImplementationLanes": {
            lane: len(rows) for lane, rows in sorted(generic_lanes.items())
        },
        "specialBehaviorCandidates": sum(
            row["recordShape"] != "generic" for row in remaining_rows
        ),
        "remainingSpecialCodes": len(special_rows),
        "specialCodesWithSupportedExamples": sum(
            bool(group["supportedExampleIds"]) for group in special_rows
        ),
        "mechanicFamilies": len(family_rows),
        "remainingMechanicFamilies": len(remaining_families),
        "remainingIdentitiesInSupportedFamilies": sum(
            len(family["remainingSpellIds"]) for family in family_extensions
        ),
        "supportedFamilyExtensions": len(family_extensions),
        "remainingDuplicateNameGroups": len(duplicate_names),
        "nativeResourceFiles": len(native_resources),
        "legacyScriptFiles": len(legacy_scripts),
        "legacyHintMatches": legacy_comparisons.count("matches-parsed-fields"),
        "legacyHintMismatches": legacy_comparisons.count("differs-from-source"),
        "validationErrors": len(validation_errors),
    }

    return {
        "schemaVersion": SCHEMA_VERSION,
        "inputs": inputs or {},
        "source": inventory_document.get("source", {}),
        "totals": totals,
        "validationErrors": sorted(validation_errors),
        "mechanicFamilies": family_rows,
        "recommendedBatches": recommended_batches,
        "specialBehaviorQueue": special_rows,
        "duplicateNameGroups": duplicate_names,
        "spells": sorted(spell_rows, key=lambda row: row["classicSpellId"]),
    }


def _ids(values: Iterable[int]) -> str:
    return ", ".join(str(value) for value in values)


def render_markdown(report: dict[str, Any]) -> str:
    totals = report["totals"]
    lines = [
        "# Classic spell parity audit",
        "",
        "This report treats decoded `Data S` records as authoritative. Native and legacy",
        "GDScript files are review evidence; neither can mark a spell supported without a",
        "curated support-matrix entry.",
        "",
        "## Summary",
        "",
        f"- Identities: {totals['identities']}",
        f"- Supported: {totals['supportedIdentities']}",
        f"- Remaining: {totals['remainingIdentities']}",
        f"- Generic candidates: {totals['genericCandidates']}",
        f"- Special-behavior candidates: {totals['specialBehaviorCandidates']}",
        f"- Remaining special codes: {totals['remainingSpecialCodes']}",
        (
            "- Special codes with a supported example: "
            f"{totals['specialCodesWithSupportedExamples']}"
        ),
        f"- Remaining mechanic families: {totals['remainingMechanicFamilies']}",
        (
            "- Remaining identities in an already-supported mechanic family: "
            f"{totals['remainingIdentitiesInSupportedFamilies']}"
        ),
        f"- Legacy hint mismatches: {totals['legacyHintMismatches']}",
        "",
        "## Recommended implementation batches",
        "",
    ]
    lines.extend(
        [
            "| Batch | Kind | Identities | Families | Existing examples |",
            "| --- | --- | ---: | ---: | --- |",
        ]
    )
    for batch in report["recommendedBatches"]:
        lines.append(
            f"| {batch['batchId']} | {batch['kind']} | {batch['count']} | "
            f"{batch['familyCount']} | {_ids(batch['supportedExampleIds']) or 'None'} |"
        )

    lines.extend(["", "## Supported-family extensions", ""])
    extensions = [
        family
        for family in report["mechanicFamilies"]
        if family["recommendedAction"] == "review-supported-family-extension"
    ]
    if extensions:
        lines.extend(
            [
                "| Family | Supported IDs | Candidate IDs | Names |",
                "| --- | --- | --- | --- |",
            ]
        )
        for family in extensions:
            lines.append(
                "| {family} | {supported} | {remaining} | {names} |".format(
                    family=family["familyId"],
                    supported=_ids(family["supportedSpellIds"]),
                    remaining=_ids(family["remainingSpellIds"]),
                    names=", ".join(family["displayNames"]),
                )
            )
    else:
        lines.append("None.")

    generic_families = [
        family
        for family in report["mechanicFamilies"]
        if family["recommendedAction"] == "implement-generic-native-family"
    ]
    lines.extend(["", "## Generic implementation families", ""])
    if generic_families:
        lines.extend(["| Family | Candidate IDs | Names |", "| --- | --- | --- |"])
        for family in generic_families:
            lines.append(
                f"| {family['familyId']} | {_ids(family['remainingSpellIds'])} | "
                f"{', '.join(family['displayNames'])} |"
            )
    else:
        lines.append("None.")

    lines.extend(
        [
            "",
            "## Special-behavior queue",
            "",
            "| Special | Identities | Families | Supported examples | Names |",
            "| ---: | ---: | ---: | --- | --- |",
        ]
    )
    for group in report["specialBehaviorQueue"]:
        lines.append(
            f"| {group['special']} | {group['count']} | {group['familyCount']} | "
            f"{_ids(group['supportedExampleIds']) or 'None'} | "
            f"{', '.join(group['displayNames'])} |"
        )

    conflicts = []
    for spell in report["spells"]:
        for legacy in spell["legacyScripts"]:
            if legacy["comparison"]["status"] == "differs-from-source":
                conflicts.append((spell, legacy))
    lines.extend(["", "## Legacy transcription conflicts", ""])
    if conflicts:
        lines.extend(
            [
                "| Classic ID | Spell | Legacy script | Differing fields |",
                "| ---: | --- | --- | --- |",
            ]
        )
        for spell, legacy in conflicts:
            lines.append(
                f"| {spell['classicSpellId']} | {spell['displayName']} | "
                f"`{legacy['path']}` | "
                f"{', '.join(legacy['comparison']['mismatchedFields'])} |"
            )
    else:
        lines.append("No differences were found among the fields simple enough to parse.")

    lines.extend(["", "## Validation", ""])
    if report["validationErrors"]:
        lines.extend(f"- {error}" for error in report["validationErrors"])
    else:
        lines.append("No structural errors found.")
    lines.append("")
    return "\n".join(lines)


def _write_text(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8", newline="\n")


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Audit Classic player-spell parity and group the remaining work."
    )
    default_root = Path(__file__).resolve().parents[1]
    parser.add_argument("--repo-root", type=Path, default=default_root)
    parser.add_argument("--inventory", type=Path)
    parser.add_argument("--matrix", type=Path)
    parser.add_argument("--native-directory", type=Path)
    parser.add_argument("--legacy-directory", type=Path)
    parser.add_argument("--json-output", type=Path)
    parser.add_argument("--markdown-output", type=Path)
    return parser


def main(argv: list[str] | None = None) -> int:
    args = _parser().parse_args(argv)
    repo_root = args.repo_root.resolve()
    inventory_path = (
        args.inventory
        or repo_root / "src/scripts/classic_runtime/classic_core_spell_inventory.json"
    ).resolve()
    matrix_path = (
        args.matrix
        or repo_root / "src/scripts/classic_runtime/classic_spell_support_matrix.json"
    ).resolve()
    native_directory = (
        args.native_directory or repo_root / "src/shared_assets/spells"
    ).resolve()
    legacy_directory = (
        args.legacy_directory or repo_root / "asset_scripts/spell_scripts"
    ).resolve()
    json_output = (
        args.json_output or repo_root / "tmp/classic-spell-parity-audit.json"
    ).resolve()
    markdown_output = (
        args.markdown_output or repo_root / "tmp/classic-spell-parity-audit.md"
    ).resolve()

    inputs = {
        "inventory": _relative_path(inventory_path, repo_root),
        "supportMatrix": _relative_path(matrix_path, repo_root),
        "nativeDirectory": _relative_path(native_directory, repo_root),
        "legacyDirectory": _relative_path(legacy_directory, repo_root),
    }
    report = build_report(
        _load_json(inventory_path),
        _load_json(matrix_path),
        read_native_resources(native_directory, repo_root),
        read_legacy_scripts(legacy_directory, repo_root),
        inputs,
    )
    _write_text(json_output, json.dumps(report, indent=2, ensure_ascii=False) + "\n")
    _write_text(markdown_output, render_markdown(report))

    totals = report["totals"]
    print(
        "Classic spell parity: "
        f"{totals['supportedIdentities']} supported, "
        f"{totals['remainingIdentities']} remaining in "
        f"{totals['remainingMechanicFamilies']} mechanic families."
    )
    print(
        "Generic lanes: "
        + ", ".join(
            f"{count} {lane}"
            for lane, count in totals["genericImplementationLanes"].items()
        )
        + "; "
        f"{totals['specialCodesWithSupportedExamples']} special codes have a supported example."
    )
    print(f"JSON: {_relative_path(json_output, repo_root)}")
    print(f"Markdown: {_relative_path(markdown_output, repo_root)}")
    if report["validationErrors"]:
        for error in report["validationErrors"]:
            print(f"ERROR: {error}")
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
