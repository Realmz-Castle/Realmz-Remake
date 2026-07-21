# Classic scenario runtime proof of concept

This directory contains a data-driven runtime proof of concept for normalized classic Realmz bundles produced by a separate Providence-based converter.

See [ARCHITECTURE.md](ARCHITECTURE.md) for the ownership boundary between the
compatibility runtime, Realmz Remake's native systems, and the optional dump
importer path. [BUNDLE_CONTRACT.md](BUNDLE_CONTRACT.md) defines the versioned
Providence-to-Remake runtime artifact. [INSTALLING_CLASSIC_CAMPAIGNS.md](INSTALLING_CLASSIC_CAMPAIGNS.md)
defines its self-contained layout below Remake's `Campaigns` directory and the
normal campaign-start lifecycle.

`ClassicCampaignBundle` validates and indexes the version 1 bundle. `ClassicExecutionAudit` inventories executable map, Data ED, Data ED2, Data ED3, battle-round, and immediate or queued death-macro actions without turning those counts into a playability percentage. `ClassicRuntimeState` owns classic quest flags, map position, view mode, priest-turning availability, per-map random-level settings, tile overrides, trigger-percentage overrides, acquired player maps, and persistent encounter, timed-encounter, and action-point replacements. `ClassicActionInterpreter` executes AP action lists until it reaches a command that must be handled by native Godot UI, map, inventory, audio, or combat code. `ClassicRuntime` is the low-level Godot `Node` facade. `ClassicRuntimeHost` drives that facade through an injected command adapter, and `ClassicGodotCommandAdapter` is the first Remake-facing adapter. That boundary can reuse existing Remake helpers wherever their behavior matches Classic while keeping compatibility-specific control flow inside the interpreter.

Implemented opcodes in this slice:

- `1` Text
- `2` Battle request
- `3` Choice and choice continuation
- `4` Simple encounter request and result-block continuation
- `5` Complex encounter request and result-block continuation
- `6` Load a Classic shop into Remake's native shop state
- `7` Copy Data ED3 actions into a map AP or encounter result
- `8` Execute another AP from the currently loaded map
- `9` Play sound
- `10` Give fixed treasure
- `11` Award party experience
- `12` Mutate a land or dungeon tile
- `13` Enable or disable one or more map triggers
- `14` and `-14` Pick characters or the inverse of a picked group
- `15` Damage or heal picked characters
- `16` Damage or heal the party
- `19` Display a random string from an inclusive message range
- `20` Teleport and destination recheck
- `21` Branch on whether the party carries an item
- `22` Remove, recharge, or replace matching party items
- `23` Alter a land or dungeon random-encounter rectangle
- `24` Keep codes / script completion
- `25` Remove and persist the active action point at its destination
- `26` Wait for a click or key acknowledgement
- `27` Display a scenario picture
- `28` Remove the scenario picture and redraw the current map view
- `29` Acquire a player map and optionally display it
- `30` Pick characters by an attribute or special-ability check
- `32` Make Classic temple services available at the authored prices
- `33` Take pooled and carried gold or gems, then follow the authored result branch
- `35` Eliminate and persist an option in the current simple encounter
- `36` Capture or restore party equipment and wealth
- `37` Move between land and dungeon maps with Classic heading/view state
- `38` Branch on an item-possession result
- `39` Extend actions through a Data ED3 AP
- `40` Branch on a live party condition
- `41` Eliminate and persist an option in any simple encounter
- `42` Branch on percent chance
- `44` Eliminate and persist one complex-encounter result
- `45` Teleport only
- `46` Branch on quest flag
- `47` Set or clear quest flag
- `49` Enable Remake's native banking controls
- `52` Pick characters by movement, position, item, chance, save, or current selection
- `54` Alter a persistent timed-encounter schedule
- `56` Battle request with victory, coward-branch, and coward-penalty continuation
- `57` Change a land level's visual set and darkness
- `58` Branch on Classic difficulty level
- `73` Load a Classic shop with two item-acceptance ranges
- `82` Disable priest turning
- `83` Enable priest turning
- `85` Branch to a random AP or encounter in an inclusive range
- `87` Branch on whether a compiled monster is a party ally
- `89` Add a compiled monster as a party ally
- `93` Enable compass updates
- `94` Disable compass updates
- `95` Set or randomize the current view direction
- `96` Require the 3D view
- `97` Allow the full map view
- `98` Continue past the open-source runtime's disabled registration gate
- `100` End the active battle as a victory with experience-only rewards
- `106` Set per-map darkness
- `111` Return from GOSUB
- `112` Pop one GOSUB frame without returning
- `121` Remove lower undead from the active battle
- `123` Rout named monsters on the acting creature's faction
- `124` Spawn compiled monsters in the active battle
- `125` Remove matching monsters from the active battle
- `126` Schedule and activate a battle-round macro
- `127` End a combat macro when its required monster is absent

The interpreter preserves Classic's unusual stack semantics: a negative action enables a sticky GOSUB mode, positive actions only clear that mode when the stack is empty, and branch opcodes may therefore push even when their own action code is positive. Returns are explicit through opcode `111`; merely reaching the end of an action point does not unwind the stack. Stack depth is capped at Classic's 20 frames with a safe runtime error instead of writing past the original fixed-size arrays. A focused War in the Sword Lands fixture exercises a shipped three-frame GOSUB chain and verifies the exact XAP return order.

Opcode `25` follows Classic's deferred door rewrite. It clears the GOSUB stack, captures the party position, and waits for the action point to finish. If the active door then moves the party, the current action list is copied into the destination map's matching door slot and its target is changed to the captured position. Data ED3 branches replace only that action list; the originating map door header remains active. These replacements live in runtime state and snapshots, leaving the compiled campaign bundle immutable. A focused Twin Sands of Time fixture exercises the shipped same-level relocation case.

