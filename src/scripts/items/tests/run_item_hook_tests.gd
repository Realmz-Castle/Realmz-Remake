extends SceneTree

const ItemCatalogScript = preload("res://scripts/items/item_catalog.gd")
const ItemHookRuntimeScript = preload(
	"res://scripts/items/item_hook_runtime.gd"
)
const ClassicItemBehaviorsScript = preload(
	"res://scripts/classic_runtime/classic_item_behaviors.gd"
)

var _assertions := 0
var _failures: Array[String] = []


func _init() -> void:
	_test_stable_hook_calls()
	_test_classic_torch_hook()
	_test_traits_and_custom_spell()
	_test_invalid_source_is_reported()
	_finish()


func _test_stable_hook_calls() -> void:
	var catalog := _catalog_with_definition("Scripted", _scripted_definition())
	var definition := catalog.get_definition("shared:Scripted")
	var instance := catalog.create_instance(
		definition.definition_id,
		{"charges": 5},
	)
	var runtime := ItemHookRuntimeScript.new()
	var view := {
		"name": "Scripted",
		"charges": 5,
	}
	var cases := [
		["equip", [null], "equip:shared:Scripted"],
		["unequip", [null], "unequip:shared:Scripted"],
		["field_use", [null], "field:shared:Scripted"],
		["combat_use", [null], "combat:shared:Scripted"],
		["drop", [null], false],
		["melee_accuracy", [null, null], 0.75],
		["melee_attack", [null, null, true, 2.0], {"Physical": 12}],
	]
	for case_value: Variant in cases:
		var case: Array = case_value
		var result := runtime.invoke(
			definition,
			instance,
			str(case[0]),
			case[1],
			view,
		)
		_expect(
			bool(result.get("ok", false)),
			"%s hook compiles and executes: %s"
			% [case[0], result.get("errors", [])],
		)
		_expect(bool(result.get("handled", false)), "%s hook is handled" % case[0])
		_expect_equal(
			result.get("value"),
			case[2],
			"%s hook preserves its return semantics" % case[0],
		)
	_expect_equal(
		instance.state_value("lastHook"),
		"combat",
		"hook receives the exact ItemInstance",
	)
	_expect_equal(
		view.get("definitionSeen"),
		definition.definition_id,
		"legacy item argument can observe the resolved definition",
	)
	_expect(
		not _contains_object(definition.to_dictionary()),
		"definition retains source descriptors without compiled scripts",
	)
	_expect(
		not _contains_object(instance.state_data()),
		"instance state contains no compiled hook objects",
	)


func _test_classic_torch_hook() -> void:
	var source := ClassicItemBehaviorsScript.enrich_definition_source({
		"name": "Core Torch",
		"type": "Supplies",
		"img_ptr": "ITEM_Test",
		"sound": "",
		"classicItemId": 805,
		"charges": 6,
		"charges_max": 6,
		"delete_on_empty": 1,
	})
	_expect(
		source.has("_on_field_use_source"),
		"explicit Classic item 805 receives the Torch field-use hook",
	)
	var catalog := _catalog_with_definition("Core Torch", source)
	var definition := catalog.get_definition("shared:Core%20Torch")
	_expect(
		definition.has_use("field"),
		"the enriched Torch definition exposes a field-use action",
	)
	var same_name := ClassicItemBehaviorsScript.enrich_definition_source({
		"name": "Torch",
		"classicItemId": 877,
	})
	_expect(
		not same_name.has("_on_field_use_source"),
		"a same-name item without Classic identity 805 receives no Torch behavior",
	)
	var authored_hook := ClassicItemBehaviorsScript.enrich_definition_source({
		"name": "Scenario Torch",
		"classicItemId": 805,
		"_on_field_use_source": "return 'scenario behavior'",
	})
	_expect_equal(
		authored_hook.get("_on_field_use_source"),
		"return 'scenario behavior'",
		"an authored scenario hook takes precedence over the stock Torch behavior",
	)


