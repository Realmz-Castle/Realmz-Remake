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
| Files | 4,991 |
| Installed footprint | 175,141,552 bytes (167.03 MiB) |
| Per-file deflate estimate | 44,995,046 bytes (42.91 MiB) |
| JSON footprint | 123,010,192 bytes (117.31 MiB) |
| Byte-identical duplication | 23,796,872 bytes (22.69 MiB) |
| Cross-campaign duplication | 23,694,783 bytes (22.60 MiB) |

The largest duplicate category is stock tilesets at 15,647,091 bytes
(14.92 MiB). The report retains every duplicate hash group and location, every
campaign diagnostic with its source and record identity, per-campaign resource
preparation evidence, file categories, and extension totals.

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

The audit is read-only and does not deduplicate or delete campaign content.
Structural validity and a generated report are not proof that a scenario is
completable.
