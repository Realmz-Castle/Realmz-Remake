extends Node

const ClassicAdapterScript = preload(
	"res://scripts/scenario_runtime/godot/scenario_godot_services.gd"
)
const ClassicInventoryRulesScript = preload(
	"res://scripts/classic_runtime/classic_inventory_rules.gd"
)
const ClassicMagicResistanceScript = preload(
	"res://scripts/classic_runtime/classic_magic_resistance.gd"
)
const ClassicIdentifyScript = preload(
	"res://scripts/classic_runtime/classic_core_identify_spell.gd"
)

var failures: Array[String] = []
var assertions := 0


class LegacyInventoryCarrier:
	extends RefCounted
	var inventory: Array = []


func _ready() -> void:
	call_deferred("_run_smoke")


func _run_smoke() -> void:
	await get_tree().process_frame
	var resources: CampaignResources = NodeAccess.__Resources()
	_expect(
		resources.load_item_resources("res://shared_assets/items/"),
		"shared item catalog loads for creature inventory smoke",
	)
	_test_inventory_identity_and_ownership()
	_test_equipment_handoff_and_slots()
	_test_charge_weight_and_consumption()
	_test_equipment_stats_and_traits()
	_test_scripted_item_hook_integration()
	_test_classic_legacy_inventory_boundary()
	_test_classic_equipment_capture()
	_test_classic_catalog_item_flows(resources)
	_test_weight_limit()
	_finish()


func _test_inventory_identity_and_ownership() -> void:
	var source := _creature("Item Source")
	var destination := _creature("Item Destination")
	var dagger := GameGlobal.generate_item("Dagger")
	_expect(source.add_inventory_item(dagger), "catalog item enters creature inventory")
	var dagger_instance := source.get_item_instance(dagger)
	_expect(dagger_instance != null, "creature inventory owns an ItemInstance")
	_expect(
		source.item_inventory[0] == dagger_instance,
		"authoritative inventory retains the exact ItemInstance",
	)
	_expect(
		source.inventory[0] == dagger_instance,
		"deprecated inventory property aliases the authoritative ItemInstance array",
	)
	_expect(
		not source.add_inventory_item(dagger_instance),
		"the same ItemInstance cannot be added twice to one creature",
	)

	_expect(
		source.add_inventory_item_copy(dagger),
		"explicit item copy adds a second catalog item",
	)
	var copied_instance := source.item_inventory[1]
	_expect(
		copied_instance.instance_id != dagger_instance.instance_id,
		"copied and split items receive distinct instance identities",
	)
	_expect(
		source.remove_inventory_item(copied_instance),
		"one of two matching items can be removed by identity",
	)
	_expect(
		source.get_item_instance(dagger) == dagger_instance,
		"removing a matching copy leaves the original instance",
	)

	var original_id := dagger_instance.instance_id
	_expect(
		source.transfer_inventory_item_to(destination, dagger),
		"creature transfers an existing ItemInstance atomically",
	)
	_expect(
		destination.item_inventory[0] == dagger_instance
			and destination.item_inventory[0].instance_id == original_id,
		"inventory transfer preserves exact object and instance ID",
	)
	_expect(
		destination.drop_inventory_item(dagger),
		"dropping removes the owned ItemInstance",
	)
	_expect(
		destination.item_inventory.is_empty() and destination.inventory.is_empty(),
		"drop empties both stable inventory property names",
	)


