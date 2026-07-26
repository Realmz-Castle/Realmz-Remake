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
