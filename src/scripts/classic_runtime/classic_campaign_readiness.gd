class_name ClassicCampaignReadiness
extends RefCounted

const BundleScript = preload("res://scripts/classic_runtime/classic_campaign_bundle.gd")
const ExecutionAuditScript = preload("res://scripts/classic_runtime/classic_execution_audit.gd")
const CharacterConditionRulesScript = preload(
	"res://scripts/classic_runtime/classic_character_condition_rules.gd"
)
const PartyConditionScript = preload(
	"res://scripts/classic_runtime/classic_party_condition.gd"
)
const ItemIdsScript = preload("res://scripts/item_id_divinity.gd")
const ItemBehaviorsScript = preload(
	"res://scripts/classic_runtime/classic_item_behaviors.gd"
)
const SpellIdsScript = preload("res://scripts/spells_id_divinity.gd")
const SpellIdentityScript = preload("res://scripts/classic_runtime/classic_spell_identity.gd")
const SoundIdsScript = preload("res://scripts/sfx_id_divinity.gd")
const SoundResolutionScript = preload(
	"res://scripts/classic_runtime/classic_sound_resolution.gd"
)
const KnownDataCorrectionsScript = preload(
	"res://scripts/classic_runtime/classic_known_data_corrections.gd"
)
const CustomSpellSupportScript = preload(
	"res://scripts/classic_runtime/classic_custom_spell_support.gd"
)

const SCHEMA_VERSION := 1
const BLOCKER := "progression-blocker"
const FALLBACK := "fidelity-fallback"
const SOURCE_BEHAVIOR := "source-behavior"
const INVENTORY := "inventory"
const MAX_RANDOM_TARGETS := 10000
const INACTIVE_DIAGNOSTIC_CODES := [
	"ambiguous-monster-icon-override",
	"incomplete-monster-icon-override",
	"inactive-action-record",
	"inactive-custom-spell-definition",
	"inactive-scenario-rule-table",
	"missing-monster-icon-preview",
	"no-op-scenario-rule-table",
	"trailing-bytes",
]
const SPELL_DEFINITION_FIELDS := [
	"range1",
	"range2",
	"queueIcon",
	"toHitBonus",
	"saveBonus",
	"fixedTargetNum",
	"canRotate",
	"saveAdjust",
	"cannot",
	"resistAdjust",
	"cost",
	"damage1",
	"damage2",
	"powerDamage1",
	"powerDamage2",
	"duration1",
	"duration2",
	"powerDuration1",
	"powerDuration2",
	"spellLook1",
	"spellLook2",
	"sound1",
	"sound2",
	"targetType",
	"size",
	"special",
	"damageType",
	"spellClass",
	"inCombat",
	"inCamp",
]

# These opcodes interpret their ID as an exact Data EDCD row number.
const EXTRA_CODE_OPCODES := [
	2, 3, 7, 12, 13, 15, 16, 17, 18, 19, 20, 21, 22, -23, 23,
	30, 31, 33, 37, 38, 40, 41, 42, 43, 44, 45, 46, 48, 51, 52, 53, 54, 55, 56,
	57, 58, 60, 61, 63, 64, 65, 67, 68, 69, 70, 72, 73, 76, 77, 78, 81, 85, 87,
	90, 92, 103,
	106, 107, 108, 120, 121, 122, 123, 124, 125, 126,
]

var _diagnostics: Array = []
var _diagnostic_keys: Dictionary = {}
var _item_mapping: Dictionary = {}
var _spell_mapping: Dictionary = {}
var _sound_mapping: Dictionary = {}
var _native_context: Dictionary = {}
var _active_custom_spell_ids: Dictionary = {}
var _campaign_id := ""
var _campaign_name := ""


func inspect_directory(directory: String, native_context := {}) -> Dictionary:
	var bundle = BundleScript.new()
	if bundle.load_from_directory(directory):
		return inspect(bundle, native_context)

	_reset(native_context)
	var code := "schema-mismatch" if _is_schema_error(bundle.last_error) else "malformed-bundle"
	_add_diagnostic({
		"severity": "error",
		"classification": BLOCKER,
		"code": code,
		"source": "campaign.json",
		"recordIndex": -1,
		"message": bundle.last_error,
	})
	return _build_report(bundle, {})


func inspect(bundle: ClassicCampaignBundle, native_context := {}) -> Dictionary:
	_reset(native_context)
	_campaign_id = str(bundle.manifest.get("id", ""))
	_campaign_name = str(bundle.manifest.get("name", "Unknown Classic campaign"))
	var execution_report: Dictionary = ExecutionAuditScript.new().inspect(bundle)
	_append_execution_diagnostics(execution_report)
	_append_evidence_diagnostics(bundle)
	_check_start_map(bundle)

	for action_value: Variant in execution_report.get("actions", []):
		if action_value is Dictionary:
			_check_action(bundle, action_value)

	_check_encounter_identities(bundle)
	_check_active_monster_spells(bundle, execution_report)
	_check_rule_table_selection(bundle)
	_check_inactive_custom_spell_definitions(bundle)
	return _build_report(bundle, execution_report)


func _reset(native_context: Variant) -> void:
	_diagnostics.clear()
	_diagnostic_keys.clear()
	_active_custom_spell_ids.clear()
	_campaign_id = ""
	_campaign_name = ""
	_native_context = (
		native_context.duplicate()
		if native_context is Dictionary
		else {}
	)
	var native_items: Variant = _native_context.get("items", {})
	if native_items is Dictionary:
		_native_context["items"] = ItemBehaviorsScript.enrich_item_book(
			native_items
		)
	_item_mapping = _mapping_from_script(ItemIdsScript, "mapping")
	_spell_mapping = _mapping_from_script(SpellIdsScript, "mappings")
	_sound_mapping = _mapping_from_script(SoundIdsScript, "mapping")


func _mapping_from_script(script: Script, property_name: String) -> Dictionary:
	var instance: Object = script.new()
	var value: Variant = instance.get(property_name)
	var mapping: Dictionary = value.duplicate() if value is Dictionary else {}
	instance.free()
	return mapping


func _append_execution_diagnostics(execution_report: Dictionary) -> void:
	for diagnostic_value: Variant in execution_report.get("diagnostics", []):
		if not (diagnostic_value is Dictionary):
			continue
		if diagnostic_value.get("code") == "inactive-action-record":
			continue
		var diagnostic: Dictionary = diagnostic_value.duplicate(true)
		var severity := str(diagnostic.get("severity", "warning"))
		diagnostic["classification"] = BLOCKER if severity == "error" else FALLBACK
		_add_diagnostic(diagnostic)


func _append_evidence_diagnostics(bundle: ClassicCampaignBundle) -> void:
	var evidence: Variant = bundle.documents.get("evidence", {})
	if not (evidence is Dictionary):
		return
	var rows: Variant = evidence.get("diagnostics", [])
	if not (rows is Array):
		return
	for row_value: Variant in rows:
		if not (row_value is Dictionary):
			continue
		var source_severity := str(row_value.get("severity", "warning"))
		var code := str(row_value.get("code", ""))
		var is_monster_icon_inventory := code in [
			"ambiguous-monster-icon-override",
			"incomplete-monster-icon-override",
			"missing-monster-icon-preview",
		]
		if source_severity == "info" and not is_monster_icon_inventory:
			continue
		var row: Dictionary = row_value.duplicate(true)
		if is_monster_icon_inventory:
			row["severity"] = "info"
			row["classification"] = INVENTORY
			row["activity"] = "inactive"
			row["inventoryScope"] = "all monster definitions"
		elif code == "missing-map-icon-overlay":
			row["producerCode"] = code
			row["code"] = "unresolved-map-icon-overlay"
			row["severity"] = "warning"
			row["classification"] = FALLBACK
			row["activity"] = "active"
			row["remakeBehavior"] = "base-tile-only"
			row["classicBehaviorIfAbsent"] = "base-tile-only"
			row["runtimeConsumer"] = "classic-map-materializer"
		else:
			row["severity"] = "error" if source_severity == "error" else "warning"
			row["classification"] = BLOCKER if source_severity == "error" else FALLBACK
		row["recordIndex"] = int(row.get("recordIndex", -1))
		_add_diagnostic(row)


func _check_start_map(bundle: ClassicCampaignBundle) -> void:
	var start := bundle.get_start()
	var map_id := "%s:%d" % [
		str(start.get("levelType", "")),
		int(start.get("levelIndex", -1)),
	]
	if bundle.get_map(map_id).is_empty():
		_add_blocker(
			"missing-start-map",
			"campaign.json",
			-1,
			-1,
			"Campaign start references missing map '%s'" % map_id,
			{"referenceId": map_id}
		)