func _test_equipment_handoff_and_slots() -> void:
	var melee_user := _creature("Melee User")
	var first_dagger := GameGlobal.generate_item("Dagger")
	var second_dagger := GameGlobal.generate_item("Dagger")
	_expect(melee_user.add_inventory_item(first_dagger), "first melee weapon is carried")
	_expect(melee_user.add_inventory_item(second_dagger), "second melee weapon is carried")
	var first_instance := melee_user.get_item_instance(first_dagger)
	var second_instance := melee_user.get_item_instance(second_dagger)
	_expect(melee_user.equip_item(first_dagger), "first melee weapon equips")
	_expect(
		melee_user.current_melee_weapon_instances == [first_instance],
		"melee combat handoff uses the inventory ItemInstance",
	)
	_expect(
		melee_user.current_melee_weapons[0] == first_instance,
		"deprecated melee property returns the authoritative ItemInstance",
	)
	_expect(
		melee_user.get_melee_weapon_for_next_attack() == first_instance,
		"equipped player melee attacks hand off the authoritative ItemInstance",
	)
	_expect(
		not melee_user.equip_item(second_dagger),
		"second one-handed weapon is rejected without dual wield",
	)
	melee_user.can_dual_wield = true
	_expect(melee_user.equip_item(second_dagger), "dual wield permits the second weapon")
	_expect(
		melee_user.current_melee_weapon_instances == [first_instance, second_instance],
		"dual-wield handoff retains both exact inventory instances",
	)
	_expect(
		not melee_user.remove_inventory_item(first_dagger),
		"equipped inventory cannot be removed without an explicit unequip",
	)
	_expect(
		not melee_user.transfer_inventory_item_to(
			_creature("Equipped Transfer Target"),
			first_dagger,
		),
		"equipped inventory cannot be transferred to another owner",
	)
	_expect(melee_user.unequip_item(first_dagger), "melee weapon unequips")
	_expect(
		not first_instance.equipped
			and melee_user.current_melee_weapon_instances == [second_instance],
		"unequip clears domain equipment state without disturbing the other weapon",
	)

	var ranged_user := _creature("Ranged User")
	var bow := GameGlobal.generate_item("Bow")
	var arrows := GameGlobal.generate_item("Quiver of Arrows")
	_expect(ranged_user.add_inventory_item(bow), "ranged weapon is carried")
	_expect(ranged_user.add_inventory_item(arrows), "ammunition is carried")
	var bow_instance := ranged_user.get_item_instance(bow)
	var arrow_instance := ranged_user.get_item_instance(arrows)
	_expect(ranged_user.equip_item(bow), "two-handed ranged weapon equips")
	_expect(ranged_user.equip_item(arrows), "ammunition equips alongside ranged weapon")
	_expect(
		ranged_user.current_range_weapon_instance == bow_instance,
		"ranged combat handoff uses the inventory ItemInstance",
	)
	_expect(
		ranged_user.current_ammo_weapon_instance == arrow_instance,
		"ammunition handoff uses the inventory ItemInstance",
	)
	_expect(
		ranged_user.current_range_weapon == bow_instance
			and ranged_user.current_ammo_weapon == arrow_instance,
		"deprecated ranged and ammunition properties preserve exact identities",
	)


func _test_charge_weight_and_consumption() -> void:
	var consumer := _creature("Consumable User")
	var potion := GameGlobal.generate_item("Muscle Potion")
	_expect(consumer.add_inventory_item(potion), "charged consumable is carried")
	var potion_instance := consumer.get_item_instance(potion)
	_expect_equal(potion_instance.charges, 3, "initial charges live on ItemInstance")
	_expect_equal(
		consumer.item_get_weight(potion_instance),
		9,
		"per-charge weight is calculated from authoritative charges",
	)
	var adapter := ClassicAdapterScript.new()
	var first_use: Dictionary = adapter.consume_complex_item(consumer, potion)
	_expect_equal(first_use.get("remainingCharges"), 2, "item use consumes one charge")
	_expect_equal(potion_instance.charges, 2, "charge use updates ItemInstance state")
	_expect_equal(
		consumer.item_get_weight(potion_instance),
		6,
		"charge consumption immediately reduces carried weight",
	)
	adapter.consume_complex_item(consumer, potion)
	var final_use: Dictionary = adapter.consume_complex_item(consumer, potion)
	_expect(bool(final_use.get("removed", false)), "delete-on-empty removes consumed item")
	_expect(
		consumer.get_item_instance(potion) == null
			and not consumer.item_inventory.has(potion_instance),
		"consumed instance is absent from both inventory APIs",
	)


