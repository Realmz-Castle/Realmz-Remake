# Classic compatibility support matrix and porting workflow

This guide describes the current, tested path from a Providence project to an
installed Realmz Remake campaign. It is for scenario authors, players, and
maintainers. It does not claim that format conversion alone makes a scenario
playable or that support proven for one scenario applies to every Classic
scenario.

The detailed sources behind this summary are:

- [bundle contract](BUNDLE_CONTRACT.md) for the portable artifact;
- [installation contract](INSTALLING_CLASSIC_CAMPAIGNS.md) for package layout,
  materialization, and replacement;
- [compatibility gap register](COMPATIBILITY_GAPS.md) for capability-level
  evidence and open boundaries;
- [regression corpus contract](CLASSIC_REGRESSION_CORPUS.md) for cross-scenario
  semantic coverage; and
- [City of Bywater acceptance log](CITY_OF_BYWATER_ACCEPTANCE.md) for the
  current end-to-end campaign checkpoint.

## Evidence ladder

Use the narrowest claim supported by the evidence:

| Level | What it proves | What it does not prove |
| --- | --- | --- |
| Contract-valid | Remake accepts the manifest, documents, identities, paths, and payload declarations. | Referenced behavior or native resources are ready. |
| Launch-ready | The readiness report found no known progression blocker for the supplied bundle and resource context. | Every branch is correct or the campaign is completable. |
| Component-verified | A focused fixture or native smoke proves one named behavior and integration boundary. | Unexercised records or other scenarios behave the same way. |
| Checkpoint-verified | An acceptance route reaches and reloads a named gameplay checkpoint through normal UI, map, battle, and save paths. | The campaign has been completed start to finish. |
| Campaign-complete | A recorded full playthrough completes the campaign with reviewed diagnostics and save/reload coverage. | Unrelated scenarios or optional presentation are exact. |

Semantic coverage is not end-to-end playability. Opcode handling, audit counts,
bundle validity, launch readiness, component smokes, checkpoint acceptance, and
campaign completion are separate results.

## Current version compatibility

| Layer | Current accepted version | Compatibility rule |
| --- | --- | --- |
| Providence project | Schema `5` | The compatibility exporter reads the canonical project directly. It does not consume Providence's native Realmz compiler output. |
| Remake bundle | Manifest `formatVersion: 1`; every document `schemaVersion: 1` | Remake rejects unknown versions before indexing any runtime record. Additive evidence fields are allowed in version 1. |
| Compatibility profile | `realmz-7.1` | A different or missing profile is rejected. |
| Realmz Remake Godot project | `4.7` | The commands below are currently verified with Godot `4.7.1`. |
| Classic save envelope | Schema `2` | Schema 1 migrates as an idle continuation. A newer schema is rejected without changing the existing save. |
| Regression corpus | Manifest schema `1`; shared suite `1` | Every member runs through the same bundle loader, execution audit, interpreter, and state path. |

The bundle version is the compiler/runtime interchange contract. Providence and
Remake repository versions may change independently as long as the exporter
still emits an accepted bundle and the cross-repository gate passes.

## Port a scenario

### 1. Prepare the Providence project

Import or author the scenario in Providence and resolve the source selections
that affect runtime behavior. Preserve imported raw source and provenance, but
do not treat a present `Data Spell`, `Data Race`, or `Data Caste` table as proof
that Classic selects it.

Export the canonical project as a Remake Classic bundle from the Providence
checkout:

```powershell
cargo run --manifest-path src-tauri/Cargo.toml `
  --bin realmz-remake-converter -- `
  --project "C:\path\Scenario.providence" `
  "C:\output\Example Campaign"
```

The output directory must be absent or empty. The result is a self-contained
compatibility bundle, not a native Realmz scenario folder and not
`project.json`.

### 2. Validate the portable contract

From the Realmz Remake checkout:

```powershell
Godot_v4.7.1-stable_win64_console.exe --headless --path src --script `
  res://scripts/classic_runtime/tests/validate_classic_bundle.gd -- `
  "C:\output\Example Campaign"
```

Exit 0 proves only contract validity. Exit 1 reports an invalid bundle; exit 2
reports incorrect command usage.

For exporter changes, also run Providence's deterministic cross-repository
gate:

```powershell
powershell -ExecutionPolicy Bypass `
  -File scripts/verify_remake_classic_export.ps1 `
  -ProvidenceRoot "C:\path\Realmz-Providence" `
  -RemakeRoot "C:\path\Realmz-Remake" `
  -Godot "C:\path\Godot_v4.7.1-stable_win64_console.exe"
