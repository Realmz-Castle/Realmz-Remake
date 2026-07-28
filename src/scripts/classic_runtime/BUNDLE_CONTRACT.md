# Realmz Remake scenario contract, version 2

This is the coordinated Providence-to-Remake runtime artifact. It is distinct
from Providence's editable project and its native Realmz export.

## Manifest

Every package contains `campaign.json`:

```json
{
  "format": "realmz-remake-scenario",
  "formatVersion": 2,
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
    "evidence": "classic/evidence.json",
    "runtime": "runtime.json"
  }
}
```

All nine document paths are required, unique, package-relative JSON paths.
Absolute paths, URI schemes, drive prefixes, empty segments, and parent
traversal are invalid. Every document currently uses `schemaVersion: 1`;
`formatVersion` versions the package as a whole.

Remake accepts only format 2. A format-1 package is rejected before indexing and
must be re-exported.

## Runtime document

`runtime.json` is required:

```json
{
  "schemaVersion": 1,
  "recommendedGameplayProfile": "core.classic",
  "requiredExtensions": [
    {
      "id": "scenario.example",
      "apiVersion": 1,
      "configuration": {}
    }
  ],
  "bindings": {
    "spells": {},
    "items": {},
    "encounters": {},
    "monsterAi": {},
    "lifecycle": {}
  },
  "targetSupport": {
    "remake": true,
    "nativeRealmz": true,
    "remakeOnlyReasons": []
  }
}
```

The recommended profile is advisory. Required extension IDs and API versions
must resolve against Remake's trusted built-in catalog during readiness.
Binding values must name capabilities declared by those extensions.

`targetSupport.nativeRealmz` is false when semantic operations or another
Remake-only feature is present. Providence blocks native Realmz export in that
case and reports the recorded reasons.

## Instruction union

Every occupied AP/XAP or encounter-result slot is explicit:

```json
{
  "kind": "classic",
  "slot": 0,
  "rawCode": -42,
  "code": 42,
  "id": 17,
  "gosub": true
}
```

```json
{
  "kind": "semantic",
  "slot": 1,
  "operation": "scenario.example.open_portal",
  "parameters": {
    "destination": "vault"
  }
}
```

Classic actions retain signed raw codes, normalized codes, IDs, slot identity,
provenance, evidence, and any additional preserved fields. Semantic operations
must be namespaced and declared by a required built-in extension. Generated
GDScript per AP/XAP is not part of the contract.

## Documents and identities

| Document | Collections | Stable identity |
| --- | --- | --- |
| `scenario` | Scenario identity and Classic shell metadata | `identity.id`, equal to the manifest ID |
| `maps` | Maps and optional player-map records | Namespaced map ID; numeric player-map ID |
| `scripts` | Triggers, Extra Codes, messages, random levels | String trigger/random-level ID; numeric source record ID |
| `encounters` | Battles, treasure, shops, simple/complex/thief/timed encounters | Numeric Classic record ID per collection |
| `content` | Monsters, scenario items, item text | Numeric Classic record ID; item text uses `itemId` |
| `rules` | Spell, race, and caste records | Numeric Classic rule ID per collection |
| `assets` | Managed payloads and media catalogs | String managed ID; numeric or signed Classic resource ID |
| `evidence` | Source observations and audit results | Source, record, slot, and raw action code |
| `runtime` | Profile, extensions, bindings, target support | Stable provider and extension IDs |

Array position is never identity. Duplicate identities, malformed references, or
out-of-range slots fail loading with document and record context.

## Assets and media

`payloadPath` identifies immutable packaged source bytes. Godot-loadable media is
separate:

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

The installer validates package-relative paths, byte counts, and hashes before
readiness. Pictures, icons, tilesets, special-land tiles, and player maps require
image media; sounds require supported audio media. Immutable Classic resource
fork bytes are never passed to Godot media loaders.

Built-in releases may use the existing content-addressed `ClassicAssets` store.
Imported packages remain self-contained.

## Data-only security boundary

Imported packages are rejected if any file has an executable type, including
`.gd`, `.gdc`, PCK, or native-library payloads. They cannot name a script path in
the manifest or runtime document. Remake never scans a campaign folder for
GDScript.

Only trusted descriptors shipped below
`res://scripts/scenario_runtime/extensions` can register handlers, ports, spell
providers, item behavior, encounter resolvers, monster AI, lifecycle hooks, or
gameplay-rule providers.

## Persistence

Package compatibility and save compatibility are separate. Scenario saves use
schema 3 and contain:

- the immutable campaign ID;
- scenario runtime mutations;
- VM continuation and its single pending-command record;
- aggregate state owned by the six ports; and
- the fully resolved gameplay provider IDs, API versions, and option values.

Older POC saves are rejected. Provider choices cannot change after a playthrough
starts, and restoration fails if a pinned provider or extension is unavailable.

## Producer and consumer gates

Providence must produce byte-identical repeated exports, identical browser and
desktop packages, and a runtime document matching its project
`remakeRuntime` section. Use:

```powershell
npm run check:authoritative-scenario-proof
```

Remake validates a package without starting the game:

```powershell
godot --headless --path src --script res://scripts/classic_runtime/tests/validate_classic_bundle.gd -- "F:\path\to\bundle"
```

The coordinated cross-repository verifier exports twice, compares bytes, runs
Providence package checks, and passes the output to Remake's consumer and
readiness gates:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/verify_remake_classic_export.ps1 `
  -ProvidenceRoot "F:\Realmz - Providence" `
  -RemakeRoot "F:\Realmz Remake"
```
