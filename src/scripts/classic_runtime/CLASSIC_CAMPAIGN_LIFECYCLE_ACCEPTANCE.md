# Classic campaign lifecycle acceptance

This checkpoint covers the shared installed-campaign lifecycle for all 13
first-party Classic packages. It is intentionally narrower than scenario
acceptance: a passing lifecycle run does not prove a scenario's representative
encounters, battles, or completion route.

For each package, two fresh Godot processes use one disposable profile:

1. The normal campaign menu resolves the package's full selection rules and
   reports `Ready` or `Ready with fallbacks`.
2. The normal party picker admits a profile character and Start enters the
   compiled campaign at the exact `campaign.json` map and coordinates.
3. The native map is drawable and the ordinary HUD Save controls persist the
   native files plus an idle Classic runtime envelope.
4. A fresh process discovers the campaign and checkpoint through the main-menu
   Load controls and restores the same native and Classic position with no
   pending continuation.

The runner discovers only `classic-compiled` packages, requires exactly 13 by
default, uses the Dummy audio driver, and removes only the disposable profile
directories that it created under the system temporary directory.

Godot's Windows test process can fault during full-scene teardown after the
phase has closed its evidence file. The runner prints that process exit. A
closed `passed` phase remains authoritative because the save phase has already
verified the files on disk and the next fresh process must load them
successfully. A fault before evidence is written, or any failed assertion in
the evidence, still fails the campaign.

## Reproduce

Run the complete built-in corpus from the repository root:

```powershell
& .\src\scripts\classic_runtime\tools\run_classic_campaign_lifecycle_acceptance.ps1
```

The command writes the deterministic result to
`src/scripts/classic_runtime/reports/classic_builtin_campaign_lifecycle_acceptance.json`.
Use `-CampaignDirectoryName "Assault on Giant Mountain (Classic)"` for a focused
run; focused output should be directed to a temporary path rather than replacing
the 13-campaign report.

## Current checkpoint

The retained corpus report passes 13 of 13 packages with no semantic failure.
Every package is `Ready with fallbacks`, admits the stock Cindred profile
character, enters its authored land-map coordinates on a drawable native map,
writes all four required native save files with an idle Classic envelope, and
restores the exact native and Classic position in a fresh process with no
pending continuation.

## Evidence boundary

This report can be combined with the authoritative readiness/footprint report
for install, discovery, launch, and save/Continue evidence. Each scenario still
needs a separate source-backed route covering representative exploration,
encounter and battle behavior, plus its documented completion route. Those
routes should reuse this lifecycle checkpoint rather than duplicate its menu and
disk-boundary assertions.
