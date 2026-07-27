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

## Prelude to Pestilence

### Main completion chain

- **Runtime-proven:** Global Start macro 76 presents PICT 32128 and messages
  704, 190, and 191. It removes the party's starting funds before establishing
  the disoriented arrival.
- **Runtime-proven:** Macro 250 has Thyrr transport the party to dungeon map 0
  `(26, 59)`, where he warns them not to trust anyone and begins the search of
  Griloch's secret camp.
- **Runtime-proven:** Macro 254 opens the floodgates sequence. With quests 27,
  29, and 30 absent, macros 255 through 259 select Battle 87. Its complete
  formation contains 37 Griloch troops and the six friendly leaders Lluellyn,
  Retyu, Zulea, Safeera, Thyrr, and Cindred.
- **Runtime-proven:** After Battle 87, message 589 declares Griloch's army
  destroyed and Battle 86 isolates Griloch. Its continuation presents message
  590, awards 32,000 experience, sets quest 40 through macro 258, and says the
  party is free to wander.
- **Runtime-proven:** Quest 40 makes `Data DD:0:73` run macro 286. Accepting
  message 660's portal changes `Data DD:0:2` to macro 287 and teleports the
  party to land map 0 `(16, 22)`.
- **Runtime-proven:** Entering the changed Mountain View action point presents
  messages 591, 592, 661, and 662. The town celebrates, Mayor Hodar thanks the
  party, and the registered-copy text explicitly ends Prelude to Pestilence
  while pointing toward the later Pestilence scenario.

### Army and alliance variants

- **Source-proven:** Macro 255 first checks quest 30 and macro 256 checks quest
  29. Either flag permits Battle 85, whose formation includes allied Minotaur
  units as well as the named leaders.
- **Source-proven:** Macro 257 checks quest 27. If that flag is set while quests
  29 and 30 are absent, it selects Battle 88, whose formation includes hostile
  Minotaurs alongside Griloch's forces.
- **Source-proven:** Macro 259 is the no-alliance fallback. It selects Battle
  87, which omits the Minotaurs but still places the six named leaders on the
  party's side. This is the branch exercised by the installed route.
- The three branch battles converge on message 589, Battle 86 against Griloch,
  the 32,000-experience award, and quest 40. The alternative Battle 85 and 88
  formations are source-checked but not runtime-exercised by this checkpoint.

### Walkthrough and hint facts

- **Source-proven:** Quest 29 is set by macro 235 after Kayvon says the Sacred
  Book of Njaln has been returned and the Minotaur army will come to the
  party's aid.
- **Source-proven:** Quest 30 is set by macro 248 after the party uses the
  Candle of Summoning (item 888), survives Battle 84, and consumes the candle.
- **Source-proven:** Quest 27 is set by macro 270 if the party chooses to leave
  peace talks early. Messages 631 and 632 warn that this disgraces the
  Minotaurs and causes them to join Griloch.
- The necklaces of Berhune and Griloch are items 884 and 885. The Sword of
  Volta +2 is item 886. The Candle of Summoning is item 888 and says it can
  summon whoever the bearer desires.
- The post-victory portal and the Mountain View celebration are two separate
  interactions. Macro 286 changes the town action point and teleports beside
  it; the player must then enter that changed point to run the epilogue.
- The floodgates sequence's signed sound IDs are not silent placeholders.
  IDs `-635`, `-637`, `-636`, and `-631` resolve to the stock clash, attack
  hit, metal hit, and resurrect death sounds respectively.
- Message 590 says Griloch has been defeated and Mountain View saved, but warns
  that he will return with an undead army. The scenario description identifies
  Prelude as the first Griloch chapter and Griloch's Revenge as the second.

### Optional-content boundary

- Quest 40, the victory portal, and the registered Mountain View epilogue form
  the explicit completion spine. Quests 27, 29, and 30 alter the final army but
  are not each required for completion.
- The dedicated route jumps between source-identified milestones. It proves the
  installed no-alliance completion behavior, not manual travel through every
  intervening map, all alliance quest branches, or every optional encounter.

