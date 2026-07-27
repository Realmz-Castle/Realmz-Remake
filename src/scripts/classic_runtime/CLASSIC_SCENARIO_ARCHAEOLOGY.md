# Classic scenario archaeology

These are durable, human-readable notes captured while tracing scenario routes.
They are not a walkthrough format or a runtime contract. Their purpose is to
retain quest, story, hint, and optional-content findings that would otherwise
be lost after an acceptance slice is complete.

Each claim should stay within its evidence:

- **Runtime-proven** means the installed Classic package exercised the behavior
  through Remake's normal campaign UI and live Classic host.
- **Source-proven** means the imported records and their references establish
  the behavior, but the dedicated route has not necessarily exercised it.
- Flavor text or an interesting room is not a completion requirement unless a
  quest flag, reachable branch, or explicit completion message connects it to
  the main route.

## Assault on Giant Mountain

### Main completion chain

- **Runtime-proven:** Baron McReese's headquarters is on land map 0 at
  `(83, 8)`. The first briefing says the giants have three main fortresses and
  several strongholds, and asks small mercenary bands to infiltrate them.
- **Runtime-proven:** That briefing silently replaces the adjacent action point
  at `(84, 8)` with a four-quest report dispatcher. The report point checks
  quest flags 10, 11, 12, and 17; flag 17 is the Lequtus victory.
- **Runtime-proven:** Lequtus's fortress is on land map 3 at `(88, 79)`.
  Battle 274 contains Lequtus and 23 other giants: seven ice giants, five hill
  giants, and eleven fire giants.
- **Runtime-proven:** Victory sets quest flag 17, replaces the four fortress
  tiles at `(88..89, 78..79)` with tile 155, and disables random-encounter
  rectangle 17 on land map 3.
- **Runtime-proven:** Returning to the report point at `(84, 8)` sends the party
  to the king. The party is knighted as the "Upholders of the Code", receives
  three separate 32,000-experience awards, Treasure 77, and the explicit main
  goal completion message.

### Story and hint facts

- Lequtus describes himself as the creator and master of giant-kind. He says he
  has spent years dormant and gathering strength, and intends to remove humans
  from the Realmz.
- The giants accompanying Lequtus chant in a language the party cannot
  identify.
- On defeat, Lequtus claims his essence will survive and that centuries of rest
  will let him return. His body and fortress dissipate, leaving only his
  clothes.
- The epilogue says bards will preserve the story as "The Assault On Giant
  Mountain" and explicitly invites the player to continue exploring after the
  main goal.

### Reward discrepancy worth preserving

- Treasure 77 contains three source item IDs: Flail of Doom +5 (68), Ring of
  Defense +7 (625), and Hellsbane +11 (467).
- The king's narration mentions only a flail and an engraved ring. The third
  source item is runtime-proven, but the text does not identify it.

### Evidence

- Route:
  `playtest/routes/assault_on_giant_mountain.json`
- Installed report:
  `reports/classic_assault_on_giant_mountain_route_acceptance.json`
- Imported source records: `Data DD:0:98`, `Data ED3:macro:118`,
  `Data DD:3:31`, `Data ED3:macro:135`, `Data ED3:macro:163`,
  `Data DD:0:99`, and `Data ED3:macro:102`, `136`, and `137`.

## Castle in the Clouds

### Main completion chain

- **Runtime-proven:** The final hostile encounter begins on land map 1 at
  `(6, 8)`. The party initially asks the elegantly dressed enchanter whether he
  is Zukar; he is Nufack, and surprise Battle 223 follows.
- **Runtime-proven:** Battle 223 contains two Evil Mages, ten Evil Warriors,
  eight Evil Paladins, and nineteen Evil Rangers.
- **Runtime-proven:** The certified safe castle-collapse route answers no to the
  first prompt, then yes to the next two prompts. This proves one successful
  branch, not that it is the only safe answer sequence.
- **Runtime-proven:** Zukar's epilogue is on land map 1 at `(5, 87)`. It gives
  Treasure 71, sets quest flag 16, changes six nearby castle tiles to `-16`,
  and can teleport the party back to McBane City on land map 0 at `(60, 68)`.

### Story and hint facts

- Nufack is a decoy or subordinate encountered during the search for Zukar; he
  is not Zukar.
- Zukar's note says the finder must seek the White Dragon. The epilogue names
  "The Search for the White Dragon" as the intended next scenario.
