class_name ClassicExecutionAudit
extends RefCounted

const InterpreterScript = preload(
	"res://scripts/scenario_runtime/handlers/classic_opcode_runtime.gd"
)


func inspect(bundle: ClassicCampaignBundle) -> Dictionary:
	var diagnostics: Array = []
	var roots: Array = []
	var root_contexts := _collect_macro_roots(bundle, roots, diagnostics)
	var actions: Array = []

	var trigger_ids: Array = bundle.triggers_by_id.keys()
	trigger_ids.sort()
	for trigger_id: Variant in trigger_ids:
		var trigger: Dictionary = bundle.triggers_by_id[trigger_id]
		var storage_context := (
			"data-ed3-xap" if str(trigger.get("source", "")) == "Data ED3" else "map-trigger"
		)
		var trigger_contexts: Array = [storage_context]
		if storage_context == "data-ed3-xap":
			for context: Variant in root_contexts.get(int(trigger.get("recordIndex", -1)), []):
				if not trigger_contexts.has(context):
					trigger_contexts.append(context)
		_append_record_actions(
			bundle,
			trigger,
			storage_context,
			trigger_contexts,
			_trigger_is_executable(trigger, storage_context, trigger_contexts),
			actions,
			diagnostics
		)

	_append_encounter_actions(
		bundle,
		bundle.simple_encounters_by_id,
		"Data ED",
		"data-ed-result",
		actions,
		diagnostics
	)
	_append_encounter_actions(
		bundle,
		bundle.complex_encounters_by_id,
		"Data ED2",
		"data-ed2-result",
		actions,
		diagnostics
	)

	return {
		"actions": actions,
		"roots": roots,
		"contexts": _summarize_contexts(actions),
		"diagnostics": diagnostics,
		"totals": _summarize_totals(actions, diagnostics),
	}


func _trigger_is_executable(
	trigger: Dictionary,
	storage_context: String,
	execution_contexts: Array
) -> bool:
	if storage_context != "data-ed3-xap":
		return bool(trigger.get("active", true))
	return _producer_marks_callable(trigger) or execution_contexts.size() > 1


func _producer_marks_callable(trigger: Dictionary) -> bool:
	if trigger.has("callable"):
		return bool(trigger["callable"])
	if trigger.has("authored") and not bool(trigger["authored"]):
		return false
	# Version 1 producers originally exposed only `active`. Keep those bundles
	# conservative: a non-empty legacy row remains part of the readiness audit.
	return bool(trigger.get("active", true))


func _has_linear_fallthrough(bundle: ClassicCampaignBundle, action: Dictionary) -> bool:
	var raw_code := int(action.get("rawCode", 0))
	var code := InterpreterScript.normalize_opcode(raw_code)
	# A negative action begins a GOSUB. Its target can explicitly return to the
	# following slot, so only the positive branch form can make later slots dead.
	if raw_code < 0:
		return true
	if code == 64:
		return false
	if code in [77, 78]:
		var two_way_branch: Dictionary = bundle.get_extra_code(
			int(action.get("id", -1))
		)
		var branch_values: Variant = two_way_branch.get("values", [])
		return (
			not (branch_values is Array)
			or branch_values.size() < 5
			or int(branch_values[3]) == 0
			or int(branch_values[4]) == 0
		)
	if code != 21:
		return true
	var extra_code: Dictionary = bundle.get_extra_code(int(action.get("id", -1)))
	var values: Variant = extra_code.get("values", [])
	if not (values is Array) or values.size() < 5:
		return true
	var target_kind := int(values[1])
	var missing_item_mode := int(values[2])
	# Classic branches on possession for target kinds 0..2. When the item is
	# absent, mode 0 branches and mode 2 displays a message and exits. Only mode
	# 1 can fall through to the next action in the source record.
	return target_kind not in [0, 1, 2] or missing_item_mode == 1


func _append_encounter_actions(
	bundle: ClassicCampaignBundle,
	records_by_id: Dictionary,
	source: String,
	storage_context: String,
	actions: Array,
	diagnostics: Array
) -> void:
	var record_ids: Array = records_by_id.keys()
	record_ids.sort()
	for record_id_value: Variant in record_ids:
		var record_id := int(record_id_value)
		var encounter: Dictionary = records_by_id[record_id_value]
		var action_record := {
			"id": "%s:%d" % [storage_context, record_id],
			"source": source,
			"recordIndex": record_id,
			"actions": encounter.get("actions", []),
		}
		_append_record_actions(
			bundle,
			action_record,
			storage_context,
			[storage_context],
			_producer_marks_callable(encounter),
			actions,
			diagnostics
		)