func _test_equipment_stats_and_traits() -> void:
	var armor_user := _creature("Armor User")
	var armor := GameGlobal.generate_item("Leather Armor")
	var baseline_evasion: float = float(armor_user.get_stat("EvasionMelee"))
	_expect(armor_user.add_inventory_item(armor), "stat-bearing armor is carried")
	_expect(armor_user.equip_item(armor), "stat-bearing armor equips")
	_expect_equal(
		armor_user.get_stat("EvasionMelee"),
		baseline_evasion + 9,
		"equipped item applies its stat once",
	)
	armor_user.recalculate_stats()
	_expect_equal(
		armor_user.get_stat("EvasionMelee"),
		baseline_evasion + 9,
		"recalculation does not apply equipment stats twice",
	)
	_expect(armor_user.unequip_item(armor), "stat-bearing armor unequips")
	_expect_equal(
		armor_user.get_stat("EvasionMelee"),
		baseline_evasion,
		"unequip removes the equipment stat",
	)

	var trait_user := _creature("Trait User")
	var trait_weapon := GameGlobal.generate_item("Dagger of Anti Magic +1")
	var baseline_traits := trait_user.traits.size()
	_expect(trait_user.add_inventory_item(trait_weapon), "trait-bearing weapon is carried")
	_expect(trait_user.equip_item(trait_weapon), "trait-bearing weapon equips")
	_expect_equal(
		trait_user.traits.size(),
		baseline_traits + 1,
		"equipping adds the item trait once",
	)
	_expect(trait_user.unequip_item(trait_weapon), "trait-bearing weapon unequips")
	_expect_equal(
		trait_user.traits.size(),
		baseline_traits,
		"unequipping removes the item trait",
	)


func _test_scripted_item_hook_integration() -> void:
	var hook_user := _creature("Scripted Item User")
	var scripted_armor := GameGlobal.generate_item("The Chastised Warrior -5")
	_expect(hook_user.add_inventory_item(scripted_armor), "scripted native item is carried")
	var scripted_instance := hook_user.get_item_instance(scripted_armor)
	var resources: CampaignResources = NodeAccess.__Resources()
	var definition := resources.get_item_definition(scripted_instance)
	_expect(
		scripted_instance != null
			and definition != null
			and not scripted_instance.state_data().has("_on_equipping")
			and not scripted_instance.state_data().has("_on_unequipping"),
		"scripted item instance contains no compiled hooks",
	)
	_expect(
		hook_user.equip_item(scripted_instance),
		"definition-backed equipping hook runs through the stable item API",
	)
	_expect(
		definition.description_for(scripted_instance).contains("foul prison"),
		"legacy hook mutation is retained as serializable instance state",
	)
	_expect(
		not hook_user.unequip_item(scripted_instance),
		"definition-backed unequipping hook preserves the cursed-item veto",
	)
	_expect(
		scripted_instance.equipped,
		"vetoed scripted unequip leaves authoritative equipment state intact",
	)
	_expect(
		hook_user.unequip_item(scripted_instance, false),
		"explicit compatibility force-unequip bypasses the scripted veto",
	)


