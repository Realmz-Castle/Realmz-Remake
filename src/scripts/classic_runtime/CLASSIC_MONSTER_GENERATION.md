# Classic monster generation

Remake rolls a generated Classic monster when the native `Creature` instance is
created. The materialized bestiary entry remains a static catalog projection and
retains the complete `classicRecord`; it is not the runtime combat-stat source.

The formulas are traced to Realmz source commit
[`0c19b9159ae1d982147f4dc5a3fd465b65a4e244`](https://github.com/Realmz-Castle/realmz/tree/0c19b9159ae1d982147f4dc5a3fd465b65a4e244/src/realmz_orig):

| Lifecycle | Source | Runtime rule |
| --- | --- | --- |
| Battle-grid creation | `combatsetup.c:379-417` | Roll each hit die as d8; vary armor and agility by -1 through 1; vary nonzero spell points by inclusive +/-10%; apply the 10-point save, 3-point armor, 1-point agility, and 40% HP/SP difficulty steps; then add scenario age to stamina. |
| Opcode 124 spawn | `buildmonster.c:5-62`, called by `newland.c:426-474` | Use the same base rolls with 7-point saves, 2-point armor, and 33% HP/SP difficulty steps. Preserve the source's two-stage magic-resistance adjustment. |
| Summon | `spelllist.c:245-325` | Use the opcode-124 stat rules with the single bounded magic-resistance adjustment. |
| Transformation | `spelllist.c:163-242` | Apply both source agility adjustments, no spell-point variance roll, the 33% difficulty scale, and the source's unconditional magic-resistance step. |
| Persistent ally | `newland.c:1050-1100` | Roll stamina once, omit armor/agility/SP variance and HP/SP age scaling, and retain the difficulty-adjusted combat defenses in the saved ally. |
| Defeat reward | `booty.c:211-216,369-371`, `partyselect.c:167` | Roll each defeated enemy's gold, gems, and jewelry inclusively from zero through its authored maximum, pool the results, then apply the 33% difficulty step with source integer truncation. |
| Attack sound | `showresults.c:153-178` | Unarmed attacks use the active row's sound byte with 631 remapped to 632. Sharp weapons roll sound 635 through 637; other weapons choose 632 below the source threshold and 639 otherwise. |

`share-movecost-dialog.c:43-50` defines `Rand(range)` as one through `range`
inclusive. `misc.c:587-590` defines the inclusive `randrange(low, high)` used by
the stat adjustments. C casts the scaled floating-point HP and SP values to
`short`; the compatibility layer therefore truncates rather than rounds.

Generated maximum stamina feeds the experience calculation from
`booty.c:218-345`. Runtime difficulty is clamped to Classic's -2 through 2
range, and scenario age is the elapsed scenario-day count. Deterministic tests
inject roll results, but ordinary runtime creation always uses fresh random
rolls. Money remains stored as its authored maximum and is rolled only after a
generated enemy is defeated. Saved allies restore the rolled stats and adjusted
defenses rather than rolling their persistent identity again.

Unarmed sound bytes materialize to the existing native SFX catalog. Records
whose sound ID is not present in that catalog retain `attackSounds` as an
explicit fidelity fallback; armed attacks only select source-backed native
sounds.
