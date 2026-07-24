# Classic condition compatibility

This matrix is the maintained ownership boundary for the 40 signed character
condition slots and 10 signed party condition slots. The index and source names
come from `CharCondition` and `PartyCondition` in the Classic `structs.h`.

For both arrays, zero means absent, a positive value is temporary, and a
negative value is permanent. `reduce.c` decrements only positive values. Combat
calls that reducer once per round (`getup.c`); field time calls it once per
crossed game-hour boundary (`textbox-time.c`). Remake keeps those signed values
authoritative, projects their mechanics through traits or narrow runtime
helpers, snapshots live values on save, and restores the same signed state.

Give Condition (opcode 43) clears an existing positive value from every party
member before applying the authored signed change to the chosen party,
selected, or living targets. Race creation, caste grants, spells, monster
attacks, and imported equipment all converge on the same condition rules.

## Character conditions

| Index | Classic source name | Source-owned effect | Remake owner |
| ---: | --- | --- | --- |
| 0 | Runs Away | combat routing and flee movement | `t/p_classic_fleeing.gd` |
| 1 | Helpless | incapacitation, guaranteed physical hit, spell block | `t/p_classic_helpless.gd` |
| 2 | Tangled | attack, defense, and movement penalties | `t/p_classic_tangled.gd` |
| 3 | Cursed | physical attack and defense penalties | `t_classic_cursed.gd`, `p_cursed.gd` |
| 4 | Magic Aura | physical attack and defense bonus | `t/p_aura.gd` |
| 5 | Stupid | spellcasting block | `t/p_dumb.gd` |
| 6 | Slow | attack, defense, initiative, and movement penalties | `t_classic_slow.gd`, `p_slow.gd` |
| 7 | Shield from Hits | melee defense bonus | `t/p_pro_hits.gd` |
| 8 | Shield from Projectiles | projectile defense and spell-projectile boundary | `t/p_pro_proj.gd` |
| 9 | Poisoned | signed periodic damage and decay | `t_poison.gd`, `p_poison.gd`, `classic_poison.gd` |
| 10 | Regenerating | signed periodic healing and decay | `t_classic_regeneration.gd`, `classic_regeneration.gd` |
| 11 | Fire Protection | fire damage halving | `t_classic_prot_fire.gd`, `p_prot_fire.gd` |
| 12 | Cold Protection | cold damage halving | `t_classic_prot_ice.gd`, `p_prot_ice.gd` |
| 13 | Electrical Protection | electrical damage halving | `t_classic_prot_elect.gd`, `p_prot_elect.gd` |
| 14 | Chemical Protection | chemical damage halving | `t_classic_prot_chem.gd`, `p_prot_chem.gd` |
| 15 | Mental Protection | mental damage halving | `t_classic_prot_mental.gd`, `p_prot_mental.gd` |
| 16 | 1st-level Spell Protection | blocks spells through level 1 | `t_classic_spell_screen.gd`, `classic_spell_screen.gd` |
| 17 | 2nd-level Spell Protection | blocks spells through level 2 | `t_classic_spell_screen.gd`, `classic_spell_screen.gd` |
| 18 | 3rd-level Spell Protection | blocks spells through level 3 | `t_classic_spell_screen.gd`, `classic_spell_screen.gd` |
| 19 | 4th-level Spell Protection | blocks spells through level 4 | `t_classic_spell_screen.gd`, `classic_spell_screen.gd` |
| 20 | 5th-level Spell Protection | blocks spells through level 5 | `t_classic_spell_screen.gd`, `classic_spell_screen.gd` |
| 21 | Strong | physical accuracy and damage bonus | `t/p_classic_strong.gd` |
| 22 | Protection from Evil | attack and defense against hostile foe types | `t/p_classic_protection_from_foe.gd` |
| 23 | Speedy | initiative and movement bonus | `t/p_classic_speedy.gd` |
| 24 | Invisible | targeting and physical defense | `t/p_classic_invisible.gd` |
| 25 | Animated | animated life state, targeting, healing, and experience filters | `t/p_classic_animated.gd`, `classic_animation.gd` |
| 26 | Turned to Stone | petrified life state and action/spell block | `t/p_classic_petrified.gd` |
| 27 | Blind | physical attack and defense penalties | `t/p_classic_blind.gd` |
| 28 | Diseased | signed periodic damage and decay | `t_classic_disease.gd`, `classic_disease.gd` |
| 29 | Confused | random action, attack/defense penalties, and spell block | `t/p_classic_confused.gd`, `classic_confusion.gd` |
| 30 | Reflecting Spells | spell reflection | `t/p_reflect_spells.gd`, `classic_reflection.gd` |
| 31 | Reflecting Attacks | melee reflection | `t/p_reflect_melee.gd`, `classic_reflection.gd` |
| 32 | Attack Bonus | signed physical damage adjustment | `t_classic_attack_bonus.gd`, `p_classic_attack_bonus.gd` |
| 33 | Absorbing Energy | periodic spell-point gain | `t_classic_power_gather.gd`, `p_classic_power_gather.gd` |
| 34 | Energy Drain | periodic spell-point loss | `t_classic_power_wither.gd`, `p_classic_power_wither.gd` |
| 35 | Absorbing Energy from Attacks | absorbs incoming spell energy | `t/p_sp_absorb.gd` |
| 36 | Hindered Attacks | signed physical accuracy penalty | `t_hindered_atk.gd`, `p_classic_hindered_atk.gd` |
| 37 | Hindered Defense | signed physical defense penalty | `t_hindered_def.gd`, `p_classic_hindered_def.gd` |
| 38 | Defense Bonus | signed physical defense bonus | `t_classic_defense_bonus.gd`, `p_classic_defense_bonus.gd` |
| 39 | Silenced | spellcasting block | `t/p_silenced.gd` |