Opcodes `26` through `28` use Remake's existing HUD presentation. Get Click displays Classic's acknowledgement prompt and waits for the normal text input. Show Picture prefers the catalog record's validated `runtimeMedia` image, retains the legacy `Splash Images` lookup for native campaigns, and leaves the image visible while later actions run. Redraw Screen hides that picture and queues the current map for redraw. Sound actions likewise prefer validated WAV, Ogg Vorbis, or MP3 runtime media before using Remake's shared sound mapping. Immutable `classic-resource-data` payloads are never passed to Godot's media loaders. The checked City of Bywater bundle identifies PICT 32128 but does not contain a decoded image file; the adapter reports that resource gap and continues, matching Classic's non-fatal behavior when a picture resource cannot be loaded.

Opcode `7` copies a Data ED3 action list into the selected map AP, simple result, or complex result while preserving the target record's other fields. The replacement is persistent and included in runtime snapshots, matching Classic's scenario-file mutation without changing the compiled bundle. Opcode `8` is deliberately transient: it borrows another AP's actions from the currently loaded map, retains the active AP's header and percentage, repeats Classic's percentage check, and then executes the copied list from its first slot. City of Bywater exercises both paths directly.

Opcode `11` sends its authored total through Remake's existing loot and experience flow, which splits the award among living party members that can receive experience and preserves the normal level-up UI. The City of Bywater child-grave sequence awards 1,500 experience and then continues into its persistent action-point replacement.

Opcodes `6` and `73` convert Classic's five fixed 200-slot stock categories into Remake's native shop categories and apply the authored inflation to purchase and resale prices. A positive shop ID makes the Shop control available until movement; a negative ID opens it immediately. Opcode `73` resolves the shop ID and two inclusive item ranges from Extra Code, then applies the resulting transfer rule to both purchases and sales. It preserves Classic's original two-range test: an item is rejected only when it misses both populated ranges, so a record with only one populated range remains unrestricted. Purchases spend pooled gold before character gold, remove depleted stock from the native UI, and retain the reduced quantity when the shop is reopened or loaded again. The active restriction is replaced or cleared by each load. Every stocked or accepted item must resolve to a loaded Remake resource. The current full City of Bywater bundle does not include names for its scenario-specific items, so affected shops remain an explicit resource boundary rather than silently omitting their merchandise.

Opcode `32` exposes Classic's nine temple services through Remake's native temple menu. The authored value is a percentage applied to Classic's base prices, including City of Bywater's standard 100-percent temple and its 300-percent hostile temple. Service payments combine pooled and selected-character gold and spend the pool first, matching Classic. Opcode `49` enables the native bank until movement and preserves the source sound and built-in warning IDs. When both services are available, banked wealth moves into the temple pool on entry and the remaining pool returns to the bank on exit, matching Classic.

Opcode `33` charges gold for a positive authored amount or gems for a negative
amount. It spends the matching pooled currency first, then removes carried units
round-robin in party order. An insufficient party total leaves every balance
unchanged before the interpreter applies the authored failure branch. City of
Bywater's seven uses all charge gold; focused fixtures also preserve the source's
gem form and its special failure continuation at the eighth result slot.

Opcodes `21` and `38` check all party inventories, including worn items, and resume the interpreter through their authored branch or fallthrough. Opcode `22` walks characters and inventory slots in party order, limits the number of matches, and can remove an item, add a signed charge value, or replace it from a fresh native template. Replacement resets identification and attempts to restore the prior worn state. Opcode `36` captures every inventory, worn state, and wealth type into adapter-local storage, then restores the original possessions and offers anything acquired in the interim through Remake's treasure UI. Repeated capture or restore actions are harmless when storage is already in the requested state. The active capture is included in the Classic save envelope, with native textures rebuilt from the saved item data on load. These commands stop explicitly when a scenario item ID has no shared mapping or exported item name.

Opcode `16` rolls its inclusive Extra Code range separately for each party member, multiplies each result by the authored signed value, and applies the resulting damage or healing through Remake's normal character health method. Its optional sound and message use the existing adapter paths. The standalone City of Bywater macro at `Data ED3:macro:142` provides a deterministic one-point party-damage proof.

Opcodes `14`, `-14`, `30`, and `15` share a transient selected-character set. Interactive picks use Remake's character panels; a negative pick ID allows dead characters, while opcode `-14` keeps the unchosen complement. Opcode `30` filters the current selection, whole party, or living party through the authored attribute or special-ability check. Opcode `15` then applies an independent signed health roll to each selected character. The City of Bywater shaft at `Data DD:7:54` exercises the native picker, while its temple sphere and pit records cover inverse and checked selections.

Opcode `52` replaces that selection from the whole party, living characters, or the previous selected set. Its selectors cover maximum movement, one-based party position, carried or worn items, percent chance, failed attribute or spell saves, the native HUD focus, and an exact party slot. The construction-set contract for checking the previous selection is preserved despite Classic's duplicate `track` clear making that source path ineffective. City of Bywater uses the opcode for two rockfalls: one selects movement below 10, while the other authors undefined attribute selector `5` alongside explicit “not fast enough” text. The adapter treats that one compatibility value as Dexterity rather than reproducing an uninitialized Classic comparison.

Opcodes `17` and `18` apply a packed Classic spell to the current selected set or whole party. The interpreter preserves the spell ID, power, save adjustment, force-affect flag, and target mode; the party variant also replaces the transient selection, matching Classic's `track` behavior. The adapter maps the ID through Remake's existing Divinity spell table and resolves every character separately. It adds the authored adjustment once per power level to the native Classic-save approximation, halves a damaging spell when the target saves, skips a saved condition-only effect, and bypasses the save when force-affect is set. Native field-spell resources declare their Classic save index and whether a save negates the effect, halves its damage, or is not available; readiness blocks mapped resources without that metadata.

