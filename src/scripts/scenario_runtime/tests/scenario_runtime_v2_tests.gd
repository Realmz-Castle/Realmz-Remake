extends Node

const BundleScript = preload(
	"res://scripts/classic_runtime/classic_campaign_bundle.gd"
)
const CampaignSessionScript = preload(
	"res://scripts/classic_runtime/classic_campaign_session.gd"
)
const ClassicOpcodeRuntimeScript = preload(
	"res://scripts/scenario_runtime/handlers/classic_opcode_runtime.gd"
)
const CoreHandlersScript = preload(
	"res://scripts/scenario_runtime/handlers/core_handler_catalog.gd"
)
const FixtureHandlerScript = preload(
	"res://scripts/scenario_runtime/extensions/runtime_fixture_handler.gd"
)
const DefaultPortsScript = preload(
	"res://scripts/scenario_runtime/default_scenario_ports.gd"
)
const ExtensionRegistryScript = preload(
	"res://scripts/scenario_runtime/scenario_extension_registry.gd"
)
const RuleRegistryScript = preload(
	"res://scripts/scenario_runtime/gameplay_rule_registry.gd"
)
const InstructionRegistryScript = preload(
	"res://scripts/scenario_runtime/scenario_instruction_registry.gd"
)
const InterpreterScript = preload(
	"res://scripts/scenario_runtime/scenario_interpreter.gd"
)
const HostScript = preload(
	"res://scripts/classic_runtime/classic_runtime_host.gd"
)

const V2_FIXTURE := \
	"res://scripts/classic_runtime/tests/fixtures/war_in_the_sword_lands_gosub"
const V1_FIXTURE := \
	"res://scripts/scenario_runtime/tests/fixtures/v1_rejected"

var failures := 0


func _ready() -> void:
	_test_v2_bundle_contract()
	_test_extension_registry()
	await _test_gameplay_rules()
	_test_handler_registry()
	_test_command_ports()
	_test_scenario_vm()
	await _test_builtin_extension_execution()
	_test_old_save_rejection()
	if failures == 0:
		print("Scenario runtime v2 tests passed")
		get_tree().quit(0)
	else:
		push_error("Scenario runtime v2 tests failed: %d" % failures)
		get_tree().quit(1)


func _test_v2_bundle_contract() -> void:
	var bundle := BundleScript.new()
	_expect(bundle.load_from_directory(V2_FIXTURE), "v2 bundle loads")
	if not bundle.last_error.is_empty():
		push_error(bundle.last_error)
	_expect(
		str(bundle.manifest.get("format", "")) == "realmz-remake-scenario",
		"v2 bundle uses generalized identity"
	)
	_expect(bundle.documents.has("runtime"), "v2 bundle includes runtime document")
	var action: Dictionary = bundle.documents["scripts"]["triggers"][0]["actions"][0]
	_expect(action.get("kind") == "classic", "Classic instruction kind is explicit")
	_expect(action.get("rawCode") == action.get("code"), "Classic instruction preserves raw code")

	var old_bundle := BundleScript.new()
	_expect(not old_bundle.load_from_directory(V1_FIXTURE), "v1 bundle is rejected")
	_expect(
		old_bundle.last_error.contains("Re-export"),
		"v1 rejection contains an upgrade action"
	)


func _test_extension_registry() -> void:
	var registry := ExtensionRegistryScript.new()
	_expect(registry.load_builtin_catalog(), "built-in extension catalog loads")
	var valid := registry.validate_requirements([{
		"id": "scenario.runtime-fixture",
		"apiVersion": 1,
		"configuration": {"marker": "test"},
	}])
	_expect(bool(valid.get("valid", false)), "built-in extension requirement resolves")
	_expect(
		not registry.binding_descriptor(
			"semanticOperations", "scenario.runtime-fixture.mark"
		).is_empty(),
		"semantic operation exposes its authoring schema"
	)
	var missing := registry.validate_requirements([{
		"id": "scenario.missing",
		"apiVersion": 1,
		"configuration": {},
	}])
	_expect(not bool(missing.get("valid", false)), "missing extension blocks readiness")
	var invalid_configuration := registry.validate_requirements([{
		"id": "scenario.runtime-fixture",
		"apiVersion": 1,
		"configuration": {"unknown": true},
	}])
	_expect(
		not bool(invalid_configuration.get("valid", false)),
		"extension configuration is checked against its schema"
	)
	var replacement := registry.register_descriptor({
		"id": "scenario.invalid",
		"apiVersion": 1,
		"capabilities": {"commands": ["core.teleport"]},
	})
	_expect(not replacement, "extension cannot replace a reserved core binding")