func _append_record_actions(
	bundle: ClassicCampaignBundle,
	record: Dictionary,
	storage_context: String,
	execution_contexts: Array,
	executable: bool,
	actions: Array,
	diagnostics: Array
) -> void:
	var record_actions: Variant = record.get("actions", [])
	if not (record_actions is Array):
		return
	if not executable and not record_actions.is_empty():
		diagnostics.append({
			"severity": "warning",
			"code": "inactive-action-record",
			"source": str(record.get("source", "")),
			"recordIndex": int(record.get("recordIndex", -1)),
			"message": "%s record %d contains actions but has no active execution path" % [
				str(record.get("source", "Unknown source")),
				int(record.get("recordIndex", -1)),
			],
		})
	var flow_executable := executable
	var blocked_by_slot := -1
	var result_index := -1
	for action_value: Variant in record_actions:
		if not (action_value is Dictionary):
			continue
		var slot := int(action_value.get("slot", -1))
		if storage_context in ["data-ed-result", "data-ed2-result"]:
			var action_result_index := floori(float(slot) / 8.0)
			if action_result_index != result_index:
				result_index = action_result_index
				flow_executable = executable
				blocked_by_slot = -1
		var raw_code := int(action_value.get("rawCode", 0))
		var code := InterpreterScript.normalize_opcode(raw_code)
		var support := "unknown"
		if InterpreterScript.handles_opcode(code):
			support = "fixture-proven-handler"
		elif bundle.is_dispatcher_noop(record, action_value):
			support = "source-backed-noop"
		var entry := {
			"key": "%s:%d:%d:%d" % [
				str(record.get("source", "")),
				int(record.get("recordIndex", -1)),
				slot,
				raw_code,
			],
			"recordId": str(record.get("id", "")),
			"source": str(record.get("source", "")),
			"recordIndex": int(record.get("recordIndex", -1)),
			"slot": slot,
			"rawCode": raw_code,
			"code": code,
			"id": int(action_value.get("id", 0)),
			"storageContext": storage_context,
			"executionContexts": execution_contexts.duplicate(),
			"executable": flow_executable,
			"reachableWithinRecord": flow_executable,
			"support": support,
		}
		if blocked_by_slot >= 0:
			entry["blockedBySlot"] = blocked_by_slot
		if storage_context in ["data-ed-result", "data-ed2-result"]:
			entry["result"] = floori(float(slot) / 8.0) + 1
			entry["resultSlot"] = slot % 8
		if action_value.has("mediaRequiredForProgression"):
			entry["mediaRequiredForProgression"] = bool(
				action_value["mediaRequiredForProgression"]
			)
		actions.append(entry)
		if flow_executable and support == "unknown":
			diagnostics.append({
				"severity": "error",
				"code": "unsupported-action",
				"source": entry["source"],
				"recordIndex": entry["recordIndex"],
				"slot": slot,
				"opcode": code,
				"message": "Unsupported Classic opcode %d at %s record %d slot %d" % [
					code,
					entry["source"],
					entry["recordIndex"],
					slot,
				],
			})
		if flow_executable and not _has_linear_fallthrough(bundle, action_value):
			flow_executable = false
			blocked_by_slot = slot


func _collect_macro_roots(
	bundle: ClassicCampaignBundle,
	roots: Array,
	diagnostics: Array
) -> Dictionary:
	var contexts_by_target: Dictionary = {}
	var battle_ids: Array = bundle.battles_by_id.keys()
	battle_ids.sort()
	for battle_id_value: Variant in battle_ids:
		var battle: Dictionary = bundle.battles_by_id[battle_id_value]
		if not _producer_marks_callable(battle):
			continue
		var raw_target := int(battle.get("battleMacro", 0))
		if raw_target == 0:
			continue
		if raw_target > 0:
			roots.append({
				"kind": "battle-round-macro",
				"source": "Data BD",
				"recordIndex": int(battle_id_value),
				"rawTarget": raw_target,
				"status": "disabled-sentinel",
			})
			continue
		_add_macro_root(
			bundle,
			"battle-round-macro",
			"Data BD",
			int(battle_id_value),
			abs(raw_target),
			["battle-round-macro"],
			contexts_by_target,
			roots,
			diagnostics
		)

	var monster_ids: Array = bundle.monsters_by_id.keys()
	monster_ids.sort()
	for monster_id_value: Variant in monster_ids:
		var monster: Dictionary = bundle.monsters_by_id[monster_id_value]
		# Data MD uses hit dice 255 as the end of its authored monster catalog.
		# Imported files can retain unrelated trailing bytes after that marker.
		if int(monster.get("hitDice", 0)) == 255:
			break
		var target := int(monster.get("deathMacro", 0))
		if target == 0:
			continue
		if target < 0:
			roots.append({
				"kind": "death-macro",
				"source": "Data MD",
				"recordIndex": int(monster_id_value),
				"rawTarget": target,
				"status": "invalid-negative-target",
			})
			diagnostics.append({
				"severity": "error",
				"code": "invalid-death-macro",
				"source": "Data MD",
				"recordIndex": int(monster_id_value),
				"message": "Data MD record %d has invalid negative death macro %d" % [
					int(monster_id_value),
					target,
				],
			})
			continue
		_add_macro_root(
			bundle,
			"death-macro",
			"Data MD",
			int(monster_id_value),
			target,
			["death-macro", "queued-death-macro"],
			contexts_by_target,
			roots,
			diagnostics
		)
	return contexts_by_target


