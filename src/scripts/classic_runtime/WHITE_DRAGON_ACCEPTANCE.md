# White Dragon acceptance

White Dragon is the twelfth first-party scenario with a dedicated installed
completion-route checkpoint. The shared 13-campaign lifecycle report already
covers normal menu discovery, launch, Save, and fresh-process Continue. This
route adds Zukar's opening, Cylantra, Drawed, Blake, Raquiline's restoration,
the dragon and planar armies, Nufack, the reward choice, and the explicit
scenario ending.

## Reproduce

Run from the repository root:

```powershell
& .\src\scripts\classic_runtime\tools\run_classic_scenario_route_acceptance.ps1 `
    -CampaignDirectory '.\src\Campaigns\White Dragon (Classic)' `
    -RoutePath '.\src\scripts\classic_runtime\playtest\routes\white_dragon.json' `
    -OutputPath '.\src\scripts\classic_runtime\reports\classic_white_dragon_route_acceptance.json'
```

The runner creates one disposable profile under the system temporary directory,
launches the installed package through the normal campaign and party controls,
and writes the deterministic result to
`src/scripts/classic_runtime/reports/classic_white_dragon_route_acceptance.json`.

## Checked route

The source and package both start on land map 0 at `(43, 74)`. The route checks
eight source-identified milestones through the live Classic host and native UI:

1. `Data DD:0:8` continues Zukar's search for the White Dragon, renders the
   scenario-owned 300-by-300 PICT 32128, and introduces Brierwood.
2. Macro 346 adds Cylantra as ally 21 and sets quest 17. `Data DD:3:5` uses
   that quest as the gate for Cylantra to find Drawed's globe, then sets quest
   18 after he identifies Blake as the White Dragon's only hope.
3. `Data DD:1:5` reunites Blake with Drawed, sets quest 19, applies the two
   authored canyon action-data patches, and adds Blake as ally 6.
4. Macro 308 requires Blake for the successful restoration branch. Macros 310
   and 312 turn the glass dragon back into Raquiline, remove Blake, add White
   Dragon ally 28, and teleport the party to land map 2 at `(2, 40)`.
5. Macro 313 enters Battles 116 and 117. Their complete initial formations
   contain 18 and 16 hostile dragons respectively. Raquiline's survival selects
   the successful post-battle continuation.
6. Macro 316 enters Battle 118 with its complete 29-member initial planar
   formation and authored battle macro.
7. Macro 318 enters Battle 119 against Nufack and the complete 35-member
   initial formation. Raquiline's survival selects macro 372 rather than the
   no-ally ending branch.
8. Macro 372 presents messages 791 and 792 and Simple Encounter 12. The checked
   choice awards Treasure 46—Tools +20, Belt of Brawn, Improved Judgment, War
   Hammer +5, and Emerald Alloy Plate +10—before messages 794 and 795 explicitly
   end White Dragon.

## Quest and ally boundaries

Quest 17 is not manufactured for Drawed's scene. The route first executes
Cylantra's source recruitment continuation, then enters the quest-gated action
point. The installed runtime subsequently records quests 18 and 19 through
their authored action lists.

Blake and Raquiline also use their normal ally identities. Blake's presence
selects the successful restoration branch; macro 312 then removes ally 6 and
adds ally 28. The two post-battle ally checks prove that Raquiline survives the
checked route into the reward scene.

## Battle and reward boundaries

The route checks all four initial battle formations on native battlefields and
then forces victory after the player turn becomes stable. Battles 118 and 119
carry authored battle macros that can extend combat. This checkpoint does not
claim round-by-round coverage of every reinforcement or Nufack's death-macro
transformation.

The checked ending chooses the magical-treasure response and verifies the five
Classic item identities presented by Treasure 46. It does not bypass native
carry limits to force every optional reward item into the disposable
one-character test inventory. The special-power and no-reward responses remain
source-identified alternatives.

## Evidence boundary

The opening, Cylantra and Blake ally transitions, quests 17 through 19,
Raquiline's restoration, all four initial battle formations, the surviving
White Dragon branch, Treasure 46, and the explicit ending are runtime-exercised
through the installed package.

The route jumps directly between source-identified milestones. It does not
claim manual travel through all 12 land maps and four dungeons, the complete
Brierwood and Chloe arcs, every regional ally and side quest, every alternate
failure or reward branch, every battle reinforcement, or every encounter.

Quest, story, hint, reward, and completion details found during the trace are
retained in `CLASSIC_SCENARIO_ARCHAEOLOGY.md`.
