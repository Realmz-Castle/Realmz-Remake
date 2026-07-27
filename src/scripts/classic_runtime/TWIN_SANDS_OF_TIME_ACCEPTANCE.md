# Twin Sands of Time acceptance

Twin Sands of Time is the tenth first-party scenario with a dedicated
installed-route checkpoint. The shared 13-campaign lifecycle report already
covers normal menu discovery, launch, Save, and fresh-process Continue. This
route adds Emi's main assignment, the Dagger of Eromon, both twins' ally
identities, Ja-Dran and Allimac, the coffin encounter, the Prince's reward, and
the explicit main-plot ending.

## Reproduce

Run from the repository root:

```powershell
& .\src\scripts\classic_runtime\tools\run_classic_scenario_route_acceptance.ps1 `
    -CampaignDirectory '.\src\Campaigns\Twin Sands of Time (Classic)' `
    -RoutePath '.\src\scripts\classic_runtime\playtest\routes\twin_sands_of_time.json' `
    -OutputPath '.\src\scripts\classic_runtime\reports\classic_twin_sands_of_time_route_acceptance.json'
```

The runner creates one disposable profile under the system temporary directory,
launches the installed package through the normal campaign and party controls,
and writes the deterministic result to
`src/scripts/classic_runtime/reports/classic_twin_sands_of_time_route_acceptance.json`.

## Checked route

The source and package both start on land map 1 at `(52, 34)`. The route checks
twelve source-identified milestones through the live Classic host and native
UI:

1. `Data DD:1:9` presents message 2, decoded PICT 30128, and the authored click
   gate before opening the surrounding scenario items.
2. `Data DD:1:31` introduces Emi. Accepting his invitation runs macros 111 and
   112, identifies the twins' disappearance and unnatural sand as the main
   mystery, and transports the party into the scenario.
3. `Data DD:0:12` supplies item 914, the Dagger of Eromon, through Treasure 44.
4. `Data DD:5:9` enters Battle 62 against Ja-Dran, one Red Dragon. Victory
   reveals Ollahn, presents Treasure 20, and adds Ollahn as ally 144.
5. Macro 129 turns Ollahn over to the Queen's representatives, removes ally
   144, and sets quest 67.
6. Macro 131 adds ally 145. Its dialogue calls the recruit Guntro, while the
   source monster identity and every later story consumer call him Malear.
7. `Data DD:6:35` recognizes ally 145 as Malear. Macros 201 and 218 establish
   the plan to reunite the twins, kill Allimac, grant map 14, and transport the
   party to the invasion route.
8. Macros 244 through 250 transform Malear from ally 145 to ally 155 and enter
   Battle 105. Its initial formation contains 32 hostiles, including Orc
   Vampire Allimac, plus eleven Prince's Royal Guards and one Prince's Captain.
   Victory reunites the twins and restores Ollahn as ally 144.
9. Macro 251 opens complex encounter 23. The native item picker accepts the
   exact Dagger of Eromon, presents Allimac's permanent destruction, applies
   the tomb mutations, and sets quest 69.
10. Macro 205 transports the party to the Prince's celebration square. The
    destination action point is a separate interaction rather than an
    automatically executed continuation.
11. `Data DD:6:37` presents the memorial and celebration. Declining to remain
    follows macro 207, awards Treasure 30 and 1,000 experience, and transports
    the party to the castle gate.
12. `Data DD:4:81` is another separate action point. Messages 572 and 573
    explicitly conclude Twin Sands of Time, declare the main plot finished,
    and preserve free post-game wandering.

The selected scenario-owned sounds `-11750` and `-22041` both resolve to their
bundled runtime media.

## Dagger response boundary

The Dagger of Eromon is both present in Treasure 44 and exposed by complex
encounter 23's item picker. The result text says the dagger crumbles to dust,
but the encounter's compiled result does not contain an item-removal action.
Classic ordinary encounter-response items are inspected rather than consumed,
so item 914 remains in inventory while quest 69 and the tomb mutations advance.

The checkpoint preserves that compiled behavior. It does not reinterpret the
narrative line as an engine instruction or claim that the dagger is consumed.

## Battle boundary

Battle 105's complete initial formation and twelve friendly combatants are
runtime-exercised. Its battle macro can call macro 256 while monster 152 is
present and summon additional enemies. The route forces victory after the
initial formation reaches a stable player turn, so reinforcement cycles and
individual deaths remain source-proven rather than runtime-exercised.

## Acceptance-driver coverage

Twin Sands required two reusable route-driver additions:

- an explicit click event verifies a picture shown after a text message and
  closes Classic's separate Get Click command;
- a complex-item step may now run authored text prelude events before the item
  picker opens.

Both paths remain source-checked. Existing route schemas without those optional
events keep their previous behavior.

## Evidence boundary

The opening picture, Emi assignment, Dagger treasure, Ja-Dran battle, Ollahn
and Malear ally transitions, invasion map, Battle 105's initial formation,
coffin item response, quests 67 and 69, return teleport, celebration reward,
and explicit ending are runtime-exercised through the installed package.

The route jumps directly between source-identified milestones and forces
victory after checking each initial formation. It does not claim manual
traversal of all eight land maps and two dungeons, the search for the Shield of
the Eternal, every intervening quest, Battle 105 reinforcement rounds, the
celebration-acceptance branch, or every optional encounter.

Quest, story, hint, and completion details found during the trace are retained
in `CLASSIC_SCENARIO_ARCHAEOLOGY.md`.