```

### 3. Inspect semantic readiness

```powershell
Godot_v4.7.1-stable_win64_console.exe --headless --path src --script `
  res://scripts/classic_runtime/tests/report_classic_readiness.gd -- `
  "C:\output\Example Campaign" --json
```

Supply the matching native campaign directory as the second positional
argument when the port intentionally reuses existing campaign resources:

```powershell
Godot_v4.7.1-stable_win64_console.exe --headless --path src --script `
  res://scripts/classic_runtime/tests/report_classic_readiness.gd -- `
  "C:\output\Example Campaign" `
  "C:\path\Realmz-Remake\src\Campaigns\Example Campaign" --json
```

Every diagnostic includes source context and is classified as:

- `progression-blocker`: missing or unsupported data can stop execution or
  change an authored result; or
- `fidelity-fallback`: play can continue with reduced presentation or a
  documented approximation.

Exit 0 means the report found no progression blocker. Exit 1 means launch is
blocked. Exit 2 means command usage was invalid. A clean readiness result is not
a campaign-completion claim.

### 4. Install through the package boundary

Close the game, then install the complete export:

```powershell
Godot_v4.7.1-stable_win64_console.exe --headless --path src --script `
  res://scripts/classic_runtime/tools/install_classic_campaign.gd -- `
  "C:\output\Example Campaign"
```

The installer stages a complete copy below `Campaigns`, materializes supported
native maps, items, and monsters, validates the staged launch state, and only
then moves the package into place. Missing native battles are materialized from
supported compiled grids when the runtime requests them. Do not pass only the
`classic` subdirectory.

The normal campaign panel discovers an installed `classic-compiled` manifest.
A ready campaign starts through the ordinary party-selection and exploration
flow; a blocked campaign exposes its readiness summary rather than starting a
partial runtime.

### 5. Prove the intended support level

Run focused fixtures for every progression-relevant mechanic, then exercise
the normal UI lifecycle. A new port should record at least:

1. portable validation and readiness output;
2. installation and campaign discovery;
3. start-map rendering and authored entry behavior;
4. representative encounter, service, item/spell, and battle paths actually
   used by the scenario;
5. save, exit, relaunch, and continuation at legal save boundaries; and
6. the furthest verified checkpoint or complete playthrough, without promoting
   it to a broader claim.

## Update an installed campaign safely

Package replacement and save compatibility are different concerns. The
installer replaces only `Campaigns/<name>`; profile saves live under `Profiles`
and are not overwritten. The installer:

- requires explicit `--replace`;
- rejects an update whose manifest `id` differs from the installed campaign;
- stages, materializes, and validates the complete new package first;
- swaps whole directories so stale files are not mixed into the update; and
- restores the previous package if final validation fails.

Its temporary package backup is removed after a successful update and is not a
long-term user backup. Use this update sequence:

1. Close Realmz Remake.
2. Keep the previous export and back up the affected profile saves.
3. Export into a fresh directory with the same folder name and campaign
   manifest `id`.
4. Run bundle validation and readiness against the new export.
5. Install into a disposable `Campaigns` root and run focused smokes.
6. Load representative existing saves against that test installation. Stable
   campaign identity and save schema do not guarantee that changed record IDs
   or removed resources remain compatible.
7. Replace the live package:

```powershell
Godot_v4.7.1-stable_win64_console.exe --headless --path src --script `
  res://scripts/classic_runtime/tools/install_classic_campaign.gd -- `
  "C:\output\Example Campaign" --replace --json
