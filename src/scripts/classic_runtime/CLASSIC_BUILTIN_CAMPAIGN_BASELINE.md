# Built-in Classic campaign readiness and footprint baseline

This is the certification entry point for the 13 built-in Classic campaigns.
It uses the same `ClassicCampaignInstall` path as campaign selection, including
the shared native context for items, bestiary, spells, and sounds. Preparation
failures are counted separately from readiness diagnostics.

Generate the human-readable summary and replace the deterministic JSON artifact:

```powershell
Godot_v4.7.1-stable_win64_console.exe --headless --path src --script `
  res://scripts/classic_runtime/tests/report_classic_campaign_corpus.gd -- `
  --expected-count=13 `
  --output=res://scripts/classic_runtime/reports/classic_builtin_campaign_baseline.json
```

The command exits with status 0 only when all 13 campaigns are launch-ready.
Status 1 is a successfully generated audit whose current readiness result is
blocked. Status 2 means the command or output path was invalid. Add `--json` to
print the complete report, `--no-compression` for a faster local audit, or pass
another campaigns directory as the sole positional argument.

The checked
[machine-readable baseline](reports/classic_builtin_campaign_baseline.json)
records:

| Measurement | Certified value |
| --- | ---: |
| Campaign packages | 13 |
| Packages loaded / preparation errors | 13 / 0 |
| Ready / blocked | 0 / 13 |
| Progression blockers | 611 |
| Fidelity fallbacks | 836 |
| Active / inactive diagnostics | 1,269 / 178 |
| Files | 4,852 |
| Installed footprint | 159,549,198 bytes (152.16 MiB) |
| Per-file deflate estimate | 34,878,096 bytes (33.26 MiB) |
| JSON footprint | 117,225,263 bytes (111.79 MiB) |
| Shared store | 21 files / 2,199,897 bytes (2.10 MiB) |
| Byte-identical duplication | 8,149,781 bytes (7.77 MiB) |
| Cross-campaign duplication | 8,047,692 bytes (7.67 MiB) |

The built-in campaigns reference 160 byte-identical stock tileset files through
20 immutable content hashes. Moving 17,820,410 campaign-local bytes into
2,173,319 unique payload bytes removes the complete 15,647,091-byte stock
tileset duplicate category. Including the store manifest, this reduces the
installed corpus by 15,592,354 bytes (14.87 MiB) and the per-file deflate
estimate by 10,116,950 bytes (9.65 MiB). Similar but non-identical files remain
campaign-local.

The report counts the sibling `ClassicAssets` store exactly once. It retains
every remaining duplicate hash group and location, every campaign diagnostic
with its source and record identity, per-campaign resource preparation evidence,
file categories, and extension totals.

The distribution JSON is compact. Semantic comparison of all 920 JSON files
against the pre-compaction corpus found zero mismatches while reducing the
installed footprint by 152,181,462 bytes (145.13 MiB). Payload and runtime-media
files are unchanged.

The earlier `13/13 ready, 0 blockers, 836 fallbacks` UI aggregate and
`732 blockers` standalone aggregate used different native resource preparation
and are not certification baselines. With shared preparation, the authoritative
result is 611 active progression blockers and 836 fallbacks. Of the fallbacks,
178 describe inactive preserved definitions or trailing data; those records
remain inventoried and are not active consumers.

The certification audit is read-only. The separate
`asset_scripts/share_classic_assets.py` tool performs the deterministic
hash-store migration and can be run without `--apply` to preview its exact
ownership and byte totals. Structural validity and a generated report are not
proof that a scenario is completable.
