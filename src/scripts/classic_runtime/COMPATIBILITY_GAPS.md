# Classic compatibility gaps

This register tracks the work needed to run compiled Classic scenarios as
Remake campaigns. It is intentionally separate from opcode coverage: an opcode
may already have interpreter semantics while still waiting for a native Remake
bridge, and an unsupported opcode may map cleanly to an existing Remake system.

## Classification

Priority describes the effect on a scenario rather than the size of the work:

- **Required**: missing behavior can block progression, change authored state or
  outcomes, or prevent a scenario from being installed, played, or saved.
- **Recommended**: the current fallback preserves progression and the authored
  result, but presentation, pacing, or interaction differs from Classic.

Implementation status describes the Remake side of the gap:

- **Native, unwired**: Remake has a suitable system, but the Classic adapter does
  not yet call it.
- **Partial**: some variants work, while others still stop or use a fallback.
- **Absent**: Remake has no corresponding system yet.
- **Resource gap**: the runtime path exists, but converted data or Remake
  resources do not preserve what it needs.
- **Unknown**: the closest native behavior or the Classic contract still needs
  source and fixture research.

Evidence is recorded as **fixture-proven**, **source-backed**, **inferred**, or
**unknown**. A row moves to completed only after its completion criterion is
covered by a focused fixture or playtest.

## Required compatibility work

| Capability | Remake status | Evidence | Current boundary | Completion criterion |
| --- | --- | --- | --- | --- |
| Campaign discovery and launch | Absent | Fixture-proven | Compiled bundles can only be loaded by the standalone playtests. | A compiled campaign can be discovered, selected, and started through the normal campaign UI. |
| Save and load integration | Absent | Fixture-proven | `ClassicRuntimeState` snapshots are standalone and are not part of a Remake profile or save. | A normal save and load round trip preserves Classic position, quest flags, map mutations, encounter mutations, acquired maps, and action-point replacements. |
| Classic map bridge | Native, unwired | Source-backed | Teleports, dungeon transfers, view changes, darkness, land looks, random-encounter rectangles, and tile mutations update compatibility state but cannot load or redraw a compiled Classic map. | Typed map commands update a native map resource and play continues at the authored destination with its persistent mutations applied. |
| Battles and battle context | Native, unwired | Source-backed | Battle requests stop at the adapter. Combat-only actions and battle macros do not yet have the Classic battle context they require. | Authored battles can start, return victory or cowardice, execute combat action points and macros, and resume the suspended Classic action list. |
| Shops and restricted shops | Partial | Fixture-proven | Opcodes `6` and `73` load compiled stock, prices, availability, and the source-authored two-range transfer rule through native shop state. Stocked and accepted items still depend on complete item-name mappings. | Compiled shop records open through the native UI, apply their restrictions and prices, and resume the correct action list. |
| Temple and banking services | Partial | Fixture-proven | Opcodes `32` and `49` expose native temple and bank controls, including Classic temple prices and pooled payment. Automatic bank-to-temple pool transfer and the built-in banking warning remain native mismatches. | The native services preserve the authored costs, state changes, cancellation path, and continuation behavior. |
| Classic item identity | Resource gap | Fixture-proven | Shared ID mappings cover most stock, but authoritative bundles may not contain names for scenario-specific items. The adapter stops rather than dropping unresolved merchandise. | Every carried, awarded, required, and stocked item has an exported identity that resolves to a bundled or shared Remake resource. |
| Equipment and item-state actions | Partial | Source-backed | Fixed treasure works, but possession branches, item-status changes, and store-or-give equipment actions (`21`, `22`, `36`, and `38`) do not. | Each action uses Remake inventory state while preserving Classic carried, worn, stored, charge, and failure semantics. |
| Modal map input and presentation | Partial | Source-backed | Get Click, Show Picture, and Center Screen (`26`, `27`, and `28`) have no adapter path. | The native UI supplies the authored click result and picture/viewport changes, then resumes execution without losing the current action context. |
| Party, door, ally, and registration branches | Partial | Source-backed | Opcodes `40`, `85`, `87`, `89`, and `98` depend on state that is not yet exposed through the compatibility boundary. | Each branch or mutation reads and writes the matching live Remake state and has a shipped fixture covering both outcomes where applicable. |
| Classic field-spell data | Resource gap | Fixture-proven | Field-spell actions work only when a mapped spell exists; Classic save adjustment and force-affect fields are preserved but unapplied. | Converted spell metadata and active Remake resources cover shipped spell IDs, including save adjustment, force-affect, and low-ID class distinctions. |
| Complex-encounter special responses | Partial | Source-backed | Action, spoken, spell, item, lock, and trap responses work. Trap spells, scroll-as-spell items, and door-activation items remain unsupported. | Every response mode in the compiled complex-encounter schema selects, consumes, and persists its authored result correctly. |

## Recommended fidelity work

These items can remain behind a compatibility fallback while required work is
in progress. A scenario-specific audit may promote one to Required when its
presentation contains information needed for progression.

| Capability | Remake status | Evidence | Current fallback | Completion criterion |
| --- | --- | --- | --- | --- |
| Timed tumbler lock interaction | Absent | Source-backed | The rogue resolver applies Remake stats and Classic modifiers directly, preserving success and failure results. | A native interaction reproduces the timed tumbler rules without changing the resolved encounter result. |
| Standalone Classic player maps | Partial | Fixture-proven | Acquired maps use a compatible native minimap when available and otherwise display the compiled note. | Compiled player-map art, labels, and display behavior render independently of native minimap assets. |
| Classic picture, sound, and UI pacing | Partial | Inferred | Existing Remake controls and mapped sounds are used where possible. | Scenario presentation follows the authored ordering, dismissal, timing, and media choices where they affect fidelity rather than progression. |
| Compatibility diagnostics | Partial | Fixture-proven | Tests report unsupported commands and the converter supplies coverage data, but there is no player-facing campaign readiness report. | Import or launch reports unsupported records and resource gaps with enough context to diagnose a scenario without tracing runtime code. |

## Remaining City of Bywater opcode queue

The checked City of Bywater bundle currently has 64 active action slots without
interpreter behavior. This is a prioritization queue, not a list of absent
Remake features.

| Area | Opcodes | Active slots | Likely integration boundary |
| --- | --- | ---: | --- |
| Combat and battle macros | `100`, `121`, `123`-`127` | 40 | Native combat and Classic battle context |
| Items and equipment | `21`, `22`, `36`, `38` | 9 | Native party inventory |
| Modal UI and map input | `26`-`28` | 6 | HUD and compiled map bridge |
| Party, door, ally, and registration state | `40`, `85`, `87`, `89`, `98` | 7 | Runtime state adapters |
| Priest turning mode | `82`, `83` | 2 | Native combat state |

Update this file when a boundary is discovered, reclassified, or completed.
Keep shipped-scenario counts in the runtime README so this register remains
useful across more than one converted campaign.