func _check_action(bundle: ClassicCampaignBundle, action: Dictionary) -> void:
	if (
		not bool(action.get("executable", false))
		or str(action.get("support", "")) == "source-backed-noop"
	):
		return
	var code := int(action.get("code", 0))
	var reference_id := int(action.get("id", 0))
	if EXTRA_CODE_OPCODES.has(code):
		if code in [69, 122] and reference_id == 0:
			return
		var extra_code := bundle.get_extra_code(reference_id)
		if extra_code.is_empty():
			_add_action_dependency(
				action,
				"missing-extra-code",
				"Action references missing Data EDCD record %d" % reference_id,
				{"referenceId": reference_id}
			)
			return
		if code in [17, 18]:
			_check_field_spell(bundle, action, extra_code)
		elif code == 40:
			_check_party_condition(action, extra_code)
		elif code == 43:
			_check_character_condition(action, extra_code)
		elif code == 61:
			_check_position_shift(bundle, action, extra_code)
		elif code in [63, 64]:
			_check_game_time_action(action, extra_code, code)
		elif code == 51:
			_check_shop_mutation(bundle, action, extra_code)
		elif code == 53:
			_check_caste_character_selection(action, extra_code)
		elif code == 55:
			_check_selected_count_branch(bundle, action, extra_code)
		elif code == 60:
			_check_currency_clear(action, extra_code)
		elif code == 65:
			_check_random_items(bundle, action, extra_code)
		elif code == 67:
			_check_item_charge_branch(bundle, action, extra_code)
		elif code == 68:
			_check_fatigue_mutation(action, extra_code)
		elif code == 69:
			_check_spellcasting_flags(action, extra_code)
		elif code == 72:
			_check_quest_range_branch(bundle, action, extra_code)
		elif code in [76, 77]:
			_check_quest_value_action(bundle, action, extra_code, code)
		elif code == 78:
			_check_tile_parameter_branch(bundle, action, extra_code)
		elif code == 81:
			_check_character_condition_branch(bundle, action, extra_code)
		elif code == 90:
			_check_experience_loss(action, extra_code)
		elif code == 92:
			_check_random_rectangle_bounds(bundle, action, extra_code)
		elif code == 103:
			_check_exploration_status(action, extra_code)
		elif code == 85:
			_check_random_branch(bundle, action, extra_code)
		elif code == 124:
			_check_spawn_monster(bundle, action, extra_code)
		return

	match code:
		1:
			_check_message(bundle, action, reference_id)
		4:
			_check_direct_record(
				bundle.get_encounter("simple", reference_id), action, "simple encounter", reference_id
			)
		5:
			_check_direct_record(
				bundle.get_encounter("complex", reference_id), action, "complex encounter", reference_id
			)
		6:
			_check_direct_record(bundle.get_shop(reference_id), action, "shop", reference_id)
		8:
			_check_same_map_action_point(bundle, action, reference_id)
		39:
			_check_direct_record(
				bundle.get_extra_action_point(reference_id),
				action,
				"Data ED3 action point",
				reference_id
			)
		9:
			_check_sound(bundle, action, reference_id)
		10:
			_check_direct_record(bundle.get_treasure(reference_id), action, "treasure", reference_id)
		27:
			_check_picture(bundle, action, reference_id)
		29:
			_check_player_map(bundle, action, reference_id)
		62:
			_check_scrolling_text(bundle, action, reference_id)
		89:
			_check_ally(bundle, action, reference_id)


func _check_party_condition(
	action: Dictionary,
	extra_code: Dictionary
) -> void:
	var values: Variant = extra_code.get("values", [])
	if not (values is Array) or values.size() < 4:
		_add_blocker_for_action(
			action,
			"malformed-party-condition",
			"Party-condition Data EDCD record has fewer than four values",
			{"referenceId": int(extra_code.get("id", -1))}
		)
		return
	var condition_index := int(values[3])
	if PartyConditionScript.supports_condition(condition_index):
		return
	_add_blocker_for_action(
		action,
		"unsupported-party-condition",
		"Classic party condition %d has no safe Remake mapping"
		% condition_index,
		{"referenceId": condition_index}
	)


func _check_character_condition(
	action: Dictionary,
	extra_code: Dictionary
) -> void:
	var values: Variant = extra_code.get("values", [])
	if not (values is Array) or values.size() < 3:
		_add_blocker_for_action(
			action,
			"malformed-character-condition",
			"Give Condition Data EDCD record has fewer than three values",
			{"referenceId": int(extra_code.get("id", -1))}
		)
		return
	var condition_index := int(values[1])
	if CharacterConditionRulesScript.supports_condition(condition_index):
		return
	_add_blocker_for_action(
		action,
		"unsupported-character-condition",
		"Classic character condition %d has no safe Remake mapping"
		% condition_index,
		{"referenceId": condition_index}
	)


func _check_message(
	bundle: ClassicCampaignBundle,
	action: Dictionary,
	message_id: int
) -> void:
	if message_id == 0 or not bundle.get_message(message_id).is_empty():
		return
	_add_fallback_for_action(
		action,
		"missing-message",
		"Action references missing message record %d" % message_id,
		{"referenceId": message_id}
	)


func _check_direct_record(
	record: Dictionary,
	action: Dictionary,
	record_kind: String,
	reference_id: int
) -> void:
	if not record.is_empty():
		return
	_add_action_dependency(
		action,
		"missing-%s" % record_kind.replace(" ", "-").to_lower(),
		"Action references missing %s record %d" % [record_kind, reference_id],
		{"referenceId": reference_id}
	)


func _check_position_shift(
	bundle: ClassicCampaignBundle,
	action: Dictionary,
	extra_code: Dictionary
) -> void:
	var values: Variant = extra_code.get("values", [])
	if not (values is Array) or values.size() < 5:
		return
	var delta_x := int(values[1])
	var delta_y := int(values[2])
	var randomized := int(values[3]) != 0
	var max_x := 0
	var max_y := 0
	for map_value: Variant in bundle.maps_by_id.values():
		if not (map_value is Dictionary):
			continue
		max_x = maxi(max_x, int(map_value.get("width", 0)) - 1)
		max_y = maxi(max_y, int(map_value.get("height", 0)) - 1)
	var invalid := (
		(randomized and (delta_x <= 0 or delta_y <= 0))
		or (not randomized and (absi(delta_x) > max_x or absi(delta_y) > max_y))
		or (randomized and (delta_x > max_x or delta_y > max_y))
	)
	if not invalid:
		return
	_add_action_dependency(
		action,
		"invalid-position-shift",
		"Position shift Data EDCD record %d cannot remain within the compiled maps" % [
			int(extra_code.get("id", -1))
		],
		{
			"referenceId": int(extra_code.get("id", -1)),
			"deltaX": delta_x,
			"deltaY": delta_y,
			"randomized": randomized,
		}
	)


func _check_game_time_action(
	action: Dictionary,
	extra_code: Dictionary,
	opcode: int
) -> void:
	var values: Variant = extra_code.get("values", [])
	if not (values is Array) or values.size() < 5:
		return
	var invalid := false
	if opcode == 63:
		var mode := int(values[0])
		invalid = mode not in [1, 2] or (
			mode == 1
			and (
				int(values[1]) < -1
				or int(values[2]) < -1
				or int(values[2]) > 23
				or int(values[3]) < -1
				or int(values[3]) > 59
			)
		)
	else:
		invalid = (
			int(values[0]) < -1
			or int(values[1]) < -1
			or int(values[1]) > 24
		)
	if not invalid:
		return
	_add_action_dependency(
		action,
		"invalid-game-time-action",
		"Opcode %d Data EDCD record %d has invalid game-time fields" % [
			opcode,
			int(extra_code.get("id", -1)),
		],
		{"referenceId": int(extra_code.get("id", -1))}
	)


func _check_exploration_status(action: Dictionary, extra_code: Dictionary) -> void:
	var values: Variant = extra_code.get("values", [])
	if not (values is Array) or values.size() < 5:
		return
	for value_index: int in 3:
		if int(values[value_index]) in [0, 1, 2]:
			continue
		_add_action_dependency(
			action,
			"invalid-exploration-status",
			"Opcode 103 Data EDCD record %d has invalid field %d" % [
				int(extra_code.get("id", -1)),
				value_index,
			],
			{
				"referenceId": int(extra_code.get("id", -1)),
				"field": value_index,
			}
		)
		return


func _check_quest_value_action(
	bundle: ClassicCampaignBundle,
	action: Dictionary,
	extra_code: Dictionary,
	opcode: int
) -> void:
	var values: Variant = extra_code.get("values", [])
	if not (values is Array) or values.size() < 5:
		_add_action_dependency(
			action,
			"malformed-quest-value-action",
			"Opcode %d Data EDCD record has fewer than five values" % opcode,
			{"referenceId": int(extra_code.get("id", -1))}
		)
		return
	var quest_id := int(values[0])
	if quest_id < 0 or quest_id >= 100:
		_add_action_dependency(
			action,
			"invalid-quest-value-action",
			"Opcode %d uses quest index %d outside 0 through 99" % [
				opcode,
				quest_id,
			],
			{"referenceId": int(extra_code.get("id", -1)), "questId": quest_id}
		)
		return
	var target_mode := int(values[2]) - 1 if opcode == 76 else int(values[2])
	var has_branch := int(values[3]) != 0 if opcode == 76 \
		else int(values[3]) != 0 or int(values[4]) != 0
	if has_branch and (target_mode < 0 or target_mode > 2):
		_add_action_dependency(
			action,
			"invalid-quest-value-action",
			"Opcode %d has invalid branch mode %d" % [
				opcode,
				int(values[2]),
			],
			{"referenceId": int(extra_code.get("id", -1))}
		)
		return
	if not has_branch:
		return
	var targets: Array[int] = []
	if opcode == 76:
		targets.append(int(values[4]))
	else:
		targets.append(int(values[3]))
		targets.append(int(values[4]))
	for target_id: int in targets:
		if target_id == 0 and opcode == 77:
			continue
		var target: Dictionary
		match target_mode:
			0:
				target = bundle.get_extra_action_point(target_id)
			1:
				target = bundle.get_encounter("simple", target_id)
			_:
				target = bundle.get_encounter("complex", target_id)
		if not target.is_empty():
			continue
		_add_action_dependency(
			action,
			"missing-quest-value-target",
			"Opcode %d references missing branch target %d" % [
				opcode,
				target_id,
			],
			{
				"referenceId": target_id,
				"targetMode": target_mode,
			}
		)


