# Classic campaign bundle contract, version 1

This contract defines the normalized artifact exchanged between Providence and
Realmz Remake's Classic compatibility runtime. It is not Providence's project
format and it is not the native Realmz scenario folder produced by Providence's
authoritative Realmz compiler. A Providence compatibility export produces this
bundle as a separate, immutable runtime artifact.

The checked fixtures under `tests/fixtures` are the current consumer examples.
They are intentionally self-contained so the Remake tests do not depend on a
Providence checkout or an original scenario installation.

## Root manifest

Every bundle is a directory containing `campaign.json`:

```json
{
  "format": "realmz-remake-classic-campaign",
  "formatVersion": 1,
  "campaignKind": "classic-compiled",
  "compatibilityProfile": "realmz-7.1",
  "id": "scenario-city-of-bywater",
  "name": "City of Bywater",
  "start": {
    "levelType": "land",
    "levelIndex": 0,
    "x": 2,
    "y": 1
  },
  "files": {
    "scenario": "classic/scenario.json",
    "maps": "classic/maps.json",
    "scripts": "classic/scripts.json",
    "encounters": "classic/encounters.json",
    "content": "classic/content.json",
    "rules": "classic/rules.json",
    "assets": "classic/assets.json",
    "evidence": "classic/evidence.json"
  }
}
```

All eight document paths are required, unique, relative to the bundle root, and
must name JSON files. Absolute paths, URI schemes, drive prefixes, and `..`
segments are invalid. Asset paths inside the documents follow the same
campaign-relative rule; an installed campaign must not depend on either source
repository's location.

## Versioning

`formatVersion` versions the manifest and document set. Every referenced document
also carries `"schemaVersion": 1`. Remake rejects a version it does not understand
before building indexes or starting the interpreter.

Version 1 readers allow unknown object fields so Providence can preserve evidence
without changing runtime behavior. Removing or renaming a required field, changing
its meaning, or changing an identity namespace requires a new format version.
Adding optional evidence or provenance fields does not.

## Documents and identities

| Document | Runtime collections | Stable identity |
| --- | --- | --- |
| `scenario` | Scenario identity and original shell metadata | `identity.id`, equal to `campaign.json.id` |
| `maps` | `maps`, optional `mapRecords` player maps | String map ID; numeric player-map `id` |
| `scripts` | `triggers`, `extraCodes`, `messages`, `randomLevels` | String trigger/random-level ID; numeric source record ID for Extra Code and messages |
| `encounters` | `battles`, `treasures`, `shops`, `simpleEncounters`, `complexEncounters`, `thiefEncounters`, `timedEncounters` | Numeric Classic record ID within each collection |
| `content` | `monsters`, `scenarioItems`, `itemTexts` | Numeric Classic record ID; item text uses `itemId` |
| `rules` | Spell, race, and caste overrides plus rule names | Numeric Classic rule ID within its collection |
| `assets` | Managed assets and the tileset, picture, icon, sound, and optional special-land-tile catalogs | String `id` for managed assets and tilesets; numeric Classic `resourceId` for pictures, icons, and sounds; signed `resourceId` for special land tiles |
| `evidence` | Validation results, dispatcher no-ops, and source evidence | Source file, record index, slot, and raw action code together identify an action observation |

Stable identities come from the compiled Classic record namespace; array position
is never an identity. Action slots are addressed by their owning trigger ID plus
their zero-based `slot`. Duplicate identities within one collection are invalid.
References retain their Classic numeric ID even when a later native adapter also
needs a Remake resource name. When an asset record includes `payloadPath`, the path
is relative to the campaign root and follows the same traversal and absolute-path
restrictions as the document paths.

`payloadPath` always identifies the immutable packaged bytes described by
`payloadEncoding`. It is not implicitly a Godot-loadable file. A catalog,
managed-asset, or player-map record may separately provide decoded media:

```json
{
  "runtimeMedia": {
    "path": "media/pictures/32128.png",
    "mediaType": "image/png",
    "bytes": 41700,
    "sha256": "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
  }
}
```

