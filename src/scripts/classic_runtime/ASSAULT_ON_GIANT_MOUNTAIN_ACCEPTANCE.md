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

The route definition also pins the source completion anchor at
`Data ED3:macro:137`: messages 913 and 914 identify the end of the journey and
the accomplished main goal, with Treasure 77 and sound 20004 between them.
Compiled Battle 274 remains the final-battle identity associated with that
source sequence.

## Evidence boundary

The opening and Battle 60 are runtime-exercised. The completion macro and final
battle are source-verified anchors only; the current checkpoint does not claim
that the full start-to-finish path has been played. A later checkpoint must
drive the prerequisite quest state, final Battle 274, reward, and post-victory
messages through the installed runtime before this scenario is individually
certified.
