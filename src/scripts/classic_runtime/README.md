# Classic scenario runtime proof of concept

This directory contains a data-driven runtime proof of concept for Providence-compiled classic Realmz campaigns.

`ClassicCampaignBundle` validates and indexes the version 1 bundle. `ClassicRuntimeState` owns classic quest flags, map position, tile overrides, and trigger-percentage overrides. `ClassicActionInterpreter` executes AP action lists until it reaches a command that must be handled by native Godot UI, map, inventory, audio, or combat code. `ClassicRuntime` is the low-level Godot `Node` facade. `ClassicRuntimeHost` drives that facade through an injected command adapter, and `ClassicGodotCommandAdapter` is the first Remake-facing adapter.

Implemented opcodes in this slice:

- `1` Text
- `2` Battle request
- `3` Choice and choice continuation
- `4` Simple encounter request and result-block continuation
- `5` Complex encounter request and result-block continuation
- `9` Play sound
- `10` Give fixed treasure
- `12` Mutate a land or dungeon tile
- `13` Enable or disable one or more map triggers
- `20` Teleport and destination recheck
- `24` Keep codes / script completion
- `39` Extend actions through a Data ED3 AP
- `45` Teleport only
- `46` Branch on quest flag
- `47` Set or clear quest flag
- `56` Battle request with victory, coward-branch, and coward-penalty continuation
- `111` Return from GOSUB

Encounter result values select the corresponding eight-action block from `Data ED` or `Data ED2`. Battle outcome branches remain suspended until the host reports victory or cowardice. Persistent tile and trigger mutations are included in runtime snapshots; the bundle records themselves remain immutable.

Against the current Providence export of City of Bywater, these handlers cover 2,013 of 2,734 active action slots. Another 470 slots are skipped only because the bundle's source-backed dispatcher evidence identifies them as Realmz no-ops. Together, the proof of concept has defined behavior for 2,483 slots, or 90.8% of active slots. This is a semantic coverage measurement, not a playability percentage. Native command adapters and 251 action slots across 49 additional opcodes remain.

The interpreter does not yet reproduce encounter repetition limits or encounter-option mutation, and it will still stop explicitly when a selected encounter result contains an unsupported opcode. This keeps the compatibility boundary visible while more handlers are added.

## Godot guard-house playtest

The first in-engine vertical slice loads the CoB fixture, displays `Data DD:0:0` through Remake's existing `TextRect`, presents the four source-backed `Data ED` choices, feeds the selected result back to the interpreter, and runs that eight-action encounter result block.

Run the standalone scene from the repository root:

```powershell
Godot_v4.6.2-stable_win64.exe --path src res://scripts/classic_runtime/playtest/classic_guard_house_playtest.tscn
```

Pass a compiled campaign directory after `--` to use the full converter output instead of the checked-in fixture:

```powershell
Godot_v4.6.2-stable_win64.exe --path src res://scripts/classic_runtime/playtest/classic_guard_house_playtest.tscn -- "C:\path\to\realmz-remake-cob-poc-final"
```

This adapter intentionally handles only text, yes/no prompts, simple-encounter choices, and mapped sounds. Other typed commands stop with an explicit adapter error until their map, item, encounter, or battle resource adapters exist.

This remains a compatibility playtest rather than an installed Remake campaign. Classic bundles are not yet discovered through `src/Campaigns`, selected from the campaign UI, or persisted through the native profile/save system. `ClassicRuntimeState` snapshots are currently standalone; a shipping integration must bridge classic quest, tile, trigger, and position state into Remake's save lifecycle.

For a non-interactive smoke of the real HUD flow, add `--smoke`. The scene verifies the displayed intro, four encounter choices, selected outcome text, and completed host state, then exits:

```powershell
Godot_v4.6.2-stable_win64_console.exe --headless --path src res://scripts/classic_runtime/playtest/classic_guard_house_playtest.tscn -- --smoke
```

Run the headless proof from the repository root:

```powershell
Godot_v4.6.2-stable_win64_console.exe --headless --path src --script res://scripts/classic_runtime/tests/run_classic_runtime_tests.gd
```

Pass the path to a full compiled bundle after `--` to run the same loader against all CoB records:

```powershell
Godot_v4.6.2-stable_win64_console.exe --headless --path src --script res://scripts/classic_runtime/tests/run_classic_runtime_tests.gd -- "C:\path\to\realmz-remake-cob-poc-final"
```