func _test_classic_legacy_inventory_boundary() -> void:
	var legacy_target := LegacyInventoryCarrier.new()
	legacy_target.inventory = [
		{"name": "Ward Ring", "equipped": 1, "classicMagicResistance": 10},
		{"name": "Cursed Charm", "equipped": 1, "classicMagicResistance": -4},
		{"name": "Carried Ward", "equipped": 0, "classicMagicResistance": 90},
	]
	_expect_equal(
		ClassicMagicResistanceScript.equipped_modifier(legacy_target),
		6,
		"Classic old-campaign adapter reads signed worn-item resistance",
	)
	var identify_target := LegacyInventoryCarrier.new()
	identify_target.inventory = [
		{"name": "Unknown sword", "is_identified": 0},
		{"name": "Known ring", "is_identified": 1},
	]
	var identify_spell := ClassicIdentifyScript.new()
	_expect_equal(
		identify_spell.identify_targets([identify_target]),
		2,
		"Classic old-campaign Identify Objects visits every carried item",
	)
	_expect_equal(
		identify_target.inventory.map(
			func(item: Dictionary) -> int: return int(item["is_identified"])
		),
		[1, 1],
		"Classic old-campaign Identify Objects updates dictionary input in place",
	)
	var resources: CampaignResources = NodeAccess.__Resources()
	var legacy_catalog_view := resources.legacy_item_view_for_adapter(
		resources.create_item_instance("Dagger")
	)
	legacy_catalog_view.erase("_item_instance")
	legacy_catalog_view.erase("instanceId")
	legacy_catalog_view["classicItemId"] = 805
	var imported_catalog_item: ItemInstance = resources.import_item_instance(
		legacy_catalog_view
	)
	_expect(
		imported_catalog_item != null
			and resources.item_classic_ids(imported_catalog_item)[0] == 805,
		"old-save per-instance Classic identity takes precedence over shared definition aliases",
	)


func _test_classic_equipment_capture() -> void:
	var character := _creature("Classic Equipment User")
	var dagger := GameGlobal.generate_item("Dagger")
	_expect(character.add_inventory_item(dagger), "Classic capture fixture carries a weapon")
	_expect(character.equip_item(dagger), "Classic capture fixture equips its weapon")
	var original_instance := character.get_item_instance(dagger)
	var pooled_money := [0, 0, 0]
	var capture: Dictionary = ClassicInventoryRulesScript.capture_party_equipment(
		[character],
		pooled_money,
	)
	_expect(bool(capture.get("active", false)), "Classic equipment capture succeeds")
	_expect(
		character.item_inventory.is_empty() and character.inventory.is_empty(),
		"Classic equipment capture clears both inventory representations",
	)
	var restore: Dictionary = ClassicInventoryRulesScript.restore_party_equipment(
		[character],
		pooled_money,
		capture,
	)
	_expect(bool(restore.get("restored", false)), "Classic equipment restore succeeds")
	var restored_instance: ItemInstance = character.item_inventory[0]
	_expect(
		restored_instance == original_instance
			and restored_instance.instance_id == original_instance.instance_id,
		"Classic equipment capture and restore preserve exact item identity",
	)
	_expect(
		restored_instance.equipped
			and character.current_melee_weapon_instances == [restored_instance],
		"Classic equipment restore rebuilds authoritative combat handoff",
	)