func _check_shop_mutation(
	bundle: ClassicCampaignBundle,
	action: Dictionary,
	extra_code: Dictionary
) -> void:
	var values: Variant = extra_code.get("values", [])
	if not (values is Array) or values.size() < 4:
		_add_action_dependency(
			action,
			"malformed-shop-mutation",
			"Shop-mutation Data EDCD record has fewer than four values",
			{"referenceId": int(extra_code.get("id", -1))}
		)
		return
	var shop_id := int(values[0])
	if bundle.get_shop(shop_id).is_empty():
		_add_action_dependency(
			action,
			"missing-shop",
			"Shop mutation references missing shop %d" % shop_id,
			{"referenceId": shop_id}
		)


func _check_currency_clear(action: Dictionary, extra_code: Dictionary) -> void:
	var values: Variant = extra_code.get("values", [])
	if not (values is Array) or values.size() < 2:
		_add_action_dependency(
			action,
			"malformed-currency-clear",
			"Currency-clear Data EDCD record has fewer than two values",
			{"referenceId": int(extra_code.get("id", -1))}
		)
		return
	if int(values[0]) not in [1, 2, 3] or int(values[1]) not in [0, 1]:
		_add_action_dependency(
			action,
			"invalid-currency-clear",
			"Currency-clear action has invalid currency or selection mode",
			{
				"referenceId": int(extra_code.get("id", -1)),
				"currency": int(values[0]),
				"selectedOnly": int(values[1]),
			}
		)


func _check_random_items(
	bundle: ClassicCampaignBundle,
	action: Dictionary,
	extra_code: Dictionary
) -> void:
	var values: Variant = extra_code.get("values", [])
	if not (values is Array) or values.size() < 3:
		_add_action_dependency(
			action,
			"malformed-random-items",
			"Random-item Data EDCD record has fewer than three values",
			{"referenceId": int(extra_code.get("id", -1))}
		)
		return
	var authored_count := int(values[0])
	var first_item_id := int(values[1])
	var last_item_id := int(values[2])
	if (
		authored_count == 0
		or absi(authored_count) > 20
		or first_item_id <= 0
		or last_item_id < first_item_id
	):
		_add_action_dependency(
			action,
			"invalid-random-items",
			"Random-item action has an invalid count or item range",
			{
				"referenceId": int(extra_code.get("id", -1)),
				"count": authored_count,
				"itemRange": [first_item_id, last_item_id],
			}
		)
		return
	var native_items: Variant = _native_context.get("items", {})
	if not (native_items is Dictionary) or native_items.is_empty():
		return
	for item_id: int in range(first_item_id, last_item_id + 1):
		if not _native_item_for_classic_id(item_id, native_items).is_empty():
			continue
		_add_action_dependency(
			action,
			"missing-native-item",
			"Random-item range includes item %d without a native Remake resource" % item_id,
			{"referenceId": item_id}
		)


func _check_fatigue_mutation(action: Dictionary, extra_code: Dictionary) -> void:
	var values: Variant = extra_code.get("values", [])
	if not (values is Array) or values.size() < 3:
		_add_action_dependency(
			action,
			"malformed-fatigue-action",
			"Fatigue Data EDCD record has fewer than three values",
			{"referenceId": int(extra_code.get("id", -1))}
		)
		return
	if int(values[0]) not in [1, 2, 3]:
		_add_action_dependency(
			action,
			"invalid-fatigue-action",
			"Fatigue action has an invalid mode",
			{
				"referenceId": int(extra_code.get("id", -1)),
				"mode": int(values[0]),
			}
		)


func _check_caste_character_selection(
	action: Dictionary,
	extra_code: Dictionary
) -> void:
	var values: Variant = extra_code.get("values", [])
	if not (values is Array) or values.size() < 3:
		_add_action_dependency(
			action,
			"malformed-caste-selection",
			"Caste-selection Data EDCD record has fewer than three values",
			{"referenceId": int(extra_code.get("id", -1))}
		)
		return
	if int(values[1]) in [0, 1, 2, 3] and int(values[2]) in [0, 1, 2]:
		return
	_add_action_dependency(
		action,
		"invalid-caste-selection",
		"Caste-selection action has an invalid group or source mode",
		{"referenceId": int(extra_code.get("id", -1))}
	)


func _check_selected_count_branch(
	bundle: ClassicCampaignBundle,
	action: Dictionary,
	extra_code: Dictionary
) -> void:
	var values: Variant = extra_code.get("values", [])
	if not (values is Array) or values.size() < 5:
		_add_action_dependency(
			action,
			"malformed-selected-count-branch",
			"Selected-count branch Data EDCD record has fewer than five values",
			{"referenceId": int(extra_code.get("id", -1))}
		)
		return
	_check_extra_action_point_target(bundle, action, int(values[3]))
	if int(values[1]) == 1:
		_check_extra_action_point_target(bundle, action, int(values[4]))
	elif int(values[1]) == 2:
		_check_message(bundle, action, int(values[4]))


func _check_item_charge_branch(
	bundle: ClassicCampaignBundle,
	action: Dictionary,
	extra_code: Dictionary
) -> void:
	var values: Variant = extra_code.get("values", [])
	if not (values is Array) or values.size() < 5:
		_add_action_dependency(
			action,
			"malformed-item-charge-branch",
			"Item-charge branch Data EDCD record has fewer than five values",
			{"referenceId": int(extra_code.get("id", -1))}
		)
		return
	var target_mode := int(values[1])
	if target_mode < 0 or target_mode > 2:
		_add_action_dependency(
			action,
			"invalid-item-charge-branch",
			"Item-charge branch has an invalid target mode",
			{"referenceId": int(extra_code.get("id", -1))}
		)
		return
	for target_id: int in [int(values[3]), int(values[4])]:
		if target_id == -1:
			continue
		match target_mode:
			0:
				_check_extra_action_point_target(bundle, action, target_id)
			1:
				_check_direct_record(
					bundle.get_encounter("simple", target_id),
					action,
					"simple encounter",
					target_id
				)
			2:
				_check_direct_record(
					bundle.get_encounter("complex", target_id),
					action,
					"complex encounter",
					target_id
				)


func _check_character_condition_branch(
	bundle: ClassicCampaignBundle,
	action: Dictionary,
	extra_code: Dictionary
) -> void:
	var values: Variant = extra_code.get("values", [])
	if not (values is Array) or values.size() < 5:
		_add_action_dependency(
			action,
			"malformed-character-condition-branch",
			"Character-condition branch Data EDCD record has fewer than five values",
			{"referenceId": int(extra_code.get("id", -1))}
		)
		return
	var condition_index := int(values[0])
	if not CharacterConditionRulesScript.supports_condition(condition_index):
		_add_action_dependency(
			action,
			"unsupported-character-condition-branch",
			"Character-condition branch uses condition %d without a Remake mapping"
			% condition_index,
			{"referenceId": condition_index}
		)
		return
	_check_extra_action_point_target(bundle, action, int(values[3]))
	_check_extra_action_point_target(bundle, action, int(values[4]))


func _check_extra_action_point_target(
	bundle: ClassicCampaignBundle,
	action: Dictionary,
	target_id: int
) -> void:
	if not bundle.get_extra_action_point(target_id).is_empty():
		return
	_add_action_dependency(
		action,
		"missing-extra-action-point",
		"Action references missing Data ED3 action point %d" % target_id,
		{"referenceId": target_id}
	)


func _check_random_rectangle_bounds(
	bundle: ClassicCampaignBundle,
	action: Dictionary,
	extra_code: Dictionary
) -> void:
	var values: Variant = extra_code.get("values", [])
	if not (values is Array) or values.size() < 5:
		_add_action_dependency(
			action,
			"malformed-random-rectangle-bounds",
			"Random-rectangle bounds Data EDCD record has fewer than five values",
			{"referenceId": int(extra_code.get("id", -1))}
		)
		return
	var reference_id := int(extra_code.get("id", -1))
	var bounds_extra := bundle.get_extra_code(reference_id + 1)
	var bounds_values: Variant = bounds_extra.get("values", [])
	if bounds_extra.is_empty() or not (bounds_values is Array) or bounds_values.size() < 4:
		_add_action_dependency(
			action,
			"missing-random-rectangle-bounds-row",
			"Random-rectangle bounds action requires consecutive Data EDCD record %d"
			% (reference_id + 1),
			{"referenceId": reference_id + 1}
		)
		return
	var level_kind := "dungeon" if int(values[2]) != 0 else "land"
	var level_index := int(values[0])
	var rectangle_index := int(values[1])
	var bounds_mode := int(values[4])
	if rectangle_index < 0 or rectangle_index >= 20 or bounds_mode < -1 or bounds_mode > 2:
		_add_action_dependency(
			action,
			"invalid-random-rectangle-bounds",
			"Random-rectangle bounds action has an invalid rectangle or mode",
			{
				"referenceId": reference_id,
				"rectIndex": rectangle_index,
				"boundsMode": bounds_mode,
			}
		)
		return
	if not bundle.get_random_level(level_kind, level_index).is_empty():
		return
	_add_action_dependency(
		action,
		"missing-random-level",
		"Random-rectangle bounds action references missing %s random level %d"
		% [level_kind, level_index],
		{
			"referenceId": level_index,
			"levelType": level_kind,
		}
	)


func _check_spellcasting_flags(action: Dictionary, extra_code: Dictionary) -> void:
	var values: Variant = extra_code.get("values", [])
	if values is Array and values.size() >= 3:
		return
	_add_action_dependency(
		action,
		"malformed-spellcasting-flags",
		"Spellcasting-flags Data EDCD record has fewer than three values",
		{"referenceId": int(extra_code.get("id", -1))}
	)


