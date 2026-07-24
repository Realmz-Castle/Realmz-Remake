# Classic regression corpus

The checked corpus runs one shared bundle-loader, execution-audit, and action-
interpreter suite against three reduced Classic scenario fixtures. It protects
cross-scenario compatibility behavior without treating a single scenario or an
opcode inventory as sufficient evidence.

Run it from the repository root:

```powershell
Godot_v4.7.1-stable_win64_console.exe --headless --path src --script `
  res://scripts/classic_runtime/tests/run_classic_regression_corpus.gd
```

Add `-- --json` for a machine-readable report. The full Classic runtime suite
also invokes this corpus and verifies that a deliberately mismatched expectation
reports the scenario, case, and source-record identifiers.

## Checked members

| Scenario fixture | Executed behavior | Audited contexts |
| --- | --- | --- |
| City of Bywater | Encounter choice/result, fixed treasure and item identity, party spell, battle request | `map-trigger`, `data-ed3-xap`, `data-ed-result`, `data-ed2-result` |
| War in the Sword Lands | Exact shipped three-frame GOSUB/XAP trace and return order | `map-trigger`, `data-ed3-xap` |
| Twin Sands of Time | Shipped opcode `25` door relocation/mutation and source battle request | `map-trigger` |

Together, passing cases cover the required map, stack/XAP, encounter, item,
spell, and battle domains. Domains count only when their executable case passes.
Contexts come from the same execution audit for every loaded member, so a
context name does not by itself claim that every audited action executed.

The manifest is
`tests/fixtures/classic_regression_corpus.json`. Add a member or case there
instead of branching the runner for a scenario-specific layout. Each member
must use `repository-reduced-fixture` availability and the common
`ClassicCampaignBundle` directory contract.

## Evidence classification

Every audited action appears in exactly one report bucket:

- **fixture-proven**: the action occurred in the exact trace of a passing corpus
  case.
- **source-backed**: the normalized record retains source provenance and is
  understood by the audit, but this corpus did not execute that exact action.
- **inferred**: provenance marks the normalized record as inferred or
  heuristic.
- **malformed**: the record or its action is marked malformed by provenance or
  the execution audit.
- **unknown**: support or provenance is unknown or missing.

Zero counts remain present in the report. That keeps the distinction stable and
makes newly introduced inferred, malformed, or unknown rows visible rather than
silently omitting their category.

## Provenance and availability boundary

The three directories contain selected normalized Providence records retained
as repository regression fixtures. Their `evidence.json` files identify the
source records and evidence. They are intentionally reduced slices, not
distributable copies of the complete scenarios, and their presence does not
claim that every behavior in those scenarios is covered.

The corpus proves normalized-data loading and runtime semantics only. Character
portraits, player-map icons, other PICT exports, and visual reference images are
outside this evidence boundary; passing this suite does not establish their
palette or image-export fidelity.

## Failure contract

Case failures use this prefix when their identifiers are available:

```text
[scenario-id] [case-id] [record-id] failure detail
```

Manifest, loader, and corpus-wide coverage failures may omit identifiers that
do not exist at that layer. A case-level expectation must retain all three so a
failure can be traced back to the exact fixture record.
