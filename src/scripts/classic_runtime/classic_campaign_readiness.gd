class_name ClassicCampaignReadiness
extends RefCounted

const BundleScript = preload("res://scripts/classic_runtime/classic_campaign_bundle.gd")
const ExecutionAuditScript = preload("res://scripts/classic_runtime/classic_execution_audit.gd")
const GodotAdapterScript = preload(
	"res://scripts/classic_runtime/classic_godot_command_adapter.gd"
)
const ItemIdsScript = preload("res://scripts/item_id_divinity.gd")
const SpellIdsScript = preload("res://scripts/spells_id_divinity.gd")
const SoundIdsScript = preload("res://scripts/sfx_id_divinity.gd")

const SCHEMA_VERSION := 1
const BLOCKER := "progression-blocker"
const FALLBACK := "fidelity-fallback"
const MAX_RANDOM_TARGETS := 10000

# These opcodes interpret their ID as an exact Data EDCD row number.
const EXTRA_CODE_OPCODES := [
	2, 3, 7, 12, 13, 15, 16, 17, 18, 19, 20, 21, 22, -23, 23,
	30, 33, 37, 38, 40, 41, 42, 43, 44, 45, 46, 48, 52, 54, 56, 57,
	58, 73, 85, 87, 106, 121, 123, 124, 125, 126,
]

var _diagnostics: Array = []
var _diagnostic_keys: Dictionary = {}
var _item_mapping: Dictionary = {}
var _spell_mapping: Dictionary = {}
var _sound_mapping: Dictionary = {}
var _native_context: Dictionary = {}
var _adapter: ClassicGodotCommandAdapter


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
	var execution_report: Dictionary = ExecutionAuditScript.new().inspect(bundle)
	_append_execution_diagnostics(execution_report)
	_append_evidence_diagnostics(bundle)
	_check_start_map(bundle)

	for action_value: Variant in execution_report.get("actions", []):
		if action_value is Dictionary:
			_check_action(bundle, action_value)

	_check_encounter_identities(bundle)
	return _build_report(bundle, execution_report)


func _reset(native_context: Variant) -> void:
	_diagnostics.clear()
	_diagnostic_keys.clear()
	_native_context = native_context if native_context is Dictionary else {}
	_item_mapping = _mapping_from_script(ItemIdsScript, "mapping")
	_spell_mapping = _mapping_from_script(SpellIdsScript, "mappings")
	_sound_mapping = _mapping_from_script(SoundIdsScript, "mapping")
	_adapter = GodotAdapterScript.new()


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
		if source_severity == "info":
			continue
		var row: Dictionary = row_value.duplicate(true)
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
			_check_field_spell(action, extra_code)
		elif code == 85:
			_check_random_branch(bundle, action, extra_code)
		return

	match code:
		1:
			_check_direct_record(bundle.get_message(reference_id), action, "message", reference_id)
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
			_check_sound(action, reference_id)
		10:
			_check_direct_record(bundle.get_treasure(reference_id), action, "treasure", reference_id)
		27:
			_check_picture(bundle, action, reference_id)
		29:
			_check_player_map(bundle, action, reference_id)
		89:
			_check_ally(bundle, action, reference_id)
		127:
			_check_direct_record(bundle.get_monster(reference_id), action, "monster", reference_id)


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
		_add_fallback_for_action(
			action,
			"missing-picture",
			"Picture %d has no exported catalog record" % abs(picture_id),
			{"resourceId": abs(picture_id)}
		)
		return
	var payload_path := str(picture.get("payloadPath", "")).strip_edges()
	if payload_path.is_empty():
		_add_fallback_for_action(
			action,
			"missing-picture-payload",
			"Picture %d is metadata-only and will not be shown" % abs(picture_id),
			{"resourceId": abs(picture_id)}
		)
	elif not FileAccess.file_exists(bundle.root_directory.path_join(payload_path)):
		_add_fallback_for_action(
			action,
			"missing-picture-file",
			"Picture %d payload '%s' is missing" % [abs(picture_id), payload_path],
			{"resourceId": abs(picture_id), "payloadPath": payload_path}
		)


func _check_sound(action: Dictionary, sound_id: int) -> void:
	var sound_name := str(_sound_mapping.get(sound_id, ""))
	if sound_name.is_empty():
		_add_fallback_for_action(
			action,
			"unresolved-sound-identity",
			"Sound %d has no Remake mapping" % sound_id,
			{"resourceId": sound_id}
		)
		return
	var sounds: Variant = _native_context.get("sounds", {})
	if sounds is Dictionary and not sounds.is_empty() and not sounds.has(sound_name):
		_add_fallback_for_action(
			action,
			"missing-native-sound",
			"Mapped sound '%s' is not available to Remake" % sound_name,
			{"resourceId": sound_id, "nativeName": sound_name}
		)