func _check_quest_range_branch(
	bundle: ClassicCampaignBundle,
	action: Dictionary,
	extra_code: Dictionary
) -> void:
	var values: Variant = extra_code.get("values", [])
	if not (values is Array) or values.size() < 5:
		_add_action_dependency(
			action,
			"malformed-quest-range-branch",
			"Quest-range Data EDCD record has fewer than five values",
			{"referenceId": int(extra_code.get("id", -1))}
		)
		return
	var first_quest := int(values[0])
	var last_quest := int(values[1])
	var target_mode := int(values[3])
	if (
		first_quest < 0
		or last_quest < first_quest
		or last_quest >= 100
		or target_mode < 0
		or target_mode > 2
	):
		_add_action_dependency(
			action,
			"invalid-quest-range-branch",
			"Quest-range branch has an invalid range or target mode",
			{
				"referenceId": int(extra_code.get("id", -1)),
				"questRange": [first_quest, last_quest],
				"targetMode": target_mode,
			}
		)
		return
	var target_id := int(values[4])
	var target: Dictionary
	match target_mode:
		0:
			target = bundle.get_extra_action_point(target_id)
		1:
			target = bundle.get_encounter("simple", target_id)
		_:
			target = bundle.get_encounter("complex", target_id)
	if not target.is_empty():
		return
	_add_action_dependency(
		action,
		"missing-quest-range-target",
		"Quest-range branch references missing target %d" % target_id,
		{"referenceId": target_id, "targetMode": target_mode}
	)


func _check_tile_parameter_branch(
	bundle: ClassicCampaignBundle,
	action: Dictionary,
	extra_code: Dictionary
) -> void:
	var values: Variant = extra_code.get("values", [])
	if not (values is Array) or values.size() < 5:
		_add_action_dependency(
			action,
			"malformed-tile-parameter-branch",
			"Tile-parameter branch Data EDCD record has fewer than five values",
			{"referenceId": int(extra_code.get("id", -1))}
		)
		return
	var selector := int(values[0])
	var target_mode := int(values[2])
	if target_mode < 0 or target_mode > 2:
		_add_action_dependency(
			action,
			"invalid-tile-parameter-branch",
			"Tile-parameter branch has an invalid target mode",
			{
				"referenceId": int(extra_code.get("id", -1)),
				"parameter": selector,
				"targetMode": target_mode,
			}
		)
		return
	for target_id: int in [int(values[3]), int(values[4])]:
		if target_id == 0:
			continue
		var target: Dictionary
		match target_mode:
			0:
				target = bundle.get_extra_action_point(target_id)
			1:
				target = bundle.get_encounter("simple", target_id)
			_:
				target = bundle.get_encounter("complex", target_id)
		if not target.is_empty():
			continue
		_add_action_dependency(
			action,
			"missing-tile-parameter-target",
			"Tile-parameter branch references missing target %d" % target_id,
			{"referenceId": target_id, "targetMode": target_mode}
		)


func _check_experience_loss(action: Dictionary, extra_code: Dictionary) -> void:
	var values: Variant = extra_code.get("values", [])
	if values is Array and values.size() >= 2:
		return
	_add_action_dependency(
		action,
		"malformed-experience-loss",
		"Experience-loss Data EDCD record has fewer than two values",
		{"referenceId": int(extra_code.get("id", -1))}
	)


func _check_same_map_action_point(
	bundle: ClassicCampaignBundle,
	action: Dictionary,
	record_index: int
) -> void:
	var origin := bundle.get_trigger(str(action.get("recordId", "")))
	if origin.is_empty() or str(origin.get("levelType", "")).is_empty():
		return
	for trigger_value: Variant in bundle.triggers_by_id.values():
		if not (trigger_value is Dictionary):
			continue
		if (
			int(trigger_value.get("recordIndex", -1)) == record_index
			and str(trigger_value.get("levelType", "")) == str(origin.get("levelType", ""))
			and int(trigger_value.get("levelIndex", -1)) == int(origin.get("levelIndex", -1))
		):
			return
	_add_action_dependency(
		action,
		"missing-same-map-action-point",
		"Action references missing same-map action point %d" % record_index,
		{"referenceId": record_index}
	)


func _check_picture(
	bundle: ClassicCampaignBundle,
	action: Dictionary,
	picture_id: int
) -> void:
	var picture := bundle.get_picture(picture_id)
	if picture.is_empty():
		var message := (
			"Picture %d is absent from the bundled scenario and stock inventories; "
			+ "an optional external Classic resource remains unresolved"
		) % abs(picture_id)
		var extra := {
			"resourceId": abs(picture_id),
			"remakeBehavior": "unchanged-picture",
			"classicBehaviorIfAbsent": "unchanged-picture",
		}
		if (
			bool(action.get("executable", false))
			and bool(action.get("mediaRequiredForProgression", false))
		):
			_add_blocker_for_action(
				action,
				"unresolved-classic-picture-resource",
				message,
				extra
			)
		else:
			_add_fallback_for_action(
				action,
				"unresolved-classic-picture-resource",
				message,
				extra
			)
		return
	var runtime_media: Variant = picture.get("runtimeMedia", {})
	if runtime_media is Dictionary and not runtime_media.is_empty():
		var runtime_path := str(runtime_media.get("path", "")).strip_edges()
		if not FileAccess.file_exists(bundle.root_directory.path_join(runtime_path)):
			_add_media_diagnostic_for_action(
				action,
				"missing-picture-runtime-media",
				"Picture %d runtime media '%s' is missing" % [abs(picture_id), runtime_path],
				{"resourceId": abs(picture_id), "runtimeMediaPath": runtime_path}
			)
		return
	var legacy_candidates: Array = _picture_file_candidates({
		"pictureId": picture_id,
		"picture": picture,
	})
	for file_name: String in legacy_candidates:
		if FileAccess.file_exists(
			bundle.root_directory.path_join("Splash Images").path_join(file_name)
		):
			return
	var payload_path := str(picture.get("payloadPath", "")).strip_edges()
	if payload_path.is_empty():
		_add_media_diagnostic_for_action(
			action,
			"missing-picture-payload",
			"Picture %d has no exported runtime media" % abs(picture_id),
			{"resourceId": abs(picture_id)}
		)
	elif str(picture.get("payloadEncoding", "")) == "classic-resource-data":
		_add_media_diagnostic_for_action(
			action,
			"missing-picture-runtime-media",
			"Picture %d has preserved Classic bytes but no decoded runtime media" \
				% abs(picture_id),
			{"resourceId": abs(picture_id), "payloadPath": payload_path}
		)
	elif not FileAccess.file_exists(bundle.root_directory.path_join(payload_path)):
		_add_media_diagnostic_for_action(
			action,
			"missing-picture-file",
			"Picture %d payload '%s' is missing" % [abs(picture_id), payload_path],
			{"resourceId": abs(picture_id), "payloadPath": payload_path}
		)


func _check_sound(
	bundle: ClassicCampaignBundle,
	action: Dictionary,
	sound_id: int
) -> void:
	var sound := bundle.get_sound(sound_id)
	var resolution: Dictionary = SoundResolutionScript.resolve(
		sound_id,
		sound,
		_sound_mapping
	)
	var status := str(resolution.get("status", ""))
	match status:
		"silent-sentinel":
			_add_source_behavior_for_action(
				action,
				"classic-sound-sentinel",
				"Sound 0 is Classic's explicit silent sentinel",
				resolution
			)
		"unresolved-external-classic-resource":
			var message := (
				"Sound %d is absent from the bundled scenario and stock inventories; "
				+ "an optional external Classic resource remains unresolved"
			) % absi(sound_id)
			if bool(action.get("mediaRequiredForProgression", false)):
				_add_media_diagnostic_for_action(
					action,
					"unresolved-classic-sound-resource",
					message,
					resolution
				)
			else:
				_add_fallback_for_action(
					action,
					"unresolved-classic-sound-resource",
					message,
					resolution
				)
		"missing-runtime-media":
			_add_media_diagnostic_for_action(
				action,
				"missing-sound-runtime-media",
				"Sound %d has preserved Classic media but no decoded runtime media" \
					% absi(sound_id),
				resolution
			)
		"unsupported-runtime-media":
			_add_media_diagnostic_for_action(
				action,
				"unsupported-sound-runtime-media",
				"Sound %d uses unsupported runtime media type '%s'" % [
					absi(sound_id),
					str(resolution.get("runtimeMediaType", "")),
				],
				resolution
			)
		"runtime-media":
			var runtime_path := str(resolution.get("runtimeMediaPath", "")).strip_edges()
			if not FileAccess.file_exists(bundle.root_directory.path_join(runtime_path)):
				_add_media_diagnostic_for_action(
					action,
					"missing-sound-runtime-media",
					"Sound %d runtime media '%s' is missing" % [
						absi(sound_id),
						runtime_path,
					],
					resolution
				)
			elif bool(resolution.get("waitForCompletion", false)):
				_add_source_behavior_for_action(
					action,
					"classic-synchronous-sound",
					"Negative sound %d waits for playback to finish" % sound_id,
					resolution
				)
		"native-mapping":
			var sound_name := str(resolution.get("nativeName", ""))
			var sounds: Variant = _native_context.get("sounds", {})
			if sounds is Dictionary and not sounds.is_empty() and not sounds.has(sound_name):
				_add_media_diagnostic_for_action(
					action,
					"missing-native-sound",
					"Mapped sound '%s' is not available to Remake" % sound_name,
					resolution
				)
			elif bool(resolution.get("waitForCompletion", false)):
				_add_source_behavior_for_action(
					action,
					"classic-synchronous-sound",
					"Negative sound %d waits for playback to finish" % sound_id,
					resolution
				)


