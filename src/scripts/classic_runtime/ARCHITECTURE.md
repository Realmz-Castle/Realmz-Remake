# Modular scenario runtime v2

Scenario format v2 has one campaign-execution path. `ScenarioInterpreter` owns
instruction position, trigger identity, GOSUB frames, encounter origins, execution
limits, trace state, pending commands, snapshots, and restoration. Campaign
folders provide data and media only; they never provide executable GDScript.

## Runtime boundaries

| Boundary | Owner | Contract |
| --- | --- | --- |
| Scenario execution | `ScenarioInterpreter` and `ScenarioInstructionRegistry` | Resolve every Classic opcode or namespaced semantic operation to exactly one handler. Apply `ScenarioStepResult` control flow centrally. |
| Classic semantics | handler families and `ClassicOpcodeRuntime` under `scenario_runtime/handlers` | Each registered family performs the opcode dispatch it owns. The runtime supplies shared source-backed mechanics and a direct-fixture compatibility loop, not a second production campaign engine. |
| Command continuation | `ScenarioPendingCommand` and `ClassicContinuationRouter` | Persist one handler ID, command ID, action identity, and typed continuation record. Resume through the owning handler and continuation ID without a host command-name switch. |
| Godot integration | `ScenarioCommandRouter` and six ports | Only ports may route commands to the Godot service boundary. Duplicate command ownership is a startup error. |
| Trusted extensions | `ScenarioExtensionRegistry` | Load only descriptors and scripts shipped under `res://scripts/scenario_runtime/extensions`. Imported packages may reference IDs and configuration, never code paths. |
| Gameplay rules | `GameplayRuleRegistry` and `GameplayRuleSet` | Resolve independently selectable domain providers, validate typed options, and pin the complete result in the save. |
| Campaign persistence | `ClassicCampaignSession`, `PersistencePort`, and the native save envelope | Store VM continuation, runtime state, all port state, and the resolved ruleset in save schema 3. |

## Six Godot ports

- `MapPort` owns maps, movement, transitions, clock, scheduling, mutation, and
  exploration commands.
- `CombatPort` owns battle construction, combatants, macros, morale, rewards,
  damage, and combat spell integration.
- `InventoryPort` owns item identity, treasure, shops, wealth, equipment,
  charges, storage, item hooks, and its serialized state.
- `CharacterPort` owns selection, statistics, progression, conditions, health,
  allies, abilities, and field spell integration.
- `PresentationPort` owns text, choices, pictures, sound, encounter UI,
  animation, and pacing.
- `PersistencePort` owns save policy, aggregate validation, and port-state
  snapshot/restoration.

`ScenarioGodotServices` contains reusable implementations behind those ports. It
does not own command IDs or scenario continuation.

Classic mechanics likewise store only one `pendingContinuation` record. The
typed `pending_choice`, `pending_battle`, and similar properties are derived
compatibility views for focused source-fidelity fixtures and are not serialized
as independent continuation state.

## Campaign lifecycle

Campaign discovery lists only directories with a `realmz-remake-scenario` v2
manifest. `ClassicCampaignInstall` rejects executable payloads before readiness.
Map materialization writes data and media but no `map_scripts.gd`. Map trigger
names are dispatched directly to the registered scenario VM; an unregistered
trigger is an error and never falls through to a returned GDScript name.

The old native `on_select.gd`, `on_campaign_start.gd`,
`campaign_global_script.gd`, `shops.gd`, battle-source compiler, scenario spell
scripts, creature scripts, and map-script executor are not part of campaign
startup. The retained native campaign folders are source fixtures only.

## Extension and reservation rules

Extension IDs and semantic operations are namespaced, normally
`scenario.<campaign-id>.*`. Core opcode IDs, `core.*` commands, and `core.*`
gameplay providers are reserved. Extensions are additive and cannot replace a
core registration.

The built-in `scenario.runtime-fixture` extension exercises semantic operations,
commands, spells, item behavior, encounter resolution, monster AI, lifecycle
hooks, and a gameplay-rule provider. Its descriptor is also the catalog fixture
consumed by Providence.

## Rule profiles

`core.classic` is the default for compiled Classic scenarios and records the POC
fidelity baseline. `core.samuel` records behavior characterized from
`origin/dev@f44a53df`. A new game may mix Map/Time, Combat, Inventory, Character,
Presentation, and Persistence providers and valid provider options. The campaign
may recommend a preset but cannot override the player selection. A running
playthrough cannot change its pinned providers or options.

## Compatibility break

Bundle v1 and save schemas before 3 are intentionally rejected with an upgrade
message. Re-export old bundles through Providence and start a new playthrough.