### Evidence

- Route: `playtest/routes/prelude_to_pestilence.json`
- Installed report:
  `reports/classic_prelude_to_pestilence_route_acceptance.json`
- Imported source records: `Data DD:0:2`, `Data DD:0:73`,
  `Data ED3:macro:76`, `235`, `248`, `250`, `254` through `259`, `270`, `286`,
  and `287`; Battles 84 through 88; items 884 through 886 and 888; Extra Codes
  485 through 494, 547 through 550, 589, and 592.

## Trouble in the Sword Lands

### Main completion chain

- **Runtime-proven:** `Data DD:0:0` at land map 0 `(3, 3)` presents PICT
  32128. The King of Bywater has sent the party to discover who or what is
  disrupting trade with the Sword Lands. Macros 1 and 138 complete the
  introduction and set quest 6.
- **Runtime-proven:** Macro 251 frees a swordswoman prisoner. Accepting her
  offer runs macro 252, identifies her as Naryl Dragonstone, and adds monster
  161 as an ally.
- **Runtime-proven:** Macro 2019 finds a secret compartment in Kith Khanaan's
  tomb. Treasure 182 supplies Kith's Talisman (item 944) and 1,000 experience.
- **Runtime-proven:** Macro 2021 manifests Kith Khanaan's essence. Macros 2025
  and 2026 remove item 944, replace Naryl Dragonstone with Naryl Thezzat
  (monster 235), and explain that Kith is using her as a temporary vessel for
  a surprise mental assault.
- **Runtime-proven:** `Data DDD:3:49` detects ally 235 and runs macro 2055.
  Kith denounces the Overlords' attempt to revive the Mind Lords, attacks them
  psionically, and leaves them weakened. Battle 349 contains two Overlords and
  Overlord Arla Qui.
- **Runtime-proven:** The Battle 349 victory continuation restores Naryl
  Dragonstone, removes the hostile headquarters state, and opens the rooms
  beyond for searching.
- **Runtime-proven:** `Data DDD:3:51` presents PICT 30124. A surviving member
  of the Inner Council says the second phase is already underway and War will
  come to the Sword Lands. Macro 2074 then presents messages 3059 through
  3061, explicitly declares the main plot complete, points to War in the Sword
  Lands as part two, shows the credits, and awards 10,000 experience.

### Three-crisis lead-in

- **Source-proven:** Lord Paladine's audience macros 424 through 426 identify
  three regional crises: goblin attacks on caravans from Hark Wood, marauders
  connected to Dagger Keep and Doran Ghall, and pirates based in the southern
  archipelago.
- The audience has variants for parties that solved one or two crises before
  reporting to Tanirith. Messages 763 through 771 acknowledge completed work
  and narrow the remaining assignment rather than treating those events as
  unrelated sidelines.
- The final headquarters table ties the earlier collaborators together through
  letters and military maps. The installed checkpoint jumps over the manual
  crisis routes, so their encounters and reward chains remain source-proven.

### Kith path and alternate confrontation

- Kith's Talisman is item 944. Its scenario item record points to macro 2021,
  and macro 2025 removes the item after Kith enters Naryl. The route obtains
  the item and invokes that target directly; it does not certify a general
  inventory-use control.
- **Source-proven:** Without ally 235, macro 2056 lets the party accept or
  reject General Qui's offer to serve the New Order. Acceptance puts the party
  under the Overlords' control. Refusal runs macro 2057 and Battle 203.
- **Source-proven:** Battle 203 starts with 46 enemies, including 6 Mind-Mages,
  18 Psi-warriors, 13 Psi-stalkers, two ordinary Overlords, General Arla Qui,
  and six other spellcasters. Its battle macro 2059 can run macro 2060 to add
  more warriors.
- Battle 349 is the Kith-weakened alternative and contains only the three
  Overlords. This is the formation exercised by the installed route.