func _check_player_map(
	bundle: ClassicCampaignBundle,
	action: Dictionary,
	map_id: int
) -> void:
	if not bundle.get_player_map(map_id).is_empty():
		return
	_add_media_diagnostic_for_action(
		action,
		"missing-player-map",
		"Player map %d is unavailable" % abs(map_id),
		{"referenceId": abs(map_id)}
	)


func _check_scrolling_text(
	bundle: ClassicCampaignBundle,
	action: Dictionary,
	resource_id: int
) -> void:
	if not bundle.get_scrolling_text(resource_id).is_empty():
		return
	_add_action_dependency(
		action,
		"missing-scrolling-text",
		"Scrolling TEXT resource %d is unavailable" % abs(resource_id),
		{"referenceId": abs(resource_id)}
	)


func _check_ally(bundle: ClassicCampaignBundle, action: Dictionary, monster_id: int) -> void:
	var monster := bundle.get_monster(monster_id)
	if monster.is_empty():
		_check_direct_record(monster, action, "monster", monster_id)
		return
	var bestiary: Variant = _native_context.get("bestiary", {})
	if not (bestiary is Dictionary) or bestiary.is_empty():
		return
	var native_name := _resolve_classic_monster_bestiary_name(
		abs(monster_id), monster, bestiary
	)
	if native_name.is_empty():
		_add_blocker_for_action(
			action,
			"unresolved-native-monster",
			"Classic monster %d '%s' has no native bestiary equivalent" % [
				abs(monster_id), str(monster.get("displayName", "")),
			],
			{"referenceId": abs(monster_id)}
		)
		return
	_check_monster_materialization(
		bestiary[native_name],
		abs(monster_id),
		str(action.get("source", "")),
		int(action.get("recordIndex", -1)),
		int(action.get("slot", -1)),
		action
	)


func _check_spawn_monster(
	bundle: ClassicCampaignBundle,
	action: Dictionary,
	extra_code: Dictionary
) -> void:
	var values: Variant = extra_code.get("values", [])
	if not (values is Array) or values.size() < 2:
		return
	var monster_id: int = abs(int(values[1]))
	if monster_id == 0:
		return
	var monster := bundle.get_monster(monster_id)
	if monster.has("hitDice") and int(monster.get("hitDice", 0)) <= 0:
		_add_fallback_for_action(
			action,
			"inert-combat-spawn",
			(
				"Combat spawn references empty Classic monster record %d; "
				+ "Classic cannot create a viable combatant from that slot"
			) % monster_id,
			{"referenceId": monster_id}
		)
		return
	_check_ally(bundle, action, monster_id)


func _check_field_spell(
	bundle: ClassicCampaignBundle,
	action: Dictionary,
	extra_code: Dictionary
) -> void:
	var values: Variant = extra_code.get("values", [])
	if not (values is Array) or values.size() < 5:
		_add_blocker_for_action(
			action,
			"malformed-extra-code",
			"Field-spell Data EDCD record has fewer than five values",
			{"referenceId": int(extra_code.get("id", -1))}
		)
		return
	var authored_spell_id := int(values[0])
	var correction: Dictionary = KnownDataCorrectionsScript.spell_reference(
		str(bundle.manifest.get("id", "")),
		str(action.get("source", "")),
		int(action.get("recordIndex", -1)),
		authored_spell_id
	)
	var spell_id := int(correction.get("spellId", authored_spell_id))
	if bool(correction.get("corrected", false)):
		_add_fallback_for_action(
			action,
			"corrected-classic-spell-reference",
			"Classic spell %d is treated as spell %d: %s" % [
				authored_spell_id,
				spell_id,
				str(correction.get("reason", "")),
			],
			{
				"referenceId": authored_spell_id,
				"resolvedReferenceId": spell_id,
			}
		)
	if _check_custom_spell_override(
		bundle, spell_id, str(action.get("source", "")), int(action.get("recordIndex", -1))
	):
		return
	var mapping_key := SpellIdentityScript.mapping_key(spell_id)
	var spell_name := str(_spell_mapping.get(mapping_key, _spell_mapping.get(spell_id, "")))
	if spell_name.is_empty():
		_add_blocker_for_action(
			action,
			"unresolved-spell-identity",
			"Classic spell %d has no Remake mapping" % spell_id,
			{"referenceId": spell_id}
		)
	else:
		var spells: Variant = _native_context.get("spells", {})
		if spells is Dictionary and not spells.is_empty():
			var resource_name := SpellIdentityScript.resource_key(
				spell_id, _spell_mapping, spells
			)
			if resource_name.is_empty():
				var code := "missing-native-spell"
				var message := \
					"Mapped spell '%s' has no executable Remake resource" % spell_name
				if spells.has(spell_name):
					code = "unsupported-native-spell-variant"
					message = "Mapped spell '%s' does not represent Classic spell %d" % [
						spell_name, spell_id,
					]
				_add_blocker_for_action(
					action,
					code,
					message,
					{"referenceId": spell_id, "nativeName": spell_name}
				)
			else:
				var spell_metadata: Variant = spells.get(resource_name, {})
				var save_index := int(spell_metadata.get("classicSpellSaveIndex", -2)) \
					if spell_metadata is Dictionary else -2
				var save_mode := str(spell_metadata.get("classicSpellSaveMode", "")) \
					if spell_metadata is Dictionary else ""
				if not ["none", "negate", "half_damage"].has(save_mode) \
						or (save_mode != "none" and (save_index < 0 or save_index > 7)):
					_add_blocker_for_action(
						action,
						"missing-native-spell-save-metadata",
						"Mapped spell '%s' has no executable Classic save behavior" % spell_name,
						{"referenceId": spell_id, "nativeName": spell_name}
					)


func _check_random_branch(
	bundle: ClassicCampaignBundle,
	action: Dictionary,
	extra_code: Dictionary
) -> void:
	var values: Variant = extra_code.get("values", [])
	if not (values is Array) or values.size() < 5:
		_add_blocker_for_action(
			action,
			"malformed-random-branch",
			"Random branch Data EDCD record has fewer than five values"
		)
		return
	var mode := int(values[0])
	var first_target := int(values[1])
	var last_target := int(values[2])
	if mode < 0 or mode > 2:
		_add_blocker_for_action(
			action,
			"invalid-random-target-mode",
			"Random branch has invalid target mode %d" % mode
		)
		return
	if last_target < first_target:
		_add_blocker_for_action(
			action,
			"reversed-random-target-range",
			"Random branch target range %d-%d is reversed" % [first_target, last_target]
		)
		return
	if last_target - first_target + 1 > MAX_RANDOM_TARGETS:
		_add_blocker_for_action(
			action,
			"random-target-range-too-large",
			"Random branch target range %d-%d is too large to validate" % [
				first_target, last_target,
			]
		)
		return
	for target: int in range(first_target, last_target + 1):
		var target_record: Dictionary
		match mode:
			0:
				target_record = bundle.get_extra_action_point(target)
			1:
				target_record = bundle.get_encounter("simple", target)
			_:
				target_record = bundle.get_encounter("complex", target)
		if target_record.is_empty():
			_add_blocker_for_action(
				action,
				"missing-random-target",
				"Random branch can select missing target %d" % target,
				{"referenceId": target, "targetMode": mode}
			)


func _check_encounter_identities(bundle: ClassicCampaignBundle) -> void:
	_check_battle_monsters(bundle)
	var encounter_ids: Array = bundle.complex_encounters_by_id.keys()
	encounter_ids.sort()
	for encounter_id_value: Variant in encounter_ids:
		var encounter_id := int(encounter_id_value)
		var encounter: Dictionary = bundle.complex_encounters_by_id[encounter_id_value]
		if not _producer_marks_callable(encounter):
			continue
		_check_item_ids(bundle, encounter, encounter_id)
		_check_spell_ids(bundle, encounter, encounter_id)
		_check_rogue_trap_spell(bundle, encounter, encounter_id)
	_check_special_scenario_items(bundle)


func _check_battle_monsters(bundle: ClassicCampaignBundle) -> void:
	var bestiary: Variant = _native_context.get("bestiary", {})
	if not (bestiary is Dictionary) or bestiary.is_empty():
		return
	var checked_ids: Dictionary = {}
	var battle_ids: Array = bundle.battles_by_id.keys()
	battle_ids.sort()
	for battle_id_value: Variant in battle_ids:
		var battle_id := int(battle_id_value)
		var battle: Dictionary = bundle.battles_by_id[battle_id_value]
		if not _producer_marks_callable(battle):
			continue
		var grid: Variant = battle.get("grid", [])
		if not (grid is Array):
			continue
		for cell_index: int in range(grid.size()):
			var monster_id: int = abs(int(grid[cell_index]))
			if monster_id == 0 or checked_ids.has(monster_id):
				continue
			checked_ids[monster_id] = true
			var monster := bundle.get_monster(monster_id)
			if monster.is_empty():
				_add_blocker(
					"missing-battle-monster",
					"Data BD",
					battle_id,
					cell_index,
					"Classic battle %d references missing monster %d" % [
						battle_id, monster_id,
					],
					{"referenceId": monster_id}
				)
				continue
			var native_name := _resolve_classic_monster_bestiary_name(
				monster_id, monster, bestiary
			)
			if native_name.is_empty():
				_add_blocker(
					"unresolved-native-monster",
					"Data BD",
					battle_id,
					cell_index,
					"Classic monster %d '%s' has no native bestiary equivalent" % [
						monster_id, str(monster.get("displayName", "")),
					],
					{"referenceId": monster_id}
				)
				continue
			_check_monster_materialization(
				bestiary[native_name],
				monster_id,
				"Data BD",
				battle_id,
				cell_index
			)


