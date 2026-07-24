# Known scenario custom-rule audit

This is the checked compatibility inventory for ISY-425. It covers the current
39-directory Classic scenario library, not a claim that every historical
Realmz scenario has been recovered or that decoded records are automatically
playable.

The generated
[`classic_known_custom_rule_manifest.json`](classic_known_custom_rule_manifest.json)
is the machine-readable result. It uses campaign-scoped stable definition IDs,
raw-payload SHA-256 IDs, source record locations, active consumer locations,
rule-table selection, and a separate malformed-data collection. The manifest
validator rejects duplicate identities, missing source locations, active spells
without consumers, invalid classifications, and totals that do not recompute.

## Source selection

The selection rules were verified against Classic Realmz 7.1's `loadprofile`
path in the companion source checkout:

- a present scenario `Data Spell` table is loaded directly;
- race and caste tables use the shared files for first-party menu IDs below 20;
  and
- scenario-local `Data Race` and `Data Caste` are selected for later scenario
  IDs when present.

The 13 first-party scenario names come from the companion Classic build's
bundled-scenario list. A preserved scenario file can therefore be inactive
source evidence. Its presence alone must not change the rules used by a
first-party campaign.

## Current snapshot

The current library contains 39 scenario directories. The older issue estimate
of 36 scenarios, 366 populated custom spells, and 14 nonempty spell tables no
longer describes the available source library.

| Inventory | Checked count |
| --- | ---: |
| Scenario directories | 39 |
| Present `Data Spell` files | 27 |
| Nonempty `Data Spell` tables | 18 |
| Populated spell definitions | 612 |
| Deduplicated 30-byte spell payloads | 319 |
| Active spell definitions | 221 |
| Active spell consumers | 1,114 |
| Present `Data Race` files | 12 |
| Deduplicated changed race records | 22 |
| Present `Data Caste` files | 9 |
| Deduplicated changed caste records | 19 |
| Malformed legacy payloads | 1 |

Packed spell IDs repeat across campaigns. Activity is therefore joined by
campaign ID and definition stable ID, not by packed ID alone. Of the 221 active
definitions, 98 have generically representable fields and 123 require an
unsupported special behavior. The latter span 15 scenarios and are
progression blockers only when their recorded consumers are active.

All 612 spell definitions classify as follows:

| Classification | Definitions | Meaning |
| --- | ---: | --- |
| Native-equivalent | 5 | Byte-identical to a supported shared spell record. All five are inactive in this snapshot. |
| Generically representable | 277 | `special: 0`; executable through the campaign-scoped data-driven spell. |
| Fidelity-only | 0 | Preserved spell evidence that is neither executable nor an unsupported optional special. |
| Unsupported optional | 207 | Nonzero special behavior with no represented active consumer. |
| Progression blocker | 123 | Nonzero special behavior with one or more represented active consumers. |

The five native-equivalent definitions need no new native implementation: their
matching shared records are already supported, and none is active. No native
implementation follow-up was approved by this audit. If a future bundle makes
one active, it needs an explicit custom-ID alias and focused execution proof
before readiness may accept it.

## Consumers and bundle boundary

The active references represented by bundle version 1 are:

| Consumer | References |
| --- | ---: |
| Battle combatants | 823 |
| Summoned combatants | 174 |
| Allies | 59 |
| Whole-party field spells | 38 |
| Selected-character field spells | 16 |
| Rogue traps | 4 |

The usage report also covers complex-encounter spell responses and
scenario-spell items; neither contributes an active custom definition in this
snapshot. Temple offerings, learned-spell lists, and scroll catalogs are not
represented by bundle version 1 and remain an explicit audit boundary rather
than being inferred inactive.

## Race and caste tables

Race and caste records are compared against the first 30 shared records and
deduplicated by exact raw bytes. Their only known Classic consumer is
`loadprofile`.

| Table status | Count |
| --- | ---: |
| Active changed race table | 8 |
| Inactive first-party race copy | 1 |
| Inactive no-op race copy | 2 |
| Malformed race table | 1 |
| Active changed caste table | 7 |
| Inactive first-party caste copy | 2 |

An active scenario-local table with no changed records produces a non-fatal
`no-op-scenario-rule-table` diagnostic. A preserved table selected as shared
produces `inactive-scenario-rule-table`. An explicit unresolved selection
produces `unresolved-rule-table-selection`. Changed tables continue through
the existing all-or-nothing race/caste compatibility adapters; this audit does
not broaden those mechanics.

`Garden gnomes robber/Data Race` is 872 bytes rather than the expected 12,240.
It is retained as `malformed-legacy`, with its own source hash and consumer,
instead of being mislabeled as an unsupported race mechanic.

## Readiness policy

- An empty spell template is ignored.
- An active generic custom spell is executable.
- An active unsupported special is a progression blocker and identifies the
  scenario, stable definition ID, `Data Spell` record, and exact consumer.
- An inactive populated custom spell produces a fidelity warning with consumer
  `none`, even when its special behavior is unsupported.
- Inactive, no-op, active-changed, and malformed race/caste tables remain
  distinct states.

The five checked acceptance cases live in
[`tests/fixtures/custom_rule_compatibility/cases.json`](tests/fixtures/custom_rule_compatibility/cases.json).
They are exercised by the main runtime suite.

## Reproduce and validate

The generator consumes a Classic scenario directory, audit-only compiled
bundles from the authoritative importer, and the shared Realmz rule files:

```powershell
pwsh ./src/scripts/classic_runtime/tools/build_known_custom_rule_manifest.ps1 `
  -ScenarioRoot 'C:\path\to\Scenarios' `
  -BundleRoot 'C:\path\to\compiled-audit-bundles' `
  -SharedDataRoot 'C:\path\to\Data Files' `
  -Godot 'C:\path\to\godot_console.exe'
```

Validate the checked artifact independently:

```powershell
godot --headless --path src --script `
  res://scripts/classic_runtime/tests/report_known_custom_rule_audit.gd
```

The generated manifest contains no workstation paths or generation timestamp.
Its hashes, stable ordering, and recomputed totals make source-library changes
visible in review.
