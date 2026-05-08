# Realmz Dump Importer

Editor tool that converts Realmz scenario text dumps (e.g. *City of Bywater
full script*) into the project's `map_scriptareas.json` + `map_scripts.gd`
file pair, one map level at a time.

## Usage

1. Make sure the plugin is enabled (Project → Project Settings → Plugins →
   "Realmz Dump Importer"). It's enabled by default in the committed
   `project.godot`.
2. Open **Project → Tools → Realmz: Import Scenario Dump...**.
3. Click **Pick Dump File...** and choose your `.txt` dump.
4. Set:
   - **Campaign Maps dir** — defaults to `res://Campaigns/City of Bywater/Maps/`.
   - **Level** — the integer suffix on `map_<N>` you want to populate (e.g. `5`
     fills `map_5`).
   - **Kind** — `LAND` for outdoor / interior land maps (matches `LAP<n>/i`
     entries in the dump), `DUNGEON` for `DAP<n>/i` entries.
   - **Dry-run** — when on, just prints stats + a preview to the log; doesn't
     touch disk.
5. Click **Import**. The log shows AP / RR counts and any unhandled opcodes
   that were left as `# TODO[<opcode>]:` comments in the GDScript output.

## What the importer does

- Parses the dump section by section (headers begin with `===== `).
- Filters to LAND_AP / DUNGEON_AP / LAND_RR / DUNGEON_RR records for the
  chosen `level`.
- Emits one `static func APIDxXyY()` per AP, mirroring the pattern used in the
  existing `Maps/map_0/map_scripts.gd`.
- Writes the matching `map_scriptareas.json` rect entries.

## Opcode coverage (first cut)

| Opcode | Translated to |
|---|---|
| `string "..."[, no_wait]` | `display_text_wait_noise(...)` (default sfx `'message nod.wav'`) |
| `set_dungeon 1(land), level=N, x=X, y=Y, dir=D` | `teleport_to_map_and_pos_divinity(N, X, Y, 0)` |
| `simple_enc SEC<N>` | `display_simple_encounter_Divinity(N)` |
| `complex_enc CEC<N>` | `start_complex_encounter_Divinity(N)` |
| `treasure TSR<N>` | `give_treasure_with_id(N)` |
| `give_map <N>` | `give_minimap(N)` |
| `sound <N>` | `play_sound_divinity(N)` |
| `exit_ap` | `return` (terminator added to every AP unconditionally) |
| Header `to_level=L to_x=X to_y=Y` | leading `teleport_to_map_and_pos_divinity(L, X, Y, 0)` |

Anything else (e.g. `option`, `battle`, `jmp_battle`, `jmp_xap`, `enable_ap`,
`modify_ap`, `set_dungeon` to a dungeon target, etc.) is emitted as
`# TODO[<opcode>]: <raw args>` so the human-translation work is visible
inline. Add coverage for these in follow-up PRs as their helper-call
conventions get nailed down.

## Design notes

- The dump has stray null bytes embedded in some string payloads. The parser
  strips them on read; they're a remnant of the original Realmz binary
  format leaking into the text export.
- Output is always rewritten in full; existing files are overwritten.
  Always use **dry-run** first or have your changes committed.
- `Paths` and `Secrets` in the JSON output are emitted as empty arrays. The
  dump format for those isn't yet plumbed through; preserve them by hand if
  the target file already has values.
