extends Node

const BundleScript = preload("res://scripts/classic_runtime/classic_campaign_bundle.gd")
const InstallerScript = preload(
	"res://scripts/classic_runtime/classic_campaign_package_installer.gd"
)
const AdapterScript = preload(
	"res://scripts/classic_runtime/classic_godot_command_adapter.gd"
)
const PRODUCER_FIXTURE := \
	"res://scripts/classic_runtime/tests/fixtures/providence_authoritative_export"
const CAMPAIGN_NAME := "providence_authoritative_export"

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
		"user://classic-producer-materialization-%d" % Time.get_ticks_msec()
	)
	var installer = InstallerScript.new()
	installer._remove_directory(test_root)
	var campaigns_directory := test_root.path_join("Campaigns")
	var install_result: Dictionary = installer.install_export(
		PRODUCER_FIXTURE,
		campaigns_directory
	)
	_expect_equal(
		install_result.get("status"),
		"ok",
		"unmodified producer fixture installs through the package lifecycle"
	)
	if str(install_result.get("status", "")) != "ok":
		_finish()
		return

	Paths.campaignsfolderpath = campaigns_directory.replace("\\", "/").trim_suffix("/") + "/"
	GameGlobal.set_current_campaign(CAMPAIGN_NAME)
	GameGlobal.player_allies.clear()
	var resources: CampaignResources = NodeAccess.__Resources()
	resources.load_campaign_ressources(CAMPAIGN_NAME)
	_expect(
		resources.items_book.has("Classic Item 901"),
		"normal campaign resources load the producer shop item"
	)
	_expect(
		resources.items_book.has("Classic Item 902"),
		"normal campaign resources load the producer scenario weapon"
	)
	_expect(
		resources.crea_book.has("Classic Monster 1"),
		"normal campaign resources load the producer monster"
	)
	if not resources.items_book.has("Classic Item 902") \
			or not resources.crea_book.has("Classic Monster 1"):
		_finish()
		return

	var blade: Dictionary = resources.items_book["Classic Item 902"]
	_expect_equal(blade.get("name"), "Providence Blade", "producer weapon keeps its authored name")
	_expect_equal(blade.get("classicItemId"), 902, "producer weapon keeps its Classic identity")
	_expect_equal(blade.get("type"), "Dagger", "producer weapon maps to a native item type")
	_expect_equal(
		blade.get("weapon_dmg", {}).get("Physical"),
		[1.0, 6.0],
		"producer weapon maps to a native damage range"
	)

	var campaign_directory := campaigns_directory.path_join(CAMPAIGN_NAME)
	var bundle = BundleScript.new()
	_expect(bundle.load_from_directory(campaign_directory), "installed producer bundle loads")
	if not bundle.last_error.is_empty():
		_finish()
		return
	var ally_action := _find_ally_action(bundle.documents.get("scripts", {}))
	_expect(not ally_action.is_empty(), "producer trigger contains an authored ally action")
	if ally_action.is_empty():
		_finish()
		return
	var monster_id := int(ally_action.get("id", 0))
	var monster: Dictionary = bundle.get_monster(monster_id)
	var add_result: Dictionary = await AdapterScript.new().execute_command(
		"add_party_ally",
		{"monsterId": monster_id, "monster": monster}
	)
	_expect_equal(add_result.get("monsterId"), 1, "authored ally action targets the producer monster")
	_expect_equal(GameGlobal.player_allies.size(), 1, "producer monster joins the native ally list")
	if GameGlobal.player_allies.is_empty():
		_finish()
		return

	var ally: Creature = GameGlobal.player_allies[0]
	_expect_equal(ally.bestiary_key, "Classic Monster 1", "ally keeps its native resource key")
	_expect_equal(ally.classic_monster_id, 1, "ally keeps its Classic record identity")
	_expect_equal(ally.inventory.size(), 1, "ally receives its producer-authored inventory")
	var equipped_blade := _inventory_item(ally.inventory, "Providence Blade")
	_expect_equal(equipped_blade.get("classicItemId"), 902, "ally carries the producer weapon")
	_expect_equal(equipped_blade.get("equipped"), 1, "ally equips the producer weapon")
	var active_weapon_id: int = (
		int(ally.current_melee_weapons[0].get("classicItemId"))
		if not ally.current_melee_weapons.is_empty()
		else 0
	)
	_expect_equal(
		active_weapon_id,
		902,
		"producer weapon becomes the ally's active melee weapon"
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

	GameGlobal.player_allies.clear()
	var restored_ally: Creature = GameGlobal.combatCreatureGD.new()
	_expect(
		restored_ally.initialize_from_saved_ally_dict(saved_value),
		"normal native ally loader restores the producer monster"
	)
	GameGlobal.add_npc_ally(restored_ally)
	_expect_equal(restored_ally.name, "Sentinel Companion", "ally display name survives save/load")
	_expect_equal(restored_ally.stats.get("curHP"), 17, "ally health survives save/load")
	_expect_equal(restored_ally.money, [23, 2, 1], "ally money survives save/load")
	_expect(not restored_ally.joins_combat, "ally combat preference survives save/load")
	_expect_equal(restored_ally.classic_monster_id, 1, "ally identity survives save/load")
	var restored_blade := _inventory_item(restored_ally.inventory, "Providence Blade")
	_expect_equal(restored_blade.get("classicItemId"), 902, "carried weapon survives ally save/load")
	_expect_equal(restored_blade.get("equipped"), 1, "equipped weapon survives ally save/load")
	_expect_equal(
		restored_ally.current_melee_weapons[0].get("classicItemId") \
			if not restored_ally.current_melee_weapons.is_empty() else 0,
		902,
		"restored producer weapon remains active"
	)
	_finish()


func _find_ally_action(scripts: Dictionary) -> Dictionary:
	for trigger_value: Variant in scripts.get("triggers", []):
		if not (trigger_value is Dictionary):
			continue
		for action_value: Variant in trigger_value.get("actions", []):
			if action_value is Dictionary and abs(int(action_value.get("rawCode", 0))) == 89:
				return action_value
	return {}


func _inventory_item(inventory: Array, item_name: String) -> Dictionary:
	for item_value: Variant in inventory:
		if item_value is Dictionary and str(item_value.get("name", "")) == item_name:
			return item_value
	return {}


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
		print("Classic producer materialization acceptance smoke passed.")
		get_tree().quit(0)
		return
	printerr(
		"Classic producer materialization acceptance smoke failed: %s" \
			% "; ".join(failures)
	)
	get_tree().quit(1)
