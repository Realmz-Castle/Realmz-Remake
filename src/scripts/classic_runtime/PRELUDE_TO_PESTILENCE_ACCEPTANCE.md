# Prelude to Pestilence acceptance

Prelude to Pestilence is the eighth first-party scenario with a dedicated
installed-route checkpoint. The shared 13-campaign lifecycle report already
covers normal menu discovery, launch, Save, and fresh-process Continue. This
route adds the registered opening, Thyrr's transport into the secret camp, the
no-alliance final army, Griloch's defeat, the post-victory portal, and Mountain
View's explicit epilogue.

## Reproduce

Run from the repository root:

```powershell
& .\src\scripts\classic_runtime\tools\run_classic_scenario_route_acceptance.ps1 `
    -CampaignDirectory '.\src\Campaigns\Prelude to Pestilence (Classic)' `
    -RoutePath '.\src\scripts\classic_runtime\playtest\routes\prelude_to_pestilence.json' `
    -OutputPath '.\src\scripts\classic_runtime\reports\classic_prelude_to_pestilence_route_acceptance.json'
```

The runner creates one disposable profile under the system temporary directory,
launches the installed package through the normal campaign and party controls,
and writes the deterministic result to
`src/scripts/classic_runtime/reports/classic_prelude_to_pestilence_route_acceptance.json`.

## Checked route

The source and package both start on land map 1 at `(9, 62)`. The route checks
five source-identified milestones through the live Classic host and native UI:

1. `Data ED3:macro:76` presents decoded PICT 32128, removes the party's
   starting funds, and introduces the party's disoriented arrival.
2. `Data ED3:macro:250` has Thyrr transport the party into the secret Griloch
   camp on dungeon map 0 at `(26, 59)`.
3. `Data ED3:macro:254` opens the floodgates sequence. With quests 27, 29, and
   30 absent, macros 255 through 259 select Battle 87: 37 Griloch troops
   against Lluellyn, Retyu, Zulea, Safeera, Thyrr, and Cindred. Battle 86 then
   isolates Griloch. The continuation awards 32,000 experience, sets quest 40,
   and presents the free-wandering message.
4. Quest 40 makes `Data DD:0:73` run macro 286. Accepting its prompt changes
   land-map trigger 2 to macro 287 and teleports the party to Mountain View at
   `(16, 22)`.
5. The changed `Data DD:0:2` runs macro 287, presents the town's celebration
   and Mayor Hodar's thanks, and ends with the explicit registered-copy
   epilogue in messages 661 and 662.

The four signed sound requests in the floodgates sequence are all playable
stock mappings: clash, attack hit, metal hit, and resurrect death.

## Final-army variants

The installed route exercises the no-alliance branch and Battles 87 and 86.
The source contract also checks macros 255 through 259 and Battles 85 and 88:

- Quest 29 or 30 allows Battle 85, whose formation includes allied Minotaurs.
- Quest 27 with quests 29 and 30 absent selects Battle 88, whose formation
  includes hostile Minotaurs.
- With quests 27, 29, and 30 absent, Battle 87 omits Minotaurs but retains the
  six allied leaders used by the installed route.

These alternative formations are source-proven, not runtime-exercised by this
checkpoint.

## Compatibility defects exposed

The registered opening uses Classic's party-currency-clear action. Its adapter
already removed the money correctly, but the host did not automatically resume
the action list afterward. The host now treats that completed command like the
other synchronous resource mutations, with a focused continuation regression.

Classic battle-grid records use a negative monster entry to force that
combatant onto the party's side. Remake previously inverted the source
creature's faction, which made an already-friendly Cindred hostile. The
metadata path now forces both faction fields to friendly, with regressions for
already-friendly and hostile source records.

Battle 87 also exposed two acceptance-driver limits rather than game behavior:
its 43 combatants can take longer than the general interaction timeout to
instantiate, and a chained source battle can share a resource name with an
already-loaded native battle. Chained battles now receive a battle-specific
timeout and discard the conflicting cached entry before source materialization.

## Evidence boundary

The opening and currency removal, Thyrr transport, Battle 87's complete initial
formation, its six allies, Battle 86, the 32,000-experience award, quest 40,
the victory portal's runtime action-point mutation, the resulting Mountain
View epilogue, and the four signed sound mappings are runtime-exercised through
the installed package.

The route jumps directly between source-identified milestones and forces
victory after verifying each initial formation. It does not claim manual
traversal of every intervening map, individual combatant death, battle round,
or optional encounter. Battles 85 and 88 and their quest-dependent formations
remain source-proven.

Quest, story, hint, and completion details found during the trace are retained
in `CLASSIC_SCENARIO_ARCHAEOLOGY.md`.