Encounter result values select the corresponding eight-action block from `Data ED` or `Data ED2`. When a result block falls through naturally, the encounter repeats up to its authored `maxTimes`; explicit keep/remove actions still terminate it. On the last attempt, Classic's complex-encounter Result 4 timeout quirk selects Result 3 instead. Opcode `35` removes an option from the active simple encounter and reopens it without consuming an attempt. Opcode `41` applies the same persistent mutation to the encounter and option named by its Extra Code row, while opcode `44` replaces one complex result row with Keep Codes. These replacements are included in runtime snapshots. Battle outcome branches remain suspended until the host reports victory or cowardice. Persistent tile, trigger, encounter, player-map, and action-point mutations are included in runtime snapshots; the bundle records themselves remain immutable.

Percent branches use Classic's inclusive 1-100 roll. Their success action can redirect to Data ED3, keep or consume the source action point, or replace the current result code with a row from the most recently loaded simple or complex encounter. Those loaded encounter references are transient interpreter state, matching the original engine's separate global encounter buffers; redirecting a result row does not start or add an encounter loop.

Difficulty branches compare their threshold with Classic's saved five-step difficulty setting, represented internally from `-2` (easiest) through `2` (hardest), with `0` as the default. They use the same success outcomes as percent branches. City of Bywater does not author opcode `58`, so this handler does not change its compatibility coverage count.

Opcode `40` reads Classic party conditions through a small native-state mapping; City of Bywater's shipped use checks Waterworld against Remake's active WaterBreath effect before branching to complex encounter 8. Opcode `43` applies its signed condition value to the whole party, the current picked set, or every living character. City of Bywater's two uses permanently poison or disease picked characters, so those conditions map to Remake's existing saved traits. The rules preserve Classic's pre-target clearing of positive durations and accumulation of permanent values; other condition indexes remain an explicit native-mapping boundary. Opcode `85` selects an inclusive random AP, simple encounter, or complex encounter and preserves its optional sound and message before branching. The only City of Bywater slot is inside malformed `Data ED3:macro:197` data and remains a signed missing-row diagnostic rather than being guessed into valid scenario logic. Opcode `87` compares the monster name byte stored on each ally, while opcode `89` selects a Data MD monster record to create. The adapter therefore stores both identities on imported allies and in save files instead of deriving one from the other. Adding an ally requires an exact native bestiary identity; stable bestiary metadata or the existing numeric bestiary ID is preferred over a unique display-name fallback. City of Bywater's Vodalian resolves through the shared `Vodalian 71` entry; a scenario-local ally with no shared or campaign match remains a visible resource boundary. Opcode `98` is intentionally a no-op because the open-source Classic dispatcher disables its registration check.

Opcodes `82` and `83` persist Classic's global permission to turn undead and nether spawn, then present their fixed message and sound through the native HUD. New campaigns start with turning enabled, and older snapshots use the same default. Battle requests carry the current value into native combat, where eligible player characters receive a Turn Undead action only while that gate is enabled. Each character can attempt it once per battle. Materialized compiler monsters supply the original undead/nether-spawn flags, hit dice, magic resistance, and summon sentinel, allowing the native action to use Classic's exact threshold and destroy-versus-turn outcomes. Destroyed hostiles continue through normal death macros and battle rewards; turned targets switch to the player's faction and no longer count as defeated enemies. Classic's two half-action cost maps to one Remake action.

Opcode `48` starts its inclusive battle range through Remake's native combat lifecycle with only the currently picked living characters. Selective losses are allowed to return to exploration so the unselected party is not treated as a whole-party game over. Native battle cleanup presents the normal defeated-enemy rewards; surviving participants then receive the action's optional fixed treasure through the existing loot UI. If nobody survives, the fixed treasure is skipped, Classic's warning is shown, and the active encounter result resumes. The same adapter now services ordinary and branching Classic battle requests, preserving pre-battle sound and text, loot suppression, surprise, and outcome responses. When a hand-converted `Battle_<id>` resource is absent, the adapter materializes one from the compiler's 13x13 `Data BD` grid, resolving each monster through the native bestiary while retaining its Classic record ID, name ID, and signed side flip. Static distance and battle-macro fields enter native battle state, and request-specific priest-turning availability is attached when combat starts. Authored cowardice outcomes show Classic's two core warnings and mapped party-loss sound, then remove 2,000 experience per character level once before the suspended action list continues. Because Remake tracks experience remaining until the next level, the adapter applies that loss by increasing `exp_tnl`. Successful exploration movement is carried into the Classic trigger context, allowing a land cowardice outcome to reverse that movement and return the party to its previous tile. Classic does not perform this retreat in dungeons. A trigger started without movement context reports the skipped retreat rather than guessing a direction.

Compiler-produced monsters retain permanent Classic regeneration from condition 10 and spell-protection conditions 16 through 20 as compatibility-owned metadata. Regeneration restores the source amount at each normal combat-round boundary without reviving a defeated monster. Spell resolution uses the cast spell's learned or exact Classic level before ordinary magic resistance, matching Classic's rule that a screen stops spells at or below its level. Positive condition counters still require their own mutable lifecycle, and other nonzero starting conditions remain installation blockers.

Opcode `54` copies a compiled timed encounter into compatibility-owned state before changing its chance, increment, or next day. Negative chance, increment, and day-offset values leave the effective value unchanged; a nonzero reset flag starts the day calculation from Remake's current scenario day. Later mutations and timed-encounter lookups use the effective override, and snapshots preserve it without changing the compiled bundle. The Godot adapter derives the Classic day from the native clock when a host starts a trigger. Invoking the scheduled action point from Remake's time-passage loop remains part of the timed-encounter bridge.

