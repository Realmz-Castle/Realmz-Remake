#!/usr/bin/env python3
"""Move byte-identical built-in Classic tileset files into one hash store."""

from __future__ import annotations

import argparse
import hashlib
import json
import shutil
from collections import defaultdict
from pathlib import Path
from typing import Any

FORMAT = "realmz-remake-classic-shared-assets"
FORMAT_VERSION = 1
HASH_ALGORITHM = "sha256"
CAMPAIGN_FORMAT = "realmz-remake-classic-campaign"
SHARED_KIND = "stock-tileset"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--root",
        type=Path,
        default=Path(__file__).resolve().parents[1] / "src",
        help="Realmz Remake Godot project root (default: repository src)",
    )
    parser.add_argument(
        "--expected-campaigns",
        type=int,
        default=13,
        help="Require this many built-in Classic campaign directories",
    )
    parser.add_argument(
        "--apply",
        action="store_true",
        help="Write the store/manifests and remove the shared local copies",
    )
    parser.add_argument(
        "--report",
        type=Path,
        help="Optional path for the deterministic JSON summary",
    )
    return parser.parse_args()


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def read_json(path: Path) -> dict[str, Any]:
    value = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(value, dict):
        raise ValueError(f"{path} must contain a JSON object")
    return value


def write_compact_json(path: Path, value: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps(value, ensure_ascii=False, separators=(",", ":")) + "\n",
        encoding="utf-8",
        newline="\n",
    )


def store_payload_path(store_root: Path, digest: str, extension: str) -> Path:
    return store_root / HASH_ALGORITHM / digest[:2] / f"{digest}.{extension}"


def require_within(path: Path, root: Path) -> None:
    resolved = path.resolve()
    resolved.relative_to(root.resolve())


def discover_campaigns(
    campaigns_root: Path, expected_campaigns: int
) -> list[dict[str, Any]]:
    campaigns: list[dict[str, Any]] = []
    for directory in sorted(campaigns_root.glob("* (Classic)")):
        manifest_path = directory / "campaign.json"
        if not directory.is_dir() or not manifest_path.is_file():
            continue
        manifest = read_json(manifest_path)
        if manifest.get("format") != CAMPAIGN_FORMAT:
            continue
        campaigns.append(
            {
                "directory": directory,
                "name": directory.name,
                "id": str(manifest.get("id", "")),
                "manifest": manifest,
                "manifestPath": manifest_path,
            }
        )
    if expected_campaigns > 0 and len(campaigns) != expected_campaigns:
        raise ValueError(
            f"Expected {expected_campaigns} built-in Classic campaigns, "
            f"found {len(campaigns)}"
        )
    return campaigns


def validate_existing_section(
    campaign: dict[str, Any], store_root: Path
) -> list[dict[str, Any]]:
    manifest = campaign["manifest"]
    section = manifest.get("sharedAssets")
    if section is None:
        return []
    if not isinstance(section, dict):
        raise ValueError(f"{campaign['name']} sharedAssets must be an object")
    if (
        section.get("format") != FORMAT
        or section.get("formatVersion") != FORMAT_VERSION
    ):
        raise ValueError(f"{campaign['name']} uses an unsupported sharedAssets format")
    records = section.get("files")
    if not isinstance(records, list) or not records:
        raise ValueError(f"{campaign['name']} sharedAssets.files must be non-empty")
    validated: list[dict[str, Any]] = []
    seen: set[str] = set()
    for record in records:
        if not isinstance(record, dict):
            raise ValueError(f"{campaign['name']} has an invalid shared asset record")
        logical_path = str(record.get("logicalPath", "")).replace("\\", "/")
        path = Path(logical_path)
        if (
            not logical_path
            or path.is_absolute()
            or ".." in path.parts
            or record.get("kind") != SHARED_KIND
        ):
            raise ValueError(
                f"{campaign['name']} has an unsafe shared path: {logical_path}"
            )
        if logical_path.lower() in seen:
            raise ValueError(
                f"{campaign['name']} repeats shared path: {logical_path}"
            )
        seen.add(logical_path.lower())
        digest = str(record.get("sha256", "")).lower()
        extension = path.suffix.lower().removeprefix(".")
        expected_bytes = int(record.get("bytes", -1))
        payload = store_payload_path(store_root, digest, extension)
        if (
            len(digest) != 64
            or any(character not in "0123456789abcdef" for character in digest)
            or expected_bytes < 0
            or not payload.is_file()
            or payload.stat().st_size != expected_bytes
            or sha256_file(payload) != digest
        ):
            raise ValueError(
                f"{campaign['name']} shared asset is missing or corrupt: {logical_path}"
            )
        validated.append(
            {
                "campaign": campaign,
                "logicalPath": logical_path,
                "sha256": digest,
                "bytes": expected_bytes,
                "extension": extension,
                "sourcePath": None,
            }
        )
    return validated


