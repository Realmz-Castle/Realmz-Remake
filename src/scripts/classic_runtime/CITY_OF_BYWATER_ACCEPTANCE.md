# City of Bywater acceptance

City of Bywater is the first full-campaign acceptance target for the Classic
runtime. This log records evidence from the current Providence producer output
without treating opcode coverage or fixture-only tests as proof that the campaign
is playable end to end.

## Acceptance layers

1. **Bundle validation** proves that the producer emitted the agreed portable
   schema.
2. **Readiness** proves that Remake can resolve progression-sensitive actions and
   resources for a particular bundle and native resource set.
3. **Installation** proves that the producer package can be staged as a normal
   Remake campaign without hand-authored files or manual rearrangement.
4. **Playable checkpoints** exercise authored campaign paths through the native
   UI, map, encounter, service, battle, and save lifecycles.
5. **Campaign acceptance** requires a documented start-to-finish route, including
   save, quit, reload, and continuation at representative mutation and battle
   checkpoints.

Passing an earlier layer does not imply that a later layer passes.

## Reproduce the current checkpoint

Export the imported City of Bywater project with Providence's authoritative
Remake converter. The input is a Providence project directory; the output is a
new temporary bundle directory.

```powershell
& "F:\Realmz - Providence\src-tauri\target\debug\realmz-remake-converter.exe" `
  --project "F:\Realmz - Providence\tmp\inspect-city-of-bywater-import" `
  "C:\path\to\new-city-of-bywater-bundle"
```

Validate the portable bundle and then run Remake's semantic readiness report
against the existing native City resources:

```powershell
Godot_v4.6.2-stable_win64_console.exe --headless --path "F:\Realmz Remake\src" `
  --script res://scripts/classic_runtime/tests/validate_classic_bundle.gd -- `
  "C:\path\to\new-city-of-bywater-bundle"

Godot_v4.6.2-stable_win64_console.exe --headless --path "F:\Realmz Remake\src" `
  --script res://scripts/classic_runtime/tests/report_classic_readiness.gd -- `
  "C:\path\to\new-city-of-bywater-bundle" `
  "F:\Realmz Remake\src\Campaigns\City of Bywater"
```

Install the same untouched bundle into a campaigns directory. The installer
stages and validates the package, materializes its native maps and resources,
and only publishes it after the launch-readiness gate passes:

```powershell
Godot_v4.6.2-stable_win64_console.exe --headless `
  --path "F:\Realmz Remake\src" `
  --script res://scripts/classic_runtime/tools/install_classic_campaign.gd -- `
  "C:\path\to\new-city-of-bywater-bundle" `
  "C:\path\to\temporary-Campaigns" --json
```

Exercise the checked authored guard-house encounter and the land-to-dungeon-to-
land map route using that same fresh bundle. The City acceptance scene runs the
guard-house encounter and tannery service before taking the blacksmith's quest
from its offer through native combat and the reward turn-in:

```powershell
Godot_v4.6.2-stable_win64_console.exe --resolution 1152x648 `
  --path "F:\Realmz Remake\src" `
  res://scripts/classic_runtime/playtest/classic_guard_house_playtest.tscn -- `
  "C:\path\to\new-city-of-bywater-bundle" --smoke

Godot_v4.6.2-stable_win64_console.exe --resolution 1100x619 `
  --path "F:\Realmz Remake\src" `
  res://scripts/classic_runtime/playtest/classic_map_bridge_playtest.tscn -- `
  "C:\path\to\new-city-of-bywater-bundle" --smoke

Godot_v4.6.2-stable_win64_console.exe --resolution 1100x619 `
  --path "F:\Realmz Remake\src" `
  res://scripts/classic_runtime/playtest/classic_city_battle_acceptance.tscn -- `
  "C:\path\to\new-city-of-bywater-bundle" --smoke

