extends Node

const BundleScript = preload("res://scripts/classic_runtime/classic_campaign_bundle.gd")
const InstallerScript = preload(
	"res://scripts/classic_runtime/classic_campaign_package_installer.gd"
)
const AdapterScript = preload(
	"res://scripts/classic_runtime/classic_godot_command_adapter.gd"
)
const MagicResistanceScript = preload(
	"res://scripts/classic_runtime/classic_magic_resistance.gd"
)
const ClassicCharacterRulesScript = preload(
	"res://scripts/classic_runtime/classic_character_rules.gd"
)
const PRODUCER_FIXTURE := \
	"res://scripts/classic_runtime/tests/fixtures/providence_authoritative_export"

var failures: Array[String] = []
var test_root := ""
var original_campaigns_directory := ""
var original_campaign := ""
var original_allies: Array = []


func _ready() -> void:
	call_deferred("_run_smoke")


func _run_smoke() -> void:
	await get_tree().process_frame
	original_campaigns_directory = Paths.campaignsfolderpath
	original_campaign = GameGlobal.currentcampaign
	original_allies = GameGlobal.player_allies.duplicate()
	test_root = ProjectSettings.globalize_path(
		"user://classic-generated-ally-smoke-%d" % Time.get_ticks_msec()
	)
	var installer = InstallerScript.new()
	installer._remove_directory(test_root)
	var fixture_directory := _prepare_resource_fixture(installer)
	if fixture_directory.is_empty():
		_finish()
		return
	var campaigns_directory := test_root.path_join("Campaigns")
	var install_result: Dictionary = installer.install_export(
		fixture_directory,
		campaigns_directory
	)
	_expect_equal(
		install_result.get("status"),
		"ok",
		"producer-derived inventory fixture installs for ally smoke"
	)
	if str(install_result.get("status", "")) != "ok":
		_finish()
		return

	var campaign_name := fixture_directory.get_file()
	var campaign_directory := campaigns_directory.path_join(campaign_name)
	Paths.campaignsfolderpath = campaigns_directory.replace("\\", "/").trim_suffix("/") + "/"
	GameGlobal.set_current_campaign(campaign_name)
	GameGlobal.player_allies.clear()
	var resources: CampaignResources = NodeAccess.__Resources()
	resources.load_campaign_ressources(campaign_name)
	_expect(
		resources.crea_book.has("Classic Monster 1"),
		"normal campaign resources load the generated Bestiary entry"
	)
	_expect(
		resources.crea_book.has("Classic Monster 2"),
		"normal campaign resources load the generated elemental attacker"
	)
	_expect(
		resources.items_book.has("Classic Item 901"),
		"normal campaign resources load the generated scenario item"
	)
	_expect(
		resources.items_book.has("Classic Item 150"),
		"normal campaign resources load the generated scenario weapon"
	)
	_expect(
		resources.items_book.has("Classic Item 250"),
		"normal campaign resources load the generated scenario armor"
	)
	_expect(
		resources.items_book.has("Classic Item 251"),
		"normal campaign resources load the generated scenario shield"
	)
	var elemental_attacker: Creature = GameGlobal.combatCreatureGD.new()
	elemental_attacker.initialize_from_bestiary_dict("Classic Monster 2")
	_expect_equal(
		elemental_attacker.current_melee_weapons[0].get(
			"weapon_dmg", {}
		).get("Electric"),
		[1.0, 8.0],
		"native creature loading retains generated Classic shock damage"
	)
	_expect_equal(
		elemental_attacker.current_melee_weapons[0].get(
			"extra_data", {}
		).get("classicSpecialAttack"),
		13,
		"native creature loading retains Classic attack metadata"
	)
	_expect_equal(
		elemental_attacker.get_meta("classic_required_weapon_kind", ""),
		"blunt",
		"native creature loading retains the Classic weapon requirement"
	)
	_expect_equal(
		elemental_attacker.get_meta("classic_required_magic_plus", 0),
		2,
		"native creature loading retains the Classic magic-plus requirement"
	)
	var weapon_user: Creature = GameGlobal.combatCreatureGD.new()
	weapon_user.initialize_from_bestiary_dict("Classic Monster 3")
	_expect_equal(
		weapon_user.current_melee_weapons[0].get("classicItemId"),
		150,
		"native creature equips the generated scenario weapon"
	)
	_expect_equal(
		weapon_user.current_melee_weapons[0].get("type"),
		"Dagger",
		"generated scenario weapon loads with its concrete native item type"
	)
	_expect_equal(
		weapon_user.current_melee_weapons[0].get("weapon_dmg", {}).get("Physical"),
		[1.0, 6.0],
		"equipped scenario weapon retains its native physical damage"
	)
	_expect_equal(
		weapon_user.current_melee_weapons[0].get("weapon_dmg", {}).get("Fire"),
		[1.0, 4.0],
		"equipped scenario weapon retains its Classic heat damage"
	)
	_expect_equal(
		weapon_user.current_melee_weapons[0].get("extra_data", {}).get(
			"classicWeaponKind"
		),
		"blunt",
		"equipped scenario weapon retains its Classic weapon classification"
	)
	_expect_equal(
		weapon_user.current_melee_weapons[0].get("extra_data", {}).get(
			"classicMagicPlus"
		),
		2,
		"equipped scenario weapon retains its Classic magic plus"
	)
	_expect_equal(
		weapon_user.current_melee_weapons[0].get("weapon_tag_bonus_dmg", {}).get(
			"Undead", {}
		).get("Physical"),
		[1.0, 4.0],
		"normal item loading retains Classic target-bonus damage"
	)
	_expect_equal(
		weapon_user.get_stat("AccuracyMelee")
			- weapon_user.base_stats.get("AccuracyMelee", 0),
		2,
		"equipped scenario weapon applies its Classic melee accuracy bonus once"
	)
	_expect_equal(
		weapon_user.get_stat("Bonus_Physical_dmg")
			- weapon_user.base_stats.get("Bonus_Physical_dmg", 0),
		2,
		"equipped scenario weapon applies its Classic damage bonus once"
	)
	_expect_equal(
		weapon_user.get_stat("Strength")
			- weapon_user.base_stats.get("Strength", 0),
		2,
		"equipped scenario weapon applies its Classic strength modifier once"
	)
	_expect_equal(
		weapon_user.get_stat("maxSP") - weapon_user.base_stats.get("maxSP", 0),
		5,
		"equipped scenario weapon applies its Classic maximum spell points once"
	)
	_expect_equal(
		weapon_user.get_stat("curSP") - weapon_user.base_stats.get("curSP", 0),
		5,
		"equipped scenario weapon applies its Classic current spell points once"
	)
	_expect_equal(
		weapon_user.get_stat("MaxMovement")
			- weapon_user.base_stats.get("MaxMovement", 0),
		4,
		"equipped scenario weapon applies its Classic movement modifier once"
	)
	var weapon_damage: Dictionary = GameGlobal.calculate_melee_damage(
		weapon_user,
		elemental_attacker,
		weapon_user.current_melee_weapons[0],
		false,
		1.0
	)
	_expect(
		float(weapon_damage.get("Physical", 0)) >= 2.0 \
			and float(weapon_damage.get("Physical", 0)) <= 10.0,
		"native combat rolls the Classic weapon and target-bonus ranges"
	)
	_expect(
		float(weapon_damage.get("Fire", 0)) >= 1.0 \
			and float(weapon_damage.get("Fire", 0)) <= 4.0,
		"native combat rolls the generated Classic heat range"
	)
	_expect_equal(
		weapon_damage.get("Bonus_dmg"),
		2,
		"native combat applies the generated Classic weapon magic-plus"
	)
	_expect(
		GameGlobal.calculate_melee_accuracy(
			weapon_user,
			elemental_attacker,
			weapon_user.current_melee_weapons[0]
		) > 0.0,
		"qualifying Classic weapon reaches native melee accuracy"
	)
	var sharp_weapon: Dictionary = weapon_user.current_melee_weapons[0].duplicate(true)
	sharp_weapon["extra_data"]["classicWeaponKind"] = "sharp"
	_expect_equal(
		GameGlobal.calculate_melee_accuracy(
			weapon_user,
			elemental_attacker,
			sharp_weapon
		),
		0.0,
		"wrong Classic weapon kind cannot hit the generated monster"
	)
	var weak_weapon: Dictionary = weapon_user.current_melee_weapons[0].duplicate(true)
	weak_weapon["extra_data"]["classicMagicPlus"] = 1
	_expect_equal(
		GameGlobal.calculate_melee_accuracy(
			weapon_user,
			elemental_attacker,
			weak_weapon
		),
		0.0,
		"insufficient Classic weapon magic plus cannot hit the generated monster"
	)
	var fixed_tag_weapon: Dictionary = (
		weapon_user.current_melee_weapons[0].duplicate(true)
	)
	fixed_tag_weapon["weapon_dmg"] = {"Physical": [1, 1]}
	fixed_tag_weapon["weapon_tag_bonus_dmg"] = {
		"Undead": {"Physical": [4, 4]},
	}
	var fixed_tag_damage: Dictionary = GameGlobal.calculate_melee_damage(
		weapon_user,
		elemental_attacker,
		fixed_tag_weapon,
		false,
		1.0
	)
	_expect_equal(
		fixed_tag_damage.get("Physical"),
		5.0,
		"native combat adds a matching tagged damage range to base weapon damage"
	)
	var shock_damage: Dictionary = GameGlobal.calculate_melee_damage(
		elemental_attacker,
		weapon_user,
		elemental_attacker.current_melee_weapons[0],
		false,
		1.0
	)
	_expect(
		float(shock_damage.get("Electric", 0)) >= 1.0 \
			and float(shock_damage.get("Electric", 0)) <= 8.0,
		"native combat accepts the generated Classic shock damage key"
	)
	var fighter: GDScript = load("res://Data/Character Classes/Class_Fighter.gd")
	var human: GDScript = load("res://Data/Character Races/Race_Human.gd")
	var priest: GDScript = load("res://Data/Character Classes/Class_Priest.gd")
	var elf: GDScript = load("res://Data/Character Races/Race_Elf.gd")
	var native_stat_character: PlayerCharacter = GameGlobal.playerCharacterGD.new(
		{"name": "Native Equipment Fixture", "level": 0},
		null,
		null,
		fighter,
		human
	)
	var native_shield: Dictionary = resources.items_book["Shield"].duplicate(true)
	var native_evasion_before: int = native_stat_character.get_stat("EvasionMelee")
	native_stat_character.inventory.append(native_shield)
	_expect(
		native_stat_character.equip_item(native_shield),
		"native equipment-stat fixture equips its shared shield"
	)
	_expect_equal(
		native_stat_character.get_stat("EvasionMelee"),
		native_evasion_before + int(native_shield["stats"]["EvasionMelee"]),
		"native equipment applies its declared stat once"
	)
	var classic_creation_character: PlayerCharacter = (
		GameGlobal.playerCharacterGD.new(
			{"name": "Classic Creation Fixture", "level": 0},
			null,
			null,
			fighter,
			human
		)
	)
	classic_creation_character.set_classic_creation_attributes({
		"Strength": 7,
		"Intellect": 12,
		"Wisdom": 12,
		"Dexterity": 23,
		"Vitality": 14,
		"classicLuck": 22,
		"classicGender": 2,
		"classicAgeYears": 20,
		"classicAgeGroup": 2,
	})
	_expect_equal(
		classic_creation_character.get_stat("Dexterity"),
		23,
		"native character creation accepts Classic attributes"
	)
	var overweight_gift: Dictionary = resources.items_book[
		"Classic Item 150"
	].duplicate(true)
	overweight_gift["name"] = "Overweight Classic creation gift"
	overweight_gift["classicItemId"] = 990
	overweight_gift["weight"] = 1000000
	resources.items_book[overweight_gift["name"]] = overweight_gift
	classic_creation_character.inventory.append(
		resources.items_book["Dagger"].duplicate(true)
	)
	classic_creation_character.money = [99, 2, 1]
	classic_creation_character.apply_classic_rule_profile({
		"creation": {
			"startingMoney": 41,
			"startingItemIds": [
				150, 250, 251, 990, 0, 0, 0, 0, 0, 0,
				0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			],
		},
		"itemPermissions": {
			"raceMasks": [
				(1 << 28) | (1 << 6),
				1 << 28,
			],
			"casteMasks": [
				(1 << 28) | (1 << 6),
				1 << 28,
			],
		},
		"specialAbilities": {
			"raceBase": [
				2, 99, 1, 2, 99, 3, 4, 5, 6, 7, 8, 9, 10, 11,
			],
			"casteBase": [
				10, 0, 3, 5, 0, 20, 5, 5, 5, 5, 5, 5, 2, 4,
			],
			"levelMaximums": [
				4, 0, 2, 3, 0, 6, 2, 2, 2, 2, 2, 2, 5, 3,
			],
		},
	})
	var creation_special_abilities := (
		ClassicCharacterRulesScript.apply_character_creation_special_abilities(
			classic_creation_character
		)
	)
	_expect_equal(
		creation_special_abilities.get("status"),
		"ok",
		"native character creation accepts Classic special abilities"
	)
	_expect_equal(
		classic_creation_character.classic_special_abilities,
		[
			15, 0, 4, 6, 0,
			38, 9, 43, 11, 0,
			13, 49, 12, 15, 0,
		],
		"native creation applies source attribute modifiers to special abilities"
	)
	var creation_resources := (
		ClassicCharacterRulesScript.apply_character_creation_resources(
			classic_creation_character,
			resources.items_book
		)
	)
	_expect_equal(
		creation_resources,
		{
			"status": "ok",
			"startingMoney": 41,
			"addedItemIds": [150, 250, 251],
			"skippedItemIds": [990],
			"unequippedItemIds": [],
		},
		"native creation applies Classic gifts in source order and skips excess weight"
	)
	_expect_equal(
		classic_creation_character.money,
		[41, 0, 0],
		"native creation replaces Remake's gifts with Classic starting money"
	)
	_expect_equal(
		classic_creation_character.inventory.map(
			func(item: Dictionary) -> int: return int(item.get("classicItemId", 0))
		),
		[150, 250, 251],
		"native creation replaces the existing inventory with accepted Classic items"
	)
	_expect(
		classic_creation_character.inventory.all(
			func(item: Dictionary) -> bool: return int(item.get("is_identified", 0)) == 1 \
					and int(item.get("equipped", 0)) == 1
		),
		"accepted Classic starting equipment is identified and worn"
	)
	var classic_creation_saved: Variant = JSON.parse_string(
		classic_creation_character.get_save_string()
	)
	_expect(
		classic_creation_saved is Dictionary,
		"native character serialization retains Classic demographics"
	)
	if classic_creation_saved is Dictionary:
		var restored_creation_character: PlayerCharacter = (
			GameGlobal.playerCharacterGD.new(
				classic_creation_saved,
				null,
				null,
				fighter,
				human
			)
		)
		_expect_equal(
			restored_creation_character.get_stat("Dexterity"),
			23,
			"native character save/load retains Classic attributes"
		)
		_expect_equal(
			[
				restored_creation_character.classic_luck,
				restored_creation_character.classic_gender,
				restored_creation_character.classic_age_years,
				restored_creation_character.classic_age_group,
			],
			[22, 2, 20, 2],
			"native character save/load retains Classic demographics"
		)
		_expect_equal(
			restored_creation_character.money.map(
				func(value: Variant) -> int: return int(value)
			),
			[41, 0, 0],
			"native character save/load retains Classic starting money"
		)
		_expect_equal(
			restored_creation_character.inventory.map(
				func(item: Dictionary) -> int: return int(item.get("classicItemId", 0))
			),
			[150, 250, 251],
			"native character save/load retains Classic starting equipment"
		)
		_expect_equal(
			restored_creation_character.classic_special_abilities,
			classic_creation_character.classic_special_abilities,
			"native save/load retains Classic special abilities"
		)
		_expect_equal(
			ClassicCharacterRulesScript.apply_character_creation_resources(
				restored_creation_character,
				resources.items_book
			),
			{"status": "skipped", "reason": "already-applied"},
			"restored characters cannot receive Classic creation resources twice"
		)
	resources.items_book.erase(overweight_gift["name"])
	var player_weapon: Dictionary = resources.items_book[
		"Classic Item 150"
	].duplicate(true)
	var player_armor: Dictionary = resources.items_book[
		"Classic Item 250"
	].duplicate(true)
	var player_shield: Dictionary = resources.items_book[
		"Classic Item 251"
	].duplicate(true)
	var player_character: PlayerCharacter = GameGlobal.playerCharacterGD.new(
		{"name": "Fixture Fighter", "level": 0},
		null,
		null,
		fighter,
		human
	)
	player_character.apply_classic_rule_profile({
		"itemPermissions": {
			"raceMasks": [
				(1 << 28) | (1 << 6),
				1 << 28,
			],
			"casteMasks": [
				(1 << 28) | (1 << 6),
				1 << 28,
			],
		},
	})
	player_character.set_ability_selection_points(5)
	_expect_equal(
		player_character.get_ability_selection_points(),
		5,
		"native characters retain their saved generic ability budget"
	)
	player_character.set_ability_selection_points(0)
	var wrong_caste_character: PlayerCharacter = GameGlobal.playerCharacterGD.new(
		{"name": "Fixture Priest", "level": 0},
		null,
		null,
		priest,
		human
	)
	var wrong_race_character: PlayerCharacter = GameGlobal.playerCharacterGD.new(
		{"name": "Fixture Elf", "level": 0},
		null,
		null,
		fighter,
		elf
	)
	var classic_spellcaster: PlayerCharacter = GameGlobal.playerCharacterGD.new(
		{"name": "Classic Spell Selection Fixture", "level": 0},
		null,
		null,
		fighter,
		human
	)
	classic_spellcaster.level = 3
	classic_spellcaster.apply_classic_rule_profile({
		"spellcastingProgression": {
			"casterType": 1,
			"school": "Sorcerer",
			"catalogEnabled": 1,
			"startLevel": 2,
			"startLevels": [2, 0, 0],
			"maximumSpellLevels": [4, 0, 0],
			"maximumSpellLevel": 4,
		},
	})
	classic_spellcaster.set_classic_spellcaster_type(1)
	classic_spellcaster.ensure_classic_spell_levels(4)
	var classic_fireball: Variant = load(
		"res://shared_assets/spells/fireball.gd"
	).new()
	_expect_equal(
		classic_spellcaster.can_learn_spell_at_level(classic_fireball),
		3,
		"a Classic caster bypasses the native Fighter spell catalog"
	)
	_expect_equal(
		classic_spellcaster.get_selection_cost(classic_fireball),
		6,
		"native spell management uses the Classic level-three cost"
	)
	_expect_equal(
		classic_spellcaster.get_ability_selection_points(),
		7,
		"native spell management exposes the derived Classic budget"
	)
	classic_spellcaster.spells[2] = [
		{"name": "First Fireball", "script": classic_fireball},
		{"name": "Over-Budget Fireball", "script": classic_fireball},
	]
	classic_spellcaster.prepare_ability_selection()
	_expect_equal(
		classic_spellcaster.spells[2].size(),
		1,
		"native spell management prunes an over-budget Classic spell"
	)
	_expect_equal(
		classic_spellcaster.get_ability_selection_points(),
		1,
		"native spell management retains the remaining Classic point"
	)
	_expect(
		not wrong_caste_character.can_equip_item(player_weapon),
		"native equipment rejects a caste outside the Classic restriction"
	)
	_expect(
		not wrong_race_character.can_equip_item(player_weapon),
		"native equipment rejects a race outside the Classic restriction"
	)
	_expect_equal(
		[
			player_weapon.get("classicItemCategory"),
			player_armor.get("classicItemCategory"),
			player_shield.get("classicItemCategory"),
		],
		[3, 35, 25],
		"generated player equipment preserves its exact Classic categories"
	)
	_expect_equal(
		ClassicCharacterRulesScript.classic_item_use_permission(
			player_character,
			player_weapon
		),
		{
			"status": "ok",
			"allowed": true,
			"category": 3,
			"raceAllowed": true,
			"casteAllowed": true,
		},
		"the native player receives both active Classic permission masks"
	)
	var denied_player_weapon := player_weapon.duplicate(true)
	denied_player_weapon["name"] = "Denied Classic Weapon"
	denied_player_weapon["classicItemCategory"] = 4
	denied_player_weapon["equippable"] = 0
	_expect(
		not player_character.can_use_inventory_item(denied_player_weapon),
		"native item activation enforces active Classic category masks"
	)
	_expect(
		player_character.can_use_inventory_item(player_weapon),
		"native item activation accepts a Classic category allowed by both masks"
	)
	denied_player_weapon["equippable"] = 1
	_expect(
		not player_character.can_equip_item(denied_player_weapon),
		"native equipment enforces active Classic race and caste category masks"
	)
	_expect(
		player_character.can_equip_item(player_weapon),
		"native equipment accepts a Classic category permitted by both masks"
	)
	var player_accuracy_before: float = player_character.get_stat("AccuracyMelee")
	var player_damage_before: float = player_character.get_stat("Bonus_Physical_dmg")
	var player_strength_before: float = player_character.get_stat("Strength")
	var player_max_sp_before: float = player_character.get_stat("maxSP")
	var player_cur_sp_before: float = player_character.get_stat("curSP")
	var player_movement_before: float = player_character.get_stat("MaxMovement")
	player_character.inventory.append(player_weapon)
	player_character.inventory.append(player_armor)
	player_character.inventory.append(player_shield)
	var player_weighted_movement_before: int = (
		player_character.get_max_movement_weighted_down()
	)
	_expect(
		player_character.equip_item(player_weapon),
		"native player equipment accepts the generated Classic weapon type"
	)
	_expect_equal(
		player_character.current_melee_weapons[0].get("classicItemId"),
		150,
		"generated Classic weapon becomes the player's active melee weapon"
	)
	_expect_equal(
		player_character.get_stat("AccuracyMelee"),
		player_accuracy_before + 2,
		"generated Classic weapon applies its melee accuracy to the player"
	)
	_expect_equal(
		player_character.get_stat("Bonus_Physical_dmg"),
		player_damage_before + 2,
		"generated Classic weapon applies its damage bonus to the player"
	)
	_expect_equal(
		player_character.get_stat("Strength"),
		player_strength_before + 2,
		"generated Classic weapon applies its strength modifier to the player"
	)
	_expect_equal(
		player_character.get_stat("maxSP"),
		player_max_sp_before + 5,
		"generated Classic weapon applies its maximum spell points to the player"
	)
	_expect_equal(
		player_character.get_stat("curSP"),
		player_cur_sp_before + 5,
		"generated Classic weapon applies its current spell points to the player"
	)
	_expect_equal(
		player_character.get_stat("MaxMovement"),
		player_movement_before + 4,
		"generated Classic weapon applies its movement modifier to the player"
	)
	_expect(
		player_character.get_max_movement_weighted_down()
			> player_weighted_movement_before,
		"generated Classic movement increases usable native movement"
	)
	_expect_equal(
		player_armor.get("type"),
		"Leather Armor",
		"generated Classic armor uses the native player permission type"
	)
	_expect(
		player_character.equip_item(player_armor),
		"native player equipment accepts the generated Classic armor type"
	)
	_expect_equal(
		player_armor.get("equipped"),
		1,
		"generated Classic armor occupies the native body slot"
	)
	_expect_equal(
		player_shield.get("type"),
		"Small Shield",
		"generated Classic shield uses the native player permission type"
	)
	var player_melee_evasion_before: int = player_character.get_stat("EvasionMelee")
	var player_ranged_evasion_before: int = player_character.get_stat("EvasionRanged")
	var accuracy_attacker: Creature = GameGlobal.combatCreatureGD.new()
	var unshielded_hit_chance := GameGlobal.calculate_melee_accuracy(
		accuracy_attacker,
		player_character,
		player_weapon
	)
	_expect(
		player_character.equip_item(player_shield),
		"native player equipment accepts the generated Classic shield type"
	)
	_expect_equal(
		player_shield.get("equipped"),
		1,
		"generated Classic shield occupies the native shield slot"
	)
	_expect_equal(
		player_character.get_stat("EvasionMelee"),
		player_melee_evasion_before + 6,
		"generated Classic armor applies its native melee evasion once"
	)
	_expect_equal(
		player_character.get_stat("EvasionRanged"),
		player_ranged_evasion_before + 6,
		"generated Classic armor applies its native ranged evasion once"
	)
	var shielded_hit_chance := GameGlobal.calculate_melee_accuracy(
		accuracy_attacker,
		player_character,
		player_weapon
	)
	_expect(
		is_equal_approx(unshielded_hit_chance - shielded_hit_chance, 0.3),
		"generated Classic armor participates in native melee accuracy"
	)
	var shield_from_hits_trait = player_character.add_trait(
		load("res://shared_assets/traits/t_pro_hits.gd"),
		[3]
	)
	var protected_hit_chance := GameGlobal.calculate_melee_accuracy(
		accuracy_attacker,
		player_character,
		player_weapon
	)
	_expect(
		is_equal_approx(shielded_hit_chance - protected_hit_chance, 0.06),
		"Shield from Hits subtracts two percentage points per condition point"
	)
	player_character.remove_trait(shield_from_hits_trait)
	var projectile_protection_trait = player_character.add_trait(
		load("res://shared_assets/traits/t_pro_proj.gd"),
		[3]
	)
	var flame_missile = load(
		"res://shared_assets/spells/classic_core_1503_flame_missile.gd"
	).new()
	var missile_resolution: Dictionary = MagicResistanceScript.spell_resolution(
		player_character,
		flame_missile,
		1,
		100
	)
	_expect(
		missile_resolution.get("resisted"),
		"projectile protection stops a class-9 spell on a native player"
	)
	_expect_equal(
		missile_resolution.get("reason"),
		"projectile-protection",
		"native player resolution uses the shared compatibility stage"
	)
	player_character.remove_trait(projectile_protection_trait)
	_expect(
		player_character.unequip_item(player_weapon, false),
		"native player equipment removes the generated Classic weapon"
	)
	_expect_equal(
		player_character.get_stat("maxSP"),
		player_max_sp_before,
		"removing Classic equipment restores the player's maximum spell points"
	)
	_expect_equal(
		player_character.get_stat("curSP"),
		player_cur_sp_before,
		"removing Classic equipment restores the player's current spell points"
	)
	_expect_equal(
		player_character.get_stat("MaxMovement"),
		player_movement_before,
		"removing Classic equipment restores the player's movement stat"
	)
	_expect_equal(
		player_character.get_max_movement_weighted_down(),
		player_weighted_movement_before,
		"removing Classic equipment restores usable native movement"
	)
	var saved_player_data: Variant = JSON.parse_string(
		player_character.get_save_string()
	)
	_expect(
		saved_player_data is Dictionary,
		"native player serialization retains Classic item permissions"
	)
	if saved_player_data is Dictionary:
		var restored_player: PlayerCharacter = GameGlobal.playerCharacterGD.new(
			saved_player_data,
			null,
			null,
			fighter,
			human
		)
		var restored_weapon: Dictionary = {}
		for restored_item: Variant in restored_player.inventory:
			if restored_item is Dictionary \
					and int(restored_item.get("classicItemId", 0)) == 150:
				restored_weapon = restored_item
				break
		_expect_equal(
			restored_weapon.get("classicItemCategory"),
			3,
			"Classic item category survives native player save/load"
		)
		_expect(
			restored_player.can_equip_item(restored_weapon),
			"restored Classic permissions accept the saved weapon category"
		)

	var bundle = BundleScript.new()
	_expect(bundle.load_from_directory(campaign_directory), "installed producer bundle loads")
	if not bundle.last_error.is_empty():
		_finish()
		return
	var monster: Dictionary = bundle.get_monster(1)
	var add_result: Dictionary = await AdapterScript.new().execute_command(
		"add_party_ally",
		{"monsterId": 1, "monster": monster}
	)
	_expect_equal(add_result.get("monsterId"), 1, "native adapter adds the producer monster")
	_expect_equal(GameGlobal.player_allies.size(), 1, "producer monster joins the native ally list")
	if GameGlobal.player_allies.is_empty():
		_finish()
		return

	var ally: Creature = GameGlobal.player_allies[0]
	_expect_equal(ally.bestiary_key, "Classic Monster 1", "ally retains its native resource key")
	_expect_equal(ally.classic_monster_id, 1, "ally retains its Classic record identity")
	_expect_equal(ally.classic_monster_name_id, 1, "ally retains its Classic name identity")
	_expect_equal(
		ally.get_meta("classic_spell_saves", []),
		[-25, -25, 100, 100, 100, 15],
		"ally receives separate Classic Charm and Mental saves through native resources"
	)
	_expect_equal(
		ally.get_meta("classic_spell_immunities", []),
		[1, 0, 0, 1, 1, 0],
		"ally receives its exact Classic spell-family immunities"
	)
	_expect_equal(
		ally.get_meta("classic_spell_screen_level", 0),
		1,
		"ally receives its permanent Classic spell screen through native resources"
	)
	_expect_equal(
		ally.get_meta("classic_regeneration_per_round", 0),
		2,
		"ally receives permanent Classic regeneration through native resources"
	)
	var ally_max_hp := int(ally.get_stat("maxHP"))
	ally.stats["curHP"] = ally_max_hp - 3
	await ally._on_new_round()
	_expect_equal(
		ally.get_stat("curHP"),
		ally_max_hp - 1,
		"normal creature round lifecycle applies exact Classic regeneration"
	)
	_expect_equal(ally.inventory.size(), 2, "ally receives both compiled monster items")
	var equipped_dagger := _inventory_item(ally.inventory, "Dagger")
	var carried_token := _inventory_item(ally.inventory, "Providence Token")
	_expect_equal(
		equipped_dagger.get("equipped"),
		1,
		"ally equips the concrete Classic weapon through native inventory"
	)
	_expect_equal(
		ally.current_melee_weapons[0].get("name"),
		"Dagger",
		"equipped Classic weapon remains the ally's active melee weapon"
	)
	_expect_equal(
		_spell_count(ally, "Fireball"),
		2,
		"ally receives the weighted Classic spell slots through the native spell book"
	)
	_expect_equal(
		carried_token.get("classicItemId"),
		901,
		"ally carries the scenario-local item with stable Classic identity"
	)
	ally.name = "Sentinel Companion"
	ally.stats["curHP"] = 17
	ally.money = [23, 2, 1]
	ally.joins_combat = false
	var saved_value: Variant = JSON.parse_string(ally.get_save_string() + "}")
	_expect(saved_value is Dictionary, "native ally serialization produces valid JSON")
	if not (saved_value is Dictionary):
		_finish()
		return
	var saved_ally: Dictionary = saved_value
	_expect_equal(
		saved_ally.get("bestiaryKey"),
		"Classic Monster 1",
		"native ally save preserves its Bestiary key"
	)
	var legacy_save := saved_ally.duplicate(true)
	legacy_save.erase("bestiaryKey")
	_expect_equal(
		Creature.resolve_bestiary_key_from_save(legacy_save, resources.crea_book),
		"Classic Monster 1",
		"Classic identity recovers the resource key for an older ally save"
	)

	GameGlobal.player_allies.clear()
	var restored_ally: Creature = GameGlobal.combatCreatureGD.new()
	_expect(
		restored_ally.initialize_from_saved_ally_dict(saved_ally),
		"normal native ally loader restores the generated resource"
	)
	GameGlobal.add_npc_ally(restored_ally)
	_expect_equal(restored_ally.name, "Sentinel Companion", "ally display name survives save/load")
	_expect_equal(restored_ally.stats["curHP"], 17, "ally health survives save/load")
	_expect_equal(restored_ally.money, [23, 2, 1], "ally money survives save/load")
	_expect(not restored_ally.joins_combat, "ally combat preference survives save/load")
	_expect_equal(restored_ally.classic_monster_id, 1, "record identity survives save/load")
	_expect_equal(restored_ally.classic_monster_name_id, 1, "name identity survives save/load")
	var restored_dagger := _inventory_item(restored_ally.inventory, "Dagger")
	var restored_token := _inventory_item(restored_ally.inventory, "Providence Token")
	_expect_equal(
		restored_dagger.get("equipped"),
		1,
		"equipped monster weapon survives native ally save/load"
	)
	_expect_equal(
		restored_ally.current_melee_weapons[0].get("name"),
		"Dagger",
		"restored Classic weapon remains active after ally save/load"
	)
	_expect_equal(
		restored_token.get("classicItemId"),
		901,
		"scenario-local carried item identity survives native ally save/load"
	)
	_expect_equal(
		_spell_count(restored_ally, "Fireball"),
		2,
		"weighted Classic spell slots survive native ally save/load"
	)
	_expect(
		_restored_spell_has_script(restored_ally, "Fireball"),
		"restored Classic spell remains executable through the native spell resource"
	)
	_expect_equal(
		restored_ally.get_meta("classic_spell_screen_level", 0),
		1,
		"restored ally recovers its permanent spell screen from the Bestiary entry"
	)
	_expect_equal(
		restored_ally.get_meta("classic_regeneration_per_round", 0),
		2,
		"restored ally recovers permanent regeneration from the Bestiary entry"
	)
	_expect_equal(
		restored_ally.get_meta("classic_spell_saves", []),
		[-25.0, -25.0, 100.0, 100.0, 100.0, 15.0],
		"restored ally recovers its separate Classic saves from the Bestiary entry"
	)
	_expect_equal(
		restored_ally.get_meta("classic_spell_immunities", []),
		[1.0, 0.0, 0.0, 1.0, 1.0, 0.0],
		"restored ally recovers its Classic immunities from the Bestiary entry"
	)
	_expect(
		AdapterScript.new().party_has_classic_ally({"monsterNameId": 1}, [restored_ally]),
		"restored producer ally satisfies a Classic name-identity check"
	)
	_finish()


