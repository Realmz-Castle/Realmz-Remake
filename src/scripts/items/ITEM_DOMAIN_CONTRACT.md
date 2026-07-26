# Stable item domain contract, version 1

This document is the completed M6 item contract. `stuff_book.json` remains the
native campaign-authoring format, and the Classic item materializer remains the
producer of campaign-local `stuff_book.json` records. Runtime inventory,
equipment, combat, UI, shops, loot, storage, encounters, and item hooks use
`ItemDefinition` plus `ItemInstance`; they do not keep a mirrored item
dictionary.

The checked fixture and its headless test are the executable examples:

```powershell
godot --headless --path src --script `
  res://scripts/items/tests/run_item_domain_contract_tests.gd
```

## Legacy behavior isolated at import

Before M6, `CampaignResources.generate_item_from_json_dict()` expanded a source
dictionary into another dictionary that contained all of these at once:

- catalog fields such as name, type, weight, restrictions, statistics, and
  Classic record identity;
- carried state such as current charges, identification, and equipped state;
- portable custom data such as hook source and compressed PNG bytes; and
- runtime-only values such as `Texture2D` and compiled `GDScript` objects.

That representation is now accepted only at catalog, old-save, and old-campaign
import boundaries. Successful import produces an `ItemInstance`; every new
save uses the versioned schema and never serializes a texture, script, callable,
or dictionary mirror.

## Domain boundary

### `ItemDefinition`

An `ItemDefinition` is an immutable, catalog-owned description of one kind of
item. It owns:

- stable identity and source provenance;
- display, image, sound, equipment, price, weight, restriction, statistic,
  damage, charge-limit, trait, and hook descriptors;
- explicit Classic identities and preserved Classic source/materialization
  data; and
- immutable extension data currently stored in `extra_data`.

It never owns current charges, current identification, equipped state, an
inventory owner, or an instance ID. Catalog clients receive a read-only
definition. Runtime media and compiled hooks are cache entries keyed by
`definitionId`; they are not fields on the definition.

The normalized fields are:

| Field | Required | Default | Validation |
| --- | --- | --- | --- |
| `definitionId` | yes | none | Non-empty, unique, and in one identity namespace below. |
| `catalogKey` | yes | none | Exact, case-sensitive key from `stuff_book.json`; non-empty. |
| `source.scope` | yes | none | `shared`, `campaign`, or `embedded`. |
| `source.campaignId` | yes | `""` for shared/embedded | Required and non-empty for campaign definitions. |
| `source.path` | yes | `""` for embedded | Diagnostic provenance; never used as identity. |
| `name` | yes | none | Non-empty display name. It is not identity. |
| `unidentifiedName` | yes | `name` | String. |
| `description` | yes | `""` | String. |
| `type` | yes | none | Non-empty string. |
| `imageKey` | yes | none | Existing `img_ptr`, or `embedded` when media is embedded. |
| `soundKey` | yes | `""` | Existing sound resource name. |
| `defaultIdentified` | yes | `false` when an unidentified name is authored, otherwise `true` | Boolean; an explicit legacy `is_identified` overrides the derived value during import. |
| `gameplay` | yes | normalized object below | JSON-compatible immutable gameplay data. |
| `hooks` | yes | normalized object below | Only source strings, resource names, arguments, and other JSON descriptors. |
| `classic` | yes | normalized empty object below | Positive numeric aliases plus preserved JSON-compatible evidence. |
| `media` | no | omitted | Only allowed for an embedded definition; encoded bytes, never a texture object. |

`gameplay` always contains these normalized fields:

| Field | Default |
| --- | --- |
| `magical`, `hands`, `unique`, `deleteOnEmpty`, `equippable` | `0` |
| `slots`, `onlyUsableByClasses`, `notUsableByClasses`, `onlyUsableByRaces`, `notUsableByRaces` | `[]` |
| `dropsOnDefeat` | `false` |
| `stats`, `weaponDamage`, `taggedWeaponDamage`, `extraData` | `{}` |
| `statsSummary` | `""` |
| `initialCharges`, `maxCharges`, `baseWeight`, `price`, `weightPerCharge` | `0` |
| `tradeable` | `1` |
| `splittable` | `0` |
| `ammoType` | `"cantuse"` |
| `meleeAnimation` | `"ATK_HTH"` when weapon damage exists, otherwise `""` |

`hooks` always contains:

- `sources`, an object containing authored hook or custom-trait source strings;
- `spellUses`, an object containing field/combat spell descriptors;
- `traits`, an array of trait resource/source descriptors; and
- `meleeInflictedTraits`, an array of trait descriptors.

The hook source spellings already accepted by the loader remain accepted by the
legacy adapter. A catalog validator reports unknown or conflicting spellings
with the source path and catalog key; it does not silently compile them.

`classic` always contains:

- `itemIds`, a de-duplicated array of positive integers, with the explicit
  `classicItemId` first and `classicItemIds` following in source order;
- `itemCategory`, `recordId`, `record`, and `materialization`, defaulting to
  `null`, `null`, `{}`, and `{}` respectively.

Negative Classic references are normalized with `abs()` for lookup, matching
the current compatibility layer. The original sign remains available in
preserved source evidence when it has separate meaning.

Unknown fields in a new definition are validation errors. A legacy import may
preserve unknown JSON-compatible definition fields under
`gameplay.extraData.legacyDefinitionFields` and emits a diagnostic. Non-JSON
values are never preserved.

### `ItemInstance`

An `ItemInstance` is a mutable, owner-held occurrence of one definition. It
owns only:

| Field | Required | Default | Validation |
| --- | --- | --- | --- |
| `instanceId` | yes | generated UUID for a new/imported instance | Non-empty and unique within a loaded save. |
| `definitionId` | yes | none | Must resolve in the active or save-local catalog. |
| `charges` | yes | definition `initialCharges` | Integer. The domain does not silently clamp legacy values. |
| `equipped` | yes | `false` | Boolean. Legacy values `1` and the transient save marker `2` import as `true`. |
| `identified` | yes | definition `defaultIdentified` | Boolean. |
| `stateData` | yes | `{}` | JSON-compatible per-instance extension state. |

Definition data is accessed through `definitionId`; it is not copied onto the
instance. Splitting an item creates a new `instanceId`. Combining items retains
one existing ID and discards the consumed ID. Moving an item between owners
retains its ID. Equipment slots refer to the instance ID, not a display name or
dictionary equality.

New-schema charge values outside a definition's supported range are validation
errors unless that definition explicitly opts into signed charges. The legacy
adapter retains existing signed values and emits a diagnostic so migration does
not change old save behavior.

## Identity rules

Identity strings are case-sensitive. Components after a namespace are
RFC 3986 percent-encoded UTF-8 source values: letters, digits, `-`, `.`, `_`,
and `~` remain literal, and every other byte uses uppercase `%HH`. Changing a
display name does not change identity.

1. A campaign definition with an explicit Classic item ID uses
   `classic:<campaignId>:<positive primary ID>`. `classicItemId` is primary;
   when only `classicItemIds` exists, its first source-order entry is primary.
   Additional explicit IDs are aliases for that same definition.
2. Another campaign-local definition uses
   `campaign:<campaignId>:<catalogKey>`.
3. A shared definition uses `shared:<catalogKey>`.
4. A definition recovered solely from self-contained save data uses
   `embedded:sha256:<digest>`.

Within one campaign, a Classic numeric ID may resolve to exactly one definition.
A collision, duplicate `definitionId`, empty key, malformed namespace, or
non-positive Classic ID rejects the catalog with source-specific diagnostics.
Campaign definitions can continue to shadow shared definitions for the
temporary legacy name lookup, but their stable IDs never collide.

The current Classic name map and item-text names are fallback discovery hints.
They never replace an explicit Classic ID and are never written as stable save
identity. `classicItemId`/`classicItemIds` remain supported input fields for M4
materialized records.

## Catalog and construction API

The catalog-level API has these semantics:

| Operation | Contract |
| --- | --- |
| `load_shared(directory)` | Load and validate the shared item pack without campaign identity. |
| `load_campaign(campaign_id, directory)` | Load campaign definitions after shared definitions; build stable-key, catalog-key, and Classic-ID indexes. |
| `get_definition(definition_id)` | Exact stable-ID lookup. No name fallback. |
| `resolve_catalog_key(scope, campaign_id, catalog_key)` | Exact source-key lookup; campaign scope may deliberately fall back to shared only when the caller requests it. |
| `resolve_classic_item(campaign_id, item_id)` | Resolve the positive numeric alias in campaign context, then explicit shared aliases; name heuristics belong only to the legacy/compatibility adapter. |
| `create_instance(definition_id, overrides = {})` | Validate the definition, assign an instance ID, apply definition defaults, then validate allowed state overrides. |
| `import_legacy_dictionary(value, context)` | Project an existing inventory dictionary into a definition plus instance and return migration diagnostics. |
| `register_embedded_definition(value)` | Validate a digest-addressed, save-local definition. It must not mutate the campaign catalog. |

Loading is transactional. Any validation error leaves the previous catalog
unchanged. Diagnostics include the source file, catalog key or definition ID,
field path, and reason. Callers never receive a partially initialized
definition or instance.

Runtime media and hook resolution are separate services:

- `imageKey` and optional embedded media resolve to a cached texture;
- hook source/resource descriptors resolve to cached compiled scripts; and
- hooks receive both the instance and its resolved definition.

Neither service changes serialized domain data.

### Public runtime API

Campaign and gameplay code uses `CampaignResources`:

| Operation | Result |
| --- | --- |
| `create_item_instance(item_identity, overrides = {})` | A new `ItemInstance` resolved by stable ID or exact active catalog key. |
| `create_classic_item_instance(item_id, overrides = {})` | A new instance resolved through explicit Classic definition metadata. |
| `get_item_definition(instance)` | The shared immutable `ItemDefinition` for an instance. |
| `item_classic_ids(instance)` | Instance-preserved legacy identity first, followed by the immutable definition aliases without duplicates. |
| `copy_item_instance(instance)` | A new instance with copied state and a distinct `instanceId`. |
| `serialize_item_inventory(instances)` | A transactional versioned save result. |
| `deserialize_item_inventory(saved)` | An array of stable instances, or an empty result with diagnostics. |
| `deserialize_item_inventory_preserving_unresolved(saved)` | Stable instances plus exact deferred payloads for valid catalog-backed definitions that are not loaded yet. |
| `item_texture(instance)` | Cached runtime media without adding media to instance state. |
| `item_has_hook(instance, kind)` / `run_item_hook(...)` | Definition-backed hook discovery and execution. |

`Creature.item_inventory` is the authoritative inventory. The historical
`Creature.inventory` property remains as a deprecated alias to that same
`Array[ItemInstance]` for campaign source compatibility; it is not a second
collection and never contains item dictionaries. Equipment properties likewise
return the owned instances. Mutation uses `add_inventory_item`,
`remove_inventory_item`, `transfer_inventory_item_to`, `equip_item`,
`unequip_item`, and `consume_item_charges`.

Item definitions expose typed accessors for display, weight, price, statistics,
damage, equipment slots, restrictions, traits, hook descriptors, and Classic
identity. Per-instance mutations belong in the `ItemInstance` fields or its
JSON-compatible `stateData`. A legacy hook that changes its temporary `name` or
`description` view is retained under `stateData.legacyMutableFields`; display
code reads that override without mutating the shared definition.

Profile loading ensures the shared item catalog is present before deserializing
versioned character inventories. Structurally valid campaign-owned references
remain as exact deferred payloads while the main-menu character picker has no
active campaign catalog. Loading a campaign retries those payloads, materializes
the definitions that now resolve, and retains any references owned by another
campaign for a later load. New saves append the deferred payloads unchanged.

## Versioned save format

Every new carried item serializes as:

```json
{
  "format": "realmz-remake-item-instance",
  "formatVersion": 1,
  "instanceId": "1edc4110-9f1f-4ea2-905d-89843a620c65",
  "definitionId": "shared:Dagger",
  "state": {
    "charges": 0,
    "equipped": true,
    "identified": true,
    "data": {}
  }
}
```

`embeddedDefinition` is the only optional root field. Catalog-backed items
serialize a reference and instance state only. The strict reader rejects an
unsupported format version, unresolved definition, duplicate instance ID,
invalid state, or malformed embedded definition with an inventory index in the
diagnostic. The profile-preservation reader may defer only an otherwise valid
versioned item whose catalog definition is not currently loaded.

Serialized data contains JSON scalars, arrays, and string-keyed objects only.
It excludes textures, images, nodes, resources, callables, compiled scripts,
object handles, and the runtime keys:

`texture`, `script`, `_on_equipping`, `_on_unequipping`, `_on_field_use`,
`_on_combat_use`, `_on_drop`, `_calculate_melee_attack`, and
`_calculate_melee_accuracy`.

Hook *source* and spell/trait descriptors are definition data and remain
portable. They are allowed in an embedded definition.

### Self-contained custom item policy

An old character can contain an item that no installed catalog can resolve.
The legacy adapter normalizes its portable definition fields and attaches that
definition as `embeddedDefinition`. It may include:

- `media.encoding = "gzip+base64-png"`, `media.data`, and the uncompressed
  `media.bytes` value derived from current `imgdata`/`imgdatasize`; and
- hook/custom-trait source strings and JSON descriptors.

The adapter computes SHA-256 over canonical UTF-8 JSON for the normalized
definition payload, excluding `definitionId` and `digest`. Object keys are
lexicographically sorted and no insignificant whitespace is present. The
definition ID is `embedded:sha256:<digest>`, and `digest` is stored beside the
payload. A reader recomputes it before registration.

For an unresolvable legacy dictionary, `charges` is current instance state.
The embedded definition derives `initialCharges` from `charges_max`, or `0`
when no maximum was authored, so a partly consumed item does not redefine every
future instance of its recovered definition.

Embedded definitions live in a save-local catalog and cannot shadow installed
IDs. Identical digests coalesce. If an exact installed definition ID exists,
the installed definition is used; embedded data with a non-matching digest or
identity is an error rather than an implicit override.

### Serializer evolution

Readers dispatch on both `format` and `formatVersion`. Version 1 accepts only
the documented root and state fields. A future migration must add a new reader,
convert transactionally to the current in-memory model, and preserve the
original inventory if any entry fails. Writers emit one current version only;
they do not silently add fields to version 1. Unsupported future versions fail
with the inventory index and version in the diagnostic.

Definition IDs and instance IDs are durable. Serializer migrations may
normalize representation but must not regenerate either ID for already
versioned items. New optional per-instance behavior belongs in `state.data`;
new immutable authored behavior belongs in a new validated definition field.

## Legacy dictionary import

ISY-412 keeps existing characters readable through this ordered import:

1. Require a dictionary and collect only JSON-compatible values.
2. Resolve an explicit future `definitionId`, then explicit
   `classicItemId`/`classicItemIds` in campaign context, then exact current
   `KEY`/catalog key, and finally the current exact `name` fallback.
3. If a catalog definition resolves, create an instance and copy only carried
   state: `charges`, `equipped`, `is_identified`, and known per-instance state.
4. If no definition resolves, normalize portable definition fields and register
   an embedded definition under its canonical digest.
5. Drop runtime-only values, preserve encoded media and hook source, and report
   every default, discarded field, ambiguity, and retained unknown field.
6. Keep the legacy dictionary unchanged until the caller accepts the complete
   conversion. A failed conversion never partially mutates an inventory.

This adapter is deliberately compatibility-only. New saves written after
ISY-412 use the versioned format even when they were loaded from an old
dictionary.

## Custom campaign authoring

Native campaigns author items in their campaign `Items/stuff_book.json`.
Shared items live in `shared_assets/items/stuff_book.json`. A campaign record
may shadow a shared catalog key for that campaign while retaining its own
stable campaign or Classic definition ID. The loader validates the complete
book transactionally, including media keys, hook descriptors, restrictions,
Classic-ID collisions, and JSON portability.

Compiled Classic campaigns continue to produce campaign-local
`stuff_book.json`; explicit `classicItemId` or `classicItemIds` metadata is the
supported bridge to numeric records. Authors should not construct runtime item
dictionaries or append copied catalog rows. They create an instance through
`create_item_instance` or `create_classic_item_instance`, then add that instance
through the creature, shop, loot, storage, or encounter API.

An old campaign may still hand an item dictionary to an import-aware public
entry point. That input is converted immediately, and only portable source data
can become an embedded definition. This is a compatibility route, not the
native authoring API.

## Retained compatibility boundaries

The dictionary adapter may exist at these boundaries only:

- `stuff_book.json` and M4 Classic materializer input into the catalog;
- old character/save inventory import;
- old campaign scripts and Classic rule adapters that require their historical
  dictionary-shaped arguments.

The last case uses `legacy_item_view_for_adapter()` and synchronizes only
supported mutable instance state back into the stable instance. Deprecated
method spellings remain in `CampaignResources` solely so installed old
campaigns do not fail method lookup. Migrated runtime and UI consumers do not
call them.

The temporary live dictionary mirror was removed by ISY-416 after:

- creature inventory, equipment, combat, UI, shops, loot, storage, encounters,
  scripted hooks, and Classic compatibility consume the stable API;
- new saves contain no raw inventory dictionaries and old saves still import
  through focused compatibility tests;
- repository search finds no item mutation by dictionary field outside the
  adapter and fixture code;
- fixture/campaign tests prove shared, campaign-local, Classic-ID, and embedded
  custom items across save/load; and
- a full gameplay regression run proves no item behavior change.

The catalog input adapter, old-save reader, and explicitly named old-campaign
projection remain supported compatibility surfaces. There is no persistent
runtime dictionary view.

## Conformance and regression commands

Run these from the repository root:

```powershell
godot --headless --path src --script `
  res://scripts/items/tests/run_item_catalog_tests.gd
godot --headless --path src --script `
  res://scripts/items/tests/run_item_serialization_tests.gd
