# Realmz Dump Importer

Editor tool that converts Realmz scenario text dumps (e.g. *City of Bywater
full script*) into the project's `map_scriptareas.json` + `map_scripts.gd`
file pair, in bulk across all map levels in one click.

## Usage (default — bulk import)

1. Make sure the plugin is enabled (Project → Project Settings → Plugins →
   "Realmz Dump Importer"). It's enabled by default in the committed
   `project.godot`.
2. Open **Project → Tools → Realmz: Import Scenario Dump...**.
3. Click **Pick Dump File...** and choose your `.txt` dump.
4. Set:
   - **Campaign Maps dir** — defaults to `res://Campaigns/City of Bywater/Maps/`.
     Change this to the equivalent path for any other scenario.
   - **Force overwrite** — leave **off** unless you really want to clobber
     hand-ported maps. The default skip-if-already-ported heuristic (≥ 20
     `static func` definitions in the existing `map_scripts.gd`) protects
     `map_0` and any other map that's been finished.
   - **Dry-run** — leave **on** for the first run; reports per-map sizes and
     unhandled-opcode counts without writing anything.
5. Click **Import All**. The importer:
   - Parses the dump.
   - Discovers every `(LAND/DUNGEON, level)` pair that has APs.
   - Routes `LAND level=N` → `<Campaign Maps>/map_<N>/` and `DUNGEON level=N`
     → `<Campaign Maps>/mapd_<N>/`.
   - Reports each map as **DRY-RUN**, **WRITTEN**, **SKIPPED** (with reason),
     or **ERROR** in a single result table in the log.

Example result table for City of Bywater (after the first proper run):

```
MAP      KIND     APs      RESULT
map_0    LAND     95       SKIPPED (already ported: 263 funcs ...)
map_1    LAND     37       WRITTEN (5 unhandled opcodes ...)
map_2    LAND     12       WRITTEN ...
map_3    LAND     23       WRITTEN ...
map_4    LAND     47       WRITTEN ...
map_5    LAND     97       WRITTEN ...
map_6    LAND     56       WRITTEN ...
map_7    LAND     98       WRITTEN ...
map_8    LAND     97       WRITTEN ...
mapd_0   DUNGEON  23       WRITTEN ...
mapd_1   DUNGEON  91       WRITTEN ...
```

## Single-map mode (advanced)

Tick **Show advanced options → Single-map mode** to import exactly one
`(level, kind)` instead of iterating the whole dump. Useful when:

- Regenerating one specific map after fixing an opcode translation in the
  emitter.
- Testing the emitter against `map_0` without touching the existing hand-port
  (combine with **Dry-run** + leave **Force overwrite** off).

## Cross-scenario reuse

The dump format is scenario-agnostic. To run on a different scenario:

1. Point **Dump file** at that scenario's text dump.
2. Point **Campaign Maps dir** at `res://Campaigns/<NewScenario>/Maps/`.
3. Click **Import All**.

No code changes — the only knob that distinguishes scenarios is the campaign
root path.

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
| `exit_ap` | `return` (terminator added unconditionally to every AP) |
| Header `to_level=L to_x=X to_y=Y` | leading `teleport_to_map_and_pos_divinity(L, X, Y, 0)` |

Anything else (e.g. `option`, `battle`, `jmp_battle`, `jmp_xap`, `enable_ap`,
`modify_ap`, `set_dungeon` to a dungeon target) is emitted as
`# TODO[<opcode>]: <raw args>` so the human-translation work is visible
inline. Coverage extends opcode-by-opcode in follow-up PRs.

## Design notes

- The dump has stray null bytes embedded in some string payloads. The parser
  strips them on read; they're a leftover of the binary→text export.
- Output is always rewritten in full when a map is processed; per-line merges
  aren't supported. The skip-if-already-ported heuristic plus Dry-run +
  commit-before-running are the safety net.
- `Paths` and `Secrets` in the JSON output are emitted as empty arrays. The
  dump format for those isn't yet plumbed through; preserve any existing
  values manually for now.