func _prepare_resource_fixture(installer: Object) -> String:
	var fixture_directory := test_root.path_join("source").path_join(
		"producer-monster-inventory"
	)
	var copy_error: Error = installer._copy_directory(
		ProjectSettings.globalize_path(PRODUCER_FIXTURE),
		fixture_directory
	)
	_expect_equal(copy_error, OK, "ally smoke copies the producer fixture for derived coverage")
	if copy_error != OK:
		return ""
	var content_path := fixture_directory.path_join("classic/content.json")
	var content: Variant = JSON.parse_string(FileAccess.get_file_as_string(content_path))
	_expect(content is Dictionary, "ally smoke reads the derived content document")
	if not (content is Dictionary):
		return ""
	content["monsters"][0]["items"] = [1, 901, 0, 0, 0, 0]
	content["monsters"][0]["weapon"] = 1
	content["monsters"][0]["spells"] = [1306, 1306, 0, 0, 0, 0, 0, 0, 0, 0]
	content["monsters"][0]["conditions"][10] = -2
	content["monsters"][0]["conditions"][16] = -1
	content["monsters"][0]["saves"] = [-25, -25, 100, 100, 100, 15]
	content["monsters"][0]["spellImmunities"] = [1, 0, 0, 1, 1, 0]
	content["monsters"][0]["magicAttackCount"] = 2
	content["monsters"][0]["castPercent"] = 75
	var weapon_record: Dictionary = content["scenarioItems"][0].duplicate(true)
	weapon_record["id"] = 103
	weapon_record["itemId"] = 150
	weapon_record["type"] = 2
	weapon_record["hands"] = 1
	weapon_record["weight"] = 12
	weapon_record["cost"] = 40
	weapon_record["vSmall"] = 6
	weapon_record["vLarge"] = 6
	weapon_record["itemCat0"] = 1 << 28
	weapon_record["heat"] = 4
	weapon_record["damage"] = 2
	weapon_record["st"] = 2
	weapon_record["spellPoints"] = 5
	weapon_record["movement"] = 4
	weapon_record["blunt"] = -1
	weapon_record["vsUndead"] = 4
	weapon_record["specificRace"] = 1
	weapon_record["specificCaste"] = 1
	content["scenarioItems"].append(weapon_record)
	var weapon_text: Dictionary = content["itemTexts"][0].duplicate(true)
	weapon_text["id"] = 150
	weapon_text["itemId"] = 150
	weapon_text["identifiedName"] = "Providence Blade"
	weapon_text["unidentifiedName"] = "Plain Blade"
	weapon_text["description"] = "A producer-derived scenario weapon."
	content["itemTexts"].append(weapon_text)
	var armor_record: Dictionary = content["scenarioItems"][0].duplicate(true)
	armor_record["id"] = 104
	armor_record["itemId"] = 250
	armor_record["type"] = 4
	armor_record["hands"] = 0
	armor_record["itemCat1"] = 1 << 28
	content["scenarioItems"].append(armor_record)
	var shield_record: Dictionary = content["scenarioItems"][0].duplicate(true)
	shield_record["id"] = 105
	shield_record["itemId"] = 251
	shield_record["type"] = 3
	shield_record["hands"] = 1
	shield_record["itemCat0"] = 1 << 6
	shield_record["ac"] = 6
	content["scenarioItems"].append(shield_record)
	var elemental_monster: Dictionary = content["monsters"][0].duplicate(true)
	elemental_monster["id"] = 2
	elemental_monster["nameId"] = 2
	elemental_monster["displayName"] = "Providence Elemental"
	elemental_monster["items"] = [0, 0, 0, 0, 0, 0]
	elemental_monster["weapon"] = 0
	elemental_monster["spells"] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	elemental_monster["magicAttackCount"] = 0
	elemental_monster["castPercent"] = 0
	elemental_monster["saves"] = [0, 0, 0, 0, 0, 0]
	elemental_monster["spellImmunities"] = [0, 0, 0, 0, 0, 0]
	elemental_monster["attacks"][0][3] = 13
	elemental_monster["distance"] = -1
	elemental_monster["magicToHit"] = 2
	content["monsters"].append(elemental_monster)
	var weapon_monster: Dictionary = elemental_monster.duplicate(true)
	weapon_monster["id"] = 3
	weapon_monster["nameId"] = 3
	weapon_monster["displayName"] = "Providence Duelist"
	weapon_monster["items"] = [150, 0, 0, 0, 0, 0]
	weapon_monster["weapon"] = 150
	weapon_monster["attacks"][0][3] = 0
	content["monsters"].append(weapon_monster)
	var content_file := FileAccess.open(content_path, FileAccess.WRITE)
	_expect(content_file != null, "ally smoke writes the derived monster inventory")
	if content_file == null:
		return ""
	content_file.store_string(JSON.stringify(content, "  ", true) + "\n")
	content_file.close()
	return fixture_directory


