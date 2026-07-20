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
	var install_result: Dictionary = installer.install_export(PRODUCER_FIXTURE, test_root)
	_expect_equal(install_result.get("status"), "ok", "producer fixture installs for ally smoke")
	if str(install_result.get("status", "")) != "ok":
		_finish()
		return

	var campaign_name := PRODUCER_FIXTURE.get_file()
	var campaign_directory := test_root.path_join(campaign_name)
	Paths.campaignsfolderpath = test_root.replace("\\", "/").trim_suffix("/") + "/"
	GameGlobal.set_current_campaign(campaign_name)
	GameGlobal.player_allies.clear()
	var resources: CampaignResources = NodeAccess.__Resources()
	resources.load_campaign_ressources(campaign_name)
	_expect(
		resources.crea_book.has("Classic Monster 1"),
		"normal campaign resources load the generated Bestiary entry"
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
	_expect(
		AdapterScript.new().party_has_classic_ally({"monsterNameId": 1}, [restored_ally]),
		"restored producer ally satisfies a Classic name-identity check"
	)
	_finish()


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