- **Source-proven:** Monsters 236 and 237 both use death macro 1570. The route
  forces native victory after checking the complete initial formation, so it
  does not individually exercise those death hooks.

### Walkthrough and hint facts

- Naryl Dragonstone must be present when the talisman is found for the full
  story context. Kith's possession changes her ally identity from 161 to 235;
  the final room checks for 235 specifically.
- Kith says the historical Mind Lords inevitably became mad or evil because
  their minds could not safely hold their power. He views the modern
  Overlords' belief in psionic superiority as a repetition of that failure.
- The final globe is a separate interaction after the Overlord battle. It
  supplies the warning that the Sword Lands have only a few months of reprieve
  and then presents the explicit completion text.
- The opening's signed sound `-203` is the scenario-owned Bird recording.
  The other selected route sounds resolve to stock intro, forest walk, gong,
  female battle cry, wind, scream, song, explosion, speech, glass, healing,
  and level-up mappings.

### Optional-content boundary

- Message 3059 explicitly distinguishes completion of the main plot from the
  many smaller adventures and treasures still available. Those remaining
  quests are optional by the scenario's own wording.
- The dedicated route proves the installed Kith-assisted completion behavior,
  not manual travel across all twenty land maps, every crisis encounter, the
  unassisted final army, or every optional adventure.

### Evidence

- Route: `playtest/routes/trouble_in_the_sword_lands.json`
- Installed report:
  `reports/classic_trouble_in_the_sword_lands_route_acceptance.json`
- Imported source records: `Data DD:0:0`, `Data DDD:3:49`,
  `Data DDD:3:51`, `Data ED3:macro:1`, `138`, `251`, `252`, `424` through
  `426`, `2019` through `2021`, `2025`, `2026`, `2055` through `2066`, and
  `2074`; Battles 203 and 349; Treasure 182; item 944; monsters 161, 235, 236,
  and 237.

## Twin Sands of Time

### Main completion chain

- **Runtime-proven:** `Data DD:1:9` presents message 2 and PICT 30128 at the
  authored land-map start. Its separate Get Click command must be acknowledged
  before the action point finishes.
- **Runtime-proven:** `Data DD:1:31` introduces Emi. Accepting his invitation
  runs macros 111 and 112. He connects the unnatural sandstorms to the
  disappearance of Ollahn and Malear, charges the party with finding the
  twins, and transports them into the scenario.
- **Runtime-proven:** `Data DD:0:12` has the lonely king ask the party to kill
  a vampire. Treasure 44 supplies the Dagger of Eromon (item 914), which he
  says must be driven through her heart.
- **Runtime-proven:** `Data DD:5:9` enters Battle 62 against Ja-Dran, one Red
  Dragon. Victory reveals Ollahn, presents Treasure 20, and adds Ollahn as ally
  144. Macro 129 then entrusts him to the Queen's representatives, drops ally
  144, and sets quest 67.
- **Runtime-proven:** Macro 131 recruits ally 145. The dialogue calls him
  Guntro, but monster 145 is named Malear and the Prince recognizes that same
  ally as Malear without an intervening reveal.
- **Runtime-proven:** `Data DD:6:35` and macro 201 present the Prince's invasion
  council. Malear agrees to reunite with Ollahn, map 14 reveals the secret
  route, and the party receives the two explicit goals: reunite the twins and
  kill Queen Allimac.
- **Runtime-proven:** Macros 244 through 250 transform Malear from ally 145 to
  the empowered ally 155 and enter Battle 105. Its initial formation has 32
  hostile creatures, eleven Prince's Royal Guards, and one Prince's Captain.
  Victory presents Allimac's temporary defeat and returns Ollahn as ally 144.
- **Runtime-proven:** Macro 251 opens complex encounter 23. Selecting item 914
  presents message 673, turns Allimac to dust, applies the tomb mutations, and
  sets quest 69. Message 677 seals the entrance behind the party.
- **Runtime-proven:** Macro 205 transports the reunited party to the Prince's
  celebration square. Entering `Data DD:6:37` separately presents the memorial,
  the public thanks, and the reward choice. Declining to stay runs macro 207,
  gives Treasure 30 and 1,000 experience, and transports the party to the
  castle gate.
