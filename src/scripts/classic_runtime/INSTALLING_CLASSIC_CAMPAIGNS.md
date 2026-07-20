# Installing Classic campaigns

A compiled Classic campaign is installed as one directory directly below
Realmz Remake's `Campaigns` directory. The package is self-contained; the game
does not retain the Providence project path or any other source-machine path.

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

To install a campaign, close any running game and copy the complete exported
directory below `Campaigns`. Do not copy only the `classic` directory. Keep the
exported folder name and manifest `id` stable when updating an installed
campaign. Player saves live below `Profiles`, outside the installed package, so
an update does not overwrite them; compatibility with an older save still
depends on the bundle and saved-state versions. Replace the complete campaign
directory as one update rather than mixing files from different exports, and
retain the previous package until the updated campaign has passed validation.