- Treasure 71 contains Ring of Healing (632), Gauntlets +24 (235), and Cloak of
  Light +10 (244).
- The final messages thank the player and include the author's dedication to
  his brother.

### Evidence

- Route: `playtest/routes/castle_in_the_clouds.json`
- Installed report:
  `reports/classic_castle_in_the_clouds_route_acceptance.json`
- Imported source records: `Data DD:1:31`, `Data DD:1:33`, and
  `Data ED3:macro:223`.

## Destroy the Necronomicon

### Main completion chain

- **Runtime-proven:** Westmore's opening is on land map 0 at `(35, 69)`.
  Messages 978 and 979 explain that an anonymous inhabitant summoned the party
  after months of travel.
- **Runtime-proven:** The Stygian Troll portal is on land map 0 at `(36, 20)`.
  Battle 47 contains 24 Stygian Trolls. Victory reveals their pyramid as a
  transport from the Abyss and awards 6,000 experience plus the Deadstone of
  Jealousy (item 886).
- **Runtime-proven:** Lord Hecubus is reached through `Data DD:4:11` at
  `(0, 43)`. Choosing to explain the mission leads through Battles 145 and 146,
  grants player map 9 and Treasure 43, and enables the Necronomicon cache.
- **Runtime-proven:** The map leads to `Data DD:4:13` at `(33, 73)`. Treasure
  44 contains the Book of Screams (899) and Necronomicon (900). Thoth Amon's
  message says allies in the Realmz already destroyed their copy at great cost.
- **Runtime-proven:** The pit at land map 7 `(3, 24)` is hot enough to destroy
  magical items. Giving item 900 to complex encounter 10 burns the book,
  removes it from the party, and changes the relevant pit and homecoming action
  points. Messages 815 and 816 explicitly say the link between the Abyss and
  Realmz is broken and the quest is complete.
- **Runtime-proven:** The homecoming begins on land map 0 at `(9, 84)`.
  Battle 215 contains 15 Fire Drakes and nine allied Westmore soldiers. Battle
  216 contains eight Fire Drakes, four Morbius clones, Thoth Amon, and two of
  Amon's Proteges. The route ends at `(24, 47)` with messages 1096 and 1097,
  which explicitly say the Realmz is saved and the scenario's main task is
  complete.

### Source-authored Hecubus loop

- **Runtime-proven:** Simple encounter 10 has 127 maximum attempts. After the
  diplomatic result kills Hecubus, grants the map and treasure, and enables the
  cache, the prompt reopens with 126 attempts remaining and no back-out choice.
- **Source-proven:** The selected result falls through without Classic's
  break-encounter-loop opcode. The repeat is therefore preserved Classic
  control flow, not an importer or interpreter invention.
- The acceptance route records the repeat and injects a test-only cancel
  outcome before continuing to the cache. This is an apparent scenario
  authoring defect and should not be presented as a normal player solution.

### Story, hint, and ending facts

- Lord Hecubus says he previously let a Realmz wizard believe a mental battle
  had defeated him. After Hecubus dies, Thoth Amon confirms that Hecubus had
  only suppressed his telepathic powers.
- The Book of Screams and Necronomicon are bound together under the arm of a
  small horned, winged skeleton. Message 1024 reminds the party that this is the
  moment when Thoth Amon advised using the blue gem.
- The pit first demonstrates its power by consuming another magical weapon.
  The book's destruction also burns the bastions and their nether-spawn cargo
  throughout the Realmz.
- Queen Selene intends to make the party members of Westmore's ruling council,
  but Morbius attacks during the ceremony. He kills Selene; Thoth Amon refuses
  healing after the final battle so that he can join her in death.
- Remdigis turns the grieving crowd against the party because the promised
  council seats threaten his political position. Selene's and Thoth Amon's
  spirits later console the party and grant caste-specific permanent benefits.
- Morbius warns that destroying his material shell will not prevent his
  eventual return. Message 1097 invites continued exploration after the main
  task.

### Authored text gaps worth preserving

- **Source-proven:** Messages 1055 and 1077 exist in the message table, but the
  homecoming macro chain does not call them. Message 1055 continues the queen's
  public introduction; message 1077 hints at a suspicious door after Morbius
  clones himself. Their absence from runtime is source-authored, not an import
  loss.

### Evidence

- Route: `playtest/routes/destroy_the_necronomicon.json`
- Installed report:
  `reports/classic_destroy_the_necronomicon_route_acceptance.json`