- **Runtime-proven:** Entering `Data DD:4:81` separately presents messages 572
  and 573. They explicitly conclude Twin Sands of Time, declare its main plot
  finished, and allow the party to continue wandering.

### Identity and narrative discrepancies

- Guntro's recruitment text says he wants to help kill orcs, but the action
  adds monster 145, whose source name is Malear. Later branches check and name
  that ally as Malear. No authored text in the completion spine explicitly
  reveals that Guntro is Malear.
- Macro 251 presents message 134, `Would you like to keep this letter?`, before
  the coffin description and complex encounter. The installed route confirms
  that this unrelated line is part of the compiled coffin action list.
- Complex encounter 23's successful item response says the Dagger of Eromon
  crumbles to dust. The result actions do not remove item 914, and Classic's
  ordinary encounter-item response inspects rather than consumes it. Quest 69
  and the tomb mutations advance while the dagger remains in inventory.

### Battles and allies

- Battle 62 contains only monster 38, a Red Dragon representing Ja-Dran.
- Battle 105 contains 32 initial hostiles: a Minor Demon, three Skeletal
  Warriors from monster 5, four Giant Zombies, two Winged Devils, three Ghouls,
  two Ghosts, three Skeletal Warriors from monster 86, an Orc Warrior, a
  Goblin, a Goblin Hero, a Flesh Fiend, two Demons, a Shantile, a Goblin
  Shaman, an Orc Shaman, an Orc Captain, two Orc Archers, a Goblin Champion,
  and Orc Vampire Allimac.
- The same formation uses negative grid identities for eleven Prince's Royal
  Guards and one Prince's Captain, forcing them onto the party's side.
- **Source-proven:** Battle 105 uses battle macro 249. Extra Code 509 can call
  macro 256 while Orc Vampire 152 remains present, present message 662, and
  spawn more enemies. The installed route checks the full initial formation
  and forces victory before certifying reinforcement rounds.
- The main ally progression is Ollahn 144, Malear 145, empowered Malear 155,
  then Ollahn 144 restored after the brothers reunite.

### Walkthrough and hint facts

- Emi's assignment is the earliest direct statement of the main mystery:
  reunite Ollahn and Malear to discover why the sandstorms began.
- The Queen initially sends the party after Ollahn and identifies Ja-Dran as
  his captor. The Shield of the Eternal is intended to protect against the Red
  Dragon's breath, but the dedicated route jumps directly to the battle.
- The Dagger of Eromon comes from the lonely king at land map 0 `(4, 86)`.
  Its importance is not limited to that local vampire request; it is the exact
  item accepted by Allimac's final coffin encounter.
- Defeating Allimac in Battle 105 is only temporary. Message 663 explicitly
  directs the party to find and destroy her coffin.
- Allimac's coffin result seals the original tomb entrance. The source mutates
  a hidden exit path, but the dedicated route jumps from the completed coffin
  state to the Prince's return branch rather than certifying the manual escape.
- Both the return teleport and the reward teleport place the party at the next
  milestone without automatically executing it. The player must enter the
  celebration square and later the castle-gate ending action point.
- Accepting the Prince's invitation to remain follows a different reward path.
  The installed route declines, receives Treasure 30, and takes the shortest
  authored route to the explicit ending.

### Optional-content boundary

- Quests 67 and 69, the reunited twins, the Prince's celebration, and messages
  572 and 573 form the runtime-proven completion spine.
- The route proves the direct installed completion behavior, not manual travel
  through all eight land maps and two dungeons, the Shield of the Eternal
  search, the hidden tomb escape, every regional quest, battle reinforcement
  rounds, the celebration-acceptance branch, or every optional encounter.

### Evidence

- Route: `playtest/routes/twin_sands_of_time.json`
- Installed report:
  `reports/classic_twin_sands_of_time_route_acceptance.json`
