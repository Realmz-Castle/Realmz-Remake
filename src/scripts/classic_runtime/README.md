# Classic scenario runtime proof of concept

This directory contains a data-driven runtime proof of concept for normalized classic Realmz bundles produced by a separate Providence-based converter.

`ClassicCampaignBundle` validates and indexes the version 1 bundle. `ClassicRuntimeState` owns classic quest flags, map position, view mode, per-map random-level settings, tile overrides, trigger-percentage overrides, acquired player maps, and persistent encounter and action-point replacements. `ClassicActionInterpreter` executes AP action lists until it reaches a command that must be handled by native Godot UI, map, inventory, audio, or combat code. `ClassicRuntime` is the low-level Godot `Node` facade. `ClassicRuntimeHost` drives that facade through an injected command adapter, and `ClassicGodotCommandAdapter` is the first Remake-facing adapter. That boundary can reuse existing Remake helpers wherever their behavior matches Classic while keeping compatibility-specific control flow inside the interpreter.

Implemented opcodes in this slice:

- `1` Text
- `2` Battle request
- `3` Choice and choice continuation
- `4` Simple encounter request and result-block continuation
- `5` Complex encounter request and result-block continuation
- `6` Load a Classic shop into Remake's native shop state
- `7` Copy Data ED3 actions into a map AP or encounter result
- `8` Execute another AP from the currently loaded map
- `9` Play sound
- `10` Give fixed treasure
- `11` Award party experience
- `12` Mutate a land or dungeon tile
- `13` Enable or disable one or more map triggers
- `14` and `-14` Pick characters or the inverse of a picked group
- `15` Damage or heal picked characters
- `16` Damage or heal the party
- `19` Display a random string from an inclusive message range
- `20` Teleport and destination recheck
- `23` Alter a land or dungeon random-encounter rectangle
- `24` Keep codes / script completion
- `25` Remove and persist the active action point at its destination
- `29` Acquire a player map and optionally display it
- `30` Pick characters by an attribute or special-ability check
- `35` Eliminate and persist an option in the current simple encounter
- `37` Move between land and dungeon maps with Classic heading/view state
- `39` Extend actions through a Data ED3 AP
- `41` Eliminate and persist an option in any simple encounter
- `42` Branch on percent chance
- `44` Eliminate and persist one complex-encounter result
- `45` Teleport only
- `46` Branch on quest flag
- `47` Set or clear quest flag
- `52` Pick characters by movement, position, item, chance, save, or current selection
- `56` Battle request with victory, coward-branch, and coward-penalty continuation
- `57` Change a land level's visual set and darkness
- `58` Branch on Classic difficulty level
- `73` Load a Classic shop with two item-acceptance ranges
- `93` Enable compass updates
- `94` Disable compass updates
- `95` Set or randomize the current view direction
- `96` Require the 3D view
- `97` Allow the full map view
- `106` Set per-map darkness
- `111` Return from GOSUB
- `112` Pop one GOSUB frame without returning

The interpreter preserves Classic's unusual stack semantics: a negative action enables a sticky GOSUB mode, positive actions only clear that mode when the stack is empty, and branch opcodes may therefore push even when their own action code is positive. Returns are explicit through opcode `111`; merely reaching the end of an action point does not unwind the stack. Stack depth is capped at Classic's 20 frames with a safe runtime error instead of writing past the original fixed-size arrays. A focused War in the Sword Lands fixture exercises a shipped three-frame GOSUB chain and verifies the exact XAP return order.

Opcode `25` follows Classic's deferred door rewrite. It clears the GOSUB stack, captures the party position, and waits for the action point to finish. If the active door then moves the party, the current action list is copied into the destination map's matching door slot and its target is changed to the captured position. Data ED3 branches replace only that action list; the originating map door header remains active. These replacements live in runtime state and snapshots, leaving the compiled campaign bundle immutable. A focused Twin Sands of Time fixture exercises the shipped same-level relocation case.

Opcode `7` copies a Data ED3 action list into the selected map AP, simple result, or complex result while preserving the target record's other fields. The replacement is persistent and included in runtime snapshots, matching Classic's scenario-file mutation without changing the compiled bundle. Opcode `8` is deliberately transient: it borrows another AP's actions from the currently loaded map, retains the active AP's header and percentage, repeats Classic's percentage check, and then executes the copied list from its first slot. City of Bywater exercises both paths directly.

