# Classic scenario runtime proof of concept

This directory contains a data-driven runtime proof of concept for normalized classic Realmz bundles produced by a separate Providence-based converter.

`ClassicCampaignBundle` validates and indexes the version 1 bundle. `ClassicRuntimeState` owns classic quest flags, map position, tile overrides, trigger-percentage overrides, and persistent action-point replacements. `ClassicActionInterpreter` executes AP action lists until it reaches a command that must be handled by native Godot UI, map, inventory, audio, or combat code. `ClassicRuntime` is the low-level Godot `Node` facade. `ClassicRuntimeHost` drives that facade through an injected command adapter, and `ClassicGodotCommandAdapter` is the first Remake-facing adapter. That boundary can reuse existing Remake helpers wherever their behavior matches Classic while keeping compatibility-specific control flow inside the interpreter.

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
- `19` Display a random string from an inclusive message range
- `20` Teleport and destination recheck
- `24` Keep codes / script completion
- `25` Remove and persist the active action point at its destination
- `39` Extend actions through a Data ED3 AP
- `45` Teleport only
- `46` Branch on quest flag
- `47` Set or clear quest flag
- `56` Battle request with victory, coward-branch, and coward-penalty continuation
- `111` Return from GOSUB
- `112` Pop one GOSUB frame without returning

The interpreter preserves Classic's unusual stack semantics: a negative action enables a sticky GOSUB mode, positive actions only clear that mode when the stack is empty, and branch opcodes may therefore push even when their own action code is positive. Returns are explicit through opcode `111`; merely reaching the end of an action point does not unwind the stack. Stack depth is capped at Classic's 20 frames with a safe runtime error instead of writing past the original fixed-size arrays. A focused War in the Sword Lands fixture exercises a shipped three-frame GOSUB chain and verifies the exact XAP return order.

Opcode `25` follows Classic's deferred door rewrite. It clears the GOSUB stack, captures the party position, and waits for the action point to finish. If the active door then moves the party, the current action list is copied into the destination map's matching door slot and its target is changed to the captured position. Data ED3 branches replace only that action list; the originating map door header remains active. These replacements live in runtime state and snapshots, leaving the compiled campaign bundle immutable. A focused Twin Sands of Time fixture exercises the shipped same-level relocation case.

Encounter result values select the corresponding eight-action block from `Data ED` or `Data ED2`. Battle outcome branches remain suspended until the host reports victory or cowardice. Persistent tile, trigger, and action-point mutations are included in runtime snapshots; the bundle records themselves remain immutable.

The complex-encounter adapter exposes the eight Classic action-text fields through Remake's existing HUD choice control and routes each selection to the record's shared action result. This covers the active non-rogue library, cave-in, and pool encounters in City of Bywater. Encounters with magic responses can open Remake's native spell picker, match the selected spell against the packed Classic IDs, consume its normal spell-point cost, and continue through the paired result block. Item responses similarly use Remake's encounter inventory picker and match the selected item's shared mapping or scenario item text against the five Classic response slots. Unmatched spells and items use Classic's Result 4 fallback. Low spell IDs `1` through `6` remain supported when a Remake spell supplies explicit Classic spell-class metadata; current shared spell resources do not yet preserve that field. Mixed rogue encounters keep action, spell, and item choices beside their `Data TD2` controls. The rogue resolver uses the selected character's Remake stat plus the Classic modifier, preserves Classic's 90-percent cap for interactive lock/trap actions, and routes success or failure into the four `Data ED2` result rows. Consumed rogue actions persist in runtime snapshots while the compiled record remains immutable. The source-backed CoB lock at `Data DD:5:12` exercises Detect Trap, Force Lock, Pick Lock, and the Necklace of Keys response. The trapped chest at `Data DD:5:3` applies its shipped 4-12 damage to the selected rogue, clears the armed state, and leaves Pick Lock available before continuing through result 2.

Against the current Providence export of City of Bywater, these handlers cover 2,032 of 2,734 active action slots. Another 470 slots are skipped only because the bundle's source-backed dispatcher evidence identifies them as Realmz no-ops. Together, the proof of concept has defined behavior for 2,502 slots, or 91.5% of active slots. This is a semantic coverage measurement, not a playability percentage. Native command adapters and 232 action slots across 48 additional opcodes remain.

The interpreter does not yet reproduce encounter repetition limits or encounter-option mutation, and it will still stop explicitly when a selected encounter result contains an unsupported opcode. Trap spells, scroll-as-spell and door-activation encounter items, spoken-word responses, imported spell-class metadata, party-target spell side effects, and Classic's timed tumbler minigame also remain explicit boundaries. This keeps the compatibility boundary visible while more handlers are added.

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