def inventory_local_tilesets(
    campaigns: list[dict[str, Any]],
) -> list[dict[str, Any]]:
    occurrences: list[dict[str, Any]] = []
    for campaign in campaigns:
        tilesets = campaign["directory"] / "Tilesets"
        if not tilesets.is_dir():
            continue
        for path in sorted(candidate for candidate in tilesets.rglob("*") if candidate.is_file()):
            logical_path = path.relative_to(campaign["directory"]).as_posix()
            occurrences.append(
                {
                    "campaign": campaign,
                    "logicalPath": logical_path,
                    "sha256": sha256_file(path),
                    "bytes": path.stat().st_size,
                    "extension": path.suffix.lower().removeprefix("."),
                    "sourcePath": path,
                }
            )
    return occurrences


def select_duplicate_occurrences(
    local_occurrences: list[dict[str, Any]],
) -> list[dict[str, Any]]:
    groups: dict[tuple[str, str], list[dict[str, Any]]] = defaultdict(list)
    for occurrence in local_occurrences:
        groups[(occurrence["sha256"], occurrence["extension"])].append(occurrence)
    selected: list[dict[str, Any]] = []
    for occurrences in groups.values():
        campaign_names = {
            occurrence["campaign"]["name"] for occurrence in occurrences
        }
        if len(campaign_names) >= 2:
            selected.extend(occurrences)
    return selected


def build_plan(root: Path, expected_campaigns: int) -> dict[str, Any]:
    root = root.resolve()
    campaigns_root = root / "Campaigns"
    store_root = root / "ClassicAssets"
    if not campaigns_root.is_dir():
        raise ValueError(f"Campaigns directory does not exist: {campaigns_root}")
    campaigns = discover_campaigns(campaigns_root, expected_campaigns)
    existing: list[dict[str, Any]] = []
    if store_root.exists():
        for campaign in campaigns:
            existing.extend(validate_existing_section(campaign, store_root))
    elif any(campaign["manifest"].get("sharedAssets") for campaign in campaigns):
        raise ValueError(f"Shared asset store does not exist: {store_root}")

    local = inventory_local_tilesets(campaigns)
    selected = select_duplicate_occurrences(local)
    by_campaign_path: dict[tuple[str, str], dict[str, Any]] = {}
    for occurrence in existing + selected:
        key = (occurrence["campaign"]["name"], occurrence["logicalPath"].lower())
        prior = by_campaign_path.get(key)
        if prior and prior["sha256"] != occurrence["sha256"]:
            raise ValueError(
                f"Shared reference conflicts with local bytes: "
                f"{occurrence['campaign']['name']}/{occurrence['logicalPath']}"
            )
        by_campaign_path[key] = occurrence
    references = sorted(
        by_campaign_path.values(),
        key=lambda row: (row["campaign"]["name"].lower(), row["logicalPath"].lower()),
    )

    payloads: dict[str, dict[str, Any]] = {}
    for reference in references:
        digest = reference["sha256"]
        prior = payloads.get(digest)
        if prior and prior["extension"] != reference["extension"]:
            raise ValueError(f"Hash {digest} is referenced with multiple extensions")
        if not prior:
            payloads[digest] = {
                "bytes": reference["bytes"],
                "extension": reference["extension"],
                "sourcePath": reference["sourcePath"],
                "owners": [],
            }
        elif payloads[digest]["sourcePath"] is None and reference["sourcePath"] is not None:
            payloads[digest]["sourcePath"] = reference["sourcePath"]
        payloads[digest]["owners"].append(
            {
                "campaignId": reference["campaign"]["id"],
                "campaignDirectory": reference["campaign"]["name"],
                "logicalPath": reference["logicalPath"],
            }
        )

    selected_local = [
        reference for reference in references if reference["sourcePath"] is not None
    ]
    local_bytes = sum(reference["bytes"] for reference in selected_local)
    shared_logical_bytes = sum(reference["bytes"] for reference in references)
    store_bytes = sum(record["bytes"] for record in payloads.values())
    return {
        "root": root,
        "campaignsRoot": campaigns_root,
        "storeRoot": store_root,
        "campaigns": campaigns,
        "references": references,
        "selectedLocal": selected_local,
        "payloads": payloads,
        "summary": {
            "format": FORMAT,
            "formatVersion": FORMAT_VERSION,
            "campaigns": len(campaigns),
            "campaignReferences": len(references),
            "uniquePayloads": len(payloads),
            "localFilesRemoved": len(selected_local),
            "localBytesRemoved": local_bytes,
            "sharedLogicalBytes": shared_logical_bytes,
            "storeBytes": store_bytes,
            "grossBytesSaved": shared_logical_bytes - store_bytes,
        },
    }


