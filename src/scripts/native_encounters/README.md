# Native special encounters

Native campaigns may define ordinary special encounters in
`Special Encounters/encounters.json`. `CampaignResources` loads that document
alongside the older per-encounter GDScript files and exposes both through the
existing Special Encounter HUD.

The document uses `schemaVersion: 1` and an `encounters` dictionary. Each
encounter contains response rules and named results:

```json
{
  "schemaVersion": 1,
  "encounters": {
    "sealed_door": {
      "responses": {
        "action": [
          {
            "id": "inspect",
            "label": "Inspect the door.",
            "result": "description"
          }
        ],
        "spokenWord": [
          {
            "values": ["waterford"],
            "result": "open"
          }
        ]
      },
      "fallbackResult": "nothing",
      "results": {
        "description": {
          "effects": [
            {"type": "message", "text": "The lock bears an old crest."}
          ],
          "close": false
        },
        "open": {
          "nextEncounter": "passage",
          "close": false
        },
        "nothing": {
          "effects": [
            {"type": "message", "text": "Nothing happens."}
          ]
        }
      }
    }
  }
}
```

## Responses and routing

The runtime accepts `action`, `spokenWord`, `spell`, `item`, and `rogueSkill`
responses. The HUD continues to own selection and cancellation. Action rules
provide an `id` and `label`; word, spell, and item rules match a `value` or
`values` array without regard to case. Rogue-skill rules provide `skill`,
`difficulty`, `successResult`, and `failureResult`.

Results can route through `nextResult`, choose a result with `branches` and an
`otherwise` fallback, or enter another encounter with `nextEncounter`.
Conditions may read encounter state, campaign flags supplied by the adapter,
prior result counts, or the current response context. `all`, `any`, and `not`
compose conditions.

The built-in effects are:

- `message`, `setFlag`, `setState`, `giveMinimap`, and `teleport`
- `mapMutation`, exposed to native map scripts as
  `<map>.mutation.<id>` in `GameGlobal.stuff_done`
- `actionPointMutation`, which updates the native action-point `chance` or
  `replacement` flags already read by `GameGlobal`
- `extension`, which calls a method on the campaign global script and appends
  the response context to its configured arguments

Result counts, encounter values, map mutations, and action-point mutations are
stored in `GameGlobal.native_encounter_state` and included in normal campaign
saves. The corresponding native flags are saved through `stuff_done`.

## Ownership boundary

This runtime is the authoring contract for Remake-native campaigns. It provides
reusable UI routing and state without requiring a GDScript file for every
encounter. Per-encounter GDScript remains available for campaign behavior that
does not fit the common effects.

Classic campaign bundles continue to run through the Classic action
interpreter. That interpreter owns original opcode behavior, stack and GOSUB
rules, mutation quirks, resource identities, and other compatibility details.
A compatibility adapter may use the native HUD or services, but native
encounter data must not be treated as a replacement for Classic control flow.

Converted native campaign scripts can return a `complexEncounter` branch
request when a branch selects an entire encounter. The map-script loop opens
that encounter through the same HUD and ends the source script chain when the
encounter closes. An active GDScript encounter can also transition to another
loaded encounter without closing the HUD. These adapters cover Remake's native
campaign scripts; Classic stack behavior remains in the compatibility
interpreter.

Legacy GDScript encounters can also branch to the start of another result row
through the active encounter control. This covers the shared top-of-result path
used by converted Codes 3, 38, 42, and 46. A nonzero instruction offset remains
an explicit conversion boundary because one-off `result1()` through `result4()`
methods do not expose Classic's individual instruction slots. The Classic
interpreter continues to support those offsets directly.

Converted Code 7 mutations store their replacement in normal campaign save
state. Map Action Points use a stable map-and-record key, simple encounters
replace their saved result entry, and complex encounters resolve their result
through the active encounter control. The native path redirects to the converted
Extra Action Point method; the Classic interpreter remains responsible for exact
eight-slot copying and stack behavior.

The City of Bywater `native_nested_proof` fixture exercises all response modes,
conditional and nested routing, and serialized mutation state. Run its focused
test from the Godot project directory with:

```text
godot --headless --path . --script res://scripts/native_encounters/tests/run_native_encounter_tests.gd
```

The live playtest uses `Main.tscn` and the normal HUD. Run it without extra
arguments for manual interaction, or add `-- --smoke` for the automated
back-out, nested-route, save-state, reopen, and stop checks:

```text
godot --path . res://scripts/native_encounters/playtest/native_encounter_playtest.tscn
godot --headless --path . res://scripts/native_encounters/playtest/native_encounter_playtest.tscn -- --smoke
```