```

8. Reopen the campaign and verify the expected save before deleting the manual
   backup.

Normal Classic saves currently preserve map and quest state, encounter and
Action Point mutations, acquired maps, adapter-owned item state, and safe
suspended interpreter continuations. Saving is deliberately refused during a
live native battle and during side-effecting rogue-response intervals that
cannot be replayed safely.

## Current support matrix

This is a routing summary. The
[compatibility gap register](COMPATIBILITY_GAPS.md) is authoritative for exact
mechanics, evidence, and open completion criteria.

| Area | Status | Verified support | Important boundary |
| --- | --- | --- | --- |
| Campaign lifecycle | Supported | Contract validation, staged installation, normal discovery/selection/start, package replacement, and readiness gating. | Updates must retain campaign identity and independently prove old-save compatibility. |
| Maps and exploration | Partial | Land/dungeon materialization, stock and decoded custom landlooks, decoded special tiles, Action Points, transfers, darkness, trigger/random rectangles, mutations, and persistence. | Unsupported render modes or required undecoded media block installation. Classic view presentation, scripted boat operations, and some boarding pacing remain open. |
| Encounters, services, and time | Partial | Simple, complex, and rogue results; action, spoken, spell, scroll, item, trap, and door responses; chance-based rogue lock controls; shops, temples, banks, timed-encounter scheduling, exact supported built-in warnings, and native acknowledgement pacing. | Remake intentionally uses a native chance roll instead of Classic's timed tumbler minigame. Other optional modal presentation remains bounded fidelity work. Every referenced resource must resolve exactly. |
| Battles and monsters | Partial | Native battle requests, generated grids and supported monsters, round/death macros, roster spawn/remove/route, source-ordered spawn sounds and native conjuration reveals, priest turning, forced victory, rewards, and outer-list resumption. | Unsupported monster fields, unresolved item/spell identities, weapon-coupled specials, and aging special 17 block affected battles. Exact Classic spell-effect artwork and some statistical fidelity remain fallbacks. |
| Items and equipment | Partial | Exact Classic identities, supported scenario-item materialization, treasure/shop/inventory paths, equipment state, charges, restrictions, and save/load. | Unsupported effects or restrictions block referenced items. Curses, scripted special fields, and exact item art/sound remain open. |
| Spells, races, and castes | Partial | Exact spell identities, supported core spell behavior, representable data-driven custom spells, producer-selected changed race/caste profiles through their verified consumers, and a [deduplicated known-library audit](KNOWN_CUSTOM_RULE_AUDIT.md) with campaign-scoped definitions and source locations. | Active custom nonzero special effects need an exact implementation; inactive definitions warn without blocking. Unresolved rule-table selection blocks use; display-name substitution and partial race/caste application are forbidden. |
| Pictures, sounds, and player maps | Partial | Immutable payload verification plus decoded runtime media, source-ordered picture dismissal and sound repetition, picture/sound commands, browsable acquired maps, terrain-composed maps, and plain scrolling text. | Missing media is a fallback unless marked required for progression. Exact scrolling-text styles and new media modes still require focused visual evidence. |
| Saves and continuations | Supported at named boundaries | Versioned runtime/adapter state, persistent mutations, GOSUB/encounter continuation, map/HUD restore, and older-save migration. | Live battles and side-effecting rogue intervals are not serializable. Newer save schemas and campaign-ID mismatches are rejected. |
| Diagnostics | Partial | Versioned headless readiness report with source, record, slot, severity, blocker/fallback classification, JSON, and exit codes; selector shows a summary and first blocker. | The normal UI does not yet expose the complete diagnostic report. |

## Add a scenario to the regression corpus

The checked corpus protects runtime semantics without redistributing complete
scenario packages. A new member must be a legally retained, repository-reduced
`classic-compiled` fixture with enough normalized source-backed records to prove
the selected behavior.

Before adding it:

- record the scenario identity, availability/provenance boundary, exact source
  file and record IDs, and evidence confidence;
- retain only the records and assets needed for the bounded regression claim;
- keep malformed or legacy data distinct from unsupported mechanics;
- choose cases by behavior domain and execution context, not only opcode;
- state exact expected commands, traces, runtime-state mutations, and outcomes;
- require every case failure to identify scenario, case, and source record; and
- add a native smoke when the claim crosses UI, map, service, media, save, or
  combat integration rather than interpreter semantics alone.

Add the fixture member and its data-driven cases to
`tests/fixtures/classic_regression_corpus.json`. Do not add scenario-specific
branches to the corpus runner.

Run:

```powershell
Godot_v4.7.1-stable_win64_console.exe --headless --path src --script `
  res://scripts/classic_runtime/tests/run_classic_regression_corpus.gd

Godot_v4.7.1-stable_win64_console.exe --headless --path src --script `
  res://scripts/classic_runtime/tests/run_classic_regression_corpus.gd -- --json

Godot_v4.7.1-stable_win64_console.exe --headless --resolution 1100x619 `
  --path src --script `
  res://scripts/classic_runtime/tests/run_classic_runtime_tests.gd
```

The standalone report must keep all five action classifications:
`fixture-proven`, `source-backed`, `inferred`, `malformed`, and `unknown`.
Review every newly nonzero inferred, malformed, or unknown count. The full
runtime suite must retain its pass marker. Existing Godot UID/autoload/shutdown
diagnostics do not replace that marker or a zero exit status.

Finally, update this guide and the detailed gap register only when the new
evidence changes a public support boundary. A decoder success, handler presence,
or one passing fixture is not evidence of complete scenario playability.
