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
	var fixture_directory := _prepare_inventory_fixture(installer)
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
		resources.items_book.has("Classic Item 901"),
		"normal campaign resources load the generated scenario item"
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
	_expect(
		AdapterScript.new().party_has_classic_ally({"monsterNameId": 1}, [restored_ally]),
		"restored producer ally satisfies a Classic name-identity check"
	)
	_finish()


func _prepare_inventory_fixture(installer: Object) -> String:
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
