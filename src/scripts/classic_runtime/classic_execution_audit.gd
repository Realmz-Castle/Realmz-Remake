class_name ClassicExecutionAudit
extends RefCounted

const InterpreterScript = preload("res://scripts/classic_runtime/classic_action_interpreter.gd")


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
			bool(trigger.get("active", true)) or trigger_contexts.size() > 1,
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
			true,
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
	for action_value: Variant in record_actions:
		if not (action_value is Dictionary):
			continue
		var raw_code := int(action_value.get("rawCode", 0))
		var code := InterpreterScript.normalize_opcode(raw_code)
		var support := "unknown"
		if InterpreterScript.handles_opcode(code):
			support = "fixture-proven-handler"
		elif bundle.is_dispatcher_noop(record, action_value):
			support = "source-backed-noop"
		var slot := int(action_value.get("slot", -1))
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
			"executable": executable,
			"support": support,
		}
		if storage_context in ["data-ed-result", "data-ed2-result"]:
			entry["result"] = floori(float(slot) / 8.0) + 1
			entry["resultSlot"] = slot % 8
		actions.append(entry)
		if executable and support == "unknown":
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
	if not bool(target_record.get("active", true)):
		diagnostics.append({
			"severity": "warning",
			"code": "inactive-macro-target",
			"source": source,
			"recordIndex": record_index,
			"target": target,
			"message": "%s record %d reaches inactive Data ED3 record %d" % [
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