func _check_monster_materialization(
	native_entry: Variant,
	monster_id: int,
	source: String,
	record_index: int,
	slot: int,
	action := {}
) -> void:
	if not (native_entry is Dictionary):
		return
	var materialization: Variant = native_entry.get("classicMaterialization", {})
	if not (materialization is Dictionary):
		return
	var unsupported: Variant = materialization.get("unsupportedFields", [])
	if str(materialization.get("status", "")) == "blocked":
		var message := "Classic monster %d has unsupported native fields" % monster_id
		if unsupported is Array and not unsupported.is_empty():
			var field_names: Array[String] = []
			for field_name: Variant in unsupported:
				field_names.append(str(field_name))
			message += ": %s" % ", ".join(field_names)
		var extra := {"referenceId": monster_id, "unsupportedFields": unsupported}
		if action is Dictionary and not action.is_empty():
			_add_blocker_for_action(action, "unsupported-native-monster-fields", message, extra)
		else:
			_add_blocker(
				"unsupported-native-monster-fields",
				source,
				record_index,
				slot,
				message,
				extra
			)
		return
	var fallback_value: Variant = materialization.get("fidelityFallbacks", [])
	if not (fallback_value is Array) or fallback_value.is_empty():
		return
	var fallbacks: Array = fallback_value.duplicate()
	var icon_fallbacks: Array = fallbacks.filter(
		func(field_name: Variant) -> bool:
			return str(field_name).begins_with("iconId:")
	)
	for icon_fallback: Variant in icon_fallbacks:
		fallbacks.erase(icon_fallback)
	var icon_resolution: Variant = materialization.get("iconResolution", {})
	if icon_resolution is Dictionary and not icon_fallbacks.is_empty():
		var icon_status := str(icon_resolution.get("status", "unresolved"))
		var icon_message := (
			"Classic monster %d icon pair %d/%d is classified as %s; "
			+ "Remake currently uses its native placeholder"
		) % [
			monster_id,
			int(icon_resolution.get("baseIconId", 0)),
			int(icon_resolution.get("pairedIconId", 0)),
			icon_status,
		]
		var icon_extra := {
			"referenceId": monster_id,
			"iconResolution": icon_resolution,
			"fallbackFields": icon_fallbacks,
		}
		if action is Dictionary and not action.is_empty():
			_add_fallback_for_action(
				action,
				"classic-monster-icon-%s" % icon_status,
				icon_message,
				icon_extra
			)
		else:
			_add_fallback(
				"classic-monster-icon-%s" % icon_status,
				source,
				record_index,
				slot,
				icon_message,
				icon_extra
			)
	if fallbacks.is_empty():
		return
	var fallback_message := "Classic monster %d uses native fidelity fallbacks" % monster_id
	var fallback_extra := {"referenceId": monster_id, "fallbackFields": fallbacks}
	if action is Dictionary and not action.is_empty():
		_add_fallback_for_action(
			action,
			"native-monster-fidelity-fallback",
			fallback_message,
			fallback_extra
		)
	else:
		_add_fallback(
			"native-monster-fidelity-fallback",
			source,
			record_index,
			slot,
			fallback_message,
			fallback_extra
		)


func _check_item_ids(
	bundle: ClassicCampaignBundle,
	encounter: Dictionary,
	encounter_id: int
) -> void:
	var item_ids: Variant = encounter.get("itemIds", [])
	if not (item_ids is Array):
		return
	for item_id_value: Variant in item_ids:
		var raw_item_id := int(item_id_value)
		if raw_item_id in [0, -1]:
			continue
		var item_id: int = abs(raw_item_id)
		if bundle.is_empty_scenario_item(item_id):
			continue
		var native_items: Variant = _native_context.get("items", {})
		var item_book: Dictionary = native_items if native_items is Dictionary else {}
		if not (native_items is Dictionary) or native_items.is_empty():
			continue
		var native_item := _native_item_for_classic_id(item_id, item_book)
		if native_item.is_empty():
			_add_blocker(
				"missing-native-item",
				"Data ED2",
				encounter_id,
				-1,
				(
					"Complex encounter item %d has no native Remake resource "
					+ "with explicit Classic identity metadata"
				) % item_id,
				{"referenceId": item_id}
			)
			continue
		var materialization: Variant = native_item.get("classicMaterialization", {})
		if materialization is Dictionary \
				and str(materialization.get("status", "")) == "blocked":
			_add_blocker(
				"unsupported-native-item-fields",
				"Data ED2",
				encounter_id,
				-1,
				"Complex encounter item %d has unsupported native fields" % item_id,
				{
					"referenceId": item_id,
					"unsupportedFields": materialization.get("unsupportedFields", []),
				}
			)


func _native_item_for_classic_id(
	item_id: int,
	native_items: Dictionary,
) -> Dictionary:
	for item_value: Variant in native_items.values():
		if not (item_value is Dictionary):
			continue
		var ids: Array[int] = []
		if item_value.has("classicItemId"):
			ids.append(abs(int(item_value["classicItemId"])))
		var aliases: Variant = item_value.get("classicItemIds", [])
		if aliases is Array:
			for alias_value: Variant in aliases:
				var alias_id: int = abs(int(alias_value))
				if alias_id != 0 and not ids.has(alias_id):
					ids.append(alias_id)
		if ids.has(item_id):
			return item_value
	return {}


func _check_spell_ids(
	bundle: ClassicCampaignBundle,
	encounter: Dictionary,
	encounter_id: int
) -> void:
	var spell_ids: Variant = encounter.get("spellIds", [])
	if not (spell_ids is Array):
		return
	var spell_results: Variant = encounter.get("spellResults", [])
	for spell_index: int in range(spell_ids.size()):
		var spell_id := int(spell_ids[spell_index])
		if spell_id in [0, 9999]:
			continue
		if _check_custom_spell_override(bundle, spell_id, "Data ED2", encounter_id):
			continue
		if spell_id > 0 and spell_id < 7:
			_check_spell_class(spell_id, encounter_id)
			continue
		if spell_id < 1101:
			continue
		var has_explicit_result: bool = (
			spell_results is Array and spell_index < spell_results.size()
		)
		var result_id := int(spell_results[spell_index]) if has_explicit_result else -1
		if (
			not SpellIdentityScript.is_valid_packed_id(spell_id)
			and has_explicit_result
			and result_id == 4
		):
			_add_fallback(
				"invalid-complex-spell-failure-sentinel",
				"Data ED2",
				encounter_id,
				spell_index,
				(
					"Complex encounter spell %d cannot be selected in Classic "
					+ "and already maps to the default failure result"
				) % spell_id,
				{"referenceId": spell_id}
			)
			continue
		var mapping_key := SpellIdentityScript.mapping_key(spell_id)
		if str(_spell_mapping.get(mapping_key, "")).is_empty():
			_add_blocker(
				"unresolved-spell-identity",
				"Data ED2",
				encounter_id,
				-1,
				"Complex encounter spell %d has no Remake identity" % spell_id,
				{"referenceId": spell_id}
			)


func _check_spell_class(spell_class: int, encounter_id: int) -> void:
	var spells: Variant = _native_context.get("spells", {})
	if not (spells is Dictionary) or spells.is_empty():
		return
	for spell_value: Variant in spells.values():
		if spell_value is Dictionary and int(spell_value.get("classicSpellClass", 0)) == spell_class:
			return
	_add_blocker(
		"missing-native-spell-class",
		"Data ED2",
		encounter_id,
		-1,
		"Complex encounter spell class %d has no native Remake resource" % spell_class,
		{"referenceId": spell_class}
	)


func _check_rogue_trap_spell(
	bundle: ClassicCampaignBundle,
	encounter: Dictionary,
	encounter_id: int
) -> void:
	if not bool(encounter.get("thief", false)):
		return
	var thief_id := int(encounter.get("thiefSuccess", -1))
	var thief_encounter := bundle.get_thief_encounter(thief_id)
	if thief_encounter.is_empty():
		return
	var spell_id := int(thief_encounter.get("spell", 0))
	if spell_id != 0:
		_check_native_effect_spell(bundle, spell_id, "Data TD2", thief_id, encounter_id)


func _check_special_scenario_items(bundle: ClassicCampaignBundle) -> void:
	var scenario_item_ids: Array = bundle.scenario_items_by_id.keys()
	scenario_item_ids.sort()
	for item_id_value: Variant in scenario_item_ids:
		var item_id := int(item_id_value)
		var item: Dictionary = bundle.scenario_items_by_id[item_id_value]
		var item_type := int(item.get("type", 0))
		var special1 := int(item.get("special1", 0))
		if item_type == 20:
			var spell_id: int = abs(int(item.get("special2", 0)))
			if spell_id == 0:
				_add_blocker(
					"invalid-scenario-spell-item",
					"Data NI",
					item_id,
					-1,
					"Scenario spell item %d has no spell ID" % item_id,
					{"referenceId": item_id}
				)
			elif (
				not SpellIdentityScript.is_valid_packed_id(spell_id)
				and bundle.get_spell_override(spell_id).is_empty()
				and _scenario_item_text_is_blank(bundle, item_id)
			):
				_add_fallback(
					"invalid-scenario-spell-item-fallback",
					"Data NI",
					item_id,
					-1,
					(
						"Unnamed scenario spell item %d has impossible packed spell ID %d; "
						+ "it remains an inert preserved item"
					) % [item_id, spell_id],
					{"referenceId": spell_id, "ownerId": item_id}
				)
			else:
				_check_native_effect_spell(bundle, spell_id, "Data NI", item_id, item_id)
		if abs(item_type) == 23 or special1 == -23:
			var action_point_id: int = abs(int(item.get("special5", 0)))
			if bundle.get_extra_action_point(action_point_id).is_empty():
				_add_blocker(
					"missing-door-action-point",
					"Data NI",
					item_id,
					-1,
					"Scenario door item %d references missing Data ED3 action point %d" % [
						item_id, action_point_id,
					],
					{"referenceId": action_point_id}
				)