All four fields are required when `runtimeMedia` is present. `path` is
campaign-relative, `bytes` is the decoded file length, and `sha256` is its
64-digit content hash. Picture, icon, tileset, special-land-tile, and player-map
media types begin with `image/`; sound media types begin with `audio/`. The
installed-campaign loader verifies both immutable payloads and decoded media
before launch. Version-1 consumers that do not know this additive object may
ignore it; producers must not overload `payloadPath` with decoded media.

A custom landlook tileset uses its catalog `runtimeMedia` as the decoded 640 x
320, 20-by-10 atlas. Remake combines its 200 one-based visual slots with records
1 through 200 from the matching `maps.customLandlooks` entry. Record 0 remains
compiler metadata rather than a visual atlas slot.

Negative `cicn` IDs identify special land tiles and belong in the additive
`assets.catalog.specialLandTiles` collection. Ordinary `assets.catalog.icons`
retain their non-negative Classic resource identity. Remake can materialize a
referenced special land tile when that record provides a decoded 32 x 32 image
through `runtimeMedia`; `payloadPath` continues to identify only the immutable
Classic resource bytes.

Monster `id` selects a Data MD record. A monster's optional `nameId` is a separate
Classic byte used by ally and combat comparisons and must not be treated as a
record reference. Scenario-item records use `itemId`, including sparse fixed-size
rows whose other authored fields may all be zero.

A document may omit a collection when that collection is empty. If the collection
is present, it must be an array and every row must satisfy its identity contract.

Maps use namespaced string IDs such as `land:0` and `dungeon:3`. Random-level IDs
extend the same namespace, for example `land:0:randlevel`. Extra action points use
their source-backed trigger ID, such as `Data ED3:macro:100`, while their numeric
`recordIndex` remains available for opcode parameters.

Trigger action arrays contain occupied slots `0` through `7`. Each action carries
integer `slot`, `rawCode`, normalized `code`, and `id` fields. Simple and complex
encounters contain four contiguous eight-slot result rows, addressed as slots
`0` through `31`; those actions carry `slot`, `rawCode`, and `id`, and Remake
normalizes the signed opcode when it selects a result. Duplicate or out-of-range
slots and malformed action values fail bundle loading with record-level context.

## Authored data and preserved evidence

Runtime-relevant records may carry:

- `authored`, when Providence knows whether the semantic value was explicitly
  authored rather than decoded as a default or placeholder;
- `callable`, an optional boolean on `Data ED3` triggers indicating that the
  producer found a source-backed execution path to that extra action point;
- `provenance`, with source file, record index, byte range, and an evidence
  confidence label; and
- additional evidence-only fields for preserved or still-unknown source data.

All `Data ED3` rows remain in `scripts.triggers`, including imported rows that are
not callable. Remake inventories those rows but excludes `callable: false` actions
from readiness blockers unless it independently discovers a runtime entry path,
such as a battle or monster macro. For bundles that omit `callable`, Remake falls
back to the trigger's existing `active` field so version 1 producers retain their
original conservative audit behavior.

Remake uses the semantic fields and stable identities. It must not reinterpret
unknown preserved bytes as authored behavior. Unknown fields remain available for
diagnostics and future contract versions, while `evidence.json` records source
observations such as dispatcher no-ops that intentionally affect compatibility
decisions.

`rules.spellOverrides.id` is the zero-based `Data Spell` record index retained
for authoring and provenance. Remake derives the exact Classic runtime identity
used by encounter references from that fixed 7-by-15 record layout. Producers
may also include `packedSpellId`; when present, it must equal the derived value.
The consumer also accepts the one-based Data Spell row references stored by
encounter records. It checks the resolved override before the shared spell
table. Overrides with `special: 0` are exposed through Remake's ordinary spell
interface using their compiled damage, duration, save, resistance, targeting,
cost, and availability fields. A referenced nonzero `special` requires an exact
native implementation or produces an
`unsupported-custom-spell-special` readiness blocker at its `Data Spell` source
record.

## Runtime entry context