func _inventory_item(inventory: Array, item_name: String) -> Dictionary:
	for item_value: Variant in inventory:
		if item_value is Dictionary and str(item_value.get("name", "")) == item_name:
			return item_value
	return {}


func _spell_count(creature: Creature, spell_name: String) -> int:
	var count := 0
	for spell_value: Variant in creature.get_all_spells():
		if spell_value is Dictionary and str(spell_value.get("name", "")) == spell_name:
			count += 1
	return count


func _restored_spell_has_script(creature: Creature, spell_name: String) -> bool:
	for spell_value: Variant in creature.get_all_spells():
		if spell_value is Dictionary \
				and str(spell_value.get("name", "")) == spell_name:
			return spell_value.get("script") is Object
	return false


func _expect(condition: bool, description: String) -> void:
	if condition:
		print("PASS: %s" % description)
		return
	failures.append(description)
	push_error("FAIL: %s" % description)


func _expect_equal(actual: Variant, expected: Variant, description: String) -> void:
	_expect(actual == expected, "%s (expected %s, got %s)" % [description, expected, actual])


func _finish() -> void:
	Paths.campaignsfolderpath = original_campaigns_directory
	GameGlobal.currentcampaign = original_campaign
	GameGlobal.player_allies = original_allies
	if not test_root.is_empty():
		InstallerScript.new()._remove_directory(test_root)
	if failures.is_empty():
		print("Classic generated ally smoke passed.")
		get_tree().quit(0)
		return
	printerr("Classic generated ally smoke failed: %s" % "; ".join(failures))
	get_tree().quit(1)
