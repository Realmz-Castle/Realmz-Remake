# Half Truth acceptance

Half Truth is the sixth first-party scenario with a dedicated installed-route
checkpoint. The shared 13-campaign lifecycle report already covers normal menu
discovery, launch, Save, and fresh-process Continue. This route adds
source-specific opening presentation, a spoken-word quest response, required
item acquisition, final combat, persistent state, and explicit major-plot
completion evidence.

## Reproduce

Run from the repository root:

```powershell
& .\src\scripts\classic_runtime\tools\run_classic_scenario_route_acceptance.ps1 `
    -CampaignDirectory '.\src\Campaigns\Half Truth (Classic)' `
    -RoutePath '.\src\scripts\classic_runtime\playtest\routes\half_truth.json' `
    -OutputPath '.\src\scripts\classic_runtime\reports\classic_half_truth_route_acceptance.json'
```

The runner creates one disposable profile under the system temporary directory,
launches the installed package through the normal campaign and party controls,
and writes the deterministic result to
`src/scripts/classic_runtime/reports/classic_half_truth_route_acceptance.json`.

## Checked route

The source and package both start on land map 0 at `(42, 71)`. The route checks
four source-identified milestones through the live Classic host and native UI:

1. Global Start macro 58 presents decoded PICT 30011 and scenario sound 242,
   then runs the complete shipwreck sequence. The authored icon changes,
   teleports, and boat-state change leave the party on land map 0 at
   `(42, 69)`.
2. `Data DD:1:90` at `(72, 62)` opens Domnu's shrine. Choosing to oppose the
   Grey God exposes Complex Encounter 23. The native speech panel accepts the
   source word `fomorians`; the successful result presents Treasure 84, and the
   route takes and retains the Fomorian Hammer (item 971).
3. `Data ED3:macro:404`, exercised at land map 10 `(34, 5)`, introduces the
   Grey God's Avatar and enters Battle 253. Its initial formation contains 11
   Shadow Bats and the Avatar. The victory continuation changes the rift tile
   to 155, disables land random rectangle 2, sets quest flag 63, awards 12,000
   experience, and moves the party to `(7, 5)`.
4. `Data ED3:macro:403` asks whether to leave the Shadowgaunt stronghold.
   Quest 63 selects macro 407 after the teleport to land map 9 `(62, 6)`.
   Rowan's departure and the assembled races' celebration end with message
   2090, which explicitly says the scenario's major plotline is complete while
   optional sidelines remain.

## Avatar death chain

The initial Avatar (monster 82) names macro 405 as its death hook. That macro
says the Fomorian Hammer breaks the Avatar's divine invulnerability and spawns
monster 83. The stronger form names macro 44 as its death hook; macro 44 says
the Avatar's link to the Grey God is severed and sets quest 63. The route's
source contract checks both monster-to-macro links, both macros, and spawn
Extra Code 1238.

The acceptance driver forces victory after verifying the complete initial
formation. That shortcut resumes the authored victory continuation but does
not defeat the two Avatar forms individually. The transformation and second
death hook are therefore source-proven, while Battle 253's initial formation,
victory continuation, quest state, map mutation, experience award, teleport,
and ending are runtime-proven.

## Spoken-word and sound lifecycle

Half Truth is the first dedicated scenario route that needs a Complex
Encounter spoken-word response. The shared route driver now operates Remake's
native speech panel and verifies the encounter's prompt, stored answer, result
number, and complete result action list before entering the text.

The opening also serializes five negative stock sound commands after the
shipwreck text. Negative sound IDs retain Classic's wait-for-completion
semantics, so this step uses a longer route deadline rather than skipping or
reclassifying the sounds.

## Evidence boundary

The opening, Domnu dialogue and spoken answer, Hammer treasure and inventory
state, complete initial final-battle formation, post-victory quest and map
state, 12,000-experience award, stronghold exit, celebration, and explicit
major-plot ending are runtime-exercised through the installed package. The
route jumps directly between source-identified milestones; it does not claim
manual traversal of every intervening map, quest, room, battle round, or
optional sideline.

Quest, story, hint, and completion details found during the trace are retained
in `CLASSIC_SCENARIO_ARCHAEOLOGY.md`.