- Imported source records: `Data DD:0:39`, `Data DD:0:15`,
  `Data DD:4:11`, `Data DD:4:13`, `Data ED3:macro:194`,
  `Data ED3:macro:196`, `Data DD:0:56`, and `Data ED3:macro:237` through
  `249`.

## Grilochs Revenge

### Main completion chain

- **Runtime-proven:** The Spear of Light rests at `Data DD:9:16` on land map 9
  at `(18, 79)`. Battle 122 guards it with 49 creatures, including 25
  Invisible Haunters. Victory awards Treasure 64 and the Spear of Light +5
  (item 915).
- **Runtime-proven:** Griloch's throne sequence is
  `Data ED3:macro:466`, exercised at land map 9 `(70, 20)`. It checks for item
  915 before selecting the real Griloch fight. Without the Spear, the source
  branches to a different escape and Battle 123 path.
- **Runtime-proven:** The Spear branch enters Battle 124: five Solsux, two Dark
  Servants, six Ice Demons, five Tuchor-uth, 19 Invisible Haunters, and Griloch.
  Victory explicitly says Griloch is vanquished and points the party to a
  glowing brazier north of the throne.
- **Runtime-proven:** The brazier at `Data DD:9:31` `(70, 25)` enables
  `Data DD:6:16` and teleports the party to land map 6 `(80, 40)`. That island
  reception enables `Data DD:2:54` and returns the party to land map 2
  `(49, 55)`.
- **Runtime-proven:** The mainland celebration at `Data DD:2:54` sets quest
  flag 55, tells the party to enter the temple for salvation, and teleports
  them beside it at `(85, 14)`.
- **Runtime-proven:** Berhune's temple at `Data DD:2:13` checks quest 55 before
  running macros 509 and 547. These award six separate 30,000-experience
  grants, Treasure 73, and messages 1310 and 1311. Message 1310 explicitly
  identifies the end of the scenario; message 1311 warns that continued
  wandering may seem odd because the author expected the player to quit.

### Walkthrough and combat facts

- Classic teleport opcode 20 does not activate the destination action point
  within the same command. After using the throne-room brazier, the island
  reception and then the mainland celebration are separate action points that
  must be entered or triggered. This is relevant to any future walkthrough or
  hint text.
- **Source-proven:** Battle 124's battle macro alternates macros 470 and 471,
  which provide Griloch and Invisible Haunter round behavior. The acceptance
  route forces native victory after verifying the complete initial formation,
  so it does not certify the timing or difficulty of those recurring rounds.
- The throne macro actively requests sound ID `-92`. The installed scenario and
  stock mapping provide no playable asset for it. This is an unresolved
  external Classic resource with silent absent-source behavior, not a
  source-authored no-op.

### Final reward

- **Runtime-proven:** Treasure 73 presents 5,000 gems, 1,000 jewelry, and these
  exact item entries: Excalibur +7 (177), Gauntlets +30 (236), Cape of
  Everlasting Life (253), Winged Helm of Zephron +10 (411), Emeral Alloy
  Shield +12 (463), Band of the Unicorn +15 (464), Hells Caretaker +15 (469),
  Improvement twice (607), Improved Brawn twice (681), Improved Knowledge
  twice (682), Improved Judgment (683), Improved Agility (684), Improved
  Vitality (685), Improved Stamina (686), and Scepter of Soul Stealing (708).
- The scenario issues the six experience awards consecutively, without a
  message between reward windows. That authored sequence exposed and now
  regression-checks the native reward-window close ordering.

### Completion evidence boundary

- Quest 55 and the explicit end text establish the completion spine. Interesting
  rooms, battles, and quest-like flavor elsewhere in the scenario should remain
  optional or unclassified unless a reachable branch, quest flag, or completion
  message connects them to this chain.
- The dedicated route jumps between source-identified milestones. It proves the
  installed completion behavior, not a manual path through every intervening
  map or optional quest.

### Evidence

- Route: `playtest/routes/grilochs_revenge.json`
- Installed report:
  `reports/classic_grilochs_revenge_route_acceptance.json`
- Imported source records: `Data DD:9:16`, `Data ED3:macro:466`,
  `Data ED3:macro:470`, `Data ED3:macro:471`, `Data ED3:macro:472`,
  `Data DD:9:31`, `Data DD:6:16`, `Data DD:2:54`, `Data DD:2:13`,
  `Data ED3:macro:509`, and `Data ED3:macro:547`.

