# Wrath of the Mind Lords acceptance

Wrath of the Mind Lords is the thirteenth first-party scenario with a dedicated
installed completion-route checkpoint. The shared 13-campaign lifecycle report
already covers normal menu discovery, launch, Save, and fresh-process Continue.
This route adds the trilogy-continuity opening, the restored timeline, Uther
Maddrix, Oberon's recruitment, Primus, the Astral pursuit, the Sceptanar,
Xenon Maximus, the Ashaan'ru Queen, the spoken way home, and the explicit
registered-scenario ending.

## Reproduce

Run from the repository root:

```powershell
& .\src\scripts\classic_runtime\tools\run_classic_scenario_route_acceptance.ps1 `
    -CampaignDirectory '.\src\Campaigns\Wrath of the Mind Lords (Classic)' `
    -RoutePath '.\src\scripts\classic_runtime\playtest\routes\wrath_of_the_mind_lords.json' `
    -OutputPath '.\src\scripts\classic_runtime\reports\classic_wrath_of_the_mind_lords_route_acceptance.json'
```

The runner creates one disposable profile under the system temporary directory,
launches the installed package through the normal campaign and party controls,
and writes the deterministic result to
`src/scripts/classic_runtime/reports/classic_wrath_of_the_mind_lords_route_acceptance.json`.

Two consecutive finalized runs produced SHA-256
`d1406943426b722599aa9303962823210aefbb215bfbbe76b96a071558b0489c`.

## Checked route

The source and package both start on land map 0 at `(3, 84)`. The route checks
15 source-identified steps through the live Classic host and native UI,
summarized here in ten phases:

1. Macro 19 records that both previous Sword Lands adventures were completed.
   The route's fixed random seed selects the authored mine-slave prologue,
   presents all 20 entries in Treasure 2, and moves the party to land map 9 at
   `(6, 7)`.
2. Macro 433 restores the heroes' original identities and equipment. Macro 553
   then reveals Primus's mystic orbs, enters Battle 308 against Uther Maddrix,
   restores the original timeline on victory, and sets quest 14.
3. `Data DD:7:57` recruits Oberon as ally 245. `Data DD:15:66` reveals
   Maximus, enters Battle 518 against Primus and his five psionic guards, and
   leaves the one-way vortex open.
4. Macro 1907 selects the main-story Astral pursuit instead of the early
   ending. `Data DD:8:2` refuses Sappho Nynex's demand for worship and uses
   Battle 308 a second time for her Mind Lord incarnation.
5. `Data DD:8:8` records quest 73 and accepts the Sceptanar's bargain. Macro
   2039 then introduces Maximus and his two surviving siblings in the castle.
6. Macro 2040 enters Battle 530 against Nuul Zarrakian and Azure Malachys,
   followed by Battle 531 against Xenon Maximus and two Nightmares. The
   installed continuation records quest 72 and presents both five-member
   20,000-experience award chains.
7. `Data DD:19:22` enters Battle 536 against the Ashaan'ru Queen, five
   Warriors, and two Lords. The post-battle room continuation sets quest 71
   and exposes the Queen's treasure-bed.
8. `Data DD:19:23` presents the complete 12-item Treasure 151 hoard. The route
   takes only scenario item 712, the serpent head required by the Sceptanar.
9. Macro 2059 consumes item 712, sets quest 74, and identifies the return
   diagram. Complex Encounter 83 accepts `ethro astranox`, displays its full
   native action menu, and teleports the party to land map 15 at `(49, 44)`.
10. Macro 1928 removes Oberon, grants the final five-member experience chain,
    presents the prior-trilogy remembrance selected by quests 1 and 4, and
    reaches messages 2601 and 2557: the explicit main-story completion and
    registered-scenario thanks.

## Random opening boundary

The installed opening uses authored random branches after the continuity
choice. Route seed 438 is applied only after the source contract has been
verified and deterministically selects the mine prologue. The checkpoint
proves that branch; it does not claim runtime coverage of every alternate
opening.

## Item identity and treasure boundaries

Treasure 2 uses Classic stock item 98. The authoritative stock `Data ID`
resource names both item 98 and item 102 `Quarter Staff`. Item 102 remains the
canonical native definition, while item 98 is now a supported alias whose
requested Classic identity is retained on each materialized instance. The
runtime unit suite checks both the primary identity and alias order.

Treasure 151 contains 12 items, but only item 712 advances this completion
route. The native treasure screen still verifies the complete authored hoard;
the route's selective-loot option takes only the serpent head and leaves the
other optional rewards untouched.

## Battle and experience boundaries

The route checks each complete initial battle formation on a native battlefield
and then forces victory after the player turn becomes stable. Battle 308 appears
twice in the runtime evidence because the scenario deliberately reuses it for
Uther Maddrix and Sappho Nynex.

The 20,000-experience rewards are represented as individual native treasure
yields. Two five-member chains occur after Maximus and another five-member
chain occurs during the final trilogy remembrance. They are not collapsed into
a prose-only reward claim.

## Evidence boundary

The trilogy flags, deterministic mine opening, restored identities, quests 14,
71 through 74, Oberon ally 245, all six battle executions, both Sceptanar
scenes, the full Queen's hoard, consumed serpent head, spoken return phrase,
explicit ending, and registered-scenario message are runtime-exercised through
the installed package.

The route jumps directly between source-identified milestones. It does not
claim manual travel through all scenario maps, every alternate opening or
ending, every regional quest, optional reward, companion variation, battle
round, or encounter.

Quest, story, hint, item-identity, and completion details found during the trace
are retained in `CLASSIC_SCENARIO_ARCHAEOLOGY.md`.
