class_name RealmzMusicSettings

const DEFAULT_MUSIC_BY_TYPE := {
	"Battle": "battle.mod",
	"Camp": "camp.mod",
	"Cave": "cave.mod",
	"Create": "create.mod",
	"Dungeon": "dungeon.mod",
	"Indoor": "indoor.mod",
	"Items": "items.mod",
	"Shop": "shop.mod",
	"Temple": "temple.mod",
	"Treasure": "treasure.mod",
	"Town": "outdoor.mod",
	"Forest": "outdoor.mod",
	"Snow": "outdoor.mod",
	"Swamp": "outdoor.mod",
	"Desert": "outdoor.mod",
}


static func default_music_choice(type: String) -> String:
	return str(DEFAULT_MUSIC_BY_TYPE.get(type, "No Music"))


static func volume_db_from_setting(value: float) -> float:
	return (value - 100.0) * 0.5


static func setting_from_volume_db(value: float) -> float:
	return clampf((value * 2.0) + 100.0, 0.0, 100.0)
