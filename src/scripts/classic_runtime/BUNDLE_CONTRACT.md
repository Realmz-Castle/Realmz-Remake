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
| `encounters` | `battles`, `treasures`, `shops`, `simpleEncounters`, `complexEncounters`, `thiefEncounters` | Numeric Classic record ID within each collection |
| `content` | `monsters`, `scenarioItems`, `itemTexts` | Numeric Classic record ID; item text uses `itemId` |
| `rules` | Spell, race, and caste overrides plus rule names | Numeric Classic rule ID within its collection |
| `assets` | Managed assets and the tileset, picture, icon, and sound catalogs | Numeric Classic `resourceId` within each catalog |
| `evidence` | Validation results, dispatcher no-ops, and source evidence | Source file, record index, slot, and raw action code together identify an action observation |

Stable identities come from the compiled Classic record namespace; array position
is never an identity. Action slots are addressed by their owning trigger ID plus
their zero-based `slot`. Duplicate identities within one collection are invalid.
References retain their Classic numeric ID even when a later native adapter also
needs a Remake resource name.

A document may omit a collection when that collection is empty. If the collection
is present, it must be an array and every row must satisfy its identity contract.

Maps use namespaced string IDs such as `land:0` and `dungeon:3`. Random-level IDs
extend the same namespace, for example `land:0:randlevel`. Extra action points use
their source-backed trigger ID, such as `Data ED3:macro:100`, while their numeric
`recordIndex` remains available for opcode parameters.

## Authored data and preserved evidence

Runtime-relevant records may carry:

- `authored`, when Providence knows whether the semantic value was explicitly
  authored rather than decoded as a default or placeholder;
- `provenance`, with source file, record index, byte range, and an evidence
  confidence label; and
- additional evidence-only fields for preserved or still-unknown source data.

Remake uses the semantic fields and stable identities. It must not reinterpret
unknown preserved bytes as authored behavior. Unknown fields remain available for
diagnostics and future contract versions, while `evidence.json` records source
observations such as dispatcher no-ops that intentionally affect compatibility
decisions.

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

The current Remake contract tests load the checked City of Bywater, War in the
Sword Lands, and Twin Sands of Time fixtures. They also load a fixture through an
absolute bundle-root path to prove that only the paths inside the artifact are
portable and relative.
