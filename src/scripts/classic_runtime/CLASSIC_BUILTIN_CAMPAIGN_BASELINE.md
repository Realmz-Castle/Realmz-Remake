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
| Installed footprint | 327,323,014 bytes (312.16 MiB) |
| Per-file deflate estimate | 47,179,058 bytes (44.99 MiB) |
| JSON footprint | 275,191,654 bytes (262.44 MiB) |
| Byte-identical duplication | 29,871,879 bytes (28.49 MiB) |
| Cross-campaign duplication | 29,664,349 bytes (28.29 MiB) |

The largest duplicate category is stock tilesets at 21,188,297 bytes
(20.21 MiB). The report retains every duplicate hash group and location, every
campaign diagnostic with its source and record identity, per-campaign resource
preparation evidence, file categories, and extension totals.

The earlier `13/13 ready, 0 blockers, 836 fallbacks` UI aggregate and
`732 blockers` standalone aggregate used different native resource preparation
and are not certification baselines. With shared preparation, the authoritative
result is 611 active progression blockers and 836 fallbacks. Of the fallbacks,
178 describe inactive preserved definitions or trailing data; those records
remain inventoried and are not active consumers.

This audit does not compact, deduplicate, or delete campaign content. Structural
validity and a generated report are not proof that a scenario is completable.
