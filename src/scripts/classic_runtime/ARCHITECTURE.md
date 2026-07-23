# Classic compatibility ownership and extension points

Classic compatibility is an alternate scenario execution path, not a second game
runtime. Realmz Remake continues to own campaign selection, native resources, maps,
combat, UI, and saves. The Classic runtime owns only behavior that is specific to
compiled Realmz scenarios: action execution, stack rules, suspended continuations,
and persistent mutations of the compiled records.

## Native owners

| Area | Remake owner | Classic integration |
| --- | --- | --- |
| Campaign discovery and selection | `Paths.campaignsfolderpath`, `NewCampaignPanel`, and `GameGlobal.set_current_campaign()` | Detect the Classic manifest inside an otherwise normal campaign directory and create one runtime host for the selected campaign. The Classic runtime must not scan for campaigns or maintain a second current-campaign value. |
| Campaign resources | `Resources.load_campaign_ressources()` and the books exposed by `NodeAccess.__Resources()` | Load compatible maps, items, monsters, spells, pictures, and sounds through the native resource lifecycle. `ClassicCampaignBundle` indexes normalized Classic documents that have no native resource representation; it does not replace the native books. |
| Map loading and rendering | `Resources.load_map_ressources()`, `Map.load_map()`, and `GameGlobal.change_map()` | Resolve a compiled map identity to a native map and apply the effective `ClassicRuntimeState` overrides through the command adapter. The interpreter describes a transition or mutation but does not render or load maps itself. |
| Map trigger dispatch | `game_state.check_map_script()` and the loaded map's `map_scriptareas.json` / `map_scripts.gd` | A native script area can name a compiled trigger by its stable ID. The map-event boundary retains coordinate and chance ownership, then delegates that ID to the registered `ClassicRuntimeHost`; unrecognized names continue through the native map script. |
| Encounters, services, inventory, and presentation | `ScriptHelperFuncs`, `GameGlobal`, and the native HUD controls | `ClassicGodotCommandAdapter` translates yielded commands into existing helpers and controls where their behavior matches. Classic branching and result-loop semantics remain in the interpreter. |
| Battle lifecycle | `GameGlobal.start_battle()`, `GameGlobal.end_battle()`, and `StateMachine` combat state | Convert a compiled battle request into native battle data, suspend the interpreter, and resume it once the native battle reports an outcome. Combat action points and macros enter from native battle events. |
| Persistence | The profile save/load flow in `save_load_rect.gd` and `GameGlobal` | Store a versioned Classic snapshot inside the native campaign save. Do not create a parallel save file. The snapshot covers compatibility-owned mutations and suspended continuations only. |

## Compatibility-owned components

These components are intentionally separate from the native owners:

- `ClassicCampaignBundle` validates the Providence bundle and builds read-only
  indexes for Classic records. Native resource loading does not understand these
  normalized action, encounter, and evidence documents.
- `ClassicMapMaterializer` is the single compiled-map-to-native-map boundary. The
  package installer runs it in staging, before the normal campaign resource
  lifecycle sees the package. It writes only Remake's existing map and tileset
  formats and does not parse Classic files or add another map loader. Dungeon
  field values become campaign-local native tiles composed from the shared
  PICT 302 overhead sprites, with the signed Classic field retained as tile
  metadata. Stock landlooks combine Remake's decoded Realmz PICT atlases with the
  compiler's tile-attribute table, preserving Classic's one-based atlas order and
  movement rules instead of translating them to a similarly themed Remake sheet.
  Decoded custom landlooks use the same native format with their exported 640 x
  320 atlas and behavior table. Decoded special-land media becomes a second
  campaign-local tile layer; immutable Classic resource bytes remain outside
  Godot's image loader.
- `ClassicRuntimeState` holds Classic mutations that cannot be written back to the
  installed campaign. Its snapshot is payload for the native save system, not a
  competing save owner.
- `ClassicActionInterpreter` implements Classic control flow and stack behavior.
  Translating that state machine into independent native scripts would change the
  semantics of some cross-action-point jumps and returns.
- `ClassicRuntimeHost` and `ClassicGodotCommandAdapter` form the boundary between
  the interpreter and Remake. Native calls belong in the adapter; Classic rules do
  not.
- The standalone playtest scenes are development fixtures. Normal campaigns will
  launch the same host through the standard campaign flow.

`GameGlobal.register_classic_runtime_host()` stores a non-owning reference for the
selected campaign. Campaign lifecycle code remains responsible for creating,
configuring, attaching, and clearing that host. Once native resources are loaded,
`ClassicRuntimeHost.activate_start_location()` applies the compiled starting map,
position, and view state and requests entry through the same map-event boundary.

The compiled bundle remains immutable while a game is running. Any mutable value
must either live in an existing native owner or in `ClassicRuntimeState`, with one
clear serialization path between them.

## Relationship to the dump importer

The dump importer proposed in [PR 86](https://github.com/Realmz-Castle/Realmz-Remake/pull/86)
generates `map_scriptareas.json` and `map_scripts.gd` as a starting point for a
hand-maintained native port. That remains a useful optional authoring path, but it
is not a dependency of compatibility mode.

Compatibility mode consumes Providence's normalized compiled data directly and
does not need its own text-dump parser or GDScript emitter. The two paths should
share Remake's native map, helper, resource, and battle entry points. They should
not share scenario control-flow ownership: generated native scripts own their own
flow, while compiled Classic campaigns remain under `ClassicActionInterpreter`.

## Integration rule

New compatibility work should first identify the native owner and add the smallest
adapter entry point that owner needs. Add behavior to the interpreter only when it
is a Classic rule, and add state to `ClassicRuntimeState` only when no native owner
already preserves the value.

Native campaign resources remain the rendered map owner. After those resources
are loaded or rebuilt, `ClassicRuntimeHost.reapply_map_state()` projects the
effective compatibility-owned mutations into `maps_book`; it does not reload the
map, change the compiled bundle, or become a second current-map owner.