func _test_traits_and_custom_spell() -> void:
	var catalog := _catalog_with_definition("Traits", {
		"name": "Traits",
		"type": "Test",
		"img_ptr": "ITEM_Test",
		"sound": "",
		"traits": [
			["custom_trait", [3]],
		],
		"custom_trait_source": (
			"extends RefCounted\n"
			+ "var menuname := \"Custom Trait\"\n"
			+ "func _init(_value := 0):\n"
			+ "\tpass\n"
		),
		"melee_inflicted_traits": [
			["custom_inflicted_trait", [1], 0.5],
		],
		"custom_inflicted_trait_source": (
			"extends RefCounted\n"
			+ "var menuname := \"Custom Inflicted Trait\"\n"
			+ "func _init(_value := 0):\n"
			+ "\tpass\n"
		),
		"custom_spell_source": (
			"extends RefCounted\n"
			+ "var name := \"Item Test Spell\"\n"
		),
	})
	var definition := catalog.get_definition("shared:Traits")
	var runtime := ItemHookRuntimeScript.new()
	var traits := runtime.trait_bindings(definition)
	_expect(
		bool(traits.get("ok", false)),
		"resource and source-backed traits resolve through the definition",
	)
	_expect_equal(
		traits.get("bindings", []).size(),
		1,
		"source-backed equipped trait descriptor resolves",
	)
	var inflicted := runtime.trait_bindings(definition, true)
	_expect(bool(inflicted.get("ok", false)), "inflicted trait resolves")
	_expect_equal(
		inflicted.get("bindings", [])[0].get("chance"),
		0.5,
		"inflicted trait chance remains descriptor data",
	)
	var spell := runtime.custom_spell_script(definition)
	_expect(spell != null, "custom spell source compiles through the definition")
	_expect(
		runtime.custom_spell_script(definition) == spell,
		"compiled custom spell is cached outside domain data",
	)


func _test_invalid_source_is_reported() -> void:
	var catalog := _catalog_with_definition("Invalid Hook", {
		"name": "Invalid Hook",
		"type": "Test",
		"img_ptr": "ITEM_Test",
		"sound": "",
		"_on_field_use_source": "this is not valid gdscript !!!",
	})
	var definition := catalog.get_definition("shared:Invalid%20Hook")
	var instance := catalog.create_instance(definition.definition_id)
	var runtime := ItemHookRuntimeScript.new()
	var result := runtime.invoke(
		definition,
		instance,
		"field_use",
		[null],
		{"name": "Invalid Hook"},
	)
	_expect(not bool(result.get("ok", true)), "invalid hook source fails closed")
	_expect(
		str(result.get("errors", [])).contains("failed to compile"),
		"invalid hook reports definition-scoped compilation failure",
	)


func _scripted_definition() -> Dictionary:
	return {
		"name": "Scripted",
		"type": "Test",
		"img_ptr": "ITEM_Test",
		"sound": "",
		"charges": 5,
		"charges_max": 5,
		"_on_equipping_source": (
			"item['definitionSeen'] = definition.definition_id\n"
			+ "return 'equip:' + _definition.definition_id"
		),
		"_on_unequipping_source": (
			"return 'unequip:' + definition.definition_id"
		),
		"_on_field_use_source": (
			"instance.set_state_value('lastHook', 'field')\n"
			+ "return 'field:' + definition.definition_id"
		),
		"_on_combat_use_source": (
			"_instance.set_state_value('lastHook', 'combat')\n"
			+ "return 'combat:' + _definition.definition_id"
		),
		"_on_drop_source": "return false",
		"_calculate_melee_accuracy_source": "return 0.75",
		"_calculate_melee_attack_source": (
			"return {'Physical': 6 * int(crit_mult)}"
		),
	}


func _catalog_with_definition(key: String, source: Dictionary) -> ItemCatalog:
	var catalog := ItemCatalogScript.new()
	_expect(
		catalog.load_book(
			{key: source},
			"shared",
			"",
			"res://tests/item_hooks.json",
			{"ITEM_Test": true},
		),
		"%s definition loads: %s" % [key, catalog.last_errors],
	)
	return catalog


static func _contains_object(value: Variant) -> bool:
	if value is Object:
		return true
	if value is Array:
		for child: Variant in value:
			if _contains_object(child):
				return true
	if value is Dictionary:
		for child: Variant in value.values():
			if _contains_object(child):
				return true
	return false


func _expect(condition: bool, message: String) -> void:
	_assertions += 1
	if not condition:
		_failures.append(message)


func _expect_equal(actual: Variant, expected: Variant, message: String) -> void:
	_expect(
		actual == expected,
		"%s; expected %s, got %s" % [message, expected, actual],
	)


func _finish() -> void:
	if _failures.is_empty():
		print(
			(
				"ITEM_HOOK_RUNTIME PASS: %d assertions; stable hook calls, "
				+ "legacy arguments, traits, inflicted traits, custom spells, "
				+ "caching, and invalid-source diagnostics are verified."
			) % _assertions
		)
		quit(0)
		return
	for failure: String in _failures:
		printerr("ITEM_HOOK_RUNTIME FAIL: %s" % failure)
	printerr(
		"ITEM_HOOK_RUNTIME FAIL: %d of %d assertions failed."
		% [_failures.size(), _assertions]
	)
	quit(1)
