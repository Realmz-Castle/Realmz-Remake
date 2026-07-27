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
| Ready / blocked | 13 / 0 |
| Progression blockers | 0 |
| Fidelity fallbacks | 961 |
| Active / inactive diagnostics | 3,850 / 184 |
| Files | 8,210 |
| Installed footprint | 173,347,987 bytes (165.32 MiB) |
| Per-file deflate estimate | 42,264,249 bytes (40.31 MiB) |
| JSON footprint | 119,787,559 bytes (114.24 MiB) |
| Shared store | 21 files / 2,221,497 bytes (2.12 MiB) |
| Byte-identical duplication | 13,024,067 bytes (12.42 MiB) |
| Cross-campaign duplication | 12,758,349 bytes (12.17 MiB) |

## Portable Windows release checkpoint

Two clean release exports from source head `17ff258e` produced byte-identical
Windows artifacts:

| Artifact | Bytes | SHA-256 |
| --- | ---: | --- |
| `libgdmpt-windows.release.64.dll` | 6,660,653 | `a7a6c867da39742f1fb074008ced09207eb34114007966ee87b80cb3ab2ff0ba` |
| `Realmz.exe` | 109,249,536 | `c5ac4997732231a94f68e62963878fccc3135ee9bc86ebd72a704f48473c24df` |
| `Realmz.pck` | 206,029,344 | `36deccd660697331fb9412359be643f21f1c38ddf99f8af481876039fafced3b` |

Each portable output includes the external `Campaigns`, `ClassicAssets`,
`Data`, and `Profiles` directories. The campaign directory contains all 13
first-party Classic packages plus the two native packages. The repository has
no Git LFS tracked files or pointer records. This checkpoint reuses the retained
campaign lifecycle and route artifacts; it does not duplicate those acceptance
runs.

This is technical packaging evidence only. It does not grant redistribution
rights. Release provenance and redistribution approval must be recorded before
the first-party Classic packages are shipped.

The built-in campaigns reference 160 byte-identical stock tileset files through
20 immutable content hashes. Moving 18,007,610 campaign-local bytes into
2,194,919 unique payload bytes removes the complete 15,812,691-byte stock
tileset duplicate category. Including the store manifest, this reduces the
installed corpus by 15,757,954 bytes (15.03 MiB). The current certified
per-file deflate estimate is recorded above. Similar but non-identical files
remain campaign-local.

The report counts the sibling `ClassicAssets` store exactly once. It retains
every remaining duplicate hash group and location, every campaign diagnostic
with its source and record identity, per-campaign resource preparation evidence,
file categories, and extension totals.

Per-instance combat-stat generation removes `randomizedStamina`,
`randomizedArmorAgility`, and `classicDifficultyScaling` from all 568 referenced
monster diagnostics, and `randomizedSpellPoints` from the 200 affected
diagnostics. Defeat-time generation removes `randomizedMoney` from 248
referenced diagnostics, and source-backed armed and unarmed playback removes
`attackSounds` from all 565 referenced diagnostics. Two unreferenced bestiary
definitions retain `attackSounds` because IDs 623, 627, and 648 are not present
in the native SFX catalog.

The 170 active monster-icon fallbacks retain their exact Classic resource-chain
classification: 169 resolve to complete stock Family Jewels pairs and one
resolves to a complete campaign/stock pair whose decoded runtime media is still
incomplete. Materialized scenario icon resources removed 396 icon-specific
fallbacks. The report keeps the remaining 528 native monster fidelity
fallbacks separate.

All 63 active unresolved-sound occurrences (22 unique IDs) are visible as
fidelity fallbacks. They are absent from the complete locally available
scenario and stock sound forks, but unavailable optional Gems 2–7 resources
prevent certifying them as intentionally absent. Remake performs no playback;
Classic would do the same only when its complete runtime resource chain also
fails `GetResource('snd ')`. The 3,067 negative playable references are
reported separately because Classic waits for those sounds to finish. The
single unresolved picture currently leaves the picture unchanged, while the
three unresolved map-overlay groups currently retain the base land tile. Both
remain fallbacks because optional external Classic resources could change that
behavior. Producer-only monster preview and override inventory is inactive
rather than being presented as runtime use.

The distribution JSON is compact. Semantic comparison of all 920 JSON files
against the pre-compaction corpus found zero mismatches while reducing the
installed footprint by 152,181,462 bytes (145.13 MiB). Payload and runtime-media
files are unchanged.

The earlier `13/13 ready, 0 blockers, 836 fallbacks` UI aggregate and
`732 blockers` standalone aggregate used different native resource preparation
and are not certification baselines. The first shared-preparation baseline
exposed 611 active progression blockers. Of those, 571 were audit-only save
metadata gaps: the executable wrappers configured their saves through inherited
initializers, while the exported-resource-safe catalog reads their script source
without executing it. The catalog now fills only missing save fields for the
built-in shared spells from the immutable `Data S` inventory. The stock
class-4 breath, paralysis, and acid-spit resources also preserve their exact
source IDs and mechanics instead of combining materially different variants.

The authoritative result is now 0 active progression blockers and 961
fallbacks. Exact stock resources removed 37 previously blocked occurrences:
Arrow `4101` (12), Boulder `4114` (1), Dart of Poison `4202` (15), Poison
`4309` (5), Improved Knowledge `4502` (2), Improved Judgment `4503` (1), and
Improved Luck `4506` (1). Dart of Poison's source duration is zero, so it deals
its chemical projectile damage without inventing a poison condition. The
special-66 attribute resources preserve the source cap of 25 and the additional
caste magic-resistance gain for Intellect or Wisdom above 15. Record `4506`
uses source attribute index 6, Luck; the earlier Improved Agility label was
incorrect.

The last three blockers were two Arrow Storm `4406` occurrences and one
malformed Improved Brawn `4507` occurrence. Arrow Storm now resolves its six
missiles as six independent damage rolls against the same selected target,
preserving Classic's per-missile armor interaction. Record `4507` uses attribute
index 7 even though the character record has only six contiguous attributes.
Classic therefore advances into `cspells[0][0]`, the first learned-spell byte,
rather than raising Brawn. Remake preserves that source behavior explicitly:
the raw byte increments up to the source cap of 25 and survives save/load; a
caster gains the first level-one spell of their own school when the byte changes
from zero, while a non-caster has no visible spell effect. It does not invent a
Brawn increase for the malformed record.

All 13 packages now pass the shared-preparation readiness audit. This removes
the structural launch blockers; it does not replace scenario-level install,
launch, gameplay, save/load, and completion certification.
Of the inactive diagnostics, 178 are preserved fallbacks or trailing data and 6
are producer-only media inventory; none are active consumers.

The certification audit is read-only. The separate
`asset_scripts/share_classic_assets.py` tool performs the deterministic
hash-store migration and can be run without `--apply` to preview its exact
ownership and byte totals. Structural validity and a generated report are not
proof that a scenario is completable.