Opcode `11` sends its authored total through Remake's existing loot and experience flow, which splits the award among living party members that can receive experience and preserves the normal level-up UI. The City of Bywater child-grave sequence awards 1,500 experience and then continues into its persistent action-point replacement.

Opcodes `6` and `73` convert Classic's five fixed 200-slot stock categories into Remake's native shop categories and apply the authored inflation to purchase and resale prices. A positive shop ID makes the Shop control available until movement; a negative ID opens it immediately. Opcode `73` resolves the shop ID and two inclusive item ranges from Extra Code, then applies the resulting transfer rule to both purchases and sales. It preserves Classic's original two-range test: an item is rejected only when it misses both populated ranges, so a record with only one populated range remains unrestricted. Existing native shop state is retained when the same shop is loaded again so purchased stock survives Remake's save lifecycle, while its active restriction is replaced or cleared by each load. Every stocked or accepted item must resolve to a loaded Remake resource. The current full City of Bywater bundle does not include names for its scenario-specific items, so affected shops remain an explicit resource boundary rather than silently omitting their merchandise.

Opcode `16` rolls its inclusive Extra Code range separately for each party member, multiplies each result by the authored signed value, and applies the resulting damage or healing through Remake's normal character health method. Its optional sound and message use the existing adapter paths. The standalone City of Bywater macro at `Data ED3:macro:142` provides a deterministic one-point party-damage proof.

Opcodes `14`, `-14`, `30`, and `15` share a transient selected-character set. Interactive picks use Remake's character panels; a negative pick ID allows dead characters, while opcode `-14` keeps the unchosen complement. Opcode `30` filters the current selection, whole party, or living party through the authored attribute or special-ability check. Opcode `15` then applies an independent signed health roll to each selected character. The City of Bywater shaft at `Data DD:7:54` exercises the native picker, while its temple sphere and pit records cover inverse and checked selections.

Opcode `52` replaces that selection from the whole party, living characters, or the previous selected set. Its selectors cover maximum movement, one-based party position, carried or worn items, percent chance, failed attribute or spell saves, the native HUD focus, and an exact party slot. The construction-set contract for checking the previous selection is preserved despite Classic's duplicate `track` clear making that source path ineffective. City of Bywater uses the opcode for two rockfalls: one selects movement below 10, while the other authors undefined attribute selector `5` alongside explicit “not fast enough” text. The adapter treats that one compatibility value as Dexterity rather than reproducing an uninitialized Classic comparison.

Opcodes `17` and `18` apply a packed Classic spell to the current selected set or whole party. The interpreter preserves the spell ID, power, save adjustment, force-affect flag, and target mode; the party variant also replaces the transient selection, matching Classic's `track` behavior. The adapter maps the ID through Remake's existing Divinity spell table and awaits its field-spell animation and effect helper. Remake's current helper has no equivalent for Classic's save adjustment or force-affect override, and a mapped spell must already exist in the active resource book, so those fields remain preserved but unapplied at this boundary.

Encounter result values select the corresponding eight-action block from `Data ED` or `Data ED2`. When a result block falls through naturally, the encounter repeats up to its authored `maxTimes`; explicit keep/remove actions still terminate it. On the last attempt, Classic's complex-encounter Result 4 timeout quirk selects Result 3 instead. Opcode `35` removes an option from the active simple encounter and reopens it without consuming an attempt. Opcode `41` applies the same persistent mutation to the encounter and option named by its Extra Code row, while opcode `44` replaces one complex result row with Keep Codes. These replacements are included in runtime snapshots. Battle outcome branches remain suspended until the host reports victory or cowardice. Persistent tile, trigger, encounter, player-map, and action-point mutations are included in runtime snapshots; the bundle records themselves remain immutable.

Percent branches use Classic's inclusive 1-100 roll. Their success action can redirect to Data ED3, keep or consume the source action point, or replace the current result code with a row from the most recently loaded simple or complex encounter. Those loaded encounter references are transient interpreter state, matching the original engine's separate global encounter buffers; redirecting a result row does not start or add an encounter loop.

Difficulty branches compare their threshold with Classic's saved five-step difficulty setting, represented internally from `-2` (easiest) through `2` (hardest), with `0` as the default. They use the same success outcomes as percent branches. City of Bywater does not author opcode `58`, so this handler does not change its compatibility coverage count.

