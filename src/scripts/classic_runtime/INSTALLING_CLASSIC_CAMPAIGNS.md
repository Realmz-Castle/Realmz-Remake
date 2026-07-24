# Installing Classic campaigns

A compiled Classic campaign is installed as one directory directly below
Realmz Remake's `Campaigns` directory. The package is self-contained; the game
does not retain the Providence project path or any other source-machine path.
For the complete export, readiness, installation, update, acceptance, and
regression sequence, see the
[Classic support matrix and porting workflow](CLASSIC_PORTING_GUIDE.md).

```text
Campaigns/
  Example Campaign/
    campaign.json
    classic/
      scenario.json
      maps.json
      scripts.json
      encounters.json
      content.json
      rules.json
      assets.json
      evidence.json
    assets/
      managed/
        ...
    Maps/
    Tilesets/
    Items/
    Bestiary/
    Battles/
    Sounds/
    Splash Images/
```

`campaign.json` selects compatibility mode with this versioned identity:

```json
{
  "format": "realmz-remake-classic-campaign",
  "formatVersion": 1,
  "campaignKind": "classic-compiled",
  "compatibilityProfile": "realmz-7.1"
}
```

The manifest's `files` object names the eight normalized documents. All document
and payload paths are relative to the campaign directory; absolute paths,
drive-qualified paths, and `.` or `..` components are rejected. Declared managed
payloads must be present and match their exported byte count and SHA-256 digest.
An unsupported format, profile, document version, missing file, or failed payload
check stops the campaign before its runtime host is registered.

Decoded resources use the same optional campaign folders as native Remake
campaigns. Compatible tiles, maps, items, monsters, battles, sounds, and pictures
are therefore loaded by `CampaignResources` rather than by a parallel asset
system. The normalized `classic` documents remain owned by
`ClassicCampaignBundle`; they supply action lists, encounter semantics, stable
Classic identities, and other data that native resource books do not represent.
Raw Classic resource payloads are not assumed to be directly usable by Godot.

The campaign directory name remains Realmz Remake's selected campaign identity.
`GameGlobal.set_current_campaign()` is the only current-campaign owner. During
the normal Exploration start path, native resources load first, then a
`ClassicCampaignSession` validates the package, creates the runtime host, and
activates the compiled starting map and position.

## Installing and updating

In a release build, open **Start Campaign**, choose **Install Classic...**, and
select the complete campaign export directory produced by Providence. Realmz
Remake validates the selected package, installs it into the writable `Campaigns`
directory beside the executable, refreshes the campaign list, and selects the
installed campaign. Selecting a newer export with the same directory name
prompts before replacing the existing package. Saves remain in the separate
`Profiles` directory.

For automation or development builds, close any running game and install a
complete export with Godot:

```powershell
godot --headless --path src --script `
  res://scripts/classic_runtime/tools/install_classic_campaign.gd -- `
  "C:\path\to\exported-campaign"
```

The optional second positional argument selects a different `Campaigns`
directory. The installer validates the compiled source, copies the complete
package to a temporary directory below `Campaigns`, materializes missing native
maps there, validates the staged launch state, and then moves it into place.
Providence does not need to emit Remake's private `map_things.json` or map-script
files. Existing complete native maps remain available for hand-maintained native
campaigns; when they are absent, Remake is the sole owner of compiled-map
materialization.

Materialization supports complete outdoor tile arrays that resolve to a shared
Remake landlook or an already decoded campaign tileset. A custom landlook with a
decoded 640 x 320 `runtimeMedia` image is converted into a 200-tile native
tileset using its compiled behavior records. The generated templates retain
movement, sight, water, shore, timing, path, clear-land, combat-build, and sound
identities. Materialization also converts ordinary Classic dungeon fields into a
campaign-local native tileset using Realmz's PICT 302 overhead sprites. The
generated tiles retain their signed field value and native movement behavior for
walls, doors, note cells, and Action Point cells.
Directional secret passages use their Classic north, east, south, and west entry
bits; entering from a permitted direction reveals the passage in native map data
and persistent Classic state, while other directions remain blocked. Stable
Action Point IDs, trigger chances, and normalized random rectangles use the
normal map files in both map families. A special negative land field with decoded
32 x 32 image media becomes a campaign-local overlay over the map's base terrain.
The generated tile retains the raw field and normalized `cicn` identity; `Data
Solids` supplies movement blocking for raw fields `-1` through `-998`. An
undecoded custom atlas, special land tile without suitable decoded media,
incomplete tile array, unknown render mode, or atlas-capacity mismatch is
reported instead of receiving lossy data. A package that is not ready to launch
is not installed.

Pass `--replace` to update an existing campaign. The old package remains in
place until the staged update passes validation, and the update replaces the
whole campaign directory rather than mixing files from different exports. Keep
the exported folder name and manifest `id` stable across updates. Player saves
live below `Profiles`, outside the installation target, so package replacement
does not overwrite them; compatibility with an older save still depends on
stable referenced identities and resources as well as the bundle and
saved-state versions. The installer's temporary rollback copy is removed after
a successful update, so retain the previous export, back up the affected
profiles, and load representative existing saves against a test installation
before replacing the live package. Use `--json` for a machine-readable result.

The source directory must already contain the complete exported campaign. In
particular, do not pass only its `classic` subdirectory, and do not treat raw
Classic resource payloads as decoded Godot images, sounds, or custom tilesets.
