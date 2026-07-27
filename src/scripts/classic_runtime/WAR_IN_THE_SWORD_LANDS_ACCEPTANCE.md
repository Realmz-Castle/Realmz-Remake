# War in the Sword Lands acceptance

War in the Sword Lands is the eleventh first-party scenario with a dedicated
installed-route checkpoint. The shared 13-campaign lifecycle report already
covers normal menu discovery, launch, Save, and fresh-process Continue. This
route adds the Part One continuity choice, Taroth Sark, Naryl's recruitment,
the liberation of Sharranth, the surviving Overlords, Xenon Maximus, Naryl's
sacrifice, and the explicit main-story ending.

## Reproduce

Run from the repository root:

```powershell
& .\src\scripts\classic_runtime\tools\run_classic_scenario_route_acceptance.ps1 `
    -CampaignDirectory '.\src\Campaigns\War in the Sword Lands (Classic)' `
    -RoutePath '.\src\scripts\classic_runtime\playtest\routes\war_in_the_sword_lands.json' `
    -OutputPath '.\src\scripts\classic_runtime\reports\classic_war_in_the_sword_lands_route_acceptance.json'
```

The runner creates one disposable profile under the system temporary directory,
launches the installed package through the normal campaign and party controls,
and writes the deterministic result to
`src/scripts/classic_runtime/reports/classic_war_in_the_sword_lands_route_acceptance.json`.

## Checked route

The source and package both start on land map 0 at `(1, 72)`. The route checks
seven source-identified milestones through the live Classic host and native UI:

1. Macro 3 asks whether the party completed Trouble in the Sword Lands.
   Answering yes preserves quest 1, presents PICT 32128, introduces the
   Overlords' invasion, and grants maps 1, 2, and 3.
2. `Data DD:17:47` enters Battle 377 against Taroth Sark and 32 psionic
   followers. Victory sets quest 75 and awards 10,000 experience.
3. Macro 2851 requires quest 75 before Naryl identifies Nyxos Uhn, Zeiia No,
   Taroth Sark, Primus, and the Mind Lords, then joins as ally 123.
4. Macro 3143 enters Battles 473 and 474. Both full initial formations and
   allied Naerun Halgard are checked before victory defeats Anthraxus Storm,
   sets quest 42, and applies the authored position shift from `(12, 76)` to
   `(12, 75)`.
5. Macro 3158 has King Naerun declare the regional war over, awards Treasure
   116 and 10,000 experience, and has Naryl continue the pursuit of Primus.
6. `Data DD:16:67` enters Battle 212 against a 44-member formation: 41 psionic
   followers plus Taroth Sark, Nyxos Uhn, and Zeiia No.
7. `Data DD:16:61` reveals Primus as Xenon Maximus. A rechecking teleport
   immediately runs the destination action point, where Naryl intercepts
   Maximus's mind blast, ally 123 is removed, PICT 30120 appears, and messages
   3961 and 3962 explicitly complete the main story and name Wrath of the Mind
   Lords as its continuation.

The selected scenario-owned sounds `-212` and `-216` resolve to their bundled
runtime media.

## Quest and ending boundaries

Naryl's recruitment is not reached by manufacturing route state. The installed
route first wins Taroth Sark's Battle 377 and observes quest 75 before entering
her recruitment macro.

Naerun's declaration that the war is over closes the Sharranth campaign, but it
is not the scenario's ending. His reward scene sends Naryl onward after Primus.
Only the later Maximus revelation and Naryl sacrifice present the explicit
main-story completion messages.

## Rechecking teleport boundary

The final branch uses a rechecking position change. Unlike Twin Sands of Time's
ordinary return teleports, this compiled opcode immediately executes the action
point at its destination. The checkpoint therefore treats Naryl's sacrifice as
part of the same live continuation rather than entering that square separately.

## Battle-resume boundary

The Sharranth climax follows two consecutive battles with an authored position
change. Native battle cleanup emits `battle_end` before restoring the
exploration actor. Resuming Classic on that signal allowed the later native
restore to overwrite the scenario's shift.

The Godot command adapter now lets native cleanup finish for one process frame
before Classic resumes. Macro 3148's shift from `(12, 76)` to `(12, 75)` is the
installed regression check for that ordering boundary.

## Evidence boundary

The prologue, Taroth Sark battle, quest 75, Naryl recruitment, both Sharranth
battles, quest 42, Naerun's reward, the Overlords' last stand, the Maximus
revelation, Naryl's sacrifice, and the explicit ending are runtime-exercised
through the installed package.

The route jumps directly between source-identified milestones and forces
victory after checking each initial formation. It does not claim manual travel
through all 21 land maps and three dungeons, every regional quest, optional
content, alternate alliance branches, or every intervening encounter.

Quest, story, hint, and completion details found during the trace are retained
in `CLASSIC_SCENARIO_ARCHAEOLOGY.md`.
