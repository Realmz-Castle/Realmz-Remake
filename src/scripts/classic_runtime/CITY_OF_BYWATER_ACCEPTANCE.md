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
land map route using that same fresh bundle. The battle acceptance scene also
runs a source-backed City action point through native combat and a fresh-session
reload:

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

## Current checkpoint

The authoritative export checked on July 22, 2026 contains 11 maps, 1,341
triggers, 880 messages, 20 simple encounters, 13 complex encounters, 8 thief
encounters, 21 shop rows, 256 battles, and 155 monsters. The generic bundle
validator accepts it. Providence also packages the 84 shared negative `cicn`
resources referenced by its land maps as immutable payloads plus 84 decoded PNGs;
Remake accepts and materializes those special-land overlays.

Readiness passes with no progression blockers when the bundle is checked against
the existing native City resources. A clean package installation also succeeds
without manual file rearrangement and reports `Ready with fallbacks`: no
progression blockers and 80 fidelity fallbacks. Imported library monsters reuse
a shared Remake bestiary entry only when the Classic ID and normalized name both
match. Authored monster records still materialize locally, even if they reuse a
stock identity.

The installed package is discovered by the normal campaign menu under the City
of Bywater manifest title. The normal party picker enables Start, creates the
Classic session, and enters the compiled `map_0` start at `(2, 1)`. The
guard-house encounter and the authored `Data DD:0:83` land-to-dungeon /
`Data DDD:0:1` dungeon-to-land route also pass their real-display smoke checks
with the fresh bundle.

The authored `Data DD:0:30` route now passes its first battle and persistence
checkpoint. Extra Code row 85 resolves to compiled Battle 45, whose 24 monster-80
entries map to Remake's existing `Krise 80` definition and enter the native
combat lifecycle. Victory resumes the source action list, awards player map 4
and treasure 11, enables land trigger 17, and replaces that trigger's action
data. The session save envelope survives a JSON round trip, and a fresh session
restores the map position, acquired map, trigger percentage, and action-point
override with no pending continuation.

The smoke scene removes any loaded `Battle_45` entry in memory before starting
the trigger. This makes the formation come from the producer bundle. The
matching Krise remains a shared native Remake resource. Because the current
producer bundle has no scenario item-text rows, item 807 is presented under its
stable generated name and records that presentation loss as a fidelity fallback;
the route consumes it by its preserved `classicItemId`.

This is now a clean-install and first playable-checkpoint result, not a complete
City of Bywater playthrough.

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
- Decoded picture, sound, and monster-icon media remain fidelity fallbacks unless
  a missing asset carries progression meaning.

## Next playable checkpoint

Expand the installed campaign's documented play path to the next
progression-significant service, encounter, or battle boundary. Add save, quit,
reload, and continuation checkpoints as that route grows, while keeping
unrelated fidelity systems from blocking each playable checkpoint.