Combat opcodes `121`, `123`, `125`, and `127` use the live native roster. Opcodes `121` and `123` select Data MD record IDs; opcodes `125` and `127` compare the separate monster name byte. Spawned combatants preserve both values, and name-byte checks do not fall back to a record ID when the values differ. Presence checks ignore defeated creatures. Monster destruction and lower-undead deanimation remove combatants through Remake's normal combat-state method, and hostile removals remain eligible for battle rewards. Rout filters its five compiled monster record IDs to the acting creature's faction and applies Remake's permanent fleeing trait, which switches each match to the native retreat AI. An explicit actor faction can be supplied for queued and on-death macros; otherwise the adapter uses the active native combatant. Once a routed combatant reaches the battlefield's outer inset, native cleanup removes it from the live roster and initiative without firing a death macro; Classic's ally sentinel still prevents the exit. Routed hostiles remain eligible for normal battle rewards, while routed allies do not. Opcode `100` ends its combat macro as a forced victory through Remake's normal battle cleanup, using an experience-only reward mode that omits defeated-enemy money and items. The adapter carries Classic's slot-8 sentinel through the native battle result so the suspended outer action point ends without running any remaining actions.

Opcode `124` resolves its compiled monster and fixed or inclusive-random count, then creates native combatants near the macro actor and adds them to the live roster and initiative order. It preserves Classic's battle-lifetime 100-monster slot ceiling, explicit faction override, actor-faction inheritance for direct and queued macros, and template faction for battle-round macros. Removed monsters do not reopen slots. Spawn sounds repeat once per successfully created monster. The battle bridge captures the dead actor's position and faction before removal, then supplies them when it drains the death-macro queue; other macro entry points fall back to the active combatant when no actor context is available. The native placement is functional, but does not reproduce Classic's conjuration animation.

Opcode `126` evaluates a battle macro against the number of completed rounds or an inclusive percent roll, selects its fixed or random Data ED3 target, and preserves repeating schedules while clearing one-shot schedules from the live battle data. The battle bridge invokes it at native round boundaries and supplies the current one-based combat round and live battle-macro value as execution context. The seven City of Bywater uses cover exact-round and repeating chance forms.

Dungeon moves change the runtime's map family as well as its level and coordinates. Entering a dungeon preserves Classic's heading, multiview, and fixed-view fields; leaving for land keeps that dungeon view state dormant. The transfer ends the active action point immediately, matching the original map loader. The Godot adapter resolves land and dungeon levels to the existing `map_<level>` and `mapd_<level>` resource convention and delegates visible transitions to `GameGlobal.change_map()`. `ClassicRuntimeHost.activate_start_location()` uses that same path for a compiled campaign start after native resources are loaded.

Native map areas can use a compiled trigger's stable ID as `scriptToLoad`. `game_state.check_map_script()` keeps native coordinate, secret, random-rectangle, and chance selection, then hands recognized IDs to the campaign's registered Classic host; ordinary native script names are unchanged. Opcode `20` performs Classic's immediate destination Action Point recheck after the visible transition. It replaces the source action point without pushing it, preserves any older GOSUB frames for an explicit destination return, and ends the chain when the destination percentage fails. Opcode `45` remains teleport-only and continues later source slots. Before entering a campaign map, the host reapplies saved darkness, landlook, random-rectangle, moved Action Point, trigger-percent, and tile mutations to the freshly loaded native resources. A restored campaign then forces the saved native map through the normal `change_map()` path so the rebuilt resources, mutations, and position enter together. The normal campaign launch creates and registers this host before entering the compiled start location.

Generated land maps turn source-backed `needBoat=1` cells into native boat placements over Classic water tile 60. The normal map resource loader retains those placements, and campaign start seeds Remake's existing boarding, sailing, docking, and save-state lifecycle only when that map has no restored boat state. Hand-authored native maps without generated boat metadata are unchanged.

Look Direction updates that persisted heading and requests a native view refresh before the action point continues. Authored directions `1` through `4` are used directly; other values select one of those four directions at random, matching Classic. The map bridge now redraws the native map for view and compass changes; Remake's current top-down renderer does not otherwise expose Classic's heading, multiview, or fixed-view presentation.

Compass and map-view actions preserve Classic's separate compass, multiview, and signed `viewtype` fields. Requiring 3D changes `viewtype` from `-1` to `1`; allowing the full map does not force the current view to change. Their command payloads preserve the source warning IDs and redraw intent. Darkland and land-look changes are keyed by map and use each compiled random-level record as their initial value. An authored no-change guard ends a Darkland action point before later slots, matching Classic. The map bridge applies darkness to both the loaded map and its native resource entry, but selecting a different landlook still requires an exported native tileset. Random-encounter changes address Classic's 20 fixed rectangle slots even when an unused zero-valued row is omitted from the normalized bundle; negative battle IDs leave the existing low or high bound unchanged. Compatible native random areas receive their updated bounds, per-10,000 chance, and battle range. Trigger percentages update matching native Action Point areas. Replayed Action Point replacements remove the obsolete native rectangle and project the effective coordinate, chance, and stable trigger ID. Tile mutations copy the matching stack from a cached reference cell in the compiled/native map pair; that immutable palette deliberately survives native resource reloads so replay stays independent of both earlier changes and replay count.