func _test_gameplay_rules() -> void:
	var registry := RuleRegistryScript.new()
	_expect(registry.load_builtin_catalog(), "gameplay rule catalog loads")
	var classic_result := registry.resolve("core.classic")
	var samuel_result := registry.resolve("core.samuel")
	_expect(classic_result.get("status") == "ok", "Classic gameplay preset resolves")
	_expect(samuel_result.get("status") == "ok", "Samuel gameplay preset resolves")
	if classic_result.get("status") != "ok" or samuel_result.get("status") != "ok":
		return
	var classic: GameplayRuleSet = classic_result["ruleset"]
	var samuel: GameplayRuleSet = samuel_result["ruleset"]
	_expect(
		classic.provider_id("mapTime") != samuel.provider_id("mapTime"),
		"Classic and Samuel map providers are distinct"
	)
	var mixed_result := registry.resolve("core.classic", {
		"combat": {"providerId": "core.samuel.combat"},
		"presentation": {
			"providerId": "scenario.runtime-fixture.presentation-rules",
			"options": {"fixtureMarker": true},
		},
	})
	_expect(mixed_result.get("status") == "ok", "domain-mixed gameplay rules resolve")
	if mixed_result.get("status") == "ok":
		var mixed: GameplayRuleSet = mixed_result["ruleset"]
		_expect(
			mixed.provider_id("combat") == samuel.provider_id("combat"),
			"mixed rules replace the selected domain"
		)
		_expect(
			mixed.provider_id("mapTime") == classic.provider_id("mapTime"),
			"mixed rules preserve unselected domains"
		)
		_expect(
			mixed.provider_id("presentation")
				== "scenario.runtime-fixture.presentation-rules",
			"built-in extension rule provider can replace one domain"
		)
		var restored := registry.restore(mixed.snapshot())
		_expect(restored.get("status") == "ok", "save-pinned rules restore exactly")
		var mixed_ports := DefaultPortsScript.create(RefCounted.new(), mixed)
		_expect(
			mixed_ports.get("status") == "ok",
			"mixed rules configure the six command ports"
		)
		if mixed_ports.get("status") == "ok":
			var mixed_router: ScenarioCommandRouter = mixed_ports["router"]
			var macro_result: Dictionary = await mixed_router.route(
				"activate_battle_round_macro",
				{}
			)
			_expect(
				bool(macro_result.get("skipped", false)),
				"Samuel combat provider disables Classic battle macros"
			)
			var condition_result: Dictionary = await mixed_router.route(
				"give_character_condition",
				{}
			)
			_expect(
				str(condition_result.get("status", "")) == "error",
				"mixed profile leaves the Classic character domain unchanged"
			)
	var samuel_ports := DefaultPortsScript.create(RefCounted.new(), samuel)
	_expect(
		samuel_ports.get("status") == "ok",
		"Samuel rules configure the six command ports"
	)
	if samuel_ports.get("status") == "ok":
		var samuel_router: ScenarioCommandRouter = samuel_ports["router"]
		var condition_result: Dictionary = await samuel_router.route(
			"give_character_condition",
			{}
		)
		_expect(
			bool(condition_result.get("skipped", false)),
			"Samuel character provider omits Classic-only conditions"
		)
		var click_result: Dictionary = await samuel_router.route(
			"wait_for_click",
			{}
		)
		_expect(
			bool(click_result.get("skipped", false)),
			"Samuel presentation provider skips authored click pacing"
		)


func _test_handler_registry() -> void:
	var registry := InstructionRegistryScript.new()
	_expect(CoreHandlersScript.register_all(registry), "core opcode families register")
	_expect(
		registry.registered_classic_opcodes() \
			== PackedInt32Array(ClassicOpcodeRuntimeScript.HANDLED_OPCODES),
		"every supported Classic opcode registers exactly once"
	)
	var fixture_handler := FixtureHandlerScript.new()
	_expect(registry.register_handler(fixture_handler), "semantic fixture handler registers")
	_expect(
		not registry.register_handler(FixtureHandlerScript.new()),
		"duplicate handler registration is rejected"
	)


func _test_command_ports() -> void:
	var result := DefaultPortsScript.create(RefCounted.new())
	_expect(result.get("status") == "ok", "six default command ports register")
	if result.get("status") != "ok":
		return
	var router: ScenarioCommandRouter = result["router"]
	for command_id: String in [
		"teleport",
		"start_battle",
		"give_treasure",
		"pick_characters",
		"show_text",
		"snapshot_runtime",
	]:
		_expect(
			router.port_for_command(command_id) != null,
			"command '%s' has one port owner" % command_id
		)
		var port := router.port_for_command(command_id)
		_expect(
			port.request_contracts().has(command_id)
				and port.response_contracts().has(command_id),
			"command '%s' declares request and response contracts" % command_id
		)