Godot_v4.6.2-stable_win64_console.exe --resolution 1100x619 `
  --path "F:\Realmz Remake\src" `
  res://scripts/classic_runtime/playtest/classic_city_battle_acceptance.tscn -- `
  "C:\path\to\temporary-Campaigns\new-city-of-bywater-bundle" `
  --smoke --ui-launch
```

The full disk boundary uses a disposable profile root and two separate Godot
processes. The first process launches the installed campaign through the normal
campaign UI, reaches the post-battle checkpoint, creates `Post Battle` through
the HUD Save controls, and exits. The second process opens the main-menu Load
window, selects that save, restores it from disk, and completes the blacksmith
quest:

```powershell
$acceptanceRoot = Join-Path $env:TEMP "realmz-city-acceptance-$([guid]::NewGuid())"
New-Item -ItemType Directory -Path $acceptanceRoot | Out-Null

Godot_v4.6.2-stable_win64_console.exe --headless --resolution 1100x619 `
  --path "F:\Realmz Remake\src" `
  res://scripts/classic_runtime/playtest/classic_city_battle_acceptance.tscn -- `
  "C:\path\to\temporary-Campaigns\new-city-of-bywater-bundle" `
  --smoke --save-phase "--profile-root=$acceptanceRoot"

Godot_v4.6.2-stable_win64_console.exe --headless --resolution 1100x619 `
  --path "F:\Realmz Remake\src" `
  res://scripts/classic_runtime/playtest/classic_city_battle_acceptance.tscn -- `
  "C:\path\to\temporary-Campaigns\new-city-of-bywater-bundle" `
  --smoke --continue-phase "--profile-root=$acceptanceRoot"
```

For an interactive overworld demo, omit `--smoke` and stop the route at its
authored starting position with `--overworld-demo`:

```powershell
Godot_v4.6.2-stable_win64_console.exe --resolution 1100x619 `
  --path "F:\Realmz Remake\src" `
  res://scripts/classic_runtime/playtest/classic_city_battle_acceptance.tscn -- `
  "C:\path\to\temporary-Campaigns\new-city-of-bywater-bundle" `
  --overworld-demo
```

Click and hold around the party on the map, or use the configured movement keys,
to travel. The ordinary HUD buttons and authored map triggers remain active.

## Current checkpoint

The authoritative export checked on July 23, 2026 contains 11 maps, 1,341
triggers, 880 messages, 20 simple encounters, 13 complex encounters, 8 thief
encounters, 21 shop rows, 256 battles, and 155 monsters. The generic bundle
validator accepts it. Providence packages 170 referenced resource payloads,
including the 84 shared negative `cicn` resources used by its land maps. Classic
payloads remain immutable while decoded PNG or WAV runtime media travels beside
them; Remake accepts and materializes the resulting native resources.

The July 23 cross-repository rerun used Providence `98afcbf` and Remake
`d001dcf`. Two untouched City exports produced the same 179 relative files with
byte-identical contents, and their JSON documents contained no absolute or
parent-relative local paths. The clean installer accepted that output directly,
and the normal campaign menu discovered it as `Ready with fallbacks`. Starting
through the party controls entered the compiled City start and completed every
stage of the route below with exit status 0.

Readiness passes with no progression blockers when the bundle is checked against
the existing native City resources. A clean package installation also succeeds
without manual file rearrangement and reports `Ready with fallbacks`: no
progression blockers and 79 fidelity fallbacks. Imported library monsters reuse
a shared Remake bestiary entry only when the Classic ID and normalized name both
match. Authored monster records still materialize locally, even if they reuse a
stock identity.

The installed package is discovered by the normal campaign menu under the City
of Bywater manifest title. The normal party picker enables Start, creates the
Classic session, and enters the compiled `map_0` start at `(2, 1)`. The
authored `Data DD:0:83` land-to-dungeon / `Data DDD:0:1` dungeon-to-land route
also passes its real-display smoke check with the fresh bundle.

Before leaving the start, the installed route runs AP 76. Providence's decoded
PICT 32128 appears at its original 320 x 320 size in the native HUD, remains
visible behind all four source messages, and disappears only when the extended
action list reaches Redraw Screen. The three interleaved stock sound actions
resolve to Remake's loaded native sound resources.