func _test_classic_catalog_item_flows(resources: CampaignResources) -> void:
	const campaign_id := "scenario-city-of-bywater"
	var shared_dagger := resources.create_classic_item_instance(1)
	_expect(
		shared_dagger != null
			and resources.get_item_definition(shared_dagger).display_name == "Dagger"
			and resources.item_classic_ids(shared_dagger).has(1),
		"Classic core item mapping is bound once as shared definition metadata",
	)
	for reward_id: int in [210, 434]:
		var reward_item := resources.create_classic_item_instance(reward_id)
		_expect(
			reward_item != null
				and resources.item_classic_ids(reward_item).has(reward_id)
				and resources.get_item_definition(reward_item).has_classic_item_id(
					reward_id
				),
			"Classic reward %d retains exact identity in its definition"
			% reward_id,
		)
	_expect(
		resources.load_item_resources(
			"res://Campaigns/City of Bywater/Items/",
			campaign_id,
		),
		"City of Bywater campaign item definitions load through the shared catalog",
	)
	var definition := resources.resolve_classic_item_definition(807)
	_expect(
		definition != null and definition.classic_item_ids() == [807],
		"City of Bywater item 807 resolves only from definition metadata",
	)
	var classic_item := resources.create_classic_item_instance(807, {"charges": 3})
	var holder := _creature("Classic Catalog User")
	_expect(
		classic_item != null and holder.add_inventory_item(classic_item),
		"Classic catalog factory creates a native inventory instance",
	)
	_expect(
		ClassicInventoryRulesScript.party_has_classic_item([holder], [807]),
		"Classic possession checks exact definition identity",
	)
	var mutation: Dictionary = ClassicInventoryRulesScript.alter_classic_items(
		[holder],
		[807],
		1,
		2,
		-1,
	)
	_expect_equal(mutation.get("changed"), 1, "Classic charge mutation finds the native instance")
	_expect_equal(classic_item.charges, 2, "Classic charge mutation updates instance state")

	var adapter := ClassicAdapterScript.new()
	var treasure: Dictionary = adapter.build_treasure_delivery_from_catalog(
		{
			"treasure": {
				"itemIds": [807],
				"gold": 2,
				"gems": 1,
				"jewelry": 0,
				"exp": 9,
			},
		},
		resources,
	)
	var treasure_items: Array = treasure.get("items", [])
	_expect(
		treasure_items.size() == 1
			and treasure_items[0] is ItemInstance
			and treasure_items[0].definition_id == classic_item.definition_id
			and treasure_items[0].instance_id != classic_item.instance_id,
		"Classic treasure delivery creates a distinct catalog-backed instance",
	)
	var shop_result: Dictionary = adapter.build_shop_inventory_from_catalog(
		{
			"shop": {
				"itemIds": [807],
				"quantities": [2],
				"inflation": 125,
			},
			"acceptRanges": [800, 810, 900, 910],
		},
		resources,
	)
	var shop: Dictionary = shop_result.get("shop", {})
	var weapon_stock: Array = shop.get("Weapons", [])
	_expect(
		weapon_stock.size() == 1
			and weapon_stock[0][0] is ItemInstance
			and weapon_stock[0][0].definition_id == classic_item.definition_id,
		"Classic shop stock is catalog-backed instead of a copied dictionary",
	)
	_expect_equal(
		shop.get("classic_accept_ranges"),
		[800, 810, 900, 910],
		"Classic shop acceptance retains numeric definition ranges",
	)


func _test_weight_limit() -> void:
	var carrier := _creature("Weight User")
	var resources: CampaignResources = NodeAccess.__Resources()
	var too_heavy := resources.generate_item_from_catalog("Dagger")
	too_heavy.erase("definitionId")
	too_heavy.erase("instanceId")
	too_heavy.erase("_item_instance")
	for classic_field: String in [
		"classicItemId",
		"classicItemIds",
		"classicItemCategory",
		"classicRecordId",
		"classicRecord",
		"classicMaterialization",
		"classicItemType",
		"classicIconId",
		"classicSoundId",
		"classicMagicResistance",
	]:
		too_heavy.erase(classic_field)
	too_heavy["KEY"] = "M6 Overweight Legacy Fixture"
	too_heavy["name"] = "M6 Overweight Legacy Fixture"
	too_heavy["weight"] = 1201
	_expect(
		not carrier.add_inventory_item(too_heavy),
		"old-campaign dictionary import is rejected beyond carrying limit",
	)
	_expect(
		carrier.item_inventory.is_empty() and carrier.inventory.is_empty(),
		"weight rejection does not partially mutate either inventory",
	)


func _creature(creature_name: String) -> Creature:
	var creature: Creature = GameGlobal.combatCreatureGD.new()
	creature.name = creature_name
	return creature


func _expect(condition: bool, description: String) -> void:
	assertions += 1
	if condition:
		print("PASS: %s" % description)
		return
	failures.append(description)
	push_error("FAIL: %s" % description)


func _expect_equal(actual: Variant, expected: Variant, description: String) -> void:
	_expect(
		actual == expected,
		"%s (expected %s, got %s)" % [description, expected, actual],
	)


func _finish() -> void:
	if failures.is_empty():
		print("Creature item-instance smoke passed: %d assertions." % assertions)
		get_tree().quit(0)
		return
	printerr("Creature item-instance smoke failed: %s" % "; ".join(failures))
	get_tree().quit(1)
