# Assault on Giant Mountain acceptance

Assault on Giant Mountain is the second first-party scenario with a dedicated
installed-route checkpoint. The shared 13-campaign lifecycle report already
covers normal menu discovery, launch, Save, and fresh-process Continue. This
route adds source-specific presentation and combat evidence without treating a
structural bundle check as end-to-end playability.

## Reproduce

Run from the repository root:

```powershell
& .\src\scripts\classic_runtime\tools\run_classic_scenario_route_acceptance.ps1
```

The runner creates one disposable profile under the system temporary directory,
launches the installed package through the normal campaign and party controls,
and writes the deterministic result to
`src/scripts/classic_runtime/reports/classic_assault_on_giant_mountain_route_acceptance.json`.

## Checked route

The source and package both start on land map 0 at `(48, 15)`. The route then
checks two compiled action points through the live Classic host and native UI:

1. `Data DD:0:60` at `(49, 15)` renders decoded PICT 32128 at 320 by 320 pixels
   and presents source messages 896, 897, and 898 in order. Its bundled sound
   24000 and stock sounds 10049 and -10001 retain their distinct resolution
   paths. Providence's sound 24000 WAV has an odd final PCM byte count and
   omits the RIFF pad byte; the compatibility loader pads a process-local copy
   without changing the packaged source or runtime-media evidence. Sound 23400
   remains explicitly classified as an absent external Classic resource whose
   source behavior is silence when unavailable; it is not counted as a stock
   sound or a supported playback path.
2. `Data DD:0:46` at `(50, 62)` presents source messages 160 and 161, then
   resolves Extra Code 70 to compiled Battle 60 and materializes it from the
   package after the native battle cache is cleared. Its 18 Hob Goblins, five
   Hob Goblin Champions, and six Hob Goblin Archers enter a drawable native
   battlefield. Forced victory uses the normal battle cleanup and returns to
   the authored land position with no pending Classic continuation.

The route then exercises the installed completion chain:

3. `Data DD:0:98` at `(83, 8)` presents Baron McReese's briefing and runs macro
   118. That macro replaces the adjacent report point at `(84, 8)` with macro
   102's quest dispatcher.
4. `Data DD:3:31` at `(88, 79)` presents Lequtus and resolves Extra Code 428 to
   Battle 274. Lequtus enters the native battlefield with 23 ice, hill, and fire
   giants. Forced victory resumes through messages 907 and 908, replaces the
   four fortress tiles with tile 155, sets quest flag 17, and disables the
   associated random-encounter rectangle.
5. Returning to `Data DD:0:99` at `(84, 8)` follows quest flag 17 into macros
   136 and 137. The installed UI presents the king's ceremony, three separate
   32,000-experience awards and their normal level-up popups, Treasure 77's
   three items, and messages 913 and 914 identifying the completed main goal.

Quest, story, hint, and reward details found during the trace are retained in
`CLASSIC_SCENARIO_ARCHAEOLOGY.md`.

## Evidence boundary

The opening, Battle 60, Baron setup mutation, Battle 274, quest-17 report,
experience awards, reward, and explicit completion message are runtime
exercised through the installed package. The route certifies the scenario's
completion chain; it does not claim a manual traversal of every intervening
fortress, stronghold, or optional encounter.