The principal source consumers are `attack.c` for physical accuracy, defense,
damage, protection, invisibility, and reflection; `modify-cancast.c` and
`spelllist.c` for spell gates; and `reduce.c`/`getup.c` for periodic condition
effects. Remake's executable mapping is
`classic_character_condition_rules.gd::CONDITION_TRAITS` plus the dedicated
disease, regeneration, and spell-screen handlers.

## Party conditions

| Index | Classic source name | Source-owned effect | Remake owner |
| ---: | --- | --- | --- |
| 0 | Torch Lit | light strength, visibility, and hourly decay | `classic_light.gd`, `GameGlobal.classic_light_condition` |
| 1 | Waterworld | water breathing | exact slot plus native `WaterBreath` projection |
| 2 | Dragon Hide | five-point physical weapon reduction | `classic_party_condition.gd`, native `Shielded` projection |
| 3 | Discover Secret | guaranteed secret detection | exact slot plus native `Awareness` projection |
| 4 | Wizard Eye | sight through blocking tiles | exact slot plus native `Scrying` projection |
| 5 | Search | persistent player search toggle and guaranteed secret detection | exact slot and `GameGlobal.set_classic_search_enabled()` |
| 6 | Free Fall / Levitate | falling protection | exact slot plus native `FeatherFall` projection |
| 7 | Sentry | suppresses random battles | exact slot plus native `Sentry` projection |
| 8 | Charm Resistance | party charm resistance bonus | exact slot plus native `CharmProt` projection |
| 9 | Unused | explicitly reserved, no gameplay effect | exact saved no-op slot |

`resolvespell.c` replaces a party condition only when the new positive duration
is larger. Imported negative values remain permanent through reduction and
save/load. Search is toggled between `-1` and `0` in `buttonchoice.c`, and
`checkforsecret.c` averages the party's Detect Secret ability for an ordinary
three-by-three land or dungeon scan. Search or Discover Secret raises that pass
to a guaranteed find, and each active Search pass costs four ticks. Remake
applies those rules directly to Providence's preserved Classic tile fields and
persists each reveal into both the runtime state and native map projection.
Party slots are persisted by the Classic save path and by
`GameGlobal.classic_party_conditions`.

## Verification

`run_classic_runtime_tests.gd` verifies the complete 40+10 index inventory,
signed application, permanent/temporary state, target modes, condition-owned
combat and spell effects, hour/round decay, and readiness blockers.
`classic_character_condition_smoke.tscn` verifies Classic-only timed traits,
signed disease, live round/hour decay, and save snapshots in the running
project.
`classic_party_condition_smoke.tscn` exercises live party state, native
projections, weapon protection, and save restoration.
`classic_generated_ally_smoke.tscn` exercises generated character condition
traits in the running project.
