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

Exercise the checked authored guard-house encounter and the land-to-dungeon-to-
land map route using that same fresh bundle:

```powershell
Godot_v4.6.2-stable_win64_console.exe --resolution 1152x648 `
  --path "F:\Realmz Remake\src" `
  res://scripts/classic_runtime/playtest/classic_guard_house_playtest.tscn -- `
  "C:\path\to\new-city-of-bywater-bundle" --smoke

Godot_v4.6.2-stable_win64_console.exe --resolution 1100x619 `
  --path "F:\Realmz Remake\src" `
  res://scripts/classic_runtime/playtest/classic_map_bridge_playtest.tscn -- `
  "C:\path\to\new-city-of-bywater-bundle" --smoke
```

## Current checkpoint

The authoritative export checked on July 22, 2026 contains 11 maps, 1,341
triggers, 880 messages, 20 simple encounters, 13 complex encounters, 8 thief
encounters, 21 shop rows, 256 battles, and 155 monsters. The generic bundle
validator accepts it. Providence also packages the 84 shared negative `cicn`
resources referenced by its land maps as immutable payloads plus 84 decoded PNGs;
Remake accepts and materializes those special-land overlays.

Readiness passes with no progression blockers when the bundle is checked against
the existing native City resources. The guard-house encounter and the authored
`Data DD:0:83` land-to-dungeon / `Data DDD:0:1` dungeon-to-land route both pass
their real-display smoke checks with the fresh bundle.

This is not yet an installable-campaign or full-playthrough result. The checks
above reuse repository-native City map resources. A clean installation now gets
through special-land and permanent-Animated materialization, then stops at the
remaining generated-bestiary readiness boundary.

## Blocking findings

- Clean package installation reports 39 progression diagnostics in referenced
  generated-bestiary records. They cluster around negative random-weapon table
  selectors, unsupported initial conditions, weapon-coupled attack specials, a
  few unresolved monster spells, and unsupported carried-item fields. The JSON
  installer result carries the complete readiness report so these can be triaged
  by an exercised route instead of discovered one at a time.
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

Run one source-backed City battle whose records are already materializable, from
map entry through victory and continuation, followed by a save, quit, reload, and
resumed mutation check. New implementation work should be taken from failures on
that route. The remaining bestiary diagnostics stay visible for later campaign
acceptance, but unrelated records and fidelity systems do not block this playable
checkpoint.