- Imported source records: `Data DD:0:12`, `Data DD:1:9`,
  `Data DD:1:31`, `Data DD:4:81`, `Data DD:5:9`, `Data DD:6:35`,
  `Data DD:6:37`, `Data ED3:macro:111`, `112`, `129`, `131`, `201`,
  `205` through `208`, `218`, `244` through `251`, `256`, and `257`;
  Battles 62 and 105; complex encounter 23; Treasures 20, 30, and 44;
  item 914; monsters 38, 96, 144, 145, 152, 154, and 155.

## War in the Sword Lands

### Main completion chain

- **Runtime-proven:** Macro 3 asks whether the party completed Part One.
  Answering yes preserves quest 1, presents the invasion prologue and PICT
  32128, and grants maps 1, 2, and 3.
- **Runtime-proven:** `Data DD:17:47` enters Battle 377 against Taroth Sark and
  32 psionic followers. Victory presents his defeat, sets quest 75, and awards
  10,000 experience.
- **Runtime-proven:** Macro 2851 diverts parties without quest 75. After Taroth
  Sark's defeat, Naryl names Nyxos Uhn, Zeiia No, Taroth Sark, Primus, and the
  Mind Lords, then joins as ally 123.
- **Runtime-proven:** Macro 3143 begins the liberation climax. Battles 473 and
  474 place Naerun Halgard on the party's side against Anthraxus Storm's two
  formations. Victory sets quest 42 and applies the authored shift from
  `(12, 76)` to `(12, 75)`.
- **Runtime-proven:** Macro 3158 has King Naerun reward the party with Treasure
  116 and declare the war in the Sword Lands over. Naryl immediately makes
  clear that the larger pursuit continues through Primus.
- **Runtime-proven:** `Data DD:16:67` enters Battle 212 against the three
  remaining Overlords and their 41 followers, a 44-member hostile formation.
- **Runtime-proven:** `Data DD:16:61` reveals that Primus is Xenon Maximus. Its
  rechecking teleport immediately runs the destination action point. Naryl
  takes Maximus's mind blast, ally 123 is removed, and messages 3961 and 3962
  explicitly complete the main story and point to Wrath of the Mind Lords.

### Continuity and route gates

- The opening yes answer records that Trouble in the Sword Lands was completed
  by preserving quest 1. The no branch sets quest 2 instead.
- **Source-proven:** Macro 3490 checks quest 2 and adds messages 3928 through
  3931, which explain Kith and Naryl to a party that did not carry Part One's
  continuity. Those explanatory lines do not appear on the installed yes path.
- Quest 75 is the real prerequisite for Naryl's recruitment. It is set by
  Taroth Sark's victory continuation, and macro 2851 immediately diverts to
  complex encounter 0 when the quest is absent.
- Naerun's declaration closes the regional war but not the scenario. Naryl's
  next line directs the party toward Primus, and the explicit main-story
  completion occurs only after the Maximus revelation and her sacrifice.

### Battles, allies, and rewards

- Battle 377 contains six Psi-stalkers, twenty Psi-Warriors, four Psi-Knights,
  two Psi-Knight Commanders, and Master Taroth Sark.
- Battle 473 contains 26 hostiles; Battle 474 contains 24. Naerun Halgard
  appears as one friendly combatant in each.
- Battle 212 contains nine Psi-stalkers, 23 Psi-Warriors, six Psi-Knights,
  three Psi-Knight Commanders, and one each of Taroth Sark, Nyxos Uhn, and
  Zeiia No.
- Treasure 116 contains items 28, 403, 424, 624, 634, and 114, plus 10,000
  experience, 1,000 gold, three gems, and one piece of jewelry.
- Naryl is ally 123 from her quest-75 recruitment through the final action
  point, where the compiled ending explicitly removes her.

### Walkthrough and hint facts

- Defeating Taroth Sark is both a major combat objective and the unlock for
  Naryl's information and recruitment.
- Anthraxus Storm's defeat and Naerun's reward are a midpoint ending. Continue
  following Naryl's investigation rather than treating the royal declaration
  as the final completion state.