The complex-encounter adapter exposes the eight Classic action-text fields through Remake's existing HUD choice control and routes each selection to the record's shared action result. This covers the active non-rogue library, cave-in, and pool encounters in City of Bywater. Spoken responses reuse Remake's speech input and preserve Classic's case-insensitive, first-space-terminated prefix comparison; a mismatch selects Result 4. The City of Bywater archive at `Data DD:6:28` exercises its `waterford` response, grants player map 2, removes the successful response through opcode `44`, and reopens with its remaining choices. Positive map IDs use Classic's acquisition notice. Negative IDs prefer the record's decoded runtime image in a standalone player-map panel with its compiled name and note. Acquired Classic records are also browseable from Maps/Notes in stable ID order; note-only records remain visible when decoded art is unavailable. A compatible native minimap remains the fallback when a campaign has no acquired Classic records. Encounters with magic responses can open Remake's native spell picker, match the selected spell against the packed Classic IDs, consume its normal spell-point cost, and continue through the paired result block. Native Scroll entries use Classic's separate scroll response, so a party does not need a conscious spellcaster to supply a spell answer. Item responses use Remake's encounter inventory picker and match ordinary items by stable Classic metadata, shared mapping, or scenario item text against the five Classic response slots. Type-20 scenario items enter the spell-response path from that item picker. Both paths consume one finite charge, and disposable items leave inventory when empty. Type-23 door items consume a charge and leave the encounter for the compiled Data ED3 action point, whose mutations are included in compatibility snapshots. Unmatched spells and ordinary items use Classic's Result 4 fallback. Low spell IDs `1` through `6` use explicit Classic spell-class metadata rather than guessing from a shared display name; the readiness report identifies a class for which no native spell exists. Mixed rogue encounters keep action, spell, scroll, and item choices beside their `Data TD2` controls. The rogue resolver uses the selected character's Remake stat plus the Classic modifier, preserves Classic's 90-percent cap for interactive lock/trap actions, and routes success or failure into the four `Data ED2` result rows. Sprung trap spells use the same mapped native spell and save flow as Classic field-spell actions, with the compiled rogue-only or whole-party target mode. Consumed rogue actions persist in runtime snapshots while the compiled record remains immutable. The source-backed CoB lock at `Data DD:5:12` exercises Detect Trap, Force Lock, Pick Lock, and the Necklace of Keys response. The trapped chest at `Data DD:5:3` applies its shipped 4-12 damage to the selected rogue, clears the armed state, and leaves Pick Lock available before continuing through result 2.

Native item entries may declare `classicItemId` or `classicItemIds`; the loader preserves those fields on inventory instances so checks, mutations, treasure, shops, and encounter responses survive native renaming. Bestiary entries accept `classicMonsterId` or `classicMonsterIds`, either at the entry level or inside `data`, while the existing numeric `data.id` remains a stable record identity. Spell scripts expose `classic_spell_class` for the distinct low-ID complex-encounter response namespace. They may also declare `classic_spell_ids` when a shared display name covers Classic spell records with different mechanics; readiness and runtime checks then reject unsupported variants instead of relying on the name alone. Field-cast resources additionally use `classic_spell_save_index`, `classic_spell_save_mode`, `classic_save_bonus`, and `classic_save_adjust` to preserve the relevant Classic damage-type save and its negate, half-damage, or no-save behavior. `classic_spell_support_matrix.json` records the checked scenario corpus, source records, usage contexts, behavior classification, exact resource, and support status. New scenario audits extend that corpus and append spell usages without relaxing exact-ID readiness checks.

Materialized monster inventories resolve all six source item slots against the campaign item book before the shared Divinity mapping. A concrete positive `weapon` ID equips the matching native inventory object. Realmz permits that active weapon to remain separate from the six carried slots; Remake represents it as an adapter-only equipped item and excludes it from victory loot. Missing items, unsupported item definitions, unresolved or non-equippable weapons, and negative random-weapon table selectors remain readiness blockers; Classic's detected-magic sign marker is retained only as a fidelity diagnostic.

Against the checked City of Bywater compatibility baseline, these handlers cover 2,264 of 2,734 active action slots. The other 470 slots are skipped only because the bundle's source-backed dispatcher evidence identifies them as Realmz no-ops. Together, the proof of concept has defined interpreter behavior for all 2,734 active trigger action slots. This is a semantic coverage measurement, not a playability percentage: native command adapters, resource bridges, campaign integration, and some encounter-result paths remain. Opcodes `35`, `42`, and `44` also occur inside encounter results and those uses are not reflected in this trigger-slot count.

The execution audit deliberately reports result rows and combat macro roots
separately from that trigger baseline. Its initial full City of Bywater inventory
found 15 actions in four missing result handlers. Opcodes `33`, `43`, and `48`
cover all seven Take Gold uses, both Give Condition uses, and all four Selective
Combat uses. Opcode `54` covers the final two Alter Time Encounter uses, leaving
no executable unknowns in the full bundle or the checked vertical fixture. This
result-path inventory does not revise the 2,734-trigger claim.

The [compatibility gap register](COMPATIBILITY_GAPS.md) tracks required integration work and recommended fidelity improvements separately from opcode coverage.

The interpreter will still stop explicitly when a selected encounter result contains an unsupported opcode. The standalone player-map panel currently consumes producer-decoded images and browses acquired records from Maps/Notes; terrain-composed previews, scrolling-text maps, and embedded marker overlays remain explicit follow-up modes. Producer-generated decoded media, exact native identities for scenario allies, unmigrated spell resources, Classic combat-spawn animation, and the timed tumbler minigame remain explicit boundaries. The original runtime's hidden developer command words are intentionally not exposed through scenario speech input. This keeps the compatibility boundary visible while more handlers are added.

## Campaign readiness report

`ClassicCampaignReadiness` combines the executable-action inventory with bundle,
record, identity, and native-resource checks. Every result carries a source file,
record index, slot when applicable, severity, and one of two player-facing
classifications:

- `progression-blocker` means the missing data or behavior can stop execution or
  change an authored result.
- `fidelity-fallback` means play can continue with missing or reduced
  presentation.

Run the report against any compiled bundle. Supplying the matching native
campaign directory also checks shared and campaign bestiary, item, spell, and
sound resources:

```powershell
Godot_v4.6.2-stable_win64_console.exe --headless --path src --script res://scripts/classic_runtime/tests/report_classic_readiness.gd -- "C:\path\to\compiled-bundle" "F:\Realmz Remake\src\Campaigns\City of Bywater"
```

Add `--json` for the versioned machine-readable report. Exit status 0 means no
progression blockers were found, status 1 means the campaign is blocked, and
status 2 means the command was used incorrectly. The current City of Bywater
export identifies metadata-only PICT 32128 as a fidelity fallback and reports
the signed `Data ED3` record 197 / Data EDCD `-1700` reference plus field-spell
record 128 as progression blockers. Its Vodalian ally resolves through the
shared bestiary and therefore correctly produces no ally diagnostic.

## Godot guard-house playtest

The map bridge playtest loads Remake's existing City of Bywater map resources,
activates the checked Classic fixture at `land:0`, follows `Data DD:0:83` into
`dungeon:0`, follows `Data DDD:0:1` back outside, and changes the returned map
to Classic landlook 10. The normal run leaves the SnowDay version of the land
map open after displaying both native maps:

```powershell
Godot_v4.6.2-stable_win64.exe --path src res://scripts/classic_runtime/playtest/classic_map_bridge_playtest.tscn
```

Its automated smoke verifies the native map identities, map families, dungeon
heading and multiview state, renderable tile textures, distinct captured land
and dungeon output, and a visibly rendered SnowDay landlook change:

```powershell
Godot_v4.6.2-stable_win64_console.exe --resolution 1100x619 --path src res://scripts/classic_runtime/playtest/classic_map_bridge_playtest.tscn -- --smoke
```

The Providence producer smoke installs the checked conformance export without
modifying it, launches it through the normal campaign menu, and captures its
materialized land, dungeon, and returned-land views:

```powershell
Godot_v4.6.2-stable_win64_console.exe --resolution 1100x619 --path src res://scripts/classic_runtime/tests/providence_export_ui_smoke.tscn
```

The fixture does not yet author a map-transfer action, so this smoke performs
the two transfers through the same compatibility adapter used by Classic
Dungeon Move. It proves producer installation and native map lifecycle without
claiming fixture-level transition semantics. The real display driver is
required because the test waits for rendered frames and writes PNG evidence.

The native battle bridge playtest starts from the same real City of Bywater
map, applies a persistent SnowDay landlook, requests native `Battle_24`, and
runs a compiled combat macro that removes its two Zombies from the live roster.
Victory continues through Remake's loot and allies cleanup, resumes the outer
Classic action list, and returns the party to its original map tile. Its smoke
mode drives that full UI lifecycle deterministically:

```powershell
Godot_v4.6.2-stable_win64_console.exe --resolution 1100x619 --path src res://scripts/classic_runtime/playtest/classic_battle_bridge_playtest.tscn -- --smoke
```

The first in-engine vertical slice loads the CoB fixture, displays `Data DD:0:0` through Remake's existing `TextRect`, presents the four source-backed `Data ED` choices and Classic's Back Out control, feeds the selected result back to the interpreter, and runs that eight-action encounter result block.

Run the standalone scene from the repository root:

```powershell
Godot_v4.6.2-stable_win64.exe --path src res://scripts/classic_runtime/playtest/classic_guard_house_playtest.tscn
```

Pass a compiled campaign directory after `--` to use the full converter output instead of the checked-in fixture:

```powershell
Godot_v4.6.2-stable_win64.exe --path src res://scripts/classic_runtime/playtest/classic_guard_house_playtest.tscn -- "C:\path\to\realmz-remake-cob-poc-final"
```

This adapter intentionally handles text, yes/no prompts, character-panel selection, simple-encounter choices, complex action and spell responses, data-driven rogue encounters, selected and party health changes, party-condition and ally checks, live combat-monster presence, spawning, destruction, routing, lower-undead deanimation, battle-round macro activation, forced battle endings, cowardice experience penalties, priest-turning feedback and native attempts, Classic ally creation when an exact bestiary resource exists, Classic field-spell effects, Classic shops with resolved item resources, temple and banking availability, fixed treasure and standalone experience through Remake's loot UI, and mapped sounds. Other typed commands stop with an explicit adapter error until their map, encounter, or battle resource adapters exist.

Compiled campaigns installed under `src/Campaigns/<campaign>` now use the normal campaign panel. While the package is staged, the installer materializes missing outdoor native maps from complete normalized tile arrays and dungeon maps from signed Classic fields. Dungeon art is composed from Realmz's shared PICT 302 overhead sprites into a campaign-local native tileset; the raw field remains on each tile as metadata. Directional secret walls admit only their authored cardinal entry directions and persist their revealed visual state. A decoded 640 x 320 custom-landlook `runtimeMedia` image and its compiled 200-tile behavior table become a normal campaign-local tileset. Movement, sight, water, shore, timing, path, clear-land, combat-build, and numeric sound metadata remain attached to the generated tiles. Native filename-based map sounds retain priority; otherwise exploration sends the generated tile's Classic sound ID through the compatibility adapter, which uses decoded bundle audio or the existing Remake sound mapping. A negative land field with decoded 32 x 32 `runtimeMedia` becomes a campaign-local overlay over the current landlook base terrain. Its raw field and normalized `cicn` identity remain tile metadata, and `Data Solids` retains the source movement rule for the first negative-ID band. Stable Action Point IDs, trigger chances, and random rectangles use Remake's normal map files. Raw custom atlases and special land tiles without suitable decoded media are not flattened into approximate terrain or movement; they remain explicit installation blockers. The selector displays the manifest title, format version, compatibility profile, and readiness state. A structurally valid bundle remains visible but is blocked with an actionable diagnostic when semantic readiness fails or its native start-map files are incomplete. Starting a ready campaign through the normal party flow loads native resources, creates the compatibility session, and enters the compiled start location.