This adapter intentionally handles text, yes/no prompts, simple-encounter choices, complex action and spell responses, data-driven rogue encounters, trap damage, fixed treasure through Remake's loot UI, and mapped sounds. Other typed commands stop with an explicit adapter error until their map, encounter, or battle resource adapters exist.

This remains a compatibility playtest rather than an installed Remake campaign. Classic bundles are not yet discovered through `src/Campaigns`, selected from the campaign UI, or persisted through the native profile/save system. `ClassicRuntimeState` snapshots are currently standalone; a shipping integration must bridge classic quest, tile, trigger, and position state into Remake's save lifecycle.

For a non-interactive smoke of the real HUD flow, add `--smoke`. The scene verifies the displayed intro, four encounter choices, selected outcome text, and completed host state, then exits:

```powershell
Godot_v4.6.2-stable_win64_console.exe --resolution 1100x619 --path src res://scripts/classic_runtime/playtest/classic_guard_house_playtest.tscn -- --smoke
```

The lock playtest loads CoB's source-backed `Data ED2:4` and `Data TD2:4` records. It supplies a playtest-only rogue when no party is loaded:

```powershell
Godot_v4.6.2-stable_win64.exe --path src res://scripts/classic_runtime/playtest/classic_lock_playtest.tscn
```

Its HUD smoke verifies the complex prompt, three available rogue controls, two authored encounter actions, back-out, and host completion:

```powershell
Godot_v4.6.2-stable_win64_console.exe --resolution 1100x619 --path src res://scripts/classic_runtime/playtest/classic_lock_playtest.tscn -- --smoke
```

The trapped-chest playtest loads CoB's source-backed `Data ED2:3` and `Data TD2:1` records. Picking the armed lock springs its rogue-only damage trap; the smoke verifies the 4-12 HP loss, changed choices, persistent state, and host completion:

```powershell
Godot_v4.6.2-stable_win64.exe --path src res://scripts/classic_runtime/playtest/classic_trap_playtest.tscn
Godot_v4.6.2-stable_win64_console.exe --resolution 1100x619 --path src res://scripts/classic_runtime/playtest/classic_trap_playtest.tscn -- --smoke
```

The cave-in playtest exercises a non-rogue complex encounter from its three authored action labels through the selected `Data ED2` result block:

```powershell
Godot_v4.6.2-stable_win64.exe --path src res://scripts/classic_runtime/playtest/classic_complex_action_playtest.tscn
Godot_v4.6.2-stable_win64_console.exe --resolution 1100x619 --path src res://scripts/classic_runtime/playtest/classic_complex_action_playtest.tscn -- --smoke
```

The spell variant supplies a playtest caster with Dig Hole, selects it through Remake's native spell menu, and verifies the packed `1201` response, spell-point cost, and Result 1 continuation:

```powershell
Godot_v4.6.2-stable_win64.exe --path src res://scripts/classic_runtime/playtest/classic_complex_spell_playtest.tscn
Godot_v4.6.2-stable_win64_console.exe --resolution 1100x619 --path src res://scripts/classic_runtime/playtest/classic_complex_spell_playtest.tscn -- --smoke
```

The item variant gives the playtest rogue a Necklace of Keys, selects it through Remake's encounter inventory picker, and verifies the source-backed Result 1 response without consuming the key:

```powershell
Godot_v4.6.2-stable_win64.exe --path src res://scripts/classic_runtime/playtest/classic_complex_item_playtest.tscn
Godot_v4.6.2-stable_win64_console.exe --resolution 1100x619 --path src res://scripts/classic_runtime/playtest/classic_complex_item_playtest.tscn -- --smoke
```

The HUD smoke intentionally uses the normal display driver because the project's shutdown handler persists the active window size to `src/override.cfg`; a headless HUD run would save `0x0` and dirty the worktree.

Run the headless proof from the repository root:

```powershell
Godot_v4.6.2-stable_win64_console.exe --headless --resolution 1100x619 --path src --script res://scripts/classic_runtime/tests/run_classic_runtime_tests.gd
```

Pass the path to a full compiled bundle after `--` to run the same loader against all CoB records:

```powershell
Godot_v4.6.2-stable_win64_console.exe --headless --resolution 1100x619 --path src --script res://scripts/classic_runtime/tests/run_classic_runtime_tests.gd -- "C:\path\to\realmz-remake-cob-poc-final"
```