- The final position change is rechecking: arriving at `(78, 36)` immediately
  triggers Naryl's sacrifice and the ending. It is not a separately entered
  action point like the return teleports in Twin Sands of Time.
- **Source-proven:** The ending has conditional farewell lines for party allies
  Riel 226, Athos 215, Ellai 242, and Leira 243. The dedicated route carries
  none of them, so those variants are not runtime-exercised.
- **Source-proven:** Messages 3741 through 3748 describe an alternate outcome
  in which Storm rewards the party and releases them toward Umaldyr. That
  service branch is not part of the dedicated completion route.

### Runtime ordering finding

- The Sharranth continuation exposed an engine ordering boundary. Native battle
  cleanup emitted `battle_end` before restoring the exploration actor, so
  Classic could apply macro 3148's position shift and then have it overwritten
  by the native restore.
- The command adapter now resumes Classic on the following process frame.
  Macro 3148 retaining `(12, 75)` after both battles is the installed regression
  check.

### Optional-content boundary

- Quests 42 and 75, Naryl ally 123, the four battle formations, Naerun's
  regional ending, the Maximus revelation, Naryl's sacrifice, and messages
  3961 and 3962 form the runtime-proven completion spine.
- The route proves the direct installed completion behavior, not manual travel
  through all 21 land maps and three dungeons, every regional quest, every
  alternate alliance path, the Storm-service outcome, the optional ally
  farewells, or every encounter.

### Evidence

- Route: `playtest/routes/war_in_the_sword_lands.json`
- Installed report:
  `reports/classic_war_in_the_sword_lands_route_acceptance.json`
- Imported source records: `Data DD:16:61`, `Data DD:16:64`,
  `Data DD:16:67`, `Data DD:17:47`, `Data ED3:macro:3`, `1772`, `2851`,
  `3143`, `3148`, `3158`, `3484`, `3489`, `3490`, `3497`, and `3499`;
  Battles 212, 377, 473, and 474; Treasure 116; monsters 29, 68, 123, 141,
  142, 143, 178, 185, 186, 187, 190, 210, 211, 212, 213, 261, and 323.

## White Dragon

### Main completion chain

- **Runtime-proven:** `Data DD:0:8` continues Zukar's search for the White
  Dragon, presents scenario PICT 32128, and introduces Brierwood.
- **Runtime-proven:** Macro 346 recruits Cylantra as ally 21 and sets quest 17.
  `Data DD:3:5` checks that quest before Cylantra finds Drawed's globe. Drawed
  names Blake as the White Dragon's only hope, and macro 306 sets quest 18.
- **Runtime-proven:** `Data DD:1:5` reunites Blake and Drawed, sets quest 19,
  applies the two canyon action-data patches, and adds Blake as ally 6.
- **Runtime-proven:** Macro 308 branches on Blake. Macros 310 and 312 turn the
  glass dragon back into Raquiline, remove Blake, add White Dragon ally 28, and
  teleport the party to land map 2 at `(2, 40)`.
- **Runtime-proven:** Macro 313 enters Battles 116 and 117 against two complete
  hostile dragon formations. Raquiline survives both and selects macro 314's
  successful continuation.
- **Runtime-proven:** Macro 316 enters Battle 118 against Nufack's first
  29-member planar formation.
- **Runtime-proven:** Macro 318 enters Battle 119 against Nufack and the full
  35-member initial formation. Raquiline's survival branches to macro 372.
- **Runtime-proven:** Macro 372 presents messages 791 and 792 and Simple
  Encounter 12. The checked magical-treasure response presents Treasure 46
  before messages 794 and 795 explicitly thank the player for playing White
  Dragon.

### Quest, ally, and route gates

- Quest 17 is the real Drawed gate. `Data EDCD:811` sends parties without it to
  empty macro 305, while Cylantra's recruited route continues into the globe
  scene.