The UI smoke instances the real `Main.tscn`, discovers a self-contained compiled fixture, selects a party, presses the normal Start path, and verifies the native map and HUD. It is an automated integration harness rather than a separate compatibility playtest UI:

```powershell
Godot_v4.6.2-stable_win64_console.exe --headless --resolution 1100x619 --path src res://scripts/classic_runtime/tests/classic_campaign_ui_smoke.tscn
```

The generated-ally smoke derives carried, equipped, and weighted spell-slot
fields from the authoritative Providence fixture. It installs the result,
loads the generated monster and scenario item through normal campaign
resources, and round-trips mutable ally state, both Classic identities,
carried inventory, the active weapon, and executable native spells:

```powershell
Godot_v4.6.2-stable_win64_console.exe --headless --resolution 1100x619 --path src res://scripts/classic_runtime/tests/classic_generated_ally_smoke.tscn
```

Normal profile saves now include a versioned Classic envelope. It records the compiled campaign identity, `ClassicRuntimeState` snapshot, adapter-owned equipment capture, and a suspended interpreter continuation when the current command is safe to replay. The continuation contains plain data for the current action list and slot, GOSUB frames, encounter attempts, pending outcome state, and deferred action-point mutations. Load restores the native map and HUD before replaying the pending presentation, encounter, or battle request, so the existing host resumes the authored outer action list exactly once.

Idle exploration, text and click presentation, yes/no choices, initial encounter response controls, random-branch presentation, and priest-turning feedback are legal save boundaries. A live native battle is not: Remake does not serialize its combat roster or round state, so the save panel asks the player to finish that battle. Rogue encounters also become temporarily unsavable after a rogue roll mutates the TD2 record or applies trap damage. This prevents a reload from duplicating damage or item/spell costs. Version-one Classic envelopes load as idle continuations, older saves without an envelope retain their native map and coordinates with fresh compatibility defaults, and a save from a newer unsupported schema is left untouched and reported in the save panel. Saving and restoring duplicate runtime state without modifying the compiled campaign bundle.

For a non-interactive smoke of the real HUD flow, add `--smoke`. The scene verifies the displayed intro, four encounter choices, selected outcome text, and completed host state, then exits:

```powershell
Godot_v4.6.2-stable_win64_console.exe --resolution 1100x619 --path src res://scripts/classic_runtime/playtest/classic_guard_house_playtest.tscn -- --smoke
```

The lock playtest loads CoB's source-backed `Data ED2:4` and `Data TD2:4` records. It supplies a playtest-only rogue when no party is loaded:

```powershell
Godot_v4.6.2-stable_win64.exe --path src res://scripts/classic_runtime/playtest/classic_lock_playtest.tscn
```

Its HUD smoke verifies the complex prompt, three available rogue controls, two authored encounter actions, back-out, and host completion:

```powershell
Godot_v4.6.2-stable_win64_console.exe --resolution 1100x619 --path src res://scripts/classic_runtime/playtest/classic_lock_playtest.tscn -- --smoke
```

The trapped-chest playtest loads CoB's source-backed `Data ED2:3` and `Data TD2:1` records. Picking the armed lock springs its rogue-only damage trap; the smoke verifies the 4-12 HP loss, changed choices, persistent state, and host completion:

```powershell
Godot_v4.6.2-stable_win64.exe --path src res://scripts/classic_runtime/playtest/classic_trap_playtest.tscn
Godot_v4.6.2-stable_win64_console.exe --resolution 1100x619 --path src res://scripts/classic_runtime/playtest/classic_trap_playtest.tscn -- --smoke
```

The experience playtest starts at the source-backed 1,500-point award in CoB's child-grave sequence. Its smoke verifies the empty loot panel, party experience change, and following action-point replacement:

```powershell
Godot_v4.6.2-stable_win64.exe --path src res://scripts/classic_runtime/playtest/classic_experience_playtest.tscn
Godot_v4.6.2-stable_win64_console.exe --resolution 1100x619 --path src res://scripts/classic_runtime/playtest/classic_experience_playtest.tscn -- --smoke
```

The services playtest runs CoB's compiled bank and temple actions through the native HUD. Its smoke verifies Classic's built-in banking warning and continuation pause, banking availability, standard and hostile temple prices, and the bank-to-temple transfer lifecycle:

```powershell
Godot_v4.6.2-stable_win64.exe --path src res://scripts/classic_runtime/playtest/classic_services_playtest.tscn
Godot_v4.6.2-stable_win64_console.exe --resolution 1100x619 --path src res://scripts/classic_runtime/playtest/classic_services_playtest.tscn -- --smoke
```

The shop playtest installs a focused compiled restricted-shop record over the CoB fixture. Its smoke verifies mapped stock, inflation, both accepted-item ranges, pooled-first payment, cancellation continuation, and persistent depleted stock:

```powershell
Godot_v4.6.2-stable_win64.exe --path src res://scripts/classic_runtime/playtest/classic_shop_playtest.tscn
Godot_v4.6.2-stable_win64_console.exe --resolution 1100x619 --path src res://scripts/classic_runtime/playtest/classic_shop_playtest.tscn -- --smoke
```