Dungeon moves change the runtime's map family as well as its level and coordinates. Entering a dungeon preserves Classic's heading, multiview, and fixed-view fields; leaving for land keeps that dungeon view state dormant. The transfer ends the active action point immediately, matching the original map loader. The command is emitted through the existing typed teleport boundary, and remains an explicit adapter stop until compiled Classic maps have a native Remake map resource bridge.

Look Direction updates that persisted heading and requests a native view refresh before the action point continues. Authored directions `1` through `4` are used directly; other values select one of those four directions at random, matching Classic. The Godot adapter leaves this command explicit until the same compiled-map bridge can redraw the party's view.

Compass and map-view actions preserve Classic's separate compass, multiview, and signed `viewtype` fields. Requiring 3D changes `viewtype` from `-1` to `1`; allowing the full map does not force the current view to change. Their command payloads also preserve the source warning IDs and redraw intent for a future map adapter. Darkland and land-look changes are keyed by map and use each compiled random-level record as their initial value. An authored no-change guard ends a Darkland action point before later slots, matching Classic. Random-encounter changes address Classic's 20 fixed rectangle slots even when an unused zero-valued row is omitted from the normalized bundle; negative battle IDs leave the existing low or high bound unchanged. Applying these map-level changes remains an explicit adapter boundary until compiled maps have a native Remake resource bridge.

The complex-encounter adapter exposes the eight Classic action-text fields through Remake's existing HUD choice control and routes each selection to the record's shared action result. This covers the active non-rogue library, cave-in, and pool encounters in City of Bywater. Spoken responses reuse Remake's speech input and preserve Classic's case-insensitive, first-space-terminated prefix comparison; a mismatch selects Result 4. The City of Bywater archive at `Data DD:6:28` exercises its `waterford` response, grants player map 2, removes the successful response through opcode `44`, and reopens with its remaining choices. Positive map IDs use Classic's acquisition notice. Negative IDs display a compatible native Remake minimap when one exists, with the compiled map note as a fallback. Encounters with magic responses can open Remake's native spell picker, match the selected spell against the packed Classic IDs, consume its normal spell-point cost, and continue through the paired result block. Item responses similarly use Remake's encounter inventory picker and match the selected item's shared mapping or scenario item text against the five Classic response slots. Unmatched spells and items use Classic's Result 4 fallback. Low spell IDs `1` through `6` remain supported when a Remake spell supplies explicit Classic spell-class metadata; current shared spell resources do not yet preserve that field. Mixed rogue encounters keep action, spell, and item choices beside their `Data TD2` controls. The rogue resolver uses the selected character's Remake stat plus the Classic modifier, preserves Classic's 90-percent cap for interactive lock/trap actions, and routes success or failure into the four `Data ED2` result rows. Consumed rogue actions persist in runtime snapshots while the compiled record remains immutable. The source-backed CoB lock at `Data DD:5:12` exercises Detect Trap, Force Lock, Pick Lock, and the Necklace of Keys response. The trapped chest at `Data DD:5:3` applies its shipped 4-12 damage to the selected rogue, clears the armed state, and leaves Pick Lock available before continuing through result 2.

Against the checked City of Bywater compatibility baseline, these handlers cover 2,196 of 2,734 active action slots. Another 470 slots are skipped only because the bundle's source-backed dispatcher evidence identifies them as Realmz no-ops. Together, the proof of concept has defined behavior for 2,666 slots, or 97.5% of active slots. This is a semantic coverage measurement, not a playability percentage. Native command adapters and 68 action slots across additional opcodes remain. Opcodes `35`, `42`, and `44` also occur inside encounter results and those uses are not reflected in this trigger-slot count.

The [compatibility gap register](COMPATIBILITY_GAPS.md) tracks required integration work and recommended fidelity improvements separately from opcode coverage.

The interpreter will still stop explicitly when a selected encounter result contains an unsupported opcode. Compiled player-map records do not yet have a standalone Remake renderer, so display requests without compatible native minimap art fall back to the map note. Trap spells, scroll-as-spell and door-activation encounter items, imported spell-class metadata, unmigrated field-spell resources, Classic spell save and force-affect modifiers, and the timed tumbler minigame also remain explicit boundaries. The original runtime's hidden developer command words are intentionally not exposed through scenario speech input. This keeps the compatibility boundary visible while more handlers are added.

## Godot guard-house playtest

The first in-engine vertical slice loads the CoB fixture, displays `Data DD:0:0` through Remake's existing `TextRect`, presents the four source-backed `Data ED` choices and Classic's Back Out control, feeds the selected result back to the interpreter, and runs that eight-action encounter result block.