func _check_player_map(
	bundle: ClassicCampaignBundle,
	action: Dictionary,
	map_id: int
) -> void:
	if not bundle.get_player_map(map_id).is_empty():
		return
	_add_fallback_for_action(
		action,
		"missing-player-map",
		"Player map %d is unavailable" % abs(map_id),
		{"referenceId": abs(map_id)}
	)


func _check_ally(bundle: ClassicCampaignBundle, action: Dictionary, monster_id: int) -> void:
	var monster := bundle.get_monster(monster_id)
	if monster.is_empty():
		_check_direct_record(monster, action, "monster", monster_id)
		return
	var bestiary: Variant = _native_context.get("bestiary", {})
	if not (bestiary is Dictionary) or bestiary.is_empty():
		return
	var native_name := _adapter.resolve_classic_monster_bestiary_name(
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


func _check_field_spell(action: Dictionary, extra_code: Dictionary) -> void:
	var values: Variant = extra_code.get("values", [])
	if not (values is Array) or values.size() < 5:
		_add_blocker_for_action(
			action,
			"malformed-extra-code",
			"Field-spell Data EDCD record has fewer than five values",
			{"referenceId": int(extra_code.get("id", -1))}
		)
		return
	var spell_id := int(values[0])
	var mapping_key := _adapter.classic_spell_mapping_key(spell_id)
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
		if spells is Dictionary and not spells.is_empty() and not spells.has(spell_name):
			_add_blocker_for_action(
				action,
				"missing-native-spell",
				"Mapped spell '%s' has no executable Remake resource" % spell_name,
				{"referenceId": spell_id, "nativeName": spell_name}
			)
	if int(values[2]) != 0 or int(values[3]) != 0:
		_add_blocker_for_action(
			action,
			"unsupported-field-spell-metadata",
			"Field spell %d requires save adjustment %d and force-affect %s" % [
				spell_id, int(values[2]), str(int(values[3]) != 0),
			],
			{
				"referenceId": spell_id,
				"saveAdjustment": int(values[2]),
				"forceAffect": int(values[3]) != 0,
			}
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
	var encounter_ids: Array = bundle.complex_encounters_by_id.keys()
	encounter_ids.sort()
	for encounter_id_value: Variant in encounter_ids:
		var encounter_id := int(encounter_id_value)
		var encounter: Dictionary = bundle.complex_encounters_by_id[encounter_id_value]
		_check_item_ids(bundle, encounter, encounter_id)
		_check_spell_ids(encounter, encounter_id)


func _check_item_ids(
	bundle: ClassicCampaignBundle,
	encounter: Dictionary,
	encounter_id: int
) -> void:
	var item_ids: Variant = encounter.get("itemIds", [])
	if not (item_ids is Array):
		return
	var item_texts: Array = []
	var content: Variant = bundle.documents.get("content", {})
	if content is Dictionary and content.get("itemTexts", []) is Array:
		item_texts = content.get("itemTexts", [])
	for item_id_value: Variant in item_ids:
		var raw_item_id := int(item_id_value)
		if raw_item_id in [0, -1]:
			continue
		var item_id: int = abs(raw_item_id)
		var names: Array = _adapter._classic_item_names(
			item_id, _item_mapping, item_texts
		)
		if names.is_empty():
			_add_blocker(
				"unresolved-item-identity",
				"Data ED2",
				encounter_id,
				-1,
				"Complex encounter item %d has no Remake identity" % item_id,
				{"referenceId": item_id}
			)
			continue
		var native_items: Variant = _native_context.get("items", {})
		if not (native_items is Dictionary) or native_items.is_empty():
			continue
		var has_native_item := false
		for item_name: String in names:
			if native_items.has(item_name):
				has_native_item = true
				break
		if not has_native_item:
			_add_blocker(
				"missing-native-item",
				"Data ED2",
				encounter_id,
				-1,
				"Complex encounter item %d has no native Remake resource" % item_id,
				{"referenceId": item_id, "candidateNames": names}
			)


func _check_spell_ids(encounter: Dictionary, encounter_id: int) -> void:
	var spell_ids: Variant = encounter.get("spellIds", [])
	if not (spell_ids is Array):
		return
	for spell_id_value: Variant in spell_ids:
		var spell_id := int(spell_id_value)
		if spell_id in [0, 9999] or spell_id < 1101:
			continue
		var mapping_key := _adapter.classic_spell_mapping_key(spell_id)
		if str(_spell_mapping.get(mapping_key, "")).is_empty():
			_add_blocker(
				"unresolved-spell-identity",
				"Data ED2",
				encounter_id,
				-1,
				"Complex encounter spell %d has no Remake identity" % spell_id,
				{"referenceId": spell_id}
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


func _add_diagnostic(diagnostic: Dictionary) -> void:
	var key := "%s:%s:%d:%d:%s" % [
		str(diagnostic.get("code", "")),
		str(diagnostic.get("source", "")),
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