## Half Truth

### Main completion chain

- **Runtime-proven:** Global Start macro 58 presents PICT 30011 and shoreline
  sound 242 before running the shipwreck sequence. The lighthouse marks what
  appears to be safe passage, but the ship strikes black rocks and leaves the
  party on land map 0 at `(42, 69)`.
- **Runtime-proven:** Domnu's shrine is `Data DD:1:90` on land map 1 at
  `(72, 62)`. Agreeing to oppose the Grey God opens Complex Encounter 23.
  The spoken-word answer is `fomorians`. The successful result gives Treasure
  84, whose sole item is the Fomorian Hammer (971).
- **Source-proven:** Hammer possession controls the campaign's northern
  progression. `Data DD:7:89` checks item 971 before Rowan says to strike the
  Avatar with Domnu's Hammer. `Data DD:9:56` and `Data DD:9:65` turn parties
  without the Hammer back from the Shadowgaunt approach.
- **Runtime-proven:** `Data ED3:macro:404`, exercised at land map 10
  `(34, 5)`, enters Battle 253 against 11 Shadow Bats and the Grey God's
  Avatar. The victory continuation sets quest 63, changes the rift tile to
  155, disables land random rectangle 2, awards 12,000 experience, and moves
  the party to `(7, 5)`.
- **Runtime-proven:** `Data ED3:macro:403` asks whether to leave the
  Shadowgaunt stronghold. After teleporting the party to land map 9 `(62, 6)`,
  quest 63 selects macro 407 and its celebration. Message 2090 explicitly says
  the scenario's major plotline is complete.

### Avatar transformation

- **Source-proven:** The first Avatar record (monster 82) uses death macro 405.
  That macro says the Fomorian Hammer releases Domnu's remaining power, breaks
  the Avatar's divine invulnerability, and spawns monster 83 through Extra
  Code 1238.
- **Source-proven:** Monster 83 is a much stronger second Avatar form and uses
  death macro 44. That macro says the Avatar's link to the Grey God is severed,
  turns him to dust, and sets quest 63.
- The acceptance route forces victory after verifying Battle 253's initial
  formation. It runtime-exercises macro 406's victory continuation but does
  not individually kill the two Avatar forms. The transformation and second
  death hook remain source-proven rather than runtime-proven.

### Walkthrough and hint facts

- The answer to Domnu's riddle, "Who were my people?", is `fomorians`.
  Complex Encounter 23 compares the spoken response case-insensitively using
  Classic's stored-word rules.
- Domnu says the Hammer cannot destroy the Grey God; it can only remove his
  Avatar's invulnerability briefly. Rowan repeats this instruction before the
  Shadowgaunt approach.
- The apparent safe lighthouse is part of the wreckers' trap. The first nearby
  encounter, `Data DD:0:1` at `(42, 67)`, has an old man explain that wreckers
  lure ships onto the rocks and invites the party north.
- Defeating the Avatar destabilizes his tortured plane and ejects the party
  back into the Shadowgaunt stronghold. Leaving the stronghold is a separate
  interaction that triggers the celebration.

### Optional-content boundary

- Message 2090 deliberately distinguishes the completed major plotline from
  "plenty of sidelines" that can still be explored. Those sidelines are not
  completion requirements merely because they contain quest-like story,
  battles, or rewards.
- The dedicated route jumps between source-identified milestones. It proves
  the installed completion behavior, not a manual path through every
  intervening map or optional quest.

### Evidence

- Route: `playtest/routes/half_truth.json`
- Installed report:
  `reports/classic_half_truth_route_acceptance.json`
- Imported source records: `Data ED3:macro:58`, `Data DD:1:90`, Complex
  Encounter 23, Treasure 84, `Data DD:7:89`, `Data DD:9:56`,
  `Data DD:9:65`, `Data ED3:macro:403` through `407`, and
  `Data ED3:macro:44`.

## Mithril Vault

### Main completion chain

- **Runtime-proven:** `Data DD:0:0` at land map 0 `(37, 6)` presents the
  Winterhaven and Silver Peak setup with PICT 32128 and stock sound 20001.
- **Runtime-proven:** `Data ED3:macro:138`, exercised on land map 11 at
  `(3, 83)`, reveals Morbius, sets quest 77, and enters Battle 33 against
  monster 61 and three copies of monster 62.
