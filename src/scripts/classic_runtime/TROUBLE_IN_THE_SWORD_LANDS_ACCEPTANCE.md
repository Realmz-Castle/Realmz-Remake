# Trouble in the Sword Lands acceptance

Trouble in the Sword Lands is the ninth first-party scenario with a dedicated
installed-route checkpoint. The shared 13-campaign lifecycle report already
covers normal menu discovery, launch, Save, and fresh-process Continue. This
route adds the Bywater mandate, Naryl's two ally identities, Kith Khanaan's
talisman lifecycle, the Kith-weakened final battle, and the explicit main-plot
ending.

## Reproduce

Run from the repository root:

```powershell
& .\src\scripts\classic_runtime\tools\run_classic_scenario_route_acceptance.ps1 `
    -CampaignDirectory '.\src\Campaigns\Trouble in the Sword Lands (Classic)' `
    -RoutePath '.\src\scripts\classic_runtime\playtest\routes\trouble_in_the_sword_lands.json' `
    -OutputPath '.\src\scripts\classic_runtime\reports\classic_trouble_in_the_sword_lands_route_acceptance.json'
```

The runner creates one disposable profile under the system temporary directory,
launches the installed package through the normal campaign and party controls,
and writes the deterministic result to
`src/scripts/classic_runtime/reports/classic_trouble_in_the_sword_lands_route_acceptance.json`.

## Checked route

The source and package both start on land map 0 at `(1, 1)`. The route checks
six source-identified milestones through the live Classic host and native UI:

1. `Data DD:0:0` presents decoded PICT 32128 and explains that the King of
   Bywater sent the party to investigate the disruption of regional trade.
   Its continuations set quest 6.
2. `Data ED3:macro:251` frees the swordswoman prisoner. Accepting her offer
   adds Naryl Dragonstone (monster 161) as an ally.
3. `Data ED3:macro:2019` searches the hidden column and presents Treasure 182.
   The route takes Kith's Talisman (item 944) and its 1,000-experience award
   through the native treasure UI.
4. Item 944 targets `Data ED3:macro:2021`. The installed route invokes that
   target, presents Kith Khanaan's emergence, removes item 944, drops Naryl
   Dragonstone, and adds the Kith-possessed Naryl Thezzat (monster 235).
5. `Data DDD:3:49` detects ally 235 and selects macro 2055. Kith attacks the
   Overlords psionically, restores Naryl Dragonstone, and reduces the final
   confrontation to Battle 349: two Overlords and General Arla Qui. Its
   victory continuation opens the headquarters for searching.
6. `Data DDD:3:51` presents PICT 30124 and the surviving Inner Council's
   warning that war is coming. Macro 2074 then explicitly declares the main
   plot complete, advertises War in the Sword Lands as part two, shows the
   credits, and awards 10,000 experience.

The route verifies one scenario-owned sound, the Bird resource requested as
`-203`, and every stock sound used by these milestones as playable native
mappings.

## Kith's Talisman lifecycle

Treasure 182 is the source of item 944. The item record names it Kith's
Talisman and points its door-activation field to macro 2021. The route takes
that exact item, runs its source target, and verifies that macro 2025 removes
item 944 while changing Naryl's ally identity from 161 to 235.

The checkpoint invokes the item's compiled target directly after obtaining the
item; it does not claim coverage of a general inventory-use button. The item
possession, target action list, item removal, ally replacement, and resulting
final-room branch are runtime-exercised.

## Alternate final battle

Without Naryl Thezzat, the final room continues through macro 2056. Accepting
the Overlords' offer submits the party to their New Order. Refusing enters
Battle 203 instead of Battle 349.

Battle 203's source formation contains 46 initial enemies: Mind-Mages,
Psi-warriors, Psi-stalkers, the three Overlords, and six additional spellcaster
records. Its battle macro can add further warriors. The route source-checks the
alternative branch and Battle 203's existence, but does not runtime-exercise
that formation.

## Evidence boundary

The opening, quest 6, Naryl recruitment, Treasure 182, item-944 possession and
removal, both Naryl ally identities, the Kith-specific branch, Battle 349's
complete initial formation, the post-battle headquarters state, both pictures,
the explicit ending, the 10,000-experience award, and selected sound mappings
are runtime-exercised through the installed package.

The route jumps directly between source-identified milestones and forces
victory after verifying Battle 349's initial formation. It does not claim
manual traversal of the scenario's twenty land maps, every intervening quest,
the three regional crises, the unassisted Battle 203, individual Overlord
death hooks, battle rounds, or optional adventures.

Quest, story, hint, and completion details found during the trace are retained
in `CLASSIC_SCENARIO_ARCHAEOLOGY.md`.