func _test_scenario_vm() -> void:
	var registry := InstructionRegistryScript.new()
	_expect(
		registry.register_handler(FixtureHandlerScript.new()),
		"VM fixture handler registers"
	)
	var vm := InterpreterScript.new()
	vm.configure(registry, {
		"fixture": {
			"id": "fixture",
			"actions": [{
				"kind": "semantic",
				"slot": 0,
				"operation": "scenario.runtime-fixture.mark",
				"parameters": {"marker": "vm"},
			}],
		},
	})
	_expect(vm.start("fixture").get("status") == "ok", "VM starts a semantic trigger")
	var yielded := vm.run(RefCounted.new())
	_expect(yielded.get("status") == "yield", "VM yields one routed command")
	_expect(
		yielded.get("commandId") == "scenario.runtime-fixture.present",
		"VM preserves semantic command identity"
	)
	var snapshot := vm.snapshot()
	_expect(
		InterpreterScript.validate_snapshot(snapshot).get("valid") == true,
		"VM snapshot validates with one pending record"
	)
	var resumed := vm.resume({"status": "ok"}, RefCounted.new())
	_expect(resumed.get("status") == "complete", "VM resumes through its owning handler")


func _test_builtin_extension_execution() -> void:
	var bundle := BundleScript.new()
	_expect(bundle.load_from_directory(V2_FIXTURE), "extension host fixture bundle loads")
	if not bundle.last_error.is_empty():
		return
	bundle.documents["runtime"]["requiredExtensions"] = [{
		"id": "scenario.runtime-fixture",
		"apiVersion": 1,
		"configuration": {"marker": "host"},
	}]
	bundle.documents["runtime"]["bindings"] = {
		"spells": {"echo": "scenario.runtime-fixture.echo-spell"},
		"items": {"echo": "scenario.runtime-fixture.echo-item"},
		"encounters": {"echo": "scenario.runtime-fixture.echo-encounter"},
		"monsterAi": {"echo": "scenario.runtime-fixture.echo-ai"},
		"lifecycle": {"load": "scenario.runtime-fixture.lifecycle"},
	}
	bundle.documents["scripts"]["triggers"].append({
		"id": "scenario-runtime-v2:semantic",
		"source": "Remake runtime fixture",
		"recordIndex": 0,
		"active": true,
		"callable": true,
		"actions": [{
			"kind": "semantic",
			"slot": 0,
			"operation": "scenario.runtime-fixture.mark",
			"parameters": {"marker": "host"},
		}],
	})
	_expect(
		bundle._validate_document_contract(),
		"compiled campaign accepts a declared built-in semantic operation"
	)
	if not bundle.last_error.is_empty():
		return
	bundle._build_indexes()
	var host := HostScript.new()
	add_child(host)
	host.configure(RefCounted.new())
	var commands: Array[String] = []
	var completions: Array[Dictionary] = []
	host.command_started.connect(func(command: String, _payload: Dictionary) -> void:
		commands.append(command)
	)
	host.playthrough_completed.connect(func(result: Dictionary) -> void:
		completions.append(result)
	)
	host.use_campaign(bundle)
	_expect(
		host.start_trigger("scenario-runtime-v2:semantic"),
		"semantic operation starts through the normal runtime host"
	)
	await get_tree().process_frame
	_expect(
		commands == ["scenario.runtime-fixture.present"],
		"semantic operation yields its built-in extension command"
	)
	_expect(
		completions.size() == 1,
		"semantic extension resumes through its handler to completion"
	)
	for capability_and_binding: Array in [
		["spells", "scenario.runtime-fixture.echo-spell"],
		["itemBehaviors", "scenario.runtime-fixture.echo-item"],
		["encounterResolvers", "scenario.runtime-fixture.echo-encounter"],
		["monsterAiProviders", "scenario.runtime-fixture.echo-ai"],
		["lifecycleHooks", "scenario.runtime-fixture.lifecycle"],
	]:
		var provider_result := bundle.extension_registry.invoke_binding(
			capability_and_binding[0],
			capability_and_binding[1],
			{"fixture": true},
			host
		)
		_expect(
			provider_result.get("status") == "ok"
				and provider_result.get("marker") == "host",
			"built-in fixture invokes %s" % capability_and_binding[0]
		)
	host.queue_free()


func _test_old_save_rejection() -> void:
	var result := CampaignSessionScript.validate_save_payload({"schemaVersion": 2})
	_expect(result.get("status") == "error", "old POC save is rejected")
	_expect(
		str(result.get("message", "")).contains("start a new playthrough"),
		"old-save rejection is actionable"
	)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	failures += 1
	push_error(message)