The route then completes `Data DD:0:0` and simple encounter 0. It
shows all four authored guard-house choices plus Back out, selects the farewell
result, displays its source message, and returns to exploration without a
pending continuation. It then enters the tannery at `Data DD:0:29`, loads
compiled shop 4, and opens Remake's normal inventory and shop controls. The
native shop preserves all 17 source stock rows, their five fixed categories,
84 total items, and the authored 100-percent price rate. Buying item 806 deducts
the native price, adds the exact Classic item to the character inventory, and
reduces both displayed and stored stock before the party continues.

The blacksmith quest now passes as a complete installed-campaign progression
route. `Data DD:0:17` presents the request with its authored Data OD labels,
acceptance grants player map 3, and the initial offer retires itself. Maps/Notes
opens both the initially owned map and the newly acquired map as independent
320 x 320 terrain-composed views, including the source note and marker overlay,
then returns cleanly to exploration. At
`Data DD:0:30`, Extra Code row 85 resolves to compiled Battle 45, whose 24
monster-80 entries map to Remake's existing `Krise 80` definition and enter the
native combat lifecycle. Victory resumes the source action list, awards player
map 4 and treasure 11, enables land trigger 17, and replaces that trigger's
action data. The normal Save controls persist both native files and the Classic
runtime envelope before the application exits. A second Godot process discovers
the installed campaign and `Post Battle` save through the main-menu Load window.
Continue restores both maps, item 807, the purchased item 806 and depleted shop
stock, the trigger percentage, the action-point override, and an idle battle
continuation at `map_0 (2, 44)`. Returning to the blacksmith runs macro 39,
consumes item 807, and awards treasure 19's items 210 and 434 plus 800 experience.
Both rewards retain their Classic item identities after mapping to native Remake
definitions.

This route also exposed a native save defect: the temporary map derived for
combat remained in the in-memory map book and was written to map exploration.
It did not exist after a fresh resource load, so Continue failed before creating
the Classic session. New saves now omit that derived map, and the loader skips
unknown map-exploration entries so existing affected saves can continue.

The smoke scene removes any loaded `Battle_45` entry in memory before starting
the trigger. This makes the formation come from the producer bundle. The
matching Krise remains a shared native Remake resource. Because the current
producer bundle has no scenario item-text rows, item 807 is presented under its
stable generated name and records that presentation loss as a fidelity fallback;
the route consumes it by its preserved `classicItemId`.

This proves a clean install and one source-backed route that includes a complete
simple encounter, a native shop transaction, a quest from offer through turn-in,
a native battle, and a save/exit/relaunch/Continue boundary. The two-process run
passes with no progression blocker and no pending Classic continuation.

## Blocking findings

- The current clean installation has no known launch blocker. Its remaining
  fidelity diagnostics and unexercised routes still require playtest evidence;
  install readiness is not evidence that the campaign can be completed.
- The authoritative export currently contains 21 shop rows. Five tail rows are
  not present in the older direct-converter baseline and include implausible
  values such as shop 20's negative inflation. These rows need a producer/source
  boundary decision before Remake's full-bundle assertions are updated.
- The older direct-converter fixture includes two active dungeon triggers and
  padding encounter data that the authoritative importer correctly treats as
  inactive. Baseline count changes must therefore be reviewed by record, rather
  than copied wholesale from either exporter.
- Unmapped optional sound and monster-icon media remain fidelity fallbacks. An
  audited executable media action uses `mediaRequiredForProgression` when the
  missing asset would prevent progress; readiness then reports a blocker at that
  action's source record and slot. City PICT 32128 and AP 76's stock sounds now
  have installed-route evidence and do not need that fallback.

## Further coverage

The accepted route is deliberately bounded; it does not claim that every City
branch or optional asset is exact. Remaining readiness fallbacks and unexercised
routes should be tracked as compatibility defects when they block progression,
or as optional fidelity work when they only affect presentation.