func _scenario_item_text_is_blank(bundle: ClassicCampaignBundle, item_id: int) -> bool:
	var item_text := bundle.get_item_text(item_id)
	return (
		str(item_text.get("identifiedName", "")).strip_edges().is_empty()
		and str(item_text.get("unidentifiedName", "")).strip_edges().is_empty()
		and str(item_text.get("description", "")).strip_edges().is_empty()
	)


func _check_custom_spell_override(
	bundle: ClassicCampaignBundle,
	spell_id: int,
	usage_source: String,
	usage_record: int,
	owner_id := -1,
	consumer := ""
) -> bool:
	var spell_override := bundle.get_spell_override(spell_id)
	if spell_override.is_empty():
		return false
	var record_id := int(spell_override.get("id", -1))
	var packed_spell_id := BundleScript.packed_spell_id_for_record_id(record_id)
	_active_custom_spell_ids[packed_spell_id] = true
	var special: int = abs(int(spell_override.get("special", 0)))
	if CustomSpellSupportScript.is_executable(spell_override):
		return true
	if _has_exact_native_spell(spell_id):
		return true
	var provenance: Variant = spell_override.get("provenance", {})
	var source := "rules.spellOverrides"
	var record_index := spell_id
	if provenance is Dictionary:
		source = str(provenance.get("sourceFile", source))
		record_index = int(provenance.get("recordIndex", record_index))
	_add_blocker(
		"unsupported-custom-spell-special",
		source,
		record_index,
		-1,
		"Custom spell %d uses unsupported special behavior %d" % [spell_id, special],
		{
			"referenceId": packed_spell_id,
			"special": special,
			"usageSource": usage_source,
			"usageRecordIndex": usage_record,
			"ownerId": owner_id,
			"consumer": consumer if not consumer.is_empty() else (
				"%s record %d" % [usage_source, usage_record]
			),
			"definitionStableId": "%s:spell:%d" % [_campaign_id, record_id],
		}
	)
	return true


func _check_inactive_custom_spell_definitions(bundle: ClassicCampaignBundle) -> void:
	var spell_ids: Array = bundle.spell_overrides_by_id.keys()
	spell_ids.sort()
	for spell_id_value: Variant in spell_ids:
		var packed_spell_id := int(spell_id_value)
		var record: Dictionary = bundle.spell_overrides_by_id[spell_id_value]
		if _is_empty_custom_spell_definition(record) \
				or _active_custom_spell_ids.has(packed_spell_id):
			continue
		var record_id := int(record.get("id", -1))
		var provenance: Variant = record.get("provenance", {})
		var source := "Data Spell"
		var source_record := record_id
		if provenance is Dictionary:
			source = str(provenance.get("sourceFile", source))
			source_record = int(provenance.get("recordIndex", source_record))
		_add_fallback(
			"inactive-custom-spell-definition",
			source,
			source_record,
			-1,
			"Custom spell %d is preserved but has no active bundle consumer" % packed_spell_id,
			{
				"referenceId": packed_spell_id,
				"special": int(record.get("special", 0)),
				"consumer": "none",
				"definitionStableId": "%s:spell:%d" % [_campaign_id, record_id],
			}
		)


func _is_empty_custom_spell_definition(record: Dictionary) -> bool:
	for field_name: String in SPELL_DEFINITION_FIELDS:
		if int(record.get(field_name, 0)) != 0:
			return false
	return true


func _check_rule_table_selection(bundle: ClassicCampaignBundle) -> void:
	var rules: Variant = bundle.documents.get("rules", {})
	if not (rules is Dictionary) or not rules.has("tableSelection"):
		return
	var selection: Variant = rules.get("tableSelection", {})
	if not (selection is Dictionary):
		return
	for specification: Array in [
		["races", "raceOverrides", "Data Race"],
		["castes", "casteOverrides", "Data Caste"],
	]:
		var table_name := str(specification[0])
		var records: Variant = rules.get(str(specification[1]), [])
		if not (records is Array) or records.is_empty():
			continue
		var table: Variant = selection.get(table_name, {})
		if not (table is Dictionary):
			continue
		var source := str(table.get("source", "unresolved"))
		var changed: Variant = table.get("changedRecordIds", [])
		if source == "shared":
			_add_fallback(
				"inactive-scenario-rule-table",
				str(specification[2]),
				-1,
				-1,
				"Scenario-local %s definitions are inactive because Classic selects the shared table"
					% table_name,
				{"consumer": "Classic loadprofile", "table": table_name}
			)
		elif source == "scenario-local" and changed is Array and changed.is_empty():
			_add_fallback(
				"no-op-scenario-rule-table",
				str(specification[2]),
				-1,
				-1,
				"Scenario-local %s table matches the shared table" % table_name,
				{"consumer": "Classic loadprofile", "table": table_name}
			)
		elif source == "unresolved":
			_add_fallback(
				"unresolved-rule-table-selection",
				str(specification[2]),
				-1,
				-1,
				"Producer did not resolve whether Classic selects the %s table" % table_name,
				{"consumer": "Classic loadprofile", "table": table_name}
			)


func _check_active_monster_spells(
	bundle: ClassicCampaignBundle,
	execution_report: Dictionary
) -> void:
	var contexts: Dictionary = {}
	for battle_value: Variant in bundle.battles_by_id.values():
		if not (battle_value is Dictionary):
			continue
		if not _producer_marks_callable(battle_value):
			continue
		var grid: Variant = battle_value.get("grid", [])
		if not (grid is Array):
			continue
		for monster_id_value: Variant in grid:
			_add_monster_spell_context(contexts, abs(int(monster_id_value)), "combatant")
	for action_value: Variant in execution_report.get("actions", []):
		if not (action_value is Dictionary) or not bool(action_value.get("executable", false)):
			continue
		var action: Dictionary = action_value
		var code := int(action.get("code", 0))
		if code == 89:
			_add_monster_spell_context(contexts, abs(int(action.get("id", 0))), "ally")
		elif code == 124:
			var extra_code := bundle.get_extra_code(int(action.get("id", 0)))
			var values: Variant = extra_code.get("values", [])
			if values is Array and values.size() > 1:
				_add_monster_spell_context(
					contexts, abs(int(values[1])), "summoned-combatant"
				)
	var monster_ids: Array = contexts.keys()
	monster_ids.sort()
	for monster_id_value: Variant in monster_ids:
		var monster_id := int(monster_id_value)
		var monster := bundle.get_monster(monster_id)
		var spell_ids: Variant = monster.get("spells", [])
		if not (spell_ids is Array):
			continue
		for slot: int in range(spell_ids.size()):
			var spell_id := int(spell_ids[slot])
			if spell_id in [0, 9999]:
				continue
			_check_native_effect_spell(
				bundle,
				spell_id,
				"Data MD",
				monster_id,
				monster_id,
				"monster %d %s spell slot %d" % [
					monster_id,
					", ".join(contexts[monster_id_value]),
					slot,
				]
			)


func _add_monster_spell_context(
	contexts: Dictionary,
	monster_id: int,
	context: String
) -> void:
	if monster_id <= 0:
		return
	if not contexts.has(monster_id):
		contexts[monster_id] = []
	if context not in contexts[monster_id]:
		contexts[monster_id].append(context)


func _producer_marks_callable(record: Dictionary) -> bool:
	if record.has("callable"):
		return bool(record["callable"])
	if record.has("authored"):
		return bool(record["authored"])
	# Version 1 producers originally emitted every parsed catalog record without
	# callability or authored metadata. Preserve the conservative legacy
	# readiness behavior for those packages.
	return true


func _has_exact_native_spell(spell_id: int) -> bool:
	var spells: Variant = _native_context.get("spells", {})
	if not (spells is Dictionary):
		return false
	var resource_name := SpellIdentityScript.resource_key(spell_id, _spell_mapping, spells)
	if resource_name.is_empty():
		return false
	var metadata: Variant = spells.get(resource_name, {})
	if not (metadata is Dictionary):
		return false
	var supported_ids: Variant = metadata.get("classicSpellIds", [])
	return supported_ids is Array and spell_id in supported_ids


func _check_native_effect_spell(
	bundle: ClassicCampaignBundle,
	spell_id: int,
	source: String,
	record_index: int,
	owner_id: int,
	consumer := ""
) -> void:
	if _check_custom_spell_override(
		bundle, spell_id, source, record_index, owner_id, consumer
	):
		return
	var mapping_key := SpellIdentityScript.mapping_key(spell_id)
	var spell_name := str(_spell_mapping.get(mapping_key, _spell_mapping.get(spell_id, "")))
	if spell_name.is_empty():
		_add_blocker(
			"unresolved-spell-identity",
			source,
			record_index,
			-1,
			"Classic spell %d has no Remake mapping" % spell_id,
			{"referenceId": spell_id, "ownerId": owner_id}
		)
		return
	var spells: Variant = _native_context.get("spells", {})
	if not (spells is Dictionary) or spells.is_empty():
		return
	var resource_name := SpellIdentityScript.resource_key(spell_id, _spell_mapping, spells)
	if resource_name.is_empty():
		var code := "missing-native-spell"
		var message := "Mapped spell '%s' has no executable Remake resource" % spell_name
		if spells.has(spell_name):
			code = "unsupported-native-spell-variant"
			message = "Mapped spell '%s' does not represent Classic spell %d" % [
				spell_name, spell_id,
			]
		_add_blocker(
			code,
			source,
			record_index,
			-1,
			message,
			{"referenceId": spell_id, "nativeName": spell_name, "ownerId": owner_id}
		)
		return
	var metadata: Variant = spells.get(resource_name, {})
	var save_index := int(metadata.get("classicSpellSaveIndex", -2)) \
		if metadata is Dictionary else -2
	var save_mode := str(metadata.get("classicSpellSaveMode", "")) \
		if metadata is Dictionary else ""
	if save_mode not in ["none", "negate", "half_damage"] \
			or (save_mode != "none" and (save_index < 0 or save_index > 7)):
		_add_blocker(
			"missing-native-spell-save-metadata",
			source,
			record_index,
			-1,
			"Mapped spell '%s' has no executable Classic save behavior" % spell_name,
			{"referenceId": spell_id, "nativeName": spell_name, "ownerId": owner_id}
		)