Run the standalone scene from the repository root:

```powershell
Godot_v4.6.2-stable_win64.exe --path src res://scripts/classic_runtime/playtest/classic_guard_house_playtest.tscn
```

Pass a compiled campaign directory after `--` to use the full converter output instead of the checked-in fixture:

```powershell
Godot_v4.6.2-stable_win64.exe --path src res://scripts/classic_runtime/playtest/classic_guard_house_playtest.tscn -- "C:\path\to\realmz-remake-cob-poc-final"
```

This adapter intentionally handles text, yes/no prompts, character-panel selection, simple-encounter choices, complex action and spell responses, data-driven rogue encounters, selected and party health changes, Classic field-spell effects, Classic shops with resolved item resources, fixed treasure and standalone experience through Remake's loot UI, and mapped sounds. Other typed commands stop with an explicit adapter error until their map, encounter, or battle resource adapters exist.

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

The experience playtest starts at the source-backed 1,500-point award in CoB's child-grave sequence. Its smoke verifies the empty loot panel, party experience change, and following action-point replacement:

```powershell
Godot_v4.6.2-stable_win64.exe --path src res://scripts/classic_runtime/playtest/classic_experience_playtest.tscn
Godot_v4.6.2-stable_win64_console.exe --resolution 1100x619 --path src res://scripts/classic_runtime/playtest/classic_experience_playtest.tscn -- --smoke
```

The party-health playtest runs CoB's standalone fixed-damage macro and verifies the character HP change and completed host state:

```powershell
Godot_v4.6.2-stable_win64.exe --path src res://scripts/classic_runtime/playtest/classic_party_health_playtest.tscn
Godot_v4.6.2-stable_win64_console.exe --resolution 1100x619 --path src res://scripts/classic_runtime/playtest/classic_party_health_playtest.tscn -- --smoke
```

The party-spell playtest runs CoB's source-backed psychic barrier, supplies two playtest targets and a test-only Power Drain resource, and verifies Remake's spell animation, per-character effect, transient party selection, and completed host state:

```powershell
Godot_v4.6.2-stable_win64.exe --path src res://scripts/classic_runtime/playtest/classic_party_spell_playtest.tscn
Godot_v4.6.2-stable_win64_console.exe --resolution 1100x619 --path src res://scripts/classic_runtime/playtest/classic_party_spell_playtest.tscn -- --smoke
```

The character-pick playtest opens Remake's party-panel picker for CoB's hollow-column volunteer and verifies that the chosen character becomes the transient Classic selection:

```powershell
Godot_v4.6.2-stable_win64.exe --path src res://scripts/classic_runtime/playtest/classic_character_pick_playtest.tscn
Godot_v4.6.2-stable_win64_console.exe --resolution 1100x619 --path src res://scripts/classic_runtime/playtest/classic_character_pick_playtest.tscn -- --smoke
```

The miscellaneous-selection playtest runs CoB's movement-based ceiling rockfall with a slow playtest rogue and verifies the transient selection, 1-3 HP loss, and completed host state:

```powershell
Godot_v4.6.2-stable_win64.exe --path src res://scripts/classic_runtime/playtest/classic_misc_selection_playtest.tscn
Godot_v4.6.2-stable_win64_console.exe --resolution 1100x619 --path src res://scripts/classic_runtime/playtest/classic_misc_selection_playtest.tscn -- --smoke
```

The tavern-option playtest selects the barmaid response in CoB's source-backed `Data ED:3`. Opcode `35` removes that response, reopens the encounter without using an attempt, and leaves the party able to back out:

```powershell
Godot_v4.6.2-stable_win64.exe --path src res://scripts/classic_runtime/playtest/classic_simple_option_playtest.tscn
Godot_v4.6.2-stable_win64_console.exe --resolution 1100x619 --path src res://scripts/classic_runtime/playtest/classic_simple_option_playtest.tscn -- --smoke
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

The spoken-word variant opens Remake's speech input for the City of Bywater archives and verifies that `WATERFORD` selects the source-backed Result 1 messages, grants its map, removes that result, and reopens the encounter:

```powershell
Godot_v4.6.2-stable_win64.exe --path src res://scripts/classic_runtime/playtest/classic_complex_word_playtest.tscn
Godot_v4.6.2-stable_win64_console.exe --resolution 1100x619 --path src res://scripts/classic_runtime/playtest/classic_complex_word_playtest.tscn -- --smoke
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
