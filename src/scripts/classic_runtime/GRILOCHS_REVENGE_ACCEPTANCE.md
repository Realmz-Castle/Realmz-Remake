# Grilochs Revenge acceptance

Grilochs Revenge is the fifth first-party scenario with a dedicated
installed-route checkpoint. The shared 13-campaign lifecycle report already
covers normal menu discovery, launch, Save, and fresh-process Continue. This
route adds source-specific presentation, combat, item-gated branching,
epilogue, reward, and completion evidence.

## Reproduce

Run from the repository root:

```powershell
& .\src\scripts\classic_runtime\tools\run_classic_scenario_route_acceptance.ps1 `
    -CampaignDirectory '.\src\Campaigns\Grilochs Revenge (Classic)' `
    -RoutePath '.\src\scripts\classic_runtime\playtest\routes\grilochs_revenge.json' `
    -OutputPath '.\src\scripts\classic_runtime\reports\classic_grilochs_revenge_route_acceptance.json'
```

The runner creates one disposable profile under the system temporary directory,
launches the installed package through the normal campaign and party controls,
and writes the deterministic result to
`src/scripts/classic_runtime/reports/classic_grilochs_revenge_route_acceptance.json`.

## Checked route

The source and package both start on land map 0 at `(0, 73)`. The route checks
seven source-identified milestones through the live Classic host and native UI:

1. `Data DD:0:13` at `(1, 73)` presents the decoded opening PICT 32128,
   introduction, scenario provenance, and native `hallelujah.wav` mapping.
2. `Data DD:9:16` at `(18, 79)` resolves Battle 122. Its 49-creature formation
   contains six Solsux, six Dark Servants, one Winged Devil, three Liches, six
   Ice Demons, two Tuchor-uth, and 25 Invisible Haunters. Victory presents
   Treasure 64, and the route takes and retains the Spear of Light +5
   (item 915).
3. `Data ED3:macro:466` at land map 9 `(70, 20)` checks item 915 before
   selecting the Griloch branch. Battle 124 contains five Solsux, two Dark
   Servants, six Ice Demons, five Tuchor-uth, 19 Invisible Haunters, and
   Griloch. Victory identifies the glowing brazier as the exit.
4. `Data DD:9:31` at `(70, 25)` enables the island epilogue and teleports the
   party to land map 6 `(80, 40)`.
5. `Data DD:6:16` presents the island reception, enables the mainland
   celebration, and teleports the party to land map 2 `(49, 55)`.
6. `Data DD:2:54` presents the mainland celebration, sets quest flag 55, and
   teleports the party beside Berhune's temple at `(85, 14)`.
7. `Data DD:2:13` at `(85, 13)` follows the quest-55 branch through macros 509
   and 547. The native UI presents all six 30,000-experience awards, Treasure
   73, and messages 1310 and 1311, which explicitly identify the end of the
   scenario.

Treasure 73 displays its exact 18 authored item entries, 5,000 gems, and 1,000
jewelry. The reward contains duplicates and exceeds what the route's one
selected character can reliably accept, so acceptance checks the complete
native presentation without requiring that character to take every item.

## Consecutive reward lifecycle

The final macros issue six experience awards without an intervening message.
That source pattern exposed a native loot-window lifecycle race: the previous
window emitted `done_looting` before hiding itself, allowing its awaiting
continuation to display the next award before the old close handler hid it.

`TreasureControl.close()` now hides the completed reward before emitting the
continuation signal. The route driver also waits for that signal rather than
using window visibility as the completion boundary. The six separate reward
screens are runtime-exercised, and the main runtime suite retains the close
ordering as a focused regression.

## Source and media boundaries

Classic opcode 20 moves the party but does not execute the destination action
point as part of the same command. The route therefore triggers the island and
mainland epilogue points as explicit consecutive milestones. This preserves the
source traversal boundary rather than inventing automatic destination
activation.

The throne macro actively requests sound ID `-92`. No corresponding packaged
or stock mapping is available in the installed corpus. The report records it as
an unresolved external Classic resource whose absent-source behavior is silent;
it is not classified as an authored no-op or as implemented audio.

Quest, story, hint, and reward details found during the trace are retained in
`CLASSIC_SCENARIO_ARCHAEOLOGY.md`.

## Evidence boundary

Opening presentation, both complete battle formations, Spear acquisition and
possession branch, Griloch's defeat, the brazier and both epilogue teleports,
quest 55, all six experience awards, Treasure 73, and the explicit ending are
runtime-exercised through the installed package. The route jumps directly
between source-identified milestones; it does not claim manual traversal of
every intervening map, quest, room, or optional encounter.