The equipment playtest captures worn and carried items plus party wealth, serializes that active capture through the Classic session envelope, reloads a fresh session, and restores the items through Remake's resource loader. Its smoke verifies worn state, charges, wealth, interim loot, native loot presentation, and continuation completion:

```powershell
Godot_v4.6.2-stable_win64.exe --path src res://scripts/classic_runtime/playtest/classic_equipment_playtest.tscn
Godot_v4.6.2-stable_win64_console.exe --resolution 1100x619 --path src res://scripts/classic_runtime/playtest/classic_equipment_playtest.tscn -- --smoke
```

The party-health playtest runs CoB's standalone fixed-damage macro and verifies the character HP change and completed host state:

```powershell
Godot_v4.6.2-stable_win64.exe --path src res://scripts/classic_runtime/playtest/classic_party_health_playtest.tscn
Godot_v4.6.2-stable_win64_console.exe --resolution 1100x619 --path src res://scripts/classic_runtime/playtest/classic_party_health_playtest.tscn -- --smoke
```

The party-spell playtest runs CoB's source-backed psychic barrier, supplies two playtest targets and a test-only Power Drain resource, and verifies Remake's spell animation, per-character effect, transient party selection, and completed host state:

```powershell
Godot_v4.6.2-stable_win64.exe --path src res://scripts/classic_runtime/playtest/classic_party_spell_playtest.tscn
Godot_v4.6.2-stable_win64_console.exe --resolution 1100x619 --path src res://scripts/classic_runtime/playtest/classic_party_spell_playtest.tscn -- --smoke
```

The character-pick playtest opens Remake's party-panel picker for CoB's hollow-column volunteer and verifies that the chosen character becomes the transient Classic selection:

```powershell
Godot_v4.6.2-stable_win64.exe --path src res://scripts/classic_runtime/playtest/classic_character_pick_playtest.tscn
Godot_v4.6.2-stable_win64_console.exe --resolution 1100x619 --path src res://scripts/classic_runtime/playtest/classic_character_pick_playtest.tscn -- --smoke
```

The miscellaneous-selection playtest runs CoB's movement-based ceiling rockfall with a slow playtest rogue and verifies the transient selection, 1-3 HP loss, and completed host state:

```powershell
Godot_v4.6.2-stable_win64.exe --path src res://scripts/classic_runtime/playtest/classic_misc_selection_playtest.tscn
Godot_v4.6.2-stable_win64_console.exe --resolution 1100x619 --path src res://scripts/classic_runtime/playtest/classic_misc_selection_playtest.tscn -- --smoke
```

The tavern-option playtest selects the barmaid response in CoB's source-backed `Data ED:3`. Opcode `35` removes that response, reopens the encounter without using an attempt, and leaves the party able to back out:

```powershell
Godot_v4.6.2-stable_win64.exe --path src res://scripts/classic_runtime/playtest/classic_simple_option_playtest.tscn
Godot_v4.6.2-stable_win64_console.exe --resolution 1100x619 --path src res://scripts/classic_runtime/playtest/classic_simple_option_playtest.tscn -- --smoke
```

The cave-in playtest exercises a non-rogue complex encounter from its three authored action labels through the selected `Data ED2` result block:

```powershell
Godot_v4.6.2-stable_win64.exe --path src res://scripts/classic_runtime/playtest/classic_complex_action_playtest.tscn
Godot_v4.6.2-stable_win64_console.exe --resolution 1100x619 --path src res://scripts/classic_runtime/playtest/classic_complex_action_playtest.tscn -- --smoke
```

The spell variant supplies a playtest caster with Dig Hole, selects it through Remake's native spell menu, and verifies the packed `1201` response, spell-point cost, and Result 1 continuation:

```powershell
Godot_v4.6.2-stable_win64.exe --path src res://scripts/classic_runtime/playtest/classic_complex_spell_playtest.tscn
Godot_v4.6.2-stable_win64_console.exe --resolution 1100x619 --path src res://scripts/classic_runtime/playtest/classic_complex_spell_playtest.tscn -- --smoke
```

The item variant gives the playtest rogue a Necklace of Keys, selects it through Remake's encounter inventory picker, and verifies the source-backed Result 1 response without consuming the key:

```powershell
Godot_v4.6.2-stable_win64.exe --path src res://scripts/classic_runtime/playtest/classic_complex_item_playtest.tscn
Godot_v4.6.2-stable_win64_console.exe --resolution 1100x619 --path src res://scripts/classic_runtime/playtest/classic_complex_item_playtest.tscn -- --smoke
```

The spoken-word variant opens Remake's speech input for the City of Bywater archives and verifies that `WATERFORD` selects the source-backed Result 1 messages, grants its map, removes that result, and reopens the encounter:

```powershell
Godot_v4.6.2-stable_win64.exe --path src res://scripts/classic_runtime/playtest/classic_complex_word_playtest.tscn
Godot_v4.6.2-stable_win64_console.exe --resolution 1100x619 --path src res://scripts/classic_runtime/playtest/classic_complex_word_playtest.tscn -- --smoke
```

The HUD smoke intentionally uses the normal display driver because the project's shutdown handler persists the active window size to `src/override.cfg`; a headless HUD run would save `0x0` and dirty the worktree.

Run the headless proof from the repository root:

```powershell
Godot_v4.6.2-stable_win64_console.exe --headless --resolution 1100x619 --path src --script res://scripts/classic_runtime/tests/run_classic_runtime_tests.gd
```

Pass the path to a full compiled bundle after `--` to run the same loader against all CoB records:

```powershell
Godot_v4.6.2-stable_win64_console.exe --headless --resolution 1100x619 --path src --script res://scripts/classic_runtime/tests/run_classic_runtime_tests.gd -- "C:\path\to\realmz-remake-cob-poc-final"
```
