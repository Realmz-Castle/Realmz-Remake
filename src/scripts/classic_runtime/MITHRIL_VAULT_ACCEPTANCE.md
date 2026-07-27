# Mithril Vault acceptance

Mithril Vault is the seventh first-party scenario with a dedicated
installed-route checkpoint. The shared 13-campaign lifecycle report already
covers normal menu discovery, launch, Save, and fresh-process Continue. This
route adds the opening presentation, The Geyser's complete item lifecycle,
four native battles, the fortress-power mutation, final rewards, and the
explicit main-goal ending.

## Reproduce

Run from the repository root:

```powershell
& .\src\scripts\classic_runtime\tools\run_classic_scenario_route_acceptance.ps1 `
    -CampaignDirectory '.\src\Campaigns\Mithril Vault (Classic)' `
    -RoutePath '.\src\scripts\classic_runtime\playtest\routes\mithril_vault.json' `
    -OutputPath '.\src\scripts\classic_runtime\reports\classic_mithril_vault_route_acceptance.json'
```

The runner creates one disposable profile under the system temporary directory,
launches the installed package through the normal campaign and party controls,
and writes the deterministic result to
`src/scripts/classic_runtime/reports/classic_mithril_vault_route_acceptance.json`.

## Checked route

The source and package both start on land map 0 at `(37, 5)`. The route checks
eight source-identified milestones through the live Classic host and native UI:

1. `Data DD:0:0` presents decoded PICT 32128, stock sound 20001, and the
   Winterhaven and Silver Peak premise.
2. `Data ED3:macro:138` reveals Morbius, sets quest 77, and enters Battle 33
   against his body and three images.
3. `Data ED3:macro:157` enters Battle 40. Its complete 24-combatant formation
   includes Gail Wyrmrider. Native defeated-enemy loot supplies The Geyser
   (item 809), which the route takes into party inventory.
4. `Data DD:1:27` accepts item 809 at the Winterhaven council and directs the
   party to King Cormite.
5. `Data DD:8:1` accepts item 809, enters Battle 41 beside Cormite and 25
   allied dwarves against 22 aliens, then removes the stolen relic from party
   inventory.
6. `Data DD:8:5` sounds the fortress alarm and enters Battle 53 against 20
   Golian defenders.
7. `Data DD:8:3` and macro 186 disable the fortress power and change the
   initially inactive land-10 trigger 2 to 100 percent.
8. The activated `Data DD:10:2` restores item 809 through Treasure 38, resolves
   Weston's curse, gives the party-wide level-up, awards items 195, 197, 471,
   and 733 through Treasure 39, removes item 809, deletes the consumed trigger,
   and presents message 562's explicit completion text.

## The Geyser lifecycle

The Geyser is not an abstract quest flag. Gail Wyrmrider's Classic monster
record carries item 809 in inventory slot six. Battle 40's native loot passes
that exact item instance to the party. The council and Cormite gates both test
possession of 809; the invasion continuation removes it when the aliens steal
it. Treasure 38 restores it at the Gridstone, and the ending removes it after
the completed exchange.

The route exposed a native-loading edge case in that lifecycle: Gail also
carries enough money to exceed Remake's generic inventory weight limit.
Generated Classic bestiary loadouts now preserve their authored items even
when their money would otherwise reject every carried item.

## Source-only battle chains

The initial Morbius formation is runtime-proven. Its individual death hooks are
source-proven: monsters 61 and 62 use macros 151 and 150, those macros replace
the images and body, and weakened monster 63 uses macro 148 to present
Treasure 36.

Battles 45 through 49 form the intervening alien and Golian counterattack.
Their records and macros 170, 171, 175, 180, and 182 are checked by the route's
source contract, including macro 182's additional combatant spawns. The
installed route jumps from the warren invasion to the fortress security battle
instead of manually fighting those five battles, so they remain source-proven.

## Evidence boundary

The opening, Battles 33, 40, 41, and 53, Battle 40's real monster loot,
item-809 possession gates and removal, Cormite's allied formation, the
fortress-power activation, both final treasures, the all-party level-up,
the consumed completion trigger, the final inventory, and message 562 are
runtime-exercised through the installed package.

The route jumps directly between source-identified milestones and forces
victory after verifying each initial formation. It does not claim manual
traversal of every intervening map, individual monster death, battle round, or
optional encounter.

Quest, story, hint, and completion details found during the trace are retained
in `CLASSIC_SCENARIO_ARCHAEOLOGY.md`.