def apply_plan(plan: dict[str, Any]) -> None:
    store_root: Path = plan["storeRoot"]
    campaigns_root: Path = plan["campaignsRoot"]
    root: Path = plan["root"]
    require_within(store_root, root)
    require_within(campaigns_root, root)

    for digest, record in sorted(plan["payloads"].items()):
        destination = store_payload_path(store_root, digest, record["extension"])
        require_within(destination, store_root)
        source: Path | None = record["sourcePath"]
        if not destination.exists():
            if source is None:
                raise ValueError(f"No source bytes are available for store payload {digest}")
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(source, destination)
        if (
            destination.stat().st_size != record["bytes"]
            or sha256_file(destination) != digest
        ):
            raise ValueError(f"Content store payload failed verification: {digest}")

    store_files: dict[str, Any] = {}
    for digest, record in sorted(plan["payloads"].items()):
        owners = sorted(
            record["owners"],
            key=lambda owner: (
                owner["campaignDirectory"].lower(),
                owner["logicalPath"].lower(),
            ),
        )
        store_files[digest] = {
            "bytes": record["bytes"],
            "extension": record["extension"],
            "owners": owners,
        }
    write_compact_json(
        store_root / "store.json",
        {
            "format": FORMAT,
            "formatVersion": FORMAT_VERSION,
            "hashAlgorithm": HASH_ALGORITHM,
            "files": store_files,
        },
    )

    references_by_campaign: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for reference in plan["references"]:
        references_by_campaign[reference["campaign"]["name"]].append(
            {
                "bytes": reference["bytes"],
                "kind": SHARED_KIND,
                "logicalPath": reference["logicalPath"],
                "sha256": reference["sha256"],
            }
        )
    for campaign in plan["campaigns"]:
        records = sorted(
            references_by_campaign.get(campaign["name"], []),
            key=lambda record: record["logicalPath"].lower(),
        )
        if records:
            campaign["manifest"]["sharedAssets"] = {
                "format": FORMAT,
                "formatVersion": FORMAT_VERSION,
                "files": records,
            }
        else:
            campaign["manifest"].pop("sharedAssets", None)
        write_compact_json(campaign["manifestPath"], campaign["manifest"])

    for reference in plan["selectedLocal"]:
        source: Path = reference["sourcePath"]
        require_within(source, campaigns_root)
        digest = reference["sha256"]
        destination = store_payload_path(
            store_root, digest, reference["extension"]
        )
        if sha256_file(destination) != digest:
            raise ValueError(f"Refusing to remove unverified source for {digest}")
        source.unlink()

    for campaign in plan["campaigns"]:
        tilesets = campaign["directory"] / "Tilesets"
        if not tilesets.is_dir():
            continue
        directories = sorted(
            (path for path in tilesets.rglob("*") if path.is_dir()),
            key=lambda path: len(path.parts),
            reverse=True,
        )
        for directory in directories:
            require_within(directory, campaigns_root)
            if not any(directory.iterdir()):
                directory.rmdir()
        if not any(tilesets.iterdir()):
            tilesets.rmdir()


def serializable_summary(plan: dict[str, Any]) -> dict[str, Any]:
    by_campaign: dict[str, dict[str, int]] = defaultdict(
        lambda: {"files": 0, "bytes": 0}
    )
    for reference in plan["references"]:
        row = by_campaign[reference["campaign"]["name"]]
        row["files"] += 1
        row["bytes"] += reference["bytes"]
    return {
        **plan["summary"],
        "campaignOwnership": dict(sorted(by_campaign.items())),
    }


def main() -> int:
    args = parse_args()
    plan = build_plan(args.root, args.expected_campaigns)
    if args.apply:
        apply_plan(plan)
    summary = serializable_summary(plan)
    summary["applied"] = args.apply
    rendered = json.dumps(summary, indent=2, sort_keys=True) + "\n"
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(rendered, encoding="utf-8", newline="\n")
    print(rendered, end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
