extends Node

const ClassicItemBehaviorsScript = preload(
	"res://scripts/classic_runtime/classic_item_behaviors.gd"
)
const ClassicTorchButtonScene = preload(
	"res://scenes/UI/HUD/ClassicTorch/classic_torch_button.tscn"
)

var _failures: Array[String] = []


class TorchHolder:
	extends RefCounted

	var items: Array[ItemInstance] = []

	func inventory_instances() -> Array[ItemInstance]:
		return items.duplicate()

	func can_use_inventory_item(_item: Variant) -> bool:
		return true

	func remove_inventory_item(item: Variant, _allow_equipped := false) -> bool:
		var index := items.find(item)
		if index < 0:
			return false
		items.remove_at(index)
		return true


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	await get_tree().process_frame
	if not UI.main_menu.initial_profile_ready:
		await UI.main_menu.initial_profile_loaded
	var resources: CampaignResources = NodeAccess.__Resources()
	_expect(resources != null, "campaign resources are available")
	if resources == null:
		_finish()
		return
	_expect(
		resources.load_item_resources("res://shared_assets/items/"),
		"shared item catalog loads",
	)
	var torch: ItemInstance = resources.create_classic_item_instance(
		805,
		{"charges": 2},
	)
	_expect(torch != null, "Classic item 805 creates an item instance")
	if torch != null:
		var definition: ItemDefinition = resources.get_item_definition(torch)
		_expect(definition != null, "Torch instance resolves its definition")
		if definition != null:
			_expect_equal(
				definition.definition_id,
				"shared:Torch",
				"stock Classic Torch resolves by explicit shared identity",
			)
			_expect(
				definition.has_use("field"),
				"runtime loading attaches the Torch field-use behavior",
			)
		var previous_condition := GameGlobal.classic_light_condition
		var previous_time := GameGlobal.light_time
		var previous_power := GameGlobal.light_power
		GameGlobal.classic_light_condition = 0
		GameGlobal.light_time = 0
		GameGlobal.light_power = 0
		var first_result: Dictionary = resources.run_item_hook(
			torch,
			"field_use",
			[null],
		)
		_expect(bool(first_result.get("ok", false)), "first Torch use succeeds")
		_expect_equal(torch.charges, 1, "runtime hook synchronizes the consumed charge")
		_expect_equal(
			GameGlobal.classic_light_condition,
			119,
			"runtime hook applies native power-four Classic light",
		)
		GameGlobal.classic_light_condition = 149
		GameGlobal._sync_classic_light_state()
		var second_result: Dictionary = resources.run_item_hook(
			torch,
			"field_use",
			[null],
		)
		_expect(bool(second_result.get("ok", false)), "second Torch use succeeds")
		_expect_equal(torch.charges, 0, "runtime hook consumes the last charge")
		_expect_equal(
			GameGlobal.classic_light_condition,
			149,
			"Torch cannot shorten stronger existing illumination",
		)
		var empty_result: Dictionary = resources.run_item_hook(
			torch,
			"field_use",
			[null],
		)
		_expect_equal(
			empty_result.get("value"),
			false,
			"runtime hook rejects an empty Torch",
		)
		_expect_equal(torch.charges, 0, "empty Torch remains empty")
		GameGlobal.classic_light_condition = previous_condition
		GameGlobal.light_time = previous_time
		GameGlobal.light_power = previous_power
	_test_party_torch_control(resources)
	_test_existing_campaign_torch(resources)
	_finish()