- **Runtime-proven:** `Data ED3:macro:157`, exercised on land map 11 at
  `(55, 49)`, enters Battle 40. Gail Wyrmrider (monster 68) carries The Geyser
  (item 809) in inventory slot six, and the native defeated-enemy reward gives
  that exact item to the party.
- **Runtime-proven:** `Data DD:1:27` at `(64, 4)` accepts item 809 and sends
  the party to King Cormite. `Data DD:8:1` at `(12, 13)` accepts the same item,
  enters Battle 41, and runs the theft sequence that removes it.
- **Runtime-proven:** Battle 41 places Cormite and 25 dwarves on the party's
  side against 6 Alien Vraps, 8 Alien Mantises, and 8 Alien Telenites.
- **Runtime-proven:** `Data DD:8:5` at `(7, 71)` enters Battle 53 against 20
  Golian defenders. `Data DD:8:3` at `(11, 70)` then runs macro 186, which
  changes land-10 trigger 2 from zero to 100 percent.
- **Runtime-proven:** The activated `Data DD:10:2` at `(82, 72)` presents
  Treasure 38, returns The Geyser, and runs macros 187 through 189. The party
  receives the all-character level-up and Treasure 39, item 809 is removed,
  the consumed trigger is deleted, and message 562 explicitly completes the
  main goal.

### Morbius and counterattack chains

- **Source-proven:** Morbius images (monster 62) use death macro 150 and the
  body (monster 61) uses death macro 151. Those macros replace the current
  form, and weakened Morbius (monster 63) uses death macro 148. That last hook
  presents Treasure 36 with 30,000 experience and item 731.
- The acceptance driver forces Battle 33 victory after checking its initial
  formation. It does not individually kill each Morbius form, so the
  transformation chain remains source-proven.
- **Source-proven:** Macros 170, 171, 175, and 180 enter Battles 45 through 49
  during the alien and Golian counterattack. Battle 49's macro 182 adds further
  combatants before macro 183 returns to the pursuit. The dedicated route
  source-checks these records but jumps over their runtime battles.

### Walkthrough and hint facts

- The Geyser is Classic item 809. It must be recovered from Gail Wyrmrider in
  Battle 40 before the Winterhaven council and King Cormite reports can
  progress.
- The relic is stolen after the warren invasion. Its absence afterward is
  intentional; the final Gridstone sequence restores it before the scenario
  removes it permanently.
- Prilit's power-control interaction on land map 8 `(11, 70)` is what activates
  the otherwise inert recovery trigger on land map 10.
- The final material rewards are items 195, 197, 471, and 733. Message 562 is
  the explicit main-goal completion marker.
- An optional casket at `Data DD:11:77` presents messages 455 through 457,
  Treasure 98, and an all-party level-up. Treasure 98 contains items 236, 415,
  644, 203, 246, and 625, plus 30,000 experience, 500 gems, 9,000 gold, and 20
  jewels. It is a lucrative sideline, not part of the certified main path.

### Item lifecycle

- Gail Wyrmrider's source record carries `[34, 218, 404, 423, 459, 809]`.
- Extra Code 294 is the possession check used by both story gates:
  `[809, 0, 0, 100, 0]`.
- Extra Code 295 removes item 809 during the theft:
  `[809, 99, 1, 0, 0]`.
- Treasure 38 restores item 809 at the ending. Extra Code 1660 removes it after
  the explicit completion message.

### Optional-content boundary

- Quest 77 is established during the Morbius sequence and set again by macro
  183; it is not the scenario-completion flag. The explicit ending is the
  Gridstone recovery and message 562.
- The dedicated route proves the installed milestone chain, not manual travel
  through every intervening map, Battles 45 through 49, optional casket, or
  individual Morbius death.

### Evidence

- Route: `playtest/routes/mithril_vault.json`
- Installed report:
  `reports/classic_mithril_vault_route_acceptance.json`
- Imported source records: `Data DD:0:0`, `Data DD:1:27`, `Data DD:8:1`,
  `Data DD:8:3`, `Data DD:8:5`, `Data DD:10:2`, `Data DD:11:77`,
  `Data ED3:macro:138`, `148`, `150`, `151`, `157`, `170`, `171`, `175`,
  `180`, and `182` through `189`; Battles 33, 40, 41, 45 through 49, and 53;
  Treasures 36, 38, 39, and 98.