- Quest 18 records finding Drawed. Quest 19 records the Blake reunion and is
  accompanied by the two action-data patches in `Data EDCD:813` and `814`,
  which point the authored canyon rows at macro 307.
- Blake ally 6 is the successful condition in `Data EDCD:815`. Without him,
  macro 311 presents Drawed's failure message and applies the authored failure
  effects instead of restoring Raquiline.
- Macro 312 replaces Blake with White Dragon ally 28. `Data EDCD:820` checks
  Raquiline after Battles 116 and 117; `Data EDCD:957` checks her again after
  Battle 119 before choosing the reward scene.

### Battles and rewards

- Battle 116 contains 18 dragons: two Frost, three Red, two Blue, two Green,
  four Chaos, three Brown, and two Ice Dragons.
- Battle 117 contains 16 dragons: one each of Frost, Red, Blue, and Green,
  five Chaos, four Brown, and three Ice Dragons.
- Battle 118 contains 29 initial hostiles: one Minor Demon, three Golems, four
  Shadow Wraiths, four Cacodeamon Warlords, four Heblorin Demons, five Winged
  Devils, and eight Masked Demons.
- Battle 119 contains 35 initial hostiles. Nufack is joined by three Flanveries
  Demons, one Minor Demon, one Chaos Dragon, three Fire Demons, two Shadow
  Wraiths, one Brown Dragon, two Winged Devils, four Fire Queens, seven Fire
  Minions, four Skeletal Knights, four Slime Demons, and two Masked Demons.
- Treasure 46 presents items 669, 672, 683, 165, and 254: Tools +20, Belt of
  Brawn, Improved Judgment, War Hammer +5, and Emerald Alloy Plate +10.
- **Source-proven:** Simple Encounter 12 also offers a special-magical-power
  response and a no-reward response. The dedicated route selects the treasure.

### Walkthrough and hint facts

- Cylantra is not merely optional flavor on the direct route. Her quest 17 is
  what lets the Drawed action point continue beyond its branch.
- Drawed's clue says Blake is hidden where the life of a river begins. Blake
  is then the ally required to pass from the glass-dragon scene into
  Raquiline's restoration.
- Freeing Raquiline is a midpoint, not the ending. She immediately asks the
  party to stop Nufack, followed by three consecutive battle stages.
- Message 791 says Nufack cannot be completely destroyed, but will need a very
  long time before he can reenter the Realmz. Message 795 is the scenario's
  explicit closing thanks.

### Battle-macro boundary

- **Source-proven:** Battles 118 and 119 carry battle macros `-317` and `-319`.
  Those macros can add combatants while their qualifying monsters remain, and
  Nufack also carries death macro 77.
- The dedicated route checks each complete initial formation and then forces
  victory after a stable player turn. It does not claim round-by-round coverage
  of every reinforcement, resurrection, or death-macro transformation.

### Optional-content boundary

- Quests 17, 18, and 19; allies Cylantra, Blake, and Raquiline; Battles 116
  through 119; the surviving-Raquiline branch; Treasure 46; and messages 794
  and 795 form the runtime-proven completion spine.
- The route proves the direct installed completion behavior, not manual travel
  through all 12 land maps and four dungeons, the complete Brierwood and Chloe
  arcs, every regional ally or side quest, every alternate failure or reward
  branch, every battle reinforcement, or every encounter.

### Evidence

- Route: `playtest/routes/white_dragon.json`
- Installed report:
  `reports/classic_white_dragon_route_acceptance.json`
- Imported source records: `Data DD:0:8`, `Data DD:1:5`, `Data DD:3:5`,
  `Data ED3:macro:306`, `308` through `314`, `316` through `319`, `346`,
  `372`, and `373`; `Data EDCD:811` through `816`, `818` through `821`,
  `825`, and `957`; Battles 116 through 119; Simple Encounter 12; Treasure
  46; monsters 1, 4, 6, 12, 21, 28, 35, 38, 39, 40, 41, 45, 54, 58, 60,
  62, 63, 69, 70, 71, 83, 84, 93, and 185.