func _test_party_torch_control(resources: CampaignResources) -> void:
	var button: ClassicTorchButton = ClassicTorchButtonScene.instantiate()
	add_child(button)
	button.sync_status(false, 0, false, false)
	_expect(not button.visible, "Torch control stays hidden outside Classic campaigns")
	button.sync_status(true, 0, true, true)
	_expect(button.visible and not button.disabled, "a carried Torch enables its control")
	_expect_equal(
		button.fuel_segment_count(),
		2,
		"the unlit control uses Classic's two-marker Torch indication",
	)
	_expect_equal(
		button.flame_frame_count(),
		8,
		"the control exposes all eight Classic flame frames",
	)
	button.sync_status(true, 119, false, false)
	_expect(
		button.visible and button.disabled,
		"Shine remains visible when no physical Torch can be activated",
	)
	_expect_equal(
		button.fuel_segment_count(),
		4,
		"power-four light uses Classic's four fuel markers",
	)
	_expect_equal(
		button.flame_y(),
		7,
		"the flame position follows the remaining Classic light condition",
	)
	button.queue_free()

	var holder := TorchHolder.new()
	var torch := resources.create_classic_item_instance(805, {"charges": 1})
	_expect(torch != null, "HUD activation fixture creates a Classic Torch")
	if torch == null:
		return
	holder.items.append(torch)
	var selection := ClassicItemBehaviorsScript.find_party_torch(
		[holder],
		resources,
	)
	_expect_equal(
		selection.get("item"),
		torch,
		"the HUD resolver finds item 805 across party inventories",
	)
	var previous_condition := GameGlobal.classic_light_condition
	var previous_time := GameGlobal.light_time
	var previous_power := GameGlobal.light_power
	GameGlobal.classic_light_condition = 0
	GameGlobal.light_time = 0
	GameGlobal.light_power = 0
	var result := ClassicItemBehaviorsScript.activate_party_torch(
		[holder],
		resources,
	)
	_expect(bool(result.get("ok", false)), "the HUD path activates a party Torch")
	_expect_equal(
		GameGlobal.classic_light_condition,
		119,
		"the HUD path executes the same power-four field-use hook",
	)
	_expect_equal(torch.charges, 0, "the HUD path consumes the Torch charge")
	_expect(
		holder.items.is_empty(),
		"the HUD path removes a delete-on-empty Torch from its holder",
	)
	_expect(
		ClassicItemBehaviorsScript.find_party_torch([holder], resources).is_empty(),
		"the exhausted Torch no longer enables the HUD control",
	)
	GameGlobal.classic_light_condition = previous_condition
	GameGlobal.light_time = previous_time
	GameGlobal.light_power = previous_power


func _test_existing_campaign_torch(resources: CampaignResources) -> void:
	_expect(
		resources.load_item_resources(
			"res://Campaigns/Assault on Giant Mountain (Classic)/Items/",
		),
		"an existing pre-materialized Classic item book loads",
	)
	var torch: ItemInstance = resources.create_classic_item_instance(
		805,
		{"charges": 1},
	)
	_expect(torch != null, "existing campaign item 805 creates an item instance")
	if torch == null:
		return
	var definition: ItemDefinition = resources.get_item_definition(torch)
	_expect(
		definition != null and definition.definition_id.begins_with("classic:"),
		"the campaign-local Torch overrides the shared fallback",
	)
	if definition != null:
		_expect(
			definition.has_use("field"),
			"runtime enrichment upgrades an already-installed Classic Torch",
		)
		_expect_equal(
			definition.classic_materialization().get("status"),
			"complete",
			"the installed Torch no longer reports its implemented fields as blocked",
		)
	var previous_condition := GameGlobal.classic_light_condition
	var previous_time := GameGlobal.light_time
	var previous_power := GameGlobal.light_power
	GameGlobal.classic_light_condition = 0
	GameGlobal.light_time = 0
	GameGlobal.light_power = 0
	var result: Dictionary = resources.run_item_hook(
		torch,
		"field_use",
		[null],
	)
	_expect(bool(result.get("ok", false)), "installed campaign Torch use succeeds")
	_expect_equal(torch.charges, 0, "installed campaign Torch consumes its charge")
	_expect_equal(
		GameGlobal.classic_light_condition,
		119,
		"installed campaign Torch reads power four from its preserved record",
	)
	GameGlobal.classic_light_condition = previous_condition
	GameGlobal.light_time = previous_time
	GameGlobal.light_power = previous_power


func _finish() -> void:
	if _failures.is_empty():
		print("Classic Torch item smoke passed.")
		get_tree().quit(0)
		return
	for failure: String in _failures:
		printerr("Classic Torch item smoke: %s" % failure)
	get_tree().quit(1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _expect_equal(actual: Variant, expected: Variant, message: String) -> void:
	_expect(
		actual == expected,
		"%s; expected %s, got %s" % [message, expected, actual],
	)