func _add_macro_root(
	bundle: ClassicCampaignBundle,
	kind: String,
	source: String,
	record_index: int,
	target: int,
	execution_contexts: Array,
	contexts_by_target: Dictionary,
	roots: Array,
	diagnostics: Array
) -> void:
	var target_record := bundle.get_extra_action_point(target)
	var status := "resolved" if not target_record.is_empty() else "missing-target"
	roots.append({
		"kind": kind,
		"source": source,
		"recordIndex": record_index,
		"target": target,
		"status": status,
		"executionContexts": execution_contexts.duplicate(),
	})
	if target_record.is_empty():
		diagnostics.append({
			"severity": "error",
			"code": "missing-macro-target",
			"source": source,
			"recordIndex": record_index,
			"target": target,
			"message": "%s record %d references missing Data ED3 record %d" % [
				source,
				record_index,
				target,
			],
		})
		return
	if not contexts_by_target.has(target):
		contexts_by_target[target] = []
	for context: Variant in execution_contexts:
		if not contexts_by_target[target].has(context):
			contexts_by_target[target].append(context)
	if not _producer_marks_callable(target_record):
		diagnostics.append({
			"severity": "warning",
			"code": "inactive-macro-target",
			"source": source,
			"recordIndex": record_index,
			"target": target,
			"message": "%s record %d reaches Data ED3 record %d not marked callable" % [
				source,
				record_index,
				target,
			],
		})


func _summarize_contexts(actions: Array) -> Dictionary:
	var contexts: Dictionary = {}
	for action_value: Variant in actions:
		if not (action_value is Dictionary):
			continue
		for context_value: Variant in action_value.get("executionContexts", []):
			var context := str(context_value)
			if not contexts.has(context):
				contexts[context] = {
					"actions": 0,
					"executable": 0,
					"inactive": 0,
					"fixtureProvenHandlers": 0,
					"sourceBackedNoops": 0,
					"unknown": 0,
					"unknownExecutable": 0,
				}
			var summary: Dictionary = contexts[context]
			summary["actions"] += 1
			if bool(action_value.get("executable", false)):
				summary["executable"] += 1
			else:
				summary["inactive"] += 1
			match str(action_value.get("support", "unknown")):
				"fixture-proven-handler":
					summary["fixtureProvenHandlers"] += 1
				"source-backed-noop":
					summary["sourceBackedNoops"] += 1
				_:
					summary["unknown"] += 1
					if bool(action_value.get("executable", false)):
						summary["unknownExecutable"] += 1
	return contexts


func _summarize_totals(actions: Array, diagnostics: Array) -> Dictionary:
	var totals := {
		"actions": actions.size(),
		"executable": 0,
		"inactive": 0,
		"fixtureProvenHandlers": 0,
		"sourceBackedNoops": 0,
		"unknown": 0,
		"unknownExecutable": 0,
		"diagnostics": diagnostics.size(),
	}
	for action_value: Variant in actions:
		if not (action_value is Dictionary):
			continue
		if bool(action_value.get("executable", false)):
			totals["executable"] += 1
		else:
			totals["inactive"] += 1
		match str(action_value.get("support", "unknown")):
			"fixture-proven-handler":
				totals["fixtureProvenHandlers"] += 1
			"source-backed-noop":
				totals["sourceBackedNoops"] += 1
			_:
				totals["unknown"] += 1
				if bool(action_value.get("executable", false)):
					totals["unknownExecutable"] += 1
	return totals
