# Castle in the Clouds acceptance

Castle in the Clouds is the third first-party scenario with a dedicated
installed-route checkpoint. The shared 13-campaign lifecycle report already
covers normal menu discovery, launch, Save, and fresh-process Continue. This
route adds source-specific presentation and combat evidence without treating a
structural bundle check as end-to-end playability.

## Reproduce

Run from the repository root:

```powershell
& .\src\scripts\classic_runtime\tools\run_classic_scenario_route_acceptance.ps1 `
    -CampaignDirectory '.\src\Campaigns\Castle in the Clouds (Classic)' `
    -RoutePath '.\src\scripts\classic_runtime\playtest\routes\castle_in_the_clouds.json' `
    -OutputPath '.\src\scripts\classic_runtime\reports\classic_castle_in_the_clouds_route_acceptance.json'
```

The runner creates one disposable profile under the system temporary directory,
launches the installed package through the normal campaign and party controls,
and writes the deterministic result to
`src/scripts/classic_runtime/reports/classic_castle_in_the_clouds_route_acceptance.json`.

## Checked route

The source and package both start on land map 0 at `(61, 66)`. The route then
checks two compiled action points through the live Classic host and native UI:

1. `Data DD:0:1` at `(60, 67)` renders decoded PICT 32128 at 320 by 320 pixels,
   plays stock sound -20004 through its native `hallelujah.wav` mapping, and
   presents source message 1. The following opcode 200 is not assigned invented
   behavior: the package's source-backed `dispatcherNoops` row identifies this
   exact action slot as a Classic dispatcher fall-through, after which the
   action point removes itself normally.
2. `Data DD:0:23` at `(39, 71)` plays stock sounds -30000 and -30002 through
   their native growl mappings, presents source message 41, and resolves Extra
   Code 251 to compiled Battle 3. Four Cave Bears enter a drawable native
   battlefield. Forced victory uses the normal battle cleanup and returns to
   the authored land position with no pending Classic continuation.

The route then exercises the installed completion chain. `Data DD:1:31` at
`(6, 8)` introduces Nufack and resolves Extra Code 2266 to surprise Battle 223:
two Evil Mages, ten Evil Warriors, eight Evil Paladins, and nineteen Evil
Rangers. Forced victory resumes through one safe castle-collapse branch.
`Data DD:1:33` at `(5, 87)` then leads into macro 223, whose Treasure 71,
picture, messages 853, 895, and 854, quest flag 16, and McBane teleport form the
authored epilogue and point toward the White Dragon sequel.

Quest, story, hint, and reward details found during the trace are retained in
`CLASSIC_SCENARIO_ARCHAEOLOGY.md`.

## Evidence boundary

The McBane arrival, Battle 3, Battle 223, a safe castle-collapse branch, Zukar's
reward and epilogue, quest flag 16, six castle tile mutations, and the return
teleport are runtime-exercised through the installed package. The route
certifies the completion chain; it does not claim a manual traversal of every
intervening room or optional encounter.
