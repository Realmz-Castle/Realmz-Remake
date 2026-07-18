# Classic scenario runtime proof of concept

This directory contains the first data-driven runtime slice for Providence-compiled classic Realmz campaigns.

`ClassicCampaignBundle` validates and indexes the version 1 bundle. `ClassicRuntimeState` owns classic quest flags and map position. `ClassicActionInterpreter` executes AP action lists until it reaches a command that must be handled by native Godot UI, map, or combat code. `ClassicRuntime` is the Godot `Node` facade: map code activates a trigger, then UI/map/combat adapters consume `command_requested` and call `continue_after_command` when finished.

Implemented opcodes in this slice:

- `1` Text
- `2` Battle request
- `3` Choice and choice continuation
- `20` Teleport and destination recheck
- `24` Keep codes / script completion
- `39` Extend actions through a Data ED3 AP
- `45` Teleport only
- `46` Branch on quest flag
- `47` Set or clear quest flag
- `111` Return from GOSUB

Branch modes that enter simple or complex encounters yield a typed `start_encounter` command. Native Godot adapters and encounter execution are intentionally a later layer.

Against the current Providence export of City of Bywater, these handlers cover 1,510 of 2,734 active action slots. Another 470 slots are skipped only because the bundle's source-backed dispatcher evidence identifies them as Realmz no-ops. Together, the first slice has defined behavior for 72.4% of active slots; this is a semantic coverage measurement, not a playability percentage. Native command adapters and 754 action slots across 56 additional opcodes remain.

The highest-value next handlers by CoB frequency are Play Sound (`9`), New Land Icon (`12`), Give Treasure (`10`), Branch Battle Outcome (`56`), Enable/Disable Door (`13`), and the simple/complex encounter opcodes (`4` and `5`).

Run the headless proof from the repository root:

```powershell
Godot_v4.6.2-stable_win64_console.exe --headless --path src --script res://scripts/classic_runtime/tests/run_classic_runtime_tests.gd
```

Pass the path to a full compiled bundle after `--` to run the same loader against all CoB records:

```powershell
Godot_v4.6.2-stable_win64_console.exe --headless --path src --script res://scripts/classic_runtime/tests/run_classic_runtime_tests.gd -- "C:\path\to\realmz-remake-cob-poc-final"
```