Map triggers start by stable trigger ID. Combat macro entry points additionally
supply live native context rather than serializing it into the bundle:

| Field | Meaning |
| --- | --- |
| `combatRound` | Current one-based native battle round |
| `battleMacro` | Compiled battle macro value, including its disabled sentinel |
| `queuedMacro` | Whether the macro entered through the queued/on-death path |
| `actorPosition` | Live native position of the creature that caused the macro |
| `actorFaction` | Live native faction of that creature |

The host supplies only the context available at that native event. The interpreter
owns Classic stack and branch state; the bundle never stores a live actor or an
interpreter continuation.

## Validation behavior

The consumer validates the complete manifest and document versions before indexing
records. Collection errors include the document, collection, and array index, for
example `scripts.triggers[4] is missing stable field 'id'`. Missing files and JSON
parse errors retain their path and parse line. A failed bundle remains unloaded and
must not partially populate runtime indexes.

Producers can validate any generated version 1 bundle without starting the game:

```powershell
godot --headless --path src --script res://scripts/classic_runtime/tests/validate_classic_bundle.gd -- "F:\path\to\bundle"
```

The command exits with status 0 only after every required document has passed the
consumer contract and its runtime indexes have been built. Status 1 identifies an
invalid bundle; status 2 identifies incorrect command-line usage.

Contract validity does not imply playability. The readiness command adds
executable-record, reference, identity, and native-resource checks and separates
progression blockers from non-fatal fidelity fallbacks:

```powershell
godot --headless --path src --script res://scripts/classic_runtime/tests/report_classic_readiness.gd -- "F:\path\to\bundle" "F:\path\to\native-campaign" --json
```

The native campaign path is optional. When provided, the report also checks the
shared and campaign resource names available to the Remake adapter.

## Independent fixture proof

Remake's consumer tests load the checked City of Bywater, War in the Sword Lands,
and Twin Sands of Time fixtures without a Providence checkout. They also load a
fixture through an absolute bundle-root path to prove that paths inside the
artifact remain portable and relative:

```powershell
godot --headless --path src --script res://scripts/classic_runtime/tests/run_classic_runtime_tests.gd
```

The checked `providence_authoritative_export` fixture is the unchanged output of
Providence commit `9b5c7d94ff6a59a81acc91be9f600c797b63f269`, generated from
`fixtures/scenario-seeds/authoritative-ownership-proof.seed.json`. Its companion
`providence_authoritative_export.provenance.json` records the byte count and
SHA-256 hash of all 14 producer files, plus the expected readiness result: no
progression blockers or fidelity fallbacks.

To regenerate the fixture, check out the recorded Providence commit and run its
`scripts/verify_remake_classic_export.ps1` gate. That script compiles the seed
twice, compares every generated byte, and passes the result to Remake's generic
validator. Copy the resulting `remake-classic-a` directory only when its complete
file manifest matches the companion provenance record.

This fixture proves producer determinism, consumer contract coverage, and
cross-repository interchange. Its managed payloads use
`payloadEncoding: classic-resource-data`; it does not yet prove decoded
Remake-native media adapter coverage. Remake's consumer tests cover the additive
`runtimeMedia` contract and native PNG, WAV, Ogg Vorbis, and MP3 loading
separately until the producer fixture includes derived files.

ISY-404 has a stricter content-coverage gate for item and monster
materialization. A candidate producer fixture must contain a scenario-local shop
item, a scenario-local item carried and equipped by a monster, a monster placed
in a battle, and an opcode 89 action that can add a compiled monster as an ally.
Audit a candidate bundle without installing it:

```powershell
godot --headless --path src --script `
  res://scripts/classic_runtime/tests/audit_classic_materialization_fixture.gd -- `
  "C:\path\to\classic-bundle"
```

The currently checked fixture covers the shop item and battle monster. The audit
deliberately remains unsuccessful until Providence's source fixture also exports
the carried/equipped item and ally action; consumer tests must not patch those
records and describe the result as producer-authored coverage. Once the audit
passes, the checked fixture provenance and full runtime suite remain the final
native installation and persistence gates.