godot --headless --path src --script `
  res://scripts/items/tests/run_item_domain_contract_tests.gd
godot --headless --path src --script `
  res://scripts/items/tests/run_item_hook_tests.gd
godot --headless --path src `
  res://scripts/items/tests/creature_item_instance_smoke.tscn
godot --headless --path src `
  res://scripts/items/tests/item_ui_flow_smoke.tscn
godot --headless --path src --script `
  res://scripts/items/tests/run_item_migration_conformance_tests.gd
```

The focused suites cover shared and campaign catalogs, independent instances,
old dictionaries, embedded custom definitions, versioned save/load, hooks,
creature inventory and combat handoff, inventory UI, shop purchase and sale,
loot, storage, encounter item selection, and source-boundary conformance.
Classic runtime and City of Bywater acceptance suites cover compiled campaign
item identities and live Classic combat behavior. The stock-character builder
also uses deterministic instance IDs; two consecutive builds must produce
byte-identical roster packages.

## M6 dependency order

The migration is intentionally dependency-ordered:

1. **ISY-410** — freeze this domain, identity, serialization, and adapter
   contract.
2. **ISY-411** — implement definitions, instances, catalog indexes, validation,
   and construction without migrating consumers.
3. **ISY-412** — implement versioned serialization and legacy dictionary
   import while current runtime dictionaries still work.
4. **ISY-413** — migrate creature inventory, equipment, combat, and item state.
5. **ISY-414** — migrate UI, shops, loot, storage, and encounter consumers.
6. **ISY-415** — migrate scripted hooks and the Classic compatibility adapters.
7. **ISY-416** — run conformance coverage and remove the temporary runtime
   dictionary view.

ISY-411 depends on this contract. ISY-412 depends on ISY-411. ISY-413 depends
on ISY-411 and ISY-412. ISY-414 and ISY-415 depend on ISY-413; both must finish
before ISY-416.
