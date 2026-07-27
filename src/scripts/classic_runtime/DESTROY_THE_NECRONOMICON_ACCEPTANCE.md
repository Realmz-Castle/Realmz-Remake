# Destroy the Necronomicon acceptance

Destroy the Necronomicon is the fourth first-party scenario with a dedicated
installed-route checkpoint. The shared 13-campaign lifecycle report already
covers normal menu discovery, launch, Save, and fresh-process Continue. This
route adds source-specific presentation, encounter, item, combat, and
completion evidence.

## Reproduce

Run from the repository root:

```powershell
& .\src\scripts\classic_runtime\tools\run_classic_scenario_route_acceptance.ps1 `
    -CampaignDirectory '.\src\Campaigns\Destroy the Necronomicon (Classic)' `
    -RoutePath '.\src\scripts\classic_runtime\playtest\routes\destroy_the_necronomicon.json' `
    -OutputPath '.\src\scripts\classic_runtime\reports\classic_destroy_the_necronomicon_route_acceptance.json'
```

The runner creates one disposable profile under the system temporary directory,
launches the installed package through the normal campaign and party controls,
and writes the deterministic result to
`src/scripts/classic_runtime/reports/classic_destroy_the_necronomicon_route_acceptance.json`.

## Checked route

The source and package both start on land map 0 at `(35, 68)`. The route checks
six compiled action points through the live Classic host and native UI:

1. `Data DD:0:39` at `(35, 69)` renders decoded PICT 32128, presents messages
   978 and 979, and preserves raw opcode 200 as a source-backed dispatcher
   fall-through.
2. `Data DD:0:15` at `(36, 20)` presents message 256 and resolves Battle 47.
   Twenty-four Stygian Trolls enter a drawable battlefield. Victory continues
   through messages 257 through 260 and Treasure 2, whose 6,000 experience and
   Deadstone of Jealousy (item 886) are delivered through the native UI.
3. `Data DD:4:11` at `(0, 43)` follows simple encounter 10's diplomatic
   response. Battle 145 contains nine Winged Demons, nine Slime Demons, and
   four Hecubus Servants. Battle 146 then contains Lord Hecubus, one Winged
   Demon, one Slime Demon, one Hells Assassin, and four Hecubus Servants.
   Victory grants player map 9 and Treasure 43, then enables the cache action
   point.
4. `Data DD:4:13` at `(33, 73)` follows the map to Treasure 44. The installed
   treasure supplies the Book of Screams (899) and Necronomicon (900), then
   consumes the cache action point.
5. `Data ED3:macro:194` at land map 7 `(3, 24)` opens complex encounter 10.
   Selecting item 900 runs macro 196, removes the Necronomicon, enables the
   homecoming and pit mutations, and presents messages 814 through 820.
6. `Data DD:0:56` at `(9, 84)` runs the Westmore homecoming. Battle 215
   materializes 15 Fire Drakes with five Warriors and one each of the Warrior
   Corporal, Sergeant, Lieutenant, and Captain on the party's side. Battle 216
   materializes eight Fire Drakes and four Morbius clones with Thoth Amon and
   two of Amon's Proteges as allies. The installed epilogue ends on land map 0
   at `(24, 47)` and presents messages 1096 and 1097, which explicitly identify
   the saved Realmz and completed main task.

Classic battle formations use local coordinates from `-5` through `+7`.
Hecubus's source action point sits at the left edge of its land map. The runtime
therefore shifts the complete formation inward on the temporary battlefield and
uses a bounded nearest-open-tile fallback when authored cells overlap blocked
terrain. Relative formation layout is preserved whenever its cells are valid.

## Source-authored encounter boundary

Simple encounter 10 has `maxTimes` 127. Its diplomatic result does not execute
Classic's break-encounter-loop opcode, so Classic semantics present the prompt
again with 126 attempts remaining even after Lord Hecubus is dead and the cache
has been enabled. The route proves that exact repeat boundary, including the
absence of an authored back-out choice.

To continue testing the downstream installed path, the acceptance driver then
injects the command adapter's ordinary cancel outcome. This is deliberately
classified as `installed-runtime-with-source-authored-escape`: it does not
change interpreter semantics or claim that the source-authored loop is a clean
manual route.

Quest, story, hint, and reward details found during the trace are retained in
`CLASSIC_SCENARIO_ARCHAEOLOGY.md`.

## Evidence boundary

The Westmore arrival, all five battles and their authored allies, map and
treasure grants, Necronomicon item response and consumption, final trigger
mutations, homecoming, epilogue, and explicit completion messages are
runtime-exercised through the installed package. The route certifies this
completion chain with the documented Hecubus acceptance escape; it does not
claim a manual traversal of every intervening bastion, room, or optional
encounter.