func _add_action_dependency(
	action: Dictionary,
	code: String,
	message: String,
	extra := {}
) -> void:
	if bool(action.get("executable", false)):
		_add_blocker_for_action(action, code, message, extra)
	else:
		_add_fallback_for_action(action, code, message, extra)


func _picture_file_candidates(payload: Dictionary) -> Array:
	var candidates: Array = []
	var picture: Variant = payload.get("picture", {})
	if picture is Dictionary:
		for field_name: String in ["fileName", "relativePath", "path", "name"]:
			var field_value: Variant = picture.get(field_name)
			if field_value is String:
				_append_picture_candidate(candidates, field_value)
	var picture_id := int(payload.get("pictureId", 0))
	if picture_id != 0:
		_append_picture_candidate(candidates, "%d.png" % absi(picture_id))
	return candidates


func _append_picture_candidate(candidates: Array, value: String) -> void:
	var file_name := value.strip_edges().replace("\\", "/")
	if file_name.begins_with("Splash Images/"):
		file_name = file_name.trim_prefix("Splash Images/")
	if file_name.is_empty() or file_name.is_absolute_path():
		return
	var path_parts := file_name.split("/", false)
	if path_parts.has("..") or candidates.has(file_name):
		return
	candidates.append(file_name)


func _resolve_classic_monster_bestiary_name(
	monster_id: int,
	monster: Dictionary,
	creature_book: Dictionary
) -> String:
	var display_name := str(monster.get("displayName", ""))
	var name_matches: Array[String] = []
	for bestiary_key: Variant in creature_book:
		var entry: Variant = creature_book[bestiary_key]
		if not (entry is Dictionary):
			continue
		var data: Variant = entry.get("data", {})
		if not (data is Dictionary):
			continue
		var explicit_ids := _classic_resource_ids(
			entry,
			"classicMonsterId",
			"classicMonsterIds"
		)
		explicit_ids.append_array(
			_classic_resource_ids(
				data,
				"classicMonsterId",
				"classicMonsterIds"
			)
		)
		if not explicit_ids.is_empty() and explicit_ids.has(monster_id):
			return str(bestiary_key)
	for bestiary_key: Variant in creature_book:
		var entry: Variant = creature_book[bestiary_key]
		if not (entry is Dictionary):
			continue
		var data: Variant = entry.get("data", {})
		if not (data is Dictionary):
			continue
		var explicit_ids := _classic_resource_ids(
			entry,
			"classicMonsterId",
			"classicMonsterIds"
		)
		explicit_ids.append_array(
			_classic_resource_ids(
				data,
				"classicMonsterId",
				"classicMonsterIds"
			)
		)
		if not explicit_ids.is_empty():
			continue
		var native_id: Variant = data.get("id")
		if (native_id is int or native_id is float) \
				and absi(int(native_id)) == monster_id:
			return str(bestiary_key)
		var native_name := str(data.get("name", bestiary_key))
		if not display_name.is_empty() \
				and native_name.to_lower() == display_name.to_lower():
			name_matches.append(str(bestiary_key))
	return name_matches[0] if name_matches.size() == 1 else ""


func _classic_resource_ids(
	resource: Dictionary,
	singular_field: String,
	plural_field: String
) -> Array[int]:
	var ids: Array[int] = []
	if resource.has(singular_field):
		ids.append(absi(int(resource[singular_field])))
	var plural_value: Variant = resource.get(plural_field, [])
	if plural_value is Array:
		for id_value: Variant in plural_value:
			var resource_id := absi(int(id_value))
			if not ids.has(resource_id):
				ids.append(resource_id)
	return ids


func _add_blocker_for_action(
	action: Dictionary,
	code: String,
	message: String,
	extra := {}
) -> void:
	_add_action_diagnostic(action, "error", BLOCKER, code, message, extra)


func _add_fallback_for_action(
	action: Dictionary,
	code: String,
	message: String,
	extra := {}
) -> void:
	_add_action_diagnostic(action, "warning", FALLBACK, code, message, extra)


func _add_media_diagnostic_for_action(
	action: Dictionary,
	code: String,
	message: String,
	extra := {}
) -> void:
	if (
		bool(action.get("executable", false))
		and bool(action.get("mediaRequiredForProgression", false))
	):
		_add_blocker_for_action(action, code, message, extra)
	else:
		_add_fallback_for_action(action, code, message, extra)


func _add_source_behavior_for_action(
	action: Dictionary,
	code: String,
	message: String,
	extra := {}
) -> void:
	_add_action_diagnostic(action, "info", SOURCE_BEHAVIOR, code, message, extra)


func _add_action_diagnostic(
	action: Dictionary,
	severity: String,
	classification: String,
	code: String,
	message: String,
	extra := {}
) -> void:
	var diagnostic := {
		"severity": severity,
		"classification": classification,
		"code": code,
		"source": str(action.get("source", "")),
		"recordId": str(action.get("recordId", "")),
		"recordIndex": int(action.get("recordIndex", -1)),
		"slot": int(action.get("slot", -1)),
		"opcode": int(action.get("code", 0)),
		"message": message,
	}
	if extra is Dictionary:
		diagnostic.merge(extra, true)
	_add_diagnostic(diagnostic)


func _add_blocker(
	code: String,
	source: String,
	record_index: int,
	slot: int,
	message: String,
	extra := {}
) -> void:
	var diagnostic := {
		"severity": "error",
		"classification": BLOCKER,
		"code": code,
		"source": source,
		"recordIndex": record_index,
		"message": message,
	}
	if slot >= 0:
		diagnostic["slot"] = slot
	if extra is Dictionary:
		diagnostic.merge(extra, true)
	_add_diagnostic(diagnostic)


func _add_fallback(
	code: String,
	source: String,
	record_index: int,
	slot: int,
	message: String,
	extra := {}
) -> void:
	var diagnostic := {
		"severity": "warning",
		"classification": FALLBACK,
		"code": code,
		"source": source,
		"recordIndex": record_index,
		"message": message,
	}
	if slot >= 0:
		diagnostic["slot"] = slot
	if extra is Dictionary:
		diagnostic.merge(extra, true)
	_add_diagnostic(diagnostic)


func _add_diagnostic(diagnostic: Dictionary) -> void:
	if not diagnostic.has("activity"):
		var code := str(diagnostic.get("code", ""))
		diagnostic["activity"] = (
			"inactive"
			if code.begins_with("inactive-") or code in INACTIVE_DIAGNOSTIC_CODES
			else "active"
		)
	if not _campaign_id.is_empty():
		diagnostic["campaignId"] = _campaign_id
	if not _campaign_name.is_empty():
		diagnostic["scenario"] = _campaign_name
	var key := "%s:%s:%s:%d:%d:%s" % [
		str(diagnostic.get("code", "")),
		str(diagnostic.get("source", "")),
		str(diagnostic.get("recordId", "")),
		int(diagnostic.get("recordIndex", -1)),
		int(diagnostic.get("slot", -1)),
		str(diagnostic.get("referenceId", diagnostic.get("resourceId", ""))),
	]
	if _diagnostic_keys.has(key):
		return
	_diagnostic_keys[key] = true
	_diagnostics.append(diagnostic)


func _build_report(bundle: ClassicCampaignBundle, execution_report: Dictionary) -> Dictionary:
	var blocker_count := 0
	var fallback_count := 0
	for diagnostic_value: Variant in _diagnostics:
		if not (diagnostic_value is Dictionary):
			continue
		if diagnostic_value.get("classification") == BLOCKER:
			blocker_count += 1
		elif diagnostic_value.get("classification") == FALLBACK:
			fallback_count += 1
	var ready := blocker_count == 0
	var summary := "Ready: no progression blockers; %d fidelity fallback%s." % [
		fallback_count, "" if fallback_count == 1 else "s",
	]
	if not ready:
		summary = "Blocked: %d progression blocker%s; %d fidelity fallback%s." % [
			blocker_count,
			"" if blocker_count == 1 else "s",
			fallback_count,
			"" if fallback_count == 1 else "s",
		]
	return {
		"schemaVersion": SCHEMA_VERSION,
		"campaign": {
			"id": str(bundle.manifest.get("id", "")),
			"name": str(bundle.manifest.get("name", "Unknown Classic campaign")),
		},
		"ready": ready,
		"status": "ready" if ready else "blocked",
		"summary": summary,
		"totals": {
			"progressionBlockers": blocker_count,
			"fidelityFallbacks": fallback_count,
			"diagnostics": _diagnostics.size(),
		},
		"diagnostics": _diagnostics.duplicate(true),
		"execution": execution_report.get("totals", {}),
	}


func _is_schema_error(message: String) -> bool:
	var lower := message.to_lower()
	return lower.contains("schema") \
		or lower.contains("format") \
		or lower.contains("compatibility profile") \
		or lower.contains("campaignkind")
