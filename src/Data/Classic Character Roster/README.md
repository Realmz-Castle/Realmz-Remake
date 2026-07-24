# Classic stock character roster

This directory packages the seven character records shipped with PC Realmz:
Cindred, Midnight, Traskelion, Sliver, Solestri, Tristan, and Wyrmwood.

`source-records` retains the original 872-byte, big-endian records. The
manifest records each source SHA-256 and the fields decoded from that record.
The portrait and combat-icon directories contain the exact decoded images for
the resource IDs named in those records. The generated `Characters`
directories are normal Remake character saves, so the existing profile loader
and party picker need no stock-character-only loading path.

When a valid Classic campaign is selected, Remake copies any missing stock
characters into the current profile. An existing character directory with the
same name is left unchanged.

The conversion preserves the source record in two forms: the exact binary in
`source-records`, and the parsed `classicSourceCharacter` snapshot on the
Remake character. Native items and spells are resolved by their preserved
Classic IDs. Classic combat values that do not have a one-to-one Remake stat
are translated by the builder; the preserved source snapshot remains the
authoritative value for future compatibility work.

Regenerate the Remake character directories from the manifest with:

```powershell
godot --headless --path src `
  res://scripts/classic_runtime/tools/build_classic_stock_roster.tscn
```
