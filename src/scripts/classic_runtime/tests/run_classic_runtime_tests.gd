extends SceneTree

const BundleScript = preload("res://scripts/classic_runtime/classic_campaign_bundle.gd")
const ExecutionAuditScript = preload("res://scripts/classic_runtime/classic_execution_audit.gd")
const ReadinessScript = preload("res://scripts/classic_runtime/classic_campaign_readiness.gd")
const StateScript = preload("res://scripts/classic_runtime/classic_runtime_state.gd")
const InterpreterScript = preload("res://scripts/classic_runtime/classic_action_interpreter.gd")
const CombatMacroQueueScript = preload(
	"res://scripts/classic_runtime/classic_combat_macro_queue.gd"
)
const RogueResolverScript = preload("res://scripts/classic_runtime/classic_rogue_encounter_resolver.gd")
const InventoryRulesScript = preload("res://scripts/classic_runtime/classic_inventory_rules.gd")
const CharacterConditionRulesScript = preload(
	"res://scripts/classic_runtime/classic_character_condition_rules.gd"
)
const MagicResistanceScript = preload(
	"res://scripts/classic_runtime/classic_magic_resistance.gd"
)
const ProjectileProtectionScript = preload(
	"res://scripts/classic_runtime/classic_projectile_protection.gd"
)
const RegenerationScript = preload(
	"res://scripts/classic_runtime/classic_regeneration.gd"
)
const SpellScreenScript = preload(
	"res://scripts/classic_runtime/classic_spell_screen.gd"
)
const SpellSavesScript = preload("res://scripts/classic_runtime/classic_spell_saves.gd")
const SpellUsageAuditScript = preload(
	"res://scripts/classic_runtime/classic_spell_usage_audit.gd"
)
const SpellResourceCatalogScript = preload(
	"res://scripts/classic_runtime/classic_spell_resource_catalog.gd"
)
const SpellIdentityScript = preload(
	"res://scripts/classic_runtime/classic_spell_identity.gd"
)
const LearnedSpellIdentityScript = preload(
	"res://scripts/classic_runtime/classic_learned_spell_identity.gd"
)
const CoreSpellCatalogScript = preload(
	"res://scripts/classic_runtime/classic_core_spell_catalog.gd"
)
const CoreSpellCoverageScript = preload(
	"res://scripts/classic_runtime/classic_core_spell_coverage.gd"
)
const EncounterResponseSpellScript = preload(
	"res://scripts/classic_runtime/classic_core_encounter_response_spell.gd"
)
const QueuedSpellRuntimeScript = preload(
	"res://scripts/classic_runtime/classic_queued_spell_runtime.gd"
)
const SpellAreaPatternsScript = preload(
	"res://scripts/classic_runtime/classic_spell_area_patterns.gd"
)
const MonsterTransformationScript = preload(
	"res://scripts/classic_runtime/classic_monster_transformation.gd"
)
const ClassicSummoningScript = preload(
	"res://scripts/classic_runtime/classic_summoning.gd"
)
const ClassicDispelScript = preload("res://scripts/classic_runtime/classic_dispel.gd")
const ClassicLightScript = preload("res://scripts/classic_runtime/classic_light.gd")
const ClassicConfusionScript = preload(
	"res://scripts/classic_runtime/classic_confusion.gd"
)
const ClassicDiseaseScript = preload(
	"res://scripts/classic_runtime/classic_disease.gd"
)
const RuntimeScript = preload("res://scripts/classic_runtime/classic_runtime.gd")
const HostScript = preload("res://scripts/classic_runtime/classic_runtime_host.gd")
const CampaignInstallScript = preload(
	"res://scripts/classic_runtime/classic_campaign_install.gd"
)
const CampaignPackageInstallerScript = preload(
	"res://scripts/classic_runtime/classic_campaign_package_installer.gd"
)
const MapMaterializerScript = preload(
	"res://scripts/classic_runtime/classic_map_materializer.gd"
)
const ItemMaterializerScript = preload(
	"res://scripts/classic_runtime/classic_item_materializer.gd"
)
const BestiaryMaterializerScript = preload(
	"res://scripts/classic_runtime/classic_bestiary_materializer.gd"
)
const MonsterWeaponRulesScript = preload(
	"res://scripts/classic_runtime/classic_monster_weapon_rules.gd"
)
const MaterializationFixtureAuditScript = preload(
	"res://scripts/classic_runtime/classic_materialization_fixture_audit.gd"
)
const NativeResourcesScript = preload("res://scripts/Resources.gd")
const CampaignSessionScript = preload(
	"res://scripts/classic_runtime/classic_campaign_session.gd"
)
const GodotAdapterScript = preload("res://scripts/classic_runtime/classic_godot_command_adapter.gd")
const ClassicPlayerMapScene = preload(
	"res://scenes/UI/HUD/ClassicPlayerMapRect/classic_player_map_rect.tscn"
)
const ClassicPlayerMapScript = preload(
	"res://scenes/UI/HUD/ClassicPlayerMapRect/classic_player_map_rect.gd"
)
const CombatIntegrationAdapterScript = preload(
	"res://scripts/classic_runtime/tests/classic_combat_integration_adapter.gd"
)
const CombatRoutRulesScript = preload(
	"res://scripts/classic_runtime/classic_combat_rout_rules.gd"
)
const MapBridgeScript = preload("res://scripts/classic_runtime/classic_map_bridge.gd")
const BattleRemovalRulesScript = preload("res://scripts/battle_removal_rules.gd")
const BattleRewardRulesScript = preload("res://scripts/battle_reward_rules.gd")
const TurnUndeadRulesScript = preload("res://scripts/turn_undead_rules.gd")
const ShopRulesScript = preload("res://scripts/shop_rules.gd")
const TemplePaymentScript = preload("res://scenes/UI/HUD/Temple/temple_payment.gd")
const SpellIdsScript = preload("res://scripts/spells_id_divinity.gd")
const ItemIdsScript = preload("res://scripts/item_id_divinity.gd")
const ShineScript = preload("res://shared_assets/spells/shine.gd")
const ClassicPartyConditionScript = preload(
	"res://scripts/classic_runtime/classic_party_condition.gd"
)
const FIXTURE := "res://scripts/classic_runtime/tests/fixtures/cob_vertical_slice"
const WAR_IN_THE_SWORD_LANDS_GOSUB_FIXTURE := \
	"res://scripts/classic_runtime/tests/fixtures/war_in_the_sword_lands_gosub"
const TWIN_SANDS_OPCODE_25_FIXTURE := \
	"res://scripts/classic_runtime/tests/fixtures/twin_sands_opcode_25"
const COB_SPOKEN_WORD_FIXTURE := \
	"res://scripts/classic_runtime/tests/fixtures/cob_spoken_word"
const COMPLEX_RESPONSE_MODES_FIXTURE := \
	"res://scripts/classic_runtime/tests/fixtures/complex_response_modes"
const PROVIDENCE_AUTHORITATIVE_FIXTURE := \
	"res://scripts/classic_runtime/tests/fixtures/providence_authoritative_export"
const PROVIDENCE_AUTHORITATIVE_PROVENANCE := \
	"res://scripts/classic_runtime/tests/fixtures/providence_authoritative_export.provenance.json"
const NATIVE_BATTLE_BRIDGE_FIXTURE := \
	"res://scripts/classic_runtime/tests/fixtures/native_battle_bridge"
const CAMPAIGN_UI_SMOKE_FIXTURE := \
	"res://scripts/classic_runtime/tests/fixtures/installed_campaigns/campaign_ui_smoke"

var failures := 0


class SorcererLearningRule:
	extends RefCounted

	static func can_learn_spell(_character: Object, spell: Object) -> int:
		return 1 if spell.school_levels.has("Sorcerer") else 10


class EnchanterLearningRule:
	extends RefCounted

	static func can_learn_spell(_character: Object, spell: Object) -> int:
		return 1 if spell.school_levels.has("Enchanter") else 10


class GuardHouseAdapter:
	extends RefCounted
	var commands: Array = []

	func get_classic_execution_context() -> Dictionary:
		return {"scenarioDay": 11, "actorFaction": 9}

	func execute_command(command: String, payload: Dictionary) -> Dictionary:
		commands.append({"command": command, "payload": payload})
		if command == "start_encounter":
			return {"outcome": 4}
		if command == "check_party_item":
			return {"possessed": true}
		if command == "check_party_condition":
			return {"active": true}
		if command == "check_party_ally":
			return {"present": true}
		if command == "check_combat_monster":
			return {"present": true}
		return {}


class BattleRoundHostAdapter:
	extends RefCounted
	var tree: SceneTree
	var commands: Array = []

	func _init(scene_tree: SceneTree) -> void:
		tree = scene_tree

	func execute_command(command: String, payload: Dictionary) -> Dictionary:
		commands.append({"command": command, "payload": payload})
		await tree.process_frame
		return {}


class SuspendedCommandAdapter:
	extends RefCounted
	signal response_ready(response: Dictionary)
	var commands: Array = []
	var waiting := false
	var save_safe := true

	func execute_command(command: String, payload: Dictionary) -> Dictionary:
		commands.append({"command": command, "payload": payload.duplicate(true)})
		waiting = true
		var response: Dictionary = await response_ready
		waiting = false
		return response

	func classic_continuation_save_policy(_command: String) -> Dictionary:
		if save_safe:
			return {"status": "ok"}
		return {
			"status": "error",
			"message": "Finish the current encounter response before saving",
		}

	func respond(response := {}) -> void:
		response_ready.emit(response)


class RejectingAdapter:
	extends RefCounted

	func execute_command(command: String, _payload: Dictionary) -> Dictionary:
		return {
			"status": "error",
			"message": "Rejected %s for test" % command,
		}


class BundleAwareAdapter:
	extends RefCounted
	var configured_bundle: Variant

	func configure_classic_bundle(bundle: Variant) -> void:
		configured_bundle = bundle

	func execute_command(_command: String, _payload: Dictionary) -> Dictionary:
		return {}


class MapSoundAdapter:
	extends RefCounted
	var sound_ids: Array[int] = []

	func play_classic_map_sound(sound_id: int) -> Dictionary:
		sound_ids.append(sound_id)
		return {"status": "ok"}


class StartLocationAdapter:
	extends RefCounted
	var configured_bundle: Variant
	var start_location: Dictionary = {}
	var reapplied_state: Variant
	var compatibility_state := {"equipmentCapture": "sealed"}

	func configure_classic_bundle(bundle: Variant) -> void:
		configured_bundle = bundle

	func activate_classic_start(location: Dictionary) -> Dictionary:
		start_location = location.duplicate(true)
		var map_prefix := "mapd_" if str(location.get("levelType", "land")) == "dungeon" \
			else "map_"
		return {
			"nativeMapName": "%s%d" % [map_prefix, int(location.get("levelIndex", -1))],
			"position": Vector2i(
				int(location.get("x", -1)),
				int(location.get("y", -1))
			),
			"recheckDestination": bool(location.get("recheckDestination", false)),
		}

	func reapply_classic_map_state(runtime_state: Variant) -> Dictionary:
		reapplied_state = runtime_state
		return {
			"status": "ok",
			"applied": {"tiles": 0},
		}

	func classic_save_state() -> Dictionary:
		return compatibility_state.duplicate(true)

	func restore_classic_save_state(saved_state: Dictionary) -> Dictionary:
		compatibility_state = saved_state.duplicate(true)
		return {"status": "ok"}

	func execute_command(_command: String, _payload: Dictionary) -> Dictionary:
		return {}


class FailingSaveRestoreAdapter:
	extends RefCounted
	var compatibility_state := {"marker": "original"}
	var reject_next_restore := false

	func configure_classic_bundle(_bundle: Variant) -> void:
		pass

	func classic_save_state() -> Dictionary:
		return compatibility_state.duplicate(true)

	func restore_classic_save_state(saved_state: Dictionary) -> Dictionary:
		compatibility_state = saved_state.duplicate(true)
		if reject_next_restore:
			reject_next_restore = false
			return {
				"status": "error",
				"message": "Classic adapter rejected the saved state",
			}
		return {"status": "ok"}

	func execute_command(_command: String, _payload: Dictionary) -> Dictionary:
		return {}


class SelectiveBattleAdapter:
	extends RefCounted
	var commands: Array = []
	var survivor_count := 1

	func execute_command(command: String, payload: Dictionary) -> Dictionary:
		commands.append({"command": command, "payload": payload})
		if command == "start_battle":
			return {
				"outcome": "won" if survivor_count > 0 else "lost",
				"coward": survivor_count == 0,
				"survivorCount": survivor_count,
			}
		return {}


class BattleOutcomeAdapter:
	extends RefCounted
	var commands: Array = []
	var coward := false

	func execute_command(command: String, payload: Dictionary) -> Dictionary:
		commands.append({"command": command, "payload": payload})
		if command == "start_battle":
			return {
				"outcome": "lost" if coward else "won",
				"coward": coward,
				"survivorCount": 0 if coward else 1,
			}
		return {}


class ForcedBattleResumeAdapter:
	extends RefCounted
	var commands: Array = []

	func execute_command(command: String, payload: Dictionary) -> Dictionary:
		commands.append({"command": command, "payload": payload})
		if command == "start_battle":
			return {
				"outcome": "won",
				"coward": false,
				"survivorCount": 1,
				"forcedResumeSlot": 8,
			}
		return {}


class CowardPenaltyTestCharacter:
	extends RefCounted
	var level := 1
	var exp_tnl := 0

	func _init(character_level: int, experience_to_next_level: int) -> void:
		level = character_level
		exp_tnl = experience_to_next_level


class WealthTestAdapter:
	extends RefCounted
	var commands: Array = []
	var paid := true

	func execute_command(command: String, payload: Dictionary) -> Dictionary:
		commands.append({"command": command, "payload": payload})
		if command == "start_encounter":
			return {"outcome": 1}
		if command == "take_party_wealth":
			return {"paid": paid}
		return {}


class RogueTestCharacter:
	extends RefCounted
	var name := "Test Rogue"
	var level := 1
	var classgd: Variant = null
	var stat_value := 35.0
	var stat_values: Dictionary = {}
	var current_hp := 30
	var inventory: Array = []
	var spells: Array = []
	var tags: Array = []
	var traits: Array = []

	func get_stat(stat_name: String) -> float:
		if stat_values.has(stat_name):
			return float(stat_values[stat_name])
		match stat_name:
			"curHP":
				return current_hp
			"maxHP":
				return 30.0
			_:
				return stat_value

	func change_cur_hp(change: int) -> void:
		current_hp += change


class InventoryTestCharacter:
	extends RefCounted
	var name := "Inventory Test"
	var inventory: Array = []
	var money: Array = [0, 0, 0]
	var weight_limit := 100
	var unequip_count := 0

	func get_stat(stat_name: String) -> int:
		return weight_limit if stat_name == "Weight_Limit" else 0

	func unequip_item(item: Dictionary, _check_script := true) -> bool:
		unequip_count += 1
		item["equipped"] = 0
		return true

	func equip_item(item: Dictionary) -> bool:
		item["equipped"] = 1
		return true


class ConditionTestTrait:
	extends RefCounted
	var name: String
	var power: int

	func _init(trait_name: String, trait_power: int) -> void:
		name = trait_name
		power = trait_power

	func get_saved_variables() -> Array:
		return [power]


class ConditionTestCharacter:
	extends RefCounted
	var name: String
	var life_status: int
	var is_player_controlled := true
	var current_hp := 20
	var traits: Array = []

	func _init(character_name: String, status := 0) -> void:
		name = character_name
		life_status = status

	func add_trait(trait_script: Variant, args: Array) -> Variant:
		var condition_trait := ConditionTestTrait.new(
			str(trait_script.resource_path).get_file(),
			int(args[0])
		)
		traits.append(condition_trait)
		return condition_trait

	func remove_trait(condition_trait: Variant) -> void:
		traits.erase(condition_trait)

	func change_cur_hp(change: int) -> void:
		current_hp += change


class CurseRemovalTestCharacter:
	extends RefCounted
	var inventory: Array = []
	var traits: Array = []
	var unequip_checks: Array[bool] = []

	func remove_trait(condition_trait: Variant) -> void:
		traits.erase(condition_trait)

	func unequip_item(item: Dictionary, check_script := true) -> bool:
		unequip_checks.append(check_script)
		item["equipped"] = 0
		return true


class HelplessTestTrait:
	extends RefCounted
	var name := "t_helpless.gd"
	var stacks := true
	var duration := 0

	func _init(initial_duration: int) -> void:
		duration = initial_duration

	func stack(args: Array) -> void:
		duration += int(args[0])


class HelplessTestCharacter:
	extends RefCounted
	var name: String
	var is_player_controlled := false
	var traits: Array = []
	var max_actions := 3
	var max_movement := 20
	var used_apr := 0
	var used_movepoints := 0

	func _init(character_name: String, player_controlled := false) -> void:
		name = character_name
		is_player_controlled = player_controlled

	func add_trait(trait_script: Variant, args: Array) -> Variant:
		for existing_trait: Variant in traits:
			if existing_trait.name == trait_script.name and existing_trait.stacks:
				existing_trait.stack(args)
				return existing_trait
		var condition_trait := HelplessTestTrait.new(int(args[0]))
		traits.append(condition_trait)
		return condition_trait

	func get_apr_left() -> int:
		return max_actions - used_apr

	func get_movement_left() -> int:
		return max_movement - used_movepoints


class SlowTestTrait:
	extends RefCounted
	var name := "t_slow.gd"
	var stacks := true
	var duration := 0

	func _init(rounds: int) -> void:
		duration = rounds * 5

	func stack(args: Array) -> void:
		duration += int(args[0]) * 5


class SlowTestCharacter:
	extends RefCounted
	var name: String
	var is_player_controlled := false
	var traits: Array = []
	var max_movement := 20
	var used_movepoints := 0

	func _init(character_name: String, player_controlled := false) -> void:
		name = character_name
		is_player_controlled = player_controlled

	func add_trait(trait_script: Variant, args: Array) -> Variant:
		for existing_trait: Variant in traits:
			if existing_trait.name == trait_script.name and existing_trait.stacks:
				existing_trait.stack(args)
				return existing_trait
		var condition_trait := SlowTestTrait.new(int(args[0]))
		traits.append(condition_trait)
		return condition_trait

	func get_movement_left() -> int:
		var current_maximum := max_movement
		for trait_value: Variant in traits:
			if trait_value.name == "t_slow.gd":
				current_maximum = floori(float(current_maximum) / 2.0)
				break
		return current_maximum - used_movepoints


class CharmTestCharacter:
	extends RefCounted
	var name: String
	var baseFaction: int
	var curFaction: int
	var is_player_controlled := false
	var creature_script = null
	var traits: Array = []

	func _init(character_name: String, faction: int) -> void:
		name = character_name
		baseFaction = faction
		curFaction = faction

	func add_trait(trait_script: Variant, args: Array) -> Variant:
		for existing_trait: Variant in traits:
			if existing_trait.name == trait_script.name and existing_trait.stacks:
				existing_trait.stack(args)
				return existing_trait
		var trait_args := [self]
		trait_args.append_array(args)
		var trait_instance = trait_script.new(trait_args)
		traits.append(trait_instance)
		return trait_instance

	func remove_trait(trait_instance: Variant) -> void:
		if trait_instance.has_method("_on_remove_trait"):
			trait_instance._on_remove_trait(self, trait_instance)
		traits.erase(trait_instance)


class DispelTestTrait:
	extends RefCounted
	var name: String

	func _init(trait_name: String) -> void:
		name = trait_name


class DispelTestCharacter:
	extends RefCounted
	var name: String
	var baseFaction: int
	var curFaction: int
	var is_player_controlled: bool
	var traits: Array = []

	func _init(character_name: String, faction: int, player_controlled: bool) -> void:
		name = character_name
		baseFaction = faction
		curFaction = faction
		is_player_controlled = player_controlled

	func add_trait(trait_script: Variant, args: Array) -> Variant:
		var trait_args := [self]
		trait_args.append_array(args)
		var trait_instance = trait_script.new(trait_args)
		traits.append(trait_instance)
		return trait_instance

	func remove_trait(trait_instance: Variant) -> void:
		if trait_instance.has_method("_on_remove_trait"):
			trait_instance._on_remove_trait(self, trait_instance)
		traits.erase(trait_instance)


class DiseaseTestCharacter:
	extends RefCounted
	var name: String
	var current_hp := 20
	var is_player_controlled := false
	var traits: Array = []

	func _init(character_name: String, player_controlled := false) -> void:
		name = character_name
		is_player_controlled = player_controlled

	func add_trait(trait_script: Variant, args: Array) -> Variant:
		for existing_trait: Variant in traits:
			if existing_trait.name == trait_script.name and existing_trait.stacks:
				existing_trait.stack(args)
				return existing_trait
		var trait_args := [self]
		trait_args.append_array(args)
		var trait_instance = trait_script.new(trait_args)
		traits.append(trait_instance)
		return trait_instance

	func remove_trait(trait_instance: Variant) -> void:
		traits.erase(trait_instance)

	func get_stat(stat_name: String) -> int:
		return current_hp if stat_name == "curHP" else 0

	func change_cur_hp(change: int) -> void:
		current_hp += change


class ReflectionTestCharacter:
	extends RefCounted
	var name: String
	var position := Vector2i.ZERO
	var combat_button = RefCounted.new()
	var is_player_controlled := false
	var traits: Array = []

	func _init(character_name: String, player_controlled := false) -> void:
		name = character_name
		is_player_controlled = player_controlled

	func add_trait(trait_script: Variant, args: Array) -> Variant:
		for existing_trait: Variant in traits:
			if existing_trait.name == trait_script.name and existing_trait.stacks:
				existing_trait.stack(args)
				return existing_trait
		var trait_args := [self]
		trait_args.append_array(args)
		var trait_instance = trait_script.new(trait_args)
		traits.append(trait_instance)
		return trait_instance

	func remove_trait(trait_instance: Variant) -> void:
		traits.erase(trait_instance)


class RegenerationTestCharacter:
	extends RefCounted
	var name: String
	var current_hp := 20
	var maximum_hp := 30
	var life_status := 0
	var is_player_controlled := false
	var traits: Array = []

	func _init(character_name: String, player_controlled := false) -> void:
		name = character_name
		is_player_controlled = player_controlled

	func add_trait(trait_script: Variant, args: Array) -> Variant:
		for existing_trait: Variant in traits:
			if existing_trait.name == trait_script.name and existing_trait.stacks:
				existing_trait.stack(args)
				return existing_trait
		var trait_args := [self]
		trait_args.append_array(args)
		var trait_instance = trait_script.new(trait_args)
		traits.append(trait_instance)
		return trait_instance

	func remove_trait(trait_instance: Variant) -> void:
		traits.erase(trait_instance)

	func get_stat(stat_name: String) -> int:
		match stat_name:
			"curHP":
				return current_hp
			"maxHP":
				return maximum_hp
			_:
				return 0

	func change_cur_hp(change: int) -> void:
		current_hp = mini(maximum_hp, current_hp + change)


class ProtectionTestTrait:
	extends RefCounted
	var name: String
	var duration: int
	var stacks := true

	func _init(trait_name: String, rounds: int) -> void:
		name = trait_name
		duration = 5 * rounds

	func stack(args: Array) -> void:
		duration += 5 * int(args[0])


class ProtectionTestCharacter:
	extends RefCounted
	var name: String
	var is_player_controlled: bool
	var traits: Array = []

	func _init(character_name: String, player_controlled := false) -> void:
		name = character_name
		is_player_controlled = player_controlled

	func add_trait(trait_script: Variant, args: Array) -> Variant:
		var trait_name := str(trait_script.resource_path).get_file()
		for existing_trait: Variant in traits:
			if existing_trait.name == trait_name and existing_trait.stacks:
				existing_trait.stack(args)
				return existing_trait
		var trait_instance := ProtectionTestTrait.new(trait_name, int(args[0]))
		traits.append(trait_instance)
		return trait_instance


class SpellScreenTestCharacter:
	extends RefCounted
	var name: String
	var is_player_controlled: bool
	var traits: Array = []
	var tags: Array = []
	var stats: Dictionary = {}
	var used_movepoints := 0

	func _init(character_name: String, player_controlled := false) -> void:
		name = character_name
		is_player_controlled = player_controlled

	func add_trait(trait_script: Variant, args: Array) -> Variant:
		for existing_trait: Variant in traits:
			if existing_trait.name == trait_script.name and existing_trait.stacks:
				existing_trait.stack(args)
				return existing_trait
		var trait_args := [self]
		trait_args.append_array(args)
		var trait_instance = trait_script.new(trait_args)
		traits.append(trait_instance)
		return trait_instance

	func remove_trait(trait_instance: Variant) -> void:
		traits.erase(trait_instance)

	func can_cast_spells() -> bool:
		for trait_value: Variant in traits:
			if trait_value.has_method("blocks_spellcasting") \
					and bool(trait_value.blocks_spellcasting()):
				return false
		return true

	func get_stat(stat_name: String) -> Variant:
		var stat: Variant = stats.get(stat_name, 0)
		for trait_value: Variant in traits:
			if trait_value.has_method("_on_get_stat"):
				stat = trait_value._on_get_stat(stat_name, stat)
		return stat

	func get_movement_left() -> int:
		return maxi(0, int(get_stat("MaxMovement")) - used_movepoints)


class AnimationTestCharacter:
	extends RefCounted
	var name: String
	var life_status := 3
	var is_player_controlled := true
	var traits: Array = []
	var stats := {
		"curHP": -12,
		"maxHP": 43,
		"SP_regen_mult": 1.0,
		"MultiplierHealing": 1.0,
	}

	func _init(character_name: String) -> void:
		name = character_name

	func add_trait(trait_script: Variant, args: Array) -> Variant:
		for existing_trait: Variant in traits:
			if existing_trait.name == trait_script.name and existing_trait.stacks:
				existing_trait.stack(args)
				return existing_trait
		var trait_args := [self]
		trait_args.append_array(args)
		var trait_instance = trait_script.new(trait_args)
		traits.append(trait_instance)
		return trait_instance

	func remove_trait(trait_instance: Variant) -> void:
		traits.erase(trait_instance)

	func get_stat(stat_name: String) -> Variant:
		var stat: Variant = stats.get(stat_name, 0)
		for trait_value: Variant in traits:
			if trait_value.has_method("_on_get_stat"):
				stat = trait_value._on_get_stat(stat_name, stat)
		return stat

	func change_cur_hp(change: int) -> void:
		stats["curHP"] = mini(int(stats["maxHP"]), int(stats["curHP"]) + change)


class PetrificationTestCharacter:
	extends RefCounted
	var name: String
	var life_status := 0
	var traits: Array = []
	var stats := {
		"curHP": 25,
		"maxHP": 25,
		"EvasionMelee": 4,
		"EvasionRanged": 4,
		"MultiplierHealing": 1,
		"MultiplierMagic": 1,
	}

	func _init(character_name: String) -> void:
		name = character_name

	func add_trait(trait_script: Variant, args: Array) -> Variant:
		for existing_trait: Variant in traits:
			if existing_trait.name == trait_script.name:
				return existing_trait
		var trait_args := [self]
		trait_args.append_array(args)
		var trait_instance = trait_script.new(trait_args)
		traits.append(trait_instance)
		return trait_instance

	func remove_trait(trait_instance: Variant) -> void:
		traits.erase(trait_instance)

	func get_stat(stat_name: String) -> Variant:
		var stat: Variant = stats.get(stat_name, 0)
		for trait_value: Variant in traits:
			if trait_value.has_method("_on_get_stat"):
				stat = trait_value._on_get_stat(stat_name, stat)
		return stat

	func change_cur_hp(change: int) -> void:
		for trait_value: Variant in traits:
			if trait_value.has_method("_on_change_cur_hp"):
				change = trait_value._on_change_cur_hp(change)
		stats["curHP"] = mini(int(stats["maxHP"]), int(stats["curHP"]) + change)


class LethalSpellTestCharacter:
	extends RefCounted
	var name: String
	var level: int
	var life_status := 0
	var stats := {
		"curHP": 50,
		"maxHP": 50,
		"MultiplierChemical": 1.0,
		"MultiplierMagic": 1.0,
		"ResistanceChemical": 0,
		"ResistanceMagic": 0,
	}

	func _init(character_name: String, character_level := 1) -> void:
		name = character_name
		level = character_level

	func get_stat(stat_name: String) -> Variant:
		return stats.get(stat_name, 0)

	func change_cur_hp(change: int) -> void:
		stats["curHP"] = mini(int(stats["maxHP"]), int(stats["curHP"]) + change)


class TransformationTestTrait:
	extends RefCounted
	var name: String
	var trait_source: String
	var chara: Variant

	func _init(trait_name: String, source: String) -> void:
		name = trait_name
		trait_source = source


class TransformationTestButton:
	extends RefCounted
	var creature: Variant
	var refresh_count := 0

	func set_creature_represented(value: Variant) -> void:
		creature = value
		refresh_count += 1


class PhaseTestButton:
	extends RefCounted
	var position := Vector2.ZERO


class PhaseTestCreature:
	extends RefCounted
	var position := Vector2.ZERO
	var size := Vector2.ONE
	var used_apr := 1
	var life_status := 0
	var stats := {"curHP": 20, "maxHP": 20}
	var combat_button := PhaseTestButton.new()

	func get_stat(stat_name: String) -> int:
		return 3 if stat_name == "MaxActions" else int(stats.get(stat_name, 0))

	func change_cur_hp(change: int) -> void:
		stats["curHP"] = int(stats["curHP"]) + change


class SummonTestCaster:
	extends RefCounted
	var name := "Summoner"
	var baseFaction := 4
	var curFaction := 5


class SummonTestCreature:
	extends RefCounted
	var name := "Summoned creature"
	var position := Vector2.ZERO
	var size := Vector2.ONE
	var is_summoned := false
	var summoner: Variant
	var summoner_name := ""
	var baseFaction := 0
	var curFaction := 0
	var combat_button: Variant


class SummonTestCombatState:
	extends RefCounted
	var classic_monster_slots_used := 0
	var all_battle_creatures_btns: Array = []
	var battle_creatures_yet_to_act_btns: Array = []

	func add_pc_or_npc_ally_to_battle_map(creature: Object, _position: Vector2) -> bool:
		var button := CombatTestButton.new(creature)
		creature.combat_button = button
		all_battle_creatures_btns.append(button)
		return true


class TransformationTestCreature:
	extends RefCounted
	var name := ""
	var level := 1
	var bestiary_key := ""
	var classic_monster_id := -1
	var size := Vector2.ONE
	var position := Vector2.ZERO
	var dirfaced := 1
	var selected := false
	var baseFaction := 1
	var curFaction := 1
	var reaction_ready := true
	var used_movepoints := 0
	var used_apr := 0
	var used_spr := 0
	var has_turned_undead := false
	var terrain_already_crossed_this_turn := {}
	var is_summoned := false
	var summoner: Variant
	var summoner_name := ""
	var joins_combat := true
	var combat_button: Variant
	var life_status := 0
	var stats := {
		"curHP": 10,
		"maxHP": 10,
		"MultiplierMagic": 1.0,
		"ResistanceMagic": 0,
	}
	var base_stats := stats.duplicate(true)
	var traits: Array = []
	var money: Array = [0, 0, 0]
	var inventory: Array = []
	var spells: Array = []
	var ai_variables := {}

	func initialize_from_bestiary_dict(_form_key: String) -> void:
		pass

	func get_stat(stat_name: String) -> Variant:
		return stats.get(stat_name, 0)


class BlindnessTestCharacter:
	extends RefCounted
	var name: String
	var traits: Array = []
	var stats := {
		"curHP": 20,
		"AccuracyMelee": 10,
		"AccuracyRanged": 8,
		"AccuracyMagic": 9,
		"EvasionMelee": 6,
		"EvasionRanged": 4,
	}

	func _init(character_name: String) -> void:
		name = character_name

	func add_trait(trait_script: Variant, args: Array) -> Variant:
		for existing_trait: Variant in traits:
			if existing_trait.name == trait_script.name:
				return existing_trait
		var trait_args := [self]
		trait_args.append_array(args)
		var trait_instance = trait_script.new(trait_args)
		traits.append(trait_instance)
		return trait_instance

	func remove_trait(trait_instance: Variant) -> void:
		traits.erase(trait_instance)

	func get_stat(stat_name: String) -> Variant:
		var stat: Variant = stats.get(stat_name, 0)
		for trait_value: Variant in traits:
			if trait_value.has_method("_on_get_stat"):
				stat = trait_value._on_get_stat(stat_name, stat)
		return stat


class AllyTestCharacter:
	extends RefCounted
	var name := "Vodalian"


class CombatTestCreature:
	extends RefCounted
	var name: String
	var current_hp: int
	var curFaction: int
	var position := Vector2.ZERO
	var classic_monster_id := -1
	var classic_monster_name_id := -1
	var is_player_controlled := false
	var please_remove_from_combat := false
	var applied_traits: Array = []

	func _init(creature_name: String, hp: int, faction := 1) -> void:
		name = creature_name
		current_hp = hp
		curFaction = faction

	func get_stat(stat_name: String) -> int:
		return current_hp if stat_name == "curHP" else 0

	func add_trait(trait_script: Variant, args: Array) -> Variant:
		applied_traits.append({"script": trait_script, "args": args})
		return null


class SpellPointTestCreature:
	extends RefCounted
	var current_sp: int

	func _init(spell_points: int) -> void:
		current_sp = spell_points

	func get_stat(stat_name: String) -> int:
		return current_sp if stat_name == "curSP" else 0

	func change_cur_sp(change: int) -> void:
		current_sp += change


class SpellPointConditionTestCharacter:
	extends RefCounted
	var name: String
	var current_hp := 20
	var current_sp: int
	var maximum_sp: int
	var is_player_controlled: bool
	var baseFaction: int
	var curFaction: int
	var traits: Array = []

	func _init(
		character_name: String,
		spell_points: int,
		maximum_spell_points: int,
		player_controlled := true,
		faction := 0
	) -> void:
		name = character_name
		current_sp = spell_points
		maximum_sp = maximum_spell_points
		is_player_controlled = player_controlled
		baseFaction = faction
		curFaction = faction

	func add_trait(trait_script: Variant, args: Array) -> Variant:
		for existing_trait: Variant in traits:
			if existing_trait.name == trait_script.name and existing_trait.stacks:
				existing_trait.stack(args)
				return existing_trait
		var trait_args := [self]
		trait_args.append_array(args)
		var trait_instance = trait_script.new(trait_args)
		traits.append(trait_instance)
		return trait_instance

	func remove_trait(trait_instance: Variant) -> void:
		traits.erase(trait_instance)

	func get_stat(stat_name: String) -> int:
		match stat_name:
			"curHP":
				return current_hp
			"curSP":
				return current_sp
			"maxSP":
				return maximum_sp
		return 0

	func change_cur_sp(change: int) -> void:
		current_sp = mini(maximum_sp, current_sp + change)


class MonsterSpellPointAbsorptionTestCharacter:
	extends RefCounted
	var name := "Spellcasting monster"
	var curFaction := 1
	var is_player_controlled := false
	var stats := {"curSP": 5, "maxSP": 5}

	func get_stat(stat_name: String) -> int:
		return int(stats.get(stat_name, 0))

	func change_cur_sp(change: int) -> void:
		stats["curSP"] = mini(int(stats["maxSP"]), int(stats["curSP"]) + change)


class CombatTestButton:
	extends RefCounted
	var creature: Variant

	func _init(represented_creature: Variant) -> void:
		creature = represented_creature


class TurnUndeadTestCreature:
	extends RefCounted
	var name: String
	var curFaction: int
	var used_apr := 0
	var has_turned_undead := false
	var tags: Array = []
	var level := 0
	var current_hp := 20
	var turn_undead := 0
	var max_actions := 3
	var magic_resistance := 0

	func _init(creature_name: String, faction: int) -> void:
		name = creature_name
		curFaction = faction

	func get_stat(stat_name: String) -> int:
		match stat_name:
			"curHP":
				return current_hp
			"Turn_Undead":
				return turn_undead
			"MaxActions":
				return max_actions
			"ResistanceMagic":
				return magic_resistance
			_:
				return 0

	func get_apr_left() -> int:
		return max_actions - used_apr

	func change_cur_hp(change: int) -> void:
		current_hp += change


class CombatTestState:
	extends RefCounted
	var all_battle_creatures_btns: Array
	var battle_creatures_yet_to_act_btns: Array
	var battle_dead_enemies: Array = []
	var battle_dead_party_members: Array = []
	var cur_battle_data: Dictionary = {"battleMacro": -1}
	var classic_monster_slots_used := 0
	var placement_origins: Array = []
	var queued_death_creatures: Array = []

	func _init(combatants: Array) -> void:
		all_battle_creatures_btns = combatants.duplicate()
		battle_creatures_yet_to_act_btns = combatants.duplicate()

	func remove_cb_from_battle(combatant: Variant) -> void:
		all_battle_creatures_btns.erase(combatant)
		battle_creatures_yet_to_act_btns.erase(combatant)

	func queue_classic_death_macro(creature: Variant) -> bool:
		if not creature.has_meta("classic_death_macro"):
			return false
		if int(creature.get_meta("classic_death_macro")) <= 0:
			return false
		queued_death_creatures.append(creature)
		return true

	func find_pos_for_crea_on_battlefield(
		_creature: Variant,
		origin: Vector2,
		_failure_ok: bool,
		_max_move_attempts: int,
		_max_los_attempts: int
	) -> Vector2:
		placement_origins.append(origin)
		return origin + Vector2(placement_origins.size(), 0)


class SpawnTestCreature:
	extends RefCounted
	var name := "Spawned creature"
	var position := Vector2.ZERO
	var baseFaction := 5
	var curFaction := 5
	var classic_monster_id := -1
	var classic_monster_name_id := -1
	var is_player_controlled := false
	var combat_button: Variant
	var initialized_name := ""

	func initialize_from_bestiary_dict(bestiary_name: String) -> void:
		initialized_name = bestiary_name

	func get_stat(stat_name: String) -> int:
		return 1 if stat_name == "curHP" else 0


class SpawnTestBackground:
	extends RefCounted
	var visible := true

	func hide() -> void:
		visible = false


class SpawnTestButton:
	extends RefCounted
	var creature: Variant
	var bgsprite = SpawnTestBackground.new()

	func set_creature_represented(value: Variant) -> void:
		creature = value


class SpawnTestScene:
	extends RefCounted

	func instantiate() -> Variant:
		return SpawnTestButton.new()


class SpawnTestNode:
	extends RefCounted
	var children: Array = []

	func add_child(child: Variant) -> void:
		children.append(child)


class SpawnTestMap:
	extends RefCounted
	var creatures_node = SpawnTestNode.new()


class CombatIntegrationResources:
	extends Node
	var crea_book: Dictionary

	func _init(creatures: Dictionary) -> void:
		crea_book = creatures


class CombatIntegrationNodeAccess:
	extends Node
	var resources: Variant
	var map: Variant

	func _init(loaded_resources: Variant, loaded_map: Variant) -> void:
		resources = loaded_resources
		map = loaded_map

	func __Resources() -> Variant:
		return resources

	func __Map() -> Variant:
		return map


class CombatIntegrationGameGlobal:
	extends Node
	var combatCreatureGD: Variant
	var time := 0
	var battle_end_calls: Array = []

	func _init(creature_script: Variant) -> void:
		combatCreatureGD = creature_script

	func end_battle(outcome: String, reward_mode: String) -> void:
		battle_end_calls.append({"outcome": outcome, "rewardMode": reward_mode})


class CombatIntegrationStateMachine:
	extends Node
	var combat_state: Variant
	var cb_decide_state: Variant

	func _init(state: Variant) -> void:
		combat_state = state

	func is_combat_state() -> bool:
		return true


class MapBridgeTestCharacter:
	extends RefCounted
	var tile_position := Vector2.ZERO

	func set_tile_position(position: Vector2) -> void:
		tile_position = position


class MapBridgeTestMap:
	extends RefCounted
	var focuscharacter = MapBridgeTestCharacter.new()
	var owcharacter = MapBridgeTestCharacter.new()
	var darkness_level := -1
	var redraw_count := 0
	var explored_position := Vector2(-1, -1)

	func queue_redraw() -> void:
		redraw_count += 1

	func explore_tiles_from_tilepos(position: Vector2) -> void:
		explored_position = position


class MapBridgeTestResources:
	extends RefCounted
	var maps_book: Dictionary = {}
	var map_info_book: Dictionary = {}
	var tiles_book: Dictionary = {}


class MapBridgeTestGameGlobal:
	extends RefCounted
	var currentmap_name := "map_0"
	var map = MapBridgeTestMap.new()
	var transitions: Array = []
	var map_boats_dict: Dictionary = {}

	func change_map(map_name: String, x: int, y: int) -> void:
		currentmap_name = map_name
		transitions.append([map_name, x, y])
		map.focuscharacter.set_tile_position(Vector2(x, y))
		map.owcharacter.set_tile_position(Vector2(x, y))


class CowardRetreatTestCharacter:
	extends RefCounted
	var tile_position_x := 12
	var tile_position_y := 7

	func set_tile_position(position: Vector2) -> void:
		tile_position_x = int(position.x)
		tile_position_y = int(position.y)


class CowardRetreatTestMap:
	extends RefCounted
	var focuscharacter = CowardRetreatTestCharacter.new()
	var owcharacter = CowardRetreatTestCharacter.new()
	var explored_positions: Array = []

	func explore_tiles_from_tilepos(position: Vector2i) -> void:
		explored_positions.append(position)


class CowardRetreatTestGameGlobal:
	extends RefCounted
	var map = CowardRetreatTestMap.new()


class FatigueServiceTestDouble:
	extends RefCounted
	var fatigue := 0.0
	var set_calls := 0

	func set_party_fatigue(value: float) -> float:
		fatigue = value
		set_calls += 1
		return fatigue


class QueuedTerrainTestCreature:
	extends RefCounted
	var position := Vector2.ZERO
	var size := Vector2.ONE

	func _init(at: Vector2, footprint := Vector2.ONE) -> void:
		position = at
		size = footprint


class QueuedTerrainTestButton:
	extends RefCounted
	var creature: QueuedTerrainTestCreature

	func _init(value: QueuedTerrainTestCreature) -> void:
		creature = value


func _init() -> void:
	var bundle = BundleScript.new()
	_expect(bundle.load_from_directory(FIXTURE), "CoB fixture loads: %s" % bundle.last_error)
	if not bundle.last_error.is_empty():
		_finish()
		return

	_test_bundle_contract_validation()
	_test_providence_authoritative_export()
	_test_installed_classic_campaign_layout()
	_test_classic_map_materializer()
	_test_classic_boat_materialization()
	_test_classic_item_materializer()
	_test_classic_bestiary_materializer()
	_test_classic_map_sound_bridge()
	_test_classic_campaign_package_installer()
	_test_failed_save_restore_rolls_back()
	_test_native_battle_bridge_fixture()
	_test_bundle_indexes(bundle)
	_test_execution_coverage_audit(bundle)
	_test_data_ed3_callability_contract()
	_test_campaign_readiness_report()
	_test_custom_spell_overrides()
	_test_classic_regeneration_contract()
	_test_classic_spell_screen_contract()
	_test_classic_magic_resistance_contract()
	_test_classic_spell_save_contract()
	_test_classic_light_contract()
	_test_classic_confusion_contract()
	_test_classic_disease_contract()
	_test_text_and_encounter(bundle)
	_test_evidence_backed_dispatcher_noop(bundle)
	_test_teleport(bundle)
	_test_teleport_recheck()
	_test_dungeon_move(bundle)
	_test_look_direction(bundle)
	_test_view_modes_and_darkland(bundle)
	_test_random_level_mutations(bundle)
	_test_classic_map_bridge()
	_test_experience_award(bundle)
	_test_party_health_effect(bundle)
	_test_selected_character_pipeline(bundle)
	_test_misc_character_selection(bundle)
	_test_spell_effect_actions(bundle)
	_test_classic_spell_usage_audit()
	_test_classic_identify_objects_spell()
	_test_classic_lethal_spells()
	_test_classic_transformation_spells()
	_test_classic_phase_spells()
	_test_classic_power_surge_spells()
	_test_classic_summon_spells()
	_test_classic_destroy_magic_spells()
	_test_classic_remove_item_spells()
	_test_classic_spell_coverage()
	_test_classic_queued_area_spells()
	_test_classic_helpless_spells()
	_test_classic_slug_spells()
	_test_classic_tangle_weed_spell()
	_test_classic_destroy_trap_spell(bundle)
	_test_classic_open_lock_spell(bundle)
	_test_classic_sleepwalk_spell()
	_test_classic_spellcasting_block_spells()
	_test_classic_magic_aura_spell()
	_test_classic_healing_spells()
	_test_classic_regeneration_spells()
	_test_classic_protection_spells()
	_test_classic_spell_screen_spells()
	_test_classic_strong_spell()
	_test_classic_protection_from_foe_spells()
	_test_classic_speedy_spells()
	_test_classic_invisible_spells()
	_test_classic_animation_spells()
	_test_classic_petrification_spells()
	_test_classic_blindness_spell()
	_test_classic_disease_spells()
	_test_classic_poison_spell()
	_test_classic_spell_deflectors()
	_test_classic_attack_deflectors()
	_test_classic_attack_bonus_spells()
	_test_classic_power_gather_spells()
	_test_classic_energy_drain_spells()
	_test_classic_arcanic_bubble_spells()
	_test_classic_itching_skin_spell()
	_test_classic_shrink_foe_spell()
	_test_classic_party_condition_spells()
	_test_classic_shield_from_hits_spells()
	_test_classic_projectile_protection_spells()
	_test_classic_silence_spells()
	_test_classic_restorative_spells()
	_test_classic_learned_spell_identity()
	_test_item_actions()
	_test_take_gold_action()
	_test_give_condition_action()
	_test_item_mutation_rules()
	_test_equipment_storage_rules()
	_test_quest_state_and_branch(bundle)
	_test_classic_stack_semantics()
	_test_shipped_gosub_chain()
	_test_shipped_opcode_25_mutation()
	_test_opcode_25_xap_copy()
	_test_modal_picture_actions()
	_test_runtime_media_adapters()
	_test_classic_player_map_renderer()
	_test_party_state_actions()
	_test_priest_turning_actions()
	_test_turn_undead_rules()
	_test_combat_monster_presence_action()
	_test_combat_monster_destruction_action()
	_test_lower_undead_deanimation_action()
	_test_combat_monster_rout_action()
	_test_combat_monster_spawn_action()
	await _test_native_combat_command_host()
	_test_battle_round_macro_action()
	_test_classic_combat_macro_queue()
	await _test_native_battle_round_host()
	await _test_queued_combat_macro_host()
	_test_forced_battle_end_action()
	_test_forced_battle_resume_host()
	_test_action_point_copy_mutations(bundle)
	_test_action_data_patch_variants()
	_test_choice_continuation(bundle)
	_test_battle_request(bundle)
	_test_compiled_battle_materialization()
	_test_selective_battle_action()
	_test_selective_battle_request()
	_test_selective_battle_host()
	_test_shop_actions()
	_test_service_actions()
	_test_sound_and_treasure(bundle)
	_test_treasure_delivery(bundle)
	_test_map_mutations(bundle)
	_test_timed_encounter_mutation()
	_test_complex_encounter(bundle)
	_test_complex_action_choices(bundle)
	_test_complex_word_results()
	_test_encounter_lifecycle()
	_test_simple_encounter_mutation()
	_test_spoken_word_archive()
	_test_percent_branching()
	_test_difficulty_branching()
	_test_complex_spell_results(bundle)
	_test_complex_item_results(bundle)
	_test_complex_response_modes()
	_test_shipped_lock_encounter(bundle)
	_test_shipped_trap_encounter(bundle)
	_test_battle_outcome(bundle)
	_test_coward_experience_penalty()
	_test_coward_party_retreat()
	_test_battle_outcome_host()
	_test_state_snapshot(bundle)
	_test_godot_runtime_facade()
	_test_runtime_host()
	await _test_encounter_continuation_restore()
	await _test_gosub_continuation_restore()
	await _test_deferred_action_point_continuation_restore()
	await _test_battle_continuation_restore()
	_test_unsafe_continuation_save_policy()
	var user_arguments := OS.get_cmdline_user_args()
	if not user_arguments.is_empty():
		_test_full_bundle(str(user_arguments[0]))
	_finish()


func _test_bundle_contract_validation() -> void:
	var absolute_bundle = BundleScript.new()
	var absolute_path := ProjectSettings.globalize_path(FIXTURE)
	_expect(
		absolute_bundle.load_from_directory(absolute_path),
		"bundle loads from an absolute root with relative document paths: %s" % \
		absolute_bundle.last_error
	)

	var unsafe_path_bundle = BundleScript.new()
	unsafe_path_bundle.manifest = _minimal_contract_manifest()
	unsafe_path_bundle.manifest["files"]["scripts"] = "../classic/scripts.json"
	_expect(
		not unsafe_path_bundle._validate_manifest_contract(),
		"bundle contract rejects a parent-relative document path"
	)
	_expect(
		unsafe_path_bundle.last_error.contains("files.scripts"),
		"unsafe path error identifies the manifest field"
	)

	var version_bundle = BundleScript.new()
	version_bundle.manifest = _minimal_contract_manifest()
	version_bundle.documents = _minimal_contract_documents()
	version_bundle.documents["rules"]["schemaVersion"] = 2
	_expect(
		not version_bundle._validate_document_contract(),
		"bundle contract rejects an unsupported document schema"
	)
	_expect(
		version_bundle.last_error.contains("rules.schemaVersion"),
		"document version error identifies the document"
	)
	var future_format_bundle = BundleScript.new()
	future_format_bundle.manifest = _minimal_contract_manifest()
	future_format_bundle.manifest["formatVersion"] = BundleScript.FORMAT_VERSION + 1
	_expect(
		not future_format_bundle._validate_manifest_contract(),
		"bundle contract rejects a newer campaign format"
	)
	_expect(
		future_format_bundle.last_error.contains("format version"),
		"campaign format rejection is actionable"
	)

	var missing_id_bundle = BundleScript.new()
	missing_id_bundle.manifest = _minimal_contract_manifest()
	missing_id_bundle.documents = _minimal_contract_documents()
	missing_id_bundle.documents["scripts"]["triggers"] = [{
		"source": "Data DD",
		"recordIndex": 0,
	}]
	_expect(
		not missing_id_bundle._validate_document_contract(),
		"bundle contract rejects a record without its stable identity"
	)
	_expect(
		missing_id_bundle.last_error.contains("scripts.triggers[0]"),
		"missing identity error includes record-level context"
	)

	var malformed_callable_bundle = BundleScript.new()
	malformed_callable_bundle.manifest = _minimal_contract_manifest()
	malformed_callable_bundle.documents = _minimal_contract_documents()
	malformed_callable_bundle.documents["scripts"]["triggers"] = [{
		"id": "Data ED3:macro:0",
		"source": "Data ED3",
		"recordIndex": 0,
		"active": true,
		"callable": "false",
		"actions": [],
	}]
	_expect(
		not malformed_callable_bundle._validate_document_contract(),
		"bundle contract rejects a non-boolean Data ED3 callability marker"
	)
	_expect(
		malformed_callable_bundle.last_error.contains("scripts.triggers[0].callable"),
		"callability error includes record-level context"
	)

	var duplicate_id_bundle = BundleScript.new()
	duplicate_id_bundle.manifest = _minimal_contract_manifest()
	duplicate_id_bundle.documents = _minimal_contract_documents()
	duplicate_id_bundle.documents["scripts"]["extraCodes"] = [{"id": 4}, {"id": 4}]
	_expect(
		not duplicate_id_bundle._validate_document_contract(),
		"bundle contract rejects duplicate stable identities"
	)
	_expect(
		duplicate_id_bundle.last_error.contains("scripts.extraCodes[1]"),
		"duplicate identity error includes record-level context"
	)

	var missing_packed_spell_id_bundle = BundleScript.new()
	missing_packed_spell_id_bundle.manifest = _minimal_contract_manifest()
	missing_packed_spell_id_bundle.documents = _minimal_contract_documents()
	missing_packed_spell_id_bundle.documents["rules"]["spellOverrides"] = [{"id": 16}]
	_expect(
		missing_packed_spell_id_bundle._validate_document_contract(),
		"bundle contract derives a custom spell's redundant runtime identity"
	)
	missing_packed_spell_id_bundle._build_indexes()
	_expect_equal(
		missing_packed_spell_id_bundle.get_spell_override(5202).get("id"),
		16,
		"derived custom-spell identity is indexed for runtime references"
	)
	_expect_equal(
		missing_packed_spell_id_bundle.get_spell_override(17).get("id"),
		16,
		"one-based Data Spell references resolve the same custom spell"
	)

	var mismatched_spell_id_bundle = BundleScript.new()
	mismatched_spell_id_bundle.manifest = _minimal_contract_manifest()
	mismatched_spell_id_bundle.documents = _minimal_contract_documents()
	mismatched_spell_id_bundle.documents["rules"]["spellOverrides"] = [
		{"id": 16, "packedSpellId": 5203},
	]
	_expect(
		not mismatched_spell_id_bundle._validate_document_contract(),
		"bundle contract rejects mismatched custom-spell identities"
	)
	_expect(
		mismatched_spell_id_bundle.last_error.contains("must be 5202"),
		"mismatched custom-spell identity reports the expected packed ID"
	)

	var tileset_bundle = BundleScript.new()
	tileset_bundle.manifest = _minimal_contract_manifest()
	tileset_bundle.documents = _minimal_contract_documents()
	var asset_catalog: Dictionary = tileset_bundle.documents["assets"]["catalog"]
	asset_catalog["tilesets"] = [{
		"id": "landlook-0",
		"pictId": 300,
		"payloadPath": "classic/assets/landlook-0.png",
	}]
	_expect(
		tileset_bundle._validate_document_contract(),
		"bundle contract accepts stable tileset identities and relative payload paths"
	)

	var missing_asset_id_bundle = BundleScript.new()
	missing_asset_id_bundle.manifest = _minimal_contract_manifest()
	missing_asset_id_bundle.documents = _minimal_contract_documents()
	missing_asset_id_bundle.documents["assets"]["managedAssets"] = [{"label": "Guard portrait"}]
	_expect(
		not missing_asset_id_bundle._validate_document_contract(),
		"bundle contract rejects a managed asset without its stable identity"
	)
	_expect(
		missing_asset_id_bundle.last_error.contains("assets.managedAssets[0]"),
		"managed asset identity error includes record-level context"
	)

	var unsafe_asset_path_bundle = BundleScript.new()
	unsafe_asset_path_bundle.manifest = _minimal_contract_manifest()
	unsafe_asset_path_bundle.documents = _minimal_contract_documents()
	unsafe_asset_path_bundle.documents["assets"]["catalog"]["pictures"] = [{
		"resourceId": 32128,
		"payloadPath": "C:/decoded/picture.png",
	}]
	_expect(
		not unsafe_asset_path_bundle._validate_document_contract(),
		"bundle contract rejects an absolute asset payload path"
	)
	_expect(
		unsafe_asset_path_bundle.last_error.contains("assets.catalog.pictures[0].payloadPath"),
		"asset payload path error includes record-level context"
	)

	var runtime_media_bundle = BundleScript.new()
	runtime_media_bundle.manifest = _minimal_contract_manifest()
	runtime_media_bundle.documents = _minimal_contract_documents()
	runtime_media_bundle.documents["assets"]["catalog"]["pictures"] = [{
		"resourceId": 32128,
		"payloadEncoding": "classic-resource-data",
		"payloadPath": "assets/managed/pict-32128.pict",
		"runtimeMedia": {
			"path": "media/pictures/32128.png",
			"mediaType": "image/png",
			"bytes": 41700,
			"sha256": "a".repeat(64),
		},
	}]
	_expect(
		runtime_media_bundle._validate_document_contract(),
		"bundle contract keeps decoded runtime media separate from Classic payloads"
	)

	var unsafe_runtime_media_bundle = BundleScript.new()
	unsafe_runtime_media_bundle.manifest = _minimal_contract_manifest()
	unsafe_runtime_media_bundle.documents = _minimal_contract_documents()
	unsafe_runtime_media_bundle.documents["assets"]["catalog"]["sounds"] = [{
		"resourceId": 321,
		"runtimeMedia": {
			"path": "../outside.wav",
			"mediaType": "audio/wav",
			"bytes": 10,
			"sha256": "b".repeat(64),
		},
	}]
	_expect(
		not unsafe_runtime_media_bundle._validate_document_contract(),
		"bundle contract rejects unsafe runtime-media paths"
	)
	_expect(
		unsafe_runtime_media_bundle.last_error.contains(
			"assets.catalog.sounds[0].runtimeMedia.path"
		),
		"runtime-media path error includes record-level context"
	)

	var mismatched_runtime_media_bundle = BundleScript.new()
	mismatched_runtime_media_bundle.manifest = _minimal_contract_manifest()
	mismatched_runtime_media_bundle.documents = _minimal_contract_documents()
	mismatched_runtime_media_bundle.documents["maps"]["mapRecords"] = [{
		"id": 2,
		"runtimeMedia": {
			"path": "media/maps/waterford.wav",
			"mediaType": "audio/wav",
			"bytes": 10,
			"sha256": "not-a-sha256",
		},
	}]
	_expect(
		not mismatched_runtime_media_bundle._validate_document_contract(),
		"bundle contract requires image runtime media for player maps"
	)
	_expect(
		mismatched_runtime_media_bundle.last_error.contains("runtimeMedia.mediaType"),
		"player-map media error identifies its mismatched type"
	)

	var special_land_tile_bundle = BundleScript.new()
	special_land_tile_bundle.manifest = _minimal_contract_manifest()
	special_land_tile_bundle.documents = _minimal_contract_documents()
	special_land_tile_bundle.documents["assets"]["catalog"]["specialLandTiles"] = [{
		"id": "resource:cicn:-100",
		"resourceId": -100,
		"payloadPath": "assets/managed/special-land-tile.cicn",
	}]
	_expect(
		special_land_tile_bundle._validate_document_contract(),
		"bundle contract accepts signed special-land-tile identities"
	)

	var negative_icon_bundle = BundleScript.new()
	negative_icon_bundle.manifest = _minimal_contract_manifest()
	negative_icon_bundle.documents = _minimal_contract_documents()
	negative_icon_bundle.documents["assets"]["catalog"]["icons"] = [{"resourceId": -100}]
	_expect(
		not negative_icon_bundle._validate_document_contract(),
		"bundle contract keeps ordinary icon identities non-negative"
	)
	_expect(
		negative_icon_bundle.last_error.contains("assets.catalog.icons[0].resourceId"),
		"ordinary icon identity error includes record-level context"
	)

	var unsafe_special_land_tile_bundle = BundleScript.new()
	unsafe_special_land_tile_bundle.manifest = _minimal_contract_manifest()
	unsafe_special_land_tile_bundle.documents = _minimal_contract_documents()
	unsafe_special_land_tile_bundle.documents["assets"]["catalog"]["specialLandTiles"] = [{
		"resourceId": -100,
		"payloadPath": "../managed/special-land-tile.cicn",
	}]
	_expect(
		not unsafe_special_land_tile_bundle._validate_document_contract(),
		"bundle contract rejects an unsafe special-land-tile payload path"
	)
	_expect(
		unsafe_special_land_tile_bundle.last_error.contains(
			"assets.catalog.specialLandTiles[0].payloadPath"
		),
		"special-land-tile payload path error includes record-level context"
	)

	var forward_compatible_bundle = BundleScript.new()
	forward_compatible_bundle.manifest = _minimal_contract_manifest()
	forward_compatible_bundle.documents = _minimal_contract_documents()
	forward_compatible_bundle.documents["scenario"]["preservedCompilerEvidence"] = {
		"status": "unknown",
		"bytes": [17, 34],
	}
	_expect(
		forward_compatible_bundle._validate_document_contract(),
		"bundle contract accepts unknown preserved evidence fields"
	)

	var encounter_action_bundle = BundleScript.new()
	encounter_action_bundle.manifest = _minimal_contract_manifest()
	encounter_action_bundle.documents = _minimal_contract_documents()
	encounter_action_bundle.documents["encounters"]["simpleEncounters"] = [{
		"id": 4,
		"actions": [{"slot": 32, "rawCode": 1, "id": 7}],
	}]
	_expect(
		not encounter_action_bundle._validate_document_contract(),
		"bundle contract rejects an out-of-range encounter-result slot"
	)
	_expect(
		encounter_action_bundle.last_error.contains("simpleEncounters[0].actions[0].slot"),
		"encounter action error includes record and slot context"
	)


func _test_providence_authoritative_export() -> void:
	var bundle = BundleScript.new()
	_expect(
		bundle.load_from_directory(PROVIDENCE_AUTHORITATIVE_FIXTURE),
		"Providence authoritative export loads: %s" % bundle.last_error
	)
	if not bundle.last_error.is_empty():
		return

	_expect_equal(bundle.manifest.get("id"), "providence-ownership-proof", "producer fixture identity")
	_expect_equal(bundle.documents["maps"].get("maps", []).size(), 2, "producer fixture map count")
	_expect_equal(bundle.documents["scripts"].get("triggers", []).size(), 3, "producer fixture trigger count")
	_expect_equal(
		bundle.documents["encounters"].get("simpleEncounters", []).size()
		+ bundle.documents["encounters"].get("complexEncounters", []).size(),
		2,
		"producer fixture encounter count"
	)

	var provenance_value: Variant = JSON.parse_string(
		FileAccess.get_file_as_string(PROVIDENCE_AUTHORITATIVE_PROVENANCE)
	)
	_expect(provenance_value is Dictionary, "producer fixture provenance parses")
	if not (provenance_value is Dictionary):
		return
	var provenance: Dictionary = provenance_value
	_expect_equal(
		provenance.get("producer", {}).get("commit"),
		"cc5055c9627f418ec1c538da8a2148025c4b180a",
		"producer fixture records its Providence commit"
	)
	var expected_readiness: Dictionary = provenance.get("readiness", {})
	_expect(bool(expected_readiness.get("ready", false)), "producer fixture provenance is ready")
	_expect_equal(
		expected_readiness.get("progressionBlockers"),
		0,
		"producer fixture provenance records no progression blockers"
	)
	_expect_equal(
		expected_readiness.get("fidelityFallbacks"),
		0,
		"producer fixture provenance records no fidelity fallbacks"
	)
	var expected_files: Array = provenance.get("files", [])
	_expect_equal(expected_files.size(), 16, "producer fixture provenance covers every file")
	for expected_value: Variant in expected_files:
		if not (expected_value is Dictionary):
			_expect(false, "producer fixture provenance file entry is an object")
			continue
		var expected: Dictionary = expected_value
		var relative_path := str(expected.get("path", ""))
		var fixture_path := PROVIDENCE_AUTHORITATIVE_FIXTURE.path_join(relative_path)
		_expect(FileAccess.file_exists(fixture_path), "producer fixture includes %s" % relative_path)
		if not FileAccess.file_exists(fixture_path):
			continue
		var file := FileAccess.open(fixture_path, FileAccess.READ)
		_expect_equal(file.get_length(), int(expected.get("bytes", -1)), "%s byte count" % relative_path)
		_expect_equal(
			FileAccess.get_sha256(fixture_path),
			str(expected.get("sha256", "")),
			"%s content hash" % relative_path
		)

	var assets: Dictionary = bundle.documents["assets"]
	var catalog: Dictionary = assets.get("catalog", {})
	_expect_equal(assets.get("managedAssets", []).size(), 5, "producer fixture managed asset count")
	_expect_equal(catalog.get("icons", []).size(), 0, "producer fixture ordinary icon count")
	var special_land_tiles: Array = catalog.get("specialLandTiles", [])
	_expect_equal(special_land_tiles.size(), 1, "producer fixture special-land-tile count")
	_expect(
		not catalog.get("pictures", [])[0].has("runtimeMedia"),
		"producer fixture distinguishes preserved Classic bytes from decoded runtime media"
	)
	_expect_equal(
		bundle.get_sound(321).get("payloadEncoding"),
		"classic-resource-data",
		"producer fixture indexes immutable sound payload metadata"
	)
	_expect_equal(
		bundle.get_sound(321).get("runtimeMedia", {}).get("mediaType"),
		"audio/wav",
		"producer fixture indexes decoded sound runtime media"
	)
	_expect(
		FileAccess.file_exists(
			PROVIDENCE_AUTHORITATIVE_FIXTURE.path_join(
				str(bundle.get_sound(321).get("runtimeMedia", {}).get("path", ""))
			)
		),
		"producer fixture includes decoded sound runtime media"
	)
	if special_land_tiles.size() == 1:
		_expect_equal(special_land_tiles[0].get("resourceId"), -100, "special land tile keeps signed identity")
		_expect_equal(
			special_land_tiles[0].get("payloadEncoding"),
			"classic-resource-data",
			"special land tile keeps its payload encoding"
		)
		_expect_equal(
			special_land_tiles[0].get("runtimeMedia", {}).get("mediaType"),
			"image/png",
			"producer fixture indexes decoded special-land runtime media"
		)
		_expect(
			FileAccess.file_exists(
				PROVIDENCE_AUTHORITATIVE_FIXTURE.path_join(
					str(special_land_tiles[0].get("runtimeMedia", {}).get("path", ""))
				)
			),
			"producer fixture includes decoded special-land runtime media"
		)
	for asset_value: Variant in assets.get("managedAssets", []):
		if not (asset_value is Dictionary):
			continue
		var payload_path := str(asset_value.get("payloadPath", ""))
		_expect(bundle._is_safe_campaign_path(payload_path), "managed asset path remains portable")
		_expect(
			FileAccess.file_exists(PROVIDENCE_AUTHORITATIVE_FIXTURE.path_join(payload_path)),
			"managed asset payload exists: %s" % payload_path
		)

	var readiness: Dictionary = ReadinessScript.new().inspect(bundle)
	_expect(bool(readiness.get("ready", false)), "producer fixture is runtime ready")
	_expect_equal(
		readiness.get("totals", {}).get("progressionBlockers"),
		0,
		"producer fixture has no progression blockers"
	)
	_expect_equal(
		readiness.get("totals", {}).get("fidelityFallbacks"),
		0,
		"producer fixture has no fidelity fallbacks"
	)
	_expect(
		not _readiness_has_reference_diagnostic(readiness, "unresolved-spell-identity", 5202),
		"producer fixture resolves its packed custom-spell identity"
	)

	var fixture_coverage: Dictionary = MaterializationFixtureAuditScript.inspect(
		bundle.documents
	)
	_expect(
		bool(fixture_coverage.get("accepted", false)),
		"checked producer fixture covers all four materialization capabilities"
	)
	_expect_equal(
		fixture_coverage.get("missingCapabilities"),
		[],
		"checked producer fixture has no materialization coverage gaps"
	)
	_expect_equal(
		fixture_coverage.get("capabilities", {}).get(
			"scenarioLocalShopItem", {}
		).get("details", {}).get("itemId"),
		901,
		"producer fixture covers its scenario-local shop item"
	)
	_expect_equal(
		fixture_coverage.get("capabilities", {}).get(
			"battleMonster", {}
		).get("details", {}).get("monsterId"),
		1,
		"producer fixture covers its battle monster"
	)
	_expect_equal(
		fixture_coverage.get("capabilities", {}).get(
			"carriedEquippedItem", {}
		).get("details", {}).get("itemId"),
		902,
		"producer fixture covers its carried and equipped scenario weapon"
	)
	_expect_equal(
		fixture_coverage.get("capabilities", {}).get(
			"ally", {}
		).get("details", {}).get("monsterId"),
		1,
		"producer fixture covers its authored ally action"
	)


func _minimal_contract_manifest() -> Dictionary:
	return {
		"format": BundleScript.FORMAT,
		"formatVersion": BundleScript.FORMAT_VERSION,
		"campaignKind": BundleScript.CAMPAIGN_KIND,
		"compatibilityProfile": BundleScript.COMPATIBILITY_PROFILE,
		"id": "scenario-contract-test",
		"name": "Contract Test",
		"start": {"levelType": "land", "levelIndex": 0, "x": 0, "y": 0},
		"files": {
			"scenario": "classic/scenario.json",
			"maps": "classic/maps.json",
			"scripts": "classic/scripts.json",
			"encounters": "classic/encounters.json",
			"content": "classic/content.json",
			"rules": "classic/rules.json",
			"assets": "classic/assets.json",
			"evidence": "classic/evidence.json",
		},
	}


func _minimal_contract_documents() -> Dictionary:
	return {
		"scenario": {
			"schemaVersion": BundleScript.DOCUMENT_SCHEMA_VERSION,
			"identity": {"id": "scenario-contract-test", "name": "Contract Test"},
		},
		"maps": {"schemaVersion": 1, "maps": []},
		"scripts": {
			"schemaVersion": 1,
			"triggers": [],
			"extraCodes": [],
			"messages": [],
			"randomLevels": [],
		},
		"encounters": {
			"schemaVersion": 1,
			"battles": [],
			"treasures": [],
			"shops": [],
			"simpleEncounters": [],
			"complexEncounters": [],
			"thiefEncounters": [],
			"timedEncounters": [],
		},
		"content": {
			"schemaVersion": 1,
			"monsters": [],
			"scenarioItems": [],
			"itemTexts": [],
		},
		"rules": {"schemaVersion": 1},
		"assets": {
			"schemaVersion": 1,
			"catalog": {"pictures": [], "sounds": []},
		},
		"evidence": {"schemaVersion": 1, "semanticDecoding": {}},
	}


func _test_native_battle_bridge_fixture() -> void:
	var bundle = BundleScript.new()
	_expect(
		bundle.load_from_directory(NATIVE_BATTLE_BRIDGE_FIXTURE),
		"native battle bridge fixture loads: %s" % bundle.last_error
	)
	if not bundle.last_error.is_empty():
		return
	var outer_trigger: Dictionary = bundle.get_trigger("Data DD:0:200")
	_expect_equal(
		outer_trigger.get("actions", []).map(
			func(action: Dictionary) -> int: return int(action.get("code", 0))
		),
		[57, 2, 1, 24],
		"native battle fixture covers mutation, battle, resume text, and completion"
	)
	_expect_equal(
		bundle.get_extra_action_point(900).get("actions", [])[0].get("code"),
		121,
		"native battle fixture provides its roster-mutation combat macro"
	)
	_expect_equal(bundle.get_battle(24).get("id"), 24, "native battle fixture requests Battle_24")
	_expect_equal(
		bundle.get_monster(78).get("displayName"),
		"Zombie",
		"native battle fixture identifies its lower-undead roster target"
	)


func _test_installed_classic_campaign_layout() -> void:
	var campaigns_directory := PROVIDENCE_AUTHORITATIVE_FIXTURE.get_base_dir()
	var campaign_name := PROVIDENCE_AUTHORITATIVE_FIXTURE.get_file()
	_expect(
		CampaignInstallScript.has_manifest(campaigns_directory, campaign_name),
		"installed Classic campaign is selected by campaign.json"
	)
	_expect(
		not CampaignInstallScript.has_manifest(campaigns_directory, "../%s" % campaign_name),
		"installed campaign discovery rejects traversal names"
	)

	var install = CampaignInstallScript.new()
	_expect(
		install.load_from_campaigns_directory(campaigns_directory, campaign_name),
		"self-contained Classic campaign layout loads: %s" % install.last_error
	)
	if not install.last_error.is_empty():
		return
	_expect_equal(
		install.campaign_directory,
		PROVIDENCE_AUTHORITATIVE_FIXTURE,
		"installed bundle remains inside its selected campaign directory"
	)
	_expect_equal(
		install.bundle.manifest.get("campaignKind"),
		BundleScript.CAMPAIGN_KIND,
		"installed manifest selects the Classic compatibility runtime"
	)
	_expect_equal(
		install.selection_rules().get("formatVersion"),
		BundleScript.FORMAT_VERSION,
		"installed campaign reports its supported runtime version"
	)
	var producer_rules: Dictionary = install.selection_rules()
	_expect_equal(
		producer_rules.get("title"),
		"Providence Ownership Proof",
		"installed campaign selection uses its manifest title"
	)
	_expect_equal(
		producer_rules.get("versionLabel"),
		"Classic format v1 (realmz-7.1)",
		"installed campaign selection identifies its compatibility contract"
	)
	_expect_equal(
		producer_rules.get("readinessState"),
		"Blocked",
		"structurally valid campaign without native maps is blocked from launch"
	)
	_expect(
		str(producer_rules.get("diagnostic", "")).contains("Native start map map_0"),
		"blocked installed campaign explains its missing native start map"
	)

	var ready_campaigns_directory := CAMPAIGN_UI_SMOKE_FIXTURE.get_base_dir()
	var ready_campaign_name := CAMPAIGN_UI_SMOKE_FIXTURE.get_file()
	var ready_install = CampaignInstallScript.new()
	_expect(
		ready_install.load_from_campaigns_directory(
			ready_campaigns_directory,
			ready_campaign_name
		),
		"ready campaign UI fixture loads: %s" % ready_install.last_error
	)
	var ready_rules: Dictionary = ready_install.selection_rules()
	_expect_equal(
		ready_rules.get("title"),
		"Classic Campaign UI Smoke",
		"ready campaign selection exposes its manifest title"
	)
	_expect_equal(
		ready_rules.get("readinessState"),
		"Ready",
		"compiled campaign with a complete native start map is ready"
	)
	_expect(
		bool(ready_rules.get("valid", false)),
		"ready compiled campaign may proceed through party selection"
	)
	var managed_assets: Array = install.bundle.documents.get("assets", {}).get(
		"managedAssets",
		[]
	)
	var first_payload: Dictionary = managed_assets[0]
	var payload_bytes := int(first_payload.get("payloadBytes", 0))
	first_payload["payloadBytes"] = payload_bytes + 1
	_expect(
		not install._validate_packaged_payloads(),
		"installed campaign rejects a payload with the wrong size"
	)
	_expect(
		install.last_error.contains("wrong size"),
		"payload size failure returns an actionable error"
	)
	first_payload["payloadBytes"] = payload_bytes
	var payload_path := str(first_payload.get("payloadPath", ""))
	first_payload["payloadPath"] = "%s.missing" % payload_path
	_expect(
		not install._validate_packaged_payloads(),
		"installed campaign rejects a missing payload"
	)
	_expect(
		install.last_error.contains("missing payload"),
		"missing payload failure returns an actionable error"
	)
	first_payload["payloadPath"] = payload_path
	var picture: Dictionary = install.bundle.get_picture(306)
	var runtime_media_path := "campaign.json"
	var runtime_media_file := FileAccess.open(
		install.campaign_directory.path_join(runtime_media_path),
		FileAccess.READ
	)
	picture["runtimeMedia"] = {
		"path": runtime_media_path,
		"mediaType": "image/png",
		"bytes": runtime_media_file.get_length(),
		"sha256": FileAccess.get_sha256(
			install.campaign_directory.path_join(runtime_media_path)
		),
	}
	runtime_media_file.close()
	_expect(
		install._validate_packaged_payloads(),
		"installed campaign validates decoded runtime media separately"
	)
	picture["runtimeMedia"]["bytes"] = int(picture["runtimeMedia"]["bytes"]) + 1
	_expect(
		not install._validate_packaged_payloads(),
		"installed campaign rejects runtime media with the wrong size"
	)
	_expect(
		install.last_error.contains("runtime media has the wrong size"),
		"runtime-media integrity failure identifies the derived file"
	)
	picture.erase("runtimeMedia")

	var invalid_install = CampaignInstallScript.new()
	_expect(
		not invalid_install.load_from_campaigns_directory(
			campaigns_directory,
			"../%s" % campaign_name
		),
		"installed campaign loader rejects traversal before reading files"
	)
	_expect(
		invalid_install.last_error.contains("one installed campaign directory"),
		"unsafe install path returns an actionable error"
	)
	var invalid_rules: Dictionary = invalid_install.selection_rules()
	_expect_equal(
		invalid_rules.get("readinessState"),
		"Invalid",
		"invalid installed campaign remains visible as invalid"
	)
	_expect(
		str(invalid_rules.get("diagnostic", "")).contains(
			"one installed campaign directory"
		),
		"invalid installed campaign preserves its actionable diagnostic"
	)

	var session = CampaignSessionScript.new()
	get_root().add_child(session)
	var adapter = StartLocationAdapter.new()
	var load_result: Dictionary = session.load_installed_campaign(
		campaigns_directory,
		campaign_name,
		adapter
	)
	_expect_equal(load_result.get("status"), "ok", "normal campaign session creates a runtime host")
	_expect_equal(
		adapter.configured_bundle,
		session.install.bundle,
		"installed campaign session configures its adapter from the selected bundle"
	)
	var start_result: Dictionary = session.activate_start_location()
	_expect_equal(start_result.get("nativeMapName"), "map_0", "installed campaign starts its native map")
	_expect_equal(start_result.get("position"), Vector2i(10, 12), "installed campaign starts at compiled coordinates")
	_expect_equal(
		start_result.get("persistentMapState", {}).get("status"),
		"ok",
		"installed campaign replays compatibility state before entry"
	)
	var original_documents: Dictionary = session.install.bundle.documents.duplicate(true)
	var saved_state: Object = session.host.runtime.runtime_state
	saved_state.set_quest_flag(37)
	saved_state.set_location("dungeon", 2, 14, 29)
	saved_state.set_dungeon_view(3, true)
	saved_state.set_compass_enabled(false)
	saved_state.set_difficulty(-1)
	saved_state.set_priest_turning_enabled(false)
	saved_state.set_tile("dungeon", 2, 14, 29, 118)
	saved_state.set_trigger_percent("dungeon", 2, 7, 35)
	saved_state.set_action_point_override("save:test", {"id": "save:test", "active": false})
	saved_state.set_thief_encounter_override(4, {"id": 4, "tumblers": 0})
	saved_state.set_simple_encounter_override(2, {"id": 2, "maximumAttempts": 1})
	saved_state.set_complex_encounter_override(3, {"id": 3, "maximumAttempts": 2})
	saved_state.set_timed_encounter_override(1, {"id": 1, "chancePercent": 0})
	session.install.bundle.player_maps_by_id[2] = {
		"id": 2,
		"primaryName": "Second Map",
	}
	session.install.bundle.player_maps_by_id[6] = {
		"id": 6,
		"primaryName": "Sixth Map",
	}
	saved_state.set_map_owned(6)
	var acquired_maps: Array = session.acquired_player_map_entries()
	_expect_equal(acquired_maps.size(), 1, "campaign session filters unacquired player maps")
	_expect_equal(
		acquired_maps[0]["record"].get("id"),
		6,
		"campaign session exposes the acquired player-map record"
	)
	saved_state.set_map_owned(2)
	acquired_maps = session.acquired_player_map_entries()
	_expect_equal(
		[
			acquired_maps[0]["record"].get("id"),
			acquired_maps[1]["record"].get("id"),
		],
		[2, 6],
		"campaign session orders acquired player maps by stable ID"
	)
	saved_state.set_random_rectangle("dungeon", 2, 1, {
		"rectIndex": 1,
		"percent": 42,
		"battleRange": [3, 5],
	})
	adapter.compatibility_state = {
		"storedPartyEquipment": {"active": true, "itemCount": 2},
	}
	var save_payload: Dictionary = session.make_save_payload()
	_expect_equal(
		save_payload.get("schemaVersion"),
		CampaignSessionScript.SAVE_SCHEMA_VERSION,
		"campaign save payload records its schema version"
	)
	_expect_equal(
		save_payload.get("campaignId"),
		"providence-ownership-proof",
		"campaign save payload records the compiled campaign identity"
	)
	var serialized_payload := JSON.stringify(save_payload)
	var parsed_payload: Variant = JSON.parse_string(serialized_payload)
	_expect(parsed_payload is Dictionary, "campaign save payload is JSON serializable")
	var version_one_payload: Dictionary = parsed_payload.duplicate(true)
	version_one_payload["schemaVersion"] = 1
	version_one_payload.erase("continuationState")
	_expect_equal(
		CampaignSessionScript.validate_save_payload(
			version_one_payload,
			"providence-ownership-proof"
		).get("status"),
		"ok",
		"version-one campaign save remains loadable as an idle continuation"
	)

	var restored_session = CampaignSessionScript.new()
	get_root().add_child(restored_session)
	var restored_adapter = StartLocationAdapter.new()
	_expect_equal(
		restored_session.load_installed_campaign(
			campaigns_directory,
			campaign_name,
			restored_adapter
		).get("status"),
		"ok",
		"saved campaign reload creates a fresh runtime host"
	)
	var restore_result: Dictionary = restored_session.restore_save_payload(parsed_payload)
	_expect_equal(restore_result.get("status"), "ok", "campaign save payload restores")
	var restored_state: Object = restored_session.host.runtime.runtime_state
	_expect(restored_state.is_quest_set(37), "saved campaign restores quest flags")
	_expect_equal(restored_state.level_type, "dungeon", "saved campaign restores map family")
	_expect_equal(restored_state.level_index, 2, "saved campaign restores map level")
	_expect_equal(restored_state.x, 14, "saved campaign restores x position")
	_expect_equal(restored_state.y, 29, "saved campaign restores y position")
	_expect_equal(restored_state.heading, 3, "saved campaign restores heading")
	_expect(restored_state.multi_view, "saved campaign restores multi-view state")
	_expect(not restored_state.compass_enabled, "saved campaign restores compass state")
	_expect_equal(restored_state.difficulty, -1, "saved campaign restores difficulty")
	_expect(not restored_state.priest_turning_enabled, "saved campaign restores priest turning")
	_expect_equal(
		restored_state.get_tile("dungeon", 2, 14, 29, -1),
		118,
		"saved campaign restores tile mutations"
	)
	_expect_equal(
		restored_state.get_trigger_percent("dungeon", 2, 7, -1),
		35,
		"saved campaign restores trigger mutations"
	)
	_expect_equal(
		restored_state.get_action_point_override("save:test").get("active"),
		false,
		"saved campaign restores action-point mutations"
	)
	_expect_equal(
		restored_state.get_effective_thief_encounter({"id": 4}).get("tumblers"),
		0,
		"saved campaign restores thief-encounter mutations"
	)
	_expect_equal(
		restored_state.get_effective_simple_encounter({"id": 2}).get("maximumAttempts"),
		1,
		"saved campaign restores simple-encounter mutations"
	)
	_expect_equal(
		restored_state.get_effective_complex_encounter({"id": 3}).get("maximumAttempts"),
		2,
		"saved campaign restores complex-encounter mutations"
	)
	_expect_equal(
		restored_state.get_effective_timed_encounter({"id": 1}).get("chancePercent"),
		0,
		"saved campaign restores timed-encounter mutations"
	)
	_expect(restored_state.is_map_owned(6), "saved campaign restores acquired maps")
	_expect_equal(
		restored_adapter.compatibility_state.get("storedPartyEquipment", {}).get("itemCount"),
		2,
		"saved campaign restores adapter-owned equipment capture"
	)
	var resumed_result: Dictionary = restored_session.activate_start_location(true)
	_expect_equal(resumed_result.get("nativeMapName"), "mapd_2", "saved campaign enters its restored map")
	_expect_equal(resumed_result.get("position"), Vector2i(14, 29), "saved campaign enters its restored position")
	_expect(
		bool(restored_adapter.start_location.get("forceReload", false)),
		"saved campaign requests a fresh native map load"
	)
	_expect_equal(
		session.install.bundle.documents,
		original_documents,
		"creating a save leaves the compiled bundle immutable"
	)
	_expect_equal(
		restored_session.install.bundle.documents,
		original_documents,
		"restoring a save leaves the compiled bundle immutable"
	)

	var future_payload: Dictionary = save_payload.duplicate(true)
	future_payload["schemaVersion"] = CampaignSessionScript.SAVE_SCHEMA_VERSION + 1
	var future_result: Dictionary = CampaignSessionScript.validate_save_payload(
		future_payload,
		"providence-ownership-proof"
	)
	_expect_equal(future_result.get("status"), "error", "future save schema is rejected")
	_expect(
		str(future_result.get("message", "")).contains("newer than this build"),
		"future save rejection is actionable"
	)
	var wrong_campaign_result: Dictionary = CampaignSessionScript.validate_save_payload(
		save_payload,
		"another-campaign"
	)
	_expect_equal(
		wrong_campaign_result.get("status"),
		"error",
		"save payload cannot be restored into another campaign"
	)
	_expect_equal(
		CampaignSessionScript.validate_save_payload({}).get("status"),
		"legacy",
		"save without a Classic envelope is recognized as legacy"
	)
	var legacy_result: Dictionary = restored_session.restore_legacy_native_location({
		"mapName": "map_4",
		"x": 8,
		"y": 11,
	})
	_expect_equal(legacy_result.get("status"), "ok", "legacy save uses native location fallback")
	_expect_equal(restored_state.level_type, "land", "legacy save infers its map family")
	_expect_equal(restored_state.level_index, 4, "legacy save infers its map level")
	_expect_equal(restored_state.x, 8, "legacy save restores x position")
	_expect_equal(restored_state.y, 11, "legacy save restores y position")
	var equipment_adapter = GodotAdapterScript.new()
	equipment_adapter.stored_party_equipment = {
		"active": true,
		"inventories": [[{
			"name": "Stored Blade",
			"texture": "runtime-only",
			"equipped": 1,
		}]],
		"wealth": [4, 3, 2],
		"itemCount": 1,
	}
	var equipment_save: Dictionary = equipment_adapter.classic_save_state()
	var saved_item: Dictionary = equipment_save.get("storedPartyEquipment", {}).get(
		"inventories",
		[]
	)[0][0]
	_expect(not saved_item.has("texture"), "equipment capture omits runtime-only textures")
	_expect(
		equipment_adapter.stored_party_equipment.get("inventories", [])[0][0].has("texture"),
		"serializing equipment does not mutate the active capture"
	)
	var reloaded_equipment_adapter = GodotAdapterScript.new()
	_expect_equal(
		reloaded_equipment_adapter.restore_classic_save_state(equipment_save).get("status"),
		"ok",
		"adapter-owned equipment capture restores"
	)
	_expect_equal(
		reloaded_equipment_adapter.stored_party_equipment.get("wealth"),
		[4, 3, 2],
		"adapter-owned captured wealth restores"
	)
	var equipment_before_invalid_restore: Dictionary = \
		reloaded_equipment_adapter.stored_party_equipment.duplicate(true)
	var invalid_equipment_result: Dictionary = \
		reloaded_equipment_adapter.restore_classic_save_state({
			"storedPartyEquipment": {
				"active": true,
				"inventories": [{"not": "an inventory"}],
			},
		})
	_expect_equal(
		invalid_equipment_result.get("status"),
		"error",
		"invalid equipment capture is rejected before load"
	)
	_expect(
		str(invalid_equipment_result.get("message", "")).contains("stored inventory"),
		"invalid equipment capture returns an actionable error"
	)
	_expect_equal(
		reloaded_equipment_adapter.stored_party_equipment,
		equipment_before_invalid_restore,
		"rejected equipment capture leaves adapter state unchanged"
	)
	restored_session.clear()
	restored_session.queue_free()
	session.clear()
	session.queue_free()


func _test_classic_map_materializer() -> void:
	var bundle = BundleScript.new()
	_expect(
		bundle.load_from_directory(PROVIDENCE_AUTHORITATIVE_FIXTURE),
		"producer fixture loads for native map materialization"
	)
	if not bundle.last_error.is_empty():
		return
	var map_record: Dictionary = bundle.documents["maps"]["maps"][0]
	var tiles: Array = []
	tiles.resize(int(map_record["width"]) * int(map_record["height"]))
	tiles.fill(156)
	tiles[0] = 1156
	tiles[1] = -100
	tiles[2] = 5
	tiles[3] = 6
	map_record["tiles"] = tiles
	var custom_landlook: Dictionary = bundle.documents["maps"]["customLandlooks"][0]
	custom_landlook["records"][6]["time"] = 9
	custom_landlook["records"][6]["solid"] = 1
	custom_landlook["records"][6]["los"] = 1
	bundle.documents["maps"]["tileAttributes"].append({
		"solidType": 2,
		"source": "Data Solids",
		"sourceKind": "data-solids",
		"tile": 100,
	})
	var random_level: Dictionary = bundle.get_random_level("land", 0)
	random_level["isDark"] = true
	random_level["useLos"] = true
	random_level["rects"] = [{
		"battleRange": [4, 6],
		"bottom": 8,
		"left": 2,
		"option": 35,
		"percent": 2500,
		"rectIndex": 3,
		"right": 7,
		"sound": 12,
		"text": 1,
		"top": 1,
	}]
	bundle.documents["maps"]["maps"][1] = {
		"height": 3,
		"id": "dungeon:0",
		"index": 0,
		"levelType": "dungeon",
		"render": {
			"landlook": null,
			"mode": "dungeon-top-down",
			"tilesetId": "dungeon-top-down-302",
		},
		"tiles": [0, 1, 2, 4, 8, 16, 128, 4097, -32767],
		"width": 3,
	}

	var test_root := ProjectSettings.globalize_path(
		"user://classic-map-materializer-%d" % Time.get_ticks_msec()
	)
	_expect_equal(
		CampaignPackageInstallerScript.new()._remove_directory(test_root),
		OK,
		"materializer test clears stale output from an interrupted run"
	)
	DirAccess.make_dir_recursive_absolute(test_root)
	var managed_directory := test_root.path_join("assets").path_join("managed")
	DirAccess.make_dir_recursive_absolute(managed_directory)
	for payload_name: String in [
		"pict-306-d08dae63460f.pict",
		"cicn-neg-100-363a140e3045.cicn",
	]:
		_expect_equal(
			DirAccess.copy_absolute(
				ProjectSettings.globalize_path(
					PROVIDENCE_AUTHORITATIVE_FIXTURE.path_join(
						"assets/managed/%s" % payload_name
					)
				),
				managed_directory.path_join(payload_name)
			),
			OK,
			"materializer fixture stages immutable %s" % payload_name
		)
	var runtime_image_directory := test_root.path_join("media").path_join("images")
	DirAccess.make_dir_recursive_absolute(runtime_image_directory)
	var runtime_image_name := "cicn-neg-100-31df32a766f9.png"
	_expect_equal(
		DirAccess.copy_absolute(
			ProjectSettings.globalize_path(
				PROVIDENCE_AUTHORITATIVE_FIXTURE.path_join(
					"media/images/%s" % runtime_image_name
				)
			),
			runtime_image_directory.path_join(runtime_image_name)
		),
		OK,
		"materializer fixture stages decoded special-land runtime media"
	)
	var materializer = MapMaterializerScript.new()
	_expect_equal(
		materializer._special_land_resource_id(-1100),
		-100,
		"second-band special land field resolves to its signed cicn identity"
	)
	_expect_equal(
		materializer._special_land_resource_id(-2100),
		-100,
		"third-band special land field resolves to its signed cicn identity"
	)
	var result: Dictionary = materializer.materialize(bundle, test_root)
	_expect_equal(result.get("status"), "ok", "normalized map generates native artifacts")
	_expect_equal(
		result.get("generatedMaps"),
		["map_0", "mapd_0"],
		"materializer reports generated land and dungeon maps"
	)
	var map_directory := test_root.path_join("Maps").path_join("map_0")
	for file_name: String in MapMaterializerScript.REQUIRED_MAP_FILES:
		_expect(
			FileAccess.file_exists(map_directory.path_join(file_name)),
			"materializer writes %s" % file_name
		)
	var map_things: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string(map_directory.path_join("map_things.json"))
	)
	_expect_equal(
		map_things.get("tilesets", [])[0].get("source"),
		"landlook-6.json",
		"custom Classic landlook resolves to its generated native tileset"
	)
	_expect_equal(
		map_things.get("layers", [])[0].get("chunks", [])[0].get("data", [])[0],
		156,
		"Classic tile flags normalize to the one-based native atlas slot"
	)
	_expect_equal(
		map_things.get("layers", [])[0].get("chunks", [])[0].get("data", [])[1],
		156,
		"special land tile keeps the current landlook base terrain"
	)
	_expect_equal(
		map_things.get("layers", [])[0].get("chunks", [])[0].get("data", [])[2],
		5,
		"custom land tile keeps its one-based atlas slot"
	)
	_expect_equal(map_things.get("layers", []).size(), 2, "special land tile adds an overlay layer")
	var overlay_first_gid := int(map_things.get("tilesets", [])[1].get("firstgid", 0))
	_expect_equal(
		map_things.get("tilesets", [])[1].get("source"),
		"ClassicLandOverlay.json",
		"special land tile uses its generated native overlay tileset"
	)
	_expect_equal(
		map_things.get("layers", [])[1].get("chunks", [])[0].get("data", [])[1],
		overlay_first_gid,
		"special land tile is layered over its source cell"
	)
	var map_info: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string(map_directory.path_join("map_info.json"))
	)
	_expect_equal(map_info.get("darkness_level"), 0, "generated map preserves darkness")
	_expect_equal(
		map_info.get("display_explored_only"),
		1,
		"generated map preserves line-of-sight exploration"
	)
	var script_areas: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string(map_directory.path_join("map_scriptareas.json"))
	)
	_expect_equal(
		script_areas.get("ScriptRects", {}).get("AP0x11y12", {}).get("scriptToLoad"),
		"land:0:ap:0",
		"native map area dispatches the producer's stable trigger ID"
	)
	_expect_equal(
		script_areas.get("ScriptRects", {}).get("AP0x11y12", {}).get("chance"),
		1.0,
		"native map area preserves the Classic trigger chance"
	)
	var random_area: Dictionary = script_areas.get("ScriptRects", {}).get("LRR0.3", {})
	_expect_equal(random_area.get("chance"), 0.25, "native map preserves random-area chance")
	_expect_equal(
		random_area.get("scriptRectangle"),
		[[2.0, 1.0], [7.0, 8.0]],
		"native map preserves random-area bounds"
	)
	_expect_equal(
		random_area.get("RR_Battle", {}).get("battle_range"),
		[4.0, 6.0],
		"native map preserves random battle range"
	)
	_expect_equal(
		random_area.get("RR_Battle", {}).get("text"),
		"Providence owns this rogue encounter.",
		"native map resolves random battle text"
	)
	var dungeon_directory := test_root.path_join("Maps").path_join("mapd_0")
	var custom_land_directory := test_root.path_join("Tilesets").path_join("landlook-6")
	var custom_land_tileset: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string(custom_land_directory.path_join("landlook-6.json"))
	)
	_expect_equal(
		custom_land_tileset.get("tilecount"),
		200,
		"custom landlook materializes all source atlas slots"
	)
	_expect_equal(
		custom_land_tileset.get("columns"),
		20,
		"custom landlook retains the source atlas layout"
	)
	var custom_land_templates: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string(custom_land_directory.path_join("tile_templates.json"))
	)
	var path_template: Dictionary = custom_land_templates.get(
		"classic_landlook_6_005",
		{}
	)
	_expect_equal(path_template.get("time"), 2, "custom land tile preserves travel time")
	_expect_equal(
		path_template.get("classicSoundId"),
		321,
		"custom land tile preserves its Classic sound identity"
	)
	_expect_equal(path_template.get("classicPath"), 1, "custom land tile preserves path behavior")
	_expect_equal(
		path_template.get("classicClearLandId"),
		156,
		"custom land tile preserves clear-land behavior"
	)
	var solid_template: Dictionary = custom_land_templates.get(
		"classic_landlook_6_006",
		{}
	)
	_expect_equal(solid_template.get("wall"), 1, "custom solid tile blocks native movement")
	_expect_equal(solid_template.get("blkview"), 1, "custom LOS tile blocks native view")
	var generated_custom_land_image := Image.load_from_file(
		custom_land_directory.path_join("landlook-6.png")
	)
	_expect_equal(
		generated_custom_land_image.get_size(),
		Vector2i(640, 320),
		"custom landlook keeps the source-backed atlas dimensions"
	)
	_expect_equal(
		generated_custom_land_image.get_pixel(5 * 32 + 16, 16),
		Color8((5 * 40) & 0xf8, (5 * 72) & 0xf8, (5 * 104) & 0xf8, 255),
		"custom landlook decodes the producer's fifth atlas tile"
	)
	var land_overlay_directory := test_root.path_join("Tilesets").path_join(
		"ClassicLandOverlay"
	)
	var land_overlay_templates: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string(
			land_overlay_directory.path_join("tile_templates.json")
		)
	)
	_expect_equal(
		land_overlay_templates.get("classic_land_overlay_neg_100", {}).get(
			"classicResourceId"
		),
		-100,
		"special land overlay retains its normalized cicn identity"
	)
	_expect_equal(
		land_overlay_templates.get("classic_land_overlay_neg_100", {}).get("wall"),
		1,
		"Data Solids makes a raw special land tile block native movement"
	)
	var land_overlay_atlas := Image.load_from_file(
		land_overlay_directory.path_join("ClassicLandOverlay.png")
	)
	_expect_equal(
		land_overlay_atlas.get_size(),
		Vector2i(32, 32),
		"decoded special land art is preserved at the native tile size"
	)
	_expect_equal(
		land_overlay_atlas.get_pixel(16, 16),
		Color8(0xe8, 0xa0, 0x30, 255),
		"special land art decodes the producer's opaque cicn palette"
	)
	var dungeon_things: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string(dungeon_directory.path_join("map_things.json"))
	)
	_expect_equal(
		dungeon_things.get("tilesets", [])[0].get("source"),
		"ClassicDungeon.json",
		"Classic dungeon fields use their generated native tileset"
	)
	_expect_equal(
		dungeon_things.get("layers", [])[0].get("chunks", [])[0].get("data"),
		[1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0],
		"signed dungeon fields resolve to deterministic native GIDs"
	)
	var dungeon_tileset_directory := test_root.path_join("Tilesets").path_join(
		"ClassicDungeon"
	)
	var dungeon_tileset: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string(
			dungeon_tileset_directory.path_join("ClassicDungeon.json")
		)
	)
	_expect_equal(dungeon_tileset.get("tilecount"), 9, "dungeon tileset covers used fields")
	var dungeon_templates: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string(
			dungeon_tileset_directory.path_join("tile_templates.json")
		)
	)
	_expect_equal(
		dungeon_templates.get("classic_dungeon_0001", {}).get("wall"),
		1,
		"Classic dungeon wall bit blocks native movement"
	)
	_expect_equal(
		dungeon_templates.get("classic_dungeon_0002", {}).get("wall"),
		0,
		"Classic dungeon door remains passable"
	)
	_expect_equal(
		dungeon_templates.get("classic_dungeon_1001", {}).get("wall"),
		0,
		"Classic Action Point cells retain the source movement exception"
	)
	_expect_equal(
		dungeon_templates.get("classic_dungeon_8001", {}).get("classicDungeonField"),
		-32767,
		"generated dungeon tiles retain their signed Classic field value"
	)
	var dungeon_atlas := Image.load_from_file(
		dungeon_tileset_directory.path_join("ClassicDungeon.png")
	)
	_expect_equal(
		dungeon_atlas.get_size(),
		Vector2i(9 * 32, 32),
		"PICT 302 dungeon sprites are materialized at Remake's tile size"
	)
	var floor_image := dungeon_atlas.get_region(Rect2i(0, 0, 32, 32))
	var wall_image := dungeon_atlas.get_region(Rect2i(32, 0, 32, 32))
	var hidden_image := dungeon_atlas.get_region(Rect2i(6 * 32, 0, 32, 32))
	_expect(
		floor_image.get_data() != wall_image.get_data(),
		"generated dungeon wall is visibly distinct from open floor"
	)
	_expect(
		floor_image.get_data() == hidden_image.get_data(),
		"hidden dungeon field suppresses its overhead sprite"
	)
	var native_resources = NativeResourcesScript.new()
	native_resources.load_tile_resources("res://shared_assets/tiles")
	native_resources.load_tile_resources(test_root.path_join("Tilesets"))
	_expect_equal(
		native_resources.tiles_book.get("ClassicDungeon.json", []).size(),
		9,
		"normal resource lifecycle loads the generated dungeon tileset"
	)
	_expect_equal(
		native_resources.tiles_book.get("landlook-6.json", []).size(),
		200,
		"normal resource lifecycle loads the generated custom landlook"
	)
	native_resources.load_map_ressources(dungeon_directory + "/", "mapd_0")
	_expect(
		native_resources.maps_book.has("mapd_0"),
		"normal resource lifecycle loads the generated dungeon map"
	)
	native_resources.load_map_ressources(map_directory + "/", "map_0")
	_expect(
		native_resources.map_info_book.get("map_0", {}).has("classic_boats"),
		"normal resource lifecycle retains generated Classic boat metadata"
	)
	var special_land_stack: Array = native_resources.maps_book.get("map_0", [])[0][1][0]
	_expect_equal(
		special_land_stack.size(),
		2,
		"normal resource lifecycle loads base terrain and special-land overlay"
	)
	_expect_equal(
		special_land_stack[1].get("classicLandField"),
		-100,
		"loaded special-land overlay retains its raw field identity"
	)
	var custom_land_stack: Array = native_resources.maps_book.get("map_0", [])[0][2][0]
	_expect_equal(
		custom_land_stack[0].get("classicTileId"),
		5,
		"loaded custom land tile retains its Classic tile identity"
	)
	native_resources.free()
	var first_artifacts := {}
	var deterministic_files := [
		"Maps/map_0/map_info.json",
		"Maps/map_0/map_scriptareas.json",
		"Maps/map_0/map_scripts.gd",
		"Maps/map_0/map_things.json",
		"Maps/mapd_0/map_info.json",
		"Maps/mapd_0/map_scriptareas.json",
		"Maps/mapd_0/map_scripts.gd",
		"Maps/mapd_0/map_things.json",
		"Tilesets/ClassicLandOverlay/ClassicLandOverlay.json",
		"Tilesets/ClassicLandOverlay/tile_templates.json",
		"Tilesets/ClassicLandOverlay/ClassicLandOverlay.png",
		"Tilesets/ClassicDungeon/ClassicDungeon.json",
		"Tilesets/ClassicDungeon/tile_templates.json",
		"Tilesets/ClassicDungeon/ClassicDungeon.png",
		"Tilesets/landlook-6/landlook-6.json",
		"Tilesets/landlook-6/tile_templates.json",
		"Tilesets/landlook-6/landlook-6.png",
	]
	for relative_path: String in deterministic_files:
		first_artifacts[relative_path] = FileAccess.get_sha256(
			test_root.path_join(relative_path)
		)
	_expect_equal(
		CampaignPackageInstallerScript.new()._remove_directory(test_root.path_join("Maps")),
		OK,
		"materializer test removes its first generated maps"
	)
	_expect_equal(
		materializer.materialize(bundle, test_root).get("status"),
		"ok",
		"normalized map regenerates"
	)
	for relative_path: String in deterministic_files:
		_expect_equal(
			FileAccess.get_sha256(test_root.path_join(relative_path)),
			first_artifacts[relative_path],
			"materialized %s is deterministic" % relative_path
		)

	var unsupported_bundle = BundleScript.new()
	unsupported_bundle.load_from_directory(PROVIDENCE_AUTHORITATIVE_FIXTURE)
	unsupported_bundle.documents["maps"]["maps"][0]["render"] = {
		"landlook": 0,
		"mode": "outdoor-landlook",
		"tilesetId": "landlook-0",
	}
	var unsupported_directory := test_root.path_join("unsupported")
	DirAccess.make_dir_recursive_absolute(unsupported_directory)
	var unsupported_result: Dictionary = MapMaterializerScript.new().materialize(
		unsupported_bundle,
		unsupported_directory
	)
	_expect_equal(
		unsupported_result.get("status"),
		"error",
		"special Classic map tile blocks lossy native materialization"
	)
	_expect(
		str(unsupported_result.get("message", "")).contains(
			"special land tile -100 (cicn -100)"
		),
		"unsupported special tile reports its exact identity"
	)
	var invalid_media_directory := unsupported_directory.path_join("media")
	DirAccess.make_dir_recursive_absolute(invalid_media_directory)
	var invalid_media := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	invalid_media.fill(Color.WHITE)
	var invalid_media_path := invalid_media_directory.path_join("special-land-neg-100.png")
	_expect_equal(
		invalid_media.save_png(invalid_media_path),
		OK,
		"materializer fixture writes wrong-sized special-land media"
	)
	unsupported_bundle.documents["assets"]["catalog"]["specialLandTiles"][0][
		"runtimeMedia"
	] = {
		"path": "media/special-land-neg-100.png",
		"mediaType": "image/png",
		"bytes": FileAccess.get_file_as_bytes(invalid_media_path).size(),
		"sha256": FileAccess.get_sha256(invalid_media_path),
	}
	var invalid_media_result: Dictionary = MapMaterializerScript.new().materialize(
		unsupported_bundle,
		unsupported_directory
	)
	_expect_equal(
		invalid_media_result.get("status"),
		"error",
		"wrong-sized special land media blocks native materialization"
	)
	_expect(
		str(invalid_media_result.get("message", "")).contains("is 16 x 16"),
		"wrong-sized special land media reports its decoded dimensions"
	)
	var missing_custom_bundle = BundleScript.new()
	missing_custom_bundle.load_from_directory(PROVIDENCE_AUTHORITATIVE_FIXTURE)
	var missing_custom_map: Dictionary = missing_custom_bundle.documents["maps"]["maps"][0]
	var ordinary_custom_tiles: Array = []
	ordinary_custom_tiles.resize(
		int(missing_custom_map["width"]) * int(missing_custom_map["height"])
	)
	ordinary_custom_tiles.fill(156)
	missing_custom_map["tiles"] = ordinary_custom_tiles
	var missing_custom_directory := test_root.path_join("missing-custom-landlook")
	DirAccess.make_dir_recursive_absolute(missing_custom_directory)
	var missing_custom_result: Dictionary = MapMaterializerScript.new().materialize(
		missing_custom_bundle,
		missing_custom_directory
	)
	_expect_equal(
		missing_custom_result.get("status"),
		"error",
		"raw custom atlas blocks lossy native materialization"
	)
	_expect(
		str(missing_custom_result.get("message", "")).contains(
			"Classic tileset landlook-6 requires a decoded 640 x 320 runtimeMedia image"
		),
		"missing custom-land media reports the exact decoded requirement"
	)
	var wrong_custom_media_directory := missing_custom_directory.path_join("media")
	DirAccess.make_dir_recursive_absolute(wrong_custom_media_directory)
	var wrong_custom_media := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	wrong_custom_media.fill(Color.WHITE)
	var wrong_custom_media_path := wrong_custom_media_directory.path_join("landlook-6.png")
	_expect_equal(
		wrong_custom_media.save_png(wrong_custom_media_path),
		OK,
		"materializer fixture writes wrong-sized custom-land media"
	)
	missing_custom_bundle.documents["assets"]["catalog"]["tilesets"][1][
		"runtimeMedia"
	] = {
		"path": "media/landlook-6.png",
		"mediaType": "image/png",
		"bytes": FileAccess.get_file_as_bytes(wrong_custom_media_path).size(),
		"sha256": FileAccess.get_sha256(wrong_custom_media_path),
	}
	var wrong_custom_result: Dictionary = MapMaterializerScript.new().materialize(
		missing_custom_bundle,
		missing_custom_directory
	)
	_expect_equal(
		wrong_custom_result.get("status"),
		"error",
		"wrong-sized custom-land media blocks native materialization"
	)
	_expect(
		str(wrong_custom_result.get("message", "")).contains("is 32 x 32"),
		"wrong-sized custom-land media reports its decoded dimensions"
	)

	var directional_bundle = BundleScript.new()
	directional_bundle.load_from_directory(PROVIDENCE_AUTHORITATIVE_FIXTURE)
	var directional_land: Dictionary = directional_bundle.documents["maps"]["maps"][0]
	directional_land["render"] = {
		"landlook": 0,
		"mode": "outdoor-landlook",
		"tilesetId": "landlook-0",
	}
	var directional_tiles := tiles.duplicate()
	directional_tiles[1] = 156
	directional_land["tiles"] = directional_tiles
	directional_bundle.documents["maps"]["maps"].append({
		"height": 1,
		"id": "dungeon:0",
		"index": 0,
		"levelType": "dungeon",
		"render": {
			"landlook": null,
			"mode": "dungeon-top-down",
			"tilesetId": "dungeon-top-down-302",
		},
		"tiles": [0x0101],
		"width": 1,
	})
	var directional_directory := test_root.path_join("directional-secret")
	DirAccess.make_dir_recursive_absolute(directional_directory)
	var directional_result: Dictionary = MapMaterializerScript.new().materialize(
		directional_bundle,
		directional_directory
	)
	_expect_equal(
		directional_result.get("status"),
		"ok",
		"directional dungeon secret materializes with native movement support"
	)
	var directional_templates: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string(
			directional_directory.path_join(
				"Tilesets/ClassicDungeon/tile_templates.json"
			)
		)
	)
	_expect(
		directional_templates.has("classic_dungeon_0101"),
		"directional dungeon tileset retains the concealed field"
	)
	_expect(
		directional_templates.has("classic_dungeon_0141"),
		"directional dungeon tileset pre-generates its revealed field"
	)
	_expect_equal(
		CampaignPackageInstallerScript.new()._remove_directory(test_root),
		OK,
		"materializer test cleans its workspace"
	)


func _test_classic_boat_materialization() -> void:
	var bundle = BundleScript.new()
	_expect(
		bundle.load_from_directory(PROVIDENCE_AUTHORITATIVE_FIXTURE),
		"producer fixture loads for Classic boat materialization"
	)
	if not bundle.last_error.is_empty():
		return
	var map_record: Dictionary = bundle.documents["maps"]["maps"][0]
	map_record["width"] = 3
	map_record["height"] = 1
	map_record["tiles"] = [147, 60, 1147]
	map_record["render"] = {
		"landlook": 0,
		"mode": "outdoor-landlook",
		"tilesetId": "landlook-0",
	}

	var test_root := ProjectSettings.globalize_path(
		"user://classic-boat-materializer-%d" % Time.get_ticks_msec()
	)
	DirAccess.make_dir_recursive_absolute(test_root)
	var materialize_result: Dictionary = MapMaterializerScript.new().materialize(bundle, test_root)
	_expect_equal(materialize_result.get("status"), "ok", "Classic boats generate native maps")
	var map_directory := test_root.path_join("Maps").path_join("map_0")
	var map_things: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string(map_directory.path_join("map_things.json"))
	)
	_expect_equal(
		map_things.get("layers", [])[0].get("chunks", [])[0].get("data", []),
		[60.0, 60.0, 60.0],
		"boat cells materialize their source-backed underlying water terrain"
	)
	var map_info: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string(map_directory.path_join("map_info.json"))
	)
	_expect_equal(
		map_info.get("classic_boats", {}),
		{"0,0": "ForestDay146", "2,0": "ForestDay146"},
		"generated map metadata preserves Classic boat placements and native art"
	)

	var resources = MapBridgeTestResources.new()
	resources.map_info_book["map_0"] = map_info
	var game_global = MapBridgeTestGameGlobal.new()
	var bridge = MapBridgeScript.new()
	bridge.configure(bundle)
	var seed_result: Dictionary = bridge.seed_classic_boats(game_global, resources)
	_expect_equal(seed_result.get("seededBoats"), 2, "Classic start seeds native boat state")
	_expect_equal(
		game_global.map_boats_dict.get("map_0", {}),
		{"0,0": "ForestDay146", "2,0": "ForestDay146"},
		"Classic boats use Remake's existing map boat dictionary"
	)
	game_global.map_boats_dict["map_0"].erase("0,0")
	bridge.seed_classic_boats(game_global, resources)
	_expect_equal(
		game_global.map_boats_dict.get("map_0", {}),
		{"2,0": "ForestDay146"},
		"saved or moved native boat state is not reseeded"
	)
	_expect_equal(
		CampaignPackageInstallerScript.new()._remove_directory(test_root),
		OK,
		"boat materializer test cleans its workspace"
	)


func _test_classic_item_materializer() -> void:
	var bundle = BundleScript.new()
	_expect(
		bundle.load_from_directory(PROVIDENCE_AUTHORITATIVE_FIXTURE),
		"producer fixture loads for native item materialization"
	)
	if not bundle.last_error.is_empty():
		return
	var test_root := ProjectSettings.globalize_path(
		"user://classic-item-materializer-%d" % Time.get_ticks_msec()
	)
	_expect_equal(
		CampaignPackageInstallerScript.new()._remove_directory(test_root),
		OK,
		"item materializer test clears stale output from an interrupted run"
	)
	DirAccess.make_dir_recursive_absolute(test_root)
	var materializer = ItemMaterializerScript.new()
	var result: Dictionary = materializer.materialize(bundle, test_root)
	_expect_equal(result.get("status"), "ok", "Classic item generates a native item book")
	_expect_equal(result.get("generated"), 2, "materializer reports its generated items")
	var item_book_path := test_root.path_join("Items/stuff_book.json")
	var image_book_path := test_root.path_join("Items/img_pack.json")
	var atlas_path := test_root.path_join("Items/textureAtlas.png")
	_expect(FileAccess.file_exists(item_book_path), "materializer writes the native item book")
	_expect(FileAccess.file_exists(image_book_path), "materializer writes the native image book")
	_expect(FileAccess.file_exists(atlas_path), "materializer writes the native image atlas")
	var first_item_book_text := FileAccess.get_file_as_string(item_book_path)
	var item_book: Dictionary = JSON.parse_string(first_item_book_text)
	var item: Dictionary = item_book.get("Classic Item 901", {})
	_expect_equal(item.get("name"), "Providence Token", "item text supplies the native name")
	_expect_equal(
		item.get("unidentified_name"),
		"Unknown Providence Token",
		"item text supplies the unidentified name"
	)
	_expect_equal(item.get("classicItemId"), 901, "native item preserves its stable Classic ID")
	_expect_equal(
		item.get("classicRecord", {}).get("itemId"),
		901,
		"native item preserves its complete source record"
	)
	_expect_equal(item.get("type"), "Supplies", "scenario item receives a safe native category")
	_expect_equal(item.get("price"), 1, "native item preserves its source price")
	_expect_equal(
		item.get("classicMaterialization", {}).get("status"),
		"complete",
		"fully mapped fixture item is launchable"
	)
	var weapon_record: Dictionary = bundle.documents[
		"content"
	]["scenarioItems"][0].duplicate(true)
	weapon_record["itemId"] = 150
	weapon_record["type"] = 2
	weapon_record["hands"] = 1
	weapon_record["vSmall"] = 6
	weapon_record["vLarge"] = 6
	weapon_record["itemCat0"] = 1 << 28
	weapon_record["heat"] = 4
	weapon_record["cold"] = 3
	weapon_record["electric"] = 2
	weapon_record["damage"] = 2
	weapon_record["st"] = 2
	weapon_record["spellPoints"] = 5
	weapon_record["movement"] = 4
	weapon_record["magicResistance"] = 7
	weapon_record["blunt"] = -1
	weapon_record["vsUndead"] = 4
	weapon_record["vsDemonDevil"] = 3
	weapon_record["vsEvil"] = 2
	weapon_record["specificRace"] = 1
	weapon_record["specificCaste"] = 1
	var weapon: Dictionary = materializer._native_item(weapon_record, [])
	_expect_equal(
		weapon.get("type"),
		"Dagger",
		"Classic melee category selects a concrete native item type"
	)
	var signed_category_record := weapon_record.duplicate(true)
	signed_category_record["itemCat0"] = -2147483648
	_expect_equal(
		materializer._native_item(signed_category_record, []).get("type"),
		"Mace",
		"signed Classic category bits retain their source ordering"
	)
	var armor_record: Dictionary = bundle.documents[
		"content"
	]["scenarioItems"][0].duplicate(true)
	armor_record["itemId"] = 250
	armor_record["type"] = 4
	armor_record["itemCat1"] = 1 << 28
	var armor: Dictionary = materializer._native_item(armor_record, [])
	_expect_equal(
		armor.get("type"),
		"Leather Armor",
		"Classic armor category selects a concrete native item type"
	)
	_expect_equal(armor.get("slots"), ["Body"], "Classic armor retains its native slot")
	_expect_equal(
		armor.get("classicMaterialization", {}).get("unsupportedFields"),
		[],
		"basic categorized Classic armor remains launchable"
	)
	var resistance_only_record := armor_record.duplicate(true)
	resistance_only_record["magicResistance"] = 7
	var resistance_only_item: Dictionary = materializer._native_item(
		resistance_only_record, []
	)
	_expect_equal(
		resistance_only_item.get("stats_mini"),
		"+7% Classic Magic Resistance",
		"resistance-only equipment exposes its compatibility effect"
	)
	var shield_record := armor_record.duplicate(true)
	shield_record["itemId"] = 251
	shield_record["type"] = 3
	shield_record["hands"] = 1
	shield_record["itemCat0"] = 1 << 6
	shield_record["itemCat1"] = 0
	shield_record["ac"] = 6
	var shield: Dictionary = materializer._native_item(shield_record, [])
	_expect_equal(
		shield.get("type"),
		"Small Shield",
		"Classic shield category selects a concrete native item type"
	)
	_expect_equal(shield.get("slots"), ["Shield"], "Classic shield retains its native slot")
	_expect_equal(
		shield.get("stats", {}).get("EvasionMelee"),
		6,
		"positive Classic armor maps to native melee evasion"
	)
	_expect_equal(
		shield.get("stats", {}).get("EvasionRanged"),
		6,
		"positive Classic armor maps to native ranged evasion"
	)
	_expect_equal(
		shield.get("extra_data", {}).get("classicArmorRating"),
		6,
		"native equipment retains the source Classic armor rating"
	)
	_expect_equal(
		shield.get("classicMaterialization", {}).get("status"),
		"fallback",
		"Classic armor remains launchable through Remake's native evasion scale"
	)
	_expect(
		shield.get("classicMaterialization", {}).get(
			"fidelityFallbacks", []
		).has("armorRatingUsesNativeEvasionScale"),
		"Classic armor records the native evasion-scale fallback"
	)
	_expect_equal(
		weapon.get("weapon_dmg", {}).get("Physical"),
		[1, 6],
		"matching Classic weapon dice map to native physical damage"
	)
	_expect_equal(
		weapon.get("weapon_dmg", {}).get("Fire"),
		[1, 4],
		"Classic weapon heat maps to native fire damage"
	)
	_expect_equal(
		weapon.get("weapon_dmg", {}).get("Ice"),
		[1, 3],
		"Classic weapon cold maps to native ice damage"
	)
	_expect_equal(
		weapon.get("weapon_dmg", {}).get("Electric"),
		[1, 2],
		"Classic weapon electricity uses the native combat damage key"
	)
	_expect_equal(
		weapon.get("extra_data", {}).get("classicWeaponDamage"),
		{"small": 6, "large": 6},
		"native weapon retains both Classic damage ranges"
	)
	_expect_equal(
		weapon.get("extra_data", {}).get("classicWeaponKind"),
		"blunt",
		"native weapon retains its Classic blunt classification"
	)
	_expect_equal(
		weapon.get("extra_data", {}).get("classicMagicPlus"),
		2,
		"native weapon retains its Classic magic-plus requirement value"
	)
	_expect_equal(
		weapon.get("weapon_tag_bonus_dmg", {}),
		{
			"Undead": {"Physical": [1, 4]},
			"Demonic": {"Physical": [1, 3]},
			"Evil Creature": {"Physical": [1, 2]},
		},
		"Classic target bonuses map to native tagged damage ranges"
	)
	_expect_equal(
		weapon.get("only_usable_by_races"),
		["Human"],
		"Classic specific-race equipment uses native race permissions"
	)
	_expect_equal(
		weapon.get("only_usable_by_classes"),
		["Fighter"],
		"Classic specific-caste equipment uses native class permissions"
	)
	_expect_equal(
		weapon.get("stats", {}).get("AccuracyMelee"),
		2,
		"positive Classic weapon magic-plus maps to native melee accuracy"
	)
	_expect_equal(
		weapon.get("stats", {}).get("Bonus_Physical_dmg"),
		2,
		"positive Classic weapon magic-plus maps to native physical damage"
	)
	_expect_equal(
		weapon.get("stats", {}).get("Strength"),
		2,
		"positive Classic strength maps to the native equipment stat"
	)
	_expect_equal(
		weapon.get("extra_data", {}).get("classicStrengthModifier"),
		2,
		"native equipment retains the source Classic strength modifier"
	)
	_expect_equal(
		weapon.get("stats", {}).get("maxSP"),
		5,
		"positive Classic spell points map to the native maximum"
	)
	_expect_equal(
		weapon.get("stats", {}).get("curSP"),
		5,
		"positive Classic spell points map to the native current pool"
	)
	_expect_equal(
		weapon.get("extra_data", {}).get("classicSpellPointModifier"),
		5,
		"native equipment retains the source Classic spell-point modifier"
	)
	_expect_equal(
		weapon.get("stats", {}).get("MaxMovement"),
		4,
		"positive Classic movement maps to the native equipment stat"
	)
	_expect_equal(
		weapon.get("extra_data", {}).get("classicMovementModifier"),
		4,
		"native equipment retains the source Classic movement modifier"
	)
	_expect_equal(
		weapon.get("classicMagicResistance"),
		7,
		"Classic magic resistance maps to compatibility-owned item metadata"
	)
	_expect(
		not weapon.get("stats", {}).has("EvasionMagic"),
		"Classic magic resistance does not become native magic evasion"
	)
	_expect(
		weapon.get("classicMaterialization", {}).get(
			"fidelityFallbacks", []
		).has("movementUsesNativeEncumbranceScale"),
		"Classic movement records the native encumbrance-order fallback"
	)
	var defensive_weapon_record := weapon_record.duplicate(true)
	defensive_weapon_record["ac"] = 3
	var defensive_weapon: Dictionary = materializer._native_item(defensive_weapon_record, [])
	_expect_equal(
		defensive_weapon.get("stats", {}).get("AccuracyMelee"),
		2,
		"Classic armor on a weapon preserves its magic-plus stats"
	)
	_expect_equal(
		defensive_weapon.get("stats", {}).get("EvasionMelee"),
		3,
		"Classic armor on a weapon adds native evasion"
	)
	_expect_equal(
		defensive_weapon.get("extra_data", {}).get("classicWeaponDamage"),
		{"small": 6, "large": 6},
		"Classic armor on a weapon preserves its damage metadata"
	)
	_expect_equal(
		weapon.get("classicMaterialization", {}).get("unsupportedFields"),
		[],
		"matching small and large damage ranges remain launchable"
	)
	_expect_equal(
		weapon.get("classicMaterialization", {}).get("status"),
		"fallback",
		"elemental Classic weapon damage remains launchable through native mitigation"
	)
	_expect(
		weapon.get("classicMaterialization", {}).get(
			"fidelityFallbacks", []
		).has("elementalWeaponDamageMitigation"),
		"elemental weapon mitigation records the Classic save and protection fallback"
	)
	var size_split_record := weapon_record.duplicate(true)
	size_split_record["vLarge"] = 8
	_expect(
		materializer._native_item(size_split_record, []).get(
			"classicMaterialization", {}
		).get("unsupportedFields", []).has("vLarge"),
		"size-dependent Classic weapon damage remains an explicit blocker"
	)
	var categoryless_record := weapon_record.duplicate(true)
	categoryless_record["itemCat0"] = 0
	_expect(
		materializer._native_item(categoryless_record, []).get(
			"classicMaterialization", {}
		).get("unsupportedFields", []).has("itemCategory.missing"),
		"categoryless Classic equipment remains an explicit blocker"
	)
	var unsupported_category_record := weapon_record.duplicate(true)
	unsupported_category_record["itemCat0"] = 0
	unsupported_category_record["itemCat1"] = 1 << 16
	_expect(
		materializer._native_item(unsupported_category_record, []).get(
			"classicMaterialization", {}
		).get("unsupportedFields", []).has("itemCategory[47]"),
		"Classic categories without native equip permissions remain blockers"
	)
	var negative_element_record := weapon_record.duplicate(true)
	negative_element_record["heat"] = -1
	_expect(
		materializer._native_item(negative_element_record, []).get(
			"classicMaterialization", {}
		).get("unsupportedFields", []).has("heat"),
		"negative Classic elemental damage remains an explicit blocker"
	)
	var negative_magic_plus_record := weapon_record.duplicate(true)
	negative_magic_plus_record["damage"] = -1
	_expect(
		materializer._native_item(negative_magic_plus_record, []).get(
			"classicMaterialization", {}
		).get("unsupportedFields", []).has("damage"),
		"negative Classic weapon magic-plus remains an explicit blocker"
	)
	var negative_strength_record := weapon_record.duplicate(true)
	negative_strength_record["st"] = -2
	var negative_strength_item: Dictionary = materializer._native_item(
		negative_strength_record, []
	)
	_expect_equal(
		negative_strength_item.get("stats", {}).get("Strength"),
		-2,
		"negative Classic strength remains a signed native equipment stat"
	)
	_expect(
		not negative_strength_item.get("classicMaterialization", {}).get(
			"unsupportedFields", []
		).has("st"),
		"signed Classic strength remains launchable on equipment"
	)
	var negative_spell_point_record := weapon_record.duplicate(true)
	negative_spell_point_record["spellPoints"] = -5
	var negative_spell_point_item: Dictionary = materializer._native_item(
		negative_spell_point_record, []
	)
	_expect_equal(
		negative_spell_point_item.get("stats", {}).get("maxSP"),
		-5,
		"negative Classic spell points remain a signed maximum modifier"
	)
	_expect_equal(
		negative_spell_point_item.get("stats", {}).get("curSP"),
		-5,
		"negative Classic spell points remain a signed current modifier"
	)
	_expect(
		not negative_spell_point_item.get("classicMaterialization", {}).get(
			"unsupportedFields", []
		).has("spellPoints"),
		"signed Classic spell points remain launchable on equipment"
	)
	var negative_movement_record := weapon_record.duplicate(true)
	negative_movement_record["movement"] = -4
	var negative_movement_item: Dictionary = materializer._native_item(
		negative_movement_record, []
	)
	_expect_equal(
		negative_movement_item.get("stats", {}).get("MaxMovement"),
		-4,
		"negative Classic movement remains a signed native equipment stat"
	)
	_expect(
		not negative_movement_item.get("classicMaterialization", {}).get(
			"unsupportedFields", []
		).has("movement"),
		"signed Classic movement remains launchable on equipment"
	)
	var negative_magic_resistance_record := weapon_record.duplicate(true)
	negative_magic_resistance_record["magicResistance"] = -9
	var negative_magic_resistance_item: Dictionary = materializer._native_item(
		negative_magic_resistance_record, []
	)
	_expect_equal(
		negative_magic_resistance_item.get("classicMagicResistance"),
		-9,
		"negative Classic magic resistance remains a signed equipment modifier"
	)
	_expect(
		not negative_magic_resistance_item.get("classicMaterialization", {}).get(
			"unsupportedFields", []
		).has("magicResistance"),
		"signed Classic magic resistance remains launchable on equipment"
	)
	var grouped_restriction_record := weapon_record.duplicate(true)
	grouped_restriction_record["specificRace"] = 0
	grouped_restriction_record["specificCaste"] = 0
	grouped_restriction_record["raceClassOnly"] = 1 << 7
	grouped_restriction_record["casteClassOnly"] = 1 << 15
	var grouped_restriction_item: Dictionary = materializer._native_item(
		grouped_restriction_record, []
	)
	_expect_equal(
		grouped_restriction_item.get("only_usable_by_races"),
		["Shadow Elf", "Orc", "Goblin", "Hobgoblin", "Kobold", "Vampire", "Demon"],
		"Classic race-descriptor requirements map to matching native races"
	)
	_expect_equal(
		grouped_restriction_item.get("only_usable_by_classes"),
		["Fighter", "Berzerker", "Fencer"],
		"Classic caste-class requirements map to matching native classes"
	)
	_expect_equal(
		grouped_restriction_item.get("classicMaterialization", {}).get(
			"unsupportedFields", []
		),
		[],
		"standard Classic restriction groups remain launchable"
	)
	var excluded_group_record := grouped_restriction_record.duplicate(true)
	excluded_group_record["raceClassOnly"] = 0
	excluded_group_record["casteClassOnly"] = 0
	excluded_group_record["raceRestrictions"] = 1 << 7
	excluded_group_record["casteRestrictions"] = 1 << 15
	var excluded_group_item: Dictionary = materializer._native_item(
		excluded_group_record, []
	)
	_expect(
		not excluded_group_item.get("only_usable_by_races", []).has("Orc")
			and excluded_group_item.get("only_usable_by_races", []).has("Human"),
		"Classic race exclusions remove matching native races"
	)
	_expect(
		not excluded_group_item.get("only_usable_by_classes", []).has("Fighter")
			and excluded_group_item.get("only_usable_by_classes", []).has("Priest"),
		"Classic caste exclusions remove matching native classes"
	)
	var negative_armor_record := shield_record.duplicate(true)
	negative_armor_record["ac"] = -1
	_expect(
		materializer._native_item(negative_armor_record, []).get(
			"classicMaterialization", {}
		).get("unsupportedFields", []).has("ac"),
		"negative Classic armor remains an explicit blocker"
	)
	var non_weapon_element_record := weapon_record.duplicate(true)
	non_weapon_element_record["type"] = 25
	_expect(
		materializer._native_item(non_weapon_element_record, []).get(
			"classicMaterialization", {}
		).get("unsupportedFields", []).has("heat"),
		"elemental damage on a non-melee item remains an explicit blocker"
	)
	_expect(
		materializer._native_item(non_weapon_element_record, []).get(
			"classicMaterialization", {}
		).get("unsupportedFields", []).has("damage"),
		"magic-plus on a non-melee item remains an explicit blocker"
	)
	var non_equipment_armor_record: Dictionary = bundle.documents[
		"content"
	]["scenarioItems"][0].duplicate(true)
	non_equipment_armor_record["ac"] = 6
	_expect(
		materializer._native_item(non_equipment_armor_record, []).get(
			"classicMaterialization", {}
		).get("unsupportedFields", []).has("ac"),
		"armor on a non-equippable Classic item remains an explicit blocker"
	)
	var non_equipment_strength_record := non_equipment_armor_record.duplicate(true)
	non_equipment_strength_record["ac"] = 0
	non_equipment_strength_record["st"] = 2
	_expect(
		materializer._native_item(non_equipment_strength_record, []).get(
			"classicMaterialization", {}
		).get("unsupportedFields", []).has("st"),
		"strength on a non-equippable Classic item remains an explicit blocker"
	)
	var non_equipment_spell_point_record := non_equipment_armor_record.duplicate(true)
	non_equipment_spell_point_record["ac"] = 0
	non_equipment_spell_point_record["spellPoints"] = 5
	_expect(
		materializer._native_item(non_equipment_spell_point_record, []).get(
			"classicMaterialization", {}
		).get("unsupportedFields", []).has("spellPoints"),
		"spell points on a non-equippable Classic item remain an explicit blocker"
	)
	var non_equipment_movement_record := non_equipment_armor_record.duplicate(true)
	non_equipment_movement_record["ac"] = 0
	non_equipment_movement_record["movement"] = 4
	_expect(
		materializer._native_item(non_equipment_movement_record, []).get(
			"classicMaterialization", {}
		).get("unsupportedFields", []).has("movement"),
		"movement on a non-equippable Classic item remains an explicit blocker"
	)
	var non_equipment_magic_resistance_record := non_equipment_armor_record.duplicate(true)
	non_equipment_magic_resistance_record["ac"] = 0
	non_equipment_magic_resistance_record["magicResistance"] = 5
	_expect(
		materializer._native_item(non_equipment_magic_resistance_record, []).get(
			"classicMaterialization", {}
		).get("unsupportedFields", []).has("magicResistance"),
		"magic resistance on a non-equippable Classic item remains a blocker"
	)
	var non_equipment_restriction_record := non_equipment_armor_record.duplicate(true)
	non_equipment_restriction_record["ac"] = 0
	non_equipment_restriction_record["specificRace"] = 1
	_expect(
		materializer._native_item(non_equipment_restriction_record, []).get(
			"classicMaterialization", {}
		).get("unsupportedFields", []).has("specificRace"),
		"non-equipment restrictions remain blocked until native item use enforces them"
	)
	var unsupported_blunt_record := weapon_record.duplicate(true)
	unsupported_blunt_record["blunt"] = 1
	_expect(
		materializer._native_item(unsupported_blunt_record, []).get(
			"classicMaterialization", {}
		).get("unsupportedFields", []).has("blunt"),
		"unknown Classic weapon classifications remain explicit blockers"
	)
	var negative_target_bonus_record := weapon_record.duplicate(true)
	negative_target_bonus_record["vsUndead"] = -1
	_expect(
		materializer._native_item(negative_target_bonus_record, []).get(
			"classicMaterialization", {}
		).get("unsupportedFields", []).has("vsUndead"),
		"negative Classic target bonuses remain explicit blockers"
	)
	var luck_record := armor_record.duplicate(true)
	luck_record["lu"] = 2
	_expect(
		materializer._native_item(luck_record, []).get(
			"classicMaterialization", {}
		).get("unsupportedFields", []).has("lu"),
		"Classic luck remains blocked without a working native stat or trait"
	)
	var readiness: Dictionary = ReadinessScript.new().inspect(bundle, {"items": item_book})
	_expect(
		not _readiness_has_reference_diagnostic(
			readiness, "missing-native-item", 901
		),
		"generated native item satisfies Classic item readiness"
	)

	var second_result: Dictionary = materializer.materialize(bundle, test_root)
	_expect_equal(second_result.get("generated"), 0, "item materialization is idempotent")
	_expect_equal(second_result.get("skipped"), 2, "rerun recognizes the existing Classic IDs")
	_expect_equal(
		FileAccess.get_file_as_string(item_book_path),
		first_item_book_text,
		"item materialization is byte-stable on rerun"
	)

	var unsupported_root := test_root.path_join("unsupported")
	DirAccess.make_dir_recursive_absolute(unsupported_root)
	var unsupported_bundle = BundleScript.new()
	unsupported_bundle.load_from_directory(PROVIDENCE_AUTHORITATIVE_FIXTURE)
	unsupported_bundle.documents["content"]["scenarioItems"][0]["damage"] = 1
	_expect_equal(
		materializer.materialize(unsupported_bundle, unsupported_root).get("status"),
		"ok",
		"unsupported item fields remain inspectable in the native book"
	)
	var unsupported_book: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string(unsupported_root.path_join("Items/stuff_book.json"))
	)
	var unsupported_readiness: Dictionary = ReadinessScript.new().inspect(
		unsupported_bundle,
		{"items": unsupported_book}
	)
	_expect(
		_readiness_has_reference_diagnostic(
			unsupported_readiness, "unsupported-native-item-fields", 901
		),
		"unsupported item behavior blocks launch with its stable identity"
	)
	_expect_equal(
		CampaignPackageInstallerScript.new()._remove_directory(test_root),
		OK,
		"item materializer test cleans its workspace"
	)


func _test_classic_bestiary_materializer() -> void:
	var bundle = BundleScript.new()
	_expect(
		bundle.load_from_directory(PROVIDENCE_AUTHORITATIVE_FIXTURE),
		"producer fixture loads for native bestiary materialization"
	)
	if not bundle.last_error.is_empty():
		return
	_clear_producer_monster_equipment(bundle)
	var test_root := ProjectSettings.globalize_path(
		"user://classic-bestiary-materializer-%d" % Time.get_ticks_msec()
	)
	_expect_equal(
		CampaignPackageInstallerScript.new()._remove_directory(test_root),
		OK,
		"bestiary materializer test clears stale output from an interrupted run"
	)
	DirAccess.make_dir_recursive_absolute(test_root)
	var materializer = BestiaryMaterializerScript.new()
	var result: Dictionary = materializer.materialize(bundle, test_root)
	_expect_equal(result.get("status"), "ok", "Classic monster generates a native bestiary")
	_expect_equal(result.get("generated"), 1, "materializer reports its generated monster")
	var book_path := test_root.path_join("Bestiary/stuff_book.json")
	var image_book_path := test_root.path_join("Bestiary/img_pack.json")
	var atlas_path := test_root.path_join("Bestiary/textureAtlas.png")
	_expect(FileAccess.file_exists(book_path), "materializer writes the native bestiary book")
	_expect(FileAccess.file_exists(image_book_path), "materializer writes the bestiary image book")
	_expect(FileAccess.file_exists(atlas_path), "materializer writes the bestiary image atlas")
	var first_book_text := FileAccess.get_file_as_string(book_path)
	var bestiary_book: Dictionary = JSON.parse_string(first_book_text)
	var monster: Dictionary = bestiary_book.get("Classic Monster 1", {})
	_expect_equal(
		monster.get("data", {}).get("name"),
		"Providence Sentinel",
		"compiled monster name reaches its native resource"
	)
	_expect_equal(
		monster.get("data", {}).get("description"),
		"Compiled entirely from canonical Providence monster data.",
		"compiled monster description reaches its native resource"
	)
	_expect_equal(monster.get("classicMonsterId"), 1, "native monster preserves its stable ID")
	_expect_equal(
		monster.get("classicMonsterNameId"),
		1,
		"native monster preserves its stable name identity"
	)
	_expect_equal(
		monster.get("classicRecord", {}).get("agility"),
		201,
		"native monster preserves the complete compiler record"
	)
	_expect_equal(
		monster.get("classicMaterialization", {}).get("status"),
		"fallback",
		"simple physical monster remains launchable with explicit visual and roll fallbacks"
	)
	_expect_equal(
		monster.get("classicMaterialization", {}).get("unsupportedFields"),
		[],
		"simple physical fixture has no unsupported behavior"
	)
	_expect_equal(monster.get("data", {}).get("size"), [1.0, 2.0], "Classic tall size maps natively")
	_expect_equal(monster.get("stats", {}).get("MaxMovement"), 202, "movement maps natively")
	_expect_equal(monster.get("stats", {}).get("Dexterity"), 201, "agility maps natively")
	_expect_equal(monster.get("stats", {}).get("EvasionMelee"), -4, "armor maps natively")
	_expect_equal(monster.get("stats", {}).get("maxHP"), 241, "average Classic stamina is deterministic")
	_expect_equal(monster.get("stats", {}).get("AccuracyMelee"), 9, "Classic melee accuracy maps natively")
	_expect_equal(monster.get("data", {}).get("exp"), 7709, "Classic average battle reward maps natively")
	var resistance_record: Dictionary = bundle.get_monster(1).duplicate(true)
	resistance_record["magicResistance"] = 37
	var resistance_stats: Dictionary = materializer._native_stats(resistance_record, 100)
	_expect_equal(
		resistance_stats.get("EvasionMagic"),
		0,
		"Classic monster magic resistance stays distinct from native evasion"
	)
	_expect_equal(
		resistance_stats.get("MultiplierMagic"),
		1.0,
		"Classic monster magic resistance stays distinct from damage scaling"
	)
	var split_save_record: Dictionary = bundle.get_monster(1).duplicate(true)
	split_save_record["saves"] = [-25, -25, 100, 100, 100, 15]
	split_save_record["spellImmunities"] = [1, 0, 0, 1, 1, 0]
	var split_save_monster: Dictionary = materializer._native_monster(
		split_save_record,
		[],
		{},
		[],
		{},
		{},
		{}
	)
	_expect_equal(
		split_save_monster.get("classicSpellSaves"),
		[-25, -25, 100, 100, 100, 15],
		"native monster metadata preserves separate Charm and Mental saves"
	)
	_expect_equal(
		split_save_monster.get("classicSpellImmunities"),
		[1, 0, 0, 1, 1, 0],
		"native monster metadata preserves separate family immunities"
	)
	_expect(
		not split_save_monster.get("classicMaterialization", {}).get(
			"unsupportedFields", []
		).has("saves.charmMentalSplit"),
		"distinct Charm and Mental saves no longer block native materialization"
	)
	_expect(
		not split_save_monster.get("classicMaterialization", {}).get(
			"unsupportedFields", []
		).has("spellImmunities.charmMentalSplit"),
		"distinct Charm and Mental immunities no longer block native materialization"
	)
	_expect_equal(
		monster.get("tools", {}).get("unarmed_melee_attacks", [])[0].get(
			"weapon_dmg", {}
		).get("Physical"),
		[1.0, 8.0],
		"ordinary Classic attack range maps natively"
	)
	_expect_equal(
		monster.get("data", {}).get("tags", []).size(),
		8,
		"all eight Classic type flags retain native tags"
	)
	var screen_record: Dictionary = bundle.get_monster(1).duplicate(true)
	var screen_conditions: Array = screen_record.get("conditions", []).duplicate()
	screen_conditions[16] = -1
	screen_record["conditions"] = screen_conditions
	var screened_monster: Dictionary = materializer._native_monster(
		screen_record,
		[],
		{},
		[],
		{},
		{},
		{}
	)
	_expect_equal(
		screened_monster.get("classicSpellScreenLevel"),
		1,
		"permanent first-level spell protection reaches native monster metadata"
	)
	_expect(
		not screened_monster.get("classicMaterialization", {}).get(
			"unsupportedFields", []
		).has("conditions"),
		"permanent Classic spell protection no longer blocks native materialization"
	)
	var regenerating_record: Dictionary = bundle.get_monster(1).duplicate(true)
	var regeneration_conditions: Array = regenerating_record.get(
		"conditions", []
	).duplicate()
	regeneration_conditions[10] = -2
	regenerating_record["conditions"] = regeneration_conditions
	var regenerating_monster: Dictionary = materializer._native_monster(
		regenerating_record,
		[],
		{},
		[],
		{},
		{},
		{}
	)
	_expect_equal(
		regenerating_monster.get("classicRegenerationPerRound"),
		2,
		"permanent Classic regeneration reaches native monster metadata"
	)
	_expect(
		not regenerating_monster.get("classicMaterialization", {}).get(
			"unsupportedFields", []
		).has("conditions"),
		"permanent Classic regeneration no longer blocks native materialization"
	)
	var temporary_regeneration_record: Dictionary = regenerating_record.duplicate(true)
	temporary_regeneration_record["conditions"][10] = 2
	_expect(
		materializer._unsupported_fields(
			temporary_regeneration_record,
			{},
			{},
			{},
			{}
		).has("conditions"),
		"temporary starting regeneration remains blocked until its counter is modeled"
	)
	var temporary_screen_record: Dictionary = screen_record.duplicate(true)
	temporary_screen_record["conditions"][16] = 2
	var temporary_screen_monster: Dictionary = materializer._native_monster(
		temporary_screen_record,
		[],
		{},
		[],
		{},
		{},
		{}
	)
	_expect(
		not temporary_screen_monster.get("classicMaterialization", {}).get(
			"unsupportedFields", []
		).has("conditions"),
		"temporary starting spell screens no longer block native materialization"
	)
	_expect_equal(
		temporary_screen_monster.get("traits", []),
		[["t_classic_spell_screen.gd", [[2, 0, 0, 0, 0]]]],
		"temporary starting screen levels reach the layered native trait"
	)
	var unrelated_condition_record: Dictionary = screen_record.duplicate(true)
	unrelated_condition_record["conditions"][16] = 0
	unrelated_condition_record["conditions"][9] = -1
	_expect(
		materializer._unsupported_fields(
			unrelated_condition_record,
			{},
			{},
			{},
			{}
		).has("conditions"),
		"unmapped permanent monster conditions remain launch blockers"
	)

	var merged_book := {
		"Older conversion": {"data": {"id": 1, "name": "Providence Sentinel"}},
	}
	merged_book.merge(bestiary_book, true)
	_expect_equal(
		GodotAdapterScript.new().resolve_classic_monster_bestiary_name(
			1,
			bundle.get_monster(1),
			merged_book
		),
		"Classic Monster 1",
		"explicit producer identity wins over a hand-converted numeric ID"
	)
	var battle_result: Dictionary = GodotAdapterScript.new().materialize_classic_battle(
		bundle.get_battle(0),
		bundle.monsters_by_id,
		bestiary_book
	)
	_expect_equal(
		battle_result.get("battle", {}).get("Creatures", [])[0][0],
		"Classic Monster 1",
		"compiled battle consumes the generated native bestiary entry"
	)
	var readiness: Dictionary = ReadinessScript.new().inspect(
		bundle,
		{"bestiary": bestiary_book}
	)
	_expect(bool(readiness.get("ready", false)), "simple physical native monster remains launchable")
	_expect(
		_readiness_has_reference_diagnostic(
			readiness, "native-monster-fidelity-fallback", 1
		),
		"readiness reports the generated monster's bounded fidelity fallbacks"
	)

	var second_result: Dictionary = materializer.materialize(bundle, test_root)
	_expect_equal(second_result.get("generated"), 0, "bestiary materialization is idempotent")
	_expect_equal(second_result.get("skipped"), 1, "rerun recognizes the existing monster ID")
	_expect_equal(
		FileAccess.get_file_as_string(book_path),
		first_book_text,
		"bestiary materialization is byte-stable on rerun"
	)

	var inventory_root := test_root.path_join("inventory")
	DirAccess.make_dir_recursive_absolute(inventory_root)
	var inventory_bundle = BundleScript.new()
	inventory_bundle.load_from_directory(PROVIDENCE_AUTHORITATIVE_FIXTURE)
	inventory_bundle.documents["content"]["monsters"][0]["items"] = [1, 901, 0, 0, 0, 0]
	inventory_bundle.documents["content"]["monsters"][0]["weapon"] = 1
	_expect_equal(
		ItemMaterializerScript.new().materialize(inventory_bundle, inventory_root).get(
			"status"
		),
		"ok",
		"monster inventory test materializes its scenario-local item first"
	)
	_expect_equal(
		materializer.materialize(inventory_bundle, inventory_root).get("status"),
		"ok",
		"Classic carried items generate native monster inventory"
	)
	var inventory_book: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string(inventory_root.path_join("Bestiary/stuff_book.json"))
	)
	var inventory_monster: Dictionary = inventory_book.get("Classic Monster 1", {})
	_expect_equal(
		inventory_monster.get("tools", {}).get("inventory"),
		[["Dagger", 1.0], ["Classic Item 901", 0.0]],
		"monster inventory prefers stable campaign identity and equips its active weapon"
	)
	_expect_equal(
		inventory_monster.get("classicWeaponItemId"),
		1,
		"native monster retains the source weapon identity"
	)
	_expect_equal(
		inventory_monster.get("classicMaterialization", {}).get("unsupportedFields"),
		[],
		"resolved carried and equipped items do not block launch"
	)
	var inventory_readiness: Dictionary = ReadinessScript.new().inspect(
		inventory_bundle,
		{"bestiary": inventory_book}
	)
	_expect(
		bool(inventory_readiness.get("ready", false)),
		"resolved native monster inventory remains launchable"
	)
	var separate_weapon_record: Dictionary = inventory_bundle.get_monster(1).duplicate(true)
	separate_weapon_record["items"] = [99, 0, 0, 0, 0, 0]
	separate_weapon_record["weapon"] = 98
	var separate_weapon_inventory: Dictionary = materializer._native_inventory(
		separate_weapon_record,
		{
			"Quarter Staff": {"equippable": 1},
			"Quarter Staff +1": {"equippable": 1},
		},
		[],
		{
			98: "Quarter Staff",
			99: "Quarter Staff +1",
		}
	)
	_expect_equal(
		separate_weapon_inventory.get("entries"),
		[["Quarter Staff +1", 0], ["Quarter Staff", 1, false]],
		"active Classic weapon remains separate from the six carried loot slots"
	)
	_expect_equal(
		separate_weapon_inventory.get("unsupportedFields"),
		[],
		"resolved positive weapon outside the carried slots remains launchable"
	)
	_expect(
		separate_weapon_inventory.get("fidelityFallbacks", []).has(
			"separateActiveWeaponInventoryEntry"
		),
		"native inventory adaptation for a separate active weapon remains explicit"
	)
	var armed_attack_record: Dictionary = inventory_bundle.get_monster(1).duplicate(true)
	armed_attack_record["attacks"][0][3] = 11
	_expect(
		materializer._native_attacks(armed_attack_record).get(
			"unsupportedFields", []
		).has("attacks[0].specialWithWeapon"),
		"elemental specials with equipped weapons remain explicit blockers"
	)

	var spell_root := test_root.path_join("spells")
	DirAccess.make_dir_recursive_absolute(spell_root)
	var spell_bundle = BundleScript.new()
	spell_bundle.load_from_directory(PROVIDENCE_AUTHORITATIVE_FIXTURE)
	_clear_producer_monster_equipment(spell_bundle)
	spell_bundle.documents["content"]["monsters"][0]["spells"] = [
		1306, 1306, 0, 0, 0, 0, 0, 0, 0, 0
	]
	spell_bundle.documents["content"]["monsters"][0]["magicAttackCount"] = 2
	spell_bundle.documents["content"]["monsters"][0]["castPercent"] = 75
	_expect_equal(
		materializer.materialize(spell_bundle, spell_root).get("status"),
		"ok",
		"Classic spell slots generate native monster spells"
	)
	var spell_book: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string(spell_root.path_join("Bestiary/stuff_book.json"))
	)
	var spell_monster: Dictionary = spell_book.get("Classic Monster 1", {})
	_expect_equal(
		spell_monster.get("tools", {}).get("spells"),
		[["Fireball", 1.0], ["Fireball", 1.0]],
		"repeated Classic spell slots preserve their random weighting"
	)
	_expect_equal(
		spell_monster.get("classicSpellIds"),
		[1306.0, 1306.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
		"native monster retains the packed spell identities"
	)
	_expect_equal(
		spell_monster.get("classicMaterialization", {}).get("unsupportedFields"),
		[],
		"exact native spell identities do not block launch"
	)
	_expect(
		bool(ReadinessScript.new().inspect(
			spell_bundle,
			{"bestiary": spell_book}
		).get("ready", false)),
		"resolved native monster spells remain launchable"
	)
	var exact_spell_book: Dictionary = {}
	SpellResourceCatalogScript.merge_directory(
		"res://shared_assets/spells",
		exact_spell_book
	)
	var spell_ids := SpellIdsScript.new()
	var exact_spell_result: Dictionary = materializer._native_spells(
		{"spells": [1102, 2102]},
		exact_spell_book,
		spell_ids.mappings
	)
	spell_ids.free()
	_expect_equal(
		exact_spell_result.get("entries"),
		[["Enchanted Blade", 1], ["Classic Discover Magic Area", 1]],
		"native monsters select mechanics-specific Classic spell resources"
	)
	_expect_equal(
		exact_spell_result.get("fidelityFallbacks"),
		[],
		"exact-ID Classic monster spells do not use name-only fallbacks"
	)

	var requirement_record: Dictionary = bundle.get_monster(1).duplicate(true)
	requirement_record["distance"] = 1
	requirement_record["magicToHit"] = 2
	var requirement_result: Dictionary = materializer._native_weapon_requirements(
		requirement_record,
		{"Dagger": {}},
		[],
		{1: "Dagger"}
	)
	_expect_equal(
		requirement_result.get("fields"),
		{
			"classicRequiredWeaponItemId": 1,
			"classicRequiredWeaponName": "Dagger",
			"classicRequiredMagicPlus": 2,
		},
		"Classic exact-weapon and magic-plus gates resolve to native metadata"
	)
	_expect_equal(
		requirement_result.get("unsupportedFields"),
		[],
		"resolved Classic weapon gates remain launchable"
	)
	var exact_defender := {
		"classic_required_weapon_item_id": 1,
		"classic_required_weapon_name": "Dagger",
		"classic_required_magic_plus": 2,
	}
	var qualifying_weapon := {
		"name": "Dagger",
		"extra_data": {"classicMagicPlus": 2},
	}
	_expect(
		MonsterWeaponRulesScript.can_hit({}, exact_defender, qualifying_weapon),
		"matching native weapon and magic plus satisfy the Classic gate"
	)
	var weak_weapon: Dictionary = qualifying_weapon.duplicate(true)
	weak_weapon["extra_data"]["classicMagicPlus"] = 1
	_expect(
		not MonsterWeaponRulesScript.can_hit({}, exact_defender, weak_weapon),
		"insufficient weapon magic plus fails the Classic gate"
	)
	var wrong_weapon: Dictionary = qualifying_weapon.duplicate(true)
	wrong_weapon["name"] = "Mace"
	_expect(
		not MonsterWeaponRulesScript.can_hit({}, exact_defender, wrong_weapon),
		"wrong native weapon identity fails the Classic gate"
	)
	var blunt_result: Dictionary = materializer._native_weapon_requirements(
		{"distance": -1},
		{},
		[],
		{}
	)
	_expect_equal(
		blunt_result.get("fields", {}).get("classicRequiredWeaponKind"),
		"blunt",
		"Classic blunt-only defenses retain their weapon classification"
	)
	_expect(
		MonsterWeaponRulesScript.can_hit(
			{},
			{"classic_required_weapon_kind": "blunt"},
			{"extra_data": {"classicWeaponKind": "blunt"}}
		),
		"matching Classic weapon classification satisfies the native gate"
	)
	_expect(
		not MonsterWeaponRulesScript.can_hit(
			{},
			{"classic_required_weapon_kind": "blunt"},
			{"extra_data": {"classicWeaponKind": "sharp"}}
		),
		"wrong Classic weapon classification fails the native gate"
	)
	_expect(
		MonsterWeaponRulesScript.can_hit(
			{"level": 16},
			{"classic_required_magic_plus": 2},
			{"name": "NO_MELEE_WEAPON", "type": "Unarmed"}
		),
		"Classic unarmed gate uses the attacker's level threshold"
	)
	var invalid_requirement: Dictionary = materializer._native_weapon_requirements(
		{"distance": -3, "magicToHit": -1},
		{},
		[],
		{}
	)
	_expect_equal(
		invalid_requirement.get("unsupportedFields"),
		["distance", "magicToHit"],
		"unknown weapon gates remain explicit launch blockers"
	)
	var runtime_state_record: Dictionary = bundle.get_monster(1).duplicate(true)
	for field_name: String in [
		"target",
		"guarding",
		"movement",
		"lr",
		"up",
		"attackNum",
		"bonusAttack",
	]:
		runtime_state_record[field_name] = 1
	runtime_state_record["underneath"] = [1001, 1002, 1003, 1004]
	_expect_equal(
		materializer._unsupported_fields(
			runtime_state_record,
			{},
			{},
			{},
			{}
		),
		[],
		"Realmz battle-setup scratch fields do not block native materialization"
	)
	var morale_record: Dictionary = bundle.get_monster(1).duplicate(true)
	morale_record["runPercent"] = 12
	morale_record["surrenderPercent"] = 6
	var morale_native: Dictionary = materializer._native_monster(
		morale_record,
		[],
		{},
		[],
		{},
		{},
		{}
	)
	_expect_equal(
		morale_native.get("classicRunPercent"),
		12,
		"Classic run threshold remains available as source metadata"
	)
	_expect_equal(
		morale_native.get("classicSurrenderPercent"),
		6,
		"Classic surrender threshold remains available as source metadata"
	)
	_expect_equal(
		morale_native.get("classicMaterialization", {}).get("unsupportedFields"),
		[],
		"shipped inert morale thresholds do not block native materialization"
	)
	_expect(
		morale_native.get(
			"classicMaterialization", {}
		).get("fidelityFallbacks", []).has("classicInertMoraleThresholds"),
		"nonzero inert morale thresholds remain visible as a compatibility fallback"
	)
	morale_record["runPercent"] = 101
	morale_record["surrenderPercent"] = 101
	var active_morale_fields: Array = materializer._unsupported_fields(
		morale_record,
		{},
		{},
		{},
		{}
	)
	_expect(
		active_morale_fields.has("runPercent") \
			and active_morale_fields.has("surrenderPercent"),
		"active Classic retreat and surrender thresholds remain explicit blockers"
	)
	var active_morale_native: Dictionary = materializer._native_monster(
		morale_record,
		[],
		{},
		[],
		{},
		{},
		{}
	)
	_expect(
		not active_morale_native.get(
			"classicMaterialization", {}
		).get("fidelityFallbacks", []).has("classicInertMoraleThresholds"),
		"active morale thresholds are not mislabeled as inert fallbacks"
	)

	var elemental_root := test_root.path_join("elemental-attack")
	DirAccess.make_dir_recursive_absolute(elemental_root)
	var elemental_bundle = BundleScript.new()
	elemental_bundle.load_from_directory(PROVIDENCE_AUTHORITATIVE_FIXTURE)
	_clear_producer_monster_equipment(elemental_bundle)
	elemental_bundle.documents["content"]["monsters"][0]["attacks"][0][3] = 11
	_expect_equal(
		materializer.materialize(elemental_bundle, elemental_root).get("status"),
		"ok",
		"Classic elemental attacks generate native damage"
	)
	var elemental_book: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string(elemental_root.path_join("Bestiary/stuff_book.json"))
	)
	var elemental_monster: Dictionary = elemental_book.get("Classic Monster 1", {})
	var elemental_attack: Dictionary = elemental_monster.get(
		"tools", {}
	).get("unarmed_melee_attacks", [])[0]
	_expect_equal(
		elemental_attack.get("weapon_dmg", {}).get("Fire"),
		[1.0, 8.0],
		"Classic fire damage uses its source attack maximum"
	)
	_expect_equal(
		elemental_attack.get("extra_data", {}).get("classicSpecialAttack"),
		11,
		"native attack retains its Classic special-attack identity"
	)
	_expect_equal(
		elemental_monster.get(
			"classicMaterialization", {}
		).get("unsupportedFields", []),
		[],
		"unarmed elemental damage does not block launch"
	)
	_expect(
		elemental_monster.get(
			"classicMaterialization", {}
		).get("fidelityFallbacks", []).has("elementalSpecialAttackMitigation"),
		"native resistance records the Classic per-hit save fallback"
	)
	_expect(
		bool(ReadinessScript.new().inspect(
			elemental_bundle,
			{"bestiary": elemental_book}
		).get("ready", false)),
		"unarmed elemental attack remains launchable"
	)
	var expected_elements := {
		11: "Fire",
		12: "Ice",
		13: "Electric",
		14: "Chemical",
		15: "Mental",
	}
	for special_code: int in expected_elements:
		var attack_record: Dictionary = bundle.get_monster(1).duplicate(true)
		attack_record["attacks"][0][3] = special_code
		var native_attack_result: Dictionary = materializer._native_attacks(attack_record)
		_expect(
			native_attack_result.get("entries", [])[0].get(
				"weapon_dmg", {}
			).has(expected_elements[special_code]),
			"Classic special attack %d maps to native %s damage" % [
				special_code,
				expected_elements[special_code],
			]
		)
	var exact_variant_root := test_root.path_join("exact-spell-variant")
	DirAccess.make_dir_recursive_absolute(exact_variant_root)
	var exact_variant_bundle = BundleScript.new()
	exact_variant_bundle.load_from_directory(PROVIDENCE_AUTHORITATIVE_FIXTURE)
	_clear_producer_monster_equipment(exact_variant_bundle)
	# The Priest record shares a display name with the weaker Sorcerer and
	# Enchanter spell, but resolves through its own exact-ID resource.
	exact_variant_bundle.documents["content"]["monsters"][0]["spells"] = [
		2708, 0, 0, 0, 0, 0, 0, 0, 0, 0
	]
	_expect_equal(
		materializer.materialize(
			exact_variant_bundle,
			exact_variant_root
		).get("status"),
		"ok",
		"exact spell variants remain materializable"
	)
	var exact_variant_book: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string(
			exact_variant_root.path_join("Bestiary/stuff_book.json")
		)
	)
	var exact_variant_monster: Dictionary = exact_variant_book.get(
		"Classic Monster 1", {}
	)
	_expect_equal(
		exact_variant_monster.get("tools", {}).get("spells"),
		[["Classic Power Drain Priest", 1.0]],
		"a same-name spell with different mechanics selects its exact resource"
	)
	_expect(
		not exact_variant_monster.get(
			"classicMaterialization", {}
		).get("unsupportedFields", []).has("spells[0]"),
		"an exact spell variant no longer records an unsupported source slot"
	)

	var unresolved_inventory_root := test_root.path_join("unresolved-inventory")
	DirAccess.make_dir_recursive_absolute(unresolved_inventory_root)
	var unresolved_inventory_bundle = BundleScript.new()
	unresolved_inventory_bundle.load_from_directory(PROVIDENCE_AUTHORITATIVE_FIXTURE)
	unresolved_inventory_bundle.documents["content"]["monsters"][0]["items"] = [
		1999, 0, 0, 0, 0, 0
	]
	unresolved_inventory_bundle.documents["content"]["monsters"][0]["weapon"] = -1
	_expect_equal(
		materializer.materialize(
			unresolved_inventory_bundle,
			unresolved_inventory_root
		).get("status"),
		"ok",
		"unresolved monster inventory remains inspectable"
	)
	var unresolved_inventory_book: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string(
			unresolved_inventory_root.path_join("Bestiary/stuff_book.json")
		)
	)
	var unresolved_fields: Array = unresolved_inventory_book.get(
		"Classic Monster 1", {}
	).get("classicMaterialization", {}).get("unsupportedFields", [])
	_expect(
		unresolved_fields.has("items[0]") \
			and unresolved_fields.has("weapon.randomSelector"),
		"unresolved item IDs and random weapon tables remain explicit blockers"
	)

	var unsupported_root := test_root.path_join("unsupported")
	DirAccess.make_dir_recursive_absolute(unsupported_root)
	var unsupported_bundle = BundleScript.new()
	unsupported_bundle.load_from_directory(PROVIDENCE_AUTHORITATIVE_FIXTURE)
	_clear_producer_monster_equipment(unsupported_bundle)
	unsupported_bundle.documents["content"]["monsters"][0]["attacks"][0][3] = 1
	_expect_equal(
		materializer.materialize(unsupported_bundle, unsupported_root).get("status"),
		"ok",
		"unsupported monster fields remain inspectable in the native bestiary"
	)
	var unsupported_book: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string(unsupported_root.path_join("Bestiary/stuff_book.json"))
	)
	_expect(
		unsupported_book.get(
			"Classic Monster 1", {}
		).get("classicMaterialization", {}).get(
			"unsupportedFields", []
		).has("attacks[0].special"),
		"unsupported attack records its exact source slot"
	)
	var unsupported_readiness: Dictionary = ReadinessScript.new().inspect(
		unsupported_bundle,
		{"bestiary": unsupported_book}
	)
	_expect(
		_readiness_has_reference_diagnostic(
			unsupported_readiness, "unsupported-native-monster-fields", 1
		),
		"unsupported monster behavior blocks launch with its stable identity"
	)
	_expect_equal(
		CampaignPackageInstallerScript.new()._remove_directory(test_root),
		OK,
		"bestiary materializer test cleans its workspace"
	)


func _clear_producer_monster_equipment(bundle: Object) -> void:
	var monsters: Array = bundle.documents.get("content", {}).get("monsters", [])
	if monsters.is_empty() or not (monsters[0] is Dictionary):
		return
	monsters[0]["items"] = [0, 0, 0, 0, 0, 0]
	monsters[0]["weapon"] = 0


func _test_classic_map_sound_bridge() -> void:
	var classic_selection: Dictionary = MapBridgeScript.select_tile_stack_sound([
		{"sound": [], "classicSoundId": 0},
		{"sound": [], "classicSoundId": 321},
	])
	_expect_equal(
		classic_selection.get("classicSoundId"),
		321,
		"exploration selects a generated tile's Classic sound"
	)
	var native_selection: Dictionary = MapBridgeScript.select_tile_stack_sound([
		{"sound": ["walk road.wav"], "classicSoundId": 0},
		{"sound": [], "classicSoundId": 321},
	])
	_expect_equal(
		native_selection.get("nativeSounds"),
		["walk road.wav"],
		"native map sound remains authoritative over Classic tile metadata"
	)
	_expect_equal(
		MapBridgeScript.select_tile_stack_sound([{"sound": []}]),
		{},
		"silent native tiles do not request Classic playback"
	)

	var adapter = MapSoundAdapter.new()
	var host = HostScript.new()
	host.configure(adapter)
	var result: Dictionary = host.play_map_sound(321)
	_expect_equal(adapter.sound_ids, [321], "map sound reaches the Classic command adapter")
	_expect_equal(result.get("handled"), true, "Classic runtime host handles map sound playback")
	host.free()


func _test_classic_campaign_package_installer() -> void:
	var test_root := ProjectSettings.globalize_path(
		"user://classic-package-installer-%d" % Time.get_ticks_msec()
	)
	var campaigns_directory := test_root.path_join("Campaigns")
	var profiles_directory := test_root.path_join("Profiles")
	var profile_sentinel := profiles_directory.path_join("keep-save.txt")
	DirAccess.make_dir_recursive_absolute(profiles_directory)
	var sentinel_file := FileAccess.open(profile_sentinel, FileAccess.WRITE)
	_expect(sentinel_file != null, "package installer test creates a save sentinel")
	if sentinel_file != null:
		sentinel_file.store_string("unchanged")
		sentinel_file.close()

	var installer = CampaignPackageInstallerScript.new()
	var install_result: Dictionary = installer.install_export(
		CAMPAIGN_UI_SMOKE_FIXTURE,
		campaigns_directory
	)
	_expect_equal(install_result.get("status"), "ok", "complete Classic export installs")
	_expect_equal(
		install_result.get("campaignId"),
		"fixture-classic-campaign-ui-smoke",
		"installed package preserves its scenario identity"
	)
	_expect_equal(
		install_result.get("readinessState"),
		"Ready",
		"installed package reports launch readiness"
	)
	var destination := campaigns_directory.path_join(CAMPAIGN_UI_SMOKE_FIXTURE.get_file())
	_expect(
		FileAccess.file_exists(destination.path_join("campaign.json")),
		"installer copies the complete campaign directory"
	)
	var materializable_export := test_root.path_join("producer-stock-map")
	_expect_equal(
		installer._copy_directory(
			ProjectSettings.globalize_path(PROVIDENCE_AUTHORITATIVE_FIXTURE),
			materializable_export
		),
		OK,
		"installer test stages a producer-generated bundle without native maps"
	)
	var producer_maps_path := materializable_export.path_join("classic").path_join("maps.json")
	var producer_maps: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string(producer_maps_path)
	)
	producer_maps["maps"][0]["render"] = {
		"landlook": 0,
		"mode": "outdoor-landlook",
		"tilesetId": "landlook-0",
	}
	var producer_tiles: Array = producer_maps["maps"][0]["tiles"]
	for tile_index: int in range(producer_tiles.size()):
		if int(producer_tiles[tile_index]) < 0:
			producer_tiles[tile_index] = 156
	producer_maps["maps"][1] = {
		"height": 2,
		"id": "dungeon:0",
		"index": 0,
		"levelType": "dungeon",
		"render": {
			"landlook": null,
			"mode": "dungeon-top-down",
			"tilesetId": "dungeon-top-down-302",
		},
		"tiles": [0, 1, 2, 8],
		"width": 2,
	}
	var producer_maps_file := FileAccess.open(producer_maps_path, FileAccess.WRITE)
	_expect(producer_maps_file != null, "installer test rewrites its disposable map document")
	if producer_maps_file != null:
		producer_maps_file.store_string(JSON.stringify(producer_maps, "  ") + "\n")
		producer_maps_file.close()
	var materialized_install: Dictionary = installer.install_export(
		materializable_export,
		campaigns_directory
	)
	_expect_equal(
		materialized_install.get("status"),
		"ok",
		"installer generates native maps from normalized producer data"
	)
	var materialized_map_directory := campaigns_directory.path_join(
		"producer-stock-map"
	).path_join("Maps").path_join("map_0")
	_expect(
		FileAccess.file_exists(materialized_map_directory.path_join("map_things.json")),
		"installed producer bundle contains its generated native map"
	)
	var materialized_dungeon_directory := campaigns_directory.path_join(
		"producer-stock-map"
	).path_join("Maps").path_join("mapd_0")
	_expect(
		FileAccess.file_exists(materialized_dungeon_directory.path_join("map_things.json")),
		"installed producer bundle contains its generated native dungeon"
	)
	_expect(
		FileAccess.file_exists(
			campaigns_directory.path_join("producer-stock-map").path_join(
				"Tilesets/ClassicDungeon/ClassicDungeon.png"
			)
		),
		"installed producer bundle contains its generated dungeon atlas"
	)
	var materialized_areas: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string(
			materialized_map_directory.path_join("map_scriptareas.json")
		)
	)
	_expect_equal(
		materialized_areas.get("ScriptRects", {}).get(
			"AP0x11y12", {}
		).get("scriptToLoad"),
		"land:0:ap:0",
		"installed producer map retains its stable action-point identity"
	)
	var unsupported_item_export := test_root.path_join("producer-unsupported-item")
	_expect_equal(
		installer._copy_directory(materializable_export, unsupported_item_export),
		OK,
		"installer test stages a producer item with unsupported behavior"
	)
	var unsupported_content_path := unsupported_item_export.path_join(
		"classic/content.json"
	)
	var unsupported_content: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string(unsupported_content_path)
	)
	unsupported_content["scenarioItems"][0]["damage"] = 1
	var unsupported_content_file := FileAccess.open(
		unsupported_content_path,
		FileAccess.WRITE
	)
	_expect(
		unsupported_content_file != null,
		"installer test rewrites its disposable item document"
	)
	if unsupported_content_file != null:
		unsupported_content_file.store_string(JSON.stringify(unsupported_content, "  ") + "\n")
		unsupported_content_file.close()
	var unsupported_item_install: Dictionary = installer.install_export(
		unsupported_item_export,
		campaigns_directory
	)
	_expect_equal(
		unsupported_item_install.get("status"),
		"error",
		"installer rejects a materialized item with unsupported behavior"
	)
	_expect(
		str(unsupported_item_install.get("message", "")).contains(
			"unsupported native fields"
		),
		"unsupported item installation reports the item readiness boundary"
	)
	var unsupported_monster_export := test_root.path_join("producer-unsupported-monster")
	_expect_equal(
		installer._copy_directory(materializable_export, unsupported_monster_export),
		OK,
		"installer test stages a producer monster with unsupported behavior"
	)
	var unsupported_monster_content_path := unsupported_monster_export.path_join(
		"classic/content.json"
	)
	var unsupported_monster_content: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string(unsupported_monster_content_path)
	)
	unsupported_monster_content["monsters"][0]["attacks"][0][3] = 1
	var unsupported_monster_content_file := FileAccess.open(
		unsupported_monster_content_path,
		FileAccess.WRITE
	)
	_expect(
		unsupported_monster_content_file != null,
		"installer test rewrites its disposable monster document"
	)
	if unsupported_monster_content_file != null:
		unsupported_monster_content_file.store_string(
			JSON.stringify(unsupported_monster_content, "  ") + "\n"
		)
		unsupported_monster_content_file.close()
	var unsupported_monster_install: Dictionary = installer.install_export(
		unsupported_monster_export,
		campaigns_directory
	)
	_expect_equal(
		unsupported_monster_install.get("status"),
		"error",
		"installer rejects a materialized monster with unsupported behavior"
	)
	_expect(
		str(unsupported_monster_install.get("message", "")).contains(
			"unsupported native fields: attacks[0].special"
		),
		"unsupported monster installation names the blocked bestiary field"
	)

	var no_replace_result: Dictionary = installer.install_export(
		CAMPAIGN_UI_SMOKE_FIXTURE,
		campaigns_directory
	)
	_expect_equal(
		no_replace_result.get("status"),
		"error",
		"installer requires an explicit package update"
	)
	_expect(
		str(no_replace_result.get("message", "")).contains("--replace"),
		"existing-package diagnostic explains how to update"
	)

	var stale_path := destination.path_join("stale-export-file.txt")
	var stale_file := FileAccess.open(stale_path, FileAccess.WRITE)
	if stale_file != null:
		stale_file.store_string("remove on update")
		stale_file.close()
	var replace_result: Dictionary = installer.install_export(
		CAMPAIGN_UI_SMOKE_FIXTURE,
		campaigns_directory,
		true
	)
	_expect_equal(replace_result.get("status"), "ok", "Classic package update succeeds")
	_expect(bool(replace_result.get("replacedExisting", false)), "package update reports replacement")
	_expect(
		not FileAccess.file_exists(stale_path),
		"package update does not mix files from different exports"
	)
	_expect_equal(
		FileAccess.get_file_as_string(profile_sentinel),
		"unchanged",
		"package update leaves profile save data untouched"
	)
	var manifest_path := destination.path_join("campaign.json")
	var installed_manifest: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string(manifest_path)
	)
	installed_manifest["id"] = "different-campaign"
	var manifest_file := FileAccess.open(manifest_path, FileAccess.WRITE)
	if manifest_file != null:
		manifest_file.store_string(JSON.stringify(installed_manifest, "  "))
		manifest_file.close()
	var identity_change_result: Dictionary = installer.install_export(
		CAMPAIGN_UI_SMOKE_FIXTURE,
		campaigns_directory,
		true
	)
	_expect_equal(
		identity_change_result.get("status"),
		"error",
		"package update preserves the installed campaign identity"
	)
	_expect(
		str(identity_change_result.get("message", "")).contains("campaign ID"),
		"campaign identity mismatch returns an actionable error"
	)
	var preserved_manifest: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string(manifest_path)
	)
	_expect_equal(
		preserved_manifest.get("id"),
		"different-campaign",
		"rejected identity change leaves the installed package untouched"
	)

	var producer_result: Dictionary = installer.install_export(
		PROVIDENCE_AUTHORITATIVE_FIXTURE,
		campaigns_directory
	)
	_expect_equal(
		producer_result.get("status"),
		"ok",
		"unchanged producer export installs with derived native media"
	)
	_expect_equal(
		producer_result.get("readinessState"),
		"Ready with fallbacks",
		"unchanged producer export reports its bounded monster fallbacks"
	)
	var producer_destination := campaigns_directory.path_join(
		PROVIDENCE_AUTHORITATIVE_FIXTURE.get_file()
	)
	_expect(
		FileAccess.file_exists(
			producer_destination.path_join("Tilesets/landlook-6/landlook-6.png")
		),
		"producer PICT payload becomes a native custom-land atlas"
	)
	_expect(
		FileAccess.file_exists(
			producer_destination.path_join(
				"Tilesets/ClassicLandOverlay/ClassicLandOverlay.png"
			)
		),
		"producer cicn payload becomes a native special-land atlas"
	)
	_expect(
		FileAccess.file_exists(
			producer_destination.path_join("Maps/mapd_0/map_things.json")
		),
		"unchanged producer export materializes its authored dungeon"
	)
	var producer_item_book: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string(
			producer_destination.path_join("Items/stuff_book.json")
		)
	)
	_expect_equal(
		producer_item_book.get("Classic Item 901", {}).get("classicItemId"),
		901,
		"unchanged producer export materializes its scenario item"
	)
	_expect(
		FileAccess.file_exists(producer_destination.path_join("Items/textureAtlas.png")),
		"installed producer bundle includes a loadable native item resource set"
	)
	var producer_bestiary: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string(
			producer_destination.path_join("Bestiary/stuff_book.json")
		)
	)
	_expect_equal(
		producer_bestiary.get("Classic Monster 1", {}).get("classicMonsterId"),
		1,
		"unchanged producer export materializes its battle monster"
	)
	_expect(
		FileAccess.file_exists(producer_destination.path_join("Bestiary/textureAtlas.png")),
		"installed producer bundle includes a loadable native bestiary resource set"
	)

	var campaigns_access := DirAccess.open(campaigns_directory)
	var temporary_entries: Array[String] = []
	if campaigns_access != null:
		campaigns_access.list_dir_begin()
		var entry := campaigns_access.get_next()
		while not entry.is_empty():
			if entry.begins_with(".realmz-"):
				temporary_entries.append(entry)
			entry = campaigns_access.get_next()
		campaigns_access.list_dir_end()
	_expect(
		temporary_entries.is_empty(),
		"package installer cleans staging and backup directories"
	)
	_expect_equal(
		installer._remove_directory(test_root),
		OK,
		"package installer test cleans its workspace"
	)


func _test_failed_save_restore_rolls_back() -> void:
	var campaigns_directory := PROVIDENCE_AUTHORITATIVE_FIXTURE.get_base_dir()
	var campaign_name := PROVIDENCE_AUTHORITATIVE_FIXTURE.get_file()
	var session = CampaignSessionScript.new()
	get_root().add_child(session)
	var adapter = FailingSaveRestoreAdapter.new()
	_expect_equal(
		session.load_installed_campaign(
			campaigns_directory,
			campaign_name,
			adapter
		).get("status"),
		"ok",
		"recovery test campaign session loads"
	)
	var state: Object = session.host.runtime.runtime_state
	state.set_quest_flag(12)
	state.set_location("land", 0, 10, 12)
	var runtime_before: Dictionary = state.snapshot()
	var adapter_before: Dictionary = adapter.compatibility_state.duplicate(true)
	var bundle_before: Dictionary = session.install.bundle.documents.duplicate(true)
	var incoming: Dictionary = session.make_save_payload().duplicate(true)
	incoming["runtimeState"]["questFlags"] = {"99": true}
	incoming["runtimeState"]["position"] = {
		"levelType": "dungeon",
		"levelIndex": 3,
		"x": 8,
		"y": 9,
	}
	incoming["adapterState"] = {"marker": "incoming"}
	adapter.reject_next_restore = true
	var restore_result: Dictionary = session.restore_save_payload(incoming)
	_expect_equal(restore_result.get("status"), "error", "failed adapter restore is reported")
	_expect(
		str(restore_result.get("message", "")).contains("rejected the saved state"),
		"failed adapter restore returns an actionable error"
	)
	_expect_equal(state.snapshot(), runtime_before, "failed restore rolls back runtime mutations")
	_expect_equal(
		adapter.compatibility_state,
		adapter_before,
		"failed restore rolls back adapter mutations"
	)
	_expect_equal(
		session.install.bundle.documents,
		bundle_before,
		"failed restore leaves the installed campaign immutable"
	)
	session.clear()
	session.queue_free()


func _test_bundle_indexes(bundle) -> void:
	_expect_equal(bundle.manifest.get("name"), "City of Bywater", "campaign identity")
	_expect_equal(bundle.get_map("land:0").get("width"), 90, "map index")
	_expect_equal(bundle.get_extra_action_point(100).get("source"), "Data ED3", "ED3 AP index")
	_expect_equal(bundle.get_triggers_at("land", 0, 9, 17).size(), 1, "coordinate trigger index")
	_expect_equal(bundle.get_treasure(11).get("itemIds", [])[0], 807, "treasure index")
	_expect_equal(bundle.get_item_text(801).get("identifiedName"), "Priest Scroll Case", "item text index")
	_expect_equal(bundle.get_encounter("simple", 0).get("prompt"), 51, "simple encounter index")
	_expect_equal(bundle.get_encounter("complex", 2).get("prompt"), 180, "complex encounter index")
	_expect_equal(bundle.get_thief_encounter(4).get("tumblers"), 2, "rogue encounter index")
	_expect_equal(bundle.get_thief_encounter(1).get("highDamage"), 12, "rogue trap index")
	_expect_equal(bundle.get_picture(32128), {}, "missing picture index")
	_expect_equal(bundle.get_monster(71), {}, "missing monster index")


func _test_execution_coverage_audit(bundle) -> void:
	var report: Dictionary = ExecutionAuditScript.new().inspect(bundle)
	var contexts: Dictionary = report.get("contexts", {})
	_expect(
		int(contexts.get("data-ed-result", {}).get("actions", 0)) > 0,
		"execution audit inventories Data ED result actions"
	)
	_expect(
		int(contexts.get("data-ed2-result", {}).get("actions", 0)) > 0,
		"execution audit inventories Data ED2 result actions"
	)
	_expect(
		int(contexts.get("data-ed3-xap", {}).get("actions", 0)) > 0,
		"execution audit inventories Data ED3 actions"
	)
	var unsupported_opcodes: Array = []
	for diagnostic_value: Variant in report.get("diagnostics", []):
		if (
			diagnostic_value is Dictionary
			and diagnostic_value.get("code") == "unsupported-action"
		):
			unsupported_opcodes.append(int(diagnostic_value.get("opcode", 0)))
	_expect_equal(unsupported_opcodes.count(43), 0, "execution audit recognizes CoB Give Condition")
	_expect_equal(unsupported_opcodes.size(), 0, "checked fixture has no executable unknowns")
	_expect_equal(
		unsupported_opcodes.size(),
		report.get("totals", {}).get("unknownExecutable"),
		"every executable unknown action has a readiness diagnostic"
	)

	var macro_bundle = _execution_audit_test_bundle()
	var macro_report: Dictionary = ExecutionAuditScript.new().inspect(macro_bundle)
	var macro_contexts: Dictionary = macro_report.get("contexts", {})
	_expect_equal(
		macro_contexts.get("battle-round-macro", {}).get("actions"),
		2,
		"execution audit expands battle-round macro roots"
	)
	_expect_equal(
		macro_contexts.get("death-macro", {}).get("actions"),
		2,
		"execution audit expands immediate death macro roots"
	)
	_expect_equal(
		macro_contexts.get("queued-death-macro", {}).get("actions"),
		2,
		"execution audit expands queued death macro roots"
	)
	_expect_equal(
		macro_contexts.get("data-ed2-result", {}).get("sourceBackedNoops"),
		1,
		"execution audit recognizes evidence-backed result no-ops"
	)
	_expect(
		_audit_has_diagnostic(macro_report, "missing-macro-target"),
		"execution audit diagnoses a missing death macro"
	)
	_expect(
		_audit_has_diagnostic(macro_report, "inactive-macro-target"),
		"execution audit diagnoses an inactive but reachable macro"
	)
	var invalid_death_records: Array = []
	for diagnostic_value: Variant in macro_report.get("diagnostics", []):
		if (
			diagnostic_value is Dictionary
			and diagnostic_value.get("code") == "invalid-death-macro"
		):
			invalid_death_records.append(int(diagnostic_value.get("recordIndex", -1)))
	_expect_equal(
		invalid_death_records,
		[3],
		"execution audit rejects negative death macros before the catalog terminator only"
	)

	var unsupported_interpreter = _interpreter(macro_bundle)
	_expect(
		unsupported_interpreter.begin_trigger("audit:complex"),
		"begin unsupported encounter-result fixture"
	)
	unsupported_interpreter.run_until_yield()
	var unsupported: Dictionary = unsupported_interpreter.resume_encounter(1)
	_expect_equal(unsupported.get("status"), "unsupported", "unknown result action stops explicitly")
	_expect(
		str(unsupported.get("message", "")).contains("Data ED2 record 2 slot 0"),
		"unsupported result identifies its source record and slot"
	)


func _test_data_ed3_callability_contract() -> void:
	var bundle = BundleScript.new()
	bundle.manifest = {"start": {"levelType": "land", "levelIndex": 0, "x": 0, "y": 0}}
	_add_stack_trigger(bundle, "Data ED3:macro:10", 10, [_classic_action(0, 256, 0)])
	_add_stack_trigger(bundle, "Data ED3:macro:11", 11, [_classic_action(0, 257, 0)])
	bundle.extra_action_points_by_id[11]["callable"] = false
	_add_stack_trigger(bundle, "Data ED3:macro:12", 12, [_classic_action(0, 258, 0)])
	bundle.extra_action_points_by_id[12]["active"] = false
	bundle.extra_action_points_by_id[12]["callable"] = true
	_add_stack_trigger(bundle, "Data ED3:macro:13", 13, [_classic_action(0, 259, 0)])
	bundle.extra_action_points_by_id[13]["callable"] = false
	bundle.battles_by_id[1] = {"id": 1, "battleMacro": -13}

	var report: Dictionary = ExecutionAuditScript.new().inspect(bundle)
	var actions_by_record: Dictionary = {}
	for action_value: Variant in report.get("actions", []):
		if action_value is Dictionary and action_value.get("source") == "Data ED3":
			actions_by_record[int(action_value.get("recordIndex", -1))] = action_value
	_expect_equal(actions_by_record.size(), 4, "execution audit preserves every Data ED3 row")
	_expect(
		bool(actions_by_record[10].get("executable")),
		"legacy Data ED3 rows retain active-based audit behavior"
	)
	_expect(
		not bool(actions_by_record[11].get("executable")),
		"producer-marked uncallable Data ED3 rows do not block readiness"
	)
	_expect(
		bool(actions_by_record[12].get("executable")),
		"producer callability takes precedence over the legacy active marker"
	)
	_expect(
		bool(actions_by_record[13].get("executable")),
		"source-backed macro roots promote a producer-marked uncallable row"
	)
	_expect(
		actions_by_record[13].get("executionContexts", []).has("battle-round-macro"),
		"promoted rows retain their discovered execution context"
	)
	_expect_equal(
		_audit_diagnostic_count(report, "unsupported-action"),
		3,
		"only callable or source-reachable unknown actions block readiness"
	)
	_expect_equal(
		_audit_diagnostic_count(report, "inactive-action-record"),
		1,
		"uncallable rows remain visible as inactive evidence"
	)


func _test_campaign_readiness_report() -> void:
	var bundle = BundleScript.new()
	bundle.manifest = _minimal_contract_manifest()
	bundle.manifest["id"] = "scenario-city-of-bywater"
	bundle.manifest["name"] = "City of Bywater"
	bundle.documents = _minimal_contract_documents()
	bundle.documents["scenario"]["identity"] = {
		"id": bundle.manifest["id"],
		"name": bundle.manifest["name"],
	}
	bundle.documents["maps"]["maps"] = [{"id": "land:0"}]
	bundle.documents["scripts"]["triggers"] = [
		_readiness_action_point("Data DD", 76, 27, 32128),
		_readiness_action_point("Data DD", 89, 18, 375),
		_readiness_action_point("Data DD", 90, 1, -30000),
		_readiness_action_point("Data ED3", 108, 17, 388),
		_readiness_action_point("Data ED3", 114, 17, 389),
		_readiness_action_point("Data ED3", 128, 17, 428),
		_readiness_action_point("Data ED3", 129, 17, 429),
		_readiness_action_point("Data ED3", 103, 89, 71),
		_readiness_action_point("Data ED3", 197, -85, -1700),
	]
	bundle.documents["scripts"]["extraCodes"] = [
		{"id": 375, "values": [1408, 3, 0, 0, 0]},
		{"id": 388, "values": [2301, 1, 0, 0, 0]},
		{"id": 389, "values": [3202, 1, 0, 0, 0]},
		{"id": 428, "values": [4606, 3, 30, 0, 0]},
		{"id": 429, "values": [2304, 7, -45, 0, 0]},
		# The positive record exists, but Classic's signed lookup is exact.
		{"id": 1700, "values": [40, 40, 40, 40, 40]},
	]
	bundle.documents["content"]["monsters"] = [{
		"id": 71,
		"nameId": 19,
		"displayName": "Vodalian",
	}]
	bundle.documents["content"]["scenarioItems"] = [
		{
			"itemId": 878,
			"iconId": 601,
			"itemType": 24,
			"cost": 10,
			"weight": 100,
		},
		{
			"itemId": 811,
			"iconId": 0,
			"itemType": 0,
			"cost": 0,
			"weight": 0,
		},
	]
	bundle.documents["encounters"]["complexEncounters"] = [{
		"id": 9,
		"actions": [],
		"itemIds": [878, 811, 0, 0, 0],
		"spellIds": [1, 9998, 0, 0, 0, 0, 0, 0, 0, 0],
	}]
	bundle.documents["assets"]["catalog"]["pictures"] = [{
		"id": "scenario-pict-32128",
		"resourceId": 32128,
		"resourceType": "PICT",
	}]
	bundle._build_indexes()
	_expect_equal(bundle.get_scenario_item(878).get("itemId"), 878, "scenario-item index")
	_expect_equal(
		bundle.get_monsters_by_name_id(19).map(
			func(monster: Dictionary) -> int: return int(monster.get("id", -1))
		),
		[71],
		"monster name-ID index"
	)

	var report: Dictionary = ReadinessScript.new().inspect(bundle, {
		"bestiary": {
			"Vodada !": {"data": {"name": "Vodada !"}},
		},
		"spells": {"Discover Magic": true},
		"items": {"Dagger": {}},
	})
	_expect(not report.get("ready", true), "readiness blocks progression-affecting gaps")
	_expect(
		_readiness_has_diagnostic(
			report, "missing-picture-payload", "Data DD", 76, 0, "fidelity-fallback"
		),
		"readiness classifies missing PICT payload as a fidelity fallback"
	)
	_expect(
		_readiness_has_diagnostic(
			report, "missing-message", "Data DD", 90, 0, "fidelity-fallback"
		),
		"readiness classifies missing message text as a fidelity fallback"
	)
	_expect(
		_readiness_has_diagnostic(
			report, "missing-extra-code", "Data ED3", 197, 0, "progression-blocker"
		),
		"readiness classifies the signed random-record gap as a blocker"
	)
	_expect(
		_readiness_has_diagnostic(
			report, "unresolved-native-monster", "Data ED3", 103, 0, "progression-blocker"
		),
		"readiness classifies an unmatched compiled ally as a blocker"
	)
	_expect(
		_readiness_has_diagnostic(
			report, "missing-native-spell", "Data ED3", 128, 0, "progression-blocker"
		),
		"readiness reports a mapped spell without a native resource"
	)
	_expect(
		_readiness_has_reference_diagnostic(report, "missing-native-spell", 1408),
		"readiness reports a missing Power Drain resource"
	)
	_expect(
		_readiness_has_reference_diagnostic(report, "missing-native-spell", 2301),
		"readiness reports a missing Confuse resource"
	)
	_expect(
		_readiness_has_reference_diagnostic(report, "missing-native-spell", 3202),
		"readiness reports a missing Daze resource"
	)
	_expect(
		_readiness_has_reference_diagnostic(report, "missing-native-spell", 2304),
		"readiness reports a missing Festering Wounds resource"
	)
	_expect(
		_readiness_has_diagnostic(
			report, "unresolved-item-identity", "Data ED2", 9, -1, "progression-blocker"
		),
		"readiness reports an unresolved complex-encounter item"
	)
	_expect(
		not _readiness_has_reference_diagnostic(report, "unresolved-item-identity", 811),
		"readiness ignores empty fixed-capacity scenario-item slots"
	)
	_expect(
		_readiness_has_diagnostic(
			report, "missing-native-spell-class", "Data ED2", 9, -1, "progression-blocker"
		),
		"readiness requires explicit metadata for Classic spell-class shortcuts"
	)
	_expect(
		_readiness_has_diagnostic(
			report, "unresolved-spell-identity", "Data ED2", 9, -1, "progression-blocker"
		),
		"readiness reports an unresolved complex-encounter spell"
	)
	_expect(
		str(report.get("summary", "")).contains("progression blocker")
		and str(report.get("summary", "")).contains("fidelity fallback"),
		"readiness supplies a concise player-facing summary"
	)
	var json_report: Variant = JSON.parse_string(JSON.stringify(report))
	_expect(json_report is Dictionary, "readiness report is machine-readable JSON")
	_expect_equal(
		json_report.get("schemaVersion") if json_report is Dictionary else -1,
		ReadinessScript.SCHEMA_VERSION,
		"readiness JSON carries its schema version"
	)
	bundle.root_directory = "res://Campaigns/City of Bywater"
	var runtime_picture_path: String = bundle.root_directory.path_join("Splash Images/0.png")
	var runtime_picture_file := FileAccess.open(runtime_picture_path, FileAccess.READ)
	bundle.get_picture(32128)["runtimeMedia"] = {
		"path": "Splash Images/0.png",
		"mediaType": "image/png",
		"bytes": runtime_picture_file.get_length(),
		"sha256": FileAccess.get_sha256(runtime_picture_path),
	}
	runtime_picture_file.close()

	var resolved_report: Dictionary = ReadinessScript.new().inspect(bundle, {
		"bestiary": {
			"Imported Vodalian": {
				"data": {"name": "Vodalian", "classicMonsterId": 71},
			},
		},
		"spells": {
			"Confuse": {
				"classicSpellIds": [2301],
				"classicSpellSaveIndex": 5,
				"classicSpellSaveMode": "negate",
			},
			"Daze": {
				"classicSpellIds": [3202],
				"classicSpellSaveIndex": -1,
				"classicSpellSaveMode": "none",
			},
			"Discover Magic": {"classicSpellClass": 1},
			"Fire Flare": {
				"classicSpellIds": [4606],
				"classicSpellSaveIndex": 1,
				"classicSpellSaveMode": "half_damage",
			},
			"Festering Wounds": {
				"classicSpellIds": [2304],
				"classicSpellSaveIndex": 4,
				"classicSpellSaveMode": "negate",
			},
			"Power Drain": {
				"classicSpellIds": [1408, 3311],
				"classicSpellSaveIndex": 7,
				"classicSpellSaveMode": "negate",
			},
		},
		"items": {
			"Campaign Rope": {"classicItemId": 878},
		},
	})
	_expect(
		not _readiness_has_reference_diagnostic(
			resolved_report, "unresolved-item-identity", 878
		),
		"stable item metadata resolves a scenario-local encounter item"
	)
	_expect(
		not _readiness_has_diagnostic(
			resolved_report,
			"missing-picture-payload",
			"Data DD",
			76,
			0,
			"fidelity-fallback"
		),
		"available picture runtime media clears its readiness fallback"
	)
	_expect(
		not _readiness_has_diagnostic(
			resolved_report,
			"missing-picture-runtime-media",
			"Data DD",
			76,
			0,
			"fidelity-fallback"
		),
		"available decoded picture does not report missing runtime media"
	)
	_expect(
		not _readiness_has_diagnostic(
			resolved_report,
			"missing-native-spell-class",
			"Data ED2",
			9,
			-1,
			"progression-blocker"
		),
		"explicit spell-class metadata resolves a low-ID encounter response"
	)
	_expect(
		not _readiness_has_reference_diagnostic(
			resolved_report, "missing-native-spell", 1408
		),
		"explicit spell-ID metadata resolves a supported field-spell variant"
	)
	_expect(
		not _readiness_has_reference_diagnostic(
			resolved_report, "unsupported-native-spell-variant", 1408
		),
		"supported spell-ID metadata does not produce a variant blocker"
	)
	_expect(
		not _readiness_has_reference_diagnostic(
			resolved_report, "missing-native-spell", 2301
		),
		"explicit Confuse identity resolves its field-spell reference"
	)
	_expect(
		not _readiness_has_reference_diagnostic(
			resolved_report, "missing-native-spell", 3202
		),
		"explicit Daze identity resolves its field-spell reference"
	)
	_expect(
		not _readiness_has_reference_diagnostic(
			resolved_report, "missing-native-spell", 4606
		),
		"explicit Fire Flare identity resolves its field-spell reference"
	)
	_expect(
		not _readiness_has_reference_diagnostic(
			resolved_report, "missing-native-spell-save-metadata", 4606
		),
		"Fire Flare's native resource supplies its Classic save behavior"
	)
	_expect(
		not _readiness_has_reference_diagnostic(
			resolved_report, "missing-native-spell", 2304
		),
		"explicit Festering Wounds identity resolves its field-spell reference"
	)
	_expect(
		not _readiness_has_reference_diagnostic(
			resolved_report, "missing-native-spell-save-metadata", 2304
		),
		"Festering Wounds' native resource supplies its Classic save behavior"
	)
	var missing_save_metadata_report: Dictionary = ReadinessScript.new().inspect(bundle, {
		"spells": {
			"Fire Flare": {"classicSpellIds": [4606]},
		},
	})
	_expect(
		_readiness_has_reference_diagnostic(
			missing_save_metadata_report,
			"missing-native-spell-save-metadata",
			4606
		),
		"readiness blocks a field spell without explicit Classic save behavior"
	)

	var unsupported_variant_report: Dictionary = ReadinessScript.new().inspect(bundle, {
		"spells": {
			"Power Drain": {"classicSpellIds": [2708]},
		},
	})
	_expect(
		_readiness_has_reference_diagnostic(
			unsupported_variant_report, "unsupported-native-spell-variant", 1408
		),
		"readiness blocks a same-name spell resource with different mechanics"
	)
	var exact_variant_report: Dictionary = ReadinessScript.new().inspect(bundle, {
		"spells": {
			"Power Drain": {"classicSpellIds": [2708]},
			"Classic Power Drain": {
				"classicSpellIds": [1408],
				"classicSpellSaveIndex": 7,
				"classicSpellSaveMode": "negate",
			},
		},
	})
	_expect(
		not _readiness_has_reference_diagnostic(
			exact_variant_report, "unsupported-native-spell-variant", 1408
		),
		"readiness accepts a compatibility resource with the exact packed ID"
	)
	_expect(
		not _readiness_has_reference_diagnostic(
			exact_variant_report, "missing-native-spell-save-metadata", 1408
		),
		"readiness reads save metadata from the exact compatibility resource"
	)

	var malformed: Dictionary = ReadinessScript.new().inspect_directory(
		"res://scripts/classic_runtime/tests/fixtures/does-not-exist"
	)
	_expect(
		_readiness_has_diagnostic(
			malformed, "malformed-bundle", "campaign.json", -1, -1, "progression-blocker"
		),
		"readiness turns malformed bundle input into an actionable blocker"
	)


func _test_custom_spell_overrides() -> void:
	var producer_bundle = BundleScript.new()
	_expect(
		producer_bundle.load_from_directory(PROVIDENCE_AUTHORITATIVE_FIXTURE),
		"producer fixture loads for custom-spell tests"
	)
	if not producer_bundle.last_error.is_empty():
		return
	_expect_equal(
		producer_bundle.get_spell_override(5202).get("displayName"),
		"Providence Ward",
		"bundle indexes a custom spell by its exact packed runtime ID"
	)
	_expect_equal(
		producer_bundle.get_spell_override(16),
		{},
		"bundle does not use the source record index as a runtime ID"
	)

	var adapter = GodotAdapterScript.new()
	adapter.configure_classic_bundle(producer_bundle)
	var ward: Variant = adapter.classic_spell_override(5202)
	_expect(ward != null, "adapter resolves the producer's exact custom spell ID")
	_expect_equal(ward.classic_spell_ids, [5202], "custom spell exposes its packed identity")
	_expect_equal(ward.classic_spell_class, 4, "custom spell preserves its class")
	_expect_equal(ward.classic_target_type, 1, "custom spell preserves its target type")
	_expect_equal(ward.get_min_duration(3, null), 3, "fixed custom duration remains finite")
	_expect_equal(ward.get_max_duration(3, null), 3, "zero upper endpoint keeps fixed duration")
	_expect_equal(ward.get_sp_cost(3, null), 12, "custom spell cost scales by power")
	_expect(ward.in_combat and not ward.classic_in_camp, "custom spell preserves availability")
	_expect_equal(adapter.classic_spell_override(16), null, "custom spell lookup stays exact")
	var host = HostScript.new()
	var host_adapter = BundleAwareAdapter.new()
	host.configure(host_adapter)
	_expect(
		host.load_campaign(PROVIDENCE_AUTHORITATIVE_FIXTURE),
		"runtime host loads the producer fixture for custom-spell configuration"
	)
	_expect_equal(
		host_adapter.configured_bundle,
		host.runtime.bundle,
		"runtime host supplies the loaded bundle to its adapter"
	)
	host.free()

	var record := _custom_spell_record(4, 5105)
	var bundle := _custom_spell_bundle(record)
	adapter = GodotAdapterScript.new()
	adapter.configure_classic_bundle(bundle)
	var spell: Variant = adapter.classic_spell_override(5105)
	_expect_equal(spell.classic_spell_ids, [5105], "packed custom ID remains an exact identity")
	_expect_equal(spell.classic_spell_class, 2, "record index remains distinct from its class")
	_expect_equal(spell.classic_fixed_target_num, 1, "custom spell preserves fixed-target metadata")
	_expect_equal(spell.classic_resist_adjust, -3, "custom spell preserves resistance adjustment")
	_expect_equal(spell.classic_save_bonus, 15, "custom spell preserves its base save bonus")
	_expect_equal(spell.classic_sound_ids, [11, 12], "custom spell preserves Classic sound IDs")
	_expect_equal(spell.get_min_damage(2, null), 4, "custom spell minimum damage includes power dice")
	_expect_equal(spell.get_max_damage(2, null), 8, "custom spell maximum damage includes power dice")
	_expect_equal(spell.get_min_duration(2, null), 7, "custom spell minimum duration includes power dice")
	_expect_equal(spell.get_max_duration(2, null), 11, "custom spell maximum duration includes power dice")
	_expect_equal(spell.get_range(2, null), 8, "custom spell range includes its power term")
	_expect_equal(
		adapter.resolve_complex_spell_result(
			{"spellIds": [5105, 2], "spellResults": [8, 9]},
			spell.name,
			spell.classic_spell_class,
			{},
			spell.classic_spell_ids
		),
		8,
		"exact packed ID wins before a low-ID class response"
	)

	var target := RogueTestCharacter.new()
	target.stat_values["MultiplierFire"] = 1.0
	target.stat_values["ResistanceFire"] = 0.0
	var resolution: Dictionary = adapter.classic_custom_spell_target_resolution(
		{
			"power": 2,
			"saveAdjustment": 10,
			"forceAffect": false,
			"checkResistance": true,
		},
		target,
		spell,
		1,
		40
	)
	_expect_equal(resolution.get("resistanceChance"), 0.0, "cannot flag bypasses resistance")
	_expect_equal(resolution.get("saveChance"), 45.0, "custom save metadata modifies the roll")
	_expect(resolution.get("saved"), "custom damage spell can be saved against")
	_expect_equal(resolution.get("effectScale"), 0.5, "custom damage save halves the effect")

	var ready_report: Dictionary = ReadinessScript.new().inspect(bundle)
	_expect(
		not _readiness_has_reference_diagnostic(
			ready_report, "unresolved-spell-identity", 5105
		),
		"generic custom spell resolves without a native mapping"
	)
	var unsupported_record := _custom_spell_record(17, 5203)
	unsupported_record["special"] = 25
	var unsupported_report: Dictionary = ReadinessScript.new().inspect(
		_custom_spell_bundle(unsupported_record)
	)
	_expect(
		_readiness_has_diagnostic(
			unsupported_report,
			"unsupported-custom-spell-special",
			"Data Spell",
			17,
			-1,
			"progression-blocker"
		),
		"unsupported custom special reports its source record"
	)
	_expect(
		not _readiness_has_reference_diagnostic(
			unsupported_report, "unresolved-spell-identity", 5203
		),
		"unsupported custom special is not mislabeled as an identity gap"
	)


func _test_classic_regeneration_contract() -> void:
	var conditions: Array = []
	conditions.resize(40)
	conditions.fill(0)
	conditions[10] = -2
	_expect_equal(
		RegenerationScript.permanent_amount(conditions),
		2,
		"negative Classic regeneration retains its per-round healing amount"
	)
	conditions[10] = 2
	_expect_equal(
		RegenerationScript.permanent_amount(conditions),
		0,
		"positive regeneration is not mistaken for a permanent effect"
	)

	var target := RogueTestCharacter.new()
	target.current_hp = 20
	target.set_meta("classic_regeneration_per_round", 2)
	_expect_equal(
		RegenerationScript.apply_new_round(target),
		2,
		"permanent Classic regeneration reports its applied healing"
	)
	_expect_equal(target.current_hp, 22, "permanent regeneration heals once per round")
	target.current_hp = 29
	_expect_equal(
		RegenerationScript.apply_new_round(target),
		1,
		"Classic regeneration clamps to maximum health"
	)
	_expect_equal(target.current_hp, 30, "clamped regeneration reaches maximum health")
	target.current_hp = 0
	_expect_equal(
		RegenerationScript.apply_new_round(target),
		0,
		"Classic monster regeneration does not revive a defeated combatant"
	)
	_expect_equal(
		RegenerationScript.stack_condition(98, 1, 99),
		99,
		"temporary player regeneration can reach its source cap"
	)
	_expect_equal(
		RegenerationScript.stack_condition(98, 2, 99),
		98,
		"temporary player regeneration rejects an addition beyond its source cap"
	)
	_expect_equal(
		RegenerationScript.player_reduction(5),
		{"condition": 4, "healing": 5},
		"party regeneration heals before its condition decreases"
	)
	_expect_equal(
		RegenerationScript.monster_reduction(5),
		{"condition": 4, "healing": 4},
		"monster regeneration decreases before it heals"
	)
	_expect_equal(
		RegenerationScript.elapsed_hour_boundaries(3599, 7201),
		2,
		"field regeneration advances once per crossed Classic hour"
	)


func _test_classic_spell_screen_contract() -> void:
	var conditions: Array = []
	conditions.resize(40)
	conditions.fill(0)
	conditions[16] = -1
	_expect_equal(
		SpellScreenScript.permanent_level(conditions),
		1,
		"Classic condition 16 provides a permanent first-level spell screen"
	)
	conditions[19] = -4
	_expect_equal(
		SpellScreenScript.permanent_level(conditions),
		4,
		"the strongest permanent Classic screen protects through its level"
	)
	_expect(
		SpellScreenScript.supports_condition(19, -4),
		"negative spell screens are complete persistent state"
	)
	conditions[19] = 2
	_expect(
		SpellScreenScript.supports_condition(19, 2),
		"positive spell screens have round-based duration support"
	)
	_expect_equal(
		SpellScreenScript.temporary_durations(conditions),
		[0, 0, 0, 2, 0],
		"temporary screen conditions retain their separate level counters"
	)
	_expect_equal(
		SpellScreenScript.elapsed_hour_boundaries(3599, 7201),
		2,
		"field spell screens advance once per crossed Classic hour"
	)

	var target := RogueTestCharacter.new()
	target.set_meta("classic_spell_screen_level", 1)
	var flame_hands = load("res://shared_assets/spells/flame_hands.gd").new()
	var screened: Dictionary = MagicResistanceScript.spell_resolution(
		target, flame_hands, 1, 100
	)
	_expect(screened.get("resisted"), "first-level Classic spell is stopped by its screen")
	_expect_equal(screened.get("reason"), "spell-screen", "spell screen owns the resistance")
	_expect_equal(screened.get("spellLevel"), 1, "packed Classic ID exposes cast level")

	var fireball = load("res://shared_assets/spells/fireball.gd").new()
	_expect(
		not MagicResistanceScript.spell_resolution(
			target, fireball, 1, 100
		).get("resisted"),
		"first-level screen does not stop a third-level spell"
	)
	target.set_meta("classic_spell_screen_level", 3)
	_expect(
		MagicResistanceScript.spell_resolution(
			target, fireball, 1, 100
		).get("resisted"),
		"higher-level screen also stops lower-level spells"
	)

	var power_drain = load("res://shared_assets/spells/power_drain.gd").new()
	_expect_equal(
		SpellScreenScript.spell_level(power_drain),
		0,
		"multi-school Classic identity is not guessed without its caster"
	)
	var caster := RogueTestCharacter.new()
	caster.spells = [[], [], [{"script": power_drain}]]
	_expect_equal(
		SpellScreenScript.spell_level(power_drain, caster),
		3,
		"caster spellbook supplies the selected native spell level"
	)
	_expect(
		MagicResistanceScript.spell_resolution(
			target, power_drain, 1, 100, false, caster
		).get("resisted"),
		"caster-resolved multi-school spell obeys the matching screen"
	)

	var layered := SpellScreenTestCharacter.new("Layered")
	var temporary_trait = load("res://shared_assets/traits/t_classic_spell_screen.gd")
	layered.add_trait(temporary_trait, [2, 6])
	layered.add_trait(temporary_trait, [4, 2])
	_expect_equal(SpellScreenScript.level(layered), 4, "strongest temporary screen is active")
	layered.traits[0]._on_new_round(layered)
	layered.traits[0]._on_new_round(layered)
	_expect_equal(
		SpellScreenScript.level(layered),
		2,
		"an expired strong screen falls back to a weaker active screen"
	)
	_expect_equal(
		layered.traits[0].get_saved_variables(),
		[[0, 4, 0, 0, 0]],
		"layered screen counters use the normal trait save contract"
	)
	var restored := SpellScreenTestCharacter.new("Restored")
	restored.add_trait(temporary_trait, layered.traits[0].get_saved_variables())
	_expect_equal(
		SpellScreenScript.temporary_duration(restored, 2),
		4,
		"saved temporary screen counters restore without flattening"
	)
	var projected := SpellScreenTestCharacter.new("Projected")
	GodotAdapterScript.new()._set_classic_monster_identity(
		projected,
		1,
		{"conditions": conditions}
	)
	_expect_equal(
		SpellScreenScript.level(projected),
		4,
		"existing native monsters receive compiled temporary screen counters"
	)
	GodotAdapterScript.new()._set_classic_monster_identity(
		projected,
		1,
		{"conditions": conditions}
	)
	_expect_equal(
		projected.traits.size(),
		1,
		"compiled monster identity does not duplicate a materialized screen trait"
	)


func _test_classic_magic_resistance_contract() -> void:
	var target := RogueTestCharacter.new()
	target.set_meta("classic_magic_resistance", 25)
	target.inventory = [
		{"name": "Ward Ring", "equipped": 1, "classicMagicResistance": 10},
		{"name": "Cursed Charm", "equipped": 1, "classicMagicResistance": -4},
		{"name": "Carried Ward", "equipped": 0, "classicMagicResistance": 90},
	]
	_expect_equal(
		MagicResistanceScript.base_value(target),
		25,
		"Classic monster metadata owns base magic resistance"
	)
	_expect_equal(
		MagicResistanceScript.equipped_modifier(target),
		6,
		"signed worn-item magic resistance stacks additively"
	)
	_expect_equal(
		MagicResistanceScript.chance(target, 2, 3),
		37,
		"Classic resistance adjustment applies after base and equipment values"
	)

	var fireball = load("res://shared_assets/spells/fireball.gd").new()
	var resisted: Dictionary = MagicResistanceScript.spell_resolution(
		target, fireball, 1, 31
	)
	_expect(resisted.get("resisted"), "mapped combat spell can be fully resisted")
	_expect_equal(
		resisted.get("chance"),
		31,
		"mapped combat spell uses the compatibility-owned percentage"
	)
	var charm_foe = load("res://shared_assets/spells/charm_foe.gd").new()
	target.stat_values["MultiplierMental"] = 1.0
	target.stat_values["ResistanceMental"] = 4.0
	var resisted_charm: Dictionary = MagicResistanceScript.spell_resolution(
		target, charm_foe, 1, 100, false, null, 40
	)
	_expect(resisted_charm.get("resisted"), "Charm Foe checks the target's charm save first")
	_expect_equal(
		resisted_charm.get("reason"),
		"charm-resistance",
		"the early charm check reports its own resistance reason"
	)
	_expect_equal(
		resisted_charm.get("charmChance"),
		40,
		"party charm resistance uses Classic save slot zero"
	)
	var thought_lace_resistance: Dictionary = MagicResistanceScript.spell_resolution(
		target, charm_foe, 1, 100, false, null, 90, 50
	)
	_expect(
		thought_lace_resistance.get("resisted"),
		"Thought Lace can stop a charm that passes the character's ordinary save"
	)
	_expect_equal(
		thought_lace_resistance.get("charmChance"),
		90,
		"Thought Lace adds fifty points to the source charm save"
	)
	var daze = load("res://shared_assets/spells/daze.gd").new()
	var unresisted_daze: Dictionary = MagicResistanceScript.spell_resolution(
		target, daze, 1, 32, false, null, 41
	)
	_expect(
		not unresisted_daze.get("resisted"),
		"Daze continues after both its early charm roll and general resistance fail"
	)
	_expect(
		unresisted_daze.get("checksCharmResistance"),
		"Daze shares the class-zero pre-resistance rule before its later damage save"
	)
	target.set_meta("classic_hit_dice", 4)
	target.tags = ["Magic Using", "Intelligent"]
	var monster_charm: Dictionary = MagicResistanceScript.spell_resolution(
		target, charm_foe, 1, 100, false, null, 61
	)
	_expect(monster_charm.get("resisted"), "Classic monsters can resist charm before magic resistance")
	_expect_equal(
		monster_charm.get("charmChance"),
		61,
		"monster charm resistance uses hit dice and the magic-using and intelligent flags"
	)
	target.remove_meta("classic_hit_dice")
	target.tags.clear()
	target.traits = [ConditionTestTrait.new("t_animated.gd", 1)]
	var animated_immunity: Dictionary = MagicResistanceScript.spell_resolution(
		target, daze, 1, 100, false, null, 100
	)
	_expect(animated_immunity.get("resisted"), "animated targets ignore charm and mental spells")
	_expect_equal(
		animated_immunity.get("reason"),
		"animated-immunity",
		"animated immunity remains distinct from charm and general resistance"
	)
	var fearful_thoughts = load("res://shared_assets/spells/fearful_thoughts.gd").new()
	var animated_mental_immunity: Dictionary = MagicResistanceScript.spell_resolution(
		target, fearful_thoughts, 1, 100
	)
	_expect(
		animated_mental_immunity.get("resisted"),
		"animated targets also ignore Classic mental-class spells"
	)
	target.traits.clear()
	var psionic_spear = load("res://shared_assets/spells/psionic_spear.gd").new()
	var psionic_caster := RogueTestCharacter.new()
	target.level = 4
	psionic_caster.level = 7
	var opposed: Dictionary = MagicResistanceScript.spell_resolution(
		target, psionic_spear, 1, 100, false, psionic_caster, 20
	)
	_expect(opposed.get("resisted"), "Psionic Spear can be stopped by its level contest")
	_expect_equal(opposed.get("reason"), "opposed-level", "level contest reports its reason")
	_expect_equal(opposed.get("opposedChance"), 20, "level contest preserves Classic's formula")
	target.set_meta("classic_hit_dice", 1)
	psionic_caster.set_meta("classic_hit_dice", 1)
	var opposed_hit_dice: Dictionary = MagicResistanceScript.opposed_level_resolution(
		target, psionic_spear, 1, 36, psionic_caster
	)
	_expect_equal(
		opposed_hit_dice.get("chance"),
		35,
		"monster opposed-level checks use preserved Classic hit dice"
	)
	_expect(
		not opposed_hit_dice.get("resisted"),
		"hit-dice contest applies its source chance"
	)
	target.remove_meta("classic_hit_dice")
	psionic_caster.remove_meta("classic_hit_dice")
	target.set_meta("classic_spell_immunities", [0, 0, 0, 0, 0, 1])
	var class_immunity: Dictionary = MagicResistanceScript.spell_resolution(
		target, psionic_spear, 1, 100, false, psionic_caster, 21
	)
	_expect(class_immunity.get("resisted"), "mental spell immunity stops Psionic Spear")
	_expect_equal(
		class_immunity.get("reason"),
		"spell-class-immunity",
		"spell-class immunity remains a complete-resistance stage"
	)
	target.set_meta("classic_spell_immunities", [0, 0, 0, 0, 0, 0])
	var missing_caster: Dictionary = MagicResistanceScript.spell_resolution(
		target, psionic_spear, 1, 100, false, null, 21
	)
	_expect_equal(
		missing_caster.get("status"),
		"error",
		"opposed-level spells do not approximate a missing caster"
	)
	_expect(missing_caster.get("resisted"), "missing opposed-level context fails closed")
	var general_resistance: Dictionary = MagicResistanceScript.spell_resolution(
		target, psionic_spear, 1, 31, false, psionic_caster, 21
	)
	_expect(
		general_resistance.get("resisted"),
		"Psionic Spear checks general resistance after the level contest"
	)
	_expect_equal(
		general_resistance.get("reason"),
		"magic-resistance",
		"general resistance remains a distinct stage"
	)
	var unresisted_psionic: Dictionary = MagicResistanceScript.spell_resolution(
		target, psionic_spear, 1, 32, false, psionic_caster, 21
	)
	_expect(
		not unresisted_psionic.get("resisted"),
		"Psionic Spear proceeds when both complete-resistance checks fail"
	)
	var ignored_spell = load("res://shared_assets/spells/festering_wounds.gd").new()
	_expect(
		MagicResistanceScript.spell_resolution(
			target, ignored_spell, 1, 1
		).get("checksResistance"),
		"Festering Wounds checks Classic magic resistance"
	)
	var native_spell := Spell.new()
	native_spell.resist = Spell.RESIST_TYPE.IGNORE_NOTHING
	var native_resolution: Dictionary = MagicResistanceScript.spell_resolution(
		target, native_spell, 1, 1
	)
	_expect(
		not native_resolution.get("checksResistance"),
		"ordinary native spells do not inherit the Classic resistance contract"
	)
	_expect(
		not native_resolution.get("checksCharmResistance"),
		"the base spell class does not make an ordinary native spell use Classic charm resistance"
	)

	var custom_record := _custom_spell_record(18, 5204)
	custom_record["cannot"] = 0
	custom_record["resistAdjust"] = 2
	var custom_spell = load(
		"res://scripts/classic_runtime/classic_spell_override.gd"
	).new()
	custom_spell.configure(custom_record)
	_expect_equal(
		custom_spell.resist,
		Spell.RESIST_TYPE.IGNORE_DODGE,
		"resistible compiled spell checks Classic magic resistance without native dodge"
	)
	_expect(
		MagicResistanceScript.custom_spell_resolution(
			target, custom_spell, 2, 35
		).get("resisted"),
		"compiler-produced spell applies its resistance adjustment"
	)
	var custom_opposed_record := _custom_spell_record(20, 5206)
	custom_opposed_record["damageType"] = -5
	custom_opposed_record["spellClass"] = 5
	var custom_opposed = load(
		"res://scripts/classic_runtime/classic_spell_override.gd"
	).new()
	custom_opposed.configure(custom_opposed_record)
	_expect(
		custom_opposed.uses_classic_opposed_level_check(),
		"compiled signed damage types opt into the semantic opposed-level rule"
	)
	_expect_equal(
		custom_opposed.classic_raw_damage_type,
		-5,
		"compiled custom spells retain their source encoding"
	)
	var custom_charm_record := _custom_spell_record(19, 5205)
	custom_charm_record["spellClass"] = 0
	custom_charm_record["damageType"] = 0
	custom_charm_record["cannot"] = 0
	var custom_charm = load(
		"res://scripts/classic_runtime/classic_spell_override.gd"
	).new()
	custom_charm.configure(custom_charm_record)
	var custom_charm_resolution: Dictionary = MagicResistanceScript.custom_spell_resolution(
		target, custom_charm, 1, 100, null, 40
	)
	_expect(
		custom_charm_resolution.get("resisted"),
		"compiler-produced class-zero spells use the same early charm resistance"
	)
	_expect_equal(
		custom_charm_resolution.get("reason"),
		"charm-resistance",
		"compiled charm resistance reports the shared reason"
	)
	var custom_field_resolution: Dictionary = (
		GodotAdapterScript.new().classic_custom_spell_target_resolution(
			{"power": 2, "saveAdjustment": 0, "forceAffect": false},
			target,
			custom_spell,
			35,
			100
		)
	)
	_expect(
		custom_field_resolution.get("resisted"),
		"compiler-produced field resolution applies general resistance"
	)
	_expect(
		not custom_field_resolution.get("saved"),
		"compiled general resistance remains distinct from its damage save"
	)
	_expect_equal(
		custom_field_resolution.get("effectScale"),
		0.0,
		"compiled general resistance negates the complete spell"
	)

	var restored_item: Dictionary = MagicResistanceScript.normalize_item_data({
		"imgdata": "",
		"imgdatasize": 0,
		"name": "Saved Ward",
		"type": "Ring",
		"sound": "",
		"equipped": 1,
		"stats": {},
		"classicMagicResistance": 12,
	})
	var saved_item: Dictionary = JSON.parse_string(JSON.stringify(restored_item))
	var loaded_item: Dictionary = MagicResistanceScript.normalize_item_data(saved_item)
	_expect_equal(
		loaded_item.get("classicMagicResistance"),
		12,
		"character save/load preserves Classic item magic resistance"
	)
	_expect_equal(
		loaded_item.get("equipped"),
		1,
		"character save/load preserves the worn state"
	)
	var migrated_item: Dictionary = MagicResistanceScript.normalize_item_data({
		"imgdata": "",
		"imgdatasize": 0,
		"name": "Catalog Ward",
		"type": "Ring",
		"sound": "",
		"stats": {"ClassicMagicResistance": -7},
	})
	_expect_equal(
		migrated_item.get("classicMagicResistance"),
		-7,
		"shared catalog migration retains signed Classic resistance"
	)
	_expect(
		not migrated_item.get("stats", {}).has("ClassicMagicResistance"),
		"Classic resistance stays distinct from native Creature stats"
	)
	var legacy_item: Dictionary = MagicResistanceScript.normalize_item_data(
		{
			"name": "Saved Legacy Ward",
			"stats": {"EvasionMagic": -4, "EvasionMelee": 2},
		},
		{"classicMagicResistance": 5}
	)
	_expect_equal(
		legacy_item.get("classicMagicResistance"),
		-4,
		"pre-contract catalog saves retain their signed resistance value"
	)
	_expect(
		not legacy_item.get("stats", {}).has("EvasionMagic"),
		"pre-contract catalog saves no longer grant native magic evasion"
	)


func _test_classic_spell_save_contract() -> void:
	var target := RogueTestCharacter.new()
	var saves := [-25, -25, 100, 100, 100, 15]
	var immunities := [0, 0, 0, 0, 0, 0]
	SpellSavesScript.apply_monster_metadata(target, saves, immunities)
	_expect_equal(
		target.get_meta("classic_spell_saves"),
		saves,
		"Classic monster save families remain separate compatibility metadata"
	)

	var charm_spell := Spell.new()
	charm_spell.classic_spell_save_index = 0
	charm_spell.classic_spell_save_mode = "negate"
	var charm_resolution: Dictionary = SpellSavesScript.target_resolution(
		target, charm_spell, 1, 1
	)
	_expect_equal(charm_resolution.get("saveChance"), 0.0, "negative Charm save clamps to zero")
	_expect(not charm_resolution.get("saved"), "Charm uses the source save at index zero")

	var mental_spell := Spell.new()
	mental_spell.classic_spell_save_index = 5
	mental_spell.classic_spell_save_mode = "negate"
	var mental_resolution: Dictionary = SpellSavesScript.target_resolution(
		target, mental_spell, 1, 15
	)
	_expect_equal(mental_resolution.get("saveChance"), 15.0, "Mental retains its distinct save")
	_expect(mental_resolution.get("saved"), "Mental uses the source save at index five")
	_expect_equal(
		SpellSavesScript.save_chance_for(target, 7),
		44.0,
		"Classic special saves use the integer average of all six monster saves"
	)
	var native_target := RogueTestCharacter.new()
	native_target.stat_values = {
		"MultiplierMagic": 0.75,
		"ResistanceMagic": 0.0,
		"MultiplierHealing": 1.0,
		"ResistanceHealing": 0.0,
	}
	_expect_equal(
		SpellSavesScript.save_chance_for(native_target, 7),
		50.0,
		"native characters use magical defense for Classic's special save"
	)

	immunities[0] = 1
	SpellSavesScript.apply_monster_metadata(target, saves, immunities)
	_expect_equal(
		SpellSavesScript.save_chance_for(target, 0),
		100.0,
		"a Classic family immunity guarantees its matching save"
	)
	_expect_equal(
		SpellSavesScript.save_chance_for(target, 5),
		15.0,
		"Charm immunity does not leak into the Mental family"
	)
	_expect_equal(
		GodotAdapterScript.new()._classic_spell_save_chance(target, 0),
		100.0,
		"encounter save checks use the same preserved monster contract"
	)


func _custom_spell_record(record_id: int, packed_spell_id: int) -> Dictionary:
	return {
		"id": record_id,
		"packedSpellId": packed_spell_id,
		"displayName": "Test Ember Ward",
		"description": "A compiled custom spell.",
		"range1": 2,
		"range2": 3,
		"fixedTargetNum": 1,
		"canRotate": 1,
		"saveAdjust": 5,
		"saveBonus": 15,
		"cannot": 1,
		"resistAdjust": -3,
		"cost": 4,
		"damage1": 2,
		"damage2": 4,
		"powerDamage1": 1,
		"powerDamage2": 2,
		"duration1": 3,
		"duration2": 5,
		"powerDuration1": 2,
		"powerDuration2": 3,
		"spellLook1": 7,
		"spellLook2": 8,
		"sound1": 11,
		"sound2": 12,
		"targetType": 1,
		"size": 2,
		"special": 0,
		"damageType": 1,
		"spellClass": 2,
		"inCombat": true,
		"inCamp": false,
		"provenance": {
			"sourceFile": "Data Spell",
			"recordIndex": record_id,
		},
	}


func _custom_spell_bundle(record: Dictionary) -> ClassicCampaignBundle:
	var bundle = BundleScript.new()
	bundle.manifest = _minimal_contract_manifest()
	bundle.documents = _minimal_contract_documents()
	bundle.documents["maps"]["maps"] = [{"id": "land:0"}]
	bundle.documents["rules"]["spellOverrides"] = [record]
	bundle.documents["encounters"]["complexEncounters"] = [{
		"id": 7,
		"actions": [],
		"spellIds": [int(record.get("packedSpellId", -1))],
		"spellResults": [3],
	}]
	bundle._build_indexes()
	return bundle


func _readiness_action_point(
	source: String,
	record_index: int,
	raw_code: int,
	reference_id: int
) -> Dictionary:
	return {
		"id": "%s:%d" % [source, record_index],
		"source": source,
		"recordIndex": record_index,
		"levelType": "land",
		"levelIndex": 0,
		"active": true,
		"coordinate": {"x": record_index, "y": 0},
		"actions": [{"slot": 0, "rawCode": raw_code, "id": reference_id}],
	}


func _readiness_has_diagnostic(
	report: Dictionary,
	code: String,
	source: String,
	record_index: int,
	slot: int,
	classification: String
) -> bool:
	for diagnostic_value: Variant in report.get("diagnostics", []):
		if not (diagnostic_value is Dictionary):
			continue
		if (
			str(diagnostic_value.get("code", "")) == code
			and str(diagnostic_value.get("source", "")) == source
			and int(diagnostic_value.get("recordIndex", -1)) == record_index
			and int(diagnostic_value.get("slot", -1)) == slot
			and str(diagnostic_value.get("classification", "")) == classification
		):
			return true
	return false


func _readiness_has_reference_diagnostic(
	report: Dictionary,
	code: String,
	reference_id: int
) -> bool:
	for diagnostic_value: Variant in report.get("diagnostics", []):
		if (
			diagnostic_value is Dictionary
			and str(diagnostic_value.get("code", "")) == code
			and int(diagnostic_value.get("referenceId", -1)) == reference_id
		):
			return true
	return false


func _test_text_and_encounter(bundle) -> void:
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:0:0"), "begin CoB guard-house trigger")
	var text_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(text_result.get("status"), "yield", "text yields to Godot host")
	_expect_equal(text_result.get("command"), "show_text", "text command")
	_expect_equal(text_result.get("payload", {}).get("messageId"), 50, "text message id")
	_expect(
		str(text_result.get("payload", {}).get("message", {}).get("text", "")).begins_with("You enter the guard house"),
		"text message resolves through bundle index"
	)
	var encounter_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(encounter_result.get("command"), "start_encounter", "simple encounter command")
	_expect_equal(encounter_result.get("payload", {}).get("encounterId"), 0, "simple encounter id")
	_expect_equal(
		encounter_result.get("payload", {}).get("promptMessage", {}).get("id"),
		51,
		"simple encounter prompt resolves"
	)
	var outcome_result: Dictionary = interpreter.resume_encounter(4)
	_expect_equal(outcome_result.get("command"), "show_text", "encounter outcome runs selected code block")
	_expect_equal(outcome_result.get("payload", {}).get("messageId"), 61, "fourth outcome starts at slot 24")
	var completed_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(completed_result.get("reason"), "keep-codes", "encounter outcome reaches slot 31")


func _test_teleport(bundle) -> void:
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:0:3"), "begin CoB teleport trigger")
	var result: Dictionary = interpreter.run_until_yield()
	var payload: Dictionary = result.get("payload", {})
	_expect_equal(result.get("command"), "teleport", "teleport command")
	_expect_equal(payload.get("levelIndex"), 5, "teleport level")
	_expect_equal(payload.get("x"), 6, "teleport x")
	_expect_equal(payload.get("y"), 83, "teleport y")
	_expect_equal(payload.get("recheckDestination"), false, "opcode 45 skips destination AP recheck")
	_expect_equal(interpreter.runtime_state.level_index, 5, "runtime position level updated")
	_expect_equal(
		interpreter.resume_teleport().get("reason"),
		"action-point-ended",
		"teleport-only continues the source action point"
	)


func _test_teleport_recheck() -> void:
	var bundle = BundleScript.new()
	bundle.manifest = {
		"start": {"levelType": "land", "levelIndex": 0, "x": 0, "y": 0},
	}
	bundle.extra_codes_by_id[1] = {"id": 1, "values": [0, 5, 6, 0, 0]}
	bundle.extra_codes_by_id[2] = {"id": 2, "values": [0, 2, 0, 10, 0]}
	bundle.extra_codes_by_id[3] = {"id": 3, "values": [0, 5, 6, 0, 0]}
	bundle.messages_by_id[200] = {"id": 200, "text": "Destination"}
	bundle.messages_by_id[201] = {"id": 201, "text": "Source tail"}
	bundle.messages_by_id[202] = {"id": 202, "text": "Returned outer tail"}

	var source := _map_trigger(0, 0, 0, [
		_classic_action(0, 20, 1),
		_classic_action(1, 1, 201),
	])
	var destination := _map_trigger(1, 5, 6, [
		_classic_action(0, 1, 200),
		_classic_action(7, 24, 0),
	])
	_add_map_trigger(bundle, source)
	_add_map_trigger(bundle, destination)

	var interpreter = _interpreter(bundle)
	interpreter.set_percent_roll_provider(func() -> int: return 1)
	_expect(interpreter.begin_trigger(str(source["id"])), "begin rechecking teleport")
	_expect_equal(
		interpreter.run_until_yield().get("command"),
		"teleport",
		"opcode 20 yields its native map transition"
	)
	var destination_result: Dictionary = interpreter.resume_teleport()
	_expect_equal(
		destination_result.get("payload", {}).get("messageId"),
		200,
		"opcode 20 enters the destination action point"
	)
	_expect(
		not _trace_has_action(interpreter.trace, str(source["id"]), 1),
		"destination recheck discards the source action-point tail"
	)
	_expect_equal(
		interpreter.run_until_yield().get("reason"),
		"keep-codes",
		"destination action point controls completion"
	)

	var miss = _interpreter(bundle)
	miss.set_percent_roll_provider(func() -> int: return 100)
	var reduced_destination: Dictionary = destination.duplicate(true)
	reduced_destination["percent"] = 50
	miss.runtime_state.set_action_point_override(str(destination["id"]), reduced_destination)
	_expect(miss.begin_trigger(str(source["id"])), "begin destination percentage miss")
	miss.run_until_yield()
	_expect_equal(
		miss.resume_teleport().get("reason"),
		"teleport-destination-percent-miss",
		"failed destination percentage ends the original action point"
	)
	var moved_destination: Dictionary = destination.duplicate(true)
	moved_destination["coordinate"] = {"x": 7, "y": 8}
	miss.runtime_state.set_action_point_override(str(destination["id"]), moved_destination)
	_expect_equal(
		miss.runtime_state.get_effective_triggers_at(bundle, "land", 0, 5, 6).size(),
		0,
		"a moved action-point override leaves its compiled coordinate"
	)
	_expect_equal(
		miss.runtime_state.get_effective_triggers_at(bundle, "land", 0, 7, 8).size(),
		1,
		"a moved action-point override enters its effective coordinate"
	)

	var outer := _map_trigger(2, 1, 1, [
		_classic_action(0, -46, 2),
		_classic_action(1, 1, 202),
	])
	_add_map_trigger(bundle, outer)
	_add_stack_trigger(bundle, "Data ED3:macro:10", 10, [
		_classic_action(0, 20, 3),
	])
	var returning_destination: Dictionary = destination.duplicate(true)
	returning_destination["actions"] = [_classic_action(0, 111, 0)]
	bundle.triggers_by_id[str(destination["id"])] = returning_destination
	bundle.triggers_by_coordinate["land:0:5:6"] = [returning_destination]
	var stacked = _interpreter(bundle)
	stacked.set_percent_roll_provider(func() -> int: return 1)
	_expect(stacked.begin_trigger(str(outer["id"])), "begin stacked destination recheck")
	_expect_equal(
		stacked.run_until_yield().get("command"),
		"teleport",
		"stacked branch reaches rechecking teleport"
	)
	_expect_equal(stacked.call_stack.size(), 1, "teleport begins with one saved GOSUB frame")
	_expect_equal(
		stacked.resume_teleport().get("payload", {}).get("messageId"),
		202,
		"destination return uses the pre-existing GOSUB frame"
	)


func _test_dungeon_move(bundle) -> void:
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:0:83"), "begin CoB dungeon entrance")
	var enter_result: Dictionary = interpreter.run_until_yield()
	var enter_payload: Dictionary = enter_result.get("payload", {})
	_expect_equal(enter_result.get("command"), "teleport", "dungeon move command")
	_expect_equal(enter_payload.get("levelType"), "dungeon", "dungeon move changes map family")
	_expect_equal(enter_payload.get("levelIndex"), 0, "dungeon entrance level")
	_expect_equal(enter_payload.get("x"), 33, "dungeon entrance x")
	_expect_equal(enter_payload.get("y"), 72, "dungeon entrance y")
	_expect_equal(enter_payload.get("heading"), 2, "dungeon entrance heading")
	_expect_equal(enter_payload.get("multiView"), true, "positive heading enables multiview")
	_expect_equal(interpreter.trace.size(), 1, "dungeon move stops before later AP slots")
	_expect_equal(interpreter.run_until_yield().get("reason"), "action-point-ended", "dungeon move ends AP")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:8:72"), "begin CoB single-view dungeon entrance")
	var single_view: Dictionary = interpreter.run_until_yield().get("payload", {})
	_expect_equal(single_view.get("levelType"), "dungeon", "single-view move enters dungeon")
	_expect_equal(single_view.get("levelIndex"), 1, "single-view dungeon level")
	_expect_equal(single_view.get("heading"), 4, "negative heading is stored as absolute")
	_expect_equal(single_view.get("multiView"), false, "negative heading disables multiview")
	_expect_equal(single_view.get("viewType"), StateScript.VIEW_3D, "negative heading selects fixed view")

	interpreter = _interpreter(bundle)
	interpreter.runtime_state.set_location("dungeon", 0, 32, 72)
	interpreter.runtime_state.set_dungeon_view(3, false)
	_expect(interpreter.begin_trigger("Data DDD:0:1"), "begin CoB dungeon exit")
	var exit_payload: Dictionary = interpreter.run_until_yield().get("payload", {})
	_expect_equal(exit_payload.get("levelType"), "land", "dungeon exit changes map family")
	_expect_equal(exit_payload.get("levelIndex"), 0, "dungeon exit land level")
	_expect_equal(exit_payload.get("x"), 88, "dungeon exit x")
	_expect_equal(exit_payload.get("y"), 48, "dungeon exit y")
	_expect(not exit_payload.has("heading"), "land transfer omits dungeon view metadata")
	_expect_equal(interpreter.runtime_state.heading, 3, "land transfer preserves dormant dungeon heading")


func _test_look_direction(bundle) -> void:
	var interpreter = _interpreter(bundle)
	interpreter.runtime_state.set_location("dungeon", 1, 20, 75)
	_expect(interpreter.begin_trigger("Data DDD:1:75"), "begin CoB fixed look direction")
	var fixed_result: Dictionary = interpreter.run_until_yield()
	var fixed_payload: Dictionary = fixed_result.get("payload", {})
	_expect_equal(fixed_result.get("command"), "set_view_direction", "look direction command")
	_expect_equal(fixed_payload.get("requestedHeading"), 1, "authored look direction")
	_expect_equal(fixed_payload.get("heading"), 1, "fixed look direction result")
	_expect_equal(fixed_payload.get("randomized"), false, "valid look direction is not randomized")
	_expect_equal(interpreter.runtime_state.heading, 1, "look direction updates runtime heading")
	var teleport_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(teleport_result.get("command"), "teleport", "look direction continues to next action")
	_expect_equal(interpreter.runtime_state.heading, 1, "teleport preserves selected heading")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:7:79"), "begin CoB south look direction")
	var south_payload: Dictionary = interpreter.run_until_yield().get("payload", {})
	_expect_equal(south_payload.get("heading"), 3, "second authored look direction")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:7:76"), "begin CoB random look direction")
	var random_payload: Dictionary = interpreter.run_until_yield().get("payload", {})
	_expect_equal(random_payload.get("requestedHeading"), -1, "random look direction sentinel")
	_expect_equal(random_payload.get("randomized"), true, "invalid direction requests random heading")
	_expect(
		int(random_payload.get("heading", 0)) >= 1 and int(random_payload.get("heading", 0)) <= 4,
		"random look direction stays within Classic's four headings"
	)


func _test_view_modes_and_darkland(bundle) -> void:
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:7:72", 1), "begin CoB compass-off action")
	var compass_off: Dictionary = interpreter.run_until_yield()
	_expect_equal(compass_off.get("command"), "set_view_mode", "compass-off command")
	_expect_equal(compass_off.get("payload", {}).get("compassEnabled"), false, "compass disabled")
	_expect_equal(compass_off.get("payload", {}).get("warningId"), 99, "compass-off warning")
	_expect_equal(compass_off.get("payload", {}).get("redraw"), "walls", "compass redraws walls")
	_expect_equal(interpreter.runtime_state.compass_enabled, false, "compass state updated")
	_expect_equal(interpreter.run_until_yield().get("reason"), "keep-codes", "compass action continues")

	_expect(interpreter.begin_trigger("Data DD:7:73"), "begin CoB compass-on action")
	var compass_on: Dictionary = interpreter.run_until_yield()
	_expect_equal(compass_on.get("payload", {}).get("compassEnabled"), true, "compass enabled")
	_expect_equal(compass_on.get("payload", {}).get("warningId"), 98, "compass-on warning")
	_expect_equal(interpreter.runtime_state.compass_enabled, true, "enabled compass persists")

	_expect(interpreter.begin_trigger("Data DD:7:85"), "begin CoB allow-map action")
	var allow_map: Dictionary = interpreter.run_until_yield()
	_expect_equal(allow_map.get("command"), "set_view_mode", "allow-map command")
	_expect_equal(allow_map.get("payload", {}).get("multiView"), true, "allow map enables multiview")
	_expect_equal(allow_map.get("payload", {}).get("viewType"), StateScript.VIEW_3D, "allow map preserves current view")
	_expect_equal(allow_map.get("payload", {}).get("warningId"), 96, "allow-map warning")

	_expect(interpreter.begin_trigger("Data DD:7:84"), "begin CoB require-3D action")
	var require_3d: Dictionary = interpreter.run_until_yield()
	_expect_equal(require_3d.get("payload", {}).get("multiView"), false, "require 3D disables multiview")
	_expect_equal(require_3d.get("payload", {}).get("viewType"), StateScript.VIEW_3D, "require 3D selects 3D view")
	_expect_equal(require_3d.get("payload", {}).get("warningId"), 97, "require-3D warning")

	interpreter.runtime_state.view_type = StateScript.VIEW_MAP
	_expect(interpreter.begin_trigger("Data DD:7:84"), "begin require-3D from map view")
	var leave_map: Dictionary = interpreter.run_until_yield()
	_expect_equal(leave_map.get("payload", {}).get("previousViewType"), StateScript.VIEW_MAP, "map view uses signed Classic state")
	_expect_equal(leave_map.get("payload", {}).get("viewType"), StateScript.VIEW_3D, "map view returns to 3D")
	_expect_equal(leave_map.get("payload", {}).get("warningId"), 0, "unchanged multiview has no warning")

	interpreter = _interpreter(bundle)
	interpreter.runtime_state.set_location("land", 4, 87, 27)
	_expect_equal(bundle.get_random_level("land", 4).get("isDark"), false, "fixture random-level baseline")
	_expect(interpreter.begin_trigger("Data DD:4:43", 1), "begin unchanged CoB darkland action")
	var unchanged_darkland: Dictionary = interpreter.run_until_yield()
	_expect_equal(unchanged_darkland.get("status"), "completed", "unchanged darkland completes")
	_expect_equal(unchanged_darkland.get("reason"), "darkland-unchanged", "unchanged darkland stops action point")
	_expect_equal(interpreter.trace.size(), 1, "unchanged darkland skips later text")

	_expect(interpreter.begin_trigger("Data DD:4:46", 2), "begin CoB darken-land action")
	var darken: Dictionary = interpreter.run_until_yield()
	_expect_equal(darken.get("command"), "set_map_darkness", "darkland command")
	_expect_equal(darken.get("payload", {}).get("previousDarkness"), 0, "darkland uses random-level baseline")
	_expect_equal(darken.get("payload", {}).get("darkness"), 1, "darkland stores authored value")
	_expect_equal(darken.get("payload", {}).get("dark"), true, "darkland adapter flag")
	_expect_equal(interpreter.runtime_state.get_darkland("land", 4, 0), 1, "darkness persists by map")
	var dark_text: Dictionary = interpreter.run_until_yield()
	_expect_equal(dark_text.get("payload", {}).get("messageId"), 849, "darkland continues to authored text")

	_expect(interpreter.begin_trigger("Data DD:4:43", 1), "begin CoB lighten-land action")
	var lighten: Dictionary = interpreter.run_until_yield()
	_expect_equal(lighten.get("payload", {}).get("previousDarkness"), 1, "lightland sees runtime override")
	_expect_equal(lighten.get("payload", {}).get("darkness"), 0, "lightland clears darkness")
	var light_text: Dictionary = interpreter.run_until_yield()
	_expect_equal(light_text.get("payload", {}).get("messageId"), -848, "lightland keeps authored text mode")
	_expect_equal(light_text.get("payload", {}).get("message", {}).get("id"), 848, "lightland resolves authored text")


func _test_random_level_mutations(bundle) -> void:
	var baseline: Dictionary = bundle.get_random_rectangle("land", 1, 17)
	_expect_equal(baseline.get("percent"), 0, "random rectangle fixture baseline percent")
	_expect_equal(
		baseline.get("battleRange", []).map(func(value: Variant) -> int: return int(value)),
		[158, 162],
		"random rectangle fixture battle range"
	)

	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:1:30", 3), "begin CoB random rectangle action")
	var rectangle_result: Dictionary = interpreter.run_until_yield()
	var rectangle_payload: Dictionary = rectangle_result.get("payload", {})
	_expect_equal(rectangle_result.get("command"), "set_random_encounter_rect", "random rectangle command")
	_expect_equal(rectangle_payload.get("levelType"), "land", "land rectangle target type")
	_expect_equal(rectangle_payload.get("levelIndex"), 1, "land rectangle target level")
	_expect_equal(rectangle_payload.get("rectIndex"), 17, "land rectangle target index")
	_expect_equal(
		rectangle_payload.get("previousRectangle", {}).get("battleRange", []).map(
			func(value: Variant) -> int: return int(value)
		),
		[158, 162],
		"random rectangle reports previous battle range"
	)
	_expect_equal(rectangle_payload.get("rectangle", {}).get("percent"), 900, "random rectangle percent")
	_expect_equal(
		rectangle_payload.get("rectangle", {}).get("battleRange"),
		[158, 163],
		"random rectangle updates authored battle high"
	)
	_expect_equal(
		interpreter.runtime_state.get_random_rectangle("land", 1, 17, {}).get("percent"),
		900,
		"random rectangle persists by map and index"
	)
	_expect_equal(
		bundle.get_random_rectangle("land", 1, 17),
		baseline,
		"random rectangle leaves bundle immutable"
	)

	interpreter = _interpreter(bundle)
	interpreter.runtime_state.set_location("land", 0, 0, 0)
	interpreter.runtime_state.set_darkland("land", 0, 1)
	_expect(interpreter.begin_trigger("Data ED3:macro:163", 1), "begin CoB land-look action")
	var landlook_result: Dictionary = interpreter.run_until_yield()
	var landlook_payload: Dictionary = landlook_result.get("payload", {})
	_expect_equal(landlook_result.get("command"), "set_land_look", "land-look command")
	_expect_equal(landlook_payload.get("previousLandlook"), 0, "land-look uses random-level baseline")
	_expect_equal(landlook_payload.get("landlook"), 10, "land-look stores authored visual set")
	_expect_equal(landlook_payload.get("previousDarkness"), 1, "land-look reports previous darkness")
	_expect_equal(landlook_payload.get("darkness"), 0, "land-look stores authored darkness")
	_expect_equal(landlook_payload.get("redraw"), "center", "land context redraws center view")
	_expect_equal(interpreter.runtime_state.get_landlook("land", 0, -1), 10, "land-look persists by map")
	_expect_equal(interpreter.runtime_state.get_darkland("land", 0, -1), 0, "land-look persists darkness")
	var winter_text: Dictionary = interpreter.run_until_yield()
	_expect_equal(winter_text.get("payload", {}).get("messageId"), 867, "land-look continues to authored text")

	interpreter = _interpreter(bundle)
	interpreter.runtime_state.set_location("dungeon", 0, 0, 0)
	interpreter.begin_trigger("Data ED3:macro:163", 1)
	_expect_equal(
		interpreter.run_until_yield().get("payload", {}).get("redraw"),
		"none",
		"dungeon context defers land redraw"
	)

	var synthetic_bundle = _random_level_mutation_test_bundle()
	interpreter = _interpreter(synthetic_bundle)
	_expect(interpreter.begin_trigger("random:dungeon"), "begin dungeon random rectangle action")
	var dungeon_result: Dictionary = interpreter.run_until_yield()
	var dungeon_payload: Dictionary = dungeon_result.get("payload", {})
	_expect_equal(dungeon_payload.get("levelType"), "dungeon", "negative opcode selects dungeon data")
	_expect_equal(dungeon_payload.get("rectangle", {}).get("percent"), 250, "dungeon rectangle percent")
	_expect_equal(
		dungeon_payload.get("rectangle", {}).get("battleRange"),
		[10, 20],
		"negative battle ids preserve existing range"
	)
	_expect_equal(interpreter.trace[0].get("code"), -23, "dungeon opcode remains signed in trace")
	_expect_equal(interpreter.run_until_yield().get("reason"), "keep-codes", "dungeon mutation continues")

	interpreter = _interpreter(synthetic_bundle)
	_expect(interpreter.begin_trigger("random:missing"), "begin unused random rectangle action")
	var missing_payload: Dictionary = interpreter.run_until_yield().get("payload", {})
	_expect_equal(missing_payload.get("rectIndex"), 18, "unused fixed rectangle index")
	_expect_equal(missing_payload.get("previousRectangle", {}).get("percent"), 0, "unused rectangle baseline percent")
	_expect_equal(missing_payload.get("rectangle", {}).get("battleRange"), [0, 0], "unused rectangle baseline range")


func _test_classic_map_bridge() -> void:
	var bundle = BundleScript.new()
	bundle.documents["assets"] = {
		"catalog": {
			"tilesets": [{"id": "landlook-6", "landlook": 6}],
		},
	}
	bundle.maps_by_id["land:0"] = {
		"id": "land:0",
		"levelType": "land",
		"index": 0,
		"width": 2,
		"height": 2,
		"tiles": [1, 2, 3, 4],
	}
	bundle.maps_by_id["dungeon:1"] = {
		"id": "dungeon:1",
		"levelType": "dungeon",
		"index": 1,
		"width": 2,
		"height": 2,
		"tiles": [0, 0x0101, 0, 0],
	}
	var bridge = MapBridgeScript.new()
	bridge.configure(bundle)
	_expect_equal(bridge.native_map_name("land", 3), "map_3", "land map uses native map naming")
	_expect_equal(
		bridge.native_map_name("dungeon", 2),
		"mapd_2",
		"dungeon map uses native map naming"
	)

	var forest_tiles: Array = [
		{"tileset_name": "ForestDay", "id": 0, "name": "grass"},
		{"tileset_name": "ForestDay", "id": 1, "name": "wall"},
		{"tileset_name": "ForestDay", "id": 2, "name": "water"},
		{"tileset_name": "ForestDay", "id": 3, "name": "sand"},
	]
	var snow_tiles: Array = [
		{"tileset_name": "SnowDay", "id": 0, "name": "snow grass"},
		{"tileset_name": "SnowDay", "id": 1, "name": "snow wall"},
		{"tileset_name": "SnowDay", "id": 2, "name": "ice"},
		{"tileset_name": "SnowDay", "id": 3, "name": "snow sand"},
	]
	var custom_tiles: Array = [
		{"tileset_name": "landlook-6", "id": 0, "name": "custom grass"},
		{"tileset_name": "landlook-6", "id": 1, "name": "custom wall"},
		{"tileset_name": "landlook-6", "id": 2, "name": "custom water"},
		{"tileset_name": "landlook-6", "id": 3, "name": "custom sand"},
	]
	var overlay_tile := {"tileset_name": "Overlay", "id": 0, "name": "tree"}
	var dungeon_floor := {
		"tileset_name": "ClassicDungeon",
		"id": 0,
		"name": "classic_dungeon_0000",
		"classicDungeonField": 0,
		"wall": 0,
	}
	var north_secret := {
		"tileset_name": "ClassicDungeon",
		"id": 1,
		"name": "classic_dungeon_0101",
		"classicDungeonField": 0x0101,
		"wall": 1,
	}
	var revealed_north_secret := {
		"tileset_name": "ClassicDungeon",
		"id": 2,
		"name": "classic_dungeon_0141",
		"classicDungeonField": 0x0141,
		"wall": 1,
	}
	var land_map: Array = [
		[[forest_tiles[0], overlay_tile], [forest_tiles[1]]],
		[[forest_tiles[2]], [forest_tiles[3]]],
	]
	var land_areas: Dictionary = {
		"AP4x1y1": {
			"scriptRectangle": [[1, 1], [1, 1]],
			"scriptToLoad": "AP4x1y1",
		},
		"LRR0.2": {
			"scriptRectangle": [[0, 0], [1, 1]],
			"chance": 0.1,
			"scriptToLoad": [],
			"RR_Battle": {"battle_range": [1, 2]},
		},
	}
	var resources = MapBridgeTestResources.new()
	resources.tiles_book["ForestDay.json"] = forest_tiles
	resources.tiles_book["SnowDay.json"] = snow_tiles
	resources.tiles_book["landlook-6.json"] = custom_tiles
	resources.tiles_book["ClassicDungeon.json"] = [
		dungeon_floor,
		north_secret,
		revealed_north_secret,
	]
	resources.maps_book["map_0"] = [
		land_map,
		{"ScriptRects": land_areas, "Paths": [], "Secrets": []},
		null,
		"Outdoor",
		"Forest",
		true,
		7,
		false,
		[],
	]
	resources.maps_book["mapd_1"] = [
		[
			[[dungeon_floor], [dungeon_floor]],
			[[north_secret], [dungeon_floor]],
		],
		{"ScriptRects": {}, "Paths": [], "Secrets": []},
		null,
		"Indoor",
		"Indoor",
		false,
		7,
		true,
		[],
	]
	var game_global = MapBridgeTestGameGlobal.new()
	var same_map: Dictionary = bridge.transition({
		"levelType": "land",
		"levelIndex": 0,
		"x": 1,
		"y": 0,
		"recheckDestination": true,
	}, game_global, resources)
	_expect_equal(same_map.get("nativeMapName"), "map_0", "map bridge resolves a land destination")
	_expect(not bool(same_map.get("mapChanged")), "same-map teleport does not reload the native map")
	_expect_equal(
		game_global.map.focuscharacter.tile_position,
		Vector2(1, 0),
		"same-map teleport moves native map focus"
	)
	_expect_equal(
		game_global.map.explored_position,
		Vector2(1, 0),
		"same-map teleport updates native exploration"
	)
	_expect(bool(same_map.get("recheckDestination")), "map bridge preserves destination recheck intent")
	_expect_equal(game_global.map.redraw_count, 1, "same-map teleport redraws visible native output")
	var reload_game_global = MapBridgeTestGameGlobal.new()
	var forced_reload: Dictionary = bridge.transition({
		"levelType": "land",
		"levelIndex": 0,
		"x": 1,
		"y": 0,
		"forceReload": true,
	}, reload_game_global, resources)
	_expect(bool(forced_reload.get("mapChanged")), "saved-map resume forces a native map reload")
	_expect_equal(
		reload_game_global.transitions,
		[["map_0", 1, 0]],
		"forced saved-map reload uses the normal native transition"
	)

	var dungeon_move: Dictionary = bridge.transition({
		"levelType": "dungeon",
		"levelIndex": 1,
		"x": 0,
		"y": 0,
	}, game_global, resources)
	_expect(bool(dungeon_move.get("mapChanged")), "land-to-dungeon transition changes native maps")
	_expect_equal(
		game_global.transitions,
		[["mapd_1", 0, 0]],
		"map bridge delegates transitions to GameGlobal.change_map"
	)

	var redraws_before: int = game_global.map.redraw_count
	var view_result: Dictionary = bridge.redraw_view({
		"heading": 3,
		"multiView": true,
		"viewType": StateScript.VIEW_MAP,
		"compassEnabled": false,
	}, game_global)
	_expect_equal(view_result.get("heading"), 3, "native view refresh preserves Classic heading")
	_expect_equal(
		game_global.map.redraw_count,
		redraws_before + 1,
		"Classic view changes redraw the native map"
	)

	var darkness: Dictionary = bridge.set_darkness({
		"levelType": "dungeon",
		"levelIndex": 1,
		"dark": true,
	}, game_global, resources)
	_expect_equal(darkness.get("nativeDarkness"), 0, "Classic darkness maps to native full darkness")
	_expect_equal(game_global.map.darkness_level, 0, "current native map receives darkness change")
	_expect_equal(resources.maps_book["mapd_1"][6], 0, "native darkness survives a map reload")

	var movement_state = StateScript.new()
	movement_state.set_location("dungeon", 1, 1, 1)
	var north_entry: Dictionary = bridge.resolve_dungeon_movement(
		movement_state,
		Vector2i(1, 1),
		Vector2i(1, 0),
		game_global,
		resources
	)
	_expect(bool(north_entry.get("handled")), "directional dungeon secret uses Classic movement")
	_expect(bool(north_entry.get("allowed")), "matching north entry passes the dungeon secret")
	_expect(bool(north_entry.get("revealed")), "first matching entry reveals the dungeon secret")
	_expect_equal(north_entry.get("movementTime"), 5, "secret entry uses normal dungeon step time")
	_expect_equal(
		MapBridgeScript.DUNGEON_DIRECTION_BY_DELTA.get(Vector2i(1, 0)),
		0x0200,
		"east movement resolves the Classic east entry bit"
	)
	_expect_equal(
		MapBridgeScript.DUNGEON_DIRECTION_BY_DELTA.get(Vector2i(0, 1)),
		0x0400,
		"south movement resolves the Classic south entry bit"
	)
	_expect_equal(
		MapBridgeScript.DUNGEON_DIRECTION_BY_DELTA.get(Vector2i(-1, 0)),
		0x0800,
		"west movement resolves the Classic west entry bit"
	)
	_expect_equal(
		movement_state.get_tile("dungeon", 1, 1, 0, -1),
		0x0141,
		"dungeon secret reveal persists in Classic map state"
	)
	_expect_equal(
		resources.maps_book["mapd_1"][0][1][0],
		[revealed_north_secret],
		"dungeon secret reveal swaps in the generated native visual"
	)
	var wrong_entry: Dictionary = bridge.resolve_dungeon_movement(
		movement_state,
		Vector2i(0, 0),
		Vector2i(1, 0),
		game_global,
		resources
	)
	_expect(bool(wrong_entry.get("handled")), "wrong-direction secret entry remains handled")
	_expect(not bool(wrong_entry.get("allowed")), "wrong-direction secret entry is blocked")
	_expect_equal(
		wrong_entry.get("message"),
		MapBridgeScript.DUNGEON_SECRET_BLOCKED_MESSAGE,
		"wrong-direction secret entry returns the Classic warning"
	)
	var repeated_north_entry: Dictionary = bridge.resolve_dungeon_movement(
		movement_state,
		Vector2i(1, 1),
		Vector2i(1, 0),
		game_global,
		resources
	)
	_expect(bool(repeated_north_entry.get("allowed")), "revealed secret retains its entry rule")
	_expect(
		not bool(repeated_north_entry.get("revealed")),
		"revealed secret is not recorded as a second discovery"
	)
	movement_state.set_tile("dungeon", 1, 1, 0, 0x1101)
	var action_point_entry: Dictionary = bridge.resolve_dungeon_movement(
		movement_state,
		Vector2i(0, 0),
		Vector2i(1, 0),
		game_global,
		resources
	)
	_expect(
		not bool(action_point_entry.get("handled")),
		"Classic Action Point exception remains passable from another direction"
	)

	var tile_result: Dictionary = bridge.set_tile({
		"levelType": "land",
		"levelIndex": 0,
		"x": 0,
		"y": 0,
		"tileValue": 4,
	}, game_global, resources)
	_expect_equal(tile_result.get("sourceCell"), Vector2i(1, 1), "tile bridge finds a native reference cell")
	_expect_equal(
		resources.maps_book["map_0"][0][0][0],
		[forest_tiles[3]],
		"tile mutation updates the native map resource"
	)
	bridge.set_tile({
		"levelType": "land",
		"levelIndex": 0,
		"x": 1,
		"y": 1,
		"tileValue": 1,
	}, game_global, resources)
	_expect_equal(
		resources.maps_book["map_0"][0][1][1],
		[forest_tiles[0], overlay_tile],
		"tile projection retains an immutable native reference palette"
	)

	var landlook_result: Dictionary = bridge.set_land_look({
		"levelType": "land",
		"levelIndex": 0,
		"landlook": 10,
		"dark": false,
	}, game_global, resources)
	_expect_equal(landlook_result.get("nativeTileset"), "SnowDay", "stock landlook resolves its native tileset")
	_expect(bool(landlook_result.get("tilesetChanged")), "landlook changes native base tiles")
	_expect_equal(landlook_result.get("changedTiles"), 4, "landlook changes every native land tile")
	_expect_equal(
		resources.maps_book["map_0"][0][1][1],
		[snow_tiles[0], overlay_tile],
		"landlook changes preserve non-landlook overlays"
	)
	bridge.set_tile({
		"levelType": "land",
		"levelIndex": 0,
		"x": 0,
		"y": 0,
		"tileValue": 2,
	}, game_global, resources)
	_expect_equal(
		resources.maps_book["map_0"][0][0][0],
		[snow_tiles[2]],
		"landlook changes update the immutable tile-mutation palette"
	)
	var custom_landlook: Dictionary = bridge.set_land_look({
		"levelType": "land",
		"levelIndex": 0,
		"landlook": 6,
		"dark": false,
	}, game_global, resources)
	_expect_equal(
		custom_landlook.get("nativeTileset"),
		"landlook-6",
		"custom landlook resolves a producer-installed catalog tileset"
	)
	_expect_equal(
		resources.maps_book["map_0"][0][0][0],
		[custom_tiles[2]],
		"custom landlook replaces the native base tile"
	)
	resources.tiles_book["Swamp.json"] = [
		{"tileset_name": "Swamp", "id": 0, "name": "swamp grass"},
	]
	var incomplete_landlook: Dictionary = bridge.set_land_look({
		"levelType": "land",
		"levelIndex": 0,
		"landlook": 9,
		"dark": false,
	}, game_global, resources)
	_expect_equal(
		incomplete_landlook.get("status"),
		"skipped",
		"landlook refuses an incomplete native tileset"
	)
	_expect_equal(
		resources.maps_book["map_0"][0][0][0],
		[custom_tiles[2]],
		"incomplete landlook does not partially change the native map"
	)

	var trigger_result: Dictionary = bridge.set_trigger_percent({
		"levelType": "land",
		"levelIndex": 0,
		"triggerIds": [4],
		"percent": 35,
	}, game_global, resources)
	_expect_equal(trigger_result.get("updatedAreas"), ["AP4x1y1"], "trigger bridge finds native AP areas")
	_expect_equal(land_areas["AP4x1y1"]["chance"], 0.35, "trigger bridge applies authored percent")

	var rectangle_result: Dictionary = bridge.set_random_rectangle({
		"levelType": "land",
		"levelIndex": 0,
		"rectIndex": 2,
		"rectangle": {
			"left": 2,
			"top": 3,
			"right": 8,
			"bottom": 9,
			"percent": 2500,
			"battleRange": [10, 12],
		},
	}, game_global, resources)
	_expect_equal(rectangle_result.get("updatedArea"), "LRR0.2", "random rectangle resolves its native area")
	_expect_equal(land_areas["LRR0.2"]["chance"], 0.25, "random rectangle applies native chance")
	_expect_equal(
		land_areas["LRR0.2"]["scriptRectangle"],
		[[2, 3], [8, 9]],
		"random rectangle applies native bounds"
	)
	_expect_equal(
		land_areas["LRR0.2"]["RR_Battle"]["battle_range"],
		[10, 12],
		"random rectangle applies native battle range"
	)

	var runtime_state = StateScript.new()
	runtime_state.set_darkland("land", 0, 1)
	runtime_state.set_landlook("land", 0, 10)
	runtime_state.set_random_rectangle("land", 0, 2, {
		"left": 0,
		"top": 1,
		"right": 1,
		"bottom": 1,
		"percent": 5000,
		"battleRange": [20, 22],
	})
	runtime_state.set_action_point_override("Data DD:0:4", {
		"id": "Data DD:0:4",
		"levelType": "land",
		"levelIndex": 0,
		"recordIndex": 4,
		"coordinate": {"x": 0, "y": 1},
		"percent": 80,
		"actions": [],
	})
	runtime_state.set_trigger_percent("land", 0, 4, 35)
	runtime_state.set_tile("land", 0, 0, 0, 4)
	land_areas = {
		"AP4x1y1": {
			"scriptRectangle": [[1, 1], [1, 1]],
			"scriptToLoad": "AP4x1y1",
		},
		"LRR0.2": {
			"scriptRectangle": [[0, 0], [1, 1]],
			"chance": 0.1,
			"scriptToLoad": [],
			"RR_Battle": {"battle_range": [1, 2]},
		},
	}
	resources.maps_book["map_0"] = [
		[
			[[forest_tiles[0], overlay_tile], [forest_tiles[1]]],
			[[forest_tiles[2]], [forest_tiles[3]]],
		],
		{"ScriptRects": land_areas, "Paths": [], "Secrets": []},
		null,
		"Outdoor",
		"Forest",
		true,
		7,
		false,
		[],
	]
	var replay: Dictionary = bridge.reapply_persistent_state(
		runtime_state,
		game_global,
		resources
	)
	_expect_equal(replay.get("status"), "ok", "persistent map replay succeeds")
	_expect_equal(replay.get("errors"), [], "persistent map replay has no errors")
	_expect_equal(
		replay.get("applied"),
		{
			"darkness": 1,
			"landLooks": 1,
			"randomRectangles": 1,
			"actionPoints": 1,
			"triggerPercents": 1,
			"tiles": 1,
		},
		"persistent map replay reports every mutation family"
	)
	_expect_equal(resources.maps_book["map_0"][6], 0, "replay restores map darkness")
	_expect_equal(
		resources.maps_book["map_0"][0][0][0],
		[snow_tiles[3]],
		"replay restores a changed tile after native resource reload"
	)
	_expect(not land_areas.has("AP4x1y1"), "replay removes the Action Point's old rectangle")
	_expect(land_areas.has("AP4x0y1"), "replay projects the moved Action Point rectangle")
	_expect_equal(
		land_areas["AP4x0y1"]["scriptToLoad"],
		"Data DD:0:4",
		"replayed Action Point uses its stable Classic trigger ID"
	)
	_expect_equal(
		land_areas["AP4x0y1"]["chance"],
		0.35,
		"replay applies the effective trigger percent after moving the area"
	)
	_expect_equal(land_areas["LRR0.2"]["chance"], 0.5, "replay restores random chance")
	_expect_equal(
		land_areas["LRR0.2"]["RR_Battle"]["battle_range"],
		[20, 22],
		"replay restores random battle range"
	)
	var repeated_replay: Dictionary = bridge.reapply_persistent_state(
		runtime_state,
		game_global,
		resources
	)
	_expect_equal(repeated_replay.get("status"), "ok", "persistent map replay is repeatable")
	var replayed_action_point_count := 0
	for replayed_area_name: Variant in land_areas:
		if str(replayed_area_name).begins_with("AP4"):
			replayed_action_point_count += 1
	_expect_equal(
		replayed_action_point_count,
		1,
		"repeated replay keeps one effective Action Point area"
	)

	var missing: Dictionary = bridge.transition({
		"levelType": "land",
		"levelIndex": 9,
		"x": 0,
		"y": 0,
	}, game_global, resources)
	_expect_equal(missing.get("status"), "error", "map bridge rejects a missing native map")


func _test_experience_award(bundle) -> void:
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:1:30", 4), "begin CoB experience award")
	var experience_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(experience_result.get("command"), "give_experience", "experience command")
	_expect_equal(
		experience_result.get("payload", {}).get("experience"),
		1500,
		"experience command preserves the authored total"
	)
	var completed: Dictionary = interpreter.run_until_yield()
	_expect_equal(completed.get("status"), "completed", "experience sequence completes")
	_expect_equal(completed.get("reason"), "action-point-ended", "experience sequence falls through")
	var patched_target: Dictionary = interpreter.runtime_state.get_action_point_override("Data DD:1:31")
	_expect_equal(
		patched_target.get("actions", [])[0].get("id"),
		522,
		"experience sequence continues to its source-backed action-point patch"
	)
	_expect_equal(
		bundle.get_trigger("Data DD:1:31").get("actions", [])[0].get("code"),
		24,
		"experience sequence leaves the compiled target immutable"
	)


func _test_party_health_effect(bundle) -> void:
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data ED3:macro:142"), "begin CoB party damage action")
	var damage_result: Dictionary = interpreter.run_until_yield()
	var payload: Dictionary = damage_result.get("payload", {})
	_expect_equal(damage_result.get("command"), "change_party_health", "party health command")
	_expect_equal(payload.get("multiplier"), -1, "party damage multiplier")
	_expect_equal(payload.get("rollRange"), [1, 1], "party damage roll range")
	_expect_equal(payload.get("soundId"), 699, "party damage sound")
	_expect_equal(payload.get("messageId"), 0, "party damage optional message")
	_expect_equal(payload.get("message"), {}, "zero party-health message id is a sentinel")
	_expect_equal(
		interpreter.run_until_yield().get("reason"),
		"action-point-ended",
		"party damage action point completes"
	)

	var adapter = GodotAdapterScript.new()
	var first_target := RogueTestCharacter.new()
	var second_target := RogueTestCharacter.new()
	var fixed_result: Dictionary = adapter.apply_party_health_effect(
		payload,
		[first_target, second_target]
	)
	_expect_equal(fixed_result.get("hits", []).size(), 2, "party damage affects every member")
	_expect_equal(first_target.current_hp, 29, "fixed party damage affects first member")
	_expect_equal(second_target.current_hp, 29, "fixed party damage affects second member")

	var variable_target := RogueTestCharacter.new()
	adapter.apply_party_health_effect(
		{"multiplier": -2, "rollRange": [1, 3]},
		[variable_target]
	)
	_expect(
		variable_target.current_hp >= 24 and variable_target.current_hp <= 28,
		"party damage uses an inclusive per-character roll"
	)
	var healing_target := RogueTestCharacter.new()
	healing_target.current_hp = 10
	adapter.apply_party_health_effect(
		{"multiplier": 2, "rollRange": [3, 3]},
		[healing_target]
	)
	_expect_equal(healing_target.current_hp, 16, "positive multiplier heals party members")


func _test_selected_character_pipeline(bundle) -> void:
	var pick_interpreter = _interpreter(bundle)
	_expect(
		pick_interpreter.begin_trigger("Data DD:7:54", 3),
		"begin CoB single-character pick"
	)
	var pick_result: Dictionary = pick_interpreter.run_until_yield()
	var pick_payload: Dictionary = pick_result.get("payload", {})
	_expect_equal(pick_result.get("command"), "pick_characters", "character-pick command")
	_expect_equal(pick_payload.get("count"), 1, "character-pick count")
	_expect_equal(pick_payload.get("allowDead"), false, "positive pick excludes dead characters")
	_expect_equal(pick_payload.get("invert"), false, "positive pick keeps chosen characters")
	_expect_equal(
		pick_interpreter.run_until_yield().get("payload", {}).get("messageId"),
		-506,
		"character pick continues to its source message"
	)

	var inverse_interpreter = _interpreter(bundle)
	_expect(
		inverse_interpreter.begin_trigger("Data DD:6:12", 5),
		"begin CoB inverse-character pick"
	)
	var inverse_result: Dictionary = inverse_interpreter.run_until_yield()
	var inverse_payload: Dictionary = inverse_result.get("payload", {})
	_expect_equal(inverse_result.get("command"), "pick_characters", "inverse-pick command")
	_expect_equal(inverse_payload.get("count"), 4, "inverse-pick count")
	_expect_equal(inverse_payload.get("allowDead"), true, "negative pick id allows dead characters")
	_expect_equal(inverse_payload.get("invert"), true, "negative opcode selects the complement")
	_expect_equal(
		inverse_interpreter.run_until_yield().get("payload", {}).get("messageId"),
		450,
		"inverse pick continues to the energy discharge"
	)
	var inverse_damage: Dictionary = inverse_interpreter.run_until_yield()
	var inverse_damage_payload: Dictionary = inverse_damage.get("payload", {})
	_expect_equal(
		inverse_damage.get("command"),
		"change_selected_health",
		"inverse-pick sequence damages its complement"
	)
	_expect_equal(inverse_damage_payload.get("multiplier"), -6, "inverse damage multiplier")
	_expect_equal(inverse_damage_payload.get("rollRange"), [1, 4], "inverse damage range")
	_expect_equal(inverse_damage_payload.get("soundId"), 659, "inverse damage sound")

	var check_interpreter = _interpreter(bundle)
	_expect(
		check_interpreter.begin_trigger("Data DD:7:45", 1),
		"begin CoB Acrobatics selection"
	)
	var check_result: Dictionary = check_interpreter.run_until_yield()
	var check_payload: Dictionary = check_result.get("payload", {})
	_expect_equal(
		check_result.get("command"),
		"filter_selected_characters",
		"character-check command"
	)
	_expect_equal(check_payload.get("checkType"), "special", "Acrobatics check type")
	_expect_equal(check_payload.get("checkIndex"), 5, "Acrobatics Classic index")
	_expect_equal(check_payload.get("modifier"), 30, "Acrobatics modifier")
	_expect_equal(check_payload.get("candidateMode"), "party", "Acrobatics checks party")
	_expect_equal(check_payload.get("selectOnFailure"), false, "positive check selects success")
	var checked_damage: Dictionary = check_interpreter.run_until_yield()
	_expect_equal(
		checked_damage.get("command"),
		"change_selected_health",
		"checked characters receive the following health effect"
	)
	_expect_equal(
		checked_damage.get("payload", {}).get("rollRange"),
		[1, 6],
		"checked damage range"
	)
	_expect_equal(
		check_interpreter.run_until_yield().get("payload", {}).get("messageId"),
		377,
		"checked damage continues to its source message"
	)

	var adapter = GodotAdapterScript.new()
	var first_target := RogueTestCharacter.new()
	first_target.name = "First"
	var second_target := RogueTestCharacter.new()
	second_target.name = "Second"
	var third_target := RogueTestCharacter.new()
	third_target.name = "Third"
	var party := [first_target, second_target, third_target]
	_expect_equal(
		adapter.select_characters_after_pick([first_target, second_target], party, false),
		[first_target, second_target],
		"normal pick keeps chosen party members"
	)
	_expect_equal(
		adapter.select_characters_after_pick([first_target, second_target], party, true),
		[third_target],
		"inverse pick keeps the unchosen party members"
	)

	first_target.stat_value = 100.0
	second_target.stat_value = -100.0
	var checked: Dictionary = adapter.filter_characters_by_check(
		check_payload,
		[first_target, second_target],
		[]
	)
	_expect_equal(checked.get("selected"), [first_target], "special check selects successes")
	var failure_payload := check_payload.duplicate()
	failure_payload["selectOnFailure"] = true
	var failed: Dictionary = adapter.filter_characters_by_check(
		failure_payload,
		[first_target, second_target],
		[]
	)
	_expect_equal(failed.get("selected"), [second_target], "negative check selects failures")
	var attribute_payload := {
		"checkType": "attribute",
		"checkIndex": 1,
		"modifier": 0,
		"candidateMode": "party",
		"selectOnFailure": false,
	}
	var attribute_result: Dictionary = adapter.filter_characters_by_check(
		attribute_payload,
		[first_target, second_target],
		[]
	)
	_expect_equal(
		attribute_result.get("selected"),
		[first_target],
		"attribute check uses the Remake stat mapping"
	)

	var selected_damage: Dictionary = adapter.apply_selected_health_effect(
		{"multiplier": -2, "rollRange": [3, 3]},
		[first_target]
	)
	_expect_equal(selected_damage.get("hits", []).size(), 1, "selected damage has one target")
	_expect_equal(first_target.current_hp, 24, "selected damage changes picked character HP")
	_expect_equal(second_target.current_hp, 30, "selected damage leaves unpicked character alone")
	_expect_equal(
		adapter.apply_selected_health_effect(
			{"multiplier": -1, "rollRange": [1, 1]},
			[]
		).get("hits", []).size(),
		0,
		"empty selected set is a valid no-op"
	)


func _test_misc_character_selection(bundle) -> void:
	var movement_interpreter = _interpreter(bundle)
	_expect(
		movement_interpreter.begin_trigger("Data ED3:macro:67"),
		"begin CoB movement-based rockfall"
	)
	_expect_equal(
		movement_interpreter.run_until_yield().get("payload", {}).get("messageId"),
		-508,
		"movement rockfall starts with its source warning"
	)
	var movement_result: Dictionary = movement_interpreter.run_until_yield()
	var movement_payload: Dictionary = movement_result.get("payload", {})
	_expect_equal(
		movement_result.get("command"),
		"select_characters_by_misc",
		"movement selector command"
	)
	_expect_equal(movement_payload.get("selector"), "movement_below", "movement selector type")
	_expect_equal(movement_payload.get("value"), 10, "movement selector threshold")
	_expect_equal(movement_payload.get("candidateMode"), "party", "movement selector checks party")
	_expect_equal(
		movement_interpreter.run_until_yield().get("command"),
		"change_selected_health",
		"movement-selected characters receive rockfall damage"
	)

	var attribute_interpreter = _interpreter(bundle)
	_expect(
		attribute_interpreter.begin_trigger("Data DD:2:12"),
		"begin CoB attribute-save rockfall"
	)
	_expect_equal(
		attribute_interpreter.run_until_yield().get("payload", {}).get("messageId"),
		560,
		"attribute rockfall starts with its source warning"
	)
	var attribute_result: Dictionary = attribute_interpreter.run_until_yield()
	var attribute_payload: Dictionary = attribute_result.get("payload", {})
	_expect_equal(
		attribute_result.get("command"),
		"select_characters_by_misc",
		"attribute-save selector command"
	)
	_expect_equal(
		attribute_payload.get("selector"),
		"attribute_save_failure",
		"attribute-save selector type"
	)
	_expect_equal(attribute_payload.get("value"), 5, "CoB rockfall preserves selector 5")
	_expect_equal(
		attribute_interpreter.run_until_yield().get("payload", {}).get("rollRange"),
		[2, 8],
		"attribute-save rockfall preserves damage range"
	)

	var first_target := RogueTestCharacter.new()
	first_target.name = "Slow"
	first_target.stat_values = {
		"MaxMovement": 8,
		"Dexterity": 0,
		"MultiplierMental": 1.0,
		"ResistanceMental": 0,
	}
	first_target.inventory = [{"name": "Dagger", "equipped": 0}]
	var second_target := RogueTestCharacter.new()
	second_target.name = "Fast"
	second_target.stat_values = {
		"MaxMovement": 12,
		"Dexterity": 100,
		"MultiplierMental": 0.0,
		"ResistanceMental": 0,
	}
	second_target.inventory = [{"name": "Dagger", "equipped": 1}]
	var third_target := RogueTestCharacter.new()
	third_target.name = "Dead"
	third_target.current_hp = 0
	var party := [first_target, second_target, third_target]
	var adapter = GodotAdapterScript.new()

	var movement_selected: Dictionary = adapter.select_characters_by_misc(
		{"selector": "movement_below", "value": 10, "candidateMode": "party"},
		party,
		[],
		null
	)
	_expect_equal(
		movement_selected.get("selected"),
		[first_target],
		"movement selector picks characters below the authored maximum"
	)
	var attribute_failed: Dictionary = adapter.select_characters_by_misc(
		{"selector": "attribute_save_failure", "value": 5, "candidateMode": "party"},
		[first_target, second_target],
		[],
		null
	)
	_expect_equal(
		attribute_failed.get("selected"),
		[first_target],
		"misc attribute selector picks failed saves"
	)
	var spell_failed: Dictionary = adapter.select_characters_by_misc(
		{"selector": "spell_save_failure", "value": 5, "candidateMode": "party"},
		[first_target, second_target],
		[],
		null
	)
	_expect_equal(
		spell_failed.get("selected"),
		[first_target],
		"misc spell selector picks failed saves"
	)
	var selected_only: Dictionary = adapter.select_characters_by_misc(
		{"selector": "percent", "value": 100, "candidateMode": "selected"},
		party,
		[second_target],
		null
	)
	_expect_equal(
		selected_only.get("selected"),
		[second_target],
		"misc selector can filter the previous selection"
	)
	var alive_only: Dictionary = adapter.select_characters_by_misc(
		{"selector": "percent", "value": 100, "candidateMode": "alive"},
		party,
		[],
		null
	)
	_expect_equal(
		alive_only.get("selected"),
		[first_target, second_target],
		"misc selector can restrict candidates to living characters"
	)
	_expect_equal(
		adapter.select_characters_by_misc(
			{"selector": "position_before", "value": 3, "candidateMode": "party"},
			party,
			[],
			null
		).get("selected"),
		[first_target, second_target],
		"position selector uses Classic's one-based before threshold"
	)
	_expect_equal(
		adapter.select_characters_by_misc(
			{"selector": "exact_position", "value": 3, "candidateMode": "party"},
			party,
			[],
			null
		).get("selected"),
		[third_target],
		"exact-position extension selects one-based party slot"
	)
	_expect_equal(
		adapter.select_characters_by_misc(
			{"selector": "focused_character", "value": 0, "candidateMode": "party"},
			party,
			[],
			second_target
		).get("selected"),
		[second_target],
		"focused-character extension uses the native HUD selection"
	)
	var item_payload := {
		"selector": "has_item",
		"value": 1,
		"candidateMode": "party",
		"itemNames": ["Dagger"],
	}
	_expect_equal(
		adapter.select_characters_by_misc(item_payload, party, [], null).get("selected"),
		[first_target, second_target],
		"item selector matches carried and worn items"
	)
	item_payload["selector"] = "wearing_item"
	_expect_equal(
		adapter.select_characters_by_misc(item_payload, party, [], null).get("selected"),
		[second_target],
		"worn-item extension requires equipped state"
	)


func _test_spell_effect_actions(bundle) -> void:
	var party_interpreter = _interpreter(bundle)
	_expect(
		party_interpreter.begin_trigger("Data DD:8:89"),
		"begin CoB party spell action"
	)
	_expect_equal(
		party_interpreter.run_until_yield().get("payload", {}).get("messageId"),
		698,
		"party spell starts with its source warning"
	)
	var party_result: Dictionary = party_interpreter.run_until_yield()
	var party_payload: Dictionary = party_result.get("payload", {})
	_expect_equal(party_result.get("command"), "cast_classic_spell", "party spell command")
	_expect_equal(party_payload.get("spellId"), 1408, "party spell ID")
	_expect_equal(party_payload.get("power"), 3, "party spell power")
	_expect_equal(party_payload.get("saveAdjustment"), 0, "party spell save adjustment")
	_expect_equal(party_payload.get("forceAffect"), false, "party spell force flag")
	_expect_equal(party_payload.get("targetMode"), "party", "party spell target mode")
	_expect_equal(
		party_interpreter.run_until_yield().get("reason"),
		"keep-codes",
		"party spell keeps its source action point"
	)

	var selected_interpreter = _interpreter(bundle)
	_expect(
		selected_interpreter.begin_trigger("Data ED3:macro:108"),
		"begin CoB selected-character spell"
	)
	_expect_equal(
		selected_interpreter.run_until_yield().get("payload", {}).get("soundId"),
		-692,
		"selected spell preserves its first source sound"
	)
	_expect_equal(
		selected_interpreter.run_until_yield().get("payload", {}).get("soundId"),
		699,
		"selected spell preserves its second source sound"
	)
	var selected_result: Dictionary = selected_interpreter.run_until_yield()
	var selected_payload: Dictionary = selected_result.get("payload", {})
	_expect_equal(
		selected_result.get("command"),
		"cast_classic_spell",
		"selected-character spell command"
	)
	_expect_equal(selected_payload.get("spellId"), 2301, "selected spell ID")
	_expect_equal(selected_payload.get("power"), 1, "selected spell power")
	_expect_equal(selected_payload.get("targetMode"), "selected", "selected spell target mode")

	var adjusted_interpreter = _interpreter(bundle)
	_expect(
		adjusted_interpreter.begin_trigger("Data ED3:macro:128"),
		"begin CoB adjusted selected-character spell"
	)
	var adjusted_payload: Dictionary = \
		adjusted_interpreter.run_until_yield().get("payload", {})
	_expect_equal(adjusted_payload.get("spellId"), 4606, "adjusted spell ID")
	_expect_equal(adjusted_payload.get("power"), 3, "adjusted spell power")
	_expect_equal(adjusted_payload.get("saveAdjustment"), 30, "adjusted spell save modifier")
	_expect_equal(adjusted_payload.get("forceAffect"), false, "adjusted spell force flag")

	var adapter = GodotAdapterScript.new()
	var first_target := RogueTestCharacter.new()
	var second_target := RogueTestCharacter.new()
	_expect_equal(
		adapter.spell_effect_targets("party", [first_target, second_target], [second_target]),
		[first_target, second_target],
		"party spell selects every party member"
	)
	_expect_equal(
		adapter.spell_effect_targets("selected", [first_target, second_target], [second_target]),
		[second_target],
		"selected spell retains the transient picked set"
	)
	_expect_equal(
		adapter.classic_spell_mapping_key(1408),
		"10037",
		"Power Drain ID resolves to Remake's spell-table key"
	)
	_expect_equal(
		adapter.classic_spell_mapping_key(2301),
		"20020",
		"Confuse ID resolves to Remake's spell-table key"
	)
	_expect_equal(
		adapter.classic_spell_mapping_key(3202),
		"30011",
		"Daze ID resolves to Remake's spell-table key"
	)
	_expect_equal(
		adapter.classic_spell_mapping_key(4606),
		"40055",
		"Fire Flare ID resolves to Remake's spell-table key"
	)
	var fire_flare = load("res://shared_assets/spells/fire_flare.gd").new()
	var confuse = load("res://shared_assets/spells/confuse.gd").new()
	var daze = load("res://shared_assets/spells/daze.gd").new()
	first_target.stat_values["MultiplierFire"] = 1.0
	first_target.stat_values["ResistanceFire"] = 0.0
	var adjusted_save: Dictionary = adapter.classic_field_spell_target_resolution(
		{
			"power": 3,
			"saveAdjustment": 30,
			"forceAffect": false,
		},
		first_target,
		fire_flare,
		1,
		90
	)
	_expect_equal(adjusted_save.get("saveChance"), 90.0, "spell save adjustment scales by power")
	_expect(adjusted_save.get("saved"), "a roll at the adjusted chance saves")
	_expect_equal(
		adjusted_save.get("effectScale"),
		0.5,
		"a successful save halves damaging field spells"
	)
	second_target.set_meta("classic_magic_resistance", 100)
	second_target.stat_values["MultiplierFire"] = 1.0
	second_target.stat_values["ResistanceFire"] = 100.0
	var resisted_field_spell: Dictionary = (
		adapter.classic_field_spell_target_resolution(
			{"power": 3, "saveAdjustment": 100, "forceAffect": false},
			second_target,
			fire_flare,
			1,
			1
		)
	)
	_expect(
		resisted_field_spell.get("resisted"),
		"mapped field spell checks general Classic magic resistance"
	)
	_expect(
		not resisted_field_spell.get("saved"),
		"general field resistance remains distinct from the damage save"
	)
	_expect_equal(
		resisted_field_spell.get("effectScale"),
		0.0,
		"general field resistance negates the complete spell"
	)
	var failed_save: Dictionary = adapter.classic_field_spell_target_resolution(
		{"power": 3, "saveAdjustment": 0, "forceAffect": false},
		first_target,
		fire_flare,
		1,
		1
	)
	_expect(not failed_save.get("saved"), "a roll above a zero save chance fails")
	_expect_equal(failed_save.get("effectScale"), 1.0, "a failed save applies the full spell")
	first_target.stat_values["MultiplierMental"] = 1.0
	first_target.stat_values["ResistanceMental"] = 10.0
	var negated_effect: Dictionary = adapter.classic_field_spell_target_resolution(
		{"power": 1, "saveAdjustment": 0, "forceAffect": false},
		first_target,
		confuse,
		1,
		50
	)
	_expect(negated_effect.get("saved"), "a target can save against a condition spell")
	_expect_equal(
		negated_effect.get("effectScale"),
		0.0,
		"a successful save negates a non-damaging field spell"
	)
	var forced_effect: Dictionary = adapter.classic_field_spell_target_resolution(
		{"power": 1, "saveAdjustment": 0, "forceAffect": true},
		first_target,
		confuse,
		1,
		1
	)
	_expect(not forced_effect.get("saved"), "force-affect bypasses a guaranteed save")
	_expect(forced_effect.get("forced"), "force-affect remains visible in the resolution")
	_expect_equal(forced_effect.get("effectScale"), 1.0, "force-affect applies the full spell")
	first_target.stat_values["ResistanceMental"] = 0.0
	var daze_save: Dictionary = adapter.classic_field_spell_target_resolution(
		{"power": 7, "saveAdjustment": 100, "forceAffect": false},
		first_target,
		daze,
		1,
		1,
		100
	)
	_expect(
		not daze_save.get("resisted"),
		"Daze can pass its independent class-zero resistance roll"
	)
	_expect(daze_save.get("saved"), "Daze uses Classic's charm save")
	_expect_equal(daze_save.get("effectScale"), 0.0, "a successful Daze save negates confusion")


func _test_classic_light_contract() -> void:
	_expect_equal(
		ClassicLightScript.apply_power(0, 2),
		59,
		"Classic Shine stores thirty condition points per power minus one"
	)
	_expect_equal(
		ClassicLightScript.apply_power(60, 2),
		60,
		"Classic Shine does not shorten a stronger existing light"
	)
	_expect_equal(
		ClassicLightScript.light_power(59),
		2,
		"Classic light derives its initial intensity from the condition"
	)
	_expect_equal(
		ClassicLightScript.advance_time(59, 3599, 3600),
		57,
		"Classic light loses two condition points at an hour boundary"
	)
	_expect_equal(
		ClassicLightScript.reduce(59),
		57,
		"Classic light uses the same reduction at a combat-round boundary"
	)
	var weakened_condition := ClassicLightScript.reduce(59, 15)
	_expect_equal(weakened_condition, 29, "fifteen reductions step power-two light down")
	_expect_equal(
		ClassicLightScript.light_power(weakened_condition),
		1,
		"Classic light loses one power after the first step"
	)
	_expect_equal(
		ClassicLightScript.reduce(29, 15),
		0,
		"fifteen reductions expire power-one Classic light"
	)
	_expect_equal(
		ClassicLightScript.remaining_seconds(29, 3500),
		50500,
		"Classic light countdown remains aligned to the next game-hour boundary"
	)
	var shine = ShineScript.new()
	_expect_equal(shine.classic_spell_ids, [1110, 2110], "both Shine records share one adapter")
	_expect(shine.skip_targeting, "Shine bypasses the field target picker")
	_expect_equal(
		shine.autotarget_type,
		Spell.AUTOTARGET_TYPE.SELF,
		"Shine executes once through the field spell flow"
	)
	_expect(shine.in_field and not shine.in_combat, "Shine retains its source availability")
	_expect_equal(shine.get_sp_cost(3, null), 9, "Shine costs three spell points per power")


func _test_classic_confusion_contract() -> void:
	_expect_equal(
		ClassicConfusionScript.turn_outcome(39, 1),
		ClassicConfusionScript.OUTCOME_BETRAY,
		"Classic confusion can reverse allegiance below forty"
	)
	_expect_equal(
		ClassicConfusionScript.turn_outcome(39, 2),
		ClassicConfusionScript.OUTCOME_NORMAL,
		"Classic confusion can leave the turn unchanged below forty"
	)
	_expect_equal(
		ClassicConfusionScript.turn_outcome(40, 1),
		ClassicConfusionScript.OUTCOME_IDLE,
		"Classic confusion idles from forty through sixty"
	)
	_expect_equal(
		ClassicConfusionScript.turn_outcome(61, 2),
		ClassicConfusionScript.OUTCOME_FLEE,
		"Classic confusion flees above sixty"
	)
	_expect_equal(
		ClassicConfusionScript.stack_condition(98, 1, 99),
		99,
		"player confusion can reach its source cap"
	)
	_expect_equal(
		ClassicConfusionScript.stack_condition(99, 1, 99),
		99,
		"player confusion rejects a stack beyond its source cap"
	)
	_expect_equal(
		ClassicConfusionScript.advance_time(3, 3599, 3600),
		2,
		"Classic confusion loses one point at a game-hour boundary"
	)
	var target := CharmTestCharacter.new("Confused target", 1)
	var trait_script = load("res://shared_assets/traits/t_classic_confused.gd")
	var confusion_trait = target.add_trait(trait_script, [3])
	_expect_equal(
		confusion_trait.get_saved_variables(),
		[3],
		"Classic confusion persists its condition"
	)
	_expect_equal(
		confusion_trait._on_get_stat("AccuracyMelee", 20),
		10,
		"Classic confusion reduces physical accuracy by ten"
	)
	_expect_equal(
		confusion_trait._on_get_stat("EvasionRanged", 20),
		10,
		"Classic confusion makes the target ten points easier to hit"
	)
	confusion_trait._on_new_round(target)
	_expect_equal(
		confusion_trait.get_saved_variables(),
		[2],
		"combat rounds reduce Classic confusion"
	)
	confusion_trait.stack([2])
	_expect_equal(
		confusion_trait.get_saved_variables(),
		[4],
		"Classic confusion durations stack"
	)
	target.curFaction = 0
	confusion_trait._on_battle_end(target)
	_expect_equal(target.curFaction, 1, "Classic confusion restores faction after battle")
	_expect_equal(
		confusion_trait.get_saved_variables(),
		[4],
		"Classic confusion can persist after battle"
	)


func _test_classic_disease_contract() -> void:
	_expect_equal(
		ClassicDiseaseScript.player_reduction(3),
		{"condition": 2, "damage": 3},
		"Classic disease damages party members before reducing the condition"
	)
	_expect_equal(
		ClassicDiseaseScript.monster_reduction(3),
		{"condition": 2, "damage": 2},
		"Classic disease reduces monsters before applying damage"
	)
	_expect_equal(
		ClassicDiseaseScript.monster_reduction(1),
		{"condition": 0, "damage": 0},
		"a monster's final disease point expires without damage"
	)
	_expect_equal(
		ClassicDiseaseScript.stack_condition(98, 1, 99),
		99,
		"player disease can reach its source cap"
	)
	_expect_equal(
		ClassicDiseaseScript.stack_condition(99, 1, 99),
		99,
		"player disease rejects a stack beyond its source cap"
	)
	_expect_equal(
		ClassicDiseaseScript.stack_condition(123, 1, 124),
		124,
		"monster disease can reach its source cap"
	)
	_expect_equal(
		ClassicDiseaseScript.advance_player_time(3, 0, 7200),
		{"condition": 1, "damage": 5},
		"crossing two game hours applies two party disease reductions"
	)
	_expect_equal(
		ClassicDiseaseScript.player_reductions(3, 2),
		[
			{"condition": 2, "damage": 3},
			{"condition": 1, "damage": 2},
		],
		"multi-hour party damage remains ordered by reduction"
	)
	_expect_equal(
		ClassicDiseaseScript.reduce(3, 2),
		1,
		"held-over allies reduce disease without field damage"
	)
	_expect_equal(
		ClassicDiseaseScript.elapsed_hour_boundaries(3599, 3600),
		1,
		"Classic disease advances at a game-hour boundary"
	)
	_expect_equal(
		ClassicDiseaseScript.stack_condition(0, -6, 99),
		-6,
		"a negative disease value records a permanent condition"
	)
	_expect_equal(
		ClassicDiseaseScript.stack_condition(-6, 3, 99),
		-6,
		"temporary disease cannot replace a permanent condition"
	)
	_expect_equal(
		ClassicDiseaseScript.stack_condition(0, -125, 124, true),
		0,
		"monster disease preserves the source absolute condition cap"
	)
	_expect_equal(
		ClassicDiseaseScript.player_reduction(-6),
		{"condition": -6, "damage": 6},
		"permanent party disease deals damage without decaying"
	)
	_expect_equal(
		ClassicDiseaseScript.monster_reduction(-6),
		{"condition": -6, "damage": 6},
		"permanent monster disease deals damage without decaying"
	)

	var trait_script = load("res://shared_assets/traits/t_classic_disease.gd")
	var party_member := DiseaseTestCharacter.new("Diseased party member", true)
	var party_trait = party_member.add_trait(trait_script, [3])
	party_trait._on_new_round(party_member)
	_expect_equal(party_member.current_hp, 17, "party disease deals the current condition")
	_expect_equal(
		party_trait.get_saved_variables(),
		[2],
		"party disease decays after dealing damage"
	)

	var monster := DiseaseTestCharacter.new("Diseased monster")
	var monster_trait = monster.add_trait(trait_script, [3])
	monster_trait._on_new_round(monster)
	_expect_equal(monster.current_hp, 18, "monster disease deals the reduced condition")
	_expect_equal(
		monster_trait.get_saved_variables(),
		[2],
		"monster disease decays before dealing damage"
	)
	monster_trait.stack([122])
	_expect_equal(
		monster_trait.get_saved_variables(),
		[124],
		"the Classic trait uses the monster condition cap"
	)
	monster_trait.stack([1])
	_expect_equal(
		monster_trait.get_saved_variables(),
		[124],
		"the Classic trait rejects a stack above the monster cap"
	)

	var permanent_target := DiseaseTestCharacter.new("Permanently diseased", true)
	var permanent_trait = permanent_target.add_trait(trait_script, [-6])
	permanent_trait._on_new_round(permanent_target)
	_expect_equal(permanent_target.current_hp, 14, "permanent disease deals absolute damage")
	_expect_equal(
		permanent_trait.get_saved_variables(),
		[-6],
		"permanent disease remains until explicitly cured"
	)
	_expect(
		permanent_trait.get_info_as_text().contains("Permanently Diseased"),
		"permanent disease is identified clearly in the trait UI"
	)

	var animated_monster := DiseaseTestCharacter.new("Animated monster")
	var animated_trait = animated_monster.add_trait(trait_script, [3])
	animated_monster.traits.append(ConditionTestTrait.new("p_animated.gd", 1))
	animated_trait._on_new_round(animated_monster)
	_expect_equal(
		animated_monster.current_hp,
		20,
		"animated monsters do not take Classic disease damage"
	)
	_expect_equal(
		animated_trait.get_saved_variables(),
		[2],
		"animated monsters still reduce the disease condition"
	)


func _test_classic_learned_spell_identity() -> void:
	var spell_mapping: Dictionary = SpellIdsScript.new().mappings
	_expect_equal(
		LearnedSpellIdentityScript.school_evidence_for_character(
			null,
			SorcererLearningRule
		),
		"Sorcerer",
		"native Sorcerer learning rules provide Classic school evidence"
	)
	_expect_equal(
		LearnedSpellIdentityScript.school_evidence_for_character(
			null,
			EnchanterLearningRule
		),
		"Enchanter",
		"native Enchanter learning rules provide Classic school evidence"
	)
	var sorcerer_darts = load("res://shared_assets/spells/magic_darts.gd").new()
	var enchanter_darts = load(
		"res://shared_assets/spells/classic_magic_darts_enchanter.gd"
	).new()
	var single_fear = load("res://shared_assets/spells/fearful_thoughts.gd").new()
	var area_fear = load(
		"res://shared_assets/spells/classic_fearful_thoughts_area.gd"
	).new()
	var priest_area_fear = load(
		"res://shared_assets/spells/classic_fearful_thoughts_priest_area.gd"
	).new()
	var spell_book := {
		"Magic Darts": {
			"name": sorcerer_darts.name,
			"source": sorcerer_darts.generate_json_string(),
			"script": sorcerer_darts,
		},
		"Classic Magic Darts Enchanter": {
			"name": enchanter_darts.name,
			"source": enchanter_darts.generate_json_string(),
			"script": enchanter_darts,
		},
		"Fearful Thoughts": {
			"name": single_fear.name,
			"source": single_fear.generate_json_string(),
			"script": single_fear,
		},
		"Classic Fearful Thoughts Area": {
			"name": area_fear.name,
			"source": area_fear.generate_json_string(),
			"script": area_fear,
		},
		"Classic Fearful Thoughts Priest Area": {
			"name": priest_area_fear.name,
			"source": priest_area_fear.generate_json_string(),
			"script": priest_area_fear,
		},
	}
	var legacy_entry: Dictionary = spell_book["Magic Darts"].duplicate(false)
	var sorcerer_resolution := LearnedSpellIdentityScript.resolve_spell_levels(
		[[legacy_entry]],
		spell_book,
		spell_mapping,
		"Sorcerer"
	)
	var sorcerer_entry: Dictionary = sorcerer_resolution.get("spellLevels", [])[0][0]
	_expect_equal(
		sorcerer_entry.get("classicSpellId"),
		1108,
		"Sorcerer campaign entry preserves the exact Magic Darts ID"
	)
	_expect_equal(
		sorcerer_entry.get("resourceName"),
		"Magic Darts",
		"Sorcerer Magic Darts keeps its native resource key"
	)
	_expect_equal(
		sorcerer_entry.get("script").get_max_damage(1, null),
		5,
		"Sorcerer Magic Darts remains a 1-5 spell after campaign entry"
	)

	var enchanter_resolution := LearnedSpellIdentityScript.resolve_spell_levels(
		[[], [legacy_entry]],
		spell_book,
		spell_mapping,
		"Enchanter"
	)
	var enchanter_entry: Dictionary = enchanter_resolution.get("spellLevels", [])[1][0]
	_expect_equal(
		enchanter_entry.get("classicSpellId"),
		3208,
		"Enchanter campaign entry preserves the exact Magic Darts ID"
	)
	_expect_equal(
		enchanter_entry.get("resourceName"),
		"Classic Magic Darts Enchanter",
		"Enchanter Magic Darts selects its compatibility resource"
	)
	_expect_equal(
		enchanter_entry.get("name"),
		"Magic Darts",
		"the spell picker keeps the player-facing Classic name"
	)
	_expect_equal(
		enchanter_entry.get("script").get_max_damage(1, null),
		4,
		"Enchanter Magic Darts remains a 1-4 spell after campaign entry"
	)
	_expect(
		enchanter_entry.get("script").school_levels.is_empty(),
		"the compatibility-only Enchanter resource stays out of native learning lists"
	)

	var save_payload := LearnedSpellIdentityScript.serialize_spell_levels(
		enchanter_resolution.get("spellLevels", [])
	)
	var saved_entry: Dictionary = save_payload[1][0]
	_expect(not saved_entry.has("script"), "learned spell saves omit runtime objects")
	_expect_equal(saved_entry.get("classicSpellId"), 3208, "learned spell saves retain exact ID")
	_expect_equal(
		saved_entry.get("resourceName"),
		"Classic Magic Darts Enchanter",
		"learned spell saves retain the native resource key"
	)
	var parsed_payload: Variant = JSON.parse_string(JSON.stringify(save_payload))
	var restored_resolution := LearnedSpellIdentityScript.resolve_spell_levels(
		parsed_payload,
		spell_book,
		spell_mapping
	)
	var restored_entry: Dictionary = restored_resolution.get("spellLevels", [])[1][0]
	_expect_equal(
		restored_entry.get("script").get_max_damage(1, null),
		4,
		"exact Enchanter Magic Darts survives JSON save and restore"
	)
	var legacy_fear: Dictionary = spell_book["Fearful Thoughts"].duplicate(false)
	var novice_priest_fear: Dictionary = LearnedSpellIdentityScript.resolve_spell_levels(
		[[legacy_fear]],
		spell_book,
		spell_mapping,
		"Priest"
	).get("spellLevels", [])[0][0]
	_expect_equal(
		novice_priest_fear.get("classicSpellId"),
		2103,
		"legacy Priest level-one Fear resolves its single-target identity"
	)
	var area_priest_fear: Dictionary = LearnedSpellIdentityScript.resolve_spell_levels(
		[[], [], [], [legacy_fear]],
		spell_book,
		spell_mapping,
		"Priest"
	).get("spellLevels", [])[3][0]
	_expect_equal(
		area_priest_fear.get("classicSpellId"),
		2403,
		"legacy Priest level-four Fear resolves its area identity"
	)
	_expect_equal(
		area_priest_fear.get("resourceName"),
		"Classic Fearful Thoughts Priest Area",
		"legacy Priest area Fear selects the exact native variant"
	)

	var ambiguous_resolution := LearnedSpellIdentityScript.resolve_entry(
		{"name": "Discover Magic", "source": "preserved source"},
		spell_book,
		spell_mapping
	)
	var ambiguous_entry: Dictionary = ambiguous_resolution.get("entry", {})
	_expect(
		not ambiguous_entry.has("classicSpellId"),
		"a name-only ambiguous legacy spell is not assigned guessed mechanics"
	)
	_expect(
		not str(ambiguous_resolution.get("diagnostic", "")).is_empty(),
		"an ambiguous legacy spell produces one actionable diagnostic"
	)


func _test_classic_identify_objects_spell() -> void:
	var identify_objects = load("res://shared_assets/spells/identify_objects.gd").new()
	_expect_equal(
		identify_objects.classic_spell_ids,
		[1106, 3307],
		"both Identify Objects records share one exact resource"
	)
	_expect_equal(identify_objects.classic_special, 48, "Identify Objects special")
	_expect_equal(identify_objects.classic_target_type, 1, "Identify Objects target type")
	_expect_equal(identify_objects.get_range(1, null), 0, "Identify Objects range")
	_expect_equal(identify_objects.get_sp_cost(1, null), 25, "Identify Objects fixed cost")
	_expect_equal(
		identify_objects.get_sp_cost(7, null),
		25,
		"Identify Objects ignores unsupported power values"
	)
	_expect_equal(identify_objects.max_plevel, 1, "Identify Objects fixes power at one")
	_expect(identify_objects.in_field, "Identify Objects is available in the field")
	_expect(not identify_objects.in_combat, "Identify Objects is unavailable in combat")
	_expect(not identify_objects.skip_targeting, "Identify Objects selects its carrier")
	_expect_equal(
		identify_objects.autotarget_type,
		Spell.AUTOTARGET_TYPE.NONE,
		"Identify Objects does not force the caster as target"
	)
	_expect_equal(
		identify_objects.school_levels,
		{"Sorcerer": 1, "Priest": 0, "Enchanter": 3},
		"Identify Objects preserves both source levels"
	)
	_expect_equal(
		identify_objects.selection_costs,
		{"Sorcerer": 1, "Priest": 0, "Enchanter": 6},
		"Identify Objects preserves both learning costs"
	)
	_expect_equal(identify_objects.classic_spell_look_ids, [14, 5], "Identify Objects art")
	_expect_equal(identify_objects.classic_sound_ids, [64, 83], "Identify Objects sounds")
	var identify_target := InventoryTestCharacter.new()
	identify_target.inventory = [
		{"name": "Unknown sword", "is_identified": 0},
		{"name": "Known ring", "is_identified": 1},
	]
	var untouched_target := InventoryTestCharacter.new()
	untouched_target.inventory = [{"name": "Unknown cloak", "is_identified": 0}]
	_expect_equal(
		identify_objects.apply_classic_group_effect(null, [identify_target], 1),
		2,
		"Identify Objects visits every carried item"
	)
	_expect_equal(
		identify_target.inventory.map(func(item: Dictionary) -> int: return item["is_identified"]),
		[1, 1],
		"Identify Objects reveals the selected character's complete inventory"
	)
	_expect_equal(
		untouched_target.inventory[0].get("is_identified"),
		0,
		"Identify Objects leaves unselected characters unchanged"
	)


func _test_classic_lethal_spells() -> void:
	var specs := [
		{
			"file": "banish.gd",
			"name": "Banish",
			"id": 2601,
			"class": 7,
			"rawDamageType": -7,
			"save": 7,
			"saveMode": "negate",
			"saveBonus": 0,
			"saveAdjust": 0,
			"resistAdjust": -5,
			"targetType": 3,
			"range": 0,
			"mask": 14,
			"footprint": 28,
			"cost": 375,
			"los": true,
		},
		{
			"file": "death.gd",
			"name": "Death",
			"id": 2701,
			"class": 7,
			"rawDamageType": 7,
			"save": 7,
			"saveMode": "negate",
			"saveBonus": 0,
			"saveAdjust": -10,
			"resistAdjust": -10,
			"targetType": 1,
			"range": 6,
			"mask": 0,
			"footprint": 1,
			"cost": 225,
			"los": true,
		},
		{
			"file": "finger_of_death.gd",
			"name": "Finger of Death",
			"id": 3606,
			"class": 7,
			"rawDamageType": 7,
			"save": 7,
			"saveMode": "negate",
			"saveBonus": 0,
			"saveAdjust": -10,
			"resistAdjust": -10,
			"targetType": 1,
			"range": 8,
			"mask": 0,
			"footprint": 1,
			"cost": 375,
			"los": false,
		},
		{
			"file": "poison_cloud.gd",
			"name": "Poison Cloud",
			"id": 3609,
			"class": 4,
			"rawDamageType": 4,
			"save": 4,
			"saveMode": "half_damage",
			"saveBonus": 35,
			"saveAdjust": -5,
			"resistAdjust": 0,
			"targetType": 3,
			"range": 6,
			"mask": 4,
			"footprint": 9,
			"cost": 300,
			"los": false,
		},
	]
	for spec: Dictionary in specs:
		var spell = load("res://shared_assets/spells/%s" % spec["file"]).new()
		var label := str(spec["name"])
		_expect_equal(spell.name, spec["name"], "%s resource identity" % label)
		_expect_equal(spell.classic_spell_ids, [spec["id"]], "%s exact ID" % label)
		_expect_equal(spell.classic_special, 49, "%s lethal special" % label)
		_expect_equal(spell.classic_spell_class, spec["class"], "%s spell class" % label)
		_expect_equal(
			spell.classic_raw_damage_type,
			spec["rawDamageType"],
			"%s signed damage type" % label
		)
		_expect_equal(spell.classic_spell_save_index, spec["save"], "%s save index" % label)
		_expect_equal(spell.classic_spell_save_mode, spec["saveMode"], "%s save mode" % label)
		_expect_equal(spell.classic_save_bonus, spec["saveBonus"], "%s save bonus" % label)
		_expect_equal(spell.classic_save_adjust, spec["saveAdjust"], "%s save adjustment" % label)
		_expect_equal(
			spell.classic_resist_adjust,
			spec["resistAdjust"],
			"%s resistance adjustment" % label
		)
		_expect_equal(spell.classic_target_type, spec["targetType"], "%s target type" % label)
		_expect_equal(spell.get_range(3, null), spec["range"], "%s source range" % label)
		_expect_equal(spell.classic_size, spec["mask"], "%s Data AD mask" % label)
		_expect_equal(spell.get_aoe(3, null).size(), spec["footprint"], "%s footprint" % label)
		_expect_equal(spell.get_sp_cost(3, null), spec["cost"], "%s casting cost" % label)
		_expect_equal(spell.los, spec["los"], "%s line-of-sight rule" % label)
		_expect(spell.in_combat and not spell.in_field, "%s is combat-only" % label)
		_expect(spell.tags.has("Instant Death"), "%s exposes lethal behavior" % label)

	var banish = load("res://shared_assets/spells/banish.gd").new()
	_expect(banish.skip_targeting, "Banish centers its zero-range mask on the caster")
	_expect_equal(
		banish.autotarget_type,
		Spell.AUTOTARGET_TYPE.SELF,
		"Banish auto-targets the caster's tile"
	)
	var caster := LethalSpellTestCharacter.new("Banish caster", 10)
	var weak_target := LethalSpellTestCharacter.new("Weak target", 6)
	var opposed: Dictionary = MagicResistanceScript.spell_resolution(
		weak_target, banish, 3, 100, false, caster, 16
	)
	_expect(opposed.get("checksOpposedLevel"), "Banish checks target level against caster level")
	_expect(not opposed.get("resisted"), "a strong Banish caster can pass the opposed check")
	var strong_target := LethalSpellTestCharacter.new("Strong target", 10)
	var resisted: Dictionary = MagicResistanceScript.spell_resolution(
		strong_target,
		banish,
		3,
		100,
		false,
		LethalSpellTestCharacter.new("Weak caster", 1),
		50
	)
	_expect(resisted.get("resisted"), "a target can resist Banish's opposed-level check")
	_expect_equal(resisted.get("reason"), "opposed-level", "Banish reports its resistance stage")
	_expect(
		banish.apply_classic_scaled_effect(caster, weak_target, 3, 1.0),
		"Banish affects an ordinary creature after its checks"
	)
	_expect_equal(weak_target.stats["curHP"], -10, "Banish uses the shared lethal result")
	_expect_equal(weak_target.life_status, 3, "Banish marks its target dead")

	var death = load("res://shared_assets/spells/death.gd").new()
	var saved_target := LethalSpellTestCharacter.new("Saved target")
	SpellSavesScript.apply_monster_metadata(
		saved_target,
		[80, 80, 80, 80, 80, 80],
		[0, 0, 0, 0, 0, 0]
	)
	var death_save: Dictionary = SpellSavesScript.target_resolution(
		saved_target, death, 3, 50
	)
	_expect(death_save.get("saved"), "Death retains its special saving throw")
	_expect_equal(death_save.get("effectScale"), 0.0, "a Death save negates the lethal effect")
	_expect(
		not death.apply_classic_scaled_effect(
			null, saved_target, 3, float(death_save.get("effectScale", 1.0))
		),
		"a successful special save negates Death"
	)
	_expect_equal(saved_target.stats["curHP"], 50, "a saved Death target keeps its health")
	var death_target := LethalSpellTestCharacter.new("Death target")
	_expect(
		death.apply_classic_scaled_effect(null, death_target, 3, 1.0),
		"an unresolved Death effect kills its target"
	)
	_expect_equal(death_target.stats["curHP"], -10, "Death ends at Classic's lethal health")
	_expect_equal(death_target.life_status, 3, "Death marks its target dead")
	_expect(
		not death.apply_classic_scaled_effect(null, death_target, 3, 1.0),
		"Death does not alter an already dead target"
	)

	var poison_cloud = load("res://shared_assets/spells/poison_cloud.gd").new()
	_expect_equal(poison_cloud.get_min_damage(3, null), 3, "Poison Cloud fallback minimum")
	_expect_equal(poison_cloud.get_max_damage(3, null), 6, "Poison Cloud fallback maximum")
	var poison_saved := LethalSpellTestCharacter.new("Poison save")
	SpellSavesScript.apply_monster_metadata(
		poison_saved,
		[0, 0, 0, 0, 70, 0],
		[0, 0, 0, 0, 0, 0]
	)
	var poison_save: Dictionary = SpellSavesScript.target_resolution(
		poison_saved, poison_cloud, 7, 70
	)
	_expect(poison_save.get("saved"), "Poison Cloud retains its chemical saving throw")
	_expect_equal(
		poison_save.get("effectScale"),
		0.5,
		"a Poison Cloud save selects reduced source damage"
	)
	_expect(
		poison_cloud.apply_classic_scaled_effect(
			null, poison_saved, 7, float(poison_save.get("effectScale", 1.0))
		),
		"a Poison Cloud save applies its reduced chemical damage"
	)
	_expect(
		int(poison_saved.stats["curHP"]) in range(43, 48),
		"Poison Cloud's saved damage stays within the source roll"
	)
	_expect_equal(poison_saved.life_status, 0, "saved Poison Cloud damage is not instant death")
	var poison_target := LethalSpellTestCharacter.new("Poison death")
	_expect(
		poison_cloud.apply_classic_scaled_effect(null, poison_target, 3, 1.0),
		"a failed Poison Cloud save is lethal"
	)
	_expect_equal(poison_target.stats["curHP"], -10, "Poison Cloud lethal result")
	var immune_target := LethalSpellTestCharacter.new("Chemical immunity")
	SpellSavesScript.apply_monster_metadata(
		immune_target,
		[0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 1, 0]
	)
	var immunity: Dictionary = MagicResistanceScript.spell_resolution(
		immune_target, poison_cloud, 3, 100
	)
	_expect(immunity.get("resisted"), "chemical spell-class immunity blocks Poison Cloud")
	_expect_equal(immunity.get("reason"), "spell-class-immunity", "Poison Cloud immunity reason")


func _test_classic_transformation_spells() -> void:
	var transmute = load("res://shared_assets/spells/transmute_other.gd").new()
	_expect_equal(transmute.name, "Transmute Other", "Transmute Other resource identity")
	_expect_equal(transmute.classic_spell_ids, [3612], "Transmute Other exact ID")
	_expect_equal(transmute.classic_special, 46, "Transmute Other transformation special")
	_expect_equal(transmute.classic_target_type, 1, "Transmute Other targets one creature")
	_expect_equal(transmute.get_range(3, null), 8, "Transmute Other source range")
	_expect_equal(transmute.get_aoe(3, null).size(), 1, "Transmute Other single footprint")
	_expect_equal(transmute.get_sp_cost(3, null), 60, "Transmute Other casting cost")
	_expect_equal(transmute.classic_spell_save_index, 7, "Transmute Other special save")
	_expect_equal(transmute.classic_save_bonus, 10, "Transmute Other save bonus")
	_expect_equal(transmute.classic_save_adjust, 0, "Transmute Other save adjustment")
	_expect_equal(transmute.classic_resist_adjust, -3, "Transmute Other resistance adjustment")
	_expect(transmute.los, "Transmute Other requires line of sight")
	_expect(transmute.tags.has("Transformation"), "Transmute Other exposes its mechanic")

	var multi = load("res://shared_assets/spells/multi_morph_other.gd").new()
	_expect_equal(multi.name, "Multi Morph Other", "Multi Morph Other resource identity")
	_expect_equal(multi.classic_spell_ids, [3705], "Multi Morph Other exact ID")
	_expect_equal(multi.classic_special, 46, "Multi Morph Other transformation special")
	_expect_equal(multi.classic_target_type, 4, "Multi Morph Other uses a scaling area")
	_expect_equal(multi.get_range(3, null), 8, "Multi Morph Other source range")
	_expect_equal(multi.get_aoe(3, null).size(), 9, "Multi Morph Other power-three area")
	_expect_equal(multi.get_sp_cost(3, null), 240, "Multi Morph Other casting cost")
	_expect_equal(multi.classic_spell_save_index, 7, "Multi Morph Other special save")
	_expect_equal(multi.classic_save_bonus, 5, "Multi Morph Other save bonus")
	_expect_equal(multi.classic_resist_adjust, 0, "Multi Morph Other resistance adjustment")
	_expect(multi.los, "Multi Morph Other requires line of sight")

	var bestiary := {
		"Native small": {
			"data": {"size": [1, 1], "summonable": 1, "level": 2},
		},
		"Classic small": {
			"classicMonsterId": 12,
			"data": {"size": [1, 1], "summonable": 1, "level": 3},
		},
		"Classic large": {
			"classicMonsterId": 13,
			"data": {"size": [2, 2], "summonable": 1, "level": 4},
		},
		"Classic inert": {
			"classicMonsterId": 14,
			"data": {"size": [1, 1], "summonable": 1, "level": 0},
		},
		"Classic forbidden": {
			"classicMonsterId": 15,
			"data": {"size": [1, 1], "summonable": 0, "level": 4},
		},
	}
	_expect_equal(
		MonsterTransformationScript.candidate_keys(bestiary, Vector2i.ONE),
		["Classic small"],
		"Classic forms take precedence over the merged native bestiary"
	)
	_expect_equal(
		MonsterTransformationScript.choose_form(bestiary, Vector2i.ONE, 0),
		"Classic small",
		"transformation selects from eligible same-size forms"
	)
	var no_matching_classic := {
		"Native small": {
			"data": {"size": [1, 1], "summonable": 1, "level": 2},
		},
		"Classic large": {
			"classicMonsterId": 13,
			"data": {"size": [2, 2], "summonable": 1, "level": 4},
		},
	}
	_expect(
		MonsterTransformationScript.candidate_keys(
			no_matching_classic, Vector2i.ONE
		).is_empty(),
		"an active Classic set does not borrow an ineligible native form"
	)
	var native_only := {
		"Native small": {
			"data": {"size": [1, 1], "summonable": 1, "level": 2},
		},
	}
	_expect_equal(
		MonsterTransformationScript.candidate_keys(native_only, Vector2i.ONE),
		["Native small"],
		"native forms remain available when no Classic Data MD set is loaded"
	)
	var resisted_target := TransformationTestCreature.new()
	resisted_target.set_meta("classic_magic_resistance", 60)
	var resisted: Dictionary = MagicResistanceScript.spell_resolution(
		resisted_target, transmute, 3, 50
	)
	_expect(resisted.get("resisted"), "Transmute Other retains general resistance")
	_expect_equal(
		resisted.get("chance"),
		51,
		"Transmute Other applies its resistance adjustment per power"
	)
	var saved_target := TransformationTestCreature.new()
	SpellSavesScript.apply_monster_metadata(
		saved_target,
		[80, 80, 80, 80, 80, 80],
		[0, 0, 0, 0, 0, 0]
	)
	var saved: Dictionary = SpellSavesScript.target_resolution(
		saved_target, transmute, 3, 50
	)
	_expect(saved.get("saved"), "Transmute Other retains its special save")
	_expect_equal(saved.get("effectScale"), 0.0, "a special save negates transformation")

	var old_condition := TransformationTestTrait.new("Slowed", "Transmute Other")
	var old_innate := TransformationTestTrait.new("Old hide", "Innate")
	var target := TransformationTestCreature.new()
	target.name = "Old monster"
	target.bestiary_key = "Old form"
	target.classic_monster_id = 4
	target.position = Vector2(7, 5)
	target.baseFaction = 0
	target.curFaction = 0
	target.used_movepoints = 3
	target.used_apr = 1
	target.reaction_ready = false
	target.is_summoned = true
	target.summoner_name = "Summoner"
	target.money = [10, 2, 1]
	target.stats = {"curHP": 17, "maxHP": 17}
	target.traits = [old_condition, old_innate]
	old_condition.chara = target
	old_innate.chara = target
	var button := TransformationTestButton.new()
	button.creature = target
	target.combat_button = button
	target.set_meta("classic_death_macro", 42)
	target.set_meta("classic_regeneration_per_round", 2)
	target.set_meta("encounter_slot", 6)

	var new_innate := TransformationTestTrait.new("New claws", "Innate")
	var replacement := TransformationTestCreature.new()
	replacement.name = "New monster"
	replacement.bestiary_key = "New form"
	replacement.classic_monster_id = 27
	replacement.stats = {"curHP": 31, "maxHP": 31}
	replacement.base_stats = replacement.stats.duplicate(true)
	replacement.money = [99, 99, 99]
	replacement.inventory = [{"name": "New weapon"}]
	replacement.spells = [[{"name": "New spell"}]]
	replacement.ai_variables = {"cast_chance": 25}
	replacement.traits = [new_innate]
	new_innate.chara = replacement
	replacement.set_meta("classic_death_macro", 7)
	replacement.set_meta("classic_regeneration_per_round", 9)

	_expect(
		transmute.apply_classic_form(target, replacement),
		"Transmute Other installs a same-size replacement form"
	)
	_expect_equal(target.name, "New monster", "transformation replaces form identity")
	_expect_equal(target.classic_monster_id, 27, "transformation replaces Classic identity")
	_expect_equal(target.stats["curHP"], 31, "transformation replaces form stamina")
	_expect_equal(target.inventory[0]["name"], "New weapon", "transformation replaces inventory")
	_expect_equal(target.spells[0][0]["name"], "New spell", "transformation replaces spells")
	_expect_equal(target.position, Vector2(7, 5), "transformation preserves battlefield position")
	_expect_equal(target.curFaction, 0, "transformation preserves current allegiance")
	_expect_equal(target.baseFaction, 0, "transformation preserves base allegiance")
	_expect_equal(target.used_movepoints, 3, "transformation preserves turn movement")
	_expect_equal(target.used_apr, 1, "transformation preserves turn actions")
	_expect(not target.reaction_ready, "transformation preserves reaction use")
	_expect(target.is_summoned, "transformation preserves summon ownership")
	_expect_equal(target.summoner_name, "Summoner", "transformation preserves summoner identity")
	_expect_equal(target.money, [0, 0, 0], "transformation clears carried money")
	var trait_names: Array = []
	for trait_value: Variant in target.traits:
		trait_names.append(trait_value.name)
	_expect(trait_names.has("Slowed"), "transformation preserves active conditions")
	_expect(not trait_names.has("Old hide"), "transformation drops the old form's innate traits")
	_expect(trait_names.has("New claws"), "transformation installs the new form's innate traits")
	for trait_value: Variant in target.traits:
		_expect(trait_value.chara == target, "transformation rebinds condition ownership")
	_expect(button.creature == target, "transformation keeps the battlefield object identity")
	_expect_equal(button.refresh_count, 1, "transformation refreshes battlefield presentation")
	_expect_equal(target.get_meta("classic_death_macro"), 7, "new form metadata replaces old metadata")
	_expect_equal(
		target.get_meta("classic_regeneration_per_round"),
		2,
		"transformation preserves active Classic condition metadata"
	)
	_expect_equal(target.get_meta("encounter_slot"), 6, "encounter-owned metadata remains attached")
	_expect_equal(target.get_meta("classic_transformed_from"), "Old form", "old form provenance")
	_expect_equal(target.get_meta("classic_transformed_form"), "New form", "new form provenance")

	var wrong_size := TransformationTestCreature.new()
	wrong_size.size = Vector2(2, 2)
	_expect(
		not transmute.apply_classic_form(target, wrong_size),
		"transformation rejects a different-size form"
	)
	_expect(
		not transmute.apply_classic_scaled_effect(null, target, 3, 0.0),
		"a successful special save negates transformation"
	)


func _test_classic_phase_spells() -> void:
	var limited = load("res://shared_assets/spells/limited_phase.gd").new()
	_expect_equal(limited.name, "Limited Phase", "Limited Phase resource identity")
	_expect_equal(limited.classic_spell_ids, [1208, 2305, 3106], "Limited Phase exact IDs")
	_expect_equal(limited.classic_special, 56, "Limited Phase special")
	_expect_equal(limited.classic_target_type, 8, "Limited Phase targets a destination tile")
	_expect_equal(limited.targettile, Spell.TARGET_TILE.NOWALL, "Limited Phase blocks walls")
	_expect_equal(limited.get_range(3, null), 6, "Limited Phase source range")
	_expect_equal(limited.get_sp_cost(3, null), 30, "Limited Phase casting cost")
	_expect(not limited.los, "Limited Phase does not require line of sight")
	_expect_equal(
		limited.school_levels,
		{"Sorcerer": 2, "Priest": 3, "Enchanter": 1},
		"Limited Phase exposes all source caster levels"
	)

	var limited_caster := PhaseTestCreature.new()
	var limited_result: Dictionary = limited.phase_to(limited_caster, Vector2i(4, 6))
	_expect_equal(limited_result.get("status"), "moved", "Limited Phase relocates its caster")
	_expect_equal(limited_caster.position, Vector2(4, 6), "Limited Phase updates tile position")
	_expect_equal(
		limited_caster.combat_button.position,
		Vector2(4, 6) * 32,
		"Limited Phase updates battlefield presentation"
	)
	_expect_equal(limited_caster.used_apr, 3, "Limited Phase exhausts remaining actions")

	var phase = load("res://shared_assets/spells/phase.gd").new()
	_expect_equal(phase.name, "Phase", "Phase resource identity")
	_expect_equal(phase.classic_spell_ids, [1509, 2511, 3309], "Phase exact IDs")
	_expect_equal(phase.classic_special, 56, "Phase special")
	_expect_equal(phase.get_range(3, null), 7, "Phase source range")
	_expect_equal(phase.get_sp_cost(3, null), 75, "Phase casting cost")
	_expect(not phase.los, "Phase does not require line of sight")
	_expect_equal(
		phase.school_levels,
		{"Sorcerer": 5, "Priest": 5, "Enchanter": 3},
		"Phase exposes all source caster levels"
	)

	var phase_caster := PhaseTestCreature.new()
	var phase_result: Dictionary = phase.phase_to(phase_caster, Vector2i(7, 2))
	_expect_equal(phase_result.get("status"), "moved", "Phase relocates its caster")
	_expect_equal(phase_caster.position, Vector2(7, 2), "Phase updates tile position")
	_expect_equal(phase_caster.used_apr, 1, "Phase preserves remaining actions")

	var collision_caster := PhaseTestCreature.new()
	var collision: Dictionary = phase.phase_to(collision_caster, Vector2i(3, 3), true)
	_expect_equal(collision.get("status"), "collision", "blocked Phase reports its collision")
	_expect_equal(collision_caster.position, Vector2(3, 3), "blocked Phase reaches the destination")
	_expect_equal(collision_caster.stats["curHP"], -10, "blocked Phase is lethal")
	_expect_equal(collision_caster.life_status, 3, "blocked Phase marks the caster dead")


func _test_classic_power_surge_spells() -> void:
	var sorcerer = load("res://shared_assets/spells/power_surge.gd").new()
	_expect_equal(sorcerer.name, "Power Surge", "Sorcerer Power Surge display name")
	_expect_equal(sorcerer.classic_spell_ids, [1409], "Sorcerer Power Surge exact ID")
	_expect_equal(sorcerer.classic_special, 59, "Power Surge special")
	_expect_equal(sorcerer.classic_spell_class, 8, "Power Surge spell class")
	_expect_equal(sorcerer.classic_target_type, 1, "Power Surge targets one creature")
	_expect_equal(sorcerer.classic_cannot, 4, "Power Surge retains friendly targeting flag")
	_expect_equal(sorcerer.classic_spell_save_index, -1, "Power Surge has no save")
	_expect_equal(sorcerer.classic_spell_save_mode, "none", "Power Surge bypasses saves")
	_expect_equal(
		sorcerer.resist,
		Spell.RESIST_TYPE.IGNORE_MRES_DODGE,
		"Power Surge bypasses resistance and dodge"
	)
	_expect(sorcerer.in_combat and sorcerer.in_field, "Power Surge works in combat and camp")
	_expect_equal(sorcerer.get_range(3, null), 1, "Power Surge range")
	_expect_equal(sorcerer.get_sp_cost(3, null), 30, "Power Surge cost scales by power")
	_expect_equal(
		sorcerer.get_min_spell_point_gain(3),
		15,
		"Power Surge minimum scales by power"
	)
	_expect_equal(
		sorcerer.get_max_spell_point_gain(3),
		24,
		"Power Surge maximum scales by power"
	)
	_expect_equal(
		sorcerer.school_levels,
		{"Sorcerer": 4, "Priest": 0, "Enchanter": 0},
		"Sorcerer Power Surge keeps its source level"
	)
	_expect_equal(sorcerer.proj_tex, Spell.GFX.BALL, "Sorcerer Power Surge presentation")
	_expect_equal(
		sorcerer.sounds,
		["hit effect 3.wav", "boing.wav"],
		"Sorcerer Power Surge keeps its source sounds"
	)

	var enchanter = load(
		"res://shared_assets/spells/classic_power_surge_enchanter.gd"
	).new()
	_expect_equal(enchanter.name, "Power Surge", "Enchanter Power Surge display name")
	_expect_equal(enchanter.classic_spell_ids, [3312], "Enchanter Power Surge exact ID")
	_expect_equal(
		enchanter.school_levels,
		{"Sorcerer": 0, "Priest": 0, "Enchanter": 3},
		"Enchanter Power Surge keeps its source level"
	)
	_expect_equal(enchanter.proj_tex, Spell.GFX.WHIRL, "Enchanter presentation remains exact")
	_expect_equal(
		enchanter.sounds,
		["boing.wav", "hit effect 3.wav"],
		"Enchanter Power Surge keeps its source sounds"
	)

	var player := SpellPointConditionTestCharacter.new("Surged player", 17, 20)
	_expect_equal(
		sorcerer.apply_classic_scaled_effect(null, player, 2, 1.0),
		3,
		"runtime Power Surge path clamps players at maximum SP"
	)
	_expect_equal(player.current_sp, 20, "player Power Surge reaches maximum SP")
	_expect_equal(sorcerer.apply_power_surge(player, 2), 0, "full player gains no spell points")

	var monster := MonsterSpellPointAbsorptionTestCharacter.new()
	var monster_gain: int = enchanter.apply_power_surge(monster, 1)
	_expect(monster_gain >= 5 and monster_gain <= 8, "monster Power Surge rolls 5-8 per power")
	_expect_equal(
		monster.stats["curSP"],
		5 + monster_gain,
		"monster Power Surge can exceed the starting spell-point pool"
	)
	monster.stats["curSP"] = 0
	var empty_monster_gain: int = enchanter.apply_power_surge(monster, 1)
	_expect(
		empty_monster_gain >= 5 and empty_monster_gain <= 8,
		"Power Surge can restore a monster with zero spell points"
	)


func _test_classic_summon_spells() -> void:
	var resource_loader = NativeResourcesScript.new()
	var sorcerer_variant := Spell.new()
	sorcerer_variant.name = "Shared summon name"
	sorcerer_variant.classic_spell_ids = [1502]
	var enchanter_variant := Spell.new()
	enchanter_variant.name = "Shared summon name"
	enchanter_variant.classic_spell_ids = [3201]
	resource_loader._store_spell_resource({
		"name": sorcerer_variant.name,
		"source": "sorcerer",
		"script": sorcerer_variant,
	})
	resource_loader._store_spell_resource({
		"name": enchanter_variant.name,
		"source": "enchanter",
		"script": enchanter_variant,
	})
	_expect_equal(
		SpellIdentityScript.resource_key(1502, {}, resource_loader.spells_book),
		"Shared summon name (1502)",
		"spell loader preserves the first same-name exact-ID variant"
	)
	_expect_equal(
		SpellIdentityScript.resource_key(3201, {}, resource_loader.spells_book),
		"Shared summon name",
		"spell loader retains the later same-name exact-ID variant"
	)
	resource_loader.free()

	var expected := {
		1502: ["res://shared_assets/spells/creature_summon_1.gd", 1, 24, 20, "Sorcerer"],
		1602: ["res://shared_assets/spells/creature_summon_2.gd", 2, 12, 40, "Sorcerer"],
		1702: ["res://shared_assets/spells/creature_summon_3.gd", 3, 12, 60, "Sorcerer"],
		2604: ["res://shared_assets/spells/minor_summons.gd", 3, 12, 40, "Priest"],
		2704: ["res://shared_assets/spells/major_summons.gd", 5, 12, 55, "Priest"],
		3201: ["res://shared_assets/spells/classic_creature_summon_1_enchanter.gd", 1, 12, 15, "Enchanter"],
		3304: ["res://shared_assets/spells/classic_creature_summon_2_enchanter.gd", 2, 12, 20, "Enchanter"],
		3403: ["res://shared_assets/spells/classic_creature_summon_3_enchanter.gd", 3, 12, 40, "Enchanter"],
		3502: ["res://shared_assets/spells/creature_summon_4.gd", 4, 12, 60, "Enchanter"],
		3604: ["res://shared_assets/spells/creature_summon_5.gd", 5, 12, 90, "Enchanter"],
		3701: ["res://shared_assets/spells/creature_summon_6.gd", 6, 12, 125, "Enchanter"],
	}
	for spell_id: int in expected:
		var values: Array = expected[spell_id]
		var spell = load(str(values[0])).new()
		_expect_equal(spell.classic_spell_ids, [spell_id], "summon exact ID %d" % spell_id)
		_expect_equal(spell.classic_special, 58, "summon special %d" % spell_id)
		_expect_equal(spell.classic_summon_tier, values[1], "summon tier %d" % spell_id)
		_expect_equal(spell.get_range(3, null), values[2], "summon range %d" % spell_id)
		_expect_equal(spell.get_sp_cost(3, null), int(values[3]) * 3, "summon cost %d" % spell_id)
		_expect_equal(spell.get_target_number(3, null), 3, "summon target count %d" % spell_id)
		_expect_equal(spell.targettile, Spell.TARGET_TILE.EMPTY, "summon targets empty tile %d" % spell_id)
		_expect(not spell.los, "summon ignores line of sight %d" % spell_id)
		_expect(spell.in_combat and not spell.in_field, "summon is combat-only %d" % spell_id)
		_expect_equal(spell.classic_spell_save_index, -1, "summon has no save %d" % spell_id)
		_expect_equal(spell.classic_spell_save_mode, "none", "summon save mode %d" % spell_id)
		_expect_equal(spell.get_aoe(3, null), [Vector2i.ZERO], "summon uses one target tile %d" % spell_id)
		_expect_equal(
			int(spell.school_levels.get(str(values[4]), 0)),
			int((spell_id % 10000) / 100) % 10,
			"summon source school level %d" % spell_id
		)

	_expect_equal(ClassicSummoningScript.hit_dice_bounds(1), Vector2i(2, 6), "tier-one summon band")
	_expect_equal(ClassicSummoningScript.hit_dice_bounds(3), Vector2i(8, 18), "tier-three summon band")
	_expect_equal(ClassicSummoningScript.hit_dice_bounds(5), Vector2i(14, 200), "tier-five summon band")
	_expect_equal(ClassicSummoningScript.hit_dice_bounds(6), Vector2i(17, 200), "tier-six summon band")
	_expect_equal(
		ClassicSummoningScript.resolved_tier(3604, 0),
		5,
		"Creature Summon 5 repairs its zero-tier source defect"
	)

	var bestiary := {
		"Native outsider": {"data": {"summonable": 1, "level": 4}},
		"Classic weak": {
			"classicMonsterId": 4,
			"classicCanSummon": 1,
			"classicHitDice": 4,
			"data": {"summonable": 1, "level": 4},
		},
		"Classic tier three": {
			"classicMonsterId": 8,
			"classicCanSummon": 1,
			"classicHitDice": 10,
			"data": {"summonable": 1, "level": 10},
		},
		"Classic forbidden": {
			"classicMonsterId": 9,
			"classicCanSummon": 0,
			"classicHitDice": 12,
			"data": {"summonable": 0, "level": 12},
		},
	}
	var pool: Dictionary = ClassicSummoningScript.candidate_pool(bestiary, 3)
	_expect_equal(pool["preferred"], ["Classic tier three"], "summon uses active Classic bestiary")
	_expect_equal(
		pool["fallback"],
		["Classic tier three", "Classic weak"],
		"summon retry pool excludes native and forbidden creatures"
	)
	var choice: Dictionary = ClassicSummoningScript.choose_candidate(bestiary, 3, 0)
	_expect_equal(choice.get("bestiaryKey"), "Classic tier three", "summon selects its tier band")
	_expect(not bool(choice.get("usedFallback", true)), "in-band summon does not use fallback")
	var fallback_choice: Dictionary = ClassicSummoningScript.choose_candidate(bestiary, 6, 0)
	_expect_equal(fallback_choice.get("bestiaryKey"), "Classic tier three", "empty band widens after retries")
	_expect(bool(fallback_choice.get("usedFallback", false)), "widened summon reports fallback")

	var summon = load("res://shared_assets/spells/creature_summon_3.gd").new()
	var caster := SummonTestCaster.new()
	var creature := SummonTestCreature.new()
	var combat_state := SummonTestCombatState.new()
	var placed: Dictionary = summon.place_summon(
		caster,
		Vector2i(7, 9),
		creature,
		combat_state,
		true
	)
	_expect_equal(placed.get("status"), "summoned", "summon enters native battle roster")
	_expect_equal(creature.position, Vector2(7, 9), "summon keeps exact selected tile")
	_expect(creature.is_summoned, "summon uses Remake summon identity")
	_expect(creature.summoner == caster, "summon retains caster ownership")
	_expect_equal(creature.summoner_name, "Summoner", "summon retains caster name")
	_expect_equal(creature.baseFaction, 4, "summon inherits base faction")
	_expect_equal(creature.curFaction, 5, "summon inherits current faction")
	_expect_equal(combat_state.classic_monster_slots_used, 1, "summon consumes Classic monster slot")
	_expect_equal(combat_state.battle_creatures_yet_to_act_btns.size(), 1, "summon joins initiative")

	var blocked_creature := SummonTestCreature.new()
	var blocked: Dictionary = summon.place_summon(
		caster,
		Vector2i(2, 3),
		blocked_creature,
		combat_state,
		false
	)
	_expect_equal(blocked.get("status"), "blocked-destination", "summon refuses blocked exact tile")
	_expect_equal(combat_state.all_battle_creatures_btns.size(), 1, "blocked summon does not relocate")
	combat_state.classic_monster_slots_used = ClassicSummoningScript.MAX_MONSTER_SLOTS
	var capped: Dictionary = summon.place_summon(
		caster,
		Vector2i(1, 1),
		SummonTestCreature.new(),
		combat_state,
		true
	)
	_expect_equal(capped.get("status"), "monster-limit", "summon honors Classic 100-slot cap")


func _test_classic_destroy_magic_spells() -> void:
	var expected := {
		1304: [
			"res://shared_assets/spells/destroy_magic.gd",
			"Sorcerer", 3, 4, [13, 14], [7, 20],
		],
		2302: [
			"res://shared_assets/spells/classic_destroy_magic_priest.gd",
			"Priest", 3, 3, [14, 13], [7, 12],
		],
		3503: [
			"res://shared_assets/spells/classic_destroy_magic_enchanter.gd",
			"Enchanter", 5, 4, [13, 5], [7, 12],
		],
	}
	for spell_id: int in expected:
		var values: Array = expected[spell_id]
		var spell = load(str(values[0])).new()
		_expect_equal(
			spell.name, "Destroy Magic", "Destroy Magic display name %d" % spell_id
		)
		_expect_equal(
			spell.classic_spell_ids,
			[spell_id],
			"Destroy Magic exact ID %d" % spell_id
		)
		_expect_equal(spell.classic_special, 61, "Destroy Magic special %d" % spell_id)
		_expect_equal(
			spell.classic_cannot,
			values[3],
			"Destroy Magic force-affect code %d" % spell_id
		)
		_expect_equal(spell.get_range(3, null), 10, "Destroy Magic range %d" % spell_id)
		_expect_equal(spell.get_sp_cost(3, null), 45, "Destroy Magic cost %d" % spell_id)
		_expect_equal(
			spell.get_target_number(3, null),
			3,
			"Destroy Magic target count %d" % spell_id
		)
		_expect_equal(
			spell.targettile,
			Spell.TARGET_TILE.CREATURE,
			"Destroy Magic target %d" % spell_id
		)
		_expect(not spell.los, "Destroy Magic ignores line of sight %d" % spell_id)
		_expect(
			spell.in_combat and spell.in_field,
			"Destroy Magic works in combat and camp %d" % spell_id
		)
		_expect_equal(
			spell.classic_spell_save_index,
			-1,
			"Destroy Magic has no save %d" % spell_id
		)
		_expect_equal(
			spell.classic_spell_save_mode,
			"none",
			"Destroy Magic save mode %d" % spell_id
		)
		_expect_equal(
			spell.resist,
			Spell.RESIST_TYPE.IGNORE_MRES_DODGE,
			"Destroy Magic bypasses resistance %d" % spell_id
		)
		_expect_equal(
			spell.classic_spell_look_ids,
			values[4],
			"Destroy Magic source art %d" % spell_id
		)
		_expect_equal(
			spell.classic_sound_ids,
			values[5],
			"Destroy Magic source sounds %d" % spell_id
		)
		_expect_equal(
			int(spell.school_levels.get(str(values[1]), 0)),
			values[2],
			"Destroy Magic source level %d" % spell_id
		)

	var caster := DispelTestCharacter.new("Caster", 2, true)
	var party_target := DispelTestCharacter.new("Party target", 0, true)
	party_target.traits = [
		DispelTestTrait.new("t_prot_fire.gd"),
		DispelTestTrait.new("p_blind.gd"),
		DispelTestTrait.new("guarding.gd"),
	]
	party_target.add_trait(load("res://shared_assets/traits/t_classic_charmed.gd"), [caster])
	_expect_equal(party_target.curFaction, 2, "test charm changes party allegiance")
	var party_result: Dictionary = ClassicDispelScript.apply(party_target)
	_expect_equal(party_result.get("status"), "applied", "Destroy Magic applies to party member")
	_expect_equal(
		party_result.get("removed"),
		["t_prot_fire.gd", "t_classic_charmed.gd"],
		"Destroy Magic removes temporary conditions and party charm"
	)
	_expect_equal(party_target.curFaction, 0, "Destroy Magic restores party allegiance")
	_expect_equal(
		party_target.traits.size(),
		2,
		"Destroy Magic preserves non-temporary traits"
	)
	_expect_equal(
		party_target.traits[0].name,
		"p_blind.gd",
		"Destroy Magic preserves permanent conditions"
	)
	_expect_equal(
		party_target.traits[1].name,
		"guarding.gd",
		"Destroy Magic preserves combat actions"
	)

	var monster_target := DispelTestCharacter.new("Monster target", 1, false)
	monster_target.add_trait(load("res://shared_assets/traits/t_classic_charmed.gd"), [party_target])
	monster_target.traits.append(DispelTestTrait.new("t_slow.gd"))
	var monster_result: Dictionary = ClassicDispelScript.apply(monster_target)
	_expect_equal(
		monster_result.get("removed"),
		["t_slow.gd"],
		"monster dispel preserves allegiance"
	)
	_expect_equal(monster_target.curFaction, 0, "monster remains charmed after Destroy Magic")
	_expect_equal(
		monster_target.traits[0].name,
		"t_classic_charmed.gd",
		"monster charm trait remains"
	)

	var no_effect_target := DispelTestCharacter.new("Saved target", 0, true)
	no_effect_target.traits.append(DispelTestTrait.new("t_slow.gd"))
	var destroy_magic = load("res://shared_assets/spells/destroy_magic.gd").new()
	_expect_equal(
		destroy_magic.apply_classic_scaled_effect(null, no_effect_target, 1, 0.0),
		0,
		"zero-scale Destroy Magic does not mutate the target"
	)
	_expect_equal(no_effect_target.traits.size(), 1, "zero-scale dispel preserves traits")


func _test_classic_remove_item_spells() -> void:
	var expected := {
		1410: ["res://shared_assets/spells/remove_item.gd", "Remove Item", "Sorcerer", 4, 6, [22, 13]],
		2309: ["res://shared_assets/spells/remove_items.gd", "Remove Items", "Priest", 3, 30, [22, 24]],
	}
	for spell_id: int in expected:
		var values: Array = expected[spell_id]
		var spell = load(str(values[0])).new()
		_expect_equal(spell.name, values[1], "curse removal display name %d" % spell_id)
		_expect_equal(spell.classic_spell_ids, [spell_id], "curse removal exact ID %d" % spell_id)
		_expect_equal(spell.classic_special, 62, "curse removal special %d" % spell_id)
		_expect_equal(spell.classic_cannot, 4, "curse removal force-affect code %d" % spell_id)
		_expect_equal(spell.get_range(3, null), 1, "curse removal range %d" % spell_id)
		_expect_equal(
			spell.get_sp_cost(3, null),
			int(values[4]) * 3,
			"curse removal cost %d" % spell_id
		)
		_expect_equal(spell.get_target_number(3, null), 3, "curse removal targets %d" % spell_id)
		_expect_equal(spell.targettile, Spell.TARGET_TILE.CREATURE, "curse removal target %d" % spell_id)
		_expect(spell.los, "curse removal requires line of sight %d" % spell_id)
		_expect(spell.in_combat and spell.in_field, "curse removal works in combat and camp %d" % spell_id)
		_expect_equal(spell.classic_spell_save_index, -1, "curse removal has no save %d" % spell_id)
		_expect_equal(spell.classic_spell_save_mode, "none", "curse removal save mode %d" % spell_id)
		_expect_equal(
			spell.resist,
			Spell.RESIST_TYPE.IGNORE_MRES_DODGE,
			"curse removal bypasses resistance %d" % spell_id
		)
		_expect_equal(spell.classic_spell_look_ids, [4, 4], "curse removal source art %d" % spell_id)
		_expect_equal(spell.classic_sound_ids, values[5], "curse removal source sounds %d" % spell_id)
		_expect_equal(
			int(spell.school_levels.get(str(values[2]), 0)),
			values[3],
			"curse removal source level %d" % spell_id
		)

	var target := CurseRemovalTestCharacter.new()
	target.traits = [
		ConditionTestTrait.new("p_cursed.gd", 1),
		ConditionTestTrait.new("t_cursed.gd", 4),
		ConditionTestTrait.new("p_blind.gd", 1),
	]
	target.inventory = [
		{"name": "Native cursed sword", "equipped": 1, "traits": [["p_cursed.gd", []]]},
		{"name": "Classic cursed ring", "equipped": 1, "classicCursedItemId": 318},
		{"name": "Carried cursed cloak", "equipped": 0, "classicRecord": {"cursedItemId": 77}},
		{"name": "Ordinary shield", "equipped": 1},
	]
	var remove_items = load("res://shared_assets/spells/remove_items.gd").new()
	_expect_equal(
		remove_items.apply_classic_scaled_effect(null, target, 1, 1.0),
		4,
		"Remove Items clears two curse traits and unequips two cursed items"
	)
	_expect_equal(target.traits.size(), 1, "Remove Items clears temporary and permanent curse traits")
	_expect_equal(target.traits[0].name, "p_blind.gd", "Remove Items preserves unrelated conditions")
	_expect_equal(target.inventory.size(), 4, "Remove Items never deletes inventory entries")
	_expect_equal(target.inventory[0].get("equipped"), 0, "native cursed item is unequipped")
	_expect_equal(target.inventory[1].get("equipped"), 0, "Classic cursed item is unequipped")
	_expect_equal(target.inventory[2].get("equipped"), 0, "carried cursed item remains carried")
	_expect_equal(target.inventory[3].get("equipped"), 1, "ordinary equipment remains worn")
	_expect_equal(target.unequip_checks, [false, false], "curse removal forces normal unequip bookkeeping")

	var no_effect_target := CurseRemovalTestCharacter.new()
	no_effect_target.traits.append(ConditionTestTrait.new("t_cursed.gd", 2))
	no_effect_target.inventory.append(
		{"name": "Cursed item", "equipped": 1, "traits": [["p_cursed.gd", []]]}
	)
	_expect_equal(
		remove_items.apply_classic_scaled_effect(null, no_effect_target, 1, 0.0),
		0,
		"zero-scale curse removal does not mutate the target"
	)
	_expect_equal(no_effect_target.traits.size(), 1, "zero-scale curse removal preserves conditions")
	_expect_equal(no_effect_target.inventory[0].get("equipped"), 1, "zero-scale curse removal preserves equipment")


func _test_classic_spell_coverage() -> void:
	var inventory: Array[Dictionary] = CoreSpellCatalogScript.inventory_records()
	_expect_equal(inventory.size(), 252, "core inventory includes every named player spell")
	_expect_equal(
		inventory.front().get("packedSpellId"),
		1101,
		"core inventory begins with Sorcerer level 1"
	)
	_expect_equal(
		inventory.back().get("packedSpellId"),
		3712,
		"core inventory ends with Enchanter level 7"
	)
	var inventory_ids: Dictionary = {}
	var unique_ids := true
	var valid_offsets := true
	var generic_records := 0
	var special_records := 0
	for record: Dictionary in inventory:
		var packed_id := int(record.get("packedSpellId", 0))
		if inventory_ids.has(packed_id):
			unique_ids = false
		inventory_ids[packed_id] = true
		var source_record: Dictionary = record.get("sourceRecord", {})
		if int(source_record.get("byteOffset", -1)) \
			!= int(source_record.get("recordIndex", -1)) * 30:
			valid_offsets = false
		if str(record.get("recordShape", "")) == "generic":
			generic_records += 1
		else:
			special_records += 1
	_expect(unique_ids, "core inventory IDs are unique")
	_expect(valid_offsets, "core inventory offsets follow Data S records")
	_expect_equal(generic_records, 79, "core inventory classifies generic record shapes")
	_expect_equal(special_records, 173, "core inventory identifies special-behavior records")
	var sorcerer_darts := CoreSpellCatalogScript.inventory_spell(1108)
	_expect_equal(sorcerer_darts.get("displayName"), "Magic Darts", "inventory resolves names")
	_expect_equal(
		sorcerer_darts.get("record", {}).get("damage2"),
		5,
		"inventory preserves Sorcerer Magic Darts damage"
	)
	var enchanter_darts := CoreSpellCatalogScript.inventory_spell(3208)
	_expect_equal(
		enchanter_darts.get("record", {}).get("damage2"),
		4,
		"inventory preserves same-name Enchanter mechanics"
	)
	_expect_equal(
		CoreSpellCatalogScript.inventory_spell(1110).get("record", {}).get("special"),
		50,
		"inventory retains special behavior numbers for adapter review"
	)
	var sorcerer_shine: Dictionary = CoreSpellCatalogScript.inventory_spell(1110).get(
		"record", {}
	).duplicate(true)
	var priest_shine: Dictionary = CoreSpellCatalogScript.inventory_spell(2110).get(
		"record", {}
	).duplicate(true)
	sorcerer_shine.erase("spellLook1")
	priest_shine.erase("spellLook1")
	_expect_equal(
		priest_shine,
		sorcerer_shine,
		"Sorcerer and Priest Shine differ only in their launch presentation"
	)
	var support_audit = SpellUsageAuditScript.new()
	var support_matrix: Dictionary = support_audit.load_support_matrix()
	var support_by_id: Dictionary = {}
	for support_value: Variant in support_matrix.get("spells", []):
		if support_value is Dictionary:
			support_by_id[int(support_value.get("classicSpellId", 0))] = support_value
	var native_spells: Dictionary = {}
	SpellResourceCatalogScript.merge_directory("res://shared_assets/spells", native_spells)
	var coverage: Dictionary = CoreSpellCoverageScript.new().inspect(
		support_matrix, native_spells
	)
	var coverage_totals: Dictionary = coverage.get("totals", {})
	_expect_equal(coverage_totals.get("spellIds"), 252, "coverage classifies every player spell")
	_expect_equal(
		coverage_totals.get("matrixSupported"),
		251,
		"coverage preserves the curated supported count"
	)
	var coverage_statuses: Dictionary = coverage_totals.get("coverageStatus", {})
	var classified_total := 0
	for status_count: Variant in coverage_statuses.values():
		classified_total += int(status_count)
	_expect_equal(classified_total, 252, "coverage assigns one review status per spell")
	_expect_equal(
		coverage_statuses.get("support-resource-mismatch", 0),
		0,
		"every supported spell resolves through its exact resource"
	)
	_expect_equal(
		coverage_statuses.get("generic-implementation-candidate", 0),
		0,
		"coverage closes the generic implementation queue"
	)
	var coverage_by_id: Dictionary = {}
	for coverage_value: Variant in coverage.get("spells", []):
		if coverage_value is Dictionary:
			coverage_by_id[int(coverage_value.get("classicSpellId", 0))] = coverage_value
	_expect_equal(
		coverage_by_id.get(1108, {}).get("coverageStatus"),
		"supported",
		"supported native spells remain distinct from review candidates"
	)
	_expect_equal(
		support_by_id.get(1108, {}).get("behavior", {}).get("learnedSpellIdentity"),
		"exact-id-campaign-entry-save-load",
		"Sorcerer Magic Darts records learned exact-ID coverage"
	)
	_expect_equal(
		support_by_id.get(3208, {}).get("behavior", {}).get("learnedSpellIdentity"),
		"exact-id-campaign-entry-save-load",
		"Enchanter Magic Darts records learned exact-ID coverage"
	)
	for reviewed_variant_id: int in [1603, 2403, 2708, 3104, 3303, 3505]:
		_expect_equal(
			coverage_by_id.get(reviewed_variant_id, {}).get("coverageStatus"),
			"supported",
			"reviewed variant %d resolves through an exact resource" % reviewed_variant_id
		)
		_expect_equal(
			support_by_id.get(reviewed_variant_id, {}).get(
				"behavior", {}
			).get("learnedSpellIdentity"),
			"exact-id-campaign-entry-save-load",
			"reviewed variant %d records learned exact-ID coverage" % reviewed_variant_id
		)
	_expect_equal(
		coverage_by_id.get(1110, {}).get("coverageStatus"),
		"supported",
		"Sorcerer Shine uses the reviewed Classic light adapter"
	)
	_expect_equal(
		coverage_by_id.get(2110, {}).get("coverageStatus"),
		"supported",
		"Priest Shine shares the same source mechanics"
	)
	_expect_equal(
		coverage_by_id.get(2301, {}).get("coverageStatus"),
		"supported",
		"Confuse uses the reviewed Classic condition adapter"
	)
	_expect_equal(
		coverage_by_id.get(2304, {}).get("coverageStatus"),
		"supported",
		"Festering Wounds uses the reviewed Classic disease adapter"
	)
	_expect_equal(
		coverage_by_id.get(2502, {}).get("coverageStatus"),
		"supported",
		"Disease uses the reviewed Classic disease adapter"
	)
	_expect_equal(
		coverage_by_id.get(2408, {}).get("coverageStatus"),
		"supported",
		"Poison uses the reviewed permanent condition adapter"
	)
	for deflector_id: int in [1508, 1707, 2406, 2603, 3507, 3703]:
		_expect_equal(
			coverage_by_id.get(deflector_id, {}).get("coverageStatus"),
			"supported",
			"Spell Deflector %d uses the reviewed reflection adapter" % deflector_id
		)
	for attack_deflector_id: int in [1406, 1606, 2307, 2506, 3408, 3608]:
		_expect_equal(
			coverage_by_id.get(attack_deflector_id, {}).get("coverageStatus"),
			"supported",
			"Attack Deflector %d uses the reviewed reflection adapter" % attack_deflector_id
		)
	for attack_bonus_id: int in [1102, 2503, 3104, 3305]:
		_expect_equal(
			coverage_by_id.get(attack_bonus_id, {}).get("coverageStatus"),
			"supported",
			"Enchanted Blade %d uses the reviewed attack-bonus adapter" % attack_bonus_id
		)
	for power_gather_id: int in [1510, 3510]:
		_expect_equal(
			coverage_by_id.get(power_gather_id, {}).get("coverageStatus"),
			"supported",
			"Power Gather %d uses the reviewed spell-point adapter" % power_gather_id
		)
	for energy_drain_id: int in [1511, 2711, 3511]:
		_expect_equal(
			coverage_by_id.get(energy_drain_id, {}).get("coverageStatus"),
			"supported",
			"energy drain %d uses the reviewed spell-point adapter" % energy_drain_id
		)
	for absorption_id: int in [1301, 1403, 2702, 3302]:
		_expect_equal(
			coverage_by_id.get(absorption_id, {}).get("coverageStatus"),
			"supported",
			"Arcanic Bubble %d uses the reviewed pre-resistance adapter" % absorption_id
		)
	for hindered_attack_id: int in [1207, 2209]:
		_expect_equal(
			coverage_by_id.get(hindered_attack_id, {}).get("coverageStatus"),
			"supported",
			"Itching Skin %d uses the reviewed attack-hindrance adapter"
			% hindered_attack_id
		)
	_expect_equal(
		coverage_by_id.get(3109, {}).get("coverageStatus"),
		"supported",
		"Shrink Foe uses the reviewed defense-hindrance adapter"
	)
	for shield_spell_id: int in [1111, 2112, 3212, 3406]:
		_expect_equal(
			coverage_by_id.get(shield_spell_id, {}).get("coverageStatus"),
			"supported",
			"Shield from Hits spell %d uses the reviewed condition adapter"
			% shield_spell_id
		)
	for projectile_protection_id: int in [2210, 3508]:
		_expect_equal(
			coverage_by_id.get(projectile_protection_id, {}).get("coverageStatus"),
			"supported",
			"projectile protection %d uses the reviewed class-9 adapter"
			% projectile_protection_id
		)
	for silence_id: int in [1411, 2211, 3110]:
		_expect_equal(
			coverage_by_id.get(silence_id, {}).get("coverageStatus"),
			"supported",
			"Silence %d uses the reviewed queued-condition adapter" % silence_id
		)
	for dispel_id: int in [1304, 2302, 3503]:
		_expect_equal(
			coverage_by_id.get(dispel_id, {}).get("coverageStatus"),
			"supported",
			"Destroy Magic %d uses the reviewed dispel adapter" % dispel_id
		)
	for curse_removal_id: int in [1410, 2309]:
		_expect_equal(
			coverage_by_id.get(curse_removal_id, {}).get("coverageStatus"),
			"supported",
			"curse removal %d uses the reviewed inventory adapter" % curse_removal_id
		)
	_expect_equal(
		coverage_by_id.get(1408, {}).get("coverageStatus"),
		"supported",
		"reviewed Sorcerer Power Drain is supported"
	)
	_expect_equal(
		coverage_by_id.get(3311, {}).get("coverageStatus"),
		"supported",
		"reviewed Enchanter Power Drain is supported"
	)
	_expect_equal(
		coverage_by_id.get(3202, {}).get("coverageStatus"),
		"supported",
		"Daze is supported after its early resistance and later charm save are represented"
	)
	_expect_equal(
		coverage_by_id.get(1212, {}).get("coverageStatus"),
		"supported",
		"reviewed generic damage spells are supported"
	)
	_expect_equal(
		coverage_by_id.get(1303, {}).get("coverageStatus"),
		"supported",
		"reviewed generic ray spells are supported"
	)
	for party_spell_id: int in [
		1105, 1202, 1205, 1312, 1512, 1612, 2104, 2202, 2312, 2710, 3107,
		3203, 3204, 3611,
	]:
		_expect_equal(
			coverage_by_id.get(party_spell_id, {}).get("coverageStatus"),
			"supported",
			"party spell %d uses the reviewed condition clock" % party_spell_id
		)
	for helpless_spell_id: int in [1710, 2310, 2405, 2510, 2610, 3209, 3707]:
		_expect_equal(
			coverage_by_id.get(helpless_spell_id, {}).get("coverageStatus"),
			"supported",
			"helpless spell %d uses the reviewed condition path" % helpless_spell_id
		)
	for slug_spell_id: int in [1311, 2311]:
		_expect_equal(
			coverage_by_id.get(slug_spell_id, {}).get("coverageStatus"),
			"supported",
			"Slug %d uses the reviewed queued Slow path" % slug_spell_id
		)
	_expect_equal(
		coverage_by_id.get(2412, {}).get("coverageStatus"),
		"supported",
		"Tangle Weed uses the reviewed queued Tangled path"
	)
	_expect_equal(
		coverage_by_id.get(3605, {}).get("coverageStatus"),
		"supported",
		"Destroy Trap uses the reviewed rogue encounter path"
	)
	_expect_equal(
		coverage_by_id.get(1109, {}).get("coverageStatus"),
		"supported",
		"Open Lock uses the reviewed rogue encounter path"
	)
	_expect_equal(
		coverage_by_id.get(1412, {}).get("coverageStatus"),
		"supported",
		"Sleepwalk uses the reviewed party fatigue path"
	)
	for spellcasting_block_id: int in [2203, 3407]:
		_expect_equal(
			coverage_by_id.get(spellcasting_block_id, {}).get("coverageStatus"),
			"supported",
			"spellcasting block %d uses the reviewed Dumb path"
			% spellcasting_block_id
		)
	for charm_spell_id: int in [1607, 1709, 2507, 2707]:
		_expect_equal(
			coverage_by_id.get(charm_spell_id, {}).get("coverageStatus"),
			"supported",
			"charm spell %d uses the reviewed battle-allegiance path" % charm_spell_id
		)
	for identify_spell_id: int in [1106, 3307]:
		_expect_equal(
			coverage_by_id.get(identify_spell_id, {}).get("coverageStatus"),
			"supported",
			"Identify Objects %d uses the reviewed inventory path" % identify_spell_id
		)
	_expect_equal(
		coverage_by_id.get(2106, {}).get("coverageStatus"),
		"supported",
		"Magic Aura uses the reviewed all-allies condition path"
	)

	var core_spell_book: Dictionary = {}
	CoreSpellCatalogScript.merge_into_spell_book(core_spell_book)
	_expect(core_spell_book.is_empty(), "core catalog has no remaining runtime spells")
	var energy_storm = load("res://shared_assets/spells/energy_storm.gd").new()
	var flame_hands = load("res://shared_assets/spells/flame_hands.gd").new()
	var frozen_palm = load("res://shared_assets/spells/frozen_palm.gd").new()
	var magic_grip = load("res://shared_assets/spells/magic_grip.gd").new()
	var frostbite = load("res://shared_assets/spells/frostbite.gd").new()
	var shock_palm = load("res://shared_assets/spells/shock_palm.gd").new()
	var sparkling_armor = load("res://shared_assets/spells/sparkling_armor.gd").new()
	var flame_spikes = load("res://shared_assets/spells/flame_spikes.gd").new()
	var migrated_spell_ids: Array[int] = [
		1103, 1104, 1204, 1209, 1211, 1303, 1402, 1504,
		1503, 1505, 1701, 3207, 3301, 3308, 3409, 3712,
		1203, 1212, 1306, 1310, 1401, 2101, 3211, 3401, 3704,
		3105, 3506,
		2109, 2306, 2605, 2706,
		1601, 1703, 2705, 2709, 2712, 3108, 3205, 3501, 3601, 3602, 3710,
		1107, 1112, 1201, 1305, 1609, 2504, 2609, 2611,
		3111, 3112, 3306, 3404, 3410, 3709, 3711,
		1308, 1309, 1407, 2512, 3310, 3509,
		1608, 1610, 1611, 1704, 1711, 1712, 2407, 2501, 2508, 2607, 3210, 3512,
		3607, 3702, 3706,
		2204, 2205, 2206, 2602, 2606, 3206, 3405, 3708,
		2107, 2108, 2303, 2308, 3101, 3103, 3402, 3412,
		1307, 1404, 1405, 1507, 1605, 1706, 2411,
		2212,
		1210, 2409,
		1302, 2401,
		1206, 1708, 2208, 2509,
		2410, 3610,
		2608, 3411,
		2402, 2304, 2502,
		1508, 1707, 2406, 2603, 3507, 3703,
		1406, 1606, 2307, 2506, 3408, 3608,
		1102, 2503, 3104, 3305,
		1510, 3510,
		1511, 2711, 3511,
		1301, 1403, 2702, 3302,
		1207, 2209,
		3109,
		2112, 2210, 3212, 3406, 3508,
		1105, 1202, 1205, 1312, 1512, 1612, 2104, 2202, 2312, 2710, 3107,
		3203, 3204, 3611,
		1411, 2211, 3110,
		1710, 2310, 2510, 2610, 3209, 3707,
		1311, 2311,
		1106, 1607, 1709, 2106, 2203, 2405, 2408, 2507, 2601, 2701, 2707,
		3307, 3407, 3606, 3609, 3612, 3705,
		1410, 2309,
	]
	_expect_equal(migrated_spell_ids.size(), 194, "the reviewed spell batches are complete")
	for migrated_spell_id: int in migrated_spell_ids:
		_expect(
			CoreSpellCatalogScript.spell(migrated_spell_id) == null,
			"migrated spell %d no longer depends on the generic runtime catalog"
			% migrated_spell_id
		)
	var migrated_native_paths := {
		"Energy Storm": "res://shared_assets/spells/energy_storm.gd",
		"Flame Hands": "res://shared_assets/spells/flame_hands.gd",
		"Frozen Palm": "res://shared_assets/spells/frozen_palm.gd",
		"Magic Grip": "res://shared_assets/spells/magic_grip.gd",
		"Frostbite": "res://shared_assets/spells/frostbite.gd",
		"Shock Palm": "res://shared_assets/spells/shock_palm.gd",
		"Scorched Earth": "res://shared_assets/spells/scorched_earth.gd",
		"Deep Freeze": "res://shared_assets/spells/deep_freeze.gd",
		"Flame Tongue": "res://shared_assets/spells/flame_tongue.gd",
		"Flash": "res://shared_assets/spells/flash.gd",
		"Arctic Wind": "res://shared_assets/spells/arctic_wind.gd",
		"Heat Ray": "res://shared_assets/spells/heat_ray.gd",
		"Acid Splash": "res://shared_assets/spells/acid_splash.gd",
		"Lightning Bolt": "res://shared_assets/spells/lightning_bolt.gd",
		"Vapor Trail": "res://shared_assets/spells/vapor_trail.gd",
		"Flame Spikes": "res://shared_assets/spells/flame_spikes.gd",
		"Shiver": "res://shared_assets/spells/shiver.gd",
		"Fireball": "res://shared_assets/spells/fireball.gd",
		"Radiate": "res://shared_assets/spells/radiate.gd",
		"Cosmic Blast": "res://shared_assets/spells/cosmic_blast.gd",
		"Brimstones": "res://shared_assets/spells/brimstones.gd",
		"Steel Rain": "res://shared_assets/spells/steel_rain.gd",
		"Acid Rain": "res://shared_assets/spells/acid_rain.gd",
		"Mind Rash": "res://shared_assets/spells/mind_rash.gd",
		"Lightning Strike": "res://shared_assets/spells/lightning_strike.gd",
		"Finger of Pain": "res://shared_assets/spells/finger_of_pain.gd",
		"Psionic Spear": "res://shared_assets/spells/psionic_spear.gd",
		"Mind Duel": "res://shared_assets/spells/mind_duel.gd",
		"Psi Wave": "res://shared_assets/spells/psi_wave.gd",
		"Mind Melt": "res://shared_assets/spells/mind_melt.gd",
		"Flame Missile": "res://shared_assets/spells/classic_core_1503_flame_missile.gd",
		"Annihilate": "res://shared_assets/spells/classic_core_1601_annihilate.gd",
		"Fire Flies": "res://shared_assets/spells/classic_core_1703_fire_flies.gd",
		"Meteor Shower": "res://shared_assets/spells/classic_core_2705_meteor_shower.gd",
		"Stun": "res://shared_assets/spells/classic_core_2712_stun.gd",
		"Repulsive Bubble": "res://shared_assets/spells/classic_core_3108_repulsive_bubble.gd",
		"Electric Pulse": "res://shared_assets/spells/classic_core_3205_electric_pulse.gd",
		"Acid Bath": "res://shared_assets/spells/classic_core_3501_acid_bath.gd",
		"Ball Lightning": "res://shared_assets/spells/classic_core_3601_ball_lightning.gd",
		"Caustic Vapor": "res://shared_assets/spells/classic_core_3602_caustic_vapor.gd",
		"Static Discharge": "res://shared_assets/spells/classic_core_3710_static_discharge.gd",
		"Leap": "res://shared_assets/spells/classic_core_1107_leap.gd",
		"Superfly": "res://shared_assets/spells/classic_core_1112_superfly.gd",
		"Dig Hole": "res://shared_assets/spells/classic_core_1201_dig_hole.gd",
		"Fantastic Wings": "res://shared_assets/spells/classic_core_1305_fantastic_wings.gd",
		"Shape Earth": "res://shared_assets/spells/classic_core_1609_shape_earth.gd",
		"Hands to Clay": "res://shared_assets/spells/classic_core_2504_hands_to_clay.gd",
		"Teleport Party": "res://shared_assets/spells/classic_core_2609_teleport_party.gd",
		"Watergate": "res://shared_assets/spells/classic_core_2611_watergate.gd",
		"Splinters": "res://shared_assets/spells/classic_core_3111_splinters.gd",
		"Voiceover": "res://shared_assets/spells/classic_core_3112_voiceover.gd",
		"Classic Hands to Clay Enchanter": "res://shared_assets/spells/classic_core_3306_hands_to_clay_enchanter.gd",
		"Speak Language": "res://shared_assets/spells/classic_core_3410_speak_language.gd",
		"Classic Teleport Party Enchanter": "res://shared_assets/spells/classic_core_3711_teleport_party_enchanter.gd",
		"Plague": "res://shared_assets/spells/classic_core_1308_plague.gd",
		"Plane of Force": "res://shared_assets/spells/classic_core_1309_plane_of_force.gd",
		"Plane of Ice": "res://shared_assets/spells/classic_core_1407_plane_of_ice.gd",
		"Classic Plane of Force Enchanter": "res://shared_assets/spells/classic_core_3310_plane_of_force_enchanter.gd",
		"Classic Plague Enchanter": "res://shared_assets/spells/classic_core_3509_plague_enchanter.gd",
		"Plane of Fire": "res://shared_assets/spells/classic_core_1608_plane_of_fire.gd",
		"Solar Flare": "res://shared_assets/spells/classic_core_1610_solar_flare.gd",
		"Stinging Lights": "res://shared_assets/spells/classic_core_1611_stinging_lights.gd",
		"Hail Storm": "res://shared_assets/spells/classic_core_1704_hail_storm.gd",
		"Pulse": "res://shared_assets/spells/classic_core_1711_pulse.gd",
		"Solor Winds": "res://shared_assets/spells/classic_core_1712_solor_winds.gd",
		"Plane of Thorns": "res://shared_assets/spells/classic_core_2407_plane_of_thorns.gd",
		"Cloud of Cleavers": "res://shared_assets/spells/classic_core_2501_cloud_of_cleavers.gd",
		"Mind Mines": "res://shared_assets/spells/classic_core_2508_mind_mines.gd",
		"Ring of Fire": "res://shared_assets/spells/classic_core_2607_ring_of_fire.gd",
		"Plane of Fog": "res://shared_assets/spells/classic_core_3210_plane_of_fog.gd",
		"Shell Shock": "res://shared_assets/spells/classic_core_3512_shell_shock.gd",
		"Fire Storm": "res://shared_assets/spells/classic_core_3607_fire_storm.gd",
		"Fog of Doom": "res://shared_assets/spells/classic_core_3702_fog_of_doom.gd",
		"Heal Small Wounds": "res://shared_assets/spells/classic_core_1506_heal_small_wounds.gd",
		"Classic Heal Medium Wounds Sorcerer": "res://shared_assets/spells/classic_core_1604_heal_medium_wounds_sorcerer.gd",
		"Classic Heal Large Wounds Sorcerer": "res://shared_assets/spells/classic_core_1705_heal_large_wounds_sorcerer.gd",
		"Heal Medium Wounds": "res://shared_assets/spells/classic_core_2207_heal_medium_wounds.gd",
		"Heal Large Wounds": "res://shared_assets/spells/classic_core_2404_heal_large_wounds.gd",
		"Heal Wounds": "res://shared_assets/spells/classic_core_2505_heal_wounds.gd",
		"Regenerate Stamina": "res://shared_assets/spells/classic_core_2709_regenerate_stamina.gd",
		"Multi Regenerate Stamina": "res://shared_assets/spells/classic_core_3706_multi_regenerate_stamina.gd",
		"Heal Blindness": "res://shared_assets/spells/classic_core_2204_heal_blindness.gd",
		"Heal Disease": "res://shared_assets/spells/classic_core_2205_heal_disease.gd",
		"Heal Poison": "res://shared_assets/spells/classic_core_2206_heal_poison.gd",
		"Flesh": "res://shared_assets/spells/classic_core_2602_flesh.gd",
		"Revive Dead": "res://shared_assets/spells/classic_core_2606_revive_dead.gd",
		"Classic Flesh Enchanter": "res://shared_assets/spells/classic_core_3405_flesh_enchanter.gd",
		"Protection from Cold": "res://shared_assets/spells/classic_core_2107_protection_from_cold.gd",
		"Protection from Heat": "res://shared_assets/spells/classic_core_2108_protection_from_heat.gd",
		"Electrical Protection": "res://shared_assets/spells/classic_core_2303_electrical_protection.gd",
		"Psi Shield": "res://shared_assets/spells/classic_core_2308_psi_shield.gd",
		"Chemical Protection": "res://shared_assets/spells/classic_core_3101_chemical_protection.gd",
		"Classic Electrical Protection Enchanter": "res://shared_assets/spells/classic_core_3103_electrical_protection_enchanter.gd",
		"Cool Breeze": "res://shared_assets/spells/classic_core_3402_cool_breeze.gd",
		"Warmth": "res://shared_assets/spells/classic_core_3412_warmth.gd",
		"Magic Screen I": "res://shared_assets/spells/classic_core_1307_magic_screen_i.gd",
		"Magic Screen II": "res://shared_assets/spells/classic_core_1404_magic_screen_ii.gd",
		"Magic Shield": "res://shared_assets/spells/classic_core_1405_magic_shield.gd",
		"Magic Screen III": "res://shared_assets/spells/classic_core_1507_magic_screen_iii.gd",
		"Magic Screen IV": "res://shared_assets/spells/classic_core_1605_magic_screen_iv.gd",
		"Magic Screen V": "res://shared_assets/spells/classic_core_1706_magic_screen_v.gd",
		"Sphere of Protection": "res://shared_assets/spells/classic_core_2411_sphere_of_protection.gd",
		"Super Brawn": "res://shared_assets/spells/classic_core_2212_super_brawn.gd",
		"Protection from Foe": "res://shared_assets/spells/classic_core_1210_protection_from_foe.gd",
		"Classic Protection from Foe Priest": "res://shared_assets/spells/classic_core_2409_protection_from_foe_priest.gd",
		"Adrenalin": "res://shared_assets/spells/classic_core_1302_adrenalin.gd",
		"Classic Adrenalin Priest": "res://shared_assets/spells/classic_core_2401_adrenalin_priest.gd",
		"Invisible Skin": "res://shared_assets/spells/classic_core_1206_invisible_skin.gd",
		"Multi Invisible Skin": "res://shared_assets/spells/classic_core_1708_multi_invisible_skin.gd",
		"Classic Invisible Skin Priest": "res://shared_assets/spells/classic_core_2208_invisible_skin_priest.gd",
		"Classic Multi Invisible Skin Priest": "res://shared_assets/spells/classic_core_2509_multi_invisible_skin_priest.gd",
		"Puppet Master": "res://shared_assets/spells/classic_core_2410_puppet_master.gd",
		"Classic Puppet Master Enchanter": "res://shared_assets/spells/classic_core_3610_puppet_master_enchanter.gd",
		"Statue": "res://shared_assets/spells/classic_core_2608_statue.gd",
		"Classic Statue Enchanter": "res://shared_assets/spells/classic_core_3411_statue_enchanter.gd",
		"Blind": "res://shared_assets/spells/classic_core_2402_blind.gd",
		"Festering Wounds": "res://shared_assets/spells/festering_wounds.gd",
		"Disease": "res://shared_assets/spells/classic_core_2502_disease.gd",
		"Minor Spell Deflector": "res://shared_assets/spells/minor_spell_deflector.gd",
		"Classic Minor Spell Deflector Priest Enchanter": "res://shared_assets/spells/classic_core_2406_minor_spell_deflector.gd",
		"Major Spell Deflector": "res://shared_assets/spells/major_spell_deflector.gd",
		"Classic Major Spell Deflector Priest Enchanter": "res://shared_assets/spells/classic_core_2603_major_spell_deflector.gd",
		"Minor Attack Deflector": "res://shared_assets/spells/minor_attack_deflector.gd",
		"Classic Minor Attack Deflector Enchanter": "res://shared_assets/spells/classic_core_3408_minor_attack_deflector.gd",
		"Major Attack Deflector": "res://shared_assets/spells/major_attack_deflector.gd",
		"Classic Major Attack Deflector Priest": "res://shared_assets/spells/classic_core_2506_major_attack_deflector.gd",
		"Classic Major Attack Deflector Enchanter": "res://shared_assets/spells/classic_core_3608_major_attack_deflector.gd",
		"Enchanted Blade": "res://shared_assets/spells/enchanted_blade.gd",
		"Classic Enchanted Blade": "res://shared_assets/spells/classic_enchanted_blade.gd",
		"Classic Enchanted Blades Priest": "res://shared_assets/spells/classic_core_2503_enchanted_blades.gd",
		"Enchanted Blades": "res://shared_assets/spells/enchanted_blades.gd",
		"Power Gather": "res://shared_assets/spells/power_gather.gd",
		"Classic Power Gather Enchanter": "res://shared_assets/spells/classic_core_3510_power_gather_enchanter.gd",
		"Power Wither": "res://shared_assets/spells/power_wither.gd",
		"Spirit Drain": "res://shared_assets/spells/spirit_drain.gd",
		"Classic Power Wither Enchanter": "res://shared_assets/spells/classic_core_3511_power_wither_enchanter.gd",
		"Arcanic Bubble": "res://shared_assets/spells/arcanic_bubble.gd",
		"Improved Arcanic Bubble": "res://shared_assets/spells/improved_arcanic_bubble.gd",
		"Classic Improved Arcanic Bubble Priest": "res://shared_assets/spells/classic_core_2702_improved_arcanic_bubble_priest.gd",
		"Classic Arcanic Bubble Enchanter": "res://shared_assets/spells/classic_core_3302_arcanic_bubble_enchanter.gd",
		"Itching Skin": "res://shared_assets/spells/itching_skin.gd",
		"Shrink Foe": "res://shared_assets/spells/shrink_foe.gd",
		"Shield from Projectiles": "res://shared_assets/spells/shield_from_projectiles.gd",
		"Vorpal Plate": "res://shared_assets/spells/vorpal_plate.gd",
		"Classic Vorpal Plate Enchanter": "res://shared_assets/spells/classic_core_3212_vorpal_plate_enchanter.gd",
		"Major Vorpal Plate": "res://shared_assets/spells/major_vorpal_plate.gd",
		"Waterworld": "res://shared_assets/spells/waterworld.gd",
		"Vorpal Shield": "res://shared_assets/spells/vorpal_shield.gd",
		"Ogre Hide": "res://shared_assets/spells/ogre_hide.gd",
		"Dragon Hide": "res://shared_assets/spells/dragon_hide.gd",
		"Free Fall": "res://shared_assets/spells/free_fall.gd",
		"Hover": "res://shared_assets/spells/hover.gd",
		"Discover Secret": "res://shared_assets/spells/discover_secret.gd",
		"Wizard Eye": "res://shared_assets/spells/wizard_eye.gd",
		"Thought Lace": "res://shared_assets/spells/thought_lace.gd",
		"Sentry": "res://shared_assets/spells/sentry.gd",
		"Classic Sentry Priest": "res://shared_assets/spells/classic_core_2710_sentry_priest.gd",
		"Missile Screen": "res://shared_assets/spells/missile_screen.gd",
		"Silence": "res://shared_assets/spells/silence.gd",
		"Classic Silence Sorcerer": "res://shared_assets/spells/classic_core_1411_silence_sorcerer.gd",
		"Major Charm Foe": "res://shared_assets/spells/major_charm_foe.gd",
		"Classic Major Charm Foe Priest": "res://shared_assets/spells/classic_major_charm_foe_priest.gd",
		"Classic Multi Mutiny Sorcerer": "res://shared_assets/spells/classic_multi_mutiny_sorcerer.gd",
		"Multi Mutiny": "res://shared_assets/spells/multi_mutiny.gd",
		"Multi Sandman": "res://shared_assets/spells/classic_core_1710_multi_sandman.gd",
		"Sandman": "res://shared_assets/spells/classic_core_2310_sandman.gd",
		"Major Soul Bind": "res://shared_assets/spells/major_soul_bind.gd",
		"Paralyzing Wall": "res://shared_assets/spells/classic_core_2510_paralyzing_wall.gd",
		"Time Trap": "res://shared_assets/spells/classic_core_2610_time_trap.gd",
		"Noxious Cloud": "res://shared_assets/spells/classic_core_3209_noxious_cloud.gd",
		"Classic Slug Sorcerer": "res://shared_assets/spells/classic_core_1311_slug_sorcerer.gd",
		"Slug": "res://shared_assets/spells/classic_core_2311_slug_priest.gd",
		"Dumbstruck": "res://shared_assets/spells/classic_core_2203_dumbstruck.gd",
		"Mind Blank": "res://shared_assets/spells/classic_core_3407_mind_blank.gd",
		"Magic Aura": "res://shared_assets/spells/magic_aura.gd",
		"Poison": "res://shared_assets/spells/poison.gd",
		"Identify Objects": "res://shared_assets/spells/identify_objects.gd",
		"Banish": "res://shared_assets/spells/banish.gd",
		"Death": "res://shared_assets/spells/death.gd",
		"Finger of Death": "res://shared_assets/spells/finger_of_death.gd",
		"Poison Cloud": "res://shared_assets/spells/poison_cloud.gd",
		"Transmute Other": "res://shared_assets/spells/transmute_other.gd",
		"Multi Morph Other": "res://shared_assets/spells/multi_morph_other.gd",
	}
	_expect_equal(
		migrated_native_paths.size(),
		183,
		"every reviewed spell implementation has a native resource"
	)
	_test_parameterized_damage_spells()
	_test_flame_missile()
	_test_stun_corrected_helplessness()
	_test_encounter_response_spells()
	var runtime_spell_resources = NativeResourcesScript.new()
	runtime_spell_resources.load_spell_resources("res://shared_assets/spells/")
	for spell_name: String in migrated_native_paths:
		var runtime_spell: Variant = runtime_spell_resources.spells_book.get(
			spell_name, {}
		).get("script")
		_expect(runtime_spell is Spell, "%s loads through the normal spell book" % spell_name)
		_expect_equal(
			runtime_spell.get_script().resource_path if runtime_spell is Spell else "",
			migrated_native_paths[spell_name],
			"%s remains native after the generic catalog merge" % spell_name
		)
	runtime_spell_resources.free()
	_expect(energy_storm.supports_classic_spell_id(1103), "Energy Storm exports its exact ID")
	_expect_equal(energy_storm.classic_spell_class, 6, "Energy Storm preserves its class")
	_expect_equal(energy_storm.classic_spell_save_index, 6, "Energy Storm uses the magic save")
	_expect_equal(
		energy_storm.classic_spell_save_mode,
		"half_damage",
		"Energy Storm halves damage on a save"
	)
	_expect_equal(energy_storm.get_range(7, null), 7, "Energy Storm keeps its source range")
	_expect_equal(energy_storm.get_min_damage(3, null), 3, "Energy Storm minimum scales")
	_expect_equal(energy_storm.get_max_damage(3, null), 9, "Energy Storm maximum scales")
	_expect_equal(energy_storm.get_sp_cost(3, null), 30, "Energy Storm cost scales")
	_expect_equal(energy_storm.get_aoe(1, null), Spell.AoE_ROUND, "Energy Storm keeps size 9")
	_expect_equal(flame_hands.classic_spell_save_index, 1, "Flame Hands uses the fire save")
	_expect_equal(
		flame_hands.classic_spell_save_mode,
		"half_damage",
		"Flame Hands halves damage on a save"
	)
	_expect_equal(
		flame_hands.resist,
		Spell.RESIST_TYPE.IGNORE_DODGE,
		"Flame Hands checks Classic resistance without projectile dodge"
	)

	_expect(
		sparkling_armor.supports_classic_spell_id(1111),
		"Sparkling Armor exports its exact ID"
	)
	_expect_equal(sparkling_armor.classic_spell_class, 8, "Sparkling Armor preserves its class")
	_expect(sparkling_armor.in_field and sparkling_armor.in_combat, "Sparkling Armor is available")
	_expect(sparkling_armor.skip_targeting, "Sparkling Armor targets its caster")
	_expect_equal(
		sparkling_armor.autotarget_type,
		Spell.AUTOTARGET_TYPE.SELF,
		"Sparkling Armor uses self targeting"
	)
	_expect_equal(sparkling_armor.get_duration_roll(3, null), 3, "Sparkling Armor duration scales")
	_expect_equal(sparkling_armor.get_sp_cost(3, null), 6, "Sparkling Armor cost scales")
	var armored_target := SpellScreenTestCharacter.new("Armored target", true)
	armored_target.stats = {"EvasionMelee": 0, "EvasionRanged": 0}
	_expect_equal(
		sparkling_armor.apply_classic_scaled_effect(null, armored_target, 3, 1.0),
		3,
		"Sparkling Armor applies its source condition"
	)
	_expect_equal(armored_target.traits.size(), 1, "Sparkling Armor applies one trait")
	_expect(
		str(armored_target.traits[0].name).ends_with("t_pro_hits.gd"),
		"Sparkling Armor uses the protection-from-hits adapter"
	)
	_expect_equal(
		armored_target.traits[0].get_saved_variables(),
		[3],
		"Sparkling Armor preserves its condition duration"
	)

	_expect(flame_spikes.supports_classic_spell_id(1203), "Flame Spikes exports its exact ID")
	_expect_equal(flame_spikes.classic_spell_class, 1, "Flame Spikes preserves its class")
	_expect_equal(flame_spikes.classic_save_bonus, 10, "Flame Spikes preserves its save bonus")
	_expect(flame_spikes.skip_targeting, "Flame Spikes needs no target selection")
	_expect_equal(
		flame_spikes.autotarget_type,
		Spell.AUTOTARGET_TYPE.ALL_ENEMIES,
		"Flame Spikes targets every enemy"
	)
	_expect(not flame_spikes.los, "Flame Spikes does not require line of sight")
	_expect_equal(flame_spikes.get_min_damage(3, null), 3, "Flame Spikes minimum scales")
	_expect_equal(flame_spikes.get_max_damage(3, null), 12, "Flame Spikes maximum scales")
	_expect_equal(flame_spikes.get_sp_cost(3, null), 75, "Flame Spikes cost scales")
	var save_target := RogueTestCharacter.new()
	save_target.stat_values["MultiplierFire"] = 1.0
	save_target.stat_values["ResistanceFire"] = 0.0
	var saved: Dictionary = SpellSavesScript.target_resolution(
		save_target,
		flame_spikes,
		3,
		10
	)
	_expect_equal(saved.get("saveChance"), 10.0, "native save includes the base bonus")
	_expect(saved.get("saved"), "Flame Spikes' +10 save bonus is executable")
	_expect_equal(saved.get("effectScale"), 0.5, "Flame Spikes save halves damage")

	_expect_equal(frozen_palm.classic_spell_ids, [1204], "Frozen Palm exact ID")
	_expect_equal(frozen_palm.classic_spell_class, 2, "Frozen Palm class")
	_expect_equal(frozen_palm.classic_spell_save_index, 2, "Frozen Palm cold save")
	_expect_equal(
		frozen_palm.classic_spell_save_mode,
		"half_damage",
		"Frozen Palm halves damage on a save"
	)
	_expect_equal(
		frozen_palm.resist,
		Spell.RESIST_TYPE.IGNORE_DODGE,
		"Frozen Palm checks Classic resistance without projectile dodge"
	)
	_expect_equal(frozen_palm.get_range(7, null), 1, "Frozen Palm keeps touch range")
	_expect_equal(frozen_palm.get_min_damage(3, null), 6, "Frozen Palm minimum scales")
	_expect_equal(frozen_palm.get_max_damage(3, null), 12, "Frozen Palm maximum scales")
	var frozen_damage: int = frozen_palm.get_damage_roll(3, null)
	_expect(
		frozen_damage >= 6 and frozen_damage <= 12,
		"Frozen Palm rolls 2-4 damage per power"
	)
	_expect_equal(frozen_palm.get_sp_cost(3, null), 9, "Frozen Palm cost scales")
	var cold_save_target := RogueTestCharacter.new()
	cold_save_target.stat_values["MultiplierIce"] = 1.0
	cold_save_target.stat_values["ResistanceIce"] = 10.0
	var cold_save: Dictionary = SpellSavesScript.target_resolution(
		cold_save_target,
		frozen_palm,
		3,
		100
	)
	_expect(cold_save.get("saved"), "Frozen Palm cold save is executable")
	_expect_equal(cold_save.get("effectScale"), 0.5, "cold save halves Frozen Palm")

	_expect_equal(magic_grip.classic_spell_ids, [1209], "Magic Grip exact ID")
	_expect_equal(magic_grip.classic_spell_class, 6, "Magic Grip class")
	_expect_equal(magic_grip.classic_spell_save_index, -1, "Magic Grip has no DRV save")
	_expect_equal(magic_grip.classic_spell_save_mode, "none", "Magic Grip bypasses DRVs")
	_expect_equal(
		magic_grip.resist,
		Spell.RESIST_TYPE.IGNORE_DODGE,
		"Magic Grip checks Classic resistance without projectile dodge"
	)
	_expect(
		MagicResistanceScript.spell_uses_resistance(magic_grip),
		"Magic Grip still checks general magic resistance"
	)
	_expect_equal(magic_grip.get_range(7, null), 1, "Magic Grip keeps touch range")
	_expect_equal(magic_grip.get_min_damage(3, null), 6, "Magic Grip minimum scales")
	_expect_equal(magic_grip.get_max_damage(3, null), 18, "Magic Grip maximum scales")
	var grip_damage: int = magic_grip.get_damage_roll(3, null)
	_expect(grip_damage >= 6 and grip_damage <= 18, "Magic Grip rolls 2-6 per power")
	_expect_equal(magic_grip.get_sp_cost(3, null), 12, "Magic Grip cost scales")
	var no_grip_save: Dictionary = SpellSavesScript.target_resolution(
		cold_save_target,
		magic_grip,
		3,
		1
	)
	_expect(not no_grip_save.get("saved"), "Magic Grip ignores a target's DRV chance")
	_expect_equal(no_grip_save.get("effectScale"), 1.0, "Magic Grip applies full damage")

	var scorched_earth = load("res://shared_assets/spells/scorched_earth.gd").new()
	_expect(scorched_earth.ray, "Scorched Earth uses native ray targeting")
	_expect_equal(scorched_earth.get_range(3, null), 6, "Scorched Earth range scales")
	_expect_equal(scorched_earth.get_min_damage(7, null), 2, "Scorched Earth minimum is fixed")
	_expect_equal(scorched_earth.get_max_damage(1, null), 10, "Scorched Earth maximum is fixed")
	_expect_equal(scorched_earth.get_sp_cost(3, null), 30, "Scorched Earth cost scales")

	var radiate = load("res://shared_assets/spells/radiate.gd").new()
	_expect(radiate.skip_targeting, "zero-range Radiate centers on its caster")
	_expect_equal(
		radiate.autotarget_type,
		Spell.AUTOTARGET_TYPE.SELF,
		"Radiate uses native self targeting"
	)
	_expect_equal(radiate.get_aoe(7, null), Spell.AoE_RADIANT, "Radiate hits adjacent tiles")
	_expect_equal(radiate.classic_save_bonus, -10, "Radiate preserves its save penalty")
	_expect_equal(radiate.get_min_damage(3, null), 6, "Radiate minimum scales")
	_expect_equal(radiate.get_max_damage(3, null), 45, "Radiate maximum scales")
	_expect_equal(radiate.get_sp_cost(3, null), 75, "Radiate cost scales")

	var cosmic_blast = load("res://shared_assets/spells/cosmic_blast.gd").new()
	_expect(cosmic_blast.skip_targeting, "Cosmic Blast needs no target selection")
	_expect_equal(
		cosmic_blast.classic_spell_ids,
		[1401, 3303],
		"equivalent Sorcerer and Enchanter Cosmic Blast records share one resource"
	)
	_expect_equal(
		cosmic_blast.autotarget_type,
		Spell.AUTOTARGET_TYPE.ALL_ENEMIES,
		"Cosmic Blast targets every enemy"
	)
	_expect_equal(cosmic_blast.classic_spell_save_index, 6, "Cosmic Blast uses magic saves")
	_expect_equal(cosmic_blast.get_min_damage(3, null), 6, "Cosmic Blast minimum scales")
	_expect_equal(cosmic_blast.get_max_damage(3, null), 12, "Cosmic Blast maximum scales")
	_expect_equal(cosmic_blast.get_sp_cost(3, null), 90, "Cosmic Blast cost scales")

	var flame_tongue = load("res://shared_assets/spells/flame_tongue.gd").new()
	_expect(flame_tongue.ray, "Flame Tongue uses native ray targeting")
	_expect_equal(flame_tongue.get_range(3, null), 6, "Flame Tongue range scales")
	_expect_equal(flame_tongue.get_min_damage(7, null), 8, "Flame Tongue minimum is fixed")
	_expect_equal(flame_tongue.get_max_damage(1, null), 16, "Flame Tongue maximum is fixed")
	_expect_equal(flame_tongue.get_sp_cost(3, null), 54, "Flame Tongue cost scales")

	var native_direct_damage_expectations := {
		3105: ["Lightning Strike", 20, 3, 18, 15, 3, "half_damage", false, "lightning_strike.gd"],
		3506: ["Finger of Pain", 8, 35, 35, 105, -1, "none", true, "finger_of_pain.gd"],
	}
	for spell_id: int in native_direct_damage_expectations:
		var expected: Array = native_direct_damage_expectations[spell_id]
		var spell = load("res://shared_assets/spells/" + str(expected[8])).new()
		var label := str(expected[0])
		_expect(spell.supports_classic_spell_id(spell_id), "%s exports its exact ID" % label)
		_expect_equal(spell.get_range(3, null), expected[1], "%s range" % label)
		_expect_equal(spell.get_min_damage(3, null), expected[2], "%s minimum damage" % label)
		_expect_equal(spell.get_max_damage(3, null), expected[3], "%s maximum damage" % label)
		var rolled_damage: int = spell.get_damage_roll(3, null)
		_expect(
			rolled_damage >= int(expected[2]) and rolled_damage <= int(expected[3]),
			"%s damage roll stays within its source range" % label
		)
		_expect_equal(spell.get_sp_cost(3, null), expected[4], "%s spell-point cost" % label)
		_expect_equal(spell.classic_spell_save_index, expected[5], "%s save index" % label)
		_expect_equal(spell.classic_spell_save_mode, expected[6], "%s save mode" % label)
		_expect_equal(spell.los, expected[7], "%s line-of-sight rule" % label)
		_expect_equal(
			spell.targettile,
			Spell.TARGET_TILE.CREATURE,
			"%s targets a single creature" % label
		)
		_expect_equal(
			spell.resist,
			Spell.RESIST_TYPE.IGNORE_DODGE,
			"%s checks Classic general resistance" % label
		)

	var native_area_expectations := {
		1203: ["Flame Spikes", 0, 3, 12, 75, 1, "half_damage", "flame_spikes.gd"],
		1212: ["Shiver", 0, 3, 6, 60, -1, "none", "shiver.gd"],
		1306: ["Fireball", 15, 1, 16, 27, 1, "half_damage", "fireball.gd"],
		1310: ["Radiate", 0, 6, 45, 75, 6, "half_damage", "radiate.gd"],
		1401: ["Cosmic Blast", 0, 6, 12, 90, 6, "half_damage", "cosmic_blast.gd"],
		2101: ["Brimstones", 10, 1, 4, 9, 1, "half_damage", "brimstones.gd"],
		3211: ["Steel Rain", 15, 2, 8, 21, 7, "half_damage", "steel_rain.gd"],
		3401: ["Acid Rain", 8, 3, 16, 36, 4, "half_damage", "acid_rain.gd"],
		3704: ["Mind Rash", 0, 16, 28, 270, 5, "half_damage", "mind_rash.gd"],
	}
	for spell_id: int in native_area_expectations:
		var expected: Array = native_area_expectations[spell_id]
		var spell = load("res://shared_assets/spells/" + str(expected[7])).new()
		var label := str(expected[0])
		_expect(spell.supports_classic_spell_id(spell_id), "%s exports its exact ID" % label)
		_expect_equal(spell.get_range(3, null), expected[1], "%s range" % label)
		_expect_equal(spell.get_min_damage(3, null), expected[2], "%s minimum damage" % label)
		_expect_equal(spell.get_max_damage(3, null), expected[3], "%s maximum damage" % label)
		var rolled_damage: int = spell.get_damage_roll(3, null)
		_expect(
			rolled_damage >= int(expected[2]) and rolled_damage <= int(expected[3]),
			"%s damage roll stays within its source range" % label
		)
		_expect_equal(spell.get_sp_cost(3, null), expected[4], "%s spell-point cost" % label)
		_expect_equal(spell.classic_spell_save_index, expected[5], "%s save index" % label)
		_expect_equal(spell.classic_spell_save_mode, expected[6], "%s save mode" % label)
		_expect_equal(
			spell.targettile,
			Spell.TARGET_TILE.NOWALL,
			"%s uses area-compatible tile targeting" % label
		)
		_expect_equal(
			spell.resist,
			Spell.RESIST_TYPE.IGNORE_DODGE,
			"%s checks Classic general resistance" % label
		)

	var native_ray_expectations := {
		1211: ["Scorched Earth", 6, 2, 10, 30, 1, true, "scorched_earth.gd"],
		1303: ["Deep Freeze", 10, 3, 30, 45, 2, false, "deep_freeze.gd"],
		1402: ["Flame Tongue", 6, 8, 16, 54, 1, true, "flame_tongue.gd"],
		1504: ["Flash", 10, 6, 45, 90, 6, true, "flash.gd"],
		1701: ["Arctic Wind", 15, 60, 120, 180, 2, false, "arctic_wind.gd"],
		3207: ["Heat Ray", 6, 2, 8, 30, 1, true, "heat_ray.gd"],
		3301: ["Acid Splash", 9, 6, 18, 30, 4, true, "acid_splash.gd"],
		3308: ["Lightning Bolt", 6, 3, 18, 30, 3, true, "lightning_bolt.gd"],
		3712: ["Vapor Trail", 6, 40, 65, 135, 4, false, "vapor_trail.gd"],
	}
	for spell_id: int in native_ray_expectations:
		var expected: Array = native_ray_expectations[spell_id]
		var spell = load("res://shared_assets/spells/" + str(expected[7])).new()
		var label := str(expected[0])
		_expect(spell != null, "%s is executable" % label)
		_expect(spell.supports_classic_spell_id(spell_id), "%s exports its exact ID" % label)
		_expect(spell.ray, "%s uses ray targeting" % label)
		_expect_equal(spell.get_range(3, null), expected[1], "%s range" % label)
		_expect_equal(spell.get_min_damage(3, null), expected[2], "%s minimum damage" % label)
		_expect_equal(spell.get_max_damage(3, null), expected[3], "%s maximum damage" % label)
		var rolled_damage: int = spell.get_damage_roll(3, null)
		_expect(
			rolled_damage >= int(expected[2]) and rolled_damage <= int(expected[3]),
			"%s damage roll stays within its source range" % label
		)
		_expect_equal(spell.get_sp_cost(3, null), expected[4], "%s spell-point cost" % label)
		_expect_equal(spell.classic_spell_save_index, expected[5], "%s save index" % label)
		_expect_equal(spell.classic_spell_save_mode, "half_damage", "%s save mode" % label)
		_expect_equal(spell.los, expected[6], "%s line-of-sight rule" % label)
		_expect_equal(
			spell.targettile,
			Spell.TARGET_TILE.NOWALL,
			"%s uses ray-compatible tile targeting" % label
		)
		_expect_equal(
			spell.resist,
			Spell.RESIST_TYPE.IGNORE_DODGE,
			"%s checks Classic general resistance" % label
		)
	var opposed_spell_expectations := {
		2109: ["Psionic Spear", 9, 1, 3, 12, true, "psionic_spear.gd", Spell.TARGET_TILE.NOWALL],
		2306: ["Mind Duel", 12, 12, 30, 30, false, "mind_duel.gd", Spell.TARGET_TILE.CREATURE],
		2605: ["Psi Wave", 0, 15, 30, 90, false, "psi_wave.gd", Spell.TARGET_TILE.NOWALL],
		2706: ["Mind Melt", 9, 25, 35, 120, true, "mind_melt.gd", Spell.TARGET_TILE.NOWALL],
	}
	for spell_id: int in opposed_spell_expectations:
		var expected: Array = opposed_spell_expectations[spell_id]
		var spell = load("res://shared_assets/spells/" + str(expected[6])).new()
		var label := str(expected[0])
		_expect(spell.uses_classic_opposed_level_check(), "%s uses a level contest" % label)
		_expect_equal(spell.classic_spell_save_index, 5, "%s also uses mental saves" % label)
		_expect_equal(spell.classic_spell_save_mode, "half_damage", "%s save halves damage" % label)
		_expect_equal(spell.get_range(3, null), expected[1], "%s range" % label)
		_expect_equal(spell.get_min_damage(3, null), expected[2], "%s minimum damage" % label)
		_expect_equal(spell.get_max_damage(3, null), expected[3], "%s maximum damage" % label)
		_expect_equal(spell.get_sp_cost(3, null), expected[4], "%s spell-point cost" % label)
		var rolled_damage: int = spell.get_damage_roll(3, null)
		_expect(
			rolled_damage >= int(expected[2]) and rolled_damage <= int(expected[3]),
			"%s damage roll stays within its source range" % label
		)
		_expect_equal(spell.ray, expected[5], "%s ray rule" % label)
		_expect_equal(spell.targettile, expected[7], "%s target type" % label)
		_expect(not spell.los, "%s does not require line of sight" % label)
		_expect_equal(
			spell.resist,
			Spell.RESIST_TYPE.IGNORE_DODGE,
			"%s also checks Classic general resistance" % label
		)
	var psi_wave = load("res://shared_assets/spells/psi_wave.gd").new()
	_expect(psi_wave.skip_targeting, "Psi Wave needs no target selection")
	_expect_equal(
		psi_wave.autotarget_type,
		Spell.AUTOTARGET_TYPE.ALL_ENEMIES,
		"Psi Wave targets every enemy"
	)

	var shiver = load("res://shared_assets/spells/shiver.gd").new()
	_expect(shiver.skip_targeting, "Shiver needs no target selection")
	_expect_equal(
		shiver.autotarget_type,
		Spell.AUTOTARGET_TYPE.ALL_ENEMIES,
		"Shiver targets every enemy"
	)
	_expect_equal(
		shiver.resist,
		Spell.RESIST_TYPE.IGNORE_DODGE,
		"Shiver checks general resistance without a DRV save"
	)
	_expect_equal(frostbite.get_range(3, null), 1, "Frostbite range")
	_expect_equal(frostbite.get_min_damage(3, null), 30, "Frostbite minimum damage")
	_expect_equal(frostbite.get_max_damage(3, null), 60, "Frostbite maximum damage")
	_expect_equal(frostbite.get_sp_cost(3, null), 60, "Frostbite spell-point cost")
	_expect_equal(frostbite.classic_spell_save_index, 2, "Frostbite save index")
	_expect_equal(frostbite.classic_spell_save_mode, "half_damage", "Frostbite save mode")
	_expect_equal(
		frostbite.resist,
		Spell.RESIST_TYPE.IGNORE_MRES_DODGE,
		"Frostbite's cannot-resist flag bypasses general resistance"
	)
	for area_spell_path: String in ["brimstones.gd", "steel_rain.gd", "acid_rain.gd"]:
		var area_spell = load("res://shared_assets/spells/" + area_spell_path).new()
		_expect_equal(
			area_spell.get_aoe(3, null),
			Spell.AoE_b3,
			"%s area grows with power" % area_spell.name
		)
	var lightning_strike = load("res://shared_assets/spells/lightning_strike.gd").new()
	_expect(not lightning_strike.los, "negative Classic range bypasses line of sight")
	_expect_equal(shock_palm.get_range(3, null), 1, "Shock Palm range")
	_expect_equal(shock_palm.get_min_damage(3, null), 16, "Shock Palm minimum damage")
	_expect_equal(shock_palm.get_max_damage(3, null), 22, "Shock Palm maximum damage")
	_expect_equal(shock_palm.get_sp_cost(3, null), 45, "Shock Palm spell-point cost")
	_expect_equal(shock_palm.classic_spell_save_index, 3, "Shock Palm save index")
	_expect_equal(shock_palm.classic_spell_save_mode, "half_damage", "Shock Palm save mode")
	_expect_equal(shock_palm.classic_save_adjust, -5, "Shock Palm scales its save penalty")
	_expect_equal(
		shock_palm.classic_resist_adjust,
		-5,
		"Shock Palm scales its resistance penalty"
	)
	for touch_spell in [flame_hands, frozen_palm, magic_grip, frostbite, shock_palm]:
		_expect_equal(
			touch_spell.targettile,
			Spell.TARGET_TILE.CREATURE,
			"%s targets a single creature" % touch_spell.name
		)
	var mind_rash = load("res://shared_assets/spells/mind_rash.gd").new()
	_expect(mind_rash.skip_targeting, "Mind Rash needs no target selection")
	_expect_equal(
		mind_rash.autotarget_type,
		Spell.AUTOTARGET_TYPE.ALL_ENEMIES,
		"Mind Rash targets every enemy"
	)
	_expect_equal(mind_rash.classic_save_adjust, -2, "Mind Rash scales its save penalty")

	_expect(
		CoreSpellCatalogScript.records().is_empty(),
		"native spell resources replace the generic core runtime catalog"
	)

	var charm_foe = load("res://shared_assets/spells/charm_foe.gd").new()
	var major_charm = load("res://shared_assets/spells/major_charm_foe.gd").new()
	var sorcerer_mutiny = load(
		"res://shared_assets/spells/classic_multi_mutiny_sorcerer.gd"
	).new()
	var priest_major_charm = load(
		"res://shared_assets/spells/classic_major_charm_foe_priest.gd"
	).new()
	var priest_mutiny = load("res://shared_assets/spells/multi_mutiny.gd").new()
	var enchanter_charm = load(
		"res://shared_assets/spells/classic_charm_foe_enchanter.gd"
	).new()
	_expect_equal(charm_foe.classic_spell_ids, [1501, 2201], "Charm Foe exact IDs")
	_expect_equal(
		charm_foe.classic_spell_response_ids,
		[1501, 2201, 3603],
		"learned Charm Foe answers all equivalent encounter variants"
	)
	_expect_equal(charm_foe.classic_spell_save_index, -1, "Charm Foe has no DRV save")
	_expect(not charm_foe.los, "Charm Foe keeps its no-LOS range")
	_expect_equal(charm_foe.get_range(7, null), 8, "Charm Foe keeps its range")
	_expect_equal(charm_foe.get_sp_cost(3, null), 45, "Charm Foe cost scales")
	_expect_equal(enchanter_charm.classic_spell_ids, [3603], "Enchanter Charm exact ID")
	_expect_equal(enchanter_charm.schools, [], "exact Enchanter variant stays hidden")
	_expect_equal(
		enchanter_charm.get_sp_cost(3, null),
		90,
		"Enchanter Charm preserves its distinct cost"
	)
	_expect_equal(major_charm.classic_spell_ids, [1607], "Major Charm Foe exact ID")
	_expect_equal(major_charm.classic_special, 51, "Major Charm Foe special")
	_expect_equal(major_charm.classic_target_type, 3, "Major Charm Foe target type")
	_expect_equal(major_charm.classic_size, 7, "Major Charm Foe area-mask ID")
	_expect_equal(major_charm.get_aoe(1, null), Spell.AoE_b7, "Major Charm Foe area")
	_expect_equal(major_charm.get_range(7, null), 8, "Major Charm Foe range")
	_expect_equal(major_charm.get_sp_cost(3, null), 135, "Major Charm Foe cost")
	_expect_equal(major_charm.school_levels.get("Sorcerer"), 6, "Major Charm Foe level")
	_expect_equal(major_charm.selection_costs.get("Sorcerer"), 21, "Major Charm Foe selection cost")
	_expect(not major_charm.los, "Major Charm Foe keeps its no-LOS range")
	var charm_caster := CharmTestCharacter.new("Caster", 0)
	var charmed_target := CharmTestCharacter.new("Target", 1)
	charm_foe.add_traits_to_creature(charm_caster, charmed_target, 1)
	_expect_equal(charmed_target.curFaction, 0, "Charm Foe adopts the caster's faction")
	_expect_equal(charmed_target.traits.size(), 1, "Charm Foe applies one battle trait")
	var second_charmer := CharmTestCharacter.new("Second caster", 2)
	charmed_target.add_trait(
		load("res://shared_assets/traits/t_classic_charmed.gd"),
		[second_charmer]
	)
	_expect_equal(charmed_target.curFaction, 2, "recasting Charm updates the allegiance")
	charmed_target.traits[0]._on_battle_end(charmed_target)
	_expect_equal(charmed_target.curFaction, 1, "Charm restores the base faction after battle")
	_expect(charmed_target.traits.is_empty(), "battle cleanup removes Classic Charm")
	var major_charmed_target := CharmTestCharacter.new("Major target", 1)
	_expect(
		major_charm.apply_classic_scaled_effect(charm_caster, major_charmed_target, 3, 1.0),
		"Major Charm Foe applies the shared battle-charm trait"
	)
	_expect_equal(major_charmed_target.curFaction, 0, "Major Charm Foe adopts caster faction")
	var resisted_major_charm := CharmTestCharacter.new("Resisted target", 1)
	_expect(
		not major_charm.apply_classic_scaled_effect(
			charm_caster, resisted_major_charm, 3, 0.0
		),
		"a resisted Major Charm Foe applies no trait"
	)
	_expect(resisted_major_charm.traits.is_empty(), "resisted Major Charm leaves no trait")
	_expect_equal(sorcerer_mutiny.classic_spell_ids, [1709], "Sorcerer Multi Mutiny exact ID")
	_expect_equal(sorcerer_mutiny.classic_special, 52, "Sorcerer Multi Mutiny special")
	_expect_equal(sorcerer_mutiny.classic_target_type, 4, "Sorcerer Multi Mutiny target type")
	_expect_equal(sorcerer_mutiny.get_aoe(3, null), Spell.AoE_b3, "Sorcerer Multi Mutiny area")
	_expect_equal(sorcerer_mutiny.get_range(3, null), 15, "Sorcerer Multi Mutiny range")
	_expect_equal(sorcerer_mutiny.get_sp_cost(3, null), 150, "Sorcerer Multi Mutiny cost")
	_expect_equal(sorcerer_mutiny.school_levels.get("Sorcerer"), 7, "Sorcerer Multi Mutiny level")
	_expect_equal(sorcerer_mutiny.selection_costs.get("Sorcerer"), 28, "Sorcerer Multi Mutiny selection cost")
	_expect_equal(sorcerer_mutiny.classic_spell_look_ids, [14, 11], "Sorcerer Multi Mutiny art")
	_expect_equal(sorcerer_mutiny.classic_sound_ids, [28, 13], "Sorcerer Multi Mutiny sounds")
	_expect_equal(priest_major_charm.classic_spell_ids, [2507], "Priest Major Charm Foe exact ID")
	_expect_equal(priest_major_charm.get_aoe(3, null), Spell.AoE_b3, "Priest Major Charm Foe area")
	_expect_equal(priest_major_charm.get_range(3, null), 8, "Priest Major Charm Foe range")
	_expect_equal(priest_major_charm.get_sp_cost(3, null), 135, "Priest Major Charm Foe cost")
	_expect_equal(priest_major_charm.school_levels.get("Priest"), 5, "Priest Major Charm Foe level")
	_expect_equal(priest_major_charm.selection_costs.get("Priest"), 15, "Priest Major Charm Foe selection cost")
	_expect_equal(priest_major_charm.classic_spell_look_ids, [14, 11], "Priest Major Charm Foe art")
	_expect_equal(priest_major_charm.classic_sound_ids, [13, 21], "Priest Major Charm Foe sounds")
	_expect_equal(priest_mutiny.classic_spell_ids, [2707], "Priest Multi Mutiny exact ID")
	_expect_equal(priest_mutiny.get_aoe(3, null), Spell.AoE_b3, "Priest Multi Mutiny area")
	_expect_equal(priest_mutiny.get_range(3, null), 15, "Priest Multi Mutiny range")
	_expect_equal(priest_mutiny.get_sp_cost(3, null), 150, "Priest Multi Mutiny cost")
	_expect_equal(priest_mutiny.school_levels.get("Priest"), 7, "Priest Multi Mutiny level")
	_expect_equal(priest_mutiny.selection_costs.get("Priest"), 28, "Priest Multi Mutiny selection cost")
	_expect_equal(priest_mutiny.classic_spell_look_ids, [15, 11], "Priest Multi Mutiny art")
	_expect_equal(priest_mutiny.classic_sound_ids, [13, 11], "Priest Multi Mutiny sounds")
	var mutinied_target := CharmTestCharacter.new("Mutinied target", 1)
	_expect(
		priest_mutiny.apply_classic_scaled_effect(charm_caster, mutinied_target, 3, 1.0),
		"Multi Mutiny applies the shared battle-charm trait"
	)
	_expect_equal(mutinied_target.curFaction, 0, "Multi Mutiny adopts caster faction")

	var fearful_thoughts = load("res://shared_assets/spells/fearful_thoughts.gd").new()
	_expect_equal(fearful_thoughts.classic_spell_ids, [2103], "Fearful Thoughts exact ID")
	_expect_equal(fearful_thoughts.classic_spell_class, 5, "Fearful Thoughts class")
	_expect_equal(fearful_thoughts.classic_spell_save_index, 5, "Fearful Thoughts save")
	_expect_equal(
		fearful_thoughts.classic_spell_save_mode,
		"negate",
		"Fearful Thoughts is negated by a successful save"
	)
	_expect(
		fearful_thoughts.uses_classic_opposed_level_check(),
		"Priest Fearful Thoughts I preserves its signed mental level contest"
	)
	_expect(fearful_thoughts.los, "Fearful Thoughts requires line of sight")
	_expect_equal(fearful_thoughts.get_range(7, null), 8, "Fearful Thoughts range")
	_expect_equal(fearful_thoughts.get_duration_roll(3, null), 3, "fear lasts by power")
	_expect_equal(fearful_thoughts.get_sp_cost(3, null), 30, "Fearful Thoughts cost")
	var fleeing_target := ConditionTestCharacter.new("Fleeing target")
	fearful_thoughts.add_traits_to_creature(null, fleeing_target, 3)
	_expect(
		str(fleeing_target.traits[0].name).ends_with("t_fleeing.gd"),
		"Fearful Thoughts uses Remake's fleeing behavior"
	)
	_expect_equal(fleeing_target.traits[0].power, 3, "Fearful Thoughts passes its duration")

	var area_fear = load(
		"res://shared_assets/spells/classic_fearful_thoughts_area.gd"
	).new()
	_expect_equal(
		area_fear.classic_spell_ids,
		[1603, 3505],
		"Sorcerer and Enchanter area Fear share source-equivalent mechanics"
	)
	_expect_equal(area_fear.schools, [], "area Fear remains a compatibility-only resource")
	_expect(
		not area_fear.uses_classic_opposed_level_check(),
		"positive mental damage types omit the opposed-level precheck"
	)
	_expect_equal(area_fear.get_range(3, null), 7, "area Fear keeps its fixed range")
	_expect_equal(area_fear.get_aoe(3, null), Spell.AoE_ROUND, "area Fear uses size 9")
	_expect_equal(area_fear.get_min_duration(3, null), 3, "area Fear minimum duration")
	_expect_equal(area_fear.get_max_duration(3, null), 6, "area Fear maximum duration")
	var area_fear_duration: int = area_fear.get_duration_roll(3, null)
	_expect(
		area_fear_duration >= 3 and area_fear_duration <= 6,
		"area Fear rolls 1-2 rounds per power"
	)
	var area_fleeing_target := ConditionTestCharacter.new("Area fleeing target")
	area_fear.add_traits_to_creature(null, area_fleeing_target, 3)
	_expect_equal(area_fleeing_target.traits.size(), 1, "area Fear applies fleeing")
	_expect(
		area_fleeing_target.traits[0].power >= 3 \
		and area_fleeing_target.traits[0].power <= 6,
		"area Fear applies its rolled duration"
	)
	_expect_equal(area_fear.get_sp_cost(3, null), 105, "area Fear preserves its high cost")

	var priest_area_fear = load(
		"res://shared_assets/spells/classic_fearful_thoughts_priest_area.gd"
	).new()
	_expect_equal(priest_area_fear.classic_spell_ids, [2403], "Priest area Fear exact ID")
	_expect_equal(
		priest_area_fear.schools,
		[],
		"Priest area Fear remains a compatibility-only resource"
	)
	_expect(
		priest_area_fear.uses_classic_opposed_level_check(),
		"Priest area Fear preserves its signed mental level contest"
	)
	_expect_equal(priest_area_fear.get_range(3, null), 7, "Priest area Fear range")
	_expect_equal(
		priest_area_fear.get_aoe(3, null),
		Spell.AoE_ROUND,
		"Priest area Fear uses size 9"
	)
	_expect_equal(
		priest_area_fear.get_duration_roll(3, null),
		3,
		"Priest area Fear lasts one round per power"
	)
	_expect_equal(priest_area_fear.get_sp_cost(3, null), 45, "Priest area Fear cost")

	var soul_bind = load("res://shared_assets/spells/soul_bind.gd").new()
	var major_soul_bind = load("res://shared_assets/spells/major_soul_bind.gd").new()
	_expect_equal(soul_bind.classic_spell_ids, [2111], "Soul Bind exact ID")
	_expect_equal(soul_bind.classic_spell_class, 5, "Soul Bind class")
	_expect_equal(soul_bind.classic_spell_save_index, 5, "Soul Bind save")
	_expect(not soul_bind.los, "Soul Bind keeps its no-LOS range")
	_expect_equal(soul_bind.get_range(7, null), 8, "Soul Bind range")
	_expect_equal(soul_bind.get_min_duration(7, null), 2, "Soul Bind minimum duration")
	_expect_equal(soul_bind.get_max_duration(1, null), 4, "Soul Bind maximum duration")
	_expect_equal(soul_bind.get_sp_cost(3, null), 45, "Soul Bind cost")
	var helpless_target := ConditionTestCharacter.new("Helpless target")
	soul_bind.add_traits_to_creature(null, helpless_target, 7)
	_expect(
		str(helpless_target.traits[0].name).ends_with("t_helpless.gd"),
		"Soul Bind uses Remake's helpless behavior"
	)
	_expect(
		helpless_target.traits[0].power >= 2 and helpless_target.traits[0].power <= 4,
		"Soul Bind passes its source duration roll"
	)
	_expect_equal(major_soul_bind.classic_spell_ids, [2405], "Major Soul Bind exact ID")
	_expect_equal(major_soul_bind.classic_special, 53, "Major Soul Bind special")
	_expect_equal(major_soul_bind.classic_target_type, 4, "Major Soul Bind target type")
	_expect_equal(major_soul_bind.classic_raw_damage_type, -5, "Major Soul Bind signed DRV")
	_expect(major_soul_bind.uses_classic_opposed_level_check(), "Major Soul Bind opposed check")
	_expect_equal(major_soul_bind.classic_spell_save_index, 5, "Major Soul Bind save")
	_expect_equal(major_soul_bind.classic_spell_save_mode, "negate", "Major Soul Bind save mode")
	_expect_equal(major_soul_bind.get_aoe(3, null), Spell.AoE_b3, "Major Soul Bind area")
	_expect_equal(major_soul_bind.get_range(7, null), 8, "Major Soul Bind range")
	_expect_equal(major_soul_bind.get_sp_cost(3, null), 105, "Major Soul Bind cost")
	_expect_equal(major_soul_bind.school_levels.get("Priest"), 4, "Major Soul Bind level")
	var first_major_bind := ConditionTestCharacter.new("First major bind target")
	var second_major_bind := ConditionTestCharacter.new("Second major bind target")
	major_soul_bind.begin_classic_target_resolution(null, 3)
	var first_bind_duration: int = major_soul_bind.apply_classic_scaled_effect(
		null, first_major_bind, 3, 1.0
	)
	var second_bind_duration: int = major_soul_bind.apply_classic_scaled_effect(
		null, second_major_bind, 3, 1.0
	)
	major_soul_bind.end_classic_target_resolution()
	_expect(first_bind_duration in range(2, 5), "Major Soul Bind rolls its source duration")
	_expect_equal(second_bind_duration, first_bind_duration, "Major Soul Bind shares one cast roll")
	_expect_equal(
		second_major_bind.traits[0].power,
		first_major_bind.traits[0].power,
		"Major Soul Bind applies the shared duration to every target"
	)

	var matrix: Variant = JSON.parse_string(FileAccess.get_file_as_string(
		"res://scripts/classic_runtime/classic_spell_support_matrix.json"
	))
	_expect(matrix is Dictionary, "Classic spell support matrix is machine readable")
	if matrix is Dictionary:
		_expect_equal(matrix.get("schemaVersion"), 1, "Classic spell support matrix version")
		var matrix_spells: Variant = matrix.get("spells", [])
		_expect(matrix_spells is Array, "Classic spell support matrix contains spell rows")
		if matrix_spells is Array:
			var matrix_ids: Array[int] = []
			for entry_value: Variant in matrix_spells:
				if not (entry_value is Dictionary):
					continue
				var entry: Dictionary = entry_value
				matrix_ids.append(int(entry.get("classicSpellId", 0)))
				_expect_equal(
					entry.get("supportStatus"),
					"supported",
					"Classic spell matrix row is executable"
				)
				_expect(
					FileAccess.file_exists(str(entry.get("resource", ""))),
					"spell matrix resource exists"
				)
			matrix_ids.sort()
			_expect_equal(
				matrix_ids,
				[
					1101, 1102, 1103, 1104, 1106, 1107, 1108, 1109, 1110, 1111, 1112, 1201, 1203,
					1204, 1209, 1211, 1212, 1303, 1305, 1306, 1308, 1309, 1310, 1401,
					1402, 1406, 1407, 1408, 1412,
					1501, 1503, 1504, 1505, 1506, 1508, 1510, 1511, 1601, 1603, 1604, 1606, 1607, 1608, 1609, 1610,
					1611, 1701, 1703, 1704, 1705, 1707, 1709, 1711, 1712, 2101, 2102, 2103, 2105,
					2109, 2110, 2111, 2112, 2201, 2207, 2210, 2301, 2304, 2306, 2307, 2403, 2404, 2405, 2406, 2407, 2412,
					2204, 2205, 2206, 2501, 2502, 2503, 2504, 2505, 2506, 2507, 2508, 2512, 2602, 2605, 2606, 2607,
					2603, 2609, 2611, 2705, 2706, 2707, 2708, 2709, 2711, 2712, 3102, 3104, 3105, 3108, 3111,
					3112, 3202, 3205, 3206, 3207, 3208, 3210, 3211, 3212, 3301, 3303, 3305, 3306, 3307, 3308,
					3310,
					3311, 3401, 3404, 3405, 3406, 3408, 3409, 3410, 3501, 3505, 3506, 3508, 3509, 3510, 3511, 3512, 3601,
					3507, 3602, 3603, 3605, 3607, 3608, 3702, 3703, 3704, 3706,
					3708, 3709, 3710, 3711, 3712,
				],
				"source-verified spell matrix includes the audited core variants"
			)


func _test_classic_queued_area_spells() -> void:
	var plague = load(
		"res://shared_assets/spells/classic_core_1308_plague.gd"
	).new()
	var force = load(
		"res://shared_assets/spells/classic_core_1309_plane_of_force.gd"
	).new()
	var ice = load(
		"res://shared_assets/spells/classic_core_1407_plane_of_ice.gd"
	).new()
	var enchanter_force = load(
		"res://shared_assets/spells/classic_core_3310_plane_of_force_enchanter.gd"
	).new()
	var enchanter_plague = load(
		"res://shared_assets/spells/classic_core_3509_plague_enchanter.gd"
	).new()

	_expect_equal(plague.classic_spell_ids, [1308, 2512], "identical Plague rows share one resource")
	_expect_equal(plague.school_levels, {"Sorcerer": 3, "Priest": 5, "Enchanter": 0}, "Plague preserves both learned-spell levels")
	_expect_equal(plague.get_range(7, null), 8, "Plague preserves its source range")
	_expect_equal(plague.get_min_damage(4, null), 5, "Plague damage is fixed")
	_expect_equal(plague.get_max_damage(4, null), 15, "Plague maximum damage is fixed")
	_expect_equal(plague.get_min_duration(4, null), 1, "Plague minimum duration")
	_expect_equal(plague.get_max_duration(4, null), 3, "Plague maximum duration")
	_expect_equal(
		plague.elements,
		[GameGlobal.ELEMENTS.MAGICAL],
		"Classic special-DRV damage does not become Remake healing"
	)
	_expect_equal(plague.terrain_tex, "Thn", "Plague uses Remake's thorn field art")
	_expect(plague.is_classic_queued_spell(), "Plague opts into Classic queue timing")
	_expect_equal(
		plague.get_aoe(3, null),
		SpellAreaPatternsScript.pattern(3),
		"Plague power selects the exact Data AD mask"
	)

	_expect_equal(force.classic_spell_ids, [1309], "Sorcerer Plane of Force exact ID")
	_expect(force.rot, "Plane of Force exposes rotatable targeting")
	_expect(
		_same_tile_set(force.get_aoe(1, null), Spell.AoE_WALL_H),
		"Plane of Force starts with Data AD wall 10"
	)
	_expect_equal(force.get_min_damage(3, null), 6, "Plane of Force damage scales by power")
	_expect_equal(force.get_max_damage(3, null), 24, "Plane of Force maximum scales")
	_expect_equal(force.classic_spell_save_index, -1, "Sorcerer Plane of Force cannot be saved against")
	_expect_equal(force.terrain_tex, "Orb", "Plane of Force uses Remake's force-field art")
	_expect_equal(ice.classic_spell_save_index, 2, "Plane of Ice uses the cold save")
	_expect_equal(ice.get_min_damage(3, null), 6, "Plane of Ice damage scales by power")
	_expect_equal(ice.get_max_damage(3, null), 30, "Plane of Ice maximum scales")
	_expect_equal(ice.get_sp_cost(2, null), 60, "Plane of Ice preserves source cost")
	_expect_equal(ice.terrain_tex, "Ice", "Plane of Ice uses Remake's ice field art")
	_expect_equal(enchanter_force.classic_spell_ids, [3310], "Enchanter Plane of Force exact ID")
	_expect_equal(enchanter_force.get_sp_cost(2, null), 70, "Enchanter Plane of Force keeps its distinct cost")
	_expect_equal(enchanter_force.classic_spell_save_index, 7, "Enchanter Plane of Force keeps its distinct save")
	_expect_equal(
		enchanter_force.elements,
		[GameGlobal.ELEMENTS.MAGICAL],
		"special-DRV force damage uses the neutral magical fallback"
	)
	_expect_equal(enchanter_plague.classic_spell_ids, [3509], "Enchanter Plague exact ID")
	_expect_equal(
		enchanter_plague.get_sp_cost(2, null),
		60,
		"Enchanter Plague keeps its distinct cost"
	)

	var remaining_specs: Array = [
		{
			"id": 1608, "file": "classic_core_1608_plane_of_fire.gd",
			"name": "Plane of Fire", "art": "Yfr", "element": GameGlobal.ELEMENTS.FIRE,
			"save": 1, "saveMode": "half_damage", "damage": [3, 18],
			"duration": [2, 4], "range": 10, "footprint": 14,
			"rot": true, "los": true, "cost": 80,
		},
		{
			"id": 1610, "file": "classic_core_1610_solar_flare.gd",
			"name": "Solar Flare", "art": "Str", "element": GameGlobal.ELEMENTS.FIRE,
			"save": 1, "saveMode": "half_damage", "damage": [15, 25],
			"duration": [2, 2], "range": 12, "footprint": 28,
			"rot": false, "los": true, "cost": 100,
		},
		{
			"id": 1611, "file": "classic_core_1611_stinging_lights.gd",
			"name": "Stinging Lights", "art": "Spk",
			"element": GameGlobal.ELEMENTS.MAGICAL,
			"save": 6, "saveMode": "half_damage", "damage": [3, 18],
			"duration": [2, 2], "range": 20, "footprint": 1,
			"rot": false, "los": true, "cost": 30,
		},
		{
			"id": 1704, "file": "classic_core_1704_hail_storm.gd",
			"name": "Hail Storm", "art": "Ice", "element": GameGlobal.ELEMENTS.ICE,
			"save": 2, "saveMode": "half_damage", "damage": [15, 20],
			"duration": [2, 4], "range": 10, "footprint": 2,
			"rot": false, "los": true, "cost": 60,
		},
		{
			"id": 1711, "file": "classic_core_1711_pulse.gd",
			"name": "Pulse", "art": "Orb", "element": GameGlobal.ELEMENTS.MENTAL,
			"save": 5, "saveMode": "half_damage", "damage": [20, 40],
			"duration": [2, 2], "range": 0, "footprint": 8,
			"rot": false, "los": true, "cost": 60,
		},
		{
			"id": 1712, "file": "classic_core_1712_solor_winds.gd",
			"name": "Solor Winds", "art": "Yfr", "element": GameGlobal.ELEMENTS.FIRE,
			"save": 1, "saveMode": "half_damage", "damage": [10, 25],
			"duration": [4, 8], "range": 10, "footprint": 28,
			"rot": false, "los": true, "cost": 100,
		},
		{
			"id": 2407, "file": "classic_core_2407_plane_of_thorns.gd",
			"name": "Plane of Thorns", "art": "Thn",
			"element": GameGlobal.ELEMENTS.MAGICAL,
			"save": 7, "saveMode": "half_damage", "damage": [5, 10],
			"duration": [2, 2], "range": 10, "footprint": 14,
			"rot": true, "los": true, "cost": 40,
		},
		{
			"id": 2501, "file": "classic_core_2501_cloud_of_cleavers.gd",
			"name": "Cloud of Cleavers", "art": "Dts",
			"element": GameGlobal.ELEMENTS.MAGICAL,
			"save": -1, "saveMode": "none", "damage": [10, 15],
			"duration": [2, 4], "range": 6, "footprint": 4,
			"rot": false, "los": true, "cost": 40,
		},
		{
			"id": 2508, "file": "classic_core_2508_mind_mines.gd",
			"name": "Mind Mines", "art": "Trg", "element": GameGlobal.ELEMENTS.MENTAL,
			"save": 5, "saveMode": "half_damage", "damage": [2, 10],
			"duration": [2, 3], "range": 20, "footprint": 2,
			"rot": false, "los": false, "cost": 30,
		},
		{
			"id": 2607, "file": "classic_core_2607_ring_of_fire.gd",
			"name": "Ring of Fire", "art": "Yfr", "element": GameGlobal.ELEMENTS.FIRE,
			"save": 1, "saveMode": "half_damage", "damage": [10, 25],
			"duration": [2, 2], "range": 3, "footprint": 8,
			"rot": false, "los": false, "cost": 80,
		},
		{
			"id": 3210, "file": "classic_core_3210_plane_of_fog.gd",
			"name": "Plane of Fog", "art": "Bcl",
			"element": GameGlobal.ELEMENTS.CHEMICAL,
			"save": 4, "saveMode": "half_damage", "damage": [6, 12],
			"duration": [2, 2], "range": 6, "footprint": 14,
			"rot": true, "los": false, "cost": 60,
		},
		{
			"id": 3512, "file": "classic_core_3512_shell_shock.gd",
			"name": "Shell Shock", "art": "Spk",
			"element": GameGlobal.ELEMENTS.ELECTRIC,
			"save": 3, "saveMode": "half_damage", "damage": [20, 40],
			"duration": [2, 2], "range": 0, "footprint": 8,
			"rot": false, "los": true, "cost": 100,
		},
		{
			"id": 3607, "file": "classic_core_3607_fire_storm.gd",
			"name": "Fire Storm", "art": "Yfr", "element": GameGlobal.ELEMENTS.FIRE,
			"save": 1, "saveMode": "half_damage", "damage": [3, 18],
			"duration": [2, 2], "range": 10, "footprint": 37,
			"rot": false, "los": true, "cost": 80,
		},
		{
			"id": 3702, "file": "classic_core_3702_fog_of_doom.gd",
			"name": "Fog of Doom", "art": "Gcl",
			"element": GameGlobal.ELEMENTS.CHEMICAL,
			"save": 4, "saveMode": "half_damage", "damage": [7, 35],
			"duration": [1, 2], "range": 8, "footprint": 2,
			"rot": false, "los": false, "cost": 100,
		},
	]
	for spec: Dictionary in remaining_specs:
		var queued_spell = load("res://shared_assets/spells/%s" % spec["file"]).new()
		var label := str(spec["name"])
		_expect_equal(queued_spell.classic_spell_ids, [spec["id"]], "%s exact ID" % label)
		_expect_equal(queued_spell.name, spec["name"], "%s display name" % label)
		_expect_equal(queued_spell.terrain_tex, spec["art"], "%s queue artwork" % label)
		_expect_equal(queued_spell.elements, [spec["element"]], "%s damage element" % label)
		_expect_equal(queued_spell.classic_spell_save_index, spec["save"], "%s save index" % label)
		_expect_equal(queued_spell.classic_spell_save_mode, spec["saveMode"], "%s save mode" % label)
		_expect_equal(
			queued_spell.get_min_damage(2, null),
			spec["damage"][0],
			"%s minimum damage" % label
		)
		_expect_equal(
			queued_spell.get_max_damage(2, null),
			spec["damage"][1],
			"%s maximum damage" % label
		)
		_expect_equal(
			queued_spell.get_min_duration(2, null),
			spec["duration"][0],
			"%s minimum duration" % label
		)
		_expect_equal(
			queued_spell.get_max_duration(2, null),
			spec["duration"][1],
			"%s maximum duration" % label
		)
		_expect_equal(queued_spell.get_range(2, null), spec["range"], "%s range" % label)
		_expect_equal(queued_spell.get_aoe(2, null).size(), spec["footprint"], "%s footprint" % label)
		_expect_equal(queued_spell.rot, spec["rot"], "%s rotation" % label)
		_expect_equal(queued_spell.los, spec["los"], "%s line of sight" % label)
		_expect_equal(queued_spell.get_sp_cost(2, null), spec["cost"], "%s casting cost" % label)

	var cleavers = load(
		"res://shared_assets/spells/classic_core_2501_cloud_of_cleavers.gd"
	).new()
	_expect_equal(
		cleavers.classic_damage_type,
		8,
		"Cloud of Cleavers keeps miscellaneous damage type 8"
	)
	_expect_equal(cleavers.classic_cannot, 1, "Cloud of Cleavers retains its no-resistance flag")
	_expect_equal(
		cleavers.resist,
		Spell.RESIST_TYPE.IGNORE_MRES_DODGE,
		"Cloud of Cleavers bypasses general magic resistance and DRV saves"
	)

	_expect(
		_same_tile_set(SpellAreaPatternsScript.pattern(11), Spell.AoE_WALL_L),
		"Data AD wall 11 matches diagonal-left targeting"
	)
	_expect(
		_same_tile_set(SpellAreaPatternsScript.pattern(12), Spell.AoE_WALL_V),
		"Data AD wall 12 matches vertical targeting"
	)
	_expect(
		_same_tile_set(SpellAreaPatternsScript.pattern(13), Spell.AoE_WALL_J),
		"Data AD wall 13 matches diagonal-right targeting"
	)
	_expect_equal(
		SpellAreaPatternsScript.pattern(14).size(),
		28,
		"Data AD hollow field preserves all source cells"
	)
	_expect_equal(
		SpellAreaPatternsScript.pattern(18).size(),
		4,
		"Data AD large-creature mask preserves four cells"
	)

	var caster := QueuedTerrainTestCreature.new(Vector2(1, 1))
	var other_caster := QueuedTerrainTestCreature.new(Vector2(9, 9))
	var target := QueuedTerrainTestCreature.new(Vector2(5, 5), Vector2(2, 2))
	var target_button := QueuedTerrainTestButton.new(target)
	var effects: Array = [
		{
			"id": 1,
			"classic": true,
			"time": 2,
			"tiles": [Vector2i(6, 6), Vector2i(7, 7)],
			"caster": caster,
			"phase_owner": caster,
			"spell": plague,
			"power": 3,
		},
		{
			"id": 2,
			"classic": true,
			"time": 2,
			"tiles": [Vector2i(5, 5), Vector2i(5, 6)],
			"caster": other_caster,
			"phase_owner": other_caster,
			"spell": force,
			"power": 2,
		},
		{
			"id": 3,
			"classic": false,
			"time": 2,
			"tiles": [Vector2i(5, 5)],
			"caster": caster,
			"phase_owner": caster,
			"spell": plague,
			"power": 1,
		},
	]
	var touching := QueuedSpellRuntimeScript.effects_touching_creature(effects, target)
	_expect_equal(touching.size(), 3, "large creatures test every occupied tile")
	var stationary := QueuedSpellRuntimeScript.stationary_actions(
		effects, [target_button]
	)
	_expect_equal(stationary.size(), 2, "stationary collision runs once per Classic effect")
	_expect_equal(
		stationary[0].get("absolute_aoe"),
		[Vector2i(6, 6)],
		"terrain retrigger carries absolute intersecting tiles"
	)
	_expect(stationary[0].get("from_terrain"), "terrain action identifies its source")
	_expect(not stationary[0].get("add_terrain"), "terrain action cannot enqueue another field")

	var after_caster_phase := QueuedSpellRuntimeScript.advance_phase(effects, caster)
	_expect_equal(after_caster_phase[0].get("time"), 1, "matching initiative phase decrements a field")
	_expect_equal(after_caster_phase[1].get("time"), 2, "other initiative phases remain unchanged")
	var after_missing_phase := QueuedSpellRuntimeScript.advance_missing_phases(
		after_caster_phase, [caster]
	)
	_expect_equal(after_missing_phase[1].get("time"), 1, "orphaned phase owners still expire after round collision")
	var capacity_probe: Array = []
	for index: int in range(QueuedSpellRuntimeScript.MAX_EFFECTS):
		capacity_probe.append({"classic": true, "time": 1, "id": index})
	_expect_equal(
		QueuedSpellRuntimeScript.classic_effect_count(capacity_probe),
		60,
		"Classic battlefield queue retains its source capacity"
	)


func _test_classic_helpless_spells() -> void:
	var multi = load(
		"res://shared_assets/spells/classic_core_1710_multi_sandman.gd"
	).new()
	var sandman = load(
		"res://shared_assets/spells/classic_core_2310_sandman.gd"
	).new()
	var wall = load(
		"res://shared_assets/spells/classic_core_2510_paralyzing_wall.gd"
	).new()
	var time_trap = load(
		"res://shared_assets/spells/classic_core_2610_time_trap.gd"
	).new()
	var noxious = load(
		"res://shared_assets/spells/classic_core_3209_noxious_cloud.gd"
	).new()
	var specs := [
		{
			"spell": multi,
			"name": "Multi Sandman",
			"ids": [1710],
			"target": 10,
			"class": 5,
			"save": 5,
			"duration": [3, 3],
			"range": 0,
			"mask": 0,
			"footprint": 1,
			"queue": 0,
			"terrain": "",
			"cost": 270,
			"los": true,
			"rot": false,
			"opposed": true,
			"save_bonus": 0,
			"save_adjust": 0,
			"resist_adjust": 0,
			"attribute": "Mental",
		},
		{
			"spell": sandman,
			"name": "Sandman",
			"ids": [2310],
			"target": 3,
			"class": 5,
			"save": 5,
			"duration": [3, 6],
			"range": 6,
			"mask": 4,
			"footprint": 9,
			"queue": 0,
			"terrain": "",
			"cost": 30,
			"los": false,
			"rot": false,
			"opposed": false,
			"save_bonus": 20,
			"save_adjust": 0,
			"resist_adjust": 0,
			"attribute": "Mental",
		},
		{
			"spell": wall,
			"name": "Paralyzing Wall",
			"ids": [2510, 3707],
			"target": 3,
			"class": 5,
			"save": 5,
			"duration": [3, 3],
			"range": 10,
			"mask": 10,
			"footprint": 14,
			"queue": 4,
			"terrain": "Web",
			"cost": 75,
			"los": true,
			"rot": true,
			"opposed": false,
			"save_bonus": 0,
			"save_adjust": 0,
			"resist_adjust": 0,
			"attribute": "Mental",
		},
		{
			"spell": time_trap,
			"name": "Time Trap",
			"ids": [2610],
			"target": 3,
			"class": 7,
			"save": 7,
			"duration": [2, 4],
			"range": 8,
			"mask": 18,
			"footprint": 4,
			"queue": 0,
			"terrain": "",
			"cost": 135,
			"los": false,
			"rot": false,
			"opposed": false,
			"save_bonus": 0,
			"save_adjust": -5,
			"resist_adjust": -5,
			"attribute": "Special",
		},
		{
			"spell": noxious,
			"name": "Noxious Cloud",
			"ids": [3209],
			"target": 3,
			"class": 4,
			"save": 4,
			"duration": [3, 3],
			"range": 4,
			"mask": 18,
			"footprint": 4,
			"queue": 7,
			"terrain": "Gcl",
			"cost": 45,
			"los": true,
			"rot": false,
			"opposed": false,
			"save_bonus": 35,
			"save_adjust": 0,
			"resist_adjust": 0,
			"attribute": "Chemical",
		},
	]
	for spec: Dictionary in specs:
		var spell: Variant = spec["spell"]
		var label := str(spec["name"])
		_expect_equal(spell.name, label, "%s display name" % label)
		_expect_equal(spell.classic_spell_ids, spec["ids"], "%s exact identities" % label)
		_expect_equal(spell.classic_special, 2, "%s helpless condition index" % label)
		_expect_equal(spell.classic_target_type, spec["target"], "%s target type" % label)
		_expect_equal(spell.classic_spell_class, spec["class"], "%s effect class" % label)
		_expect_equal(spell.classic_spell_save_index, spec["save"], "%s save index" % label)
		_expect_equal(spell.classic_spell_save_mode, "negate", "%s save negates" % label)
		_expect_equal(spell.get_min_duration(3, null), spec["duration"][0], "%s minimum duration" % label)
		_expect_equal(spell.get_max_duration(3, null), spec["duration"][1], "%s maximum duration" % label)
		_expect_equal(spell.get_range(3, null), spec["range"], "%s range" % label)
		_expect_equal(spell.classic_size, spec["mask"], "%s Data AD mask" % label)
		_expect_equal(spell.get_aoe(3, null).size(), spec["footprint"], "%s footprint" % label)
		_expect_equal(spell.classic_queue_icon, spec["queue"], "%s queue icon" % label)
		_expect_equal(spell.terrain_tex, spec["terrain"], "%s terrain art" % label)
		_expect_equal(spell.get_sp_cost(3, null), spec["cost"], "%s casting cost" % label)
		_expect_equal(spell.los, spec["los"], "%s line of sight" % label)
		_expect_equal(spell.rot, spec["rot"], "%s rotation" % label)
		_expect_equal(spell.uses_classic_opposed_level_check(), spec["opposed"], "%s opposed-level check" % label)
		_expect_equal(spell.classic_save_bonus, spec["save_bonus"], "%s save bonus" % label)
		_expect_equal(spell.classic_save_adjust, spec["save_adjust"], "%s save adjustment" % label)
		_expect_equal(spell.classic_resist_adjust, spec["resist_adjust"], "%s resistance adjustment" % label)
		_expect_equal(spell.attributes, ["Magical", spec["attribute"]], "%s delivery attributes" % label)
		_expect_equal(
			spell.is_classic_queued_spell(),
			int(spec["queue"]) > 0,
			"%s queue behavior" % label
		)

	var first := HelplessTestCharacter.new("First target", true)
	first.used_apr = 1
	first.used_movepoints = 5
	var second := HelplessTestCharacter.new("Second target")
	multi.begin_classic_target_resolution(null, 3)
	_expect_equal(
		multi.apply_classic_scaled_effect(null, first, 3, 1.0),
		3,
		"Multi Sandman applies its shared duration to the first target"
	)
	_expect_equal(
		multi.apply_classic_scaled_effect(null, second, 3, 1.0),
		3,
		"Multi Sandman applies the same duration to the second target"
	)
	multi.end_classic_target_resolution()
	_expect_equal(first.traits[0].duration, 3, "helplessness stores the source duration")
	_expect_equal(second.traits[0].duration, 3, "shared duration reaches every target")
	_expect_equal(first.used_apr, first.max_actions, "helplessness exhausts current actions")
	_expect_equal(
		first.used_movepoints,
		first.max_movement,
		"helplessness exhausts current movement after a partial turn"
	)

	first.used_apr = 0
	first.used_movepoints = 0
	_expect_equal(
		multi.apply_classic_scaled_effect(null, first, 2, 1.0),
		2,
		"a later helpless effect stacks its duration"
	)
	_expect_equal(first.traits[0].duration, 5, "helpless duration stacks additively")

	var capped := HelplessTestCharacter.new("Capped target", true)
	capped.traits.append(HelplessTestTrait.new(98))
	_expect_equal(
		multi.apply_classic_scaled_effect(null, capped, 3, 1.0),
		0,
		"a player condition result of 100 or more is rejected"
	)
	_expect_equal(capped.traits[0].duration, 98, "a rejected duration leaves the condition unchanged")
	_expect_equal(capped.used_apr, 0, "a rejected duration leaves current actions available")
	_expect_equal(
		capped.used_movepoints,
		capped.max_movement,
		"special code 2 still exhausts movement when the duration cap rejects"
	)

	var saved := HelplessTestCharacter.new("Saved target", true)
	saved.used_apr = 1
	saved.used_movepoints = 5
	_expect_equal(
		multi.apply_classic_scaled_effect(null, saved, 3, 0.0),
		0,
		"a successful DRV prevents helplessness"
	)
	_expect(saved.traits.is_empty(), "a successful DRV adds no condition")
	_expect_equal(saved.used_apr, 1, "a successful DRV preserves current actions")
	_expect_equal(saved.used_movepoints, 5, "a successful DRV preserves current movement")

	var queue_caster := QueuedTerrainTestCreature.new(Vector2(1, 1))
	var queue_target := QueuedTerrainTestCreature.new(Vector2(5, 5))
	var queue_action := QueuedSpellRuntimeScript.action_for_effect(
		{
			"id": 61,
			"classic": true,
			"tiles": [Vector2i(5, 5)],
			"caster": queue_caster,
			"spell": wall,
			"power": 3,
		},
		QueuedTerrainTestButton.new(queue_target)
	)
	_expect_equal(queue_action.get("spell"), wall, "Paralyzing Wall collision reuses its spell")
	_expect(queue_action.get("from_terrain"), "Paralyzing Wall collision identifies the field")
	_expect(not queue_action.get("add_terrain"), "Paralyzing Wall collision cannot duplicate its field")


func _test_classic_slug_spells() -> void:
	var sorcerer = load(
		"res://shared_assets/spells/classic_core_1311_slug_sorcerer.gd"
	).new()
	var priest = load(
		"res://shared_assets/spells/classic_core_2311_slug_priest.gd"
	).new()
	var specs := [
		{
			"spell": sorcerer,
			"name": "Classic Slug Sorcerer",
			"id": 1311,
			"school": "Sorcerer",
			"looks": [4, 4],
			"sounds": [3, 10],
		},
		{
			"spell": priest,
			"name": "Slug",
			"id": 2311,
			"school": "Priest",
			"looks": [8, 4],
			"sounds": [0, 9],
		},
	]
	for spec: Dictionary in specs:
		var spell: Variant = spec["spell"]
		var label := str(spec["name"])
		_expect_equal(spell.name, label, "%s native resource name" % label)
		_expect_equal(spell.classic_spell_ids, [spec["id"]], "%s exact identity" % label)
		_expect_equal(spell.classic_spell_class, 7, "%s effect class" % label)
		_expect_equal(spell.classic_special, 7, "%s Slow condition code" % label)
		_expect_equal(spell.classic_spell_save_index, 7, "%s save index" % label)
		_expect_equal(spell.classic_spell_save_mode, "negate", "%s save negates" % label)
		_expect_equal(spell.classic_save_bonus, 10, "%s save bonus" % label)
		_expect_equal(spell.classic_target_type, 3, "%s fixed-area targeting" % label)
		_expect_equal(spell.classic_size, 14, "%s Data AD mask" % label)
		_expect_equal(spell.get_aoe(3, null).size(), 28, "%s footprint" % label)
		_expect_equal(spell.get_range(3, null), 10, "%s range" % label)
		_expect(not spell.los, "%s ignores line of sight" % label)
		_expect(not spell.rot, "%s mask is not rotatable" % label)
		_expect_equal(spell.classic_queue_icon, 4, "%s queue icon" % label)
		_expect_equal(spell.terrain_tex, "Web", "%s battlefield art" % label)
		_expect(spell.is_classic_queued_spell(), "%s creates a queued field" % label)
		_expect_equal(spell.get_min_duration(3, null), 3, "%s minimum duration" % label)
		_expect_equal(spell.get_max_duration(3, null), 6, "%s maximum duration" % label)
		_expect_equal(spell.get_sp_cost(3, null), 60, "%s casting cost" % label)
		_expect_equal(spell.classic_spell_look_ids, spec["looks"], "%s source art" % label)
		_expect_equal(spell.classic_sound_ids, spec["sounds"], "%s source sounds" % label)
		_expect_equal(spell.school_levels.get(spec["school"]), 3, "%s source level" % label)

	var slow_trait_script = load("res://shared_assets/traits/t_slow.gd")
	for stat_name: String in [
		"AccuracyMelee", "AccuracyRanged", "EvasionMelee", "EvasionRanged",
	]:
		_expect_equal(
			slow_trait_script.adjust_stat(stat_name, 10),
			7,
			"native Slow applies Classic's 15-point %s adjustment" % stat_name
		)
	_expect_equal(
		slow_trait_script.adjust_stat("MaxMovement", 21),
		10,
		"native Slow halves future movement with Classic integer division"
	)
	_expect_equal(
		slow_trait_script.adjust_stat("MaxActions", 3),
		3,
		"Classic Slow leaves action count unchanged"
	)

	var first := SlowTestCharacter.new("First target", true)
	first.used_movepoints = 5
	var second := SlowTestCharacter.new("Second target")
	sorcerer.begin_classic_target_resolution(null, 3)
	var first_duration: int = sorcerer.apply_classic_scaled_effect(
		null, first, 3, 1.0
	)
	var second_duration: int = sorcerer.apply_classic_scaled_effect(
		null, second, 3, 1.0
	)
	sorcerer.end_classic_target_resolution()
	_expect(first_duration in range(3, 7), "Slug uses its 1-2 rounds per power duration")
	_expect_equal(second_duration, first_duration, "Slug shares one duration across its area")
	_expect_equal(
		first.traits[0].duration,
		first_duration * 5,
		"Slug stores its duration in the native Slow trait"
	)
	_expect_equal(first.get_movement_left(), 7, "Slug halves current partial-turn movement")
	_expect_equal(second.get_movement_left(), 10, "Slug halves current full movement")

	var stacked_before := int(first.traits[0].duration)
	var stacked_duration: int = sorcerer.apply_classic_scaled_effect(
		null, first, 1, 1.0
	)
	_expect_equal(
		first.traits[0].duration,
		stacked_before + stacked_duration * 5,
		"Slug stacks later condition duration"
	)
	_expect_equal(first.get_movement_left(), 3, "a later Slug halves remaining movement again")

	var capped := SlowTestCharacter.new("Capped target", true)
	capped.traits.append(SlowTestTrait.new(99))
	_expect_equal(
		sorcerer.apply_classic_scaled_effect(null, capped, 1, 1.0),
		0,
		"a player Slow result of 100 or more is rejected"
	)
	_expect_equal(capped.traits[0].duration, 495, "a rejected duration leaves Slow unchanged")
	_expect_equal(capped.get_movement_left(), 5, "special code 7 still halves current movement at the cap")

	var saved := SlowTestCharacter.new("Saved target", true)
	saved.used_movepoints = 5
	_expect_equal(
		sorcerer.apply_classic_scaled_effect(null, saved, 3, 0.0),
		0,
		"a successful special save prevents Slug"
	)
	_expect(saved.traits.is_empty(), "a successful save adds no Slow trait")
	_expect_equal(saved.get_movement_left(), 15, "a successful save preserves movement")

	var queue_caster := QueuedTerrainTestCreature.new(Vector2(1, 1))
	var queue_target := QueuedTerrainTestCreature.new(Vector2(5, 5))
	var queue_action := QueuedSpellRuntimeScript.action_for_effect(
		{
			"id": 62,
			"classic": true,
			"tiles": [Vector2i(5, 5)],
			"caster": queue_caster,
			"spell": sorcerer,
			"power": 3,
		},
		QueuedTerrainTestButton.new(queue_target)
	)
	_expect_equal(queue_action.get("spell"), sorcerer, "Slug collision reuses its spell")
	_expect(queue_action.get("from_terrain"), "Slug collision identifies the field")
	_expect(not queue_action.get("add_terrain"), "Slug collision cannot duplicate its field")


func _test_classic_tangle_weed_spell() -> void:
	var spell = load("res://shared_assets/spells/tangle_weed.gd").new()
	_expect_equal(spell.name, "Tangle Weed", "Tangle Weed native resource name")
	_expect_equal(spell.classic_spell_ids, [2412], "Tangle Weed exact identity")
	_expect_equal(spell.classic_spell_class, 7, "Tangle Weed effect class")
	_expect_equal(spell.source_record.get("special"), 253, "Tangle Weed preserves its raw special byte")
	_expect_equal(spell.classic_special, 3, "Tangle Weed resolves the encoded condition code")
	_expect_equal(spell.classic_cannot, 3, "Tangle Weed keeps its force-affect code")
	_expect_equal(spell.classic_spell_save_index, -1, "Tangle Weed bypasses saving throws")
	_expect_equal(spell.classic_spell_save_mode, "none", "Tangle Weed has no save mode")
	_expect_equal(spell.classic_target_type, 3, "Tangle Weed uses fixed-area targeting")
	_expect_equal(spell.classic_size, 14, "Tangle Weed uses its Data AD mask")
	_expect_equal(spell.get_aoe(3, null).size(), 28, "Tangle Weed footprint")
	_expect_equal(spell.get_range(3, null), 8, "Tangle Weed range")
	_expect(spell.los, "Tangle Weed requires line of sight")
	_expect(not spell.rot, "Tangle Weed mask is not rotatable")
	_expect_equal(spell.classic_queue_icon, 4, "Tangle Weed queue icon")
	_expect_equal(spell.terrain_tex, "Web", "Tangle Weed battlefield art")
	_expect(spell.is_classic_queued_spell(), "Tangle Weed creates a queued field")
	_expect(not spell.uses_classic_group_effect(), "Tangle Weed resolves each target separately")
	_expect_equal(spell.get_min_duration(3, null), 3, "Tangle Weed minimum duration")
	_expect_equal(spell.get_max_duration(3, null), 6, "Tangle Weed maximum duration")
	_expect_equal(spell.get_sp_cost(3, null), 90, "Tangle Weed casting cost")
	_expect_equal(spell.classic_spell_look_ids, [4, 4], "Tangle Weed source art")
	_expect_equal(spell.classic_sound_ids, [5, 81], "Tangle Weed source sounds")
	_expect_equal(spell.school_levels.get("Priest"), 4, "Tangle Weed source level")

	var target := SpellScreenTestCharacter.new("Tangled target", true)
	target.stats = {
		"MaxMovement": 20,
		"AccuracyMelee": 20,
		"AccuracyRanged": 18,
		"EvasionMelee": 16,
		"EvasionRanged": 14,
	}
	target.used_movepoints = 5
	spell.begin_classic_target_resolution(null, 3)
	var duration: int = spell.apply_classic_scaled_effect(null, target, 3, 1.0)
	spell.end_classic_target_resolution()
	_expect(duration in range(3, 7), "Tangle Weed rolls one to two rounds per power")
	_expect_equal(target.traits[0].get_saved_variables(), [duration], "Tangle Weed stores condition points")
	_expect_equal(target.get_movement_left(), 7, "Tangle Weed halves current partial-turn movement")
	_expect_equal(target.get_stat("MaxMovement"), 20 - duration, "Tangle Weed reduces later movement")
	_expect(
		is_equal_approx(target.get_stat("AccuracyMelee"), 20.0 - 0.2 * duration),
		"Tangle Weed applies its exact physical accuracy percentage"
	)
	_expect(
		is_equal_approx(target.get_stat("EvasionRanged"), 14.0 - 0.2 * duration),
		"Tangle Weed applies its exact physical evasion percentage"
	)
	target.traits[0]._on_new_round(target)
	_expect_equal(
		target.traits[0].get_saved_variables(),
		[duration - 1],
		"Tangle Weed loses one condition point per combat round"
	)
	var tangled_trait = load("res://shared_assets/traits/t_classic_tangled.gd")
	var player_floor := SpellScreenTestCharacter.new("Player floor", true)
	var monster_floor := SpellScreenTestCharacter.new("Monster floor")
	_expect_equal(
		tangled_trait.new([player_floor, 3])._on_get_stat("MaxMovement", 2),
		2,
		"Tangle Weed preserves Classic's player movement floor"
	)
	_expect_equal(
		tangled_trait.new([monster_floor, 3])._on_get_stat("MaxMovement", 2),
		0,
		"Tangle Weed permits a monster to be fully immobilized"
	)

	var queue_caster := QueuedTerrainTestCreature.new(Vector2(1, 1))
	var queue_target := QueuedTerrainTestCreature.new(Vector2(5, 5))
	var queue_action := QueuedSpellRuntimeScript.action_for_effect(
		{
			"id": 63,
			"classic": true,
			"tiles": [Vector2i(5, 5)],
			"caster": queue_caster,
			"spell": spell,
			"power": 3,
		},
		QueuedTerrainTestButton.new(queue_target)
	)
	_expect_equal(queue_action.get("spell"), spell, "Tangle Weed collision reuses its spell")
	_expect(queue_action.get("from_terrain"), "Tangle Weed collision identifies the field")
	_expect(not queue_action.get("add_terrain"), "Tangle Weed collision cannot duplicate its field")


func _test_classic_destroy_trap_spell(bundle) -> void:
	var spell = load("res://shared_assets/spells/destroy_trap.gd").new()
	_expect_equal(spell.name, "Destroy Trap", "Destroy Trap native resource name")
	_expect_equal(spell.classic_spell_ids, [3605], "Destroy Trap exact identity")
	_expect_equal(spell.classic_spell_response_ids, [3605], "Destroy Trap encounter identity")
	_expect_equal(spell.classic_special, 65, "Destroy Trap special code")
	_expect_equal(spell.classic_spell_class, 8, "Destroy Trap effect class")
	_expect_equal(spell.classic_target_type, 11, "Destroy Trap rogue target mode")
	_expect_equal(spell.classic_cannot, 3, "Destroy Trap force-affect code")
	_expect_equal(spell.classic_spell_save_index, -1, "Destroy Trap has no creature save")
	_expect_equal(spell.classic_spell_save_mode, "none", "Destroy Trap has no save mode")
	_expect_equal(spell.get_range(3, null), 0, "Destroy Trap requires no map range")
	_expect_equal(spell.get_sp_cost(3, null), 120, "Destroy Trap source cost")
	_expect_equal(spell.classic_spell_look_ids, [5, 15], "Destroy Trap source art")
	_expect_equal(spell.classic_sound_ids, [77, 92], "Destroy Trap source sounds")
	_expect_equal(spell.school_levels.get("Enchanter"), 6, "Destroy Trap source level")
	_expect_equal(spell.selection_costs.get("Enchanter"), 21, "Destroy Trap selection cost")
	_expect(not spell.in_field and not spell.in_combat, "Destroy Trap is encounter-only")
	_expect(not spell.is_generically_executable(), "Destroy Trap requires rogue encounter state")

	var encounter: Dictionary = bundle.get_encounter("complex", 3)
	var rogue: Dictionary = bundle.get_thief_encounter(1)
	var adapter = GodotAdapterScript.new()
	_expect_equal(
		adapter.resolve_complex_spell_result(
			encounter,
			spell.name,
			spell.classic_spell_class,
			{},
			spell.classic_spell_ids
		),
		2,
		"Destroy Trap retains the encounter's ordinary fallback result"
	)

	var resolver = RogueResolverScript.new()
	_expect(resolver.configure(encounter, rogue), "configure Destroy Trap encounter")
	_expect_equal(resolver.spell_success_percent(65, 3), 30, "Destroy Trap chance scales by power")
	_expect_equal(resolver.spell_success_percent(70, 3), 60, "fallback Open Lock rolls separately")
	var disarmed: Dictionary = adapter.resolve_rogue_spell_result(
		resolver,
		{
			"outcome": 2,
			"spellName": spell.name,
			"spellPower": 3,
			"classicSpecial": 65,
		},
		true,
		false
	)
	_expect(bool(disarmed.get("classicRogueSpellHandled")), "Destroy Trap enters the rogue spell path")
	_expect_equal(disarmed.get("outcome"), 0, "successful disarm uses its TD2 result")
	_expect(
		not bool(disarmed.get("thiefEncounter", {}).get("typeFlags", [])[9]),
		"successful Destroy Trap clears the armed flag"
	)
	var disarm_events: Array = disarmed.get("rogueSpellResolution", {}).get("events", [])
	_expect_equal(disarm_events.size(), 1, "successful Destroy Trap emits one feedback event")
	_expect_equal(disarm_events[0].get("messageId"), 5, "Destroy Trap success text")
	_expect_equal(disarm_events[0].get("soundId"), 677, "Destroy Trap success sound")
	var spell_interpreter = _interpreter(bundle)
	_expect(
		spell_interpreter.begin_trigger("Data DD:5:3"),
		"begin trapped chest for Destroy Trap persistence"
	)
	spell_interpreter.run_until_yield()
	var zero_result: Dictionary = spell_interpreter.resume_encounter(0, disarmed)
	_expect_equal(
		zero_result.get("reason"),
		"encounter-cancelled",
		"a zero Destroy Trap result exits the encounter"
	)
	_expect(
		not bool(spell_interpreter.runtime_state.get_effective_thief_encounter(
			bundle.get_thief_encounter(1)
		).get("typeFlags", [])[9]),
		"Destroy Trap mutation persists when its result exits the encounter"
	)
	# The standalone test runner does not initialize a campaign Resources node;
	# supply the same spell instance that the normal resource scan registers.
	adapter.classic_spell_overrides[3605] = spell
	var spell_item_response: Dictionary = adapter.resolve_complex_item_selection(
		encounter,
		{
			"name": "Destroy Trap scroll",
			"type": "Scroll",
			"_on_field_use_spell": ["Destroy Trap (3605)", 3],
		},
		{},
		[],
		[]
	)
	_expect_equal(spell_item_response.get("mode"), "spell-item", "Destroy Trap scroll uses spell mode")
	_expect_equal(spell_item_response.get("outcome"), 2, "Destroy Trap scroll keeps its fallback result")
	_expect_equal(spell_item_response.get("classicSpecial"), 65, "Destroy Trap scroll enters rogue spell handling")
	_expect_equal(spell_item_response.get("spellPower"), 3, "Destroy Trap scroll preserves power")

	resolver = RogueResolverScript.new()
	resolver.configure(encounter, rogue)
	var sprung_and_opened: Dictionary = adapter.resolve_rogue_spell_result(
		resolver,
		{
			"outcome": 2,
			"spellName": spell.name,
			"spellPower": 3,
			"classicSpecial": 65,
		},
		false,
		true
	)
	_expect_equal(sprung_and_opened.get("outcome"), 2, "failed disarm can still open the lock")
	var failure_events: Array = sprung_and_opened.get(
		"rogueSpellResolution", {}
	).get("events", [])
	_expect_equal(failure_events.size(), 3, "failed disarm preserves feedback, trap, and lock order")
	_expect_equal(failure_events[0].get("messageId"), 6, "Destroy Trap failure text")
	_expect_equal(failure_events[1].get("type"), "trap", "failed disarm springs the armed trap")
	_expect_equal(
		failure_events[1].get("trap", {}).get("damageLow"),
		4,
		"Destroy Trap fallback keeps trap damage"
	)
	_expect_equal(failure_events[2].get("messageId"), 4, "fallback Open Lock success text")
	var sprung_flags: Array = sprung_and_opened.get("thiefEncounter", {}).get("typeFlags", [])
	_expect(not bool(sprung_flags[9]), "Destroy Trap fallback clears the sprung trap")
	_expect(not bool(sprung_flags[1]), "Destroy Trap fallback consumes Detect Trap when sprung")
	_expect(bool(sprung_flags[6]), "Destroy Trap fallback leaves Pick Lock available")
	resolver = RogueResolverScript.new()
	resolver.configure(encounter, rogue)
	var sprung_and_failed: Dictionary = adapter.resolve_rogue_spell_result(
		resolver,
		{
			"outcome": 2,
			"spellName": spell.name,
			"spellPower": 3,
			"classicSpecial": 65,
		},
		false,
		false
	)
	_expect_equal(sprung_and_failed.get("outcome"), 0, "both failed spell rolls select TD2 result zero")
	var failed_events: Array = sprung_and_failed.get("rogueSpellResolution", {}).get("events", [])
	_expect_equal(failed_events[2].get("messageId"), 3, "fallback Open Lock failure text")
	_expect_equal(failed_events[2].get("soundId"), 696, "fallback Open Lock failure sound")

	resolver = RogueResolverScript.new()
	resolver.configure(bundle.get_encounter("complex", 4), bundle.get_thief_encounter(4))
	var ordinary_response: Dictionary = adapter.resolve_rogue_spell_result(
		resolver,
		{
			"outcome": 1,
			"spellName": spell.name,
			"spellPower": 3,
			"classicSpecial": 65,
		},
		false,
		false
	)
	_expect_equal(
		ordinary_response.get("outcome"),
		1,
		"a TD2 record without a disarm chance keeps the authored spell result"
	)
	_expect_equal(
		ordinary_response.get("rogueSpellResolution", {}).get("status"),
		"fallback",
		"Destroy Trap explicitly reports the generic encounter fallback"
	)


func _test_classic_open_lock_spell(bundle) -> void:
	var spell = load("res://shared_assets/spells/open_lock.gd").new()
	_expect_equal(spell.name, "Open Lock", "Open Lock native resource name")
	_expect_equal(spell.classic_spell_ids, [1109], "Open Lock exact identity")
	_expect_equal(spell.classic_spell_response_ids, [1109], "Open Lock encounter identity")
	_expect_equal(spell.classic_special, 70, "Open Lock special code")
	_expect_equal(spell.classic_spell_class, 8, "Open Lock effect class")
	_expect_equal(spell.classic_target_type, 11, "Open Lock rogue target mode")
	_expect_equal(spell.classic_cannot, 3, "Open Lock force-affect code")
	_expect_equal(spell.classic_spell_save_index, -1, "Open Lock has no creature save")
	_expect_equal(spell.classic_spell_save_mode, "none", "Open Lock has no save mode")
	_expect_equal(spell.get_range(3, null), 0, "Open Lock requires no map range")
	_expect_equal(spell.get_sp_cost(3, null), 135, "Open Lock source cost")
	_expect_equal(spell.classic_spell_look_ids, [14, 5], "Open Lock source art")
	_expect_equal(spell.classic_sound_ids, [22, 20], "Open Lock source sounds")
	_expect_equal(spell.school_levels.get("Sorcerer"), 1, "Open Lock source level")
	_expect_equal(spell.selection_costs.get("Sorcerer"), 1, "Open Lock selection cost")
	_expect(not spell.in_field and not spell.in_combat, "Open Lock is encounter-only")
	_expect(not spell.is_generically_executable(), "Open Lock requires rogue encounter state")

	var encounter: Dictionary = bundle.get_encounter("complex", 3)
	var rogue: Dictionary = bundle.get_thief_encounter(1)
	var adapter = GodotAdapterScript.new()
	_expect_equal(
		adapter.resolve_complex_spell_result(
			encounter,
			spell.name,
			spell.classic_spell_class,
			{},
			spell.classic_spell_ids
		),
		2,
		"Open Lock retains the encounter's ordinary fallback result"
	)

	var resolver = RogueResolverScript.new()
	_expect(resolver.configure(encounter, rogue), "configure Open Lock encounter")
	_expect_equal(resolver.spell_success_percent(70, 3), 60, "Open Lock chance scales by power")
	var opened: Dictionary = adapter.resolve_rogue_spell_result(
		resolver,
		{
			"outcome": 2,
			"spellName": spell.name,
			"spellPower": 3,
			"classicSpecial": 70,
		},
		false,
		true
	)
	_expect(bool(opened.get("classicRogueSpellHandled")), "Open Lock enters the rogue spell path")
	_expect_equal(opened.get("outcome"), 2, "successful Open Lock uses its TD2 result")
	var success_events: Array = opened.get("rogueSpellResolution", {}).get("events", [])
	_expect_equal(success_events.size(), 2, "armed Open Lock preserves trap and feedback order")
	_expect_equal(success_events[0].get("type"), "trap", "Open Lock springs the armed trap first")
	_expect_equal(success_events[0].get("trap", {}).get("damageLow"), 4, "Open Lock keeps trap damage")
	_expect_equal(success_events[1].get("messageId"), 4, "Open Lock success text")
	_expect_equal(success_events[1].get("soundId"), 141, "Open Lock success sound")
	var opened_flags: Array = opened.get("thiefEncounter", {}).get("typeFlags", [])
	_expect(not bool(opened_flags[9]), "Open Lock clears the sprung trap")
	_expect(not bool(opened_flags[1]), "Open Lock consumes Detect Trap when sprung")
	_expect(bool(opened_flags[6]), "Open Lock leaves Pick Lock available after a trap")

	resolver = RogueResolverScript.new()
	resolver.configure(encounter, rogue)
	var failed: Dictionary = adapter.resolve_rogue_spell_result(
		resolver,
		{
			"outcome": 2,
			"spellName": spell.name,
			"spellPower": 3,
			"classicSpecial": 70,
		},
		false,
		false
	)
	_expect_equal(failed.get("outcome"), 0, "failed Open Lock uses its TD2 result")
	var failure_events: Array = failed.get("rogueSpellResolution", {}).get("events", [])
	_expect_equal(failure_events.size(), 2, "failed Open Lock still springs an armed trap first")
	_expect_equal(failure_events[1].get("messageId"), 3, "Open Lock failure text")
	_expect_equal(failure_events[1].get("soundId"), 696, "Open Lock failure sound")
	var spell_interpreter = _interpreter(bundle)
	_expect(spell_interpreter.begin_trigger("Data DD:5:3"), "begin Open Lock persistence test")
	spell_interpreter.run_until_yield()
	var zero_result: Dictionary = spell_interpreter.resume_encounter(0, failed)
	_expect_equal(zero_result.get("reason"), "encounter-cancelled", "zero Open Lock result exits")
	_expect(
		not bool(spell_interpreter.runtime_state.get_effective_thief_encounter(
			bundle.get_thief_encounter(1)
		).get("typeFlags", [])[9]),
		"Open Lock trap mutation persists when its result exits the encounter"
	)

	# The standalone test runner does not initialize the campaign resource scan.
	adapter.classic_spell_overrides[1109] = spell
	var scroll_response: Dictionary = adapter.resolve_complex_item_selection(
		encounter,
		{
			"name": "Open Lock scroll",
			"type": "Scroll",
			"_on_field_use_spell": ["Open Lock (1109)", 3],
		},
		{},
		[],
		[]
	)
	_expect_equal(scroll_response.get("classicSpecial"), 70, "Open Lock scroll enters rogue handling")
	_expect_equal(scroll_response.get("spellPower"), 3, "Open Lock scroll preserves power")
	var item_response: Dictionary = adapter.resolve_complex_item_selection(
		encounter,
		{"name": "Open Lock wand", "classic_item_id": 900},
		{},
		[],
		[{"itemId": 900, "type": 20, "special1": 3, "special2": 1109}]
	)
	_expect_equal(item_response.get("mode"), "spell-item", "Open Lock type-20 item uses spell mode")
	_expect_equal(item_response.get("classicSpecial"), 70, "Open Lock type-20 item enters rogue handling")
	_expect_equal(item_response.get("spellPower"), 3, "Open Lock type-20 item preserves power")

	var no_open_modifier := rogue.duplicate(true)
	var modifiers: Array = no_open_modifier.get("modifiers", []).duplicate()
	modifiers[1] = 0
	no_open_modifier["modifiers"] = modifiers
	resolver = RogueResolverScript.new()
	resolver.configure(encounter, no_open_modifier)
	var ordinary_response: Dictionary = adapter.resolve_rogue_spell_result(
		resolver,
		{
			"outcome": 2,
			"spellName": spell.name,
			"spellPower": 3,
			"classicSpecial": 70,
		},
		false,
		false
	)
	_expect_equal(ordinary_response.get("outcome"), 2, "Open Lock keeps its authored fallback result")
	_expect_equal(
		ordinary_response.get("rogueSpellResolution", {}).get("status"),
		"fallback",
		"Open Lock reports a missing TD2 lock check as fallback"
	)
	_expect_equal(
		ordinary_response.get("rogueSpellResolution", {}).get("events", []).size(),
		0,
		"Open Lock fallback does not spring the trap"
	)


func _test_classic_sleepwalk_spell() -> void:
	var spell = load("res://shared_assets/spells/sleepwalk.gd").new()
	_expect_equal(spell.name, "Sleepwalk", "Sleepwalk native resource name")
	_expect_equal(spell.classic_spell_ids, [1412], "Sleepwalk exact identity")
	_expect_equal(spell.classic_special, 68, "Sleepwalk fatigue special")
	_expect_equal(spell.classic_spell_class, 8, "Sleepwalk effect class")
	_expect_equal(spell.classic_target_type, 11, "Sleepwalk source target type")
	_expect_equal(spell.classic_cannot, 3, "Sleepwalk force-affect code")
	_expect_equal(spell.classic_spell_save_index, -1, "Sleepwalk has no creature save")
	_expect_equal(spell.classic_spell_save_mode, "none", "Sleepwalk has no save mode")
	_expect_equal(spell.get_range(3, null), 0, "Sleepwalk requires no map range")
	_expect_equal(spell.get_targets(3, null), 0, "Sleepwalk has no selected targets")
	_expect_equal(spell.get_target_number(3, null), 0, "Sleepwalk has no target multiplier")
	_expect_equal(spell.get_min_damage(3, null), 0, "Sleepwalk has no damage")
	_expect_equal(spell.get_max_duration(3, null), 0, "Sleepwalk has no duration")
	_expect_equal(spell.get_sp_cost(3, null), 60, "Sleepwalk source cost")
	_expect_equal(spell.classic_spell_look_ids, [14, 5], "Sleepwalk source art")
	_expect_equal(spell.classic_sound_ids, [77, 13], "Sleepwalk source sounds")
	_expect_equal(spell.school_levels.get("Sorcerer"), 4, "Sleepwalk source level")
	_expect_equal(spell.selection_costs.get("Sorcerer"), 10, "Sleepwalk selection cost")
	_expect(spell.in_field and not spell.in_combat, "Sleepwalk is field and camp only")
	_expect(spell.skip_targeting, "Sleepwalk skips the character picker")
	_expect_equal(spell.autotarget_type, Spell.AUTOTARGET_TYPE.SELF, "Sleepwalk enters field flow once")
	_expect_equal(spell.targettile, Spell.TARGET_TILE.ANY, "Sleepwalk has no tile restriction")

	var fatigue_service = FatigueServiceTestDouble.new()
	fatigue_service.fatigue = 12345.0
	_expect(spell.apply_to_game_global(fatigue_service), "Sleepwalk finds the fatigue service")
	_expect_equal(fatigue_service.fatigue, 1.0, "Sleepwalk assigns Classic fatigue value one")
	_expect_equal(fatigue_service.set_calls, 1, "Sleepwalk mutates party fatigue once")
	fatigue_service.fatigue = 0.0
	spell.apply_to_game_global(fatigue_service)
	_expect_equal(fatigue_service.fatigue, 1.0, "Sleepwalk assigns rather than subtracting fatigue")


func _test_classic_spellcasting_block_spells() -> void:
	var dumbstruck = load(
		"res://shared_assets/spells/classic_core_2203_dumbstruck.gd"
	).new()
	var mind_blank = load(
		"res://shared_assets/spells/classic_core_3407_mind_blank.gd"
	).new()
	var specs := [
		{
			"spell": dumbstruck,
			"name": "Dumbstruck",
			"id": 2203,
			"school": "Priest",
			"level": 2,
			"target_type": 1,
			"targets": 1,
			"range": 9,
			"duration": [3, 6],
			"cost": 24,
			"looks": [14, 5],
			"sounds": [77, 81],
			"opposed": true,
			"resist_adjust": 0,
		},
		{
			"spell": mind_blank,
			"name": "Mind Blank",
			"id": 3407,
			"school": "Enchanter",
			"level": 4,
			"target_type": 0,
			"targets": 3,
			"range": 6,
			"duration": [2, 6],
			"cost": 45,
			"looks": [14, 5],
			"sounds": [26, 5],
			"opposed": false,
			"resist_adjust": -5,
		},
	]
	for spec: Dictionary in specs:
		var spell: Variant = spec["spell"]
		var label := str(spec["name"])
		_expect_equal(spell.name, label, "%s native resource name" % label)
		_expect_equal(spell.classic_spell_ids, [spec["id"]], "%s exact identity" % label)
		_expect_equal(spell.classic_spell_class, 5, "%s mental effect class" % label)
		_expect_equal(spell.classic_special, 6, "%s Dumb condition code" % label)
		_expect_equal(spell.classic_spell_save_index, 5, "%s mental save index" % label)
		_expect_equal(spell.classic_spell_save_mode, "negate", "%s save negates" % label)
		_expect_equal(spell.classic_save_bonus, 0, "%s save bonus" % label)
		_expect_equal(spell.classic_target_type, spec["target_type"], "%s targeting" % label)
		_expect_equal(spell.get_target_number(3, null), spec["targets"], "%s target count" % label)
		_expect_equal(spell.get_range(3, null), spec["range"], "%s range" % label)
		_expect(not spell.los, "%s ignores line of sight" % label)
		_expect_equal(spell.classic_queue_icon, 0, "%s is immediate" % label)
		_expect(not spell.in_field and spell.in_combat, "%s is combat-only" % label)
		_expect_equal(spell.get_min_duration(3, null), spec["duration"][0], "%s minimum duration" % label)
		_expect_equal(spell.get_max_duration(3, null), spec["duration"][1], "%s maximum duration" % label)
		_expect_equal(spell.get_sp_cost(3, null), spec["cost"], "%s casting cost" % label)
		_expect_equal(spell.classic_spell_look_ids, spec["looks"], "%s source art" % label)
		_expect_equal(spell.classic_sound_ids, spec["sounds"], "%s source sounds" % label)
		_expect_equal(spell.school_levels.get(spec["school"]), spec["level"], "%s source level" % label)
		_expect_equal(spell.attributes, ["Magical", "Mental"], "%s delivery attributes" % label)
		_expect_equal(
			spell.uses_classic_opposed_level_check(),
			spec["opposed"],
			"%s opposed-level rule" % label
		)
		_expect_equal(
			spell.classic_resist_adjust,
			spec["resist_adjust"],
			"%s resistance adjustment" % label
		)
		_expect_equal(
			spell.resist,
			Spell.RESIST_TYPE.IGNORE_DODGE,
			"%s checks general magic resistance" % label
		)

	var first := SpellScreenTestCharacter.new("First mind target", true)
	var second := SpellScreenTestCharacter.new("Second mind target")
	mind_blank.begin_classic_target_resolution(null, 3)
	var first_duration: int = mind_blank.apply_classic_scaled_effect(
		null, first, 3, 1.0
	)
	var second_duration: int = mind_blank.apply_classic_scaled_effect(
		null, second, 3, 1.0
	)
	mind_blank.end_classic_target_resolution()
	_expect(first_duration in range(2, 7), "Mind Blank uses its two-to-six-round duration")
	_expect_equal(second_duration, first_duration, "Mind Blank shares one duration across targets")
	_expect(not first.can_cast_spells(), "the temporary Dumb trait blocks spellcasting")
	_expect(not second.can_cast_spells(), "every affected target is blocked from spellcasting")
	first.traits[0]._on_new_round(first)
	_expect_equal(
		first.traits[0].get_saved_variables(),
		[first_duration - 1],
		"Dumb loses one point each combat round"
	)
	_expect(
		not FileAccess.get_file_as_string(
			"res://shared_assets/traits/t_dumb.gd"
		).contains("focus_counter"),
		"Dumb leaves non-spell actions unchanged"
	)

	var saved := SpellScreenTestCharacter.new("Saved mind target", true)
	_expect_equal(
		mind_blank.apply_classic_scaled_effect(null, saved, 3, 0.0),
		0,
		"a successful mental save prevents Dumb"
	)
	_expect(saved.can_cast_spells(), "a successful save leaves spellcasting available")

	var capped := SpellScreenTestCharacter.new("Capped mind target", true)
	capped.add_trait(load("res://shared_assets/traits/t_dumb.gd"), [98])
	_expect_equal(
		mind_blank.apply_classic_scaled_effect(null, capped, 3, 1.0),
		0,
		"player Dumb rejects a stack that reaches condition 100"
	)
	_expect_equal(capped.traits[0].get_saved_variables(), [98], "a rejected stack is unchanged")

	var permanent := SpellScreenTestCharacter.new("Permanently dumb target", true)
	permanent.add_trait(load("res://shared_assets/traits/p_dumb.gd"), [2])
	_expect(not permanent.can_cast_spells(), "permanent Dumb blocks spellcasting")
	_expect_equal(
		dumbstruck.apply_classic_scaled_effect(null, permanent, 3, 1.0),
		0,
		"temporary Dumb does not replace permanent Dumb"
	)

	var condition_target := ConditionTestCharacter.new("Dumb condition target")
	var condition_result: Dictionary = CharacterConditionRulesScript.apply_condition(
		[condition_target],
		[condition_target],
		"selected",
		5,
		4
	)
	_expect_equal(condition_result.get("affectedCount"), 1, "Give Condition maps Dumb")
	_expect_equal(
		CharacterConditionRulesScript.condition_value(condition_target, 5),
		4,
		"Give Condition preserves the Dumb value"
	)


func _test_classic_magic_aura_spell() -> void:
	var aura = load("res://shared_assets/spells/magic_aura.gd").new()
	_expect_equal(aura.name, "Magic Aura", "Magic Aura native resource name")
	_expect_equal(aura.classic_spell_ids, [2106], "Magic Aura exact identity")
	_expect_equal(aura.classic_spell_class, 8, "Magic Aura miscellaneous class")
	_expect_equal(aura.classic_damage_type, 8, "Magic Aura miscellaneous DRV")
	_expect_equal(aura.classic_special, 5, "Magic Aura condition code")
	_expect_equal(aura.classic_cannot, 3, "Magic Aura bypasses resistance")
	_expect_equal(aura.classic_spell_save_index, -1, "Magic Aura has no save")
	_expect_equal(aura.classic_spell_save_mode, "none", "Magic Aura save mode")
	_expect_equal(
		aura.resist,
		Spell.RESIST_TYPE.IGNORE_MRES_DODGE,
		"Magic Aura cannot miss or be resisted"
	)
	_expect(aura.in_combat and aura.in_field, "Magic Aura works in combat and camp")
	_expect_equal(aura.classic_target_type, 9, "Magic Aura targets all allies")
	_expect(aura.skip_targeting, "Magic Aura needs no manual target selection")
	_expect_equal(
		aura.autotarget_type,
		Spell.AUTOTARGET_TYPE.ALL_ALLIES,
		"Magic Aura uses Remake's all-allies targeting"
	)
	_expect_equal(aura.get_range(3, null), 0, "Magic Aura source range")
	_expect_equal(aura.get_target_number(3, null), 1, "Magic Aura source target count")
	_expect_equal(aura.get_min_duration(3, null), 3, "Magic Aura minimum duration")
	_expect_equal(aura.get_max_duration(3, null), 6, "Magic Aura maximum duration")
	_expect_equal(aura.get_sp_cost(3, null), 12, "Magic Aura casting cost")
	_expect_equal(aura.classic_spell_look_ids, [5, 5], "Magic Aura source art")
	_expect_equal(aura.classic_sound_ids, [77, 61], "Magic Aura source sounds")

	var first := SpellScreenTestCharacter.new("First aura target", true)
	var second := SpellScreenTestCharacter.new("Second aura target")
	first.stats = {
		"AccuracyMelee": 5,
		"AccuracyRanged": 4,
		"AccuracyMagic": 3,
		"EvasionMelee": 2,
		"EvasionRanged": 1,
		"EvasionMagic": 6,
	}
	second.stats = first.stats.duplicate()
	_expect_equal(
		aura.apply_classic_group_effect(null, [first, second], 3),
		2,
		"Magic Aura affects every ally"
	)
	var first_duration: int = first.traits[0].power
	_expect(first_duration in range(3, 7), "Magic Aura rolls one to two rounds per power")
	_expect_equal(second.traits[0].power, first_duration, "Magic Aura shares one duration roll")
	_expect_equal(
		first.get_stat("AccuracyMelee"), 6,
		"Aura adds five percentage points of melee hit chance"
	)
	_expect_equal(
		first.get_stat("AccuracyRanged"), 5,
		"Aura adds five percentage points of ranged hit chance"
	)
	_expect_equal(
		first.get_stat("EvasionMelee"), 3,
		"Aura adds five percentage points of melee defense"
	)
	_expect_equal(
		first.get_stat("EvasionRanged"), 2,
		"Aura adds five percentage points of ranged defense"
	)
	_expect_equal(first.get_stat("AccuracyMagic"), 3, "Aura leaves spell accuracy unchanged")
	_expect_equal(first.get_stat("EvasionMagic"), 6, "Aura leaves spell evasion unchanged")
	first.traits[0]._on_new_round(first)
	_expect_equal(first.traits[0].power, first_duration - 1, "Aura loses one point each combat round")

	var capped := SpellScreenTestCharacter.new("Capped aura target", true)
	capped.add_trait(load("res://shared_assets/traits/t_aura.gd"), [98])
	_expect_equal(
		aura.apply_classic_group_effect(null, [capped], 3),
		0,
		"player Aura rejects a stack that reaches condition 100"
	)
	_expect_equal(capped.traits[0].power, 98, "a rejected Aura stack is unchanged")

	var permanent := SpellScreenTestCharacter.new("Permanent aura target", true)
	permanent.add_trait(load("res://shared_assets/traits/p_aura.gd"), [4])
	_expect_equal(permanent.get_stat("AccuracyMelee"), 1, "permanent Aura uses the same bonus")
	_expect_equal(permanent.traits[0].get_saved_variables(), [4], "permanent Aura preserves magnitude")
	_expect_equal(
		aura.apply_classic_group_effect(null, [permanent], 3),
		0,
		"temporary Aura does not replace permanent Aura"
	)

	var condition_target := ConditionTestCharacter.new("Aura condition target")
	var condition_result: Dictionary = CharacterConditionRulesScript.apply_condition(
		[condition_target],
		[condition_target],
		"selected",
		4,
		5
	)
	_expect_equal(condition_result.get("affectedCount"), 1, "Give Condition maps Magic Aura")
	_expect_equal(
		CharacterConditionRulesScript.condition_value(condition_target, 4),
		5,
		"Give Condition preserves the Magic Aura value"
	)


func _test_classic_healing_spells() -> void:
	var specs: Array = [
		{
			"file": "classic_core_1506_heal_small_wounds.gd",
			"name": "Heal Small Wounds", "ids": [1506, 2105],
			"healing": [2, 16], "cost": 20, "sounds": [26, 30],
		},
		{
			"file": "classic_core_1604_heal_medium_wounds_sorcerer.gd",
			"name": "Classic Heal Medium Wounds Sorcerer", "ids": [1604],
			"healing": [4, 32], "cost": 40, "sounds": [26, 13],
		},
		{
			"file": "classic_core_1705_heal_large_wounds_sorcerer.gd",
			"name": "Classic Heal Large Wounds Sorcerer", "ids": [1705],
			"healing": [6, 48], "cost": 22, "sounds": [26, 13],
		},
		{
			"file": "classic_core_2207_heal_medium_wounds.gd",
			"name": "Heal Medium Wounds", "ids": [2207],
			"healing": [4, 32], "cost": 40, "sounds": [26, 51],
		},
		{
			"file": "classic_core_2404_heal_large_wounds.gd",
			"name": "Heal Large Wounds", "ids": [2404],
			"healing": [6, 48], "cost": 60, "sounds": [26, 13],
		},
		{
			"file": "classic_core_2505_heal_wounds.gd",
			"name": "Heal Wounds", "ids": [2505],
			"healing": [16, 72], "cost": 80, "sounds": [26, 13],
		},
	]
	for spec: Dictionary in specs:
		var spell = load("res://shared_assets/spells/%s" % spec["file"]).new()
		var label := str(spec["name"])
		_expect_equal(spell.name, label, "%s resource identity" % label)
		_expect_equal(spell.classic_spell_ids, spec["ids"], "%s exact IDs" % label)
		_expect_equal(spell.classic_special, 57, "%s uses the healing special" % label)
		_expect_equal(spell.classic_spell_class, 8, "%s keeps miscellaneous class" % label)
		_expect_equal(spell.classic_damage_type, 8, "%s keeps miscellaneous damage type" % label)
		_expect_equal(spell.classic_cannot, 4, "%s bypasses magic resistance" % label)
		_expect_equal(spell.classic_spell_save_index, -1, "%s has no DRV save" % label)
		_expect_equal(spell.classic_spell_save_mode, "none", "%s has no save mode" % label)
		_expect_equal(
			spell.resist,
			Spell.RESIST_TYPE.IGNORE_MRES_DODGE,
			"%s cannot miss or resist" % label
		)
		_expect_equal(
			spell.targettile,
			Spell.TARGET_TILE.CREATURE,
			"%s targets one creature" % label
		)
		_expect_equal(spell.get_range(2, null), 1, "%s preserves source range" % label)
		_expect_equal(
			spell.get_min_damage(2, null),
			spec["healing"][0],
			"%s minimum healing" % label
		)
		_expect_equal(
			spell.get_max_damage(2, null),
			spec["healing"][1],
			"%s maximum healing" % label
		)
		_expect_equal(spell.get_sp_cost(2, null), spec["cost"], "%s casting cost" % label)
		_expect_equal(
			spell.classic_sound_ids,
			spec["sounds"],
			"%s presentation bytes" % label
		)
		_expect(spell.in_combat and spell.in_field, "%s works in combat and camp" % label)

	var small_heal = load(
		"res://shared_assets/spells/classic_core_1506_heal_small_wounds.gd"
	).new()
	var unconscious := Creature.new()
	unconscious.stats["curHP"] = -2
	unconscious.stats["maxHP"] = 100
	unconscious.life_status = 2
	var recovered: int = small_heal.apply_classic_scaled_effect(
		null, unconscious, 7, 1.0
	)
	_expect(recovered >= 7, "healing applies every power roll to an unconscious target")
	_expect(unconscious.get_stat("curHP") > 0, "healing can restore positive health")
	_expect_equal(unconscious.life_status, 0, "positive health returns an unconscious ally")

	var dead := Creature.new()
	dead.stats["curHP"] = -12
	dead.stats["maxHP"] = 100
	dead.life_status = 3
	_expect_equal(
		small_heal.apply_classic_scaled_effect(null, dead, 7, 1.0),
		0,
		"ordinary healing does not revive a dead character"
	)
	_expect_equal(dead.get_stat("curHP"), -12, "a dead character's health stays unchanged")


func _test_classic_regeneration_spells() -> void:
	var single = load(
		"res://shared_assets/spells/classic_core_2709_regenerate_stamina.gd"
	).new()
	var multi = load(
		"res://shared_assets/spells/classic_core_3706_multi_regenerate_stamina.gd"
	).new()
	for spell in [single, multi]:
		_expect_equal(spell.classic_special, 11, "%s uses regeneration special 11" % spell.name)
		_expect_equal(spell.classic_spell_class, 7, "%s preserves spell class 7" % spell.name)
		_expect_equal(spell.classic_damage_type, 7, "%s preserves damage type 7" % spell.name)
		_expect_equal(spell.classic_cannot, 4, "%s bypasses magic resistance" % spell.name)
		_expect_equal(spell.classic_spell_save_index, -1, "%s has no DRV save" % spell.name)
		_expect_equal(spell.classic_spell_save_mode, "none", "%s has no save mode" % spell.name)
		_expect_equal(
			spell.resist,
			Spell.RESIST_TYPE.IGNORE_MRES_DODGE,
			"%s cannot miss or resist" % spell.name
		)
		_expect(spell.in_combat and spell.in_field, "%s works in combat and camp" % spell.name)

	_expect_equal(single.name, "Regenerate Stamina", "single regeneration resource identity")
	_expect_equal(single.classic_spell_ids, [2709], "single regeneration exact ID")
	_expect_equal(single.get_range(3, null), 1, "single regeneration source range")
	_expect_equal(single.get_target_number(3, null), 1, "single regeneration target count")
	_expect(single.los, "single regeneration requires line of sight")
	_expect_equal(single.get_min_duration(3, null), 6, "single regeneration minimum duration")
	_expect_equal(single.get_max_duration(3, null), 18, "single regeneration maximum duration")
	_expect_equal(single.get_sp_cost(3, null), 105, "single regeneration casting cost")
	_expect_equal(single.classic_spell_look_ids, [15, 7], "single regeneration visuals")
	_expect_equal(single.classic_sound_ids, [58, 84], "single regeneration sounds")

	_expect_equal(multi.name, "Multi Regenerate Stamina", "multi regeneration resource identity")
	_expect_equal(multi.classic_spell_ids, [3706], "multi regeneration exact ID")
	_expect_equal(multi.get_range(3, null), 7, "multi regeneration source range")
	_expect_equal(multi.get_target_number(3, null), 3, "multi regeneration targets once per power")
	_expect(not multi.los, "negative source range bypasses line of sight")
	_expect_equal(multi.get_min_duration(3, null), 5, "multi regeneration minimum duration")
	_expect_equal(multi.get_max_duration(3, null), 15, "multi regeneration maximum duration")
	_expect_equal(multi.get_sp_cost(3, null), 150, "multi regeneration casting cost")
	_expect_equal(multi.classic_spell_look_ids, [5, 7], "multi regeneration visuals")
	_expect_equal(multi.classic_sound_ids, [58, 84], "multi regeneration sounds")

	var first := RegenerationTestCharacter.new("First", true)
	var second := RegenerationTestCharacter.new("Second", true)
	_expect_equal(
		multi.apply_classic_group_effect(null, [first, second], 3),
		2,
		"multi regeneration applies to every selected target"
	)
	_expect_equal(
		first.traits[0].condition,
		second.traits[0].condition,
		"one Classic duration roll is shared by every target in the cast"
	)
	_expect(first.traits[0].condition in range(5, 16), "shared duration stays within source bounds")

	var player := RegenerationTestCharacter.new("Player", true)
	player.add_trait(load("res://shared_assets/traits/t_classic_regeneration.gd"), [5])
	player.traits[0]._on_new_round(player)
	_expect_equal(player.current_hp, 25, "party regeneration heals before decrementing")
	_expect_equal(player.traits[0].condition, 4, "party regeneration decreases after healing")
	player.traits[0].condition = 98
	player.traits[0].stack([2])
	_expect_equal(player.traits[0].condition, 98, "party regeneration rejects cap overflow")

	var monster := RegenerationTestCharacter.new("Monster")
	monster.add_trait(load("res://shared_assets/traits/t_classic_regeneration.gd"), [5])
	monster.traits[0]._on_new_round(monster)
	_expect_equal(monster.current_hp, 24, "monster regeneration decrements before healing")
	_expect_equal(monster.traits[0].condition, 4, "monster regeneration keeps the reduced value")

	var innate := RegenerationTestCharacter.new("Innate")
	innate.set_meta(RegenerationScript.META_KEY, 2)
	_expect_equal(
		single.apply_classic_scaled_effect(null, innate, 1, 1.0),
		0,
		"temporary regeneration does not replace innate negative condition 10"
	)
	_expect(innate.traits.is_empty(), "innate regeneration receives no temporary trait")


func _test_classic_protection_spells() -> void:
	var specs: Array = [
		{
			"file": "classic_core_2107_protection_from_cold.gd",
			"name": "Protection from Cold", "id": 2107, "special": 13,
			"range": 6, "targets": 3, "duration": [4, 12], "cost": 12,
			"looks": [6, 6], "sounds": [77, 45],
			"element": GameGlobal.ELEMENTS.ICE,
		},
		{
			"file": "classic_core_2108_protection_from_heat.gd",
			"name": "Protection from Heat", "id": 2108, "special": 12,
			"range": 6, "targets": 3, "duration": [4, 12], "cost": 12,
			"looks": [9, 9], "sounds": [18, 86],
			"element": GameGlobal.ELEMENTS.FIRE,
		},
		{
			"file": "classic_core_2303_electrical_protection.gd",
			"name": "Electrical Protection", "id": 2303, "special": 14,
			"range": 6, "targets": 3, "duration": [4, 12], "cost": 12,
			"looks": [8, 15], "sounds": [44, 30],
			"element": GameGlobal.ELEMENTS.ELECTRIC,
		},
		{
			"file": "classic_core_2308_psi_shield.gd",
			"name": "Psi Shield", "id": 2308, "special": 16,
			"range": 6, "targets": 3, "duration": [4, 12], "cost": 12,
			"looks": [13, 5], "sounds": [51, 29],
			"element": GameGlobal.ELEMENTS.MENTAL,
		},
		{
			"file": "classic_core_3101_chemical_protection.gd",
			"name": "Chemical Protection", "id": 3101, "special": 15,
			"range": 6, "targets": 3, "duration": [4, 12], "cost": 12,
			"looks": [12, 12], "sounds": [81, 84],
			"element": GameGlobal.ELEMENTS.CHEMICAL,
		},
		{
			"file": "classic_core_3103_electrical_protection_enchanter.gd",
			"name": "Classic Electrical Protection Enchanter", "id": 3103,
			"special": 14, "range": 6, "targets": 3,
			"duration": [4, 12], "cost": 12,
			"looks": [10, 15], "sounds": [44, 30],
			"element": GameGlobal.ELEMENTS.ELECTRIC,
		},
		{
			"file": "classic_core_3402_cool_breeze.gd",
			"name": "Cool Breeze", "id": 3402, "special": 12,
			"range": 0, "targets": 1, "duration": [3, 6], "cost": 60,
			"looks": [9, 8], "sounds": [77, 86],
			"element": GameGlobal.ELEMENTS.FIRE,
		},
		{
			"file": "classic_core_3412_warmth.gd",
			"name": "Warmth", "id": 3412, "special": 13,
			"range": 0, "targets": 1, "duration": [3, 6], "cost": 60,
			"looks": [6, 6], "sounds": [26, 45],
			"element": GameGlobal.ELEMENTS.ICE,
		},
	]
	for spec: Dictionary in specs:
		var spell = load("res://shared_assets/spells/%s" % spec["file"]).new()
		var label := str(spec["name"])
		_expect_equal(spell.name, label, "%s resource identity" % label)
		_expect_equal(spell.classic_spell_ids, [spec["id"]], "%s exact ID" % label)
		_expect_equal(spell.classic_special, spec["special"], "%s protection condition" % label)
		_expect_equal(spell.classic_spell_class, 8, "%s preserves spell class 8" % label)
		_expect_equal(spell.classic_damage_type, 8, "%s remains miscellaneous" % label)
		_expect_equal(spell.classic_spell_save_index, -1, "%s has no DRV save" % label)
		_expect_equal(spell.classic_spell_save_mode, "none", "%s has no save mode" % label)
		_expect_equal(
			spell.resist,
			Spell.RESIST_TYPE.IGNORE_MRES_DODGE,
			"%s cannot miss or resist" % label
		)
		_expect(spell.in_combat and spell.in_field, "%s works in combat and camp" % label)
		_expect_equal(spell.get_range(3, null), spec["range"], "%s source range" % label)
		_expect_equal(
			spell.get_target_number(3, null),
			spec["targets"],
			"%s source target count" % label
		)
		_expect_equal(
			spell.get_min_duration(3, null),
			spec["duration"][0],
			"%s minimum duration" % label
		)
		_expect_equal(
			spell.get_max_duration(3, null),
			spec["duration"][1],
			"%s maximum duration" % label
		)
		_expect_equal(spell.get_sp_cost(3, null), spec["cost"], "%s casting cost" % label)
		_expect_equal(spell.classic_spell_look_ids, spec["looks"], "%s visuals" % label)
		_expect_equal(spell.classic_sound_ids, spec["sounds"], "%s sounds" % label)
		_expect_equal(spell.elements, [spec["element"]], "%s native damage seam" % label)

	var psi_shield = load(
		"res://shared_assets/spells/classic_core_2308_psi_shield.gd"
	).new()
	var mental_target := SpellScreenTestCharacter.new("Mental Target", true)
	var mental_duration: int = psi_shield.apply_classic_scaled_effect(
		null,
		mental_target,
		1,
		1.0
	)
	_expect(
		mental_duration in range(4, 13),
		"Psi Shield duration stays within its source bounds"
	)
	_expect_equal(mental_target.traits.size(), 1, "Psi Shield adds one protection trait")
	var mental_trait: Variant = mental_target.traits[0]
	_expect_equal(mental_trait.name, "t_prot_mental.gd", "Psi Shield reuses mental protection")
	_expect_equal(
		mental_trait._on_get_stat("MultiplierMental", 1),
		0.5,
		"Psi Shield halves mental damage"
	)
	_expect_equal(
		mental_trait._on_get_stat("MultiplierElect", 1),
		1,
		"Psi Shield does not alter electrical damage"
	)
	_expect(
		not mental_trait.has_method("_on_get_player_controlled"),
		"Psi Shield does not act as charm protection"
	)
	mental_trait.duration = 5
	mental_trait._on_new_round(mental_target)
	_expect(mental_target.traits.is_empty(), "Psi Shield expires after its last round")

	var cool_breeze = load(
		"res://shared_assets/spells/classic_core_3402_cool_breeze.gd"
	).new()
	_expect(cool_breeze.skip_targeting, "Cool Breeze automatically targets friendlies")
	_expect_equal(
		cool_breeze.autotarget_type,
		Spell.AUTOTARGET_TYPE.ALL_ALLIES,
		"Cool Breeze uses the native all-allies target mode"
	)
	var first := ProtectionTestCharacter.new("First", true)
	var second := ProtectionTestCharacter.new("Second", true)
	_expect_equal(
		cool_breeze.apply_classic_group_effect(null, [first, second], 3),
		2,
		"Cool Breeze applies fire protection to every friendly target"
	)
	_expect_equal(first.traits[0].name, "t_prot_fire.gd", "Cool Breeze reuses native fire protection")
	_expect_equal(
		first.traits[0].duration,
		second.traits[0].duration,
		"one Classic duration roll is shared by every protected target"
	)
	_expect(
		first.traits[0].duration in range(15, 31),
		"Cool Breeze duration stays within its source bounds"
	)

	var heat = load(
		"res://shared_assets/spells/classic_core_2108_protection_from_heat.gd"
	).new()
	var capped := ProtectionTestCharacter.new("Capped", true)
	capped.traits.append(ProtectionTestTrait.new("t_prot_fire.gd", 98))
	_expect_equal(
		heat.apply_classic_scaled_effect(null, capped, 1, 1.0),
		0,
		"player protection rejects a duration that would exceed condition 99"
	)
	_expect_equal(capped.traits[0].duration, 490, "rejected protection leaves duration unchanged")
	var capped_monster := ProtectionTestCharacter.new("Capped Monster")
	capped_monster.traits.append(ProtectionTestTrait.new("t_prot_fire.gd", 123))
	_expect_equal(
		heat.apply_classic_scaled_effect(null, capped_monster, 1, 1.0),
		0,
		"monster protection rejects a duration that would exceed condition 124"
	)
	var innate := ProtectionTestCharacter.new("Innate", true)
	innate.traits.append(ProtectionTestTrait.new("p_prot_fire.gd", 1))
	_expect_equal(
		heat.apply_classic_scaled_effect(null, innate, 1, 1.0),
		0,
		"temporary protection does not replace an innate negative condition"
	)
	_expect_equal(innate.traits.size(), 1, "innate protection receives no temporary trait")


func _test_classic_strong_spell() -> void:
	var super_brawn = load(
		"res://shared_assets/spells/classic_core_2212_super_brawn.gd"
	).new()
	_expect_equal(super_brawn.name, "Super Brawn", "Super Brawn resource identity")
	_expect_equal(super_brawn.classic_spell_ids, [2212], "Super Brawn exact ID")
	_expect_equal(super_brawn.classic_special, 22, "Super Brawn writes Strong condition 21")
	_expect_equal(super_brawn.classic_spell_class, 8, "Super Brawn preserves spell class 8")
	_expect_equal(super_brawn.classic_damage_type, 8, "Super Brawn remains miscellaneous")
	_expect_equal(super_brawn.classic_spell_save_index, -1, "Super Brawn has no DRV save")
	_expect_equal(super_brawn.classic_spell_save_mode, "none", "Super Brawn has no save mode")
	_expect_equal(
		super_brawn.resist,
		Spell.RESIST_TYPE.IGNORE_MRES_DODGE,
		"Super Brawn cannot miss or resist"
	)
	_expect(super_brawn.in_combat and super_brawn.in_field, "Super Brawn works in combat and camp")
	_expect_equal(super_brawn.get_range(3, null), 1, "Super Brawn source range")
	_expect_equal(super_brawn.get_target_number(3, null), 3, "Super Brawn targets one creature per power")
	_expect_equal(super_brawn.get_min_duration(3, null), 3, "Super Brawn minimum duration")
	_expect_equal(super_brawn.get_max_duration(3, null), 8, "Super Brawn maximum duration")
	_expect_equal(super_brawn.get_sp_cost(3, null), 45, "Super Brawn casting cost")
	_expect_equal(super_brawn.classic_spell_look_ids, [5, 5], "Super Brawn visuals")
	_expect_equal(super_brawn.classic_sound_ids, [83, 21], "Super Brawn sounds")
	_expect(super_brawn.elements.is_empty(), "Super Brawn has no damage element")

	var first := SpellScreenTestCharacter.new("First", true)
	var second := SpellScreenTestCharacter.new("Second", true)
	_expect_equal(
		super_brawn.apply_classic_group_effect(null, [first, second], 3),
		2,
		"Super Brawn applies Strong to every selected target"
	)
	var first_trait: Variant = first.traits[0]
	var second_trait: Variant = second.traits[0]
	_expect_equal(first_trait.name, "t_classic_strong.gd", "Super Brawn uses its Classic Strong trait")
	_expect_equal(
		first_trait.duration_seconds,
		second_trait.duration_seconds,
		"one Classic duration roll is shared by every Strong target"
	)
	_expect_equal(
		first_trait._on_get_stat("AccuracyMelee", 0),
		3,
		"Strong adds 15 percentage points of melee accuracy"
	)
	_expect_equal(
		first_trait._on_get_stat("AccuracyRanged", 0),
		3,
		"Strong adds 15 percentage points of ranged accuracy"
	)
	_expect_equal(
		first_trait._on_get_stat("Bonus_Physical_dmg", 0),
		3,
		"Strong adds three physical damage"
	)
	_expect_equal(
		first_trait._on_get_stat("AccuracyMagic", 2),
		2,
		"Strong does not alter magical accuracy"
	)
	_expect_equal(
		first_trait.elapsed_hour_boundaries(3599, 7201),
		2,
		"Strong field duration decreases once per crossed Classic hour"
	)
	first_trait.duration_seconds = 5
	first_trait._on_new_round(first)
	_expect(first.traits.is_empty(), "Strong expires after its last round")

	var capped := SpellScreenTestCharacter.new("Capped", true)
	capped.add_trait(load("res://shared_assets/traits/t_classic_strong.gd"), [98])
	_expect_equal(
		super_brawn.apply_classic_scaled_effect(null, capped, 1, 1.0),
		0,
		"player Strong rejects a duration that would exceed condition 99"
	)
	_expect_equal(capped.traits[0].get_saved_variables(), [98], "rejected Strong leaves duration unchanged")
	var innate := ProtectionTestCharacter.new("Innate", true)
	innate.traits.append(ProtectionTestTrait.new("p_strong.gd", 1))
	_expect_equal(
		super_brawn.apply_classic_scaled_effect(null, innate, 1, 1.0),
		0,
		"temporary Strong does not replace an innate negative condition"
	)


func _test_classic_protection_from_foe_spells() -> void:
	var specs: Array = [
		{
			"file": "classic_core_1210_protection_from_foe.gd",
			"name": "Protection from Foe",
			"id": 1210,
			"range": 5,
			"targets": 3,
			"duration": [2, 5],
			"cost": 6,
			"looks": [13, 14],
			"sounds": [11, 12],
			"los": false,
			"aoe": Spell.AoE_b1,
		},
		{
			"file": "classic_core_2409_protection_from_foe_priest.gd",
			"name": "Classic Protection from Foe Priest",
			"id": 2409,
			"range": 5,
			"targets": 1,
			"duration": [3, 6],
			"cost": 45,
			"looks": [15, 5],
			"sounds": [4, 10],
			"los": true,
			"aoe": Spell.AoE_ROUND,
		},
	]
	for spec: Dictionary in specs:
		var protection = load(
			"res://shared_assets/spells/%s" % spec["file"]
		).new()
		var label := str(spec["name"])
		_expect_equal(protection.name, spec["name"], "%s resource identity" % label)
		_expect_equal(protection.classic_spell_ids, [spec["id"]], "%s exact ID" % label)
		_expect_equal(protection.classic_special, 23, "%s writes Protection condition 22" % label)
		_expect_equal(protection.classic_spell_class, 8, "%s preserves spell class 8" % label)
		_expect_equal(protection.classic_damage_type, 8, "%s remains miscellaneous" % label)
		_expect_equal(protection.classic_spell_save_index, -1, "%s has no DRV save" % label)
		_expect_equal(protection.classic_spell_save_mode, "none", "%s has no save mode" % label)
		_expect_equal(
			protection.resist,
			Spell.RESIST_TYPE.IGNORE_MRES_DODGE,
			"%s cannot miss or resist" % label
		)
		_expect(protection.in_combat and protection.in_field, "%s works in combat and camp" % label)
		_expect_equal(protection.get_range(3, null), spec["range"], "%s source range" % label)
		_expect_equal(protection.get_target_number(3, null), spec["targets"], "%s source targets" % label)
		_expect_equal(protection.get_min_duration(3, null), spec["duration"][0], "%s minimum duration" % label)
		_expect_equal(protection.get_max_duration(3, null), spec["duration"][1], "%s maximum duration" % label)
		_expect_equal(protection.get_sp_cost(3, null), spec["cost"], "%s casting cost" % label)
		_expect_equal(protection.classic_spell_look_ids, spec["looks"], "%s visuals" % label)
		_expect_equal(protection.classic_sound_ids, spec["sounds"], "%s sounds" % label)
		_expect_equal(protection.los, spec["los"], "%s line of sight" % label)
		_expect_equal(protection.get_aoe(3, null), spec["aoe"], "%s source area" % label)
		_expect(protection.elements.is_empty(), "%s has no damage element" % label)

	var sorcerer = load(
		"res://shared_assets/spells/classic_core_1210_protection_from_foe.gd"
	).new()
	var first := SpellScreenTestCharacter.new("First", true)
	var second := SpellScreenTestCharacter.new("Second", true)
	_expect_equal(
		sorcerer.apply_classic_group_effect(null, [first, second], 3),
		2,
		"Protection from Foe applies to every selected target"
	)
	_expect_equal(
		first.traits[0].name,
		"t_classic_protection_from_foe.gd",
		"Protection from Foe uses its Classic condition trait"
	)
	_expect_equal(
		first.traits[0].duration_seconds,
		second.traits[0].duration_seconds,
		"one Classic duration roll is shared by every Protection from Foe target"
	)

	var protection_trait = load(
		"res://shared_assets/traits/t_classic_protection_from_foe.gd"
	)
	var protection_rules = load(
		"res://scripts/classic_runtime/classic_protection_from_foe.gd"
	)
	var protected_attacker := SpellScreenTestCharacter.new("Protected attacker")
	var evil_defender := SpellScreenTestCharacter.new("Evil defender")
	protected_attacker.traits.append(protection_trait.new([protected_attacker, 4]))
	evil_defender.tags = ["Evil Creature"]
	_expect(
		is_equal_approx(
			protection_rules.adjust_melee_accuracy(
				0.5,
				protected_attacker,
				evil_defender
			),
			0.6
		),
		"Protection from Foe adds 10 percentage points against an evil defender"
	)

	var evil_attacker := SpellScreenTestCharacter.new("Evil attacker")
	var protected_defender := SpellScreenTestCharacter.new("Protected defender")
	evil_attacker.tags = ["Very Evil"]
	protected_defender.traits.append(protection_trait.new([protected_defender, 4]))
	_expect(
		is_equal_approx(
			protection_rules.adjust_melee_accuracy(
				0.5,
				evil_attacker,
				protected_defender
			),
			0.4
		),
		"Protection from Foe subtracts 10 percentage points from an evil attacker"
	)
	evil_defender.tags = ["Humanoid"]
	_expect(
		is_equal_approx(
			protection_rules.adjust_melee_accuracy(
				0.5,
				protected_attacker,
				evil_defender
			),
			0.5
		),
		"Protection from Foe does not change attacks against neutral defenders"
	)
	_expect(
		FileAccess.get_file_as_string("res://scripts/GameGlobal.gd").contains(
			"ClassicProtectionFromFoeScript.adjust_melee_accuracy"
		),
		"native melee accuracy routes through the Classic Protection from Foe rule"
	)

	var innate := ProtectionTestCharacter.new("Innate", true)
	innate.traits.append(ProtectionTestTrait.new("p_prot_evil.gd", 1))
	_expect_equal(
		sorcerer.apply_classic_scaled_effect(null, innate, 1, 1.0),
		0,
		"Classic Protection from Foe does not replace native permanent protection"
	)


func _test_classic_speedy_spells() -> void:
	var specs: Array = [
		{
			"file": "classic_core_1302_adrenalin.gd",
			"name": "Adrenalin",
			"id": 1302,
			"cost": 105,
		},
		{
			"file": "classic_core_2401_adrenalin_priest.gd",
			"name": "Classic Adrenalin Priest",
			"id": 2401,
			"cost": 60,
		},
	]
	for spec: Dictionary in specs:
		var adrenalin = load(
			"res://shared_assets/spells/%s" % spec["file"]
		).new()
		var label := str(spec["name"])
		_expect_equal(adrenalin.name, spec["name"], "%s resource identity" % label)
		_expect_equal(adrenalin.classic_spell_ids, [spec["id"]], "%s exact ID" % label)
		_expect_equal(adrenalin.classic_special, 24, "%s writes Speedy condition 23" % label)
		_expect_equal(adrenalin.classic_spell_class, 8, "%s preserves spell class 8" % label)
		_expect_equal(adrenalin.classic_damage_type, 8, "%s remains miscellaneous" % label)
		_expect_equal(adrenalin.classic_spell_save_index, -1, "%s has no DRV save" % label)
		_expect_equal(adrenalin.classic_spell_save_mode, "none", "%s has no save mode" % label)
		_expect_equal(
			adrenalin.resist,
			Spell.RESIST_TYPE.IGNORE_MRES_DODGE,
			"%s cannot miss or resist" % label
		)
		_expect(adrenalin.in_combat and adrenalin.in_field, "%s works in combat and camp" % label)
		_expect_equal(adrenalin.get_range(3, null), 4, "%s source range" % label)
		_expect_equal(adrenalin.get_target_number(3, null), 1, "%s source targets" % label)
		_expect_equal(adrenalin.get_min_duration(3, null), 3, "%s minimum duration" % label)
		_expect_equal(adrenalin.get_max_duration(3, null), 6, "%s maximum duration" % label)
		_expect_equal(adrenalin.get_sp_cost(3, null), spec["cost"], "%s casting cost" % label)
		_expect_equal(adrenalin.classic_spell_look_ids, [14, 8], "%s visuals" % label)
		_expect_equal(adrenalin.classic_sound_ids, [22, 26], "%s sounds" % label)
		_expect(adrenalin.los, "%s requires line of sight" % label)
		_expect_equal(adrenalin.get_aoe(3, null), Spell.AoE_ROUND, "%s source area" % label)
		_expect(adrenalin.elements.is_empty(), "%s has no damage element" % label)

	var sorcerer = load(
		"res://shared_assets/spells/classic_core_1302_adrenalin.gd"
	).new()
	var first := SpellScreenTestCharacter.new("First", true)
	var second := SpellScreenTestCharacter.new("Second", true)
	_expect_equal(
		sorcerer.apply_classic_group_effect(null, [first, second], 3),
		2,
		"Adrenalin applies Speedy to every creature in its area"
	)
	var first_trait: Variant = first.traits[0]
	var second_trait: Variant = second.traits[0]
	_expect_equal(first_trait.name, "t_classic_speedy.gd", "Adrenalin uses its Classic Speedy trait")
	_expect_equal(
		first_trait.duration_seconds,
		second_trait.duration_seconds,
		"one Classic duration roll is shared by every Adrenalin target"
	)
	_expect_equal(first_trait._on_get_stat("MaxMovement", 7), 14, "Speedy doubles movement")
	_expect_equal(
		first_trait._on_get_stat("MaxActions", 1),
		3,
		"Speedy adds the Classic equivalent of two Remake actions"
	)
	_expect_equal(
		first_trait._on_get_stat("AccuracyMelee", 4),
		4,
		"Speedy does not alter unrelated stats"
	)
	first.stats["MaxMovement"] = 7
	first.stats["MaxActions"] = 1
	_expect_equal(
		first.get_stat("MaxMovement"),
		14,
		"character movement uses the Classic Speedy stat hook"
	)
	_expect_equal(
		first.get_stat("MaxActions"),
		3,
		"character action economy uses the Classic Speedy stat hook"
	)

	var native_speedy := ProtectionTestCharacter.new("Native Speedy", true)
	native_speedy.traits.append(ProtectionTestTrait.new("t_speedy.gd", 1))
	_expect_equal(
		sorcerer.apply_classic_scaled_effect(null, native_speedy, 1, 1.0),
		0,
		"Classic Speedy does not stack beside Remake's temporary Speedy trait"
	)


func _test_classic_invisible_spells() -> void:
	var specs: Array = [
		{
			"file": "classic_core_1206_invisible_skin.gd",
			"name": "Invisible Skin", "id": 1206,
			"range": 6, "targets": 3, "duration": [4, 10], "cost": 15,
			"looks": [14, 15], "sounds": [4, 83], "los": false,
			"cannot": 4, "allies": false,
		},
		{
			"file": "classic_core_1708_multi_invisible_skin.gd",
			"name": "Multi Invisible Skin", "id": 1708,
			"range": 0, "targets": 1, "duration": [3, 3], "cost": 150,
			"looks": [14, 15], "sounds": [86, 81], "los": true,
			"cannot": 3, "allies": true,
		},
		{
			"file": "classic_core_2208_invisible_skin_priest.gd",
			"name": "Classic Invisible Skin Priest", "id": 2208,
			"range": 6, "targets": 3, "duration": [4, 10], "cost": 15,
			"looks": [14, 15], "sounds": [4, 83], "los": false,
			"cannot": 4, "allies": false,
		},
		{
			"file": "classic_core_2509_multi_invisible_skin_priest.gd",
			"name": "Classic Multi Invisible Skin Priest", "id": 2509,
			"range": 0, "targets": 1, "duration": [3, 3], "cost": 150,
			"looks": [14, 15], "sounds": [4, 83], "los": true,
			"cannot": 3, "allies": true,
		},
	]
	for spec: Dictionary in specs:
		var invisibility = load(
			"res://shared_assets/spells/%s" % spec["file"]
		).new()
		var label := str(spec["name"])
		_expect_equal(invisibility.name, spec["name"], "%s resource identity" % label)
		_expect_equal(invisibility.classic_spell_ids, [spec["id"]], "%s exact ID" % label)
		_expect_equal(invisibility.classic_special, 25, "%s writes Invisible condition 24" % label)
		_expect_equal(invisibility.classic_spell_class, 8, "%s preserves spell class 8" % label)
		_expect_equal(invisibility.classic_damage_type, 8, "%s remains miscellaneous" % label)
		_expect_equal(invisibility.classic_spell_save_index, -1, "%s has no DRV save" % label)
		_expect_equal(invisibility.classic_spell_save_mode, "none", "%s has no save mode" % label)
		_expect_equal(invisibility.classic_cannot, spec["cannot"], "%s source cannot value" % label)
		_expect_equal(
			invisibility.resist,
			Spell.RESIST_TYPE.IGNORE_MRES_DODGE,
			"%s cannot miss or resist" % label
		)
		_expect(
			invisibility.in_combat and invisibility.in_field,
			"%s works in combat and camp" % label
		)
		_expect_equal(invisibility.get_range(3, null), spec["range"], "%s source range" % label)
		_expect_equal(
			invisibility.get_target_number(3, null),
			spec["targets"],
			"%s source targets" % label
		)
		_expect_equal(
			invisibility.get_min_duration(3, null),
			spec["duration"][0],
			"%s minimum duration" % label
		)
		_expect_equal(
			invisibility.get_max_duration(3, null),
			spec["duration"][1],
			"%s maximum duration" % label
		)
		_expect_equal(invisibility.get_sp_cost(3, null), spec["cost"], "%s casting cost" % label)
		_expect_equal(invisibility.classic_spell_look_ids, spec["looks"], "%s visuals" % label)
		_expect_equal(invisibility.classic_sound_ids, spec["sounds"], "%s sounds" % label)
		_expect_equal(invisibility.los, spec["los"], "%s line of sight" % label)
		_expect_equal(invisibility.get_aoe(3, null), Spell.AoE_b1, "%s source area" % label)
		_expect(invisibility.elements.is_empty(), "%s has no damage element" % label)
		if bool(spec["allies"]):
			_expect(
				invisibility.skip_targeting,
				"%s automatically targets friendlies" % label
			)
			_expect_equal(
				invisibility.autotarget_type,
				Spell.AUTOTARGET_TYPE.ALL_ALLIES,
				"%s targets every ally" % label
			)
		else:
			_expect(not invisibility.skip_targeting, "%s uses the creature target picker" % label)
			_expect_equal(
				invisibility.targettile,
				Spell.TARGET_TILE.CREATURE,
				"%s targets creatures" % label
			)

	var multi = load(
		"res://shared_assets/spells/classic_core_1708_multi_invisible_skin.gd"
	).new()
	var first := SpellScreenTestCharacter.new("First", true)
	var second := SpellScreenTestCharacter.new("Second", true)
	_expect_equal(
		multi.apply_classic_group_effect(null, [first, second], 3),
		2,
		"Multi Invisible Skin affects every ally"
	)
	var first_trait: Variant = first.traits[0]
	var second_trait: Variant = second.traits[0]
	_expect_equal(
		first_trait.name,
		"t_classic_invisible.gd",
		"Invisible Skin uses its Classic condition trait"
	)
	_expect_equal(
		first_trait.duration_seconds,
		second_trait.duration_seconds,
		"one Classic duration roll is shared by every invisible ally"
	)
	_expect(
		first_trait.trait_types.has("AoO_imm"),
		"Classic invisibility prevents opportunity attacks"
	)
	_expect_equal(
		first_trait._on_get_stat("EvasionMelee", 4),
		6,
		"invisibility adds two melee evasion points"
	)
	_expect_equal(
		first_trait._on_get_stat("EvasionRanged", 1),
		3,
		"invisibility adds two ranged evasion points"
	)
	_expect_equal(
		first_trait._on_get_stat("EvasionMagic", 7),
		7,
		"invisibility does not alter magic evasion"
	)
	first.stats["EvasionMelee"] = 4
	first.stats["EvasionRanged"] = 1
	_expect_equal(
		first.get_stat("EvasionMelee"),
		6,
		"character melee evasion uses Classic invisibility"
	)
	_expect_equal(
		first.get_stat("EvasionRanged"),
		3,
		"character ranged evasion uses Classic invisibility"
	)

	var native_invisible := ProtectionTestCharacter.new("Native Invisible", true)
	native_invisible.traits.append(ProtectionTestTrait.new("t_invisible.gd", 1))
	_expect_equal(
		multi.apply_classic_scaled_effect(null, native_invisible, 1, 1.0),
		0,
		"Classic invisibility does not stack beside Remake's temporary invisibility"
	)


func _test_classic_animation_spells() -> void:
	var specs: Array = [
		{
			"file": "classic_core_2410_puppet_master.gd",
			"name": "Puppet Master",
			"id": 2410,
			"sounds": [66, 31],
		},
		{
			"file": "classic_core_3610_puppet_master_enchanter.gd",
			"name": "Classic Puppet Master Enchanter",
			"id": 3610,
			"sounds": [83, 31],
		},
	]
	for spec: Dictionary in specs:
		var puppet_master = load(
			"res://shared_assets/spells/%s" % spec["file"]
		).new()
		var label := str(spec["name"])
		_expect_equal(puppet_master.name, spec["name"], "%s resource identity" % label)
		_expect_equal(puppet_master.classic_spell_ids, [spec["id"]], "%s exact ID" % label)
		_expect_equal(puppet_master.classic_special, 26, "%s uses animation special 26" % label)
		_expect_equal(puppet_master.classic_spell_class, 7, "%s preserves special class 7" % label)
		_expect_equal(puppet_master.classic_damage_type, 7, "%s preserves special DRV 7" % label)
		_expect_equal(puppet_master.classic_cannot, 3, "%s source cannot value" % label)
		_expect_equal(puppet_master.classic_spell_save_index, -1, "%s has no DRV save" % label)
		_expect_equal(puppet_master.classic_spell_save_mode, "none", "%s has no save mode" % label)
		_expect_equal(
			puppet_master.resist,
			Spell.RESIST_TYPE.IGNORE_MRES_DODGE,
			"%s cannot miss or resist" % label
		)
		_expect(not puppet_master.in_combat and puppet_master.in_field, "%s is camp-only" % label)
		_expect_equal(puppet_master.get_range(3, null), 0, "%s source range" % label)
		_expect_equal(
			puppet_master.get_target_number(3, null),
			3,
			"%s selects one party character per power" % label
		)
		_expect_equal(puppet_master.get_min_duration(3, null), 0, "%s has no duration" % label)
		_expect_equal(puppet_master.get_max_duration(3, null), 0, "%s has no duration roll" % label)
		_expect_equal(puppet_master.get_sp_cost(3, null), 195, "%s casting cost" % label)
		_expect_equal(puppet_master.classic_spell_look_ids, [14, 15], "%s visuals" % label)
		_expect_equal(puppet_master.classic_sound_ids, spec["sounds"], "%s sounds" % label)
		_expect(puppet_master.los, "%s preserves source line of sight" % label)
		_expect_equal(puppet_master.get_aoe(3, null), Spell.AoE_b1, "%s source area" % label)
		_expect(puppet_master.elements.is_empty(), "%s has no damage element" % label)
		_expect(not puppet_master.skip_targeting, "%s uses the camp party picker" % label)
		_expect_equal(
			puppet_master.autotarget_type,
			Spell.AUTOTARGET_TYPE.NONE,
			"%s does not force a self target" % label
		)
		_expect_equal(
			puppet_master.targettile,
			Spell.TARGET_TILE.CREATURE,
			"%s targets party characters" % label
		)

	var priest = load(
		"res://shared_assets/spells/classic_core_2410_puppet_master.gd"
	).new()
	var dead := AnimationTestCharacter.new("Dead character")
	_expect(
		priest.apply_classic_scaled_effect(null, dead, 3, 1.0),
		"Puppet Master animates a dead character"
	)
	_expect_equal(dead.stats["curHP"], 10, "animation restores one-quarter maximum health")
	_expect_equal(dead.life_status, 0, "animation returns the character to active health")
	_expect_equal(dead.traits.size(), 1, "animation adds one permanent condition")
	var animation_trait: Variant = dead.traits[0]
	_expect_equal(
		animation_trait.name,
		"p_classic_animated.gd",
		"Puppet Master uses its Classic permanent trait"
	)
	_expect(animation_trait.permanent == 1, "Puppet Master animation is permanent")
	_expect(not animation_trait.stacks, "permanent animation does not stack")
	_expect(animation_trait.trait_types.has("no_exp"), "animated characters cannot gain experience")
	_expect(not animation_trait._on_get_player_controlled(), "animated characters fight automatically")
	_expect_equal(
		animation_trait._on_get_stat("SP_regen_mult", 1.0),
		0,
		"animated characters do not recover spell points"
	)
	_expect_equal(
		animation_trait._on_get_stat("MultiplierHealing", 1.0),
		1.0,
		"Classic animation does not turn healing into damage"
	)
	_expect_equal(
		animation_trait.get_saved_variables(),
		[],
		"permanent animation needs no duration payload"
	)

	var animation_rules = load(
		"res://scripts/classic_runtime/classic_animation.gd"
	)
	_expect(animation_rules.is_animated(dead), "animation helper recognizes Puppet Master")
	_expect(
		animation_rules.is_permanently_animated(dead),
		"animation helper recognizes Classic permanent animation"
	)
	_expect(
		not animation_rules.can_receive_experience(dead),
		"the shared experience rule excludes animated characters"
	)
	_expect(
		FileAccess.get_file_as_string("res://scripts/GameGlobal.gd").contains(
			"ClassicAnimationScript.can_receive_experience(character)"
		),
		"direct experience awards use the shared no-experience rule"
	)
	_expect(
		FileAccess.get_file_as_string(
			"res://scenes/UI/HUD/Looting/TreasureControl.gd"
		).contains("GameGlobal.can_character_receive_experience(pc)"),
		"battle-loot experience selection uses the same no-experience rule"
	)

	var daze = load("res://shared_assets/spells/daze.gd").new()
	_expect(
		MagicResistanceScript.animated_spell_immunity(dead, daze, true),
		"Puppet Master grants Classic charm and mental immunity"
	)
	var regeneration_trait = load(
		"res://shared_assets/traits/t_classic_regeneration.gd"
	)
	var regeneration = dead.add_trait(regeneration_trait, [3])
	regeneration._on_new_round(dead)
	_expect_equal(dead.stats["curHP"], 10, "animated characters do not regenerate")
	var disease_trait = load("res://shared_assets/traits/t_classic_disease.gd")
	var disease = dead.add_trait(disease_trait, [3])
	disease._on_new_round(dead)
	_expect_equal(dead.stats["curHP"], 10, "permanently animated characters ignore disease damage")
	_expect_equal(disease.condition, 2, "animated disease still reduces normally")
	var poison_trait = load("res://shared_assets/traits/t_poison.gd")
	var poison = dead.add_trait(poison_trait, [3])
	poison._on_new_round(dead)
	_expect_equal(dead.stats["curHP"], 10, "permanently animated characters ignore poison damage")
	_expect_equal(poison.power, 2, "animated poison still reduces normally")

	var living := AnimationTestCharacter.new("Living character")
	living.stats["curHP"] = 1
	living.life_status = 0
	_expect(
		not priest.apply_classic_scaled_effect(null, living, 1, 1.0),
		"Puppet Master ignores living characters"
	)
	_expect(living.traits.is_empty(), "failed animation does not add a trait")

	var revive = load("res://shared_assets/spells/classic_core_2606_revive_dead.gd").new()
	_expect(
		revive.apply_classic_scaled_effect(null, dead, 1, 1.0),
		"Revive Dead accepts a character animated by Puppet Master"
	)
	_expect(
		not animation_rules.is_animated(dead),
		"Revive Dead removes Classic permanent animation"
	)
	_expect_equal(dead.stats["curHP"], -9, "deanimation leaves the character unconscious")


func _test_classic_petrification_spells() -> void:
	var specs: Array = [
		{
			"file": "classic_core_2608_statue.gd",
			"name": "Statue",
			"id": 2608,
			"looks": [5, 15],
			"resistAdjust": -10,
		},
		{
			"file": "classic_core_3411_statue_enchanter.gd",
			"name": "Classic Statue Enchanter",
			"id": 3411,
			"looks": [5, 5],
			"resistAdjust": -5,
		},
	]
	for spec: Dictionary in specs:
		var statue = load("res://shared_assets/spells/%s" % spec["file"]).new()
		var label := str(spec["name"])
		_expect_equal(statue.name, spec["name"], "%s resource identity" % label)
		_expect_equal(statue.classic_spell_ids, [spec["id"]], "%s exact ID" % label)
		_expect_equal(statue.classic_special, 27, "%s uses petrification special 27" % label)
		_expect_equal(statue.classic_spell_class, 7, "%s preserves special class 7" % label)
		_expect_equal(statue.classic_damage_type, 7, "%s preserves special DRV 7" % label)
		_expect_equal(statue.classic_cannot, 0, "%s preserves source resistance gates" % label)
		_expect_equal(statue.classic_spell_save_index, 7, "%s uses the special DRV" % label)
		_expect_equal(statue.classic_spell_save_mode, "negate", "%s save negates petrification" % label)
		_expect_equal(statue.classic_save_bonus, 20, "%s source save bonus" % label)
		_expect_equal(
			statue.classic_resist_adjust,
			spec["resistAdjust"],
			"%s source resistance adjustment" % label
		)
		_expect_equal(
			statue.resist,
			Spell.RESIST_TYPE.IGNORE_DODGE,
			"%s checks magic resistance but cannot miss" % label
		)
		_expect(statue.in_combat and not statue.in_field, "%s is combat-only" % label)
		_expect_equal(statue.get_range(3, null), 4, "%s source range" % label)
		_expect_equal(statue.get_target_number(3, null), 1, "%s targets one creature" % label)
		_expect_equal(statue.get_min_duration(3, null), -1, "%s is permanent" % label)
		_expect_equal(statue.get_max_duration(3, null), -1, "%s has no duration roll" % label)
		_expect_equal(statue.get_sp_cost(3, null), 150, "%s casting cost" % label)
		_expect_equal(statue.classic_spell_look_ids, spec["looks"], "%s visuals" % label)
		_expect_equal(statue.classic_sound_ids, [84, 59], "%s sounds" % label)
		_expect(statue.los, "%s requires line of sight" % label)
		_expect_equal(statue.get_aoe(3, null), Spell.AoE_b1, "%s source area" % label)
		_expect(statue.elements.is_empty(), "%s has no ordinary damage element" % label)
		_expect_equal(statue.targettile, Spell.TARGET_TILE.CREATURE, "%s targets creatures" % label)

	var statue = load("res://shared_assets/spells/classic_core_2608_statue.gd").new()
	var unaffected := PetrificationTestCharacter.new("Saved target")
	_expect(
		not statue.apply_classic_scaled_effect(null, unaffected, 1, 0.0),
		"a successful save negates Statue"
	)
	_expect_equal(unaffected.stats["curHP"], 25, "a saved target keeps its health")
	_expect(unaffected.traits.is_empty(), "a saved target is not petrified")

	var target := PetrificationTestCharacter.new("Statue target")
	_expect(
		statue.apply_classic_scaled_effect(null, target, 1, 1.0),
		"an unresolved Statue effect petrifies its target"
	)
	_expect_equal(target.stats["curHP"], -10, "Statue leaves its target at minus ten health")
	_expect_equal(target.life_status, 3, "Statue kills its target")
	_expect_equal(target.traits.size(), 1, "Statue adds one permanent condition")
	var petrified_trait: Variant = target.traits[0]
	_expect_equal(petrified_trait.name, "p_petrified.gd", "Statue reuses Remake's petrified trait")
	_expect(petrified_trait.permanent, "petrification is permanent")
	_expect(not petrified_trait._on_get_player_controlled(), "petrified characters cannot act")
	_expect_equal(
		petrified_trait._on_get_stat("MultiplierHealing", 1),
		0,
		"petrification blocks healing"
	)
	_expect_equal(petrified_trait._on_change_cur_hp(10), 0, "petrification rejects health recovery")
	_expect_equal(petrified_trait._on_change_cur_hp(-10), -10, "petrification does not absorb damage")

	var revive = load("res://shared_assets/spells/classic_core_2606_revive_dead.gd").new()
	_expect(
		not revive.apply_classic_scaled_effect(null, target, 1, 1.0),
		"Revive Dead rejects a petrified target"
	)
	var flesh = load("res://shared_assets/spells/classic_core_2602_flesh.gd").new()
	_expect_equal(
		flesh.apply_classic_scaled_effect(null, target, 1, 1.0),
		1,
		"Flesh removes Statue's petrification"
	)
	_expect(
		revive.apply_classic_scaled_effect(null, target, 1, 1.0),
		"Revive Dead can restore the victim after Flesh"
	)
	_expect_equal(target.stats["curHP"], -9, "post-Flesh revival returns the victim unconscious")

	var healing_gate := PetrificationTestCharacter.new("Petrified healing target")
	healing_gate.stats["curHP"] = 10
	healing_gate.add_trait(load("res://shared_assets/traits/p_petrified.gd"), [])
	healing_gate.change_cur_hp(5)
	_expect_equal(healing_gate.stats["curHP"], 10, "Creature health changes honor petrification")
	_expect(
		FileAccess.get_file_as_string("res://Creature/Creature.gd").contains(
			'trait_value.has_method("_on_change_cur_hp")'
		),
		"the native Creature health path invokes trait health-change hooks"
	)
	flesh.apply_classic_scaled_effect(null, healing_gate, 1, 1.0)
	healing_gate.change_cur_hp(5)
	_expect_equal(healing_gate.stats["curHP"], 15, "Flesh restores ordinary health recovery")


func _test_classic_blindness_spell() -> void:
	var blind = load("res://shared_assets/spells/classic_core_2402_blind.gd").new()
	_expect_equal(blind.name, "Blind", "Blind resource identity")
	_expect_equal(blind.classic_spell_ids, [2402], "Blind exact ID")
	_expect_equal(blind.classic_special, 28, "Blind uses condition special 28")
	_expect_equal(blind.classic_spell_class, 7, "Blind preserves special class 7")
	_expect_equal(blind.classic_damage_type, 7, "Blind preserves special DRV 7")
	_expect_equal(blind.classic_cannot, 0, "Blind preserves source resistance gates")
	_expect_equal(blind.classic_spell_save_index, 7, "Blind uses the special DRV")
	_expect_equal(blind.classic_spell_save_mode, "negate", "a save negates Blind")
	_expect_equal(blind.classic_save_bonus, 0, "Blind source save bonus")
	_expect_equal(blind.classic_resist_adjust, 0, "Blind source resistance adjustment")
	_expect_equal(
		blind.resist,
		Spell.RESIST_TYPE.IGNORE_DODGE,
		"Blind checks magic resistance but cannot miss"
	)
	_expect(blind.in_combat and not blind.in_field, "Blind is combat-only")
	_expect_equal(blind.get_range(3, null), 1, "Blind source range")
	_expect_equal(blind.get_target_number(3, null), 3, "Blind targets one creature per power")
	_expect_equal(blind.get_min_duration(3, null), -1, "Blind is permanent")
	_expect_equal(blind.get_max_duration(3, null), -1, "Blind has no duration roll")
	_expect_equal(blind.get_sp_cost(3, null), 75, "Blind casting cost")
	_expect_equal(blind.classic_spell_look_ids, [14, 11], "Blind visuals")
	_expect_equal(blind.classic_sound_ids, [29, 98], "Blind sounds")
	_expect(blind.los, "Blind requires line of sight")
	_expect_equal(blind.get_aoe(3, null), Spell.AoE_b1, "Blind source area")
	_expect(blind.elements.is_empty(), "Blind has no ordinary damage element")
	_expect_equal(blind.targettile, Spell.TARGET_TILE.CREATURE, "Blind targets creatures")

	var unaffected := BlindnessTestCharacter.new("Saved target")
	_expect(
		not blind.apply_classic_scaled_effect(null, unaffected, 1, 0.0),
		"a successful save negates Blind"
	)
	_expect(unaffected.traits.is_empty(), "a saved target is not blinded")

	var target := BlindnessTestCharacter.new("Blind target")
	_expect(
		blind.apply_classic_scaled_effect(null, target, 1, 1.0),
		"an unresolved Blind effect applies its condition"
	)
	_expect_equal(target.traits.size(), 1, "Blind adds one permanent condition")
	_expect_equal(
		target.get_stat("curHP"),
		20,
		"Blind does not inherit the stale disease healing path"
	)
	var blind_trait: Variant = target.traits[0]
	_expect_equal(blind_trait.name, "p_classic_blind.gd", "Blind uses its translated native trait")
	_expect(blind_trait.permanent, "blindness is permanent")
	_expect_equal(target.get_stat("AccuracyMelee"), 7, "Blind lowers melee accuracy by 15 points")
	_expect_equal(target.get_stat("AccuracyRanged"), 5, "Blind lowers ranged accuracy by 15 points")
	_expect_equal(target.get_stat("EvasionMelee"), 3, "Blind lowers melee evasion by 15 points")
	_expect_equal(target.get_stat("EvasionRanged"), 1, "Blind lowers ranged evasion by 15 points")
	_expect_equal(target.get_stat("AccuracyMagic"), 9, "Blind does not alter spell resistance checks")
	blind.apply_classic_scaled_effect(null, target, 1, 1.0)
	_expect_equal(target.traits.size(), 1, "permanent blindness does not stack")

	var heal_blindness = load(
		"res://shared_assets/spells/classic_core_2204_heal_blindness.gd"
	).new()
	_expect_equal(
		heal_blindness.apply_classic_scaled_effect(null, target, 1, 1.0),
		1,
		"Heal Blindness removes Classic permanent blindness"
	)
	_expect(target.traits.is_empty(), "the cured target regains normal accuracy and evasion")


func _test_classic_disease_spells() -> void:
	var festering = load("res://shared_assets/spells/festering_wounds.gd").new()
	_expect_equal(festering.name, "Festering Wounds", "Festering Wounds resource identity")
	_expect_equal(festering.classic_spell_ids, [2304], "Festering Wounds exact ID")
	_expect_equal(festering.classic_special, 29, "Festering Wounds uses disease special 29")
	_expect_equal(festering.classic_spell_class, 4, "Festering Wounds source class")
	_expect_equal(festering.classic_damage_type, 4, "Festering Wounds uses chemical DRV")
	_expect_equal(festering.classic_cannot, 0, "Festering Wounds preserves resistance gates")
	_expect_equal(festering.classic_spell_save_index, 4, "Festering Wounds uses chemical saves")
	_expect_equal(festering.classic_spell_save_mode, "negate", "a save negates Festering Wounds")
	_expect_equal(festering.resist, Spell.RESIST_TYPE.IGNORE_DODGE, "Festering Wounds checks magic resistance")
	_expect(festering.in_combat and not festering.in_field, "Festering Wounds is combat-only")
	_expect_equal(festering.get_range(3, null), 0, "Festering Wounds source range")
	_expect_equal(festering.get_damage_roll(3, null), 0, "Festering Wounds has no direct damage")
	_expect_equal(festering.get_min_duration(3, null), 3, "Festering Wounds minimum duration")
	_expect_equal(festering.get_max_duration(3, null), 9, "Festering Wounds maximum duration")
	_expect_equal(festering.get_sp_cost(3, null), 36, "Festering Wounds casting cost")
	_expect_equal(festering.classic_spell_look_ids, [8, 7], "Festering Wounds visuals")
	_expect_equal(festering.classic_sound_ids, [84, 40], "Festering Wounds sounds")
	_expect_equal(
		festering.autotarget_type,
		Spell.AUTOTARGET_TYPE.ALL_ENEMIES,
		"Festering Wounds targets every enemy"
	)

	var first_target := DiseaseTestCharacter.new("First diseased target")
	var second_target := DiseaseTestCharacter.new("Second diseased target")
	festering.begin_classic_target_resolution(null, 3)
	festering.add_traits_to_creature(null, first_target, 3)
	festering.add_traits_to_creature(null, second_target, 3)
	festering.end_classic_target_resolution()
	var first_condition := int(first_target.traits[0].get_saved_variables()[0])
	var second_condition := int(second_target.traits[0].get_saved_variables()[0])
	_expect(
		first_condition >= 3 and first_condition <= 9,
		"Festering Wounds rolls its source duration"
	)
	_expect_equal(
		second_condition,
		first_condition,
		"Festering Wounds shares one duration roll across the cast"
	)

	var disease = load("res://shared_assets/spells/classic_core_2502_disease.gd").new()
	_expect_equal(disease.name, "Disease", "Disease resource identity")
	_expect_equal(disease.classic_spell_ids, [2502], "Disease exact ID")
	_expect_equal(disease.classic_special, 29, "Disease uses disease special 29")
	_expect_equal(disease.classic_spell_class, 4, "Disease source class")
	_expect_equal(disease.classic_damage_type, 4, "Disease uses chemical damage")
	_expect_equal(disease.classic_cannot, 0, "Disease preserves resistance gates")
	_expect_equal(disease.classic_spell_save_index, 4, "Disease uses chemical saves")
	_expect_equal(disease.classic_spell_save_mode, "half_damage", "a save halves Disease damage")
	_expect_equal(disease.resist, Spell.RESIST_TYPE.IGNORE_DODGE, "Disease checks magic resistance")
	_expect(disease.in_combat and not disease.in_field, "Disease is combat-only")
	_expect_equal(disease.get_range(3, null), 5, "Disease source range")
	_expect_equal(disease.get_target_number(3, null), 1, "Disease targets one area")
	_expect_equal(disease.get_damage_roll(3, null), 6, "Disease direct damage scales by power")
	_expect_equal(disease.get_duration_roll(3, null), -6, "Disease condition is permanent")
	_expect_equal(disease.get_sp_cost(3, null), 90, "Disease casting cost")
	_expect_equal(disease.classic_spell_look_ids, [7, 12], "Disease visuals")
	_expect_equal(disease.classic_sound_ids, [10, 84], "Disease sounds")
	_expect_equal(disease.targettile, Spell.TARGET_TILE.NOWALL, "Disease targets an area")
	_expect_equal(disease.get_aoe(3, null), Spell.AoE_b4, "Disease source area")
	_expect(
		not disease.has_method("apply_classic_scaled_effect"),
		"Disease leaves direct damage on Remake's save-scaled spell path"
	)
	var save_target := RogueTestCharacter.new()
	SpellSavesScript.apply_monster_metadata(
		save_target,
		[0, 0, 0, 0, 100, 0],
		[0, 0, 0, 0, 0, 0]
	)
	var saved_disease: Dictionary = SpellSavesScript.target_resolution(
		save_target, disease, 3, 1
	)
	_expect(saved_disease.get("saved"), "Disease executes its chemical save")
	_expect_equal(
		saved_disease.get("effectScale"),
		0.5,
		"a Disease save halves direct damage without negating the condition path"
	)

	var permanent_target := DiseaseTestCharacter.new("Disease target", true)
	disease.begin_classic_target_resolution(null, 3)
	disease.add_traits_to_creature(null, permanent_target, 3)
	disease.end_classic_target_resolution()
	_expect_equal(permanent_target.traits.size(), 1, "Disease adds one condition trait")
	var permanent_trait: Variant = permanent_target.traits[0]
	_expect_equal(
		permanent_trait.get_saved_variables(),
		[-6],
		"Disease applies its full permanent condition after damage resolution"
	)
	permanent_trait._on_new_round(permanent_target)
	_expect_equal(permanent_target.current_hp, 14, "Disease deals permanent round damage")
	_expect_equal(permanent_trait.get_saved_variables(), [-6], "Disease does not decay")
	var heal_disease = load(
		"res://shared_assets/spells/classic_core_2205_heal_disease.gd"
	).new()
	_expect_equal(
		heal_disease.apply_classic_scaled_effect(null, permanent_target, 1, 1.0),
		1,
		"Heal Disease removes a permanent Classic disease"
	)
	_expect(permanent_target.traits.is_empty(), "the permanent disease remains curable")
	_expect(
		FileAccess.get_file_as_string("res://scripts/states/CbAnimationState.gd").contains(
			'begin_classic_target_resolution'
		),
		"combat resolution brackets multi-target Classic condition rolls"
	)


func _test_classic_poison_spell() -> void:
	var poison = load("res://shared_assets/spells/poison.gd").new()
	_expect_equal(poison.name, "Poison", "Poison native resource identity")
	_expect_equal(poison.classic_spell_ids, [2408], "Poison exact ID")
	_expect_equal(poison.classic_special, 10, "Poison uses condition special 10")
	_expect_equal(poison.classic_spell_class, 4, "Poison source spell class")
	_expect_equal(poison.classic_damage_type, 4, "Poison uses chemical damage")
	_expect_equal(poison.classic_cannot, 0, "Poison preserves resistance gates")
	_expect_equal(poison.classic_spell_save_index, 4, "Poison uses chemical saves")
	_expect_equal(poison.classic_spell_save_mode, "half_damage", "a save halves Poison damage")
	_expect_equal(poison.resist, Spell.RESIST_TYPE.IGNORE_DODGE, "Poison checks magic resistance")
	_expect(poison.in_combat and not poison.in_field, "Poison is combat-only")
	_expect_equal(poison.get_range(3, null), 1, "Poison source range")
	_expect_equal(poison.get_target_number(3, null), 3, "Poison targets one creature per power")
	_expect_equal(poison.get_damage_roll(3, null), 2, "Poison deals fixed immediate damage")
	_expect_equal(poison.get_duration_roll(3, null), -2, "Poison applies a fixed permanent condition")
	_expect_equal(poison.get_sp_cost(3, null), 75, "Poison casting cost")
	_expect_equal(poison.classic_spell_look_ids, [7, 12], "Poison visuals")
	_expect_equal(poison.classic_sound_ids, [40, 84], "Poison sounds")
	_expect_equal(poison.targettile, Spell.TARGET_TILE.CREATURE, "Poison targets creatures")
	_expect_equal(poison.get_aoe(3, null), Spell.AoE_b1, "Poison has no area spread")
	_expect(
		not poison.has_method("apply_classic_scaled_effect"),
		"Poison leaves immediate damage on Remake's save-scaled spell path"
	)

	var save_target := RogueTestCharacter.new()
	SpellSavesScript.apply_monster_metadata(
		save_target,
		[0, 0, 0, 0, 100, 0],
		[0, 0, 0, 0, 0, 0]
	)
	var saved_poison: Dictionary = SpellSavesScript.target_resolution(
		save_target, poison, 3, 1
	)
	_expect(saved_poison.get("saved"), "Poison executes its chemical save")
	_expect_equal(
		saved_poison.get("effectScale"),
		0.5,
		"a Poison save halves immediate damage without negating its condition"
	)
	var class_immune := DiseaseTestCharacter.new("Chemical immune monster")
	SpellSavesScript.apply_monster_metadata(
		class_immune,
		[0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 1, 0]
	)
	var immunity_result: Dictionary = MagicResistanceScript.spell_resolution(
		class_immune, poison, 1, 100
	)
	_expect_equal(
		immunity_result.get("reason"),
		"spell-class-immunity",
		"Poison respects chemical-class immunity before damage and condition handling"
	)

	var temporary_poison: GDScript = load("res://shared_assets/traits/t_poison.gd")
	var permanent_target := DiseaseTestCharacter.new("Poison target", true)
	permanent_target.add_trait(temporary_poison, [5])
	poison.begin_classic_target_resolution(null, 3)
	poison.add_traits_to_creature(null, permanent_target, 3)
	poison.end_classic_target_resolution()
	_expect_equal(permanent_target.traits.size(), 1, "permanent Poison replaces temporary poison")
	var permanent_trait: Variant = permanent_target.traits[0]
	_expect_equal(permanent_trait.name, "p_poison.gd", "Poison uses Remake's saved poison trait")
	_expect_equal(permanent_trait.get_saved_variables(), [2], "Poison stores its full condition power")
	permanent_trait._on_new_round(permanent_target)
	_expect_equal(permanent_target.current_hp, 18, "permanent Poison deals round damage")
	_expect_equal(permanent_trait.get_saved_variables(), [2], "permanent Poison does not decay")

	var heal_poison = load("res://shared_assets/spells/classic_core_2206_heal_poison.gd").new()
	_expect_equal(
		heal_poison.apply_classic_scaled_effect(null, permanent_target, 1, 1.0),
		1,
		"Heal Poison removes permanent Poison"
	)
	_expect(permanent_target.traits.is_empty(), "Poison remains curable through the native spell")

	var mental_immune := DiseaseTestCharacter.new("Mental immune monster")
	mental_immune.add_trait(temporary_poison, [3])
	SpellSavesScript.apply_monster_metadata(
		mental_immune,
		[0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 1]
	)
	poison.add_traits_to_creature(null, mental_immune, 1)
	_expect(
		mental_immune.traits.is_empty(),
		"Poison's source special clears lingering poison from mental-immune monsters"
	)

	var animated_target := DiseaseTestCharacter.new("Animated target", true)
	animated_target.traits.append(ConditionTestTrait.new("p_animated.gd", 1))
	animated_target.add_trait(temporary_poison, [3])
	poison.add_traits_to_creature(null, animated_target, 1)
	_expect_equal(animated_target.traits.size(), 1, "permanent animation clears lingering poison")
	_expect_equal(animated_target.traits[0].name, "p_animated.gd", "animation itself remains intact")

	var poison_rules = load("res://scripts/classic_runtime/classic_poison.gd")
	_expect_equal(
		poison_rules.elapsed_hour_boundaries(3599, 7201),
		2,
		"field poison ticks once per crossed game hour"
	)
	_expect_equal(
		poison_rules.player_reduction(3),
		{"power": 2, "damage": 3},
		"party poison damages before reducing its temporary condition"
	)
	_expect_equal(
		poison_rules.monster_reduction(3),
		{"power": 2, "damage": 2},
		"monster poison reduces before dealing temporary-condition damage"
	)


func _test_classic_spell_deflectors() -> void:
	var specs: Array = [
		{
			"file": "minor_spell_deflector.gd",
			"name": "Minor Spell Deflector",
			"ids": [1508],
			"source_id": 1508,
			"target_type": 5,
			"range": 0,
			"targets": 1,
			"duration": [3, 3],
			"cost": 90,
			"looks": [13, 14],
		},
		{
			"file": "classic_core_2406_minor_spell_deflector.gd",
			"name": "Classic Minor Spell Deflector Priest Enchanter",
			"ids": [2406, 3507],
			"source_id": 2406,
			"target_type": 5,
			"range": 0,
			"targets": 1,
			"duration": [3, 3],
			"cost": 90,
			"looks": [15, 5],
		},
		{
			"file": "major_spell_deflector.gd",
			"name": "Major Spell Deflector",
			"ids": [1707],
			"source_id": 1707,
			"target_type": 0,
			"range": 6,
			"targets": 3,
			"duration": [2, 4],
			"cost": 225,
			"looks": [13, 5],
		},
		{
			"file": "classic_core_2603_major_spell_deflector.gd",
			"name": "Classic Major Spell Deflector Priest Enchanter",
			"ids": [2603, 3703],
			"source_id": 2603,
			"target_type": 0,
			"range": 6,
			"targets": 3,
			"duration": [2, 4],
			"cost": 225,
			"looks": [15, 5],
		},
	]
	for spec: Dictionary in specs:
		var spell = load("res://shared_assets/spells/%s" % spec["file"]).new()
		var label := str(spec["name"])
		_expect_equal(spell.name, label, "%s resource identity" % label)
		_expect_equal(spell.classic_spell_ids, spec["ids"], "%s exact IDs" % label)
		_expect_equal(spell.classic_special, 31, "%s special code" % label)
		_expect_equal(spell.classic_spell_class, 8, "%s source class" % label)
		_expect_equal(spell.classic_damage_type, 8, "%s miscellaneous DRV" % label)
		_expect_equal(spell.classic_cannot, 4, "%s bypasses resistance" % label)
		_expect_equal(spell.classic_spell_save_index, -1, "%s has no save" % label)
		_expect_equal(spell.classic_spell_save_mode, "none", "%s save mode" % label)
		_expect_equal(
			spell.resist,
			Spell.RESIST_TYPE.IGNORE_MRES_DODGE,
			"%s cannot miss or be resisted" % label
		)
		_expect(spell.in_combat and spell.in_field, "%s works in combat and camp" % label)
		_expect_equal(spell.classic_target_type, spec["target_type"], "%s target type" % label)
		_expect_equal(spell.get_range(3, null), spec["range"], "%s source range" % label)
		_expect_equal(
			spell.get_target_number(3, null),
			spec["targets"],
			"%s source target count" % label
		)
		_expect_equal(
			spell.get_min_duration(3, null),
			spec["duration"][0],
			"%s minimum duration" % label
		)
		_expect_equal(
			spell.get_max_duration(3, null),
			spec["duration"][1],
			"%s maximum duration" % label
		)
		_expect_equal(spell.get_sp_cost(3, null), spec["cost"], "%s casting cost" % label)
		_expect_equal(spell.classic_spell_look_ids, spec["looks"], "%s visuals" % label)
		_expect_equal(spell.classic_sound_ids, [58, 67], "%s sounds" % label)
		_expect(not spell.uses_classic_group_effect(), "%s resolves each selected target" % label)

	var minor = load("res://shared_assets/spells/minor_spell_deflector.gd").new()
	_expect_equal(
		minor.schools,
		["Sorcerer", "Priest", "Enchanter"],
		"the native Minor Spell Deflector remains learnable by all source schools"
	)
	var target := ReflectionTestCharacter.new("Reflecting target", true)
	_expect_equal(
		minor.apply_classic_scaled_effect(null, target, 3, 1.0),
		3,
		"Minor Spell Deflector applies one round per power"
	)
	_expect_equal(target.traits.size(), 1, "Spell Deflector adds one reflection trait")
	var reflection_trait: Variant = target.traits[0]
	_expect_equal(reflection_trait.get_saved_variables(), [3], "reflection duration persists")
	reflection_trait._on_new_round(target)
	_expect_equal(reflection_trait.get_saved_variables(), [2], "reflection loses one combat round")
	_expect_equal(
		minor.apply_classic_scaled_effect(null, target, 98, 1.0),
		0,
		"party reflection rejects a stack beyond condition 99"
	)

	var permanent_target := ReflectionTestCharacter.new("Permanent reflector", true)
	permanent_target.add_trait(load("res://shared_assets/traits/p_reflect_spells.gd"), [])
	_expect_equal(
		minor.apply_classic_scaled_effect(null, permanent_target, 3, 1.0),
		0,
		"temporary reflection does not replace a permanent condition"
	)

	var attacker := ReflectionTestCharacter.new("Original caster")
	attacker.position = Vector2i(4, 5)
	var incoming := Spell.new()
	incoming.name = "Incoming Classic spell"
	incoming.attributes = ["Magical"]
	incoming.classic_spell_ids = [1103]
	incoming.classic_spell_class = 6
	incoming.set("classic_target_type", 0)
	var reflection_rules = load(
		"res://scripts/classic_runtime/classic_spell_reflection.gd"
	)
	reflection_rules.begin_resolution(incoming, false)
	var reflected: Array = reflection_trait._on_classic_spell_targeted(
		attacker, incoming, 2, 33
	)
	_expect(not reflected[0], "a roll of 33 reflects a Classic spell")
	_expect_equal(reflected[1].size(), 1, "the first reflector queues one redirected cast")
	var reflected_action: Dictionary = reflected[1][0]
	_expect_equal(reflected_action.get("caster"), target.combat_button, "the defender recasts")
	_expect_equal(
		reflected_action.get("Main Targeted Tile"),
		attacker.position,
		"the reflected spell targets its original caster"
	)
	_expect(
		reflected_action.get("suppress_spell_reflection"),
		"a reflected cast cannot be reflected again"
	)
	var duplicate_reflection: Array = reflection_trait._on_classic_spell_targeted(
		attacker, incoming, 2, 1
	)
	_expect(not duplicate_reflection[0], "a second reflector still avoids the original spell")
	_expect(
		duplicate_reflection[1].is_empty(),
		"an area spell redirects to its caster only once per resolution"
	)
	reflection_rules.end_resolution(incoming)

	reflection_rules.begin_resolution(incoming, false)
	_expect(
		reflection_trait._on_classic_spell_targeted(attacker, incoming, 2, 34)[0],
		"a roll of 34 does not reflect"
	)
	reflection_rules.end_resolution(incoming)
	incoming.classic_spell_class = 9
	_expect(
		not reflection_rules.should_reflect(incoming, 1),
		"Classic missile-class spells bypass reflection"
	)
	incoming.classic_spell_class = 6
	incoming.set("classic_target_type", 10)
	_expect(
		not reflection_rules.should_reflect(incoming, 1),
		"Classic automatic all-enemy spells bypass reflection"
	)
	incoming.set("classic_target_type", 0)
	reflection_rules.begin_resolution(incoming, true)
	_expect(
		not reflection_rules.should_reflect(incoming, 1),
		"a redirected spell cannot recurse through another reflector"
	)
	reflection_rules.end_resolution(incoming)

	var combat_source := FileAccess.get_file_as_string(
		"res://scripts/states/CbAnimationState.gd"
	)
	_expect(
		combat_source.find("on_classic_spell_targeted") \
			< combat_source.find("CLASSIC_MAGIC_RESISTANCE_SCRIPT.spell_resolution"),
		"Classic reflection resolves before magic resistance"
	)


func _test_classic_attack_deflectors() -> void:
	var specs: Array = [
		{
			"file": "minor_attack_deflector.gd",
			"name": "Minor Attack Deflector",
			"ids": [1406, 2307],
			"target_type": 5,
			"range": 0,
			"targets": 1,
			"duration": [3, 3],
			"cost": 75,
			"looks": [13, 5],
			"sounds": [93, 90],
		},
		{
			"file": "classic_core_3408_minor_attack_deflector.gd",
			"name": "Classic Minor Attack Deflector Enchanter",
			"ids": [3408],
			"target_type": 5,
			"range": 0,
			"targets": 1,
			"duration": [3, 3],
			"cost": 75,
			"looks": [15, 5],
			"sounds": [93, 37],
		},
		{
			"file": "major_attack_deflector.gd",
			"name": "Major Attack Deflector",
			"ids": [1606],
			"target_type": 0,
			"range": 5,
			"targets": 3,
			"duration": [3, 6],
			"cost": 135,
			"looks": [13, 5],
			"sounds": [93, 90],
		},
		{
			"file": "classic_core_2506_major_attack_deflector.gd",
			"name": "Classic Major Attack Deflector Priest",
			"ids": [2506],
			"target_type": 0,
			"range": 5,
			"targets": 3,
			"duration": [3, 6],
			"cost": 135,
			"looks": [15, 5],
			"sounds": [93, 10],
		},
		{
			"file": "classic_core_3608_major_attack_deflector.gd",
			"name": "Classic Major Attack Deflector Enchanter",
			"ids": [3608],
			"target_type": 0,
			"range": 5,
			"targets": 3,
			"duration": [3, 6],
			"cost": 135,
			"looks": [13, 5],
			"sounds": [93, 37],
		},
	]
	for spec: Dictionary in specs:
		var spell = load("res://shared_assets/spells/%s" % spec["file"]).new()
		var label := str(spec["name"])
		_expect_equal(spell.name, label, "%s resource identity" % label)
		_expect_equal(spell.classic_spell_ids, spec["ids"], "%s exact IDs" % label)
		_expect_equal(spell.classic_special, 32, "%s special code" % label)
		_expect_equal(spell.classic_spell_class, 8, "%s source class" % label)
		_expect_equal(spell.classic_damage_type, 8, "%s miscellaneous DRV" % label)
		_expect_equal(spell.classic_cannot, 4, "%s bypasses resistance" % label)
		_expect_equal(spell.classic_spell_save_index, -1, "%s has no save" % label)
		_expect_equal(spell.classic_spell_save_mode, "none", "%s save mode" % label)
		_expect_equal(
			spell.resist,
			Spell.RESIST_TYPE.IGNORE_MRES_DODGE,
			"%s cannot miss or be resisted" % label
		)
		_expect(spell.in_combat and spell.in_field, "%s works in combat and camp" % label)
		_expect_equal(spell.classic_target_type, spec["target_type"], "%s target type" % label)
		_expect_equal(spell.get_range(3, null), spec["range"], "%s source range" % label)
		_expect_equal(
			spell.get_target_number(3, null),
			spec["targets"],
			"%s source target count" % label
		)
		_expect_equal(
			spell.get_min_duration(3, null),
			spec["duration"][0],
			"%s minimum duration" % label
		)
		_expect_equal(
			spell.get_max_duration(3, null),
			spec["duration"][1],
			"%s maximum duration" % label
		)
		_expect_equal(spell.get_sp_cost(3, null), spec["cost"], "%s casting cost" % label)
		_expect_equal(spell.classic_spell_look_ids, spec["looks"], "%s visuals" % label)
		_expect_equal(spell.classic_sound_ids, spec["sounds"], "%s sounds" % label)
		_expect(not spell.uses_classic_group_effect(), "%s resolves each selected target" % label)

	var minor = load("res://shared_assets/spells/minor_attack_deflector.gd").new()
	_expect_equal(
		minor.schools,
		["Sorcerer", "Priest", "Enchanter"],
		"the native Minor Attack Deflector remains learnable by all source schools"
	)
	var target := ReflectionTestCharacter.new("Attack-reflecting target", true)
	_expect_equal(
		minor.apply_classic_scaled_effect(null, target, 3, 1.0),
		3,
		"Minor Attack Deflector applies one round per power"
	)
	_expect_equal(target.traits.size(), 1, "Attack Deflector adds one reflection trait")
	var reflection_trait: Variant = target.traits[0]
	_expect_equal(reflection_trait.get_saved_variables(), [3], "attack reflection persists")
	reflection_trait._on_new_round(target)
	_expect_equal(reflection_trait.get_saved_variables(), [2], "attack reflection loses one round")
	_expect_equal(
		minor.apply_classic_scaled_effect(null, target, 98, 1.0),
		0,
		"party attack reflection rejects a stack beyond condition 99"
	)

	var permanent_target := ReflectionTestCharacter.new("Permanent attack reflector", true)
	permanent_target.add_trait(load("res://shared_assets/traits/p_reflect_melee.gd"), [])
	_expect_equal(
		minor.apply_classic_scaled_effect(null, permanent_target, 3, 1.0),
		0,
		"temporary attack reflection does not replace a permanent condition"
	)

	var attacker := ReflectionTestCharacter.new("Melee attacker")
	var weapon := {"name": "Test sword"}
	_expect(
		reflection_trait._on_melee_reflection_check(attacker, weapon, 33),
		"a roll of 33 reflects a successful melee attack"
	)
	_expect(
		not reflection_trait._on_melee_reflection_check(attacker, weapon, 34),
		"a roll of 34 does not reflect a melee attack"
	)
	var combat_source := FileAccess.get_file_as_string(
		"res://scripts/states/CbAnimationState.gd"
	)
	_expect(
		combat_source.find("on_melee_reflection_check") \
			< combat_source.find("calculate_melee_damage", combat_source.find("func perform_melee_attack")),
		"attack reflection redirects the successful hit before damage is rolled"
	)
	_expect(
		combat_source.contains("defendercb = attackercb"),
		"the original attacker becomes the target without a queued counterattack"
	)


func _test_classic_attack_bonus_spells() -> void:
	var specs: Array = [
		{
			"file": "enchanted_blade.gd",
			"name": "Enchanted Blade",
			"ids": [1102],
			"target_type": 1,
			"range": 5,
			"targets": 1,
			"duration": [3, 3],
			"cost": 6,
			"looks": [14, 5],
			"sounds": [0, 35],
		},
		{
			"file": "classic_enchanted_blade.gd",
			"name": "Classic Enchanted Blade",
			"ids": [3104],
			"target_type": 1,
			"range": 5,
			"targets": 1,
			"duration": [3, 3],
			"cost": 6,
			"looks": [14, 5],
			"sounds": [81, 35],
		},
		{
			"file": "classic_core_2503_enchanted_blades.gd",
			"name": "Classic Enchanted Blades Priest",
			"ids": [2503],
			"target_type": 0,
			"range": 3,
			"targets": 3,
			"duration": [1, 3],
			"cost": 45,
			"looks": [14, 5],
			"sounds": [83, 37],
		},
		{
			"file": "enchanted_blades.gd",
			"name": "Enchanted Blades",
			"ids": [3305],
			"target_type": 9,
			"range": 1,
			"targets": 1,
			"duration": [3, 6],
			"cost": 60,
			"looks": [15, 5],
			"sounds": [81, 35],
		},
	]
	for spec: Dictionary in specs:
		var spell = load("res://shared_assets/spells/%s" % spec["file"]).new()
		var label := str(spec["name"])
		_expect_equal(spell.name, label, "%s resource identity" % label)
		_expect_equal(spell.classic_spell_ids, spec["ids"], "%s exact IDs" % label)
		_expect_equal(spell.classic_special, 33, "%s special code" % label)
		_expect_equal(spell.classic_spell_class, 8, "%s source class" % label)
		_expect_equal(spell.classic_damage_type, 8, "%s miscellaneous DRV" % label)
		_expect_equal(spell.classic_cannot, 4, "%s bypasses resistance" % label)
		_expect_equal(spell.classic_spell_save_index, -1, "%s has no save" % label)
		_expect_equal(spell.classic_spell_save_mode, "none", "%s save mode" % label)
		_expect_equal(
			spell.resist,
			Spell.RESIST_TYPE.IGNORE_MRES_DODGE,
			"%s cannot miss or be resisted" % label
		)
		_expect(spell.in_combat and spell.in_field, "%s works in combat and camp" % label)
		_expect_equal(spell.classic_target_type, spec["target_type"], "%s target type" % label)
		_expect_equal(spell.get_range(3, null), spec["range"], "%s source range" % label)
		_expect_equal(
			spell.get_target_number(3, null),
			spec["targets"],
			"%s source target count" % label
		)
		_expect_equal(
			spell.get_min_duration(3, null),
			spec["duration"][0],
			"%s minimum duration" % label
		)
		_expect_equal(
			spell.get_max_duration(3, null),
			spec["duration"][1],
			"%s maximum duration" % label
		)
		_expect_equal(spell.get_sp_cost(3, null), spec["cost"], "%s casting cost" % label)
		_expect_equal(spell.classic_spell_look_ids, spec["looks"], "%s visuals" % label)
		_expect_equal(spell.classic_sound_ids, spec["sounds"], "%s sounds" % label)

	var blade = load("res://shared_assets/spells/enchanted_blade.gd").new()
	_expect_equal(
		blade.schools,
		["Sorcerer", "Enchanter"],
		"native Enchanted Blade remains learnable by both source schools"
	)
	var blades = load("res://shared_assets/spells/enchanted_blades.gd").new()
	_expect_equal(
		blades.schools,
		["Priest", "Enchanter"],
		"native Enchanted Blades remains learnable by both source schools"
	)
	_expect_equal(
		blades.autotarget_type,
		Spell.AUTOTARGET_TYPE.ALL_ALLIES,
		"Enchanted Blades automatically reaches every ally"
	)

	var target := ReflectionTestCharacter.new("Enchanted target", true)
	_expect_equal(
		blade.apply_classic_scaled_effect(null, target, 3, 1.0),
		3,
		"Enchanted Blade applies one attack-bonus point per power"
	)
	_expect_equal(target.traits.size(), 1, "Enchanted Blade adds one attack-bonus trait")
	var attack_bonus_trait: Variant = target.traits[0]
	_expect_equal(attack_bonus_trait.get_saved_variables(), [3], "attack bonus persists")
	_expect_equal(
		attack_bonus_trait._on_get_stat("Bonus_Physical_dmg", 2),
		5,
		"attack bonus adds its remaining condition value to physical damage"
	)
	attack_bonus_trait._on_new_round(target)
	_expect_equal(attack_bonus_trait.get_saved_variables(), [2], "attack bonus loses one round")
	_expect_equal(
		blade.apply_classic_scaled_effect(null, target, 98, 1.0),
		0,
		"player attack bonus rejects a stack beyond condition 99"
	)

	var priest_blades = load(
		"res://shared_assets/spells/classic_core_2503_enchanted_blades.gd"
	).new()
	var first := ReflectionTestCharacter.new("First enchanted target", true)
	var second := ReflectionTestCharacter.new("Second enchanted target", true)
	_expect_equal(
		priest_blades.apply_classic_group_effect(null, [first, second], 3),
		2,
		"Enchanted Blades applies to every selected target"
	)
	var first_duration: Array = first.traits[0].get_saved_variables()
	var second_duration: Array = second.traits[0].get_saved_variables()
	_expect(first_duration[0] in range(1, 4), "Priest Enchanted Blades rolls a 1-3 duration")
	_expect_equal(
		second_duration,
		first_duration,
		"Enchanted Blades shares one duration roll across the cast"
	)


func _test_classic_power_gather_spells() -> void:
	var specs: Array = [
		{
			"file": "power_gather.gd",
			"name": "Power Gather",
			"ids": [1510],
			"looks": [13, 15],
			"sounds": [67, 66],
		},
		{
			"file": "classic_core_3510_power_gather_enchanter.gd",
			"name": "Classic Power Gather Enchanter",
			"ids": [3510],
			"looks": [14, 13],
			"sounds": [67, 66],
		},
	]
	for spec: Dictionary in specs:
		var spell = load("res://shared_assets/spells/%s" % spec["file"]).new()
		var label := str(spec["name"])
		_expect_equal(spell.name, label, "%s resource identity" % label)
		_expect_equal(spell.classic_spell_ids, spec["ids"], "%s exact IDs" % label)
		_expect_equal(spell.classic_special, 34, "%s special code" % label)
		_expect_equal(spell.classic_spell_class, 7, "%s source class" % label)
		_expect_equal(spell.classic_damage_type, 7, "%s special DRV" % label)
		_expect_equal(spell.classic_cannot, 4, "%s bypasses resistance" % label)
		_expect_equal(spell.classic_spell_save_index, -1, "%s has no save" % label)
		_expect_equal(spell.classic_spell_save_mode, "none", "%s save mode" % label)
		_expect_equal(
			spell.resist,
			Spell.RESIST_TYPE.IGNORE_MRES_DODGE,
			"%s cannot miss or be resisted" % label
		)
		_expect(spell.in_combat and spell.in_field, "%s works in combat and camp" % label)
		_expect_equal(spell.classic_target_type, 1, "%s targets one creature" % label)
		_expect_equal(spell.get_range(3, null), 5, "%s source range" % label)
		_expect_equal(spell.get_target_number(3, null), 1, "%s source target count" % label)
		_expect_equal(spell.get_min_duration(3, null), 3, "%s minimum duration" % label)
		_expect_equal(spell.get_max_duration(3, null), 15, "%s maximum duration" % label)
		_expect_equal(spell.get_sp_cost(3, null), 120, "%s casting cost" % label)
		_expect_equal(spell.classic_spell_look_ids, spec["looks"], "%s visuals" % label)
		_expect_equal(spell.classic_sound_ids, spec["sounds"], "%s sounds" % label)

	var power_gather = load("res://shared_assets/spells/power_gather.gd").new()
	_expect_equal(
		power_gather.schools,
		["Sorcerer", "Enchanter"],
		"native Power Gather remains learnable by both source schools"
	)
	var target := SpellPointConditionTestCharacter.new("Power-gathering target", 10, 30)
	var duration: int = power_gather.apply_classic_scaled_effect(null, target, 3, 1.0)
	_expect(duration in range(3, 16), "Power Gather rolls 1-5 condition points per power")
	_expect_equal(target.traits.size(), 1, "Power Gather adds one regeneration trait")
	var power_gather_trait: Variant = target.traits[0]
	_expect_equal(power_gather_trait.get_saved_variables(), [duration], "Power Gather persists")
	power_gather_trait._on_new_round(target)
	_expect_equal(
		target.current_sp,
		mini(30, 10 + duration),
		"Power Gather restores its current condition value before decay"
	)
	_expect_equal(
		power_gather_trait.get_saved_variables(),
		[duration - 1],
		"Power Gather loses one condition point per combat round"
	)
	_expect_equal(
		power_gather_trait.elapsed_hour_boundaries(3599, 7201),
		2,
		"Power Gather uses game-hour boundaries outside combat"
	)

	var capped_target := SpellPointConditionTestCharacter.new("Capped target", 0, 200)
	capped_target.add_trait(
		load("res://shared_assets/traits/t_classic_power_gather.gd"),
		[98]
	)
	_expect(
		not power_gather._apply_duration(capped_target, 2),
		"player Power Gather rejects a stack beyond condition 99"
	)
	var nearly_full := SpellPointConditionTestCharacter.new("Nearly full target", 29, 30)
	var nearly_full_trait = load(
		"res://shared_assets/traits/t_classic_power_gather.gd"
	).new([nearly_full, 4])
	nearly_full_trait._on_new_round(nearly_full)
	_expect_equal(nearly_full.current_sp, 30, "Power Gather clamps at maximum spell points")

	var monster := SpellPointConditionTestCharacter.new("Gathering monster", 5, 30, false)
	var monster_trait = load(
		"res://shared_assets/traits/t_classic_power_gather.gd"
	).new([monster, 4])
	monster_trait._on_new_round(monster)
	_expect_equal(
		monster.current_sp,
		9,
		"Power Gather honors the described monster effect instead of the adjacent-slot typo"
	)


func _test_classic_energy_drain_spells() -> void:
	var specs: Array = [
		{
			"file": "power_wither.gd",
			"name": "Power Wither",
			"ids": [1511],
			"range": 5,
			"duration": [3, 15],
			"damage": [0, 0],
			"cost": 75,
			"save_mode": "negate",
			"save_adjust": 0,
			"resist_adjust": 0,
			"looks": [13, 15],
			"sounds": [66, 67],
		},
		{
			"file": "spirit_drain.gd",
			"name": "Spirit Drain",
			"ids": [2711],
			"range": 1,
			"duration": [3, 6],
			"damage": [10, 20],
			"cost": 105,
			"save_mode": "half_damage",
			"save_adjust": -10,
			"resist_adjust": -10,
			"looks": [5, 15],
			"sounds": [4, 86],
		},
		{
			"file": "classic_core_3511_power_wither_enchanter.gd",
			"name": "Classic Power Wither Enchanter",
			"ids": [3511],
			"range": 5,
			"duration": [3, 15],
			"damage": [0, 0],
			"cost": 75,
			"save_mode": "negate",
			"save_adjust": 0,
			"resist_adjust": 0,
			"looks": [14, 13],
			"sounds": [66, 67],
		},
	]
	for spec: Dictionary in specs:
		var spell = load("res://shared_assets/spells/%s" % spec["file"]).new()
		var label := str(spec["name"])
		_expect_equal(spell.name, label, "%s resource identity" % label)
		_expect_equal(spell.classic_spell_ids, spec["ids"], "%s exact IDs" % label)
		_expect_equal(spell.classic_special, 35, "%s special code" % label)
		_expect_equal(spell.classic_spell_class, 7, "%s source class" % label)
		_expect_equal(spell.classic_damage_type, 7, "%s special DRV" % label)
		_expect_equal(spell.classic_cannot, 0, "%s preserves resistance gates" % label)
		_expect_equal(spell.classic_spell_save_index, 7, "%s uses the special save" % label)
		_expect_equal(spell.classic_spell_save_mode, spec["save_mode"], "%s save mode" % label)
		_expect_equal(spell.classic_save_adjust, spec["save_adjust"], "%s save adjustment" % label)
		_expect_equal(spell.classic_resist_adjust, spec["resist_adjust"], "%s resistance adjustment" % label)
		_expect_equal(
			spell.resist,
			Spell.RESIST_TYPE.IGNORE_DODGE,
			"%s checks Classic magic resistance" % label
		)
		_expect(spell.in_combat and not spell.in_field, "%s is combat-only" % label)
		_expect_equal(spell.classic_target_type, 1, "%s targets one creature" % label)
		_expect_equal(spell.get_range(3, null), spec["range"], "%s source range" % label)
		_expect_equal(spell.get_target_number(3, null), 1, "%s source target count" % label)
		_expect_equal(spell.get_min_duration(3, null), spec["duration"][0], "%s minimum duration" % label)
		_expect_equal(spell.get_max_duration(3, null), spec["duration"][1], "%s maximum duration" % label)
		_expect_equal(spell.get_min_damage(3, null), spec["damage"][0], "%s minimum damage" % label)
		_expect_equal(spell.get_max_damage(3, null), spec["damage"][1], "%s maximum damage" % label)
		_expect_equal(spell.get_sp_cost(3, null), spec["cost"], "%s casting cost" % label)
		_expect_equal(spell.classic_spell_look_ids, spec["looks"], "%s visuals" % label)
		_expect_equal(spell.classic_sound_ids, spec["sounds"], "%s sounds" % label)
		_expect(
			not spell.has_method("apply_classic_scaled_effect"),
			"%s retains the native damage-plus-trait resolution path" % label
		)

	var power_wither = load("res://shared_assets/spells/power_wither.gd").new()
	_expect_equal(
		power_wither.schools,
		["Sorcerer", "Enchanter"],
		"native Power Wither remains learnable by both source schools"
	)
	var spirit_drain = load("res://shared_assets/spells/spirit_drain.gd").new()
	_expect_equal(spirit_drain.schools, ["Priest"], "Spirit Drain remains a Priest spell")
	_expect_equal(
		spirit_drain.classic_spell_save_mode,
		"half_damage",
		"Spirit Drain saves halve immediate damage without negating its trait path"
	)

	var applied_target := SpellPointConditionTestCharacter.new("Withered target", 20, 30)
	power_wither.add_traits_to_creature(null, applied_target, 3)
	_expect_equal(applied_target.traits.size(), 1, "Power Wither adds one drain trait")
	var applied_duration: int = applied_target.traits[0].get_saved_variables()[0]
	_expect(applied_duration in range(3, 16), "Power Wither rolls 1-5 condition points per power")

	var player := SpellPointConditionTestCharacter.new("Withered player", 10, 30)
	var player_trait = load(
		"res://shared_assets/traits/t_classic_power_wither.gd"
	).new([player, 4])
	player_trait._on_new_round(player)
	_expect_equal(player.current_sp, 6, "player energy drain uses the current condition value")
	_expect_equal(player_trait.get_saved_variables(), [3], "player energy drain then decays")

	var monster := SpellPointConditionTestCharacter.new("Withered monster", 10, 30, false)
	var monster_trait = load(
		"res://shared_assets/traits/t_classic_power_wither.gd"
	).new([monster, 4])
	monster_trait._on_new_round(monster)
	_expect_equal(monster.current_sp, 7, "monster energy drain decays before applying")
	_expect_equal(monster_trait.get_saved_variables(), [3], "monster energy drain persists")

	var nearly_empty := SpellPointConditionTestCharacter.new("Nearly empty target", 2, 30)
	var nearly_empty_trait = load(
		"res://shared_assets/traits/t_classic_power_wither.gd"
	).new([nearly_empty, 4])
	nearly_empty_trait._on_new_round(nearly_empty)
	_expect_equal(nearly_empty.current_sp, 0, "energy drain clamps spell points at zero")

	var capped_target := SpellPointConditionTestCharacter.new("Capped wither", 20, 30)
	capped_target.add_trait(
		load("res://shared_assets/traits/t_classic_power_wither.gd"),
		[98]
	)
	_expect(
		not power_wither.apply_energy_drain_duration(capped_target, 2),
		"player energy drain rejects a stack beyond condition 99"
	)


func _test_classic_arcanic_bubble_spells() -> void:
	var specs: Array = [
		{
			"file": "arcanic_bubble.gd",
			"name": "Arcanic Bubble",
			"ids": [1301],
			"target_type": 5,
			"range": 0,
			"targets": 1,
			"duration": [3, 6],
			"cost": 60,
			"looks": [8, 15],
			"sounds": [5, 39],
		},
		{
			"file": "improved_arcanic_bubble.gd",
			"name": "Improved Arcanic Bubble",
			"ids": [1403],
			"target_type": 0,
			"range": 4,
			"targets": 3,
			"duration": [2, 6],
			"cost": 90,
			"looks": [13, 15],
			"sounds": [2, 39],
		},
		{
			"file": "classic_core_2702_improved_arcanic_bubble_priest.gd",
			"name": "Classic Improved Arcanic Bubble Priest",
			"ids": [2702],
			"target_type": 0,
			"range": 4,
			"targets": 3,
			"duration": [2, 6],
			"cost": 90,
			"looks": [8, 15],
			"sounds": [30, 39],
		},
		{
			"file": "classic_core_3302_arcanic_bubble_enchanter.gd",
			"name": "Classic Arcanic Bubble Enchanter",
			"ids": [3302],
			"target_type": 5,
			"range": 0,
			"targets": 1,
			"duration": [3, 6],
			"cost": 60,
			"looks": [8, 13],
			"sounds": [5, 39],
		},
	]
	for spec: Dictionary in specs:
		var spell = load("res://shared_assets/spells/%s" % spec["file"]).new()
		var label := str(spec["name"])
		_expect_equal(spell.name, label, "%s resource identity" % label)
		_expect_equal(spell.classic_spell_ids, spec["ids"], "%s exact IDs" % label)
		_expect_equal(spell.classic_special, 36, "%s special code" % label)
		_expect_equal(spell.classic_spell_class, 8, "%s source class" % label)
		_expect_equal(spell.classic_damage_type, 8, "%s miscellaneous DRV" % label)
		_expect_equal(spell.classic_cannot, 4, "%s bypasses resistance" % label)
		_expect_equal(spell.classic_spell_save_index, -1, "%s has no save" % label)
		_expect_equal(spell.classic_spell_save_mode, "none", "%s save mode" % label)
		_expect_equal(
			spell.resist,
			Spell.RESIST_TYPE.IGNORE_MRES_DODGE,
			"%s cannot miss or be resisted" % label
		)
		_expect(spell.in_combat and spell.in_field, "%s works in combat and camp" % label)
		_expect_equal(spell.classic_target_type, spec["target_type"], "%s target type" % label)
		_expect_equal(spell.get_range(3, null), spec["range"], "%s source range" % label)
		_expect_equal(spell.get_target_number(3, null), spec["targets"], "%s target count" % label)
		_expect_equal(spell.get_min_duration(3, null), spec["duration"][0], "%s minimum duration" % label)
		_expect_equal(spell.get_max_duration(3, null), spec["duration"][1], "%s maximum duration" % label)
		_expect_equal(spell.get_sp_cost(3, null), spec["cost"], "%s casting cost" % label)
		_expect_equal(spell.classic_spell_look_ids, spec["looks"], "%s visuals" % label)
		_expect_equal(spell.classic_sound_ids, spec["sounds"], "%s sounds" % label)

	var bubble = load("res://shared_assets/spells/arcanic_bubble.gd").new()
	_expect_equal(
		bubble.schools,
		["Sorcerer", "Enchanter"],
		"Arcanic Bubble remains learnable by both source schools"
	)
	var improved = load("res://shared_assets/spells/improved_arcanic_bubble.gd").new()
	_expect_equal(
		improved.schools,
		["Sorcerer", "Priest"],
		"Improved Arcanic Bubble remains learnable by both source schools"
	)

	var first := SpellPointConditionTestCharacter.new("First bubble target", 5, 20)
	var second := SpellPointConditionTestCharacter.new("Second bubble target", 5, 20)
	_expect_equal(
		improved.apply_classic_group_effect(null, [first, second], 3),
		2,
		"Improved Arcanic Bubble affects every selected target"
	)
	_expect_equal(first.traits.size(), 1, "Improved Arcanic Bubble adds its trait")
	_expect_equal(
		first.traits[0].get_saved_variables(),
		second.traits[0].get_saved_variables(),
		"one Improved Arcanic Bubble cast shares its duration roll"
	)
	_expect(
		int(first.traits[0].get_saved_variables()[0]) in range(2, 7),
		"Improved Arcanic Bubble rolls two to six rounds"
	)

	var warded := SpellPointConditionTestCharacter.new("Warded player", 10, 12, true, 0)
	var hostile := SpellPointConditionTestCharacter.new("Hostile caster", 20, 20, false, 1)
	var friendly := SpellPointConditionTestCharacter.new("Friendly caster", 20, 20, true, 0)
	var incoming := Spell.new()
	incoming.name = "Incoming Classic spell"
	incoming.attributes = ["Magical"]
	incoming.classic_spell_ids = [1103]
	var absorption_trait = load("res://shared_assets/traits/t_sp_absorb.gd").new([warded, 4])
	absorption_trait._on_classic_spell_targeted_before_resistance(hostile, incoming, 3)
	_expect_equal(warded.current_sp, 12, "Arcanic Bubble gains selected power and clamps players")
	absorption_trait._on_classic_spell_targeted_before_resistance(friendly, incoming, 3)
	_expect_equal(warded.current_sp, 12, "friendly spells do not feed Arcanic Bubble")
	incoming.set_meta("suppress_spell_reflection", true)
	warded.current_sp = 8
	absorption_trait._on_classic_spell_targeted_before_resistance(hostile, incoming, 3)
	_expect_equal(warded.current_sp, 8, "a reflected cast does not feed its new target")
	incoming.remove_meta("suppress_spell_reflection")
	absorption_trait._on_new_round(warded)
	_expect_equal(absorption_trait.get_saved_variables(), [3], "Arcanic Bubble loses one combat round")

	var monster := MonsterSpellPointAbsorptionTestCharacter.new()
	var player_caster := SpellPointConditionTestCharacter.new("Player caster", 20, 20, true, 0)
	var monster_trait = load("res://shared_assets/traits/t_sp_absorb.gd").new([monster, 4])
	monster_trait._on_classic_spell_targeted_before_resistance(player_caster, incoming, 2)
	_expect_equal(monster.stats["curSP"], 7, "monster absorption can exceed its starting pool")
	monster.stats["curSP"] = 0
	monster_trait._on_classic_spell_targeted_before_resistance(player_caster, incoming, 2)
	_expect_equal(monster.stats["curSP"], 0, "monsters without spell points cannot absorb")

	var capped := SpellPointConditionTestCharacter.new("Capped bubble", 10, 20)
	capped.add_trait(load("res://shared_assets/traits/t_sp_absorb.gd"), [98])
	_expect(
		not bubble.apply_classic_group_effect(null, [capped], 3),
		"player Arcanic Bubble rejects a stack beyond condition 99"
	)

	var combat_source := FileAccess.get_file_as_string(
		"res://scripts/states/CbAnimationState.gd"
	)
	var reflection_hook := combat_source.find("on_classic_spell_targeted(")
	var absorption_hook := combat_source.find(
		"on_classic_spell_targeted_before_resistance("
	)
	var resistance_hook := combat_source.find(
		"CLASSIC_MAGIC_RESISTANCE_SCRIPT.spell_resolution"
	)
	_expect(
		reflection_hook < absorption_hook and absorption_hook < resistance_hook,
		"Arcanic Bubble absorbs after reflection and before magic resistance"
	)


func _test_classic_itching_skin_spell() -> void:
	var spell = load("res://shared_assets/spells/itching_skin.gd").new()
	_expect_equal(spell.name, "Itching Skin", "Itching Skin resource identity")
	_expect_equal(spell.classic_spell_ids, [1207, 2209], "Itching Skin exact IDs")
	_expect_equal(spell.classic_special, 37, "Itching Skin special code")
	_expect_equal(spell.classic_spell_class, 5, "Itching Skin mental effect class")
	_expect_equal(spell.classic_damage_type, 5, "Itching Skin mental DRV")
	_expect_equal(spell.classic_cannot, 0, "Itching Skin preserves resistance gates")
	_expect_equal(spell.classic_spell_save_index, 5, "Itching Skin uses the mental save")
	_expect_equal(spell.classic_spell_save_mode, "negate", "Itching Skin save negates")
	_expect_equal(
		spell.resist,
		Spell.RESIST_TYPE.IGNORE_DODGE,
		"Itching Skin checks Classic magic resistance"
	)
	_expect(spell.in_combat and not spell.in_field, "Itching Skin is combat-only")
	_expect_equal(spell.classic_target_type, 10, "Itching Skin targets every enemy")
	_expect(spell.skip_targeting, "Itching Skin skips manual targeting")
	_expect_equal(
		spell.autotarget_type,
		Spell.AUTOTARGET_TYPE.ALL_ENEMIES,
		"Itching Skin uses Remake's all-enemy targeting"
	)
	_expect_equal(spell.get_range(3, null), 0, "Itching Skin source range")
	_expect_equal(spell.get_target_number(3, null), 1, "Itching Skin source target count")
	_expect_equal(spell.get_min_duration(3, null), 3, "Itching Skin minimum duration")
	_expect_equal(spell.get_max_duration(3, null), 9, "Itching Skin maximum duration")
	_expect_equal(spell.get_sp_cost(3, null), 24, "Itching Skin casting cost")
	_expect_equal(spell.classic_spell_look_ids, [16, 16], "Itching Skin visuals")
	_expect_equal(spell.classic_sound_ids, [93, 30], "Itching Skin sounds")
	_expect_equal(
		spell.schools,
		["Sorcerer", "Priest"],
		"Itching Skin remains learnable by both source schools"
	)
	_expect(
		not spell.uses_classic_group_effect(),
		"Itching Skin keeps per-target saves despite its shared duration roll"
	)

	var first := SpellScreenTestCharacter.new("First itching target", true)
	first.stats = {"AccuracyMelee": 20, "AccuracyRanged": 18}
	var second := SpellScreenTestCharacter.new("Second itching target", true)
	second.stats = {"AccuracyMelee": 20, "AccuracyRanged": 18}
	spell.begin_classic_target_resolution(null, 3)
	var first_duration: int = spell.apply_classic_scaled_effect(null, first, 3, 1.0)
	var second_duration: int = spell.apply_classic_scaled_effect(null, second, 3, 1.0)
	spell.end_classic_target_resolution()
	_expect(first_duration in range(3, 10), "Itching Skin rolls one to three per power")
	_expect_equal(second_duration, first_duration, "one cast shares its condition roll")
	_expect_equal(
		first.get_stat("AccuracyMelee"),
		20 - first_duration,
		"Itching Skin reduces melee accuracy by the full condition"
	)
	_expect_equal(
		first.get_stat("AccuracyRanged"),
		18 - first_duration,
		"Itching Skin reduces ranged accuracy by the full condition"
	)
	first.traits[0]._on_new_round(first)
	_expect_equal(
		first.get_stat("AccuracyMelee"),
		21 - first_duration,
		"Itching Skin loses one penalty point each combat round"
	)

	var capped := SpellScreenTestCharacter.new("Capped itching target", true)
	capped.add_trait(load("res://shared_assets/traits/t_hindered_atk.gd"), [98])
	_expect_equal(
		spell.apply_classic_scaled_effect(null, capped, 3, 1.0),
		0,
		"player Itching Skin rejects a stack beyond condition 99"
	)
	var permanent := SpellScreenTestCharacter.new("Permanently hindered", true)
	permanent.traits.append(ConditionTestTrait.new("p_hindered_atk.gd", 5))
	_expect_equal(
		spell.apply_classic_scaled_effect(null, permanent, 3, 1.0),
		0,
		"temporary Itching Skin does not replace permanent hindrance"
	)


func _test_classic_shrink_foe_spell() -> void:
	var spell = load("res://shared_assets/spells/shrink_foe.gd").new()
	_expect_equal(spell.name, "Shrink Foe", "Shrink Foe resource identity")
	_expect_equal(spell.classic_spell_ids, [3109], "Shrink Foe exact ID")
	_expect_equal(spell.classic_special, 38, "Shrink Foe special code")
	_expect_equal(spell.classic_spell_class, 7, "Shrink Foe special effect class")
	_expect_equal(spell.classic_damage_type, 7, "Shrink Foe special DRV")
	_expect_equal(spell.classic_cannot, 3, "Shrink Foe bypasses resistance gates")
	_expect_equal(spell.classic_spell_save_index, -1, "Shrink Foe has no save")
	_expect_equal(spell.classic_spell_save_mode, "none", "Shrink Foe has no save mode")
	_expect_equal(
		spell.resist,
		Spell.RESIST_TYPE.IGNORE_MRES_DODGE,
		"Shrink Foe cannot miss or be resisted"
	)
	_expect(spell.in_combat and not spell.in_field, "Shrink Foe is combat-only")
	_expect_equal(spell.classic_target_type, 4, "Shrink Foe uses a power-scaled area")
	_expect(not spell.skip_targeting, "Shrink Foe keeps manual area targeting")
	_expect_equal(
		spell.targettile,
		Spell.TARGET_TILE.NOWALL,
		"Shrink Foe preserves no-wall area targeting"
	)
	_expect_equal(spell.get_range(3, null), 74, "Shrink Foe source range")
	_expect(not spell.los, "Shrink Foe does not require line of sight")
	_expect_equal(spell.get_aoe(3, null), Spell.AoE_b3, "Shrink Foe area scales with power")
	_expect_equal(spell.get_target_number(3, null), 1, "Shrink Foe source target count")
	_expect_equal(spell.get_min_duration(3, null), 3, "Shrink Foe minimum duration")
	_expect_equal(spell.get_max_duration(3, null), 6, "Shrink Foe maximum duration")
	_expect_equal(spell.get_sp_cost(3, null), 9, "Shrink Foe casting cost")
	_expect_equal(spell.classic_spell_look_ids, [15, 15], "Shrink Foe visuals")
	_expect_equal(spell.classic_sound_ids, [30, 26], "Shrink Foe sounds")
	_expect_equal(spell.schools, ["Enchanter"], "Shrink Foe remains an Enchanter spell")

	var first := SpellScreenTestCharacter.new("First shrunken foe", true)
	first.stats = {"EvasionMelee": 20, "EvasionRanged": 18}
	var second := SpellScreenTestCharacter.new("Second shrunken foe", true)
	second.stats = {"EvasionMelee": 20, "EvasionRanged": 18}
	_expect_equal(
		spell.apply_classic_group_effect(null, [first, second], 3),
		2,
		"Shrink Foe affects every creature in its area"
	)
	var duration: int = first.traits[0].get_saved_variables()[0]
	_expect(duration in range(3, 7), "Shrink Foe rolls three to six rounds")
	_expect_equal(
		second.traits[0].get_saved_variables()[0],
		duration,
		"one Shrink Foe cast shares its condition roll"
	)
	_expect_equal(
		first.get_stat("EvasionMelee"),
		20 - duration,
		"Shrink Foe reduces melee evasion by the full condition"
	)
	_expect_equal(
		first.get_stat("EvasionRanged"),
		18 - duration,
		"Shrink Foe reduces ranged evasion by the full condition"
	)
	first.traits[0]._on_new_round(first)
	_expect_equal(
		first.get_stat("EvasionMelee"),
		21 - duration,
		"Shrink Foe loses one penalty point each combat round"
	)

	var capped := SpellScreenTestCharacter.new("Capped shrunken foe", true)
	capped.add_trait(load("res://shared_assets/traits/t_hindered_def.gd"), [98])
	_expect_equal(
		spell.apply_classic_scaled_effect(null, capped, 3, 1.0),
		0,
		"player Shrink Foe rejects a stack beyond condition 99"
	)
	var permanent := SpellScreenTestCharacter.new("Permanently vulnerable", true)
	permanent.traits.append(ConditionTestTrait.new("p_hindered_def.gd", 5))
	_expect_equal(
		spell.apply_classic_scaled_effect(null, permanent, 3, 1.0),
		0,
		"temporary Shrink Foe does not replace permanent hindrance"
	)


func _test_classic_shield_from_hits_spells() -> void:
	var sparkling = load("res://shared_assets/spells/sparkling_armor.gd").new()
	var priest = load("res://shared_assets/spells/vorpal_plate.gd").new()
	var enchanter = load(
		"res://shared_assets/spells/classic_core_3212_vorpal_plate_enchanter.gd"
	).new()
	var major = load("res://shared_assets/spells/major_vorpal_plate.gd").new()
	var spells := [sparkling, priest, enchanter, major]
	var expected_ids := [1111, 2112, 3212, 3406]
	for index: int in range(spells.size()):
		var spell: Variant = spells[index]
		_expect_equal(
			spell.classic_spell_ids,
			[expected_ids[index]],
			"Shield from Hits spell keeps its exact ID"
		)
		_expect_equal(spell.classic_special, 8, "Shield from Hits special code")
		_expect_equal(spell.classic_spell_class, 8, "Shield from Hits effect class")
		_expect_equal(spell.classic_damage_type, 8, "Shield from Hits miscellaneous DRV")
		_expect_equal(spell.classic_cannot, 4, "Shield from Hits bypasses resistance")
		_expect_equal(spell.classic_spell_save_index, -1, "Shield from Hits has no save")
		_expect_equal(spell.classic_spell_save_mode, "none", "Shield from Hits save mode")
		_expect(
			spell.in_combat and spell.in_field,
			"Shield from Hits spell works in combat and camp"
		)
		_expect_equal(
			spell.resist,
			Spell.RESIST_TYPE.IGNORE_MRES_DODGE,
			"Shield from Hits cannot miss or be resisted"
		)

	_expect_equal(sparkling.name, "Sparkling Armor", "Sparkling Armor resource identity")
	_expect(sparkling.skip_targeting, "Sparkling Armor targets its caster")
	_expect_equal(sparkling.get_min_duration(3, null), 3, "Sparkling Armor duration")
	_expect_equal(sparkling.get_max_duration(3, null), 3, "Sparkling Armor fixed duration")
	_expect_equal(sparkling.get_sp_cost(3, null), 6, "Sparkling Armor casting cost")
	_expect_equal(sparkling.classic_spell_look_ids, [13, 5], "Sparkling Armor visuals")
	_expect_equal(sparkling.classic_sound_ids, [26, 10], "Sparkling Armor sounds")

	_expect_equal(priest.name, "Vorpal Plate", "Priest Vorpal Plate resource identity")
	_expect_equal(priest.classic_target_type, 3, "Priest Vorpal Plate area target")
	_expect(not priest.skip_targeting, "Priest Vorpal Plate keeps manual targeting")
	_expect_equal(priest.get_range(3, null), 3, "Priest Vorpal Plate range")
	_expect(priest.los, "Priest Vorpal Plate requires line of sight")
	_expect_equal(priest.get_aoe(3, null), Spell.AoE_b4, "Priest Vorpal Plate area")
	_expect_equal(priest.get_min_duration(3, null), 3, "Priest Vorpal Plate minimum duration")
	_expect_equal(priest.get_max_duration(3, null), 6, "Priest Vorpal Plate maximum duration")
	_expect_equal(priest.get_sp_cost(3, null), 24, "Priest Vorpal Plate casting cost")
	_expect_equal(priest.classic_spell_look_ids, [13, 5], "Priest Vorpal Plate visuals")
	_expect_equal(priest.classic_sound_ids, [35, 37], "Priest Vorpal Plate sounds")

	_expect_equal(
		enchanter.name,
		"Classic Vorpal Plate Enchanter",
		"Enchanter Vorpal Plate has a distinct native identity"
	)
	_expect(enchanter.skip_targeting, "Enchanter Vorpal Plate centers on its caster")
	_expect_equal(
		enchanter.autotarget_type,
		Spell.AUTOTARGET_TYPE.SELF,
		"Enchanter Vorpal Plate uses self targeting"
	)
	_expect_equal(enchanter.get_range(3, null), 0, "Enchanter Vorpal Plate range")
	_expect_equal(enchanter.get_aoe(3, null), Spell.AoE_b4, "Enchanter Vorpal Plate area")
	_expect_equal(enchanter.get_sp_cost(3, null), 24, "Enchanter Vorpal Plate casting cost")

	_expect_equal(major.name, "Major Vorpal Plate", "Major Vorpal Plate resource identity")
	_expect_equal(major.classic_target_type, 9, "Major Vorpal Plate targets all allies")
	_expect(major.skip_targeting, "Major Vorpal Plate needs no target selection")
	_expect_equal(
		major.autotarget_type,
		Spell.AUTOTARGET_TYPE.ALL_ALLIES,
		"Major Vorpal Plate uses ally autotargeting"
	)
	_expect_equal(major.get_min_duration(3, null), 3, "Major Vorpal Plate duration")
	_expect_equal(major.get_max_duration(3, null), 3, "Major Vorpal Plate fixed duration")
	_expect_equal(major.get_sp_cost(3, null), 60, "Major Vorpal Plate casting cost")
	_expect_equal(major.classic_spell_look_ids, [15, 5], "Major Vorpal Plate visuals")
	_expect_equal(major.classic_sound_ids, [35, 37], "Major Vorpal Plate sounds")

	var first := SpellScreenTestCharacter.new("First armored target", true)
	first.stats = {"EvasionMelee": 5, "EvasionRanged": 7}
	var second := SpellScreenTestCharacter.new("Second armored target", true)
	second.stats = {"EvasionMelee": 5, "EvasionRanged": 7}
	_expect_equal(
		priest.apply_classic_group_effect(null, [first, second], 3),
		2,
		"Vorpal Plate affects every creature in its area"
	)
	var duration: int = first.traits[0].get_saved_variables()[0]
	_expect(duration in range(3, 7), "Vorpal Plate rolls three to six condition points")
	_expect_equal(
		second.traits[0].get_saved_variables(),
		[duration],
		"one Vorpal Plate cast shares its condition roll"
	)
	_expect(
		is_equal_approx(first.get_stat("EvasionMelee"), 5.0 + 0.4 * duration),
		"Shield from Hits translates each point to two percent melee protection"
	)
	_expect_equal(
		first.get_stat("EvasionRanged"),
		7,
		"Shield from Hits does not alter ranged evasion"
	)
	_expect(
		is_equal_approx(
			0.05 * (float(first.get_stat("EvasionMelee")) - 5.0),
			0.02 * duration
		),
		"Remake melee accuracy receives the exact Classic percentage change"
	)
	first.traits[0]._on_new_round(first)
	_expect_equal(
		first.traits[0].get_saved_variables(),
		[duration - 1],
		"Shield from Hits loses one point each combat round"
	)
	var saved_duration: Array = first.traits[0].get_saved_variables()
	var restored := SpellScreenTestCharacter.new("Restored armored target", true)
	restored.add_trait(load("res://shared_assets/traits/t_pro_hits.gd"), saved_duration)
	_expect_equal(
		restored.traits[0].get_saved_variables(),
		saved_duration,
		"temporary Shield from Hits preserves its saved condition"
	)

	var capped := SpellScreenTestCharacter.new("Capped armored target", true)
	capped.add_trait(load("res://shared_assets/traits/t_pro_hits.gd"), [98])
	_expect_equal(
		sparkling.apply_classic_scaled_effect(null, capped, 2, 1.0),
		0,
		"player Shield from Hits rejects a stack beyond condition 99"
	)
	_expect_equal(
		capped.traits[0].get_saved_variables(),
		[98],
		"rejected Shield from Hits leaves the current duration unchanged"
	)
	var permanent_target := SpellScreenTestCharacter.new("Permanently armored", true)
	permanent_target.traits.append(ConditionTestTrait.new("p_pro_hits.gd", 3))
	_expect_equal(
		sparkling.apply_classic_scaled_effect(null, permanent_target, 3, 1.0),
		0,
		"temporary Shield from Hits does not replace a permanent condition"
	)
	var permanent_trait = load("res://shared_assets/traits/p_pro_hits.gd").new(
		[permanent_target, 3]
	)
	_expect_equal(permanent_trait.name, "p_pro_hits.gd", "permanent condition save identity")
	_expect_equal(permanent_trait.get_saved_variables(), [3], "permanent condition persists")
	_expect(
		is_equal_approx(permanent_trait._on_get_stat("EvasionMelee", 5), 6.2),
		"permanent Shield from Hits uses the same source percentage"
	)


func _test_classic_projectile_protection_spells() -> void:
	var shield = load("res://shared_assets/spells/shield_from_projectiles.gd").new()
	var screen = load("res://shared_assets/spells/missile_screen.gd").new()
	for spell: Variant in [shield, screen]:
		_expect_equal(spell.classic_special, 9, "projectile protection special code")
		_expect_equal(spell.classic_cannot, 4, "projectile protection bypasses resistance")
		_expect_equal(spell.classic_spell_save_index, -1, "projectile protection has no save")
		_expect_equal(spell.classic_spell_save_mode, "none", "projectile protection save mode")
		_expect_equal(
			spell.resist,
			Spell.RESIST_TYPE.IGNORE_MRES_DODGE,
			"projectile protection cannot miss or check general resistance"
		)

	_expect_equal(shield.name, "Shield from Projectiles", "Priest spell identity")
	_expect_equal(shield.classic_spell_ids, [2210], "Priest spell exact ID")
	_expect_equal(shield.classic_spell_class, 8, "Priest spell effect class")
	_expect_equal(shield.classic_damage_type, 8, "Priest spell miscellaneous DRV")
	_expect(shield.skip_targeting, "Priest spell targets its caster")
	_expect_equal(shield.get_range(3, null), 0, "Priest spell range")
	_expect_equal(shield.get_min_duration(3, null), 3, "Priest spell minimum duration")
	_expect_equal(shield.get_max_duration(3, null), 6, "Priest spell maximum duration")
	_expect_equal(shield.get_sp_cost(3, null), 24, "Priest spell casting cost")
	_expect_equal(shield.classic_spell_look_ids, [13, 5], "Priest spell visuals")
	_expect_equal(shield.classic_sound_ids, [93, 53], "Priest spell sounds")
	_expect(shield.in_combat and shield.in_field, "Priest spell works in combat and camp")

	_expect_equal(screen.name, "Missile Screen", "Enchanter spell identity")
	_expect_equal(screen.classic_spell_ids, [3508], "Enchanter spell exact ID")
	_expect_equal(screen.classic_spell_class, 0, "Enchanter spell effect class")
	_expect_equal(screen.classic_damage_type, 0, "Enchanter spell zero DRV")
	_expect_equal(screen.classic_target_type, 1, "Enchanter spell targets one creature")
	_expect_equal(screen.targettile, Spell.TARGET_TILE.CREATURE, "Enchanter target tile")
	_expect_equal(screen.get_range(3, null), 8, "Enchanter spell range")
	_expect(screen.los, "Enchanter spell requires line of sight")
	_expect_equal(screen.get_min_duration(3, null), 7, "Enchanter spell minimum duration")
	_expect_equal(screen.get_max_duration(3, null), 22, "Enchanter spell maximum duration")
	_expect_equal(screen.get_sp_cost(3, null), 45, "Enchanter spell casting cost")
	_expect_equal(screen.classic_spell_look_ids, [13, 15], "Enchanter spell visuals")
	_expect_equal(screen.classic_sound_ids, [75, 77], "Enchanter spell sounds")
	_expect(screen.in_combat and not screen.in_field, "Enchanter spell is combat-only")

	var charm_target := SpellScreenTestCharacter.new("Charm-resistant ally", true)
	charm_target.stats = {"MultiplierMental": 0.5, "ResistanceMental": 0}
	var resisted_screen: Dictionary = MagicResistanceScript.spell_resolution(
		charm_target, screen, 3, 100
	)
	_expect(resisted_screen.get("resisted"), "Missile Screen keeps its class-zero precheck")
	_expect_equal(
		resisted_screen.get("reason"),
		"charm-resistance",
		"Missile Screen reports the source precheck"
	)
	charm_target.stats["MultiplierMental"] = 1.0
	_expect(
		not MagicResistanceScript.spell_resolution(
			charm_target, screen, 3, 100
		).get("resisted"),
		"Missile Screen proceeds after its class-zero precheck fails"
	)

	var protected_target := SpellScreenTestCharacter.new("Missile-protected target", true)
	var duration: int = shield.apply_classic_scaled_effect(null, protected_target, 3, 1.0)
	_expect(duration in range(3, 7), "Priest spell rolls three to six condition points")
	_expect_equal(
		protected_target.traits[0].get_saved_variables(),
		[duration],
		"temporary projectile protection preserves its saved condition"
	)
	var flame_missile = load(
		"res://shared_assets/spells/classic_core_1503_flame_missile.gd"
	).new()
	var blocked: Dictionary = MagicResistanceScript.spell_resolution(
		protected_target, flame_missile, 4, 100
	)
	_expect(blocked.get("resisted"), "projectile protection stops a class-9 missile")
	_expect_equal(
		blocked.get("reason"),
		"projectile-protection",
		"class-9 immunity reports its own resolution stage"
	)
	_expect(
		not blocked.get("checksScreen"),
		"class-9 projectile protection runs after the source screen bypass"
	)
	var compiled_record := _custom_spell_record(0, 5101)
	compiled_record["spellClass"] = 9
	compiled_record["cannot"] = 4
	var compiled_missile = load(
		"res://scripts/classic_runtime/classic_spell_override.gd"
	).new()
	compiled_missile.configure(compiled_record)
	var compiled_blocked: Dictionary = MagicResistanceScript.custom_spell_resolution(
		protected_target, compiled_missile, 1, 100
	)
	_expect(compiled_blocked.get("resisted"), "compiled class-9 missiles share protection")
	_expect_equal(
		compiled_blocked.get("reason"),
		"projectile-protection",
		"compiled projectile protection reports the shared stage"
	)
	protected_target.traits[0]._on_new_round(protected_target)
	_expect_equal(
		protected_target.traits[0].get_saved_variables(),
		[duration - 1],
		"temporary projectile protection loses one point each combat round"
	)

	var ordinary_spell := Spell.new()
	ordinary_spell.attributes = ["Ranged"]
	_expect(
		not ProjectileProtectionScript.spell_resolution(
			protected_target, ordinary_spell
		).get("checksProjectileProtection"),
		"the Classic adapter does not reinterpret ordinary ranged attacks as class 9"
	)
	var native_projectile := Spell.new()
	native_projectile.attributes = ["Projectile"]
	_expect_equal(
		protected_target.traits[0]._on_spell_hit_chara(
			null, native_projectile, 1, -10
		),
		[false, 0, []],
		"the updated trait retains Remake's native Projectile behavior"
	)

	var capped := SpellScreenTestCharacter.new("Capped missile protection", true)
	capped.add_trait(load("res://shared_assets/traits/t_pro_proj.gd"), [98])
	_expect_equal(
		shield.apply_classic_scaled_effect(null, capped, 2, 1.0),
		0,
		"player projectile protection rejects a stack beyond condition 99"
	)
	var permanent_target := SpellScreenTestCharacter.new("Permanent missile protection", true)
	var permanent_trait = load("res://shared_assets/traits/p_pro_proj.gd").new(
		[permanent_target]
	)
	permanent_target.traits.append(permanent_trait)
	_expect(ProjectileProtectionScript.is_active(permanent_target), "permanent protection is active")
	_expect_equal(
		shield.apply_classic_scaled_effect(null, permanent_target, 3, 1.0),
		0,
		"temporary projectile protection does not replace a permanent condition"
	)
	_expect_equal(permanent_trait.get_saved_variables(), [], "permanent protection persists")


func _test_classic_party_condition_spells() -> void:
	_expect_equal(
		ClassicPartyConditionScript.apply(5, 3),
		5,
		"a shorter party spell does not replace the current condition"
	)
	_expect_equal(
		ClassicPartyConditionScript.apply(5, 8),
		8,
		"a longer party spell replaces the current condition"
	)
	_expect_equal(
		ClassicPartyConditionScript.advance_time(3, 3599, 3600),
		2,
		"party conditions lose one point at a game-hour boundary"
	)
	_expect_equal(
		ClassicPartyConditionScript.advance_time(3, 3600, 7199),
		3,
		"party conditions do not decay within a game hour"
	)
	_expect_equal(
		ClassicPartyConditionScript.remaining_seconds(3, 3500),
		7300,
		"party conditions expose an equivalent native HUD duration"
	)

	var free_fall = load("res://shared_assets/spells/free_fall.gd").new()
	var hover = load("res://shared_assets/spells/hover.gd").new()
	var waterworld = load("res://shared_assets/spells/waterworld.gd").new()
	var vorpal_shield = load("res://shared_assets/spells/vorpal_shield.gd").new()
	var ogre_hide = load("res://shared_assets/spells/ogre_hide.gd").new()
	var dragon_hide = load("res://shared_assets/spells/dragon_hide.gd").new()
	var discover_secret = load("res://shared_assets/spells/discover_secret.gd").new()
	var wizard_eye = load("res://shared_assets/spells/wizard_eye.gd").new()
	var thought_lace = load("res://shared_assets/spells/thought_lace.gd").new()
	var sentry = load("res://shared_assets/spells/sentry.gd").new()
	var priest_sentry = load(
		"res://shared_assets/spells/classic_core_2710_sentry_priest.gd"
	).new()
	_expect_equal(free_fall.name, "Free Fall", "Free Fall resource identity")
	_expect_equal(
		free_fall.classic_spell_ids,
		[1105, 2104],
		"Sorcerer and Priest Free Fall share source-equivalent mechanics"
	)
	_expect_equal(hover.name, "Hover", "Hover resource identity")
	_expect_equal(hover.classic_spell_ids, [1205], "Hover exports its exact Classic ID")
	for spell: Variant in [free_fall, hover]:
		var label := str(spell.name)
		_expect_equal(spell.classic_special, 6, "%s party condition index" % label)
		_expect_equal(spell.classic_target_type, 7, "%s targets the party" % label)
		_expect(spell.in_field and not spell.in_combat, "%s is field-only" % label)
		_expect(spell.skip_targeting, "%s bypasses creature targeting" % label)
		_expect_equal(spell.get_targets(3, null), 0, "%s selects no creatures" % label)
		_expect_equal(spell.get_target_number(3, null), 0, "%s reports a party target" % label)
		_expect_equal(spell.classic_spell_save_index, -1, "%s has no save" % label)
		_expect_equal(
			spell.resist,
			Spell.RESIST_TYPE.IGNORE_MRES_DODGE,
			"%s bypasses creature resistance" % label
		)
	_expect_equal(free_fall.get_min_duration(3, null), 6, "Free Fall minimum duration")
	_expect_equal(free_fall.get_max_duration(3, null), 12, "Free Fall maximum duration")
	_expect_equal(free_fall.get_sp_cost(3, null), 30, "Free Fall casting cost")
	_expect_equal(free_fall.classic_sound_ids, [99, 21], "Free Fall source sounds")
	_expect_equal(
		free_fall.schools,
		["Sorcerer", "Priest"],
		"Free Fall remains available to both source caster classes"
	)
	_expect_equal(hover.get_min_duration(3, null), 15, "Hover minimum duration")
	_expect_equal(hover.get_max_duration(3, null), 30, "Hover maximum duration")
	_expect_equal(hover.get_sp_cost(3, null), 45, "Hover casting cost")
	_expect_equal(hover.classic_sound_ids, [22, 4], "Hover source sounds")
	_expect_equal(waterworld.name, "Waterworld", "Waterworld resource identity")
	_expect_equal(waterworld.classic_spell_ids, [1312], "Waterworld exact identity")
	_expect_equal(waterworld.classic_special, 1, "Waterworld party condition index")
	_expect_equal(waterworld.classic_target_type, 7, "Waterworld targets the party")
	_expect(waterworld.in_field and not waterworld.in_combat, "Waterworld is field-only")
	_expect_equal(waterworld.get_range(3, null), 0, "Waterworld source range")
	_expect_equal(waterworld.get_min_duration(3, null), 9, "Waterworld minimum duration")
	_expect_equal(waterworld.get_max_duration(3, null), 15, "Waterworld maximum duration")
	_expect_equal(waterworld.get_sp_cost(3, null), 75, "Waterworld casting cost")
	_expect_equal(waterworld.classic_spell_look_ids, [8, 8], "Waterworld source visuals")
	_expect_equal(waterworld.classic_sound_ids, [18, 66], "Waterworld source sounds")
	_expect_equal(waterworld.classic_cannot, 3, "Waterworld bypasses creature resistance")
	_expect_equal(
		waterworld.resist,
		Spell.RESIST_TYPE.IGNORE_MRES_DODGE,
		"Waterworld does not resolve against a creature"
	)
	var hide_cases := [
		{
			"spell": vorpal_shield,
			"name": "Vorpal Shield",
			"id": 2312,
			"minimum": 36,
			"maximum": 72,
			"cost": 60,
			"looks": [13, 5],
			"sounds": [37, 94],
			"school": "Priest",
		},
		{
			"spell": ogre_hide,
			"name": "Ogre Hide",
			"id": 3107,
			"minimum": 24,
			"maximum": 48,
			"cost": 45,
			"looks": [16, 16],
			"sounds": [91, 74],
			"school": "Enchanter",
		},
		{
			"spell": dragon_hide,
			"name": "Dragon Hide",
			"id": 3204,
			"minimum": 48,
			"maximum": 96,
			"cost": 60,
			"looks": [16, 16],
			"sounds": [91, 74],
			"school": "Enchanter",
		},
	]
	for hide_case: Dictionary in hide_cases:
		var spell: Variant = hide_case["spell"]
		var label := str(hide_case["name"])
		_expect_equal(spell.name, label, "%s resource identity" % label)
		_expect_equal(spell.classic_spell_ids, [hide_case["id"]], "%s exact identity" % label)
		_expect_equal(spell.classic_special, 2, "%s party condition index" % label)
		_expect_equal(spell.classic_target_type, 7, "%s targets the party" % label)
		_expect(spell.in_field and not spell.in_combat, "%s is field-only" % label)
		_expect_equal(spell.classic_spell_class, 8, "%s source spell class" % label)
		_expect_equal(spell.classic_damage_type, 8, "%s miscellaneous type" % label)
		_expect_equal(spell.classic_cannot, 3, "%s bypasses creature resolution" % label)
		_expect_equal(spell.classic_spell_save_mode, "none", "%s has no save" % label)
		_expect_equal(spell.get_range(3, null), 0, "%s source range" % label)
		_expect_equal(
			spell.get_min_duration(3, null),
			hide_case["minimum"],
			"%s minimum duration" % label
		)
		_expect_equal(
			spell.get_max_duration(3, null),
			hide_case["maximum"],
			"%s maximum duration" % label
		)
		_expect_equal(spell.get_sp_cost(3, null), hide_case["cost"], "%s casting cost" % label)
		_expect_equal(spell.classic_spell_look_ids, hide_case["looks"], "%s source visuals" % label)
		_expect_equal(spell.classic_sound_ids, hide_case["sounds"], "%s source sounds" % label)
		_expect_equal(spell.schools, [hide_case["school"]], "%s caster school" % label)

	var protected_damage := ClassicPartyConditionScript.adjust_weapon_damage(
		{
			"Physical": 9,
			"Bonus_dmg": 2,
			"Chemical": 4,
			"total": 15,
		},
		1,
		true
	)
	_expect_equal(protected_damage.get("Physical"), 6, "Dragon Hide combines physical damage")
	_expect_equal(protected_damage.get("Bonus_dmg"), 0, "Dragon Hide consumes the bonus field")
	_expect_equal(protected_damage.get("Chemical"), 4, "Dragon Hide leaves elemental damage unchanged")
	_expect_equal(protected_damage.get("total"), 10, "Dragon Hide removes five physical damage")
	_expect_equal(
		ClassicPartyConditionScript.adjust_weapon_damage(
			{"Physical": 3, "Bonus_dmg": 0, "total": 3},
			1,
			true
		).get("total"),
		1,
		"Dragon Hide preserves one point from a successful physical hit"
	)
	_expect_equal(
		ClassicPartyConditionScript.adjust_weapon_damage(
			{"Physical": 9, "Bonus_dmg": 2, "total": 11},
			1,
			false
		).get("total"),
		11,
		"Dragon Hide does not affect attacks outside the protected party"
	)
	_expect_equal(
		discover_secret.name,
		"Discover Secret",
		"Discover Secret resource identity"
	)
	_expect_equal(
		discover_secret.classic_spell_ids,
		[1202, 2202, 3203],
		"all three schools share source-equivalent Discover Secret mechanics"
	)
	_expect_equal(discover_secret.classic_special, 3, "Discover Secret condition index")
	_expect_equal(
		discover_secret.classic_target_type,
		7,
		"Discover Secret targets the party"
	)
	_expect(
		discover_secret.in_field and not discover_secret.in_combat,
		"Discover Secret is field-only"
	)
	_expect_equal(
		discover_secret.get_min_duration(3, null),
		30,
		"Discover Secret minimum duration"
	)
	_expect_equal(
		discover_secret.get_max_duration(3, null),
		90,
		"Discover Secret maximum duration"
	)
	_expect_equal(discover_secret.get_sp_cost(3, null), 15, "Discover Secret casting cost")
	_expect_equal(
		discover_secret.schools,
		["Sorcerer", "Priest", "Enchanter"],
		"Discover Secret remains available to all three source caster classes"
	)
	_expect_equal(wizard_eye.name, "Wizard Eye", "Wizard Eye resource identity")
	_expect_equal(wizard_eye.classic_spell_ids, [1512], "Wizard Eye exact identity")
	_expect_equal(wizard_eye.classic_special, 4, "Wizard Eye condition index")
	_expect_equal(wizard_eye.classic_target_type, 7, "Wizard Eye targets the party")
	_expect(wizard_eye.in_field and not wizard_eye.in_combat, "Wizard Eye is field-only")
	_expect_equal(wizard_eye.get_min_duration(3, null), 8, "Wizard Eye minimum duration")
	_expect_equal(wizard_eye.get_max_duration(3, null), 35, "Wizard Eye maximum duration")
	_expect_equal(wizard_eye.get_sp_cost(3, null), 120, "Wizard Eye casting cost")
	_expect_equal(wizard_eye.classic_spell_look_ids, [13, 5], "Wizard Eye source visuals")
	_expect_equal(wizard_eye.classic_sound_ids, [67, 83], "Wizard Eye source sounds")
	_expect_equal(thought_lace.name, "Thought Lace", "Thought Lace resource identity")
	_expect_equal(thought_lace.classic_spell_ids, [1612], "Thought Lace exact identity")
	_expect_equal(thought_lace.classic_special, 8, "Thought Lace condition index")
	_expect_equal(thought_lace.classic_target_type, 7, "Thought Lace targets the party")
	_expect(thought_lace.in_field and thought_lace.in_combat, "Thought Lace works in field and combat")
	_expect_equal(thought_lace.get_min_duration(3, null), 3, "Thought Lace duration")
	_expect_equal(thought_lace.get_max_duration(3, null), 3, "Thought Lace fixed duration")
	_expect_equal(thought_lace.get_sp_cost(3, null), 225, "Thought Lace casting cost")
	_expect_equal(thought_lace.classic_spell_look_ids, [11, 11], "Thought Lace source visuals")
	_expect_equal(thought_lace.classic_sound_ids, [92, 93], "Thought Lace source sounds")
	_expect_equal(sentry.name, "Sentry", "Enchanter Sentry resource identity")
	_expect_equal(sentry.classic_spell_ids, [3611], "Enchanter Sentry exact identity")
	_expect_equal(sentry.classic_special, 7, "Enchanter Sentry condition index")
	_expect_equal(sentry.get_min_duration(2, null), 48, "Enchanter Sentry duration")
	_expect_equal(sentry.get_max_duration(2, null), 48, "Enchanter Sentry fixed duration")
	_expect_equal(sentry.get_sp_cost(2, null), 60, "Enchanter Sentry casting cost")
	_expect_equal(
		priest_sentry.name,
		"Classic Sentry Priest",
		"Priest Sentry uses a distinct exact-ID resource"
	)
	_expect_equal(priest_sentry.classic_spell_ids, [2710], "Priest Sentry exact identity")
	_expect_equal(priest_sentry.classic_special, 7, "Priest Sentry condition index")
	_expect_equal(priest_sentry.get_min_duration(2, null), 48, "Priest Sentry duration")
	_expect_equal(priest_sentry.get_sp_cost(2, null), 70, "Priest Sentry casting cost")

	_expect_equal(
		ClassicPartyConditionScript.reduce(
			ClassicPartyConditionScript.apply(4, 8),
			2
		),
		6,
		"the shared condition loses one point per combat round"
	)
	_expect(
		FileAccess.get_file_as_string("res://scripts/GameGlobal.gd").contains(
			"func apply_classic_party_condition"
		),
		"GameGlobal exposes the party-condition spell boundary"
	)
	_expect(
		FileAccess.get_file_as_string(
			"res://scenes/UI/HUD/SaveLoad/save_load_rect.gd"
		).contains("classic_party_conditions"),
		"save files retain exact Classic party-condition counters"
	)


func _test_classic_silence_spells() -> void:
	var silence = load("res://shared_assets/spells/silence.gd").new()
	var sorcerer = load(
		"res://shared_assets/spells/classic_core_1411_silence_sorcerer.gd"
	).new()
	_expect_equal(silence.name, "Silence", "Silence resource identity")
	_expect_equal(
		silence.classic_spell_ids,
		[2211, 3110],
		"Priest and Enchanter Silence share one source-equivalent resource"
	)
	_expect_equal(
		sorcerer.classic_spell_ids,
		[1411],
		"Sorcerer Silence keeps its distinct resistance record"
	)
	for spell: Variant in [silence, sorcerer]:
		var label := str(spell.name)
		_expect_equal(spell.classic_special, 40, "%s special code" % label)
		_expect_equal(spell.classic_spell_class, 7, "%s special effect class" % label)
		_expect_equal(spell.classic_damage_type, 7, "%s special save family" % label)
		_expect_equal(spell.classic_spell_save_index, 7, "%s special save index" % label)
		_expect_equal(spell.classic_spell_save_mode, "negate", "%s save negates" % label)
		_expect_equal(spell.classic_save_bonus, 15, "%s save bonus" % label)
		_expect(spell.in_combat and not spell.in_field, "%s is combat-only" % label)
		_expect_equal(spell.classic_target_type, 3, "%s uses a fixed area" % label)
		_expect_equal(spell.classic_size, 9, "%s uses Data AD area 9" % label)
		_expect_equal(spell.classic_queue_icon, 14, "%s queue icon" % label)
		_expect_equal(spell.targettile, Spell.TARGET_TILE.NOWALL, "%s targeting" % label)
		_expect_equal(spell.get_range(3, null), 10, "%s source range" % label)
		_expect(not spell.los, "%s does not require line of sight" % label)
		_expect(
			_same_tile_set(spell.get_aoe(3, null), Spell.AoE_ROUND),
			"%s preserves the round area" % label
		)
		_expect_equal(spell.get_min_duration(3, null), 3, "%s minimum duration" % label)
		_expect_equal(spell.get_max_duration(3, null), 3, "%s maximum duration" % label)
		_expect_equal(spell.get_sp_cost(3, null), 45, "%s casting cost" % label)
		_expect_equal(spell.classic_spell_look_ids, [8, 15], "%s visuals" % label)
		_expect_equal(spell.terrain_tex, "Trg", "%s battlefield texture" % label)
		_expect(spell.is_classic_queued_spell(), "%s creates a queued field" % label)
		_expect(
			not spell.uses_classic_group_effect(),
			"%s resolves resistance and saves per target" % label
		)
	_expect_equal(silence.classic_cannot, 0, "Priest Silence uses general resistance")
	_expect_equal(
		silence.resist,
		Spell.RESIST_TYPE.IGNORE_DODGE,
		"Priest Silence checks general magic resistance"
	)
	_expect_equal(silence.classic_sound_ids, [66, 77], "Priest Silence sounds")
	_expect_equal(sorcerer.classic_cannot, 1, "Sorcerer Silence bypasses resistance")
	_expect_equal(
		sorcerer.resist,
		Spell.RESIST_TYPE.IGNORE_MRES_DODGE,
		"Sorcerer Silence bypasses general magic resistance"
	)
	_expect_equal(sorcerer.classic_sound_ids, [26, 24], "Sorcerer Silence sounds")
	_expect_equal(
		silence.schools,
		["Sorcerer", "Priest", "Enchanter"],
		"Silence remains available to all three caster classes"
	)

	var target := SpellScreenTestCharacter.new("Silenced target", true)
	_expect(target.can_cast_spells(), "an unaffected creature can cast spells")
	_expect_equal(
		silence.apply_classic_scaled_effect(null, target, 3, 1.0),
		3,
		"Silence applies one condition round per selected power"
	)
	_expect(not target.can_cast_spells(), "temporary Silence blocks spellcasting")
	for remaining: int in [2, 1]:
		target.traits[0]._on_new_round(target)
		_expect_equal(
			target.traits[0].get_saved_variables(),
			[remaining],
			"Silence loses one point each combat round"
		)
	target.traits[0]._on_new_round(target)
	_expect(target.can_cast_spells(), "spellcasting returns when Silence expires")

	var capped := SpellScreenTestCharacter.new("Capped silence target", true)
	capped.add_trait(load("res://shared_assets/traits/t_silenced.gd"), [98])
	_expect_equal(
		silence.apply_classic_scaled_effect(null, capped, 3, 1.0),
		0,
		"player Silence rejects a stack beyond condition 99"
	)
	var permanent := SpellScreenTestCharacter.new("Permanently silenced target", true)
	permanent.add_trait(load("res://shared_assets/traits/p_silenced.gd"), [2])
	_expect(not permanent.can_cast_spells(), "permanent Silence blocks spellcasting")
	_expect_equal(
		silence.apply_classic_scaled_effect(null, permanent, 3, 1.0),
		0,
		"temporary Silence does not replace permanent Silence"
	)

	var condition_target := ConditionTestCharacter.new("Condition target")
	var condition_result: Dictionary = CharacterConditionRulesScript.apply_condition(
		[condition_target],
		[condition_target],
		"selected",
		39,
		4
	)
	_expect_equal(condition_result.get("affectedCount"), 1, "Give Condition maps Silence")
	_expect_equal(
		CharacterConditionRulesScript.condition_value(condition_target, 39),
		4,
		"Give Condition preserves the Silence value"
	)
	_expect(
		FileAccess.get_file_as_string("res://Creature/Creature.gd").contains(
			"func can_cast_spells()"
		),
		"creatures expose one spellcasting eligibility seam"
	)
	for consumer_path: String in [
		"res://scenes/UI/HUD/Spells/SpellsRect.gd",
		"res://scripts/states/CbDecideActionState.gd",
		"res://shared_assets/CreatureScripts/test_crea_script.gd",
		"res://shared_assets/CreatureScripts/dumb_melee.gd",
	]:
		_expect(
			FileAccess.get_file_as_string(consumer_path).contains("can_cast_spells()"),
			"%s observes spellcasting eligibility" % consumer_path.get_file()
		)


func _test_classic_spell_screen_spells() -> void:
	var specs: Array = [
		{
			"file": "classic_core_1307_magic_screen_i.gd",
			"name": "Magic Screen I", "id": 1307, "special": 17,
			"range": 5, "targets": 3, "duration": [2, 8], "cost": 30,
			"looks": [13, 15], "sounds": [58, 29],
		},
		{
			"file": "classic_core_1404_magic_screen_ii.gd",
			"name": "Magic Screen II", "id": 1404, "special": 18,
			"range": 5, "targets": 3, "duration": [2, 8], "cost": 75,
			"looks": [13, 15], "sounds": [58, 90],
		},
		{
			"file": "classic_core_1405_magic_shield.gd",
			"name": "Magic Shield", "id": 1405, "special": 18,
			"range": 0, "targets": 1, "duration": [3, 6], "cost": 75,
			"looks": [13, 15], "sounds": [59, 90],
		},
		{
			"file": "classic_core_1507_magic_screen_iii.gd",
			"name": "Magic Screen III", "id": 1507, "special": 19,
			"range": 5, "targets": 3, "duration": [2, 8], "cost": 135,
			"looks": [13, 15], "sounds": [58, 90],
		},
		{
			"file": "classic_core_1605_magic_screen_iv.gd",
			"name": "Magic Screen IV", "id": 1605, "special": 20,
			"range": 5, "targets": 3, "duration": [2, 8], "cost": 210,
			"looks": [13, 15], "sounds": [58, 90],
		},
		{
			"file": "classic_core_1706_magic_screen_v.gd",
			"name": "Magic Screen V", "id": 1706, "special": 21,
			"range": 5, "targets": 3, "duration": [2, 8], "cost": 300,
			"looks": [13, 15], "sounds": [30, 29],
		},
		{
			"file": "classic_core_2411_sphere_of_protection.gd",
			"name": "Sphere of Protection", "id": 2411, "special": 20,
			"range": 0, "targets": 1, "duration": [3, 3], "cost": 150,
			"looks": [14, 15], "sounds": [44, 67],
		},
	]
	for spec: Dictionary in specs:
		var spell = load("res://shared_assets/spells/%s" % spec["file"]).new()
		var label := str(spec["name"])
		_expect_equal(spell.name, label, "%s resource identity" % label)
		_expect_equal(spell.classic_spell_ids, [spec["id"]], "%s exact ID" % label)
		_expect_equal(spell.classic_special, spec["special"], "%s screen condition" % label)
		_expect_equal(spell.classic_spell_class, 8, "%s preserves spell class 8" % label)
		_expect_equal(spell.classic_damage_type, 8, "%s remains miscellaneous" % label)
		_expect_equal(spell.classic_spell_save_index, -1, "%s has no DRV save" % label)
		_expect_equal(spell.classic_spell_save_mode, "none", "%s has no save mode" % label)
		_expect_equal(
			spell.resist,
			Spell.RESIST_TYPE.IGNORE_MRES_DODGE,
			"%s cannot miss or resist" % label
		)
		_expect(spell.in_combat and spell.in_field, "%s works in combat and camp" % label)
		_expect_equal(spell.get_range(3, null), spec["range"], "%s source range" % label)
		_expect_equal(
			spell.get_target_number(3, null),
			spec["targets"],
			"%s source target count" % label
		)
		_expect_equal(
			spell.get_min_duration(3, null),
			spec["duration"][0],
			"%s minimum duration" % label
		)
		_expect_equal(
			spell.get_max_duration(3, null),
			spec["duration"][1],
			"%s maximum duration" % label
		)
		_expect_equal(spell.get_sp_cost(3, null), spec["cost"], "%s casting cost" % label)
		_expect_equal(spell.classic_spell_look_ids, spec["looks"], "%s visuals" % label)
		_expect_equal(spell.classic_sound_ids, spec["sounds"], "%s sounds" % label)

	var magic_shield = load(
		"res://shared_assets/spells/classic_core_1405_magic_shield.gd"
	).new()
	_expect(magic_shield.skip_targeting, "Magic Shield centers its radiant area on the caster")
	_expect_equal(
		magic_shield.get_aoe(1, null),
		Spell.AoE_RADIANT,
		"Magic Shield preserves Classic size 8"
	)
	var sphere = load(
		"res://shared_assets/spells/classic_core_2411_sphere_of_protection.gd"
	).new()
	_expect(sphere.skip_targeting, "Sphere of Protection automatically targets its caster")
	_expect_equal(
		sphere.autotarget_type,
		Spell.AUTOTARGET_TYPE.SELF,
		"Sphere of Protection uses the native self target mode"
	)

	var screen_one = load(
		"res://shared_assets/spells/classic_core_1307_magic_screen_i.gd"
	).new()
	var first := SpellScreenTestCharacter.new("First", true)
	var second := SpellScreenTestCharacter.new("Second", true)
	_expect_equal(
		screen_one.apply_classic_group_effect(null, [first, second], 1),
		2,
		"Magic Screen applies to every selected target"
	)
	_expect_equal(
		first.traits[0].condition_values(),
		second.traits[0].condition_values(),
		"one Classic duration roll is shared by every screened target"
	)
	_expect(
		first.traits[0].duration_for_level(1) in range(2, 9),
		"Magic Screen duration stays within its source bounds"
	)
	var flame_hands = load("res://shared_assets/spells/flame_hands.gd").new()
	_expect(
		MagicResistanceScript.spell_resolution(first, flame_hands, 1, 100).get("resisted"),
		"a cast Magic Screen participates in normal spell resistance"
	)

	var capped := SpellScreenTestCharacter.new("Capped", true)
	capped.add_trait(load("res://shared_assets/traits/t_classic_spell_screen.gd"), [1, 98])
	_expect_equal(
		screen_one.apply_classic_scaled_effect(null, capped, 1, 1.0),
		0,
		"player spell screens reject a duration that would exceed condition 99"
	)
	_expect_equal(capped.traits[0].duration_for_level(1), 98, "rejected screen is unchanged")
	var capped_monster := SpellScreenTestCharacter.new("Capped Monster")
	capped_monster.add_trait(
		load("res://shared_assets/traits/t_classic_spell_screen.gd"),
		[1, 123]
	)
	_expect_equal(
		screen_one.apply_classic_scaled_effect(null, capped_monster, 1, 1.0),
		0,
		"monster spell screens reject a duration that would exceed condition 124"
	)
	var innate := SpellScreenTestCharacter.new("Innate", true)
	innate.set_meta(SpellScreenScript.META_KEY, 1)
	_expect_equal(
		screen_one.apply_classic_scaled_effect(null, innate, 1, 1.0),
		0,
		"temporary spell screens do not replace an innate negative condition"
	)
	_expect(innate.traits.is_empty(), "innate screen receives no temporary trait")


func _test_classic_restorative_spells() -> void:
	var specs: Array = [
		{
			"file": "classic_core_2204_heal_blindness.gd",
			"name": "Heal Blindness", "ids": [2204, 3206],
			"special": 128, "condition": 27, "class": 8,
			"range": 1, "targets": 2, "cost": 40,
			"looks": [5, 11], "sounds": [93, 98], "combat": true,
		},
		{
			"file": "classic_core_2205_heal_disease.gd",
			"name": "Heal Disease", "ids": [2205],
			"special": 129, "condition": 28, "class": 8,
			"range": 1, "targets": 2, "cost": 40,
			"looks": [5, 8], "sounds": [40, 84], "combat": true,
		},
		{
			"file": "classic_core_2206_heal_poison.gd",
			"name": "Heal Poison", "ids": [2206],
			"special": 110, "condition": 9, "class": 8,
			"range": 1, "targets": 2, "cost": 40,
			"looks": [5, 7], "sounds": [84, 40], "combat": true,
		},
		{
			"file": "classic_core_2602_flesh.gd",
			"name": "Flesh", "ids": [2602],
			"special": 127, "condition": 26, "class": 6,
			"range": 1, "targets": 1, "cost": 100,
			"looks": [5, 5], "sounds": [40, 84], "combat": false,
		},
		{
			"file": "classic_core_3405_flesh_enchanter.gd",
			"name": "Classic Flesh Enchanter", "ids": [3405],
			"special": 127, "condition": 26, "class": 8,
			"range": 0, "targets": 2, "cost": 60,
			"looks": [5, 5], "sounds": [9, 86], "combat": false,
		},
	]
	for spec: Dictionary in specs:
		var spell = load("res://shared_assets/spells/%s" % spec["file"]).new()
		var label := str(spec["name"])
		_expect_equal(spell.name, label, "%s resource identity" % label)
		_expect_equal(spell.classic_spell_ids, spec["ids"], "%s exact IDs" % label)
		_expect_equal(spell.classic_special, spec["special"], "%s special code" % label)
		_expect_equal(
			spell.classic_condition_index,
			spec["condition"],
			"%s condition mapping" % label
		)
		_expect_equal(spell.classic_spell_class, spec["class"], "%s effect class" % label)
		_expect_equal(spell.classic_spell_save_index, -1, "%s has no DRV save" % label)
		_expect_equal(spell.classic_spell_save_mode, "none", "%s has no save mode" % label)
		_expect_equal(
			spell.resist,
			Spell.RESIST_TYPE.IGNORE_MRES_DODGE,
			"%s cannot miss or resist" % label
		)
		_expect_equal(spell.get_range(2, null), spec["range"], "%s source range" % label)
		_expect_equal(
			spell.get_target_number(2, null),
			spec["targets"],
			"%s camp target count" % label
		)
		_expect(not spell.skip_targeting, "%s uses the camp party picker" % label)
		_expect_equal(spell.get_sp_cost(2, null), spec["cost"], "%s casting cost" % label)
		_expect_equal(spell.classic_spell_look_ids, spec["looks"], "%s visuals" % label)
		_expect_equal(spell.classic_sound_ids, spec["sounds"], "%s sounds" % label)
		_expect_equal(spell.in_combat, spec["combat"], "%s combat availability" % label)
		_expect(spell.in_field, "%s remains available in camp" % label)

	var priest_blind_source: Dictionary = CoreSpellCatalogScript.inventory_spell(2204).get(
		"record", {}
	)
	var enchanter_blind_source: Dictionary = CoreSpellCatalogScript.inventory_spell(3206).get(
		"record", {}
	)
	_expect_equal(
		[int(priest_blind_source.get("cannot", 0)), int(enchanter_blind_source.get("cannot", 0))],
		[3, 4],
		"Heal Blindness aliases preserve two source records that both bypass resistance"
	)

	var poison_target := ConditionTestCharacter.new("Poisoned")
	poison_target.traits = [
		ConditionTestTrait.new("t_poison.gd", 3),
		ConditionTestTrait.new("p_poison.gd", 5),
		ConditionTestTrait.new("t_blind.gd", 2),
	]
	var heal_poison = load(
		"res://shared_assets/spells/classic_core_2206_heal_poison.gd"
	).new()
	_expect_equal(
		heal_poison.apply_classic_scaled_effect(null, poison_target, 1, 1.0),
		2,
		"Heal Poison clears temporary and permanent poison"
	)
	_expect_equal(poison_target.traits[0].name, "t_blind.gd", "Heal Poison leaves other conditions")

	var disease_target := ConditionTestCharacter.new("Diseased")
	disease_target.traits = [
		ConditionTestTrait.new("t_classic_disease.gd", 3),
		ConditionTestTrait.new("t_disease.gd", 2),
		ConditionTestTrait.new("p_disease.gd", 1),
	]
	var heal_disease = load(
		"res://shared_assets/spells/classic_core_2205_heal_disease.gd"
	).new()
	_expect_equal(
		heal_disease.apply_classic_scaled_effect(null, disease_target, 1, 1.0),
		3,
		"Heal Disease clears native and compatibility disease traits"
	)
	_expect(disease_target.traits.is_empty(), "Heal Disease removes every disease representation")

	var blind_target := ConditionTestCharacter.new("Blind")
	blind_target.traits = [
		ConditionTestTrait.new("t_blind.gd", 2),
		ConditionTestTrait.new("p_blind.gd", 1),
	]
	var heal_blindness = load(
		"res://shared_assets/spells/classic_core_2204_heal_blindness.gd"
	).new()
	_expect_equal(
		heal_blindness.apply_classic_scaled_effect(null, blind_target, 2, 1.0),
		2,
		"Heal Blindness clears temporary and permanent blindness"
	)

	var stone_target := ConditionTestCharacter.new("Stone")
	stone_target.traits = [ConditionTestTrait.new("p_petrified.gd", 1)]
	var flesh = load("res://shared_assets/spells/classic_core_2602_flesh.gd").new()
	_expect_equal(
		flesh.apply_classic_scaled_effect(null, stone_target, 1, 0.0),
		0,
		"a negated Flesh effect does not clear petrification"
	)
	_expect_equal(
		flesh.apply_classic_scaled_effect(null, stone_target, 1, 1.0),
		1,
		"Flesh clears petrification"
	)

	var revive = load("res://shared_assets/spells/classic_core_2606_revive_dead.gd").new()
	_expect_equal(revive.classic_spell_ids, [2606, 3708], "identical Revive Dead rows share one resource")
	_expect_equal(revive.classic_special, 64, "Revive Dead uses special 64")
	_expect_equal(revive.classic_spell_class, 7, "Revive Dead preserves spell class 7")
	_expect_equal(revive.classic_damage_type, 7, "Revive Dead preserves damage type 7")
	_expect_equal(revive.get_target_number(3, null), 3, "Revive Dead selects once per power")
	_expect(not revive.skip_targeting, "Revive Dead uses the camp party picker")
	_expect(not revive.in_combat and revive.in_field, "Revive Dead remains camp-only")

	var dead := Creature.new()
	dead.stats["curHP"] = -12
	dead.stats["maxHP"] = 30
	dead.life_status = 3
	dead.classic_special_abilities[2] = 9
	_expect(revive.apply_classic_scaled_effect(null, dead, 1, 1.0), "Revive Dead accepts a dead target")
	_expect_equal(dead.stats["curHP"], -9, "Revive Dead returns the target at source health")
	_expect_equal(dead.life_status, 2, "Revive Dead returns the target unconscious")
	_expect_equal(dead.classic_special_abilities[2], 7, "Revive Dead consumes two Resurrect points")

	var animated := Creature.new()
	animated.stats["curHP"] = 1
	animated.stats["maxHP"] = 30
	animated.traits.append(ConditionTestTrait.new("p_animated.gd", 1))
	animated.classic_special_abilities[2] = 3
	_expect(
		revive.apply_classic_scaled_effect(null, animated, 1, 1.0),
		"Revive Dead accepts an animated target"
	)
	_expect(animated.traits.is_empty(), "Revive Dead removes animation")
	_expect_equal(animated.stats["curHP"], -9, "deanimation leaves the target unconscious")
	_expect_equal(animated.classic_special_abilities[2], 1, "deanimation consumes Resurrect points")

	var petrified_dead := Creature.new()
	petrified_dead.stats["curHP"] = -12
	petrified_dead.stats["maxHP"] = 30
	petrified_dead.life_status = 3
	petrified_dead.traits.append(ConditionTestTrait.new("p_petrified.gd", 1))
	petrified_dead.classic_special_abilities[2] = 4
	_expect(
		not revive.apply_classic_scaled_effect(null, petrified_dead, 1, 1.0),
		"Revive Dead rejects a petrified target"
	)
	_expect_equal(petrified_dead.stats["curHP"], -12, "failed revival leaves health unchanged")
	_expect_equal(petrified_dead.classic_special_abilities[2], 4, "failed revival has no ability cost")

	var saved_character := Creature.new()
	saved_character.classic_special_abilities[2] = 11
	var saved_value: Variant = JSON.parse_string(saved_character.get_save_string() + "}")
	_expect(saved_value is Dictionary, "Classic special abilities serialize with character saves")
	if saved_value is Dictionary:
		var restored_character := Creature.new()
		restored_character.restore_classic_special_abilities(
			saved_value.get("classicSpecialAbilities", [])
		)
		_expect_equal(
			restored_character.classic_special_abilities[2],
			11,
			"character saves preserve the mutable Resurrect ability"
		)


func _test_parameterized_damage_spells() -> void:
	var paths := {
		1601: "res://shared_assets/spells/classic_core_1601_annihilate.gd",
		1703: "res://shared_assets/spells/classic_core_1703_fire_flies.gd",
		2705: "res://shared_assets/spells/classic_core_2705_meteor_shower.gd",
		3108: "res://shared_assets/spells/classic_core_3108_repulsive_bubble.gd",
		3205: "res://shared_assets/spells/classic_core_3205_electric_pulse.gd",
		3501: "res://shared_assets/spells/classic_core_3501_acid_bath.gd",
		3601: "res://shared_assets/spells/classic_core_3601_ball_lightning.gd",
		3602: "res://shared_assets/spells/classic_core_3602_caustic_vapor.gd",
		3710: "res://shared_assets/spells/classic_core_3710_static_discharge.gd",
	}
	for spell_id: int in paths:
		var inventory_entry: Dictionary = CoreSpellCatalogScript.inventory_spell(spell_id)
		var source: Dictionary = inventory_entry.get("record", {})
		var spell: Variant = load(str(paths[spell_id])).new()
		var label := str(inventory_entry.get("displayName", spell_id))
		var power := 3
		var fixed_low := int(source.get("damage1", 0))
		var fixed_high := _classic_record_high(fixed_low, int(source.get("damage2", 0)))
		var power_low := int(source.get("powerDamage1", 0))
		var power_high := _classic_record_high(
			power_low,
			int(source.get("powerDamage2", 0))
		)
		var expected_min := fixed_low + power * power_low
		var expected_max := fixed_high + power * power_high
		_expect(spell is ClassicSpellOverride, "%s uses the shared Classic adapter" % label)
		_expect_equal(spell.name, label, "%s preserves its Data S name" % label)
		_expect_equal(spell.classic_spell_ids, [spell_id], "%s exports its exact ID" % label)
		_expect_equal(
			spell.classic_spell_class,
			int(source.get("spellClass", 0)),
			"%s preserves its effect class" % label
		)
		_expect_equal(
			spell.classic_sound_ids,
			[int(source.get("sound1", 0)), int(source.get("sound2", 0))],
			"%s preserves its source presentation IDs" % label
		)
		_expect_equal(
			spell.get_range(power, null),
			abs(int(source.get("range1", 0)) + power * int(source.get("range2", 0))),
			"%s range follows its signed source fields" % label
		)
		_expect_equal(spell.get_min_damage(power, null), expected_min, "%s minimum damage" % label)
		_expect_equal(spell.get_max_damage(power, null), expected_max, "%s maximum damage" % label)
		var rolled_damage: int = spell.get_damage_roll(power, null)
		_expect(
			rolled_damage >= expected_min and rolled_damage <= expected_max,
			"%s damage roll stays within its source range" % label
		)
		_expect_equal(
			spell.get_sp_cost(power, null),
			abs(power * int(source.get("cost", 0))),
			"%s cost scales from its source field" % label
		)
		var expected_save_index: int = abs(int(source.get("damageType", 0))) \
			if int(source.get("cannot", 0)) <= 1 else -1
		_expect_equal(spell.classic_spell_save_index, expected_save_index, "%s save index" % label)
		_expect_equal(
			spell.classic_spell_save_mode,
			"half_damage" if expected_save_index >= 0 else "none",
			"%s save mode" % label
		)
		var checks_resistance := int(source.get("cannot", 0)) != 1 \
			and int(source.get("cannot", 0)) <= 2
		_expect_equal(
			spell.resist,
			Spell.RESIST_TYPE.IGNORE_DODGE \
				if checks_resistance else Spell.RESIST_TYPE.IGNORE_MRES_DODGE,
			"%s general-resistance rule" % label
		)
		_expect_equal(
			spell.los,
			int(source.get("range1", 0)) >= 0 and int(source.get("range2", 0)) >= 0,
			"%s line-of-sight rule follows signed range fields" % label
		)
		_expect_equal(
			spell.school_levels.get(str(inventory_entry.get("casterClass", ""))),
			int(inventory_entry.get("level", 0)),
			"%s exports its source school level" % label
		)
		_expect_equal(
			spell.selection_costs.get(str(inventory_entry.get("casterClass", ""))),
			[0, 1, 3, 6, 10, 15, 21, 28][int(inventory_entry.get("level", 0))],
			"%s exports its source selection cost" % label
		)
		var source_size := int(source.get("size", 0))
		var expected_aoe: Array[Vector2i]
		if int(source.get("targetType", 0)) == 4:
			expected_aoe = Spell.AoE_b_SCALING[power]
		elif source_size == 8:
			expected_aoe = Spell.AoE_RADIANT
		elif source_size == 9:
			expected_aoe = Spell.AoE_ROUND
		else:
			expected_aoe = Spell.AoE_b_SCALING[clampi(source_size, 1, 7)]
		_expect_equal(spell.get_aoe(power, null), expected_aoe, "%s source area" % label)
		if int(source.get("targetType", 0)) in [0, 1]:
			_expect_equal(
				spell.targettile,
				Spell.TARGET_TILE.CREATURE,
				"%s requires a creature target" % label
			)
		_expect_equal(
			spell.get_target_number(power, null),
			power if int(source.get("targetType", 0)) < 1 else 1,
			"%s target count follows its source type" % label
		)
		_expect_equal(
			spell.source_record.get("sourceRecord", {}).get("byteOffset"),
			inventory_entry.get("sourceRecord", {}).get("byteOffset"),
			"%s retains source provenance" % label
		)


func _test_flame_missile() -> void:
	var spell: Variant = load(
		"res://shared_assets/spells/classic_core_1503_flame_missile.gd"
	).new()
	var source_entry: Dictionary = CoreSpellCatalogScript.inventory_spell(1503)
	var source: Dictionary = source_entry.get("record", {})
	_expect(spell is ClassicCoreMissileSpell, "Flame Missile uses the missile specialization")
	_expect_equal(spell.classic_spell_ids, [1503], "Flame Missile exports its exact ID")
	_expect_equal(spell.classic_spell_class, 9, "Flame Missile preserves class 9")
	_expect_equal(spell.classic_to_hit_bonus, 127, "Flame Missile preserves its hit bonus")
	_expect_equal(
		spell.attributes,
		["Magical", "Projectile"],
		"Flame Missile participates in native projectile protection"
	)
	_expect_equal(spell.targettile, Spell.TARGET_TILE.CREATURE, "Flame Missile targets one creature")
	_expect(not spell.los, "Flame Missile preserves its negative no-sight range")
	_expect_equal(spell.get_range(4, null), 12, "Flame Missile range scales by three")
	_expect_equal(spell.get_min_damage(4, null), 30, "Flame Missile minimum damage")
	_expect_equal(spell.get_max_damage(4, null), 35, "Flame Missile maximum damage")
	_expect_equal(spell.get_sp_cost(4, null), 80, "Flame Missile cost scales by power")
	_expect_equal(spell.classic_spell_save_index, 1, "Flame Missile uses the fire save")
	_expect_equal(
		spell.classic_spell_save_mode,
		"half_damage",
		"Flame Missile halves damage on a save"
	)
	_expect_equal(
		spell.resist,
		Spell.RESIST_TYPE.IGNORE_MRES_DODGE,
		"Flame Missile bypasses ordinary magic resistance and dodge"
	)
	_expect_equal(
		spell.source_record.get("sourceRecord", {}).get("byteOffset"),
		source_entry.get("sourceRecord", {}).get("byteOffset"),
		"Flame Missile retains source provenance"
	)
	_expect_equal(int(source.get("spellClass", 0)), 9, "Flame Missile test uses its Data S class")

	var caster := RogueTestCharacter.new()
	caster.level = 10
	caster.classgd = load("res://Data/Character Classes/Class_Archer.gd")
	_expect_equal(
		spell.classic_missile_bonus_range(caster),
		Vector2i(1, 5),
		"Archer Flame Missile gains Classic half-level bonus damage"
	)
	caster.classgd = load("res://Data/Character Classes/Class_Marksman.gd")
	_expect_equal(
		spell.classic_missile_bonus_range(caster),
		Vector2i(1, 5),
		"Marksman Flame Missile gains Classic half-level bonus damage"
	)
	caster.classgd = load("res://Data/Character Classes/Class_Sorcerer.gd")
	_expect_equal(
		spell.classic_missile_bonus_range(caster),
		Vector2i.ZERO,
		"other standard castes do not gain missile bonus damage"
	)
	caster.set_meta("classic_gets_missile_bonus", true)
	_expect_equal(
		spell.classic_missile_bonus_range(caster),
		Vector2i(1, 5),
		"preserved custom-caste metadata can opt into missile bonus damage"
	)

	var protected_target := RogueTestCharacter.new()
	protected_target.set_meta(SpellScreenScript.META_KEY, 5)
	protected_target.set_meta(MagicResistanceScript.META_KEY, 100)
	var resolution: Dictionary = MagicResistanceScript.spell_resolution(
		protected_target, spell, 4, 1, false, caster
	)
	_expect(not resolution.get("resisted"), "Flame Missile bypasses spell screens and magic resistance")
	_expect(not resolution.get("checksScreen"), "class-9 missiles do not check spell screens")
	_expect(not resolution.get("checksResistance"), "class-9 missiles do not check magic resistance")


func _test_stun_corrected_helplessness() -> void:
	var spell: Variant = load(
		"res://shared_assets/spells/classic_core_2712_stun.gd"
	).new()
	var source_entry: Dictionary = CoreSpellCatalogScript.inventory_spell(2712)
	var source: Dictionary = source_entry.get("record", {})
	_expect(spell is ClassicSpellOverride, "Stun uses the source-record spell adapter")
	_expect_equal(spell.classic_spell_ids, [2712], "Stun exports its exact ID")
	_expect_equal(spell.classic_spell_class, 7, "Stun preserves its Classic spell class")
	_expect_equal(spell.classic_special, 0, "Stun preserves its empty special code")
	_expect_equal(spell.attributes, ["Magical", "Special"], "Stun retains its delivery attributes")
	_expect_equal(spell.targettile, Spell.TARGET_TILE.CREATURE, "Stun targets one creature")
	_expect(spell.los, "Stun requires line of sight")
	_expect_equal(spell.get_range(7, null), 1, "Stun keeps its touch range")
	_expect_equal(spell.get_min_damage(7, null), 0, "Stun has no source damage")
	_expect_equal(spell.get_max_damage(7, null), 0, "Stun cannot roll source damage")
	_expect_equal(spell.get_min_duration(7, null), 1, "Stun lasts one round")
	_expect_equal(spell.get_duration_roll(1, null), 1, "Stun duration does not scale")
	_expect_equal(spell.get_max_duration(7, null), 1, "Stun maximum is one round")
	_expect_equal(spell.get_sp_cost(3, null), 120, "Stun cost scales by power")
	_expect_equal(spell.classic_spell_save_index, 7, "Stun uses Classic's special save")
	_expect_equal(spell.classic_spell_save_mode, "negate", "Stun keeps its save stage")
	_expect_equal(spell.classic_save_adjust, -5, "Stun keeps its save adjustment")
	_expect_equal(spell.classic_resist_adjust, -5, "Stun keeps its resistance adjustment")
	_expect_equal(
		spell.resist,
		Spell.RESIST_TYPE.IGNORE_DODGE,
		"Stun checks Classic magic resistance without native dodge"
	)
	_expect(spell.has_method("apply_classic_scaled_effect"), "Stun has a corrected condition hook")
	_expect_equal(int(source.get("special", -1)), 0, "Stun test uses the shipped zero special")
	_expect_equal(int(source.get("damage1", -1)), 0, "Stun test uses the shipped zero damage")
	_expect_equal(int(source.get("duration1", 0)), -1, "Stun retains its defective raw duration")
	_expect_equal(
		spell.source_record.get("sourceRecord", {}).get("byteOffset"),
		source_entry.get("sourceRecord", {}).get("byteOffset"),
		"Stun retains source provenance"
	)

	var target := RogueTestCharacter.new()
	target.current_hp = 23
	target.traits.append(ConditionTestTrait.new("existing.gd", 2))
	target.set_meta(MagicResistanceScript.META_KEY, 50)
	target.set_meta(SpellSavesScript.META_SAVES_KEY, [50, 50, 50, 50, 50, 50])
	var resistance: Dictionary = MagicResistanceScript.spell_resolution(
		target, spell, 3, 36
	)
	_expect(not resistance.get("resisted"), "Stun can pass its adjusted resistance check")
	_expect_equal(resistance.get("chance"), 35, "Stun applies its resistance penalty per power")
	var save: Dictionary = SpellSavesScript.target_resolution(target, spell, 3, 36)
	_expect(not save.get("saved"), "Stun can pass its adjusted special save")
	_expect_equal(save.get("saveChance"), 35.0, "Stun applies its save penalty per power")
	var stunned_target := ConditionTestCharacter.new("Stunned target")
	stunned_target.current_hp = 23
	spell.apply_classic_scaled_effect(null, stunned_target, 3, 1.0)
	_expect_equal(stunned_target.current_hp, 23, "Stun changes no health")
	_expect_equal(stunned_target.traits.size(), 1, "Stun applies one condition trait")
	_expect(
		str(stunned_target.traits[0].name).ends_with("t_helpless.gd"),
		"Stun uses Remake's helpless behavior"
	)
	_expect_equal(stunned_target.traits[0].power, 1, "Stun applies helplessness for one round")


func _test_encounter_response_spells() -> void:
	var cases := [
		[1107, "res://shared_assets/spells/classic_core_1107_leap.gd", 15, 11, 0],
		[1112, "res://shared_assets/spells/classic_core_1112_superfly.gd", 12, 11, 0],
		[1201, "res://shared_assets/spells/classic_core_1201_dig_hole.gd", 20, 11, 0],
		[1305, "res://shared_assets/spells/classic_core_1305_fantastic_wings.gd", 20, 11, 0],
		[1609, "res://shared_assets/spells/classic_core_1609_shape_earth.gd", 50, 11, 255],
		[2504, "res://shared_assets/spells/classic_core_2504_hands_to_clay.gd", 45, 11, 255],
		[2609, "res://shared_assets/spells/classic_core_2609_teleport_party.gd", 120, 11, 255],
		[2611, "res://shared_assets/spells/classic_core_2611_watergate.gd", 70, 11, 255],
		[3111, "res://shared_assets/spells/classic_core_3111_splinters.gd", 10, 11, 255],
		[3112, "res://shared_assets/spells/classic_core_3112_voiceover.gd", 15, 11, 255],
		[3306, "res://shared_assets/spells/classic_core_3306_hands_to_clay_enchanter.gd", 25, 11, 0],
		[3404, "res://shared_assets/spells/classic_core_1305_fantastic_wings.gd", 20, 11, 0],
		[3410, "res://shared_assets/spells/classic_core_3410_speak_language.gd", 25, 11, 255],
		[3709, "res://shared_assets/spells/classic_core_1609_shape_earth.gd", 50, 11, 255],
		[3711, "res://shared_assets/spells/classic_core_3711_teleport_party_enchanter.gd", 45, 0, 255],
	]
	var adapter = GodotAdapterScript.new()
	for spell_case: Array in cases:
		var spell_id := int(spell_case[0])
		var spell: Variant = load(str(spell_case[1])).new()
		var source: Dictionary = spell.source_record
		_expect(
			spell is EncounterResponseSpellScript,
			"encounter-response spell %d uses the shared adapter" % spell_id
		)
		_expect(
			spell.supports_classic_spell_id(spell_id),
			"encounter-response spell %d exports its exact identity" % spell_id
		)
		_expect(
			spell_id in spell.classic_spell_response_ids,
			"encounter-response spell %d is eligible for authored results" % spell_id
		)
		_expect_equal(spell.max_plevel, 1, "encounter responses use fixed power 1")
		_expect(
			not spell.in_field and not spell.in_combat,
			"encounter-response spell %d is hidden from ordinary casting" % spell_id
		)
		_expect_equal(
			spell.get_sp_cost(1, null),
			int(spell_case[2]),
			"encounter-response spell %d keeps its fixed source cost" % spell_id
		)
		_expect_equal(
			int(source.get("cost", 0)),
			-int(spell_case[2]),
			"encounter-response spell %d retains the negative fixed-cost marker" % spell_id
		)
		_expect_equal(
			int(source.get("targetType", -1)),
			int(spell_case[3]),
			"encounter-response spell %d preserves its source target type" % spell_id
		)
		_expect_equal(
			int(source.get("inCamp", -1)),
			int(spell_case[4]),
			"encounter-response spell %d preserves its source availability byte" % spell_id
		)
		_expect_equal(spell.classic_special, 0, "encounter response has no universal opcode")
		_expect_equal(spell.get_min_damage(1, null), 0, "encounter response has no damage")
		_expect_equal(spell.get_max_damage(1, null), 0, "encounter response cannot roll damage")
		_expect_equal(
			adapter.resolve_complex_spell_result(
				{"spellIds": [spell_id], "spellResults": [1]},
				spell.name,
				spell.classic_spell_class,
				{},
				adapter.classic_spell_response_ids(spell)
			),
			1,
			"encounter-response spell %d selects its authored result" % spell_id
		)

	var wings: Variant = load(
		"res://shared_assets/spells/classic_core_1305_fantastic_wings.gd"
	).new()
	_expect_equal(wings.classic_spell_ids, [1305, 3404], "Fantastic Wings shares exact records")
	_expect_equal(wings.schools, ["Sorcerer", "Enchanter"], "Fantastic Wings exposes both schools")
	_expect_equal(wings.school_levels.get("Sorcerer"), 3, "Sorcerer Wings level")
	_expect_equal(wings.school_levels.get("Enchanter"), 4, "Enchanter Wings level")
	var shape_earth: Variant = load(
		"res://shared_assets/spells/classic_core_1609_shape_earth.gd"
	).new()
	_expect_equal(shape_earth.classic_spell_ids, [1609, 3709], "Shape Earth shares exact records")
	_expect_equal(shape_earth.school_levels.get("Sorcerer"), 6, "Sorcerer Shape Earth level")
	_expect_equal(shape_earth.school_levels.get("Enchanter"), 7, "Enchanter Shape Earth level")
	var hidden_hands: Variant = load(
		"res://shared_assets/spells/classic_core_3306_hands_to_clay_enchanter.gd"
	).new()
	var hidden_teleport: Variant = load(
		"res://shared_assets/spells/classic_core_3711_teleport_party_enchanter.gd"
	).new()
	_expect(hidden_hands.schools.is_empty(), "duplicate Hands to Clay stays out of the spell book")
	_expect(hidden_teleport.schools.is_empty(), "duplicate Teleport Party stays out of the spell book")


func _test_classic_spell_usage_audit() -> void:
	var city_bundle = BundleScript.new()
	_expect(city_bundle.load_from_directory(FIXTURE), "spell audit City fixture loads")
	city_bundle.monsters_by_id[71] = {
		"id": 71,
		"displayName": "Vodalian",
		"spells": [1103],
		"provenance": {"sourceFile": "Data MD", "recordIndex": 71},
	}
	city_bundle.battles_by_id[999] = {"id": 999, "grid": [71]}
	city_bundle.extra_codes_by_id[999] = {"id": 999, "values": [1, 71]}
	city_bundle.extra_codes_by_id[998] = {"id": 998, "values": [1102, 1, 0, 0, 0]}
	city_bundle.extra_codes_by_id[997] = {"id": 997, "values": [9998, 1, 0, 0, 0]}
	city_bundle.extra_codes_by_id[996] = {"id": 996, "values": [2708, 1, 0, 0, 0]}
	city_bundle.triggers_by_id["spell-audit:monster-contexts"] = {
		"id": "spell-audit:monster-contexts",
		"source": "Data DD",
		"recordIndex": 999,
		"active": true,
		"actions": [
			{"id": 71, "rawCode": 89, "slot": 0},
			{"id": 999, "rawCode": 124, "slot": 1},
			{"id": 998, "rawCode": 17, "slot": 2},
			{"id": 997, "rawCode": 18, "slot": 3},
			{"id": 996, "rawCode": 17, "slot": 4},
		],
	}
	var response_bundle = BundleScript.new()
	_expect(
		response_bundle.load_from_directory(COMPLEX_RESPONSE_MODES_FIXTURE),
		"spell audit response fixture loads"
	)
	var audit = SpellUsageAuditScript.new()
	var native_spells := {}
	SpellResourceCatalogScript.merge_directory("res://shared_assets/spells", native_spells)
	_expect(native_spells.has("Fireball"), "spell catalog discovers shared resources")
	_expect_equal(
		native_spells.get("Fireball", {}).get("classicSpellIds"),
		[1306],
		"spell catalog preserves declared Classic IDs"
	)
	_expect_equal(
		native_spells.get("Enchanted Blade", {}).get("classicSpellIds"),
		[1102],
		"spell catalog maps the native Enchanted Blade resource"
	)
	_expect_equal(
		native_spells.get("Classic Enchanted Blade", {}).get("classicSpellIds"),
		[3104],
		"spell catalog discovers exact-ID compatibility resources"
	)
	_expect_equal(
		native_spells.get("Classic Enchanted Blades Priest", {}).get("classicSpellIds"),
		[2503],
		"spell catalog keeps the Priest Enchanted Blades record distinct"
	)
	_expect_equal(
		native_spells.get("Enchanted Blades", {}).get("classicSpellIds"),
		[3305],
		"spell catalog maps the native Enchanted Blades resource"
	)
	_expect_equal(
		native_spells.get("Power Gather", {}).get("classicSpellIds"),
		[1510],
		"spell catalog maps the native Power Gather resource"
	)
	_expect_equal(
		native_spells.get("Classic Power Gather Enchanter", {}).get("classicSpellIds"),
		[3510],
		"spell catalog keeps the Enchanter Power Gather presentation distinct"
	)
	_expect_equal(
		native_spells.get("Power Wither", {}).get("classicSpellIds"),
		[1511],
		"spell catalog maps the native Power Wither resource"
	)
	_expect_equal(
		native_spells.get("Spirit Drain", {}).get("classicSpellIds"),
		[2711],
		"spell catalog maps the native Spirit Drain resource"
	)
	_expect_equal(
		native_spells.get("Classic Power Wither Enchanter", {}).get("classicSpellIds"),
		[3511],
		"spell catalog keeps the Enchanter Power Wither presentation distinct"
	)
	_expect_equal(
		native_spells.get("Arcanic Bubble", {}).get("classicSpellIds"),
		[1301],
		"spell catalog maps the native Arcanic Bubble resource"
	)
	_expect_equal(
		native_spells.get("Improved Arcanic Bubble", {}).get("classicSpellIds"),
		[1403],
		"spell catalog maps the native Improved Arcanic Bubble resource"
	)
	_expect_equal(
		native_spells.get(
			"Classic Improved Arcanic Bubble Priest", {}
		).get("classicSpellIds"),
		[2702],
		"spell catalog keeps the Priest Improved Arcanic Bubble presentation distinct"
	)
	_expect_equal(
		native_spells.get("Classic Arcanic Bubble Enchanter", {}).get("classicSpellIds"),
		[3302],
		"spell catalog keeps the Enchanter Arcanic Bubble presentation distinct"
	)
	_expect_equal(
		native_spells.get("Itching Skin", {}).get("classicSpellIds"),
		[1207, 2209],
		"spell catalog maps both source-equivalent Itching Skin identities"
	)
	_expect_equal(
		native_spells.get("Shrink Foe", {}).get("classicSpellIds"),
		[3109],
		"spell catalog maps the native Shrink Foe resource"
	)
	_expect_equal(
		native_spells.get("Silence", {}).get("classicSpellIds"),
		[2211, 3110],
		"spell catalog groups source-equivalent Priest and Enchanter Silence"
	)
	_expect_equal(
		native_spells.get("Classic Silence Sorcerer", {}).get("classicSpellIds"),
		[1411],
		"spell catalog keeps the Sorcerer resistance variant distinct"
	)
	_expect_equal(
		native_spells.get("Magic Darts", {}).get("classicSpellIds"),
		[1108],
		"spell catalog maps the existing native Magic Darts resource"
	)
	_expect_equal(
		native_spells.get("Classic Magic Darts Enchanter", {}).get("classicSpellIds"),
		[3208],
		"spell catalog keeps the Enchanter damage variant distinct"
	)
	_expect_equal(
		native_spells.get("Classic Fearful Thoughts Area", {}).get("classicSpellIds"),
		[1603, 3505],
		"spell catalog groups source-equivalent area Fear identities"
	)
	_expect_equal(
		native_spells.get("Classic Fearful Thoughts Priest Area", {}).get(
			"classicSpellIds"
		),
		[2403],
		"spell catalog keeps the opposed-level Priest area Fear distinct"
	)
	_expect_equal(
		native_spells.get("Classic Power Drain Priest", {}).get("classicSpellIds"),
		[2708],
		"spell catalog keeps the stronger Priest Power Drain distinct"
	)
	_expect_equal(
		native_spells.get("Cosmic Blast", {}).get("classicSpellIds"),
		[1401, 3303],
		"spell catalog groups source-equivalent Cosmic Blast identities"
	)
	var spell_mapping: Dictionary = SpellIdsScript.new().mappings
	_expect_equal(
		SpellIdentityScript.resource_key(3208, spell_mapping, native_spells),
		"Classic Magic Darts Enchanter",
		"exact Enchanter ID selects the compatibility variant"
	)
	_expect_equal(
		SpellIdentityScript.resource_key(1401, spell_mapping, native_spells),
		"Cosmic Blast",
		"spell catalog resolves the supported Cosmic Blast variant"
	)
	_expect_equal(
		SpellIdentityScript.resource_key(3303, spell_mapping, native_spells),
		"Cosmic Blast",
		"spell catalog reuses Cosmic Blast for its equivalent Enchanter identity"
	)
	var report: Dictionary = audit.inspect_bundles(
		[city_bundle, response_bundle], {}, native_spells
	)
	var totals: Dictionary = report.get("totals", {})
	_expect_equal(totals.get("campaigns"), 2, "spell audit merges multiple scenario bundles")
	_expect(int(totals.get("spellIds", 0)) > 0, "spell audit inventories packed spell IDs")
	_expect(
		int(totals.get("unclassifiedSpellIds", 0)) > 0,
		"spell audit identifies matrix rows still needing classification"
	)

	var spell_item_row: Dictionary = {}
	var trap_row: Dictionary = {}
	var combat_spell_row: Dictionary = {}
	var exact_adapter_row: Dictionary = {}
	var missing_row: Dictionary = {}
	var variant_row: Dictionary = {}
	var unmapped_row: Dictionary = {}
	for row_value: Variant in report.get("spells", []):
		if not (row_value is Dictionary):
			continue
		var row: Dictionary = row_value
		match int(row.get("classicSpellId", 0)):
			1306:
				spell_item_row = row
			1110:
				trap_row = row
			1103:
				combat_spell_row = row
			1102:
				exact_adapter_row = row
			1201:
				missing_row = row
			2708:
				variant_row = row
			9998:
				unmapped_row = row
	_expect(not spell_item_row.is_empty(), "spell audit records a scenario-item spell")
	var spell_item_contexts: Array = spell_item_row.get("usages", []).map(
		func(usage: Dictionary) -> String: return str(usage.get("context", ""))
	)
	_expect(
		spell_item_contexts.has("complex-response"),
		"spell audit records complex-response usage"
	)
	_expect(
		spell_item_contexts.has("scenario-spell-item"),
		"spell audit records scenario-item usage"
	)
	_expect(not trap_row.is_empty(), "spell audit records a rogue trap spell")
	var trap_usage: Dictionary = trap_row.get("usages", [])[0]
	_expect_equal(trap_usage.get("context"), "rogue-trap", "spell audit labels trap context")
	_expect_equal(trap_usage.get("sourceFile"), "Data TD2", "spell audit preserves trap source")
	_expect_equal(trap_usage.get("recordIndex"), 0, "spell audit preserves trap record")
	_expect_equal(
		combat_spell_row.get("supportStatus"),
		"supported",
		"spell audit joins a packed ID to the curated matrix"
	)
	_expect_equal(
		combat_spell_row.get("nativeResolution", {}).get("status"),
		"exact-id-resource",
		"spell audit recognizes an explicit native spell identity"
	)
	var combat_contexts: Array = combat_spell_row.get("usages", []).map(
		func(usage: Dictionary) -> String: return str(usage.get("context", ""))
	)
	for expected_context: String in ["combatant", "ally", "summoned-combatant"]:
		_expect(
			combat_contexts.has(expected_context),
			"spell audit records %s usage" % expected_context
		)
	_expect_equal(
		exact_adapter_row.get("nativeResolution", {}).get("status"),
		"exact-id-resource",
		"spell audit resolves an exact-ID compatibility resource"
	)
	_expect_equal(
		exact_adapter_row.get("nativeResolution", {}).get("resourceName"),
		"Enchanted Blade",
		"spell audit reports the selected compatibility resource"
	)
	_expect_equal(
		audit._native_resolution(
			1102,
			{"Enchanted Blade": {"resourcePath": "res://test-name-only.gd"}}
		).get("status"),
		"name-only-resource",
		"spell audit retains a distinct name-only classification"
	)
	_expect_equal(
		missing_row.get("nativeResolution", {}).get("status"),
		"exact-id-resource",
		"spell audit resolves Dig Hole through its encounter-response resource"
	)
	_expect_equal(
		missing_row.get("nativeResolution", {}).get("resourceName"),
		"Dig Hole",
		"spell audit reports the implemented Dig Hole response"
	)
	_expect_equal(
		variant_row.get("nativeResolution", {}).get("status"),
		"exact-id-resource",
		"spell audit resolves the Priest Power Drain variant by exact ID"
	)
	_expect_equal(
		variant_row.get("nativeResolution", {}).get("resourceName"),
		"Classic Power Drain Priest",
		"spell audit reports the specialized Priest Power Drain resource"
	)
	_expect_equal(
		unmapped_row.get("nativeResolution", {}).get("status"),
		"unmapped-identity",
		"spell audit distinguishes an unmapped packed ID"
	)

	var class_rows: Array = report.get("spellClasses", [])
	_expect_equal(class_rows.size(), 1, "spell audit separates low-ID class responses")
	if not class_rows.is_empty():
		_expect_equal(class_rows[0].get("classicSpellClass"), 1, "spell class identity stays exact")
	_expect_equal(
		report.get("unresolvedReferences", []).size(),
		0,
		"spell audit has no ambiguous low references in the fixture corpus"
	)
	_expect(
		report.get("sourceCoverage", {}).get("notRepresentedByBundleV1", []).has(
			"learned-spell-lists"
		),
		"spell audit names contexts unavailable in bundle v1"
	)


func _test_item_actions() -> void:
	var bundle = _item_action_test_bundle()
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("item:possession"), "begin item possession branch")
	var item_check: Dictionary = interpreter.run_until_yield()
	_expect_equal(item_check.get("command"), "check_party_item", "opcode 21 checks party inventory")
	_expect_equal(item_check.get("payload", {}).get("itemId"), 100, "item check preserves item ID")
	_expect_equal(
		item_check.get("payload", {}).get("itemTexts", [])[0].get("identifiedName"),
		"Test Key",
		"item check supplies scenario item text"
	)
	var possessed: Dictionary = interpreter.resume_item_check(true)
	_expect_equal(possessed.get("payload", {}).get("messageId"), 900, "possessed item takes success branch")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("item:possession"), "begin missing item continuation")
	interpreter.run_until_yield()
	var missing_continues: Dictionary = interpreter.resume_item_check(false)
	_expect_equal(
		missing_continues.get("payload", {}).get("messageId"),
		910,
		"missing item can continue the current action point"
	)

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("item:missing-branch"), "begin missing item branch")
	interpreter.run_until_yield()
	var missing_branch: Dictionary = interpreter.resume_item_check(false)
	_expect_equal(
		missing_branch.get("payload", {}).get("messageId"),
		901,
		"missing item can take its alternate branch"
	)

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("item:missing-text"), "begin missing item message")
	interpreter.run_until_yield()
	var missing_text: Dictionary = interpreter.resume_item_check(false)
	_expect_equal(missing_text.get("payload", {}).get("messageId"), 902, "missing item can exit with text")
	_expect_equal(
		interpreter.run_until_yield().get("reason"),
		"action-point-ended",
		"missing-item text exits instead of falling through"
	)

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("item:gosub"), "begin GOSUB item branch")
	interpreter.run_until_yield()
	var subroutine: Dictionary = interpreter.resume_item_check(true)
	_expect_equal(subroutine.get("payload", {}).get("messageId"), 911, "item branch enters GOSUB target")
	var returned: Dictionary = interpreter.run_until_yield()
	_expect_equal(returned.get("payload", {}).get("messageId"), 913, "item branch returns to caller")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("item:simple"), "begin item encounter branch")
	interpreter.run_until_yield()
	var item_encounter: Dictionary = interpreter.resume_item_check(true)
	_expect_equal(item_encounter.get("command"), "start_encounter", "item branch can start an encounter")
	_expect_equal(item_encounter.get("payload", {}).get("encounterId"), 2, "item branch selects encounter")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("item:result-present"), "begin present-item result branch")
	interpreter.run_until_yield()
	var present_result: Dictionary = interpreter.resume_item_check(true)
	_expect_equal(present_result.get("payload", {}).get("messageId"), 921, "opcode 38 branches on possession")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("item:result-present"), "begin failed result item test")
	interpreter.run_until_yield()
	var present_fallthrough: Dictionary = interpreter.resume_item_check(false)
	_expect_equal(
		present_fallthrough.get("payload", {}).get("messageId"),
		920,
		"opcode 38 falls through when its test fails"
	)

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("item:result-absent"), "begin absent-item result branch")
	interpreter.run_until_yield()
	var absent_result: Dictionary = interpreter.resume_item_check(false)
	_expect_equal(absent_result.get("payload", {}).get("messageId"), 922, "opcode 38 branches on absence")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("item:result-force"), "begin forced item result branch")
	var forced_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(forced_result.get("payload", {}).get("messageId"), 923, "opcode 38 preserves forced branch mode")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("item:mutation"), "begin item mutation action")
	var mutation: Dictionary = interpreter.run_until_yield()
	_expect_equal(mutation.get("command"), "alter_party_items", "opcode 22 yields typed mutation")
	_expect_equal(mutation.get("payload", {}).get("maxMatches"), 2, "item mutation preserves match limit")
	_expect_equal(mutation.get("payload", {}).get("operation"), 3, "item mutation preserves operation")
	_expect_equal(mutation.get("payload", {}).get("chargeDelta"), -4, "item mutation preserves charge delta")
	_expect_equal(
		mutation.get("payload", {}).get("replacementItemId"),
		101,
		"item mutation preserves replacement ID"
	)

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("item:capture"), "begin equipment capture action")
	_expect(bool(interpreter.run_until_yield().get("payload", {}).get("capture")), "nonzero opcode 36 captures")
	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("item:restore"), "begin equipment restore action")
	_expect(not bool(interpreter.run_until_yield().get("payload", {}).get("capture")), "zero opcode 36 restores")
	var adapter = GodotAdapterScript.new()
	var unresolved_item: Dictionary = adapter._check_party_item({
		"itemId": 990,
		"itemTexts": [],
	})
	_expect_equal(
		unresolved_item.get("status"),
		"error",
		"native item check stops when a scenario item has no exported identity"
	)
	var host = HostScript.new()
	get_root().add_child(host)
	var host_adapter = GuardHouseAdapter.new()
	host.configure(host_adapter)
	host.runtime.bundle = bundle
	host.runtime.runtime_state = StateScript.new()
	host.runtime.runtime_state.configure_from_bundle(bundle)
	host.runtime.interpreter.configure(bundle, host.runtime.runtime_state)
	var host_completions: Array = []
	host.playthrough_completed.connect(
		func(result: Dictionary) -> void: host_completions.append(result)
	)
	_expect(host.start_trigger("item:possession"), "runtime host starts item possession branch")
	_expect_equal(host_adapter.commands[0].get("command"), "check_party_item", "host dispatches item check")
	_expect_equal(host_adapter.commands[1].get("payload", {}).get("messageId"), 900, "host resumes item branch")
	_expect_equal(host_completions.size(), 1, "host completes item possession branch")
	host.queue_free()


func _test_take_gold_action() -> void:
	var first = InventoryTestCharacter.new()
	first.money = [3, 2, 0]
	var second = InventoryTestCharacter.new()
	second.money = [3, 2, 0]
	var pooled_money := [3, 1, 0]
	var gold_result: Dictionary = InventoryRulesScript.take_party_currency(
		[first, second],
		pooled_money,
		0,
		7
	)
	_expect(bool(gold_result.get("paid", false)), "Take Gold accepts sufficient party gold")
	_expect_equal(gold_result.get("pooledSpent"), 3, "Take Gold spends pooled gold first")
	_expect_equal(first.money[0], 1, "Take Gold round-robin reaches the first character")
	_expect_equal(second.money[0], 1, "Take Gold round-robin reaches the second character")

	var gem_result: Dictionary = InventoryRulesScript.take_party_currency(
		[first, second],
		pooled_money,
		1,
		4
	)
	_expect(bool(gem_result.get("paid", false)), "Take Gold accepts sufficient party gems")
	_expect_equal(pooled_money[1], 0, "Take Gold spends pooled gems first")
	_expect_equal(first.money[1], 0, "gem payment preserves round-robin party order")
	_expect_equal(second.money[1], 1, "gem payment deducts only the requested amount")

	var before_failure := [pooled_money.duplicate(), first.money.duplicate(), second.money.duplicate()]
	var failed: Dictionary = InventoryRulesScript.take_party_currency(
		[first, second],
		pooled_money,
		0,
		99
	)
	_expect(not bool(failed.get("paid", true)), "Take Gold rejects insufficient wealth")
	_expect_equal(
		[pooled_money, first.money, second.money],
		before_failure,
		"failed Take Gold leaves all wealth unchanged"
	)

	var bundle = _take_gold_test_bundle()
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("payment:success"), "begin successful Take Gold fixture")
	interpreter.run_until_yield()
	var command: Dictionary = interpreter.resume_encounter(1)
	_expect_equal(command.get("command"), "take_party_wealth", "opcode 33 requests native payment")
	_expect_equal(command.get("payload", {}).get("currency"), 0, "positive amount requests gold")
	_expect_equal(command.get("payload", {}).get("amount"), 7, "payment preserves authored amount")
	var success_branch: Dictionary = interpreter.resume_wealth_payment(true)
	_expect_equal(
		success_branch.get("payload", {}).get("messageId"),
		901,
		"successful payment follows its authored result branch"
	)

	interpreter = _interpreter(bundle)
	interpreter.begin_trigger("payment:success")
	interpreter.run_until_yield()
	interpreter.resume_encounter(1)
	var success_fallthrough: Dictionary = interpreter.resume_wealth_payment(false)
	_expect_equal(
		success_fallthrough.get("payload", {}).get("messageId"),
		900,
		"failed payment falls through when success was required"
	)

	interpreter = _interpreter(bundle)
	interpreter.begin_trigger("payment:failure")
	interpreter.run_until_yield()
	interpreter.resume_encounter(1)
	var failure_branch: Dictionary = interpreter.resume_wealth_payment(false)
	_expect_equal(
		failure_branch.get("payload", {}).get("messageId"),
		911,
		"failed payment follows its authored failure branch"
	)

	interpreter = _interpreter(bundle)
	interpreter.begin_trigger("payment:force")
	interpreter.run_until_yield()
	interpreter.resume_encounter(1)
	var forced_branch: Dictionary = interpreter.resume_wealth_payment(false)
	_expect_equal(
		forced_branch.get("payload", {}).get("messageId"),
		941,
		"forced payment branch ignores the payment result"
	)

	interpreter = _interpreter(bundle)
	interpreter.begin_trigger("payment:skip")
	interpreter.run_until_yield()
	interpreter.resume_encounter(1)
	var skipped: Dictionary = interpreter.resume_wealth_payment(false)
	_expect_equal(
		skipped.get("payload", {}).get("messageId"),
		927,
		"special payment failure resumes at the eighth action slot"
	)

	interpreter = _interpreter(bundle)
	interpreter.begin_trigger("payment:gems")
	interpreter.run_until_yield()
	var gem_command: Dictionary = interpreter.resume_encounter(1)
	_expect_equal(gem_command.get("payload", {}).get("currency"), 1, "negative amount requests gems")
	_expect_equal(gem_command.get("payload", {}).get("amount"), 4, "gem amount is normalized")

	var host = HostScript.new()
	get_root().add_child(host)
	var adapter = WealthTestAdapter.new()
	host.configure(adapter)
	host.runtime.bundle = bundle
	host.runtime.runtime_state = StateScript.new()
	host.runtime.runtime_state.configure_from_bundle(bundle)
	host.runtime.interpreter.configure(bundle, host.runtime.runtime_state)
	var host_completions: Array = []
	host.playthrough_completed.connect(func(result: Dictionary) -> void: host_completions.append(result))
	_expect(host.start_trigger("payment:success"), "runtime host starts Take Gold fixture")
	_expect_equal(adapter.commands[1].get("command"), "take_party_wealth", "host dispatches payment")
	_expect_equal(adapter.commands[2].get("payload", {}).get("messageId"), 901, "host resumes payment branch")
	_expect_equal(host_completions.size(), 1, "host completes Take Gold branch")
	host.queue_free()


func _test_give_condition_action() -> void:
	var first := ConditionTestCharacter.new("Selected")
	var second := ConditionTestCharacter.new("Unselected", 2)
	var dead := ConditionTestCharacter.new("Dead", 3)
	var temporary_poison: GDScript = load("res://shared_assets/traits/t_poison.gd")
	var permanent_poison: GDScript = load("res://shared_assets/traits/p_poison.gd")
	first.add_trait(temporary_poison, [4])
	second.add_trait(temporary_poison, [2])
	dead.add_trait(permanent_poison, [1])
	var party := [first, second, dead]

	var selected_result: Dictionary = CharacterConditionRulesScript.apply_condition(
		party,
		[first],
		"selected",
		9,
		-1
	)
	_expect_equal(selected_result.get("affectedCount"), 1, "Give Condition targets picked characters")
	_expect_equal(
		CharacterConditionRulesScript.condition_value(first, 9),
		-1,
		"Give Condition applies a permanent signed poison value"
	)
	_expect_equal(
		CharacterConditionRulesScript.condition_value(second, 9),
		0,
		"Give Condition clears positive values outside the picked set"
	)
	_expect_equal(
		CharacterConditionRulesScript.condition_value(dead, 9),
		-1,
		"Give Condition preserves permanent values outside the picked set"
	)
	CharacterConditionRulesScript.apply_condition(party, [first], "selected", 9, -1)
	_expect_equal(
		CharacterConditionRulesScript.condition_value(first, 9),
		-2,
		"repeated permanent conditions accumulate their signed value"
	)
	CharacterConditionRulesScript.apply_condition(party, [first], "selected", 9, 3)
	_expect_equal(
		CharacterConditionRulesScript.condition_value(first, 9),
		1,
		"positive duration combines with an existing permanent value"
	)
	var living_result: Dictionary = CharacterConditionRulesScript.apply_condition(
		party,
		[],
		"living",
		28,
		-1
	)
	_expect_equal(living_result.get("affectedCount"), 2, "living mode excludes only dead characters")
	_expect_equal(
		CharacterConditionRulesScript.condition_value(second, 28),
		-1,
		"living mode includes an incapacitated character"
	)
	_expect_equal(
		CharacterConditionRulesScript.condition_value(dead, 28),
		0,
		"living mode excludes a dead character"
	)
	var party_result: Dictionary = CharacterConditionRulesScript.apply_condition(
		party,
		[],
		"party",
		28,
		-1
	)
	_expect_equal(party_result.get("affectedCount"), 3, "party mode includes every character")
	_expect_equal(
		CharacterConditionRulesScript.condition_value(dead, 28),
		-1,
		"party mode can affect a dead character"
	)
	var effect_target := ConditionTestCharacter.new("Effect target")
	var poison_effect: Variant = permanent_poison.new([effect_target, 2])
	_expect_equal(
		poison_effect.get_saved_variables(),
		[2],
		"the native trait exposes the value used by character saves"
	)
	poison_effect._on_time_pass(effect_target, 5)
	_expect_equal(
		effect_target.current_hp,
		20,
		"native permanent poison waits for a crossed game-hour boundary"
	)
	var permanent_disease: GDScript = load("res://shared_assets/traits/p_disease.gd")
	var disease_target := ConditionTestCharacter.new("Disease effect target")
	var disease_effect: Variant = permanent_disease.new([disease_target, 3])
	disease_effect._on_time_pass(disease_target, 5)
	_expect_equal(disease_target.current_hp, 17, "native permanent disease deals periodic damage")
	var temporary_poison_target := ConditionTestCharacter.new("Temporary poison target")
	var temporary_poison_effect: Variant = temporary_poison.new([temporary_poison_target, 2])
	temporary_poison_effect._on_time_pass(temporary_poison_target, 5)
	_expect_equal(
		temporary_poison_target.current_hp,
		20,
		"native temporary poison waits for a crossed game-hour boundary"
	)
	var temporary_disease: GDScript = load("res://shared_assets/traits/t_disease.gd")
	var temporary_disease_target := ConditionTestCharacter.new("Temporary disease target")
	var temporary_disease_effect: Variant = temporary_disease.new([temporary_disease_target, 3])
	temporary_disease_effect._on_time_pass(temporary_disease_target, 5)
	_expect_equal(
		temporary_disease_target.current_hp,
		17,
		"native temporary disease deals periodic damage"
	)

	var bundle = _give_condition_test_bundle()
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("condition:poison"), "begin Give Condition fixture")
	_expect_equal(
		interpreter.run_until_yield().get("command"),
		"start_encounter",
		"condition fixture starts encounter"
	)
	var command: Dictionary = interpreter.resume_encounter(1)
	_expect_equal(
		command.get("command"),
		"give_character_condition",
		"opcode 43 requests native condition mutation"
	)
	_expect_equal(command.get("payload", {}).get("targetMode"), "selected", "opcode 43 preserves picked mode")
	_expect_equal(command.get("payload", {}).get("conditionIndex"), 9, "opcode 43 preserves condition index")
	_expect_equal(command.get("payload", {}).get("duration"), -1, "opcode 43 preserves signed duration")
	_expect_equal(command.get("payload", {}).get("soundId"), 0, "opcode 43 preserves sound ID")
	_expect_equal(
		interpreter.run_until_yield().get("reason"),
		"keep-codes",
		"opcode 43 continues its result row"
	)


func _test_item_mutation_rules() -> void:
	var equipped_character = InventoryTestCharacter.new()
	equipped_character.inventory = [_test_item("Test Key", 1, 5)]
	var carried_character = InventoryTestCharacter.new()
	carried_character.inventory = [_test_item("Spare Key")]
	_expect(
		InventoryRulesScript.party_has_named_item(
			[equipped_character, carried_character],
			["test key"]
		),
		"item possession includes equipped items"
	)

	var drop_result: Dictionary = InventoryRulesScript.alter_named_items(
		[equipped_character, carried_character],
		["Test Key", "Spare Key"],
		1,
		1,
		0
	)
	_expect_equal(drop_result.get("changed"), 1, "item removal honors its match limit")
	_expect(equipped_character.inventory.is_empty(), "item removal drops the first party match")
	_expect_equal(carried_character.inventory.size(), 1, "item removal leaves later matches alone")

	var charged_character = InventoryTestCharacter.new()
	charged_character.inventory = [_test_item("Charged Wand", 1, 5)]
	var charge_result: Dictionary = InventoryRulesScript.alter_named_items(
		[charged_character],
		["Charged Wand"],
		1,
		2,
		-2
	)
	_expect_equal(charge_result.get("changed"), 1, "item charge mutation finds its target")
	_expect_equal(charged_character.inventory[0].get("charges"), 3, "item charge mutation is signed")
	_expect_equal(charged_character.unequip_count, 0, "charge mutation does not unequip the item")
	_expect_equal(charged_character.inventory[0].get("equipped"), 1, "charged item remains equipped")

	var replaced_character = InventoryTestCharacter.new()
	replaced_character.inventory = [_test_item("Old Wand", 1, 2)]
	var replacement := _test_item("New Wand", 0, 7)
	var replace_result: Dictionary = InventoryRulesScript.alter_named_items(
		[replaced_character],
		["Old Wand"],
		1,
		3,
		0,
		replacement
	)
	_expect_equal(replace_result.get("changed"), 1, "item replacement finds its target")
	_expect_equal(replaced_character.inventory[0].get("name"), "New Wand", "item replacement uses new template")
	_expect_equal(replaced_character.inventory[0].get("charges"), 7, "item replacement resets charges")
	_expect_equal(replaced_character.inventory[0].get("is_identified"), 0, "item replacement resets identification")
	_expect_equal(replaced_character.inventory[0].get("equipped"), 1, "replacement retries prior equipment state")


func _test_equipment_storage_rules() -> void:
	var first_character = InventoryTestCharacter.new()
	first_character.inventory = [_test_item("Sword", 1)]
	first_character.money = [10, 1, 0]
	var second_character = InventoryTestCharacter.new()
	second_character.inventory = [_test_item("Ring")]
	second_character.money = [0, 0, 1]
	var pooled_money := [5, 2, 1]
	var captured: Dictionary = InventoryRulesScript.capture_party_equipment(
		[first_character, second_character],
		pooled_money
	)
	_expect(bool(captured.get("active")), "equipment capture creates active storage")
	_expect_equal(captured.get("wealth"), [15, 3, 2], "equipment capture pools all wealth")
	_expect(first_character.inventory.is_empty(), "equipment capture clears first inventory")
	_expect(second_character.inventory.is_empty(), "equipment capture clears second inventory")
	first_character.inventory.append(_test_item("Interim Loot"))
	var restored: Dictionary = InventoryRulesScript.restore_party_equipment(
		[first_character, second_character],
		pooled_money,
		captured
	)
	_expect(bool(restored.get("restored")), "equipment restore consumes active storage")
	_expect_equal(first_character.inventory[0].get("name"), "Sword", "equipment restore returns original item")
	_expect_equal(first_character.inventory[0].get("equipped"), 1, "equipment restore reapplies worn state")
	_expect_equal(second_character.inventory[0].get("name"), "Ring", "equipment restore returns party inventory")
	_expect_equal(restored.get("extraItems", [])[0].get("name"), "Interim Loot", "interim items become loot")
	for currency: int in 3:
		_expect_equal(
			int(first_character.money[currency]) + int(second_character.money[currency]) \
				+ int(pooled_money[currency]),
			int(captured.get("wealth", [])[currency]),
			"equipment restore preserves wealth type %d" % currency
		)
	var limited_character = InventoryTestCharacter.new()
	limited_character.weight_limit = 10
	var limited_pool := [0, 0, 0]
	InventoryRulesScript.restore_party_equipment(
		[limited_character],
		limited_pool,
		{"active": true, "inventories": [[]], "wealth": [0, 0, 1]}
	)
	_expect_equal(
		limited_character.money[2],
		1,
		"equipment restore preserves Classic's pre-award jewel weight check"
	)
	var loaded_character = InventoryTestCharacter.new()
	loaded_character.weight_limit = 2
	loaded_character.inventory = [_test_item("Interim Weight")]
	loaded_character.inventory[0]["weight"] = 2
	var loaded_pool := [0, 0, 0]
	InventoryRulesScript.restore_party_equipment(
		[loaded_character],
		loaded_pool,
		{"active": true, "inventories": [[]], "wealth": [1, 0, 0]}
	)
	_expect_equal(
		loaded_pool[0],
		1,
		"equipment restore shares wealth before replacing interim items"
	)


func _test_evidence_backed_dispatcher_noop(bundle) -> void:
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data ED3:macro:73", 2), "begin CoB dispatcher no-op slot")
	var result: Dictionary = interpreter.run_until_yield()
	_expect_equal(result.get("status"), "completed", "evidence-listed dispatcher no-op is skipped")
	_expect_equal(interpreter.trace[0].get("code"), 200, "dispatcher no-op remains visible in trace")


func _test_quest_state_and_branch(bundle) -> void:
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:0:80", 5), "begin CoB quest setter at slot 5")
	var set_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(set_result.get("status"), "completed", "quest setter completes")
	_expect(interpreter.runtime_state.is_quest_set(33), "opcode 47 sets quest 33")
	_expect_equal(bundle.get_trigger("Data DD:0:80").get("id"), "Data DD:0:80", "execution does not mutate bundle records")
	interpreter.runtime_state.set_quest_flag(-33)
	_expect(not interpreter.runtime_state.is_quest_set(33), "negative quest id clears quest 33")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:0:78"), "begin CoB quest branch")
	var false_branch: Dictionary = interpreter.run_until_yield()
	_expect_equal(false_branch.get("status"), "completed", "unset quest follows ED3 branch")
	_expect_equal(false_branch.get("reason"), "keep-codes", "ED3 target executes opcode 24")
	_expect_equal(interpreter.trace.size(), 2, "branch trace contains source and target")
	_expect_equal(interpreter.trace[1].get("triggerId"), "Data ED3:macro:100", "branch target is CoB ED3 record 100")

	interpreter = _interpreter(bundle)
	interpreter.runtime_state.set_quest_flag(20)
	_expect(interpreter.begin_trigger("Data DD:0:78"), "restart CoB quest branch")
	var true_branch: Dictionary = interpreter.run_until_yield()
	_expect_equal(true_branch.get("command"), "show_text", "set quest continues within current AP")
	_expect_equal(true_branch.get("payload", {}).get("messageId"), 620, "continued AP reaches CoB message 620")


func _test_classic_stack_semantics() -> void:
	var bundle = _stack_test_bundle()
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("stack:sticky"), "begin sticky GOSUB stack fixture")
	var nested_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(nested_result.get("payload", {}).get("messageId"), 902, "nested positive branch inherits GOSUB mode")
	_expect_equal(interpreter.call_stack.size(), 2, "sticky GOSUB pushes nested positive branch")
	_expect(interpreter.gosub_active, "GOSUB mode remains active while nested")
	var middle_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(middle_result.get("payload", {}).get("messageId"), 901, "first return resumes middle AP")
	_expect_equal(interpreter.call_stack.size(), 1, "first return pops one frame")
	var root_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(root_result.get("payload", {}).get("messageId"), 900, "second return resumes root AP")
	_expect_equal(interpreter.call_stack.size(), 0, "second return empties stack")
	_expect(not interpreter.gosub_active, "positive root action clears GOSUB mode on empty stack")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("stack:pop"), "begin POP stack fixture")
	var pop_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(pop_result.get("payload", {}).get("messageId"), 910, "POP discards middle frame before return")
	_expect_equal(interpreter.call_stack.size(), 0, "POP and return consume both frames")
	_expect(
		not _trace_has_action(interpreter.trace, "Data ED3:macro:200", 1),
		"discarded frame does not resume"
	)

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("stack:empty-pop"), "begin empty POP stack fixture")
	var empty_pop_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(empty_pop_result.get("payload", {}).get("messageId"), 912, "POP on an empty stack is a no-op")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("stack:extend"), "begin Extend Door Codes fixture")
	var extend_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(extend_result.get("payload", {}).get("messageId"), 931, "Extend Door Codes enters its target AP")
	_expect_equal(interpreter.call_stack.size(), 0, "negative Extend Door Codes does not push a frame")
	var extend_end: Dictionary = interpreter.run_until_yield()
	_expect_equal(extend_end.get("reason"), "return-with-empty-stack", "Extend Door Codes target cannot return to its source")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("stack:no-implicit-return"), "begin explicit-return fixture")
	var leaf_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(leaf_result.get("payload", {}).get("messageId"), 921, "GOSUB leaf executes")
	var ended_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(ended_result.get("reason"), "action-point-ended", "AP end does not implicitly return")
	_expect_equal(interpreter.call_stack.size(), 0, "unfinished frames are discarded when execution ends")
	_expect(
		not _trace_has_action(interpreter.trace, "stack:no-implicit-return", 1),
		"root AP remains suspended without opcode 111"
	)

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("stack:overflow"), "begin stack depth fixture")
	var overflow_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(overflow_result.get("status"), "error", "twenty-first GOSUB frame stops safely")
	_expect_equal(interpreter.call_stack.size(), 20, "GOSUB stack matches Classic's twenty-frame capacity")
	_expect(
		str(overflow_result.get("message", "")).contains("exceeded 20 frames"),
		"stack overflow reports Classic frame limit"
	)


func _test_shipped_gosub_chain() -> void:
	var bundle = BundleScript.new()
	_expect(
		bundle.load_from_directory(WAR_IN_THE_SWORD_LANDS_GOSUB_FIXTURE),
		"War in the Sword Lands GOSUB fixture loads: %s" % bundle.last_error
	)
	if not bundle.last_error.is_empty():
		return

	var interpreter = _interpreter(bundle)
	# EDCD rows 1508 and 1824 require set flags; row 1510 requires quest 2 to remain unset.
	interpreter.runtime_state.set_quest_flag(29)
	interpreter.runtime_state.set_quest_flag(64)
	_expect(
		interpreter.begin_trigger("Data DD:9:48", 3),
		"begin shipped War in the Sword Lands GOSUB chain"
	)

	var random_text: Dictionary = interpreter.run_until_yield()
	var random_message_id := int(random_text.get("payload", {}).get("messageId", -1))
	_expect_equal(random_text.get("command"), "show_text", "shipped chain displays random text")
	_expect(
		random_message_id >= 1107 and random_message_id <= 1109,
		"random text stays within source EDCD message range"
	)
	_expect_equal(
		random_text.get("payload", {}).get("message", {}).get("id"),
		random_message_id,
		"random text resolves the selected source message"
	)
	_expect_equal(interpreter.call_stack.size(), 1, "first shipped GOSUB pushes the map AP")

	var first_nested_text: Dictionary = interpreter.run_until_yield()
	_expect_equal(
		first_nested_text.get("payload", {}).get("messageId"),
		1110,
		"first nested XAP displays source message 1110"
	)
	_expect_equal(interpreter.call_stack.size(), 2, "second shipped GOSUB pushes its XAP")

	var second_nested_text: Dictionary = interpreter.run_until_yield()
	_expect_equal(
		second_nested_text.get("payload", {}).get("messageId"),
		1246,
		"second nested XAP displays source message 1246"
	)
	_expect_equal(interpreter.call_stack.size(), 3, "third shipped GOSUB pushes its XAP")

	var completed: Dictionary = interpreter.run_until_yield()
	_expect_equal(completed.get("reason"), "keep-codes", "three opcode 111 returns resume the map AP")
	_expect_equal(interpreter.call_stack.size(), 0, "shipped GOSUB chain unwinds every frame")
	_expect_equal(interpreter.trace, [
		{"triggerId": "Data DD:9:48", "slot": 3, "code": 46},
		{"triggerId": "Data ED3:macro:1026", "slot": 0, "code": 19},
		{"triggerId": "Data ED3:macro:1026", "slot": 1, "code": 46},
		{"triggerId": "Data ED3:macro:1027", "slot": 0, "code": 1},
		{"triggerId": "Data ED3:macro:1027", "slot": 1, "code": 46},
		{"triggerId": "Data ED3:macro:1196", "slot": 0, "code": 1},
		{"triggerId": "Data ED3:macro:1196", "slot": 1, "code": 111},
		{"triggerId": "Data ED3:macro:1027", "slot": 2, "code": 111},
		{"triggerId": "Data ED3:macro:1026", "slot": 2, "code": 111},
		{"triggerId": "Data DD:9:48", "slot": 7, "code": 24},
	], "shipped GOSUB trace matches Classic return order")


func _test_shipped_opcode_25_mutation() -> void:
	var bundle = BundleScript.new()
	_expect(
		bundle.load_from_directory(TWIN_SANDS_OPCODE_25_FIXTURE),
		"Twin Sands opcode 25 fixture loads: %s" % bundle.last_error
	)
	if not bundle.last_error.is_empty():
		return

	var state = StateScript.new()
	state.configure_from_bundle(bundle)
	state.level_type = "dungeon"
	state.set_position(0, 43, 81)
	var interpreter = InterpreterScript.new()
	interpreter.configure(bundle, state)
	_expect(
		interpreter.begin_trigger("Data DDD:0:32", 7),
		"begin shipped Twin Sands opcode 25"
	)
	var completed: Dictionary = interpreter.run_until_yield()
	_expect_equal(completed.get("reason"), "action-point-ended", "opcode 25 finishes the AP")
	_expect_equal(state.x, 77, "opcode 25 exit reaches the source door destination x")
	_expect_equal(state.y, 16, "opcode 25 exit reaches the source door destination y")
	_expect_equal(
		state.get_trigger_percent("dungeon", 0, 32, 100),
		-1,
		"opcode 25 consumes the source door"
	)
	var replacement := state.get_action_point_override("Data DDD:0:32")
	_expect_equal(replacement.get("targetX"), 43, "replacement door points back to activation x")
	_expect_equal(replacement.get("targetY"), 81, "replacement door points back to activation y")
	_expect_equal(replacement.get("coordinate"), {"x": 43, "y": 81}, "replacement keeps its door coordinate")
	_expect_equal(replacement.get("actions", []).size(), 3, "replacement keeps the active AP actions")
	_expect_equal(
		bundle.get_trigger("Data DDD:0:32").get("targetX"),
		77,
		"opcode 25 leaves imported bundle records immutable"
	)

	var restored = StateScript.new()
	restored.restore(state.snapshot())
	var restored_replacement := restored.get_action_point_override("Data DDD:0:32")
	_expect_equal(restored_replacement.get("targetX"), 43, "replacement door survives snapshot")
	_expect_equal(
		restored.get_trigger_percent("dungeon", 0, 32, 100),
		-1,
		"replacement percent survives snapshot"
	)

	var runtime = RuntimeScript.new()
	_expect(runtime.load_campaign(TWIN_SANDS_OPCODE_25_FIXTURE), "runtime loads opcode 25 fixture")
	runtime.restore(state.snapshot())
	var triggers := runtime.triggers_at("dungeon", 0, 43, 81)
	_expect_equal(triggers.size(), 1, "runtime lookup exposes the persisted door record")
	_expect_equal(triggers[0].get("targetX"), 43, "runtime lookup applies the persisted target")


func _test_opcode_25_xap_copy() -> void:
	var bundle = _opcode_25_test_bundle()
	var state = StateScript.new()
	state.configure_from_bundle(bundle)
	state.set_position(0, 2, 3)
	var interpreter = InterpreterScript.new()
	interpreter.configure(bundle, state)
	_expect(interpreter.begin_trigger("Data DD:0:7"), "begin opcode 25 XAP copy fixture")

	var first_text: Dictionary = interpreter.run_until_yield()
	_expect_equal(first_text.get("payload", {}).get("messageId"), 900, "GOSUB enters replacement XAP")
	_expect_equal(interpreter.call_stack.size(), 1, "XAP starts with a saved caller frame")
	var second_text: Dictionary = interpreter.run_until_yield()
	_expect_equal(second_text.get("payload", {}).get("messageId"), 901, "execution continues after opcode 25")
	_expect_equal(interpreter.call_stack.size(), 0, "opcode 25 clears the GOSUB stack immediately")
	_expect_equal(interpreter.trace[3].get("code"), 111, "cleared-stack return is a no-op after opcode 25")
	var completed: Dictionary = interpreter.run_until_yield()
	_expect_equal(completed.get("status"), "completed", "replacement XAP completes")
	_expect_equal(completed.get("reason"), "keep-codes", "replacement XAP honors Keep Codes")

	var replacement := state.get_action_point_override("Data DD:0:7")
	_expect_equal(replacement.get("targetX"), 2, "XAP replacement captures activation x")
	_expect_equal(replacement.get("targetY"), 3, "XAP replacement captures activation y")
	_expect_equal(replacement.get("actions", []).size(), 5, "XAP actions replace the map AP actions")
	_expect_equal(replacement.get("actions", [])[1].get("code"), 25, "replacement contains opcode 25")
	_expect_equal(
		state.get_trigger_percent("land", 0, 7, 100),
		100,
		"Keep Codes preserves the replacement trigger percent"
	)
	_expect_equal(
		bundle.get_trigger("Data DD:0:7").get("actions", []).size(),
		1,
		"XAP replacement does not edit the bundle map AP"
	)

	var replay = InterpreterScript.new()
	replay.configure(bundle, state)
	_expect(replay.begin_trigger("Data DD:0:7"), "restart persisted XAP replacement")
	var replay_text: Dictionary = replay.run_until_yield()
	_expect_equal(replay_text.get("payload", {}).get("messageId"), 900, "persisted XAP actions run on reactivation")
	_expect_equal(replay.trace[0].get("code"), 1, "reactivation starts with the copied action list")
	_expect_equal(replay.call_stack.size(), 0, "reactivation no longer enters the original GOSUB")


func _test_modal_picture_actions() -> void:
	var bundle = BundleScript.new()
	bundle.manifest = {"start": {"levelType": "land", "levelIndex": 0, "x": 0, "y": 0}}
	bundle.pictures_by_id[32128] = {
		"resourceId": 32128,
		"resourceType": "PICT",
		"relativePath": "Splash Images/32128.png",
	}
	bundle.messages_by_id[900] = {"id": 900, "text": "After the click."}
	bundle.messages_by_id[901] = {"id": 901, "text": "After the picture."}
	_add_stack_trigger(bundle, "modal:click", -1, [
		_classic_action(0, 26, 0),
		_classic_action(1, 1, 900),
	])
	_add_stack_trigger(bundle, "modal:picture", -1, [
		_classic_action(0, 27, 32128),
		_classic_action(1, 1, 901),
	])
	_add_stack_trigger(bundle, "modal:redraw", -1, [_classic_action(0, 28, 0)])

	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("modal:click"), "begin click acknowledgement fixture")
	var click_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(click_result.get("command"), "wait_for_click", "get-click command")
	_expect_equal(click_result.get("payload", {}).get("prompt"), "Click Mouse", "get-click prompt")
	_expect_equal(click_result.get("payload", {}).get("soundId"), 30005, "get-click sound")
	_expect_equal(interpreter.run_until_yield().get("command"), "show_text", "click resumes action list")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("modal:picture"), "begin picture fixture")
	var picture_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(picture_result.get("command"), "show_picture", "show-picture command")
	_expect_equal(picture_result.get("payload", {}).get("pictureId"), 32128, "show-picture ID")
	_expect_equal(
		picture_result.get("payload", {}).get("picture", {}).get("resourceType"),
		"PICT",
		"show-picture catalog record"
	)
	_expect_equal(interpreter.run_until_yield().get("command"), "show_text", "picture resumes action list")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("modal:redraw"), "begin map redraw fixture")
	_expect_equal(interpreter.run_until_yield().get("command"), "redraw_map", "map redraw command")

	var adapter = GodotAdapterScript.new()
	_expect_equal(
		adapter.picture_file_candidates({
			"pictureId": 32128,
			"picture": {
				"fileName": "../outside.png",
				"relativePath": "Splash Images/32128.png",
				"path": "C:/outside.png",
				"name": "portraits/mayor.png",
			},
		}),
		["32128.png", "portraits/mayor.png"],
		"picture candidates stay inside the campaign splash directory"
	)


func _test_runtime_media_adapters() -> void:
	var bundle = BundleScript.new()
	bundle.root_directory = "res://Campaigns/City of Bywater"
	var adapter = GodotAdapterScript.new()
	adapter.configure_classic_bundle(bundle)
	var picture := {
		"resourceId": 0,
		"runtimeMedia": {
			"path": "Splash Images/0.png",
			"mediaType": "image/png",
		},
	}
	var picture_path := adapter.runtime_media_path(picture, "image/")
	_expect_equal(
		picture_path,
		"res://Campaigns/City of Bywater/Splash Images/0.png",
		"picture adapter resolves campaign-relative runtime media"
	)
	var unsafe_picture := picture.duplicate(true)
	unsafe_picture["runtimeMedia"]["path"] = "../0.png"
	_expect_equal(
		adapter.runtime_media_path(unsafe_picture, "image/"),
		"",
		"picture adapter rejects runtime-media traversal"
	)

	for sound_specification: Array in [
		["Sounds/woof.wav", "audio/wav", "AudioStreamWAV"],
		["Sounds/woof.ogg", "audio/ogg", "AudioStreamOggVorbis"],
		["Sounds/woof.mp3", "audio/mpeg", "AudioStreamMP3"],
	]:
		var stream: AudioStream = adapter.runtime_audio_stream({
			"runtimeMedia": {
				"path": sound_specification[0],
				"mediaType": sound_specification[1],
			},
		})
		_expect(stream != null, "%s runtime media loads" % sound_specification[1])
		if stream != null:
			_expect_equal(
				stream.get_class(),
				sound_specification[2],
				"%s uses the expected Godot stream" % sound_specification[1]
			)

	var runtime_image := Image.new()
	_expect(
		runtime_image.load(picture_path) == OK,
		"Godot decodes picture runtime media by campaign-relative path"
	)
	_expect(runtime_image.get_width() > 0, "decoded picture runtime media has image content")


func _test_classic_player_map_renderer() -> void:
	var player_map_rect: Control = ClassicPlayerMapScene.instantiate()
	player_map_rect.map_texture_rect = player_map_rect.get_node(
		"VBoxContainer/MapArea/MapTextureRect"
	)
	player_map_rect.missing_media_label = player_map_rect.get_node(
		"VBoxContainer/MapArea/MissingMediaLabel"
	)
	player_map_rect.map_name_label = player_map_rect.get_node(
		"VBoxContainer/Footer/MapNameLabel"
	)
	player_map_rect.map_note_label = player_map_rect.get_node(
		"VBoxContainer/Footer/MapNoteLabel"
	)
	player_map_rect.previous_button = player_map_rect.get_node(
		"VBoxContainer/Footer/PreviousButton"
	)
	player_map_rect.next_button = player_map_rect.get_node("VBoxContainer/Footer/NextButton")
	player_map_rect.done_button = player_map_rect.get_node("VBoxContainer/Footer/DoneButton")
	get_root().add_child(player_map_rect)
	var map_record := {
		"id": 7,
		"primaryName": "The Old Road",
		"secondaryName": "Unknown Map",
		"note": "The old road crosses the river north of town.",
	}
	_expect(
		player_map_rect.display_map(
			map_record,
			"res://Campaigns/City of Bywater/Splash Images/0.png"
		),
		"Classic player-map renderer loads campaign runtime media"
	)
	_expect(player_map_rect.visible, "Classic player-map renderer opens independently")
	_expect_equal(
		player_map_rect.map_name_label.text,
		"The Old Road",
		"Classic player-map renderer uses the available map name"
	)
	_expect_equal(
		player_map_rect.map_note_label.text,
		map_record["note"],
		"Classic player-map renderer presents the compiled note"
	)
	_expect(
		player_map_rect.map_texture_rect.texture != null,
		"Classic player-map renderer presents decoded image content"
	)
	_expect_equal(
		ClassicPlayerMapScript.map_display_name({"id": 9}),
		"Player Map 9",
		"Classic player-map renderer supplies a stable unnamed-map label"
	)
	_expect(
		player_map_rect.display_catalog([
			{
				"record": map_record,
				"runtimeMediaPath": "res://Campaigns/City of Bywater/Splash Images/0.png",
			},
			{
				"record": {
					"id": 9,
					"primaryName": "Map Without Art",
					"note": "The note remains available.",
				},
				"runtimeMediaPath": "",
			},
		]),
		"Classic player-map renderer opens an acquired-map catalog"
	)
	_expect(
		not player_map_rect.previous_button.disabled and not player_map_rect.next_button.disabled,
		"Classic player-map catalog enables navigation when multiple maps are acquired"
	)
	player_map_rect._on_next_button_pressed()
	_expect_equal(
		player_map_rect.current_map_record.get("id"),
		9,
		"Classic player-map catalog advances to the next acquired map"
	)
	_expect(
		player_map_rect.missing_media_label.visible \
			and not player_map_rect.map_texture_rect.visible,
		"Classic player-map catalog keeps note-only records browseable"
	)
	player_map_rect._on_previous_button_pressed()
	_expect_equal(
		player_map_rect.current_map_record.get("id"),
		7,
		"Classic player-map catalog returns to the previous acquired map"
	)
	var close_state := {"didClose": false}
	player_map_rect.closed.connect(func() -> void: close_state["didClose"] = true)
	player_map_rect.close_map()
	_expect(
		bool(close_state["didClose"]) and not player_map_rect.visible,
		"Classic player-map renderer closes cleanly"
	)
	player_map_rect.free()


func _test_party_state_actions() -> void:
	var bundle = _party_state_test_bundle()
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("party:condition"), "begin party-condition fixture")
	var condition_check: Dictionary = interpreter.run_until_yield()
	_expect_equal(condition_check.get("command"), "check_party_condition", "condition yields typed check")
	_expect_equal(condition_check.get("payload", {}).get("conditionIndex"), 1, "condition preserves Waterworld index")
	_expect(bool(condition_check.get("payload", {}).get("requiredActive")), "condition requests active state")
	var condition_branch: Dictionary = interpreter.resume_party_condition_check(true)
	_expect_equal(condition_branch.get("command"), "start_encounter", "active condition follows its branch")
	_expect_equal(condition_branch.get("payload", {}).get("encounterKind"), "complex", "condition selects complex encounter")
	_expect_equal(condition_branch.get("payload", {}).get("encounterId"), 8, "condition preserves encounter ID")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("party:condition"), "restart party-condition fixture")
	interpreter.run_until_yield()
	var condition_fallthrough: Dictionary = interpreter.resume_party_condition_check(false)
	_expect_equal(condition_fallthrough.get("payload", {}).get("messageId"), 901, "inactive condition falls through")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("party:ally"), "begin ally-check fixture")
	var ally_check: Dictionary = interpreter.run_until_yield()
	_expect_equal(ally_check.get("command"), "check_party_ally", "ally action yields typed check")
	_expect_equal(ally_check.get("payload", {}).get("monsterNameId"), 19, "ally check preserves name ID")
	_expect_equal(
		ally_check.get("payload", {}).get("monster", {}).get("displayName"),
		"Vodalian",
		"ally check resolves compiled monster"
	)
	var ally_branch: Dictionary = interpreter.resume_ally_check(true)
	_expect_equal(ally_branch.get("payload", {}).get("messageId"), 910, "present ally follows XAP branch")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("party:ally"), "restart ally-check fixture")
	interpreter.run_until_yield()
	var ally_fallthrough: Dictionary = interpreter.resume_ally_check(false)
	_expect_equal(ally_fallthrough.get("payload", {}).get("messageId"), 902, "absent ally continues when requested")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("party:ally-message"), "begin absent-ally message fixture")
	interpreter.run_until_yield()
	var ally_message: Dictionary = interpreter.resume_ally_check(false)
	_expect_equal(ally_message.get("payload", {}).get("messageId"), 903, "absent ally can show text and exit")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("party:add-ally"), "begin add-ally fixture")
	var add_ally: Dictionary = interpreter.run_until_yield()
	_expect_equal(add_ally.get("command"), "add_party_ally", "add ally yields typed mutation")
	_expect_equal(add_ally.get("payload", {}).get("monsterId"), 71, "add ally preserves monster ID")
	_expect_equal(add_ally.get("payload", {}).get("monster", {}).get("displayName"), "Vodalian", "add ally resolves monster")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("party:registration"), "begin registration fixture")
	var registration_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(registration_result.get("payload", {}).get("messageId"), 904, "registration gate is a no-op")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("party:random-xap"), "begin random XAP fixture")
	var random_presentation: Dictionary = interpreter.run_until_yield()
	_expect_equal(random_presentation.get("command"), "present_random_branch", "random branch presents message and sound")
	_expect_equal(random_presentation.get("payload", {}).get("targetId"), 500, "fixed random range selects its target")
	_expect_equal(random_presentation.get("payload", {}).get("soundId"), 10105, "random branch preserves sound")
	_expect_equal(random_presentation.get("payload", {}).get("messageId"), 905, "random branch preserves message")
	var random_xap: Dictionary = interpreter.resume_random_branch()
	_expect_equal(random_xap.get("payload", {}).get("messageId"), 910, "random branch resumes into XAP")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("party:random-gosub"), "begin random GOSUB fixture")
	var random_gosub: Dictionary = interpreter.run_until_yield()
	_expect_equal(random_gosub.get("payload", {}).get("messageId"), 912, "random GOSUB enters its XAP")
	_expect_equal(interpreter.call_stack.size(), 1, "random GOSUB retains its return frame")
	var random_return: Dictionary = interpreter.run_until_yield()
	_expect_equal(random_return.get("payload", {}).get("messageId"), 911, "random GOSUB returns to its next action")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("party:random-simple"), "begin random simple fixture")
	var random_simple: Dictionary = interpreter.run_until_yield()
	_expect_equal(random_simple.get("payload", {}).get("encounterKind"), "simple", "random branch starts simple encounter")
	_expect_equal(random_simple.get("payload", {}).get("encounterId"), 3, "random simple target is inclusive")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("party:random-complex"), "begin random complex fixture")
	var random_complex: Dictionary = interpreter.run_until_yield()
	_expect_equal(random_complex.get("payload", {}).get("encounterKind"), "complex", "random branch starts complex encounter")
	_expect_equal(random_complex.get("payload", {}).get("encounterId"), 8, "random complex target is inclusive")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("party:random-missing"), "begin malformed random fixture")
	var random_missing: Dictionary = interpreter.run_until_yield()
	_expect_equal(random_missing.get("status"), "error", "missing random Extra Code is explicit")
	_expect("-1700" in str(random_missing.get("message", "")), "missing random row retains signed ID")

	var adapter = GodotAdapterScript.new()
	_expect_equal(
		adapter.party_condition_status(1, {"WaterBreath": {"Duration": 10}}, 0),
		{"supported": true, "active": true},
		"Waterworld maps to active WaterBreath"
	)
	_expect_equal(
		adapter.party_condition_status(1, {"WaterBreath": {"Duration": 0}}, 0),
		{"supported": true, "active": false},
		"expired WaterBreath is inactive"
	)
	_expect_equal(
		adapter.party_condition_status(0, {}, 5),
		{"supported": true, "active": true},
		"torch condition uses remaining light time"
	)
	_expect_equal(
		adapter.party_condition_status(5, {}, 0),
		{"supported": false, "active": false},
		"Search remains an explicit unmapped condition"
	)
	var ally = AllyTestCharacter.new()
	_expect(
		adapter.party_has_classic_ally({"monsterId": 71, "monster": {"displayName": "Vodalian"}}, [ally]),
		"native ally name can satisfy a Classic check"
	)
	ally.name = "Renamed Ally"
	ally.set_meta("classic_monster_id", 71)
	_expect(
		adapter.party_has_classic_ally({"monsterId": 71, "monster": {"displayName": "Vodalian"}}, [ally]),
		"imported Classic monster ID survives ally renaming"
	)
	ally.set_meta("classic_monster_name_id", 19)
	_expect(
		adapter.party_has_classic_ally({"monsterNameId": 19}, [ally]),
		"Classic ally name identity survives ally renaming"
	)
	_expect_equal(
		adapter.resolve_classic_monster_bestiary_name(
			71,
			{"displayName": "Vodalian"},
			{"Vodalian": {"data": {"name": "Vodalian"}}}
		),
		"Vodalian",
		"ally resource resolves by exact display name"
	)
	_expect_equal(
		adapter.resolve_classic_monster_bestiary_name(
			71,
			{"displayName": "Renamed Vodalian"},
			{"Vodalian 71": {"data": {"id": 71, "name": "Vodalian"}}}
		),
		"Vodalian 71",
		"native bestiary IDs resolve before display names"
	)
	_expect_equal(
		adapter.resolve_classic_monster_bestiary_name(
			71,
			{"displayName": "Vodalian"},
			{
				"Vodalian": {"data": {"name": "Vodalian"}},
				"Imported ally": {"data": {"name": "Other", "classicMonsterId": 71}},
			}
		),
		"Imported ally",
		"ally resource prefers explicit Classic monster ID"
	)
	_expect_equal(
		adapter.resolve_classic_monster_bestiary_name(
			71,
			{"displayName": "Vodalian"},
			{
				"First Vodalian": {"data": {"name": "Vodalian"}},
				"Second Vodalian": {"data": {"name": "Vodalian"}},
			}
		),
		"",
		"ambiguous display names require explicit Classic monster metadata"
	)


func _test_priest_turning_actions() -> void:
	var bundle = BundleScript.new()
	bundle.manifest = {"start": {"levelType": "land", "levelIndex": 0, "x": 0, "y": 0}}
	bundle.extra_codes_by_id[1] = {"id": 1, "values": [5, 0, 0, 0, 0]}
	bundle.battles_by_id[5] = {"id": 5}
	_add_stack_trigger(bundle, "priest:disable", -1, [
		_classic_action(0, 82, 0),
		_classic_action(1, 2, 1),
	])
	_add_stack_trigger(bundle, "priest:enable", -1, [
		_classic_action(0, 83, 0),
		_classic_action(1, 2, 1),
	])

	var interpreter = _interpreter(bundle)
	_expect(interpreter.runtime_state.priest_turning_enabled, "priest turning starts enabled")
	_expect(interpreter.begin_trigger("priest:disable"), "begin priest-turning disable fixture")
	var disabled: Dictionary = interpreter.run_until_yield()
	_expect_equal(disabled.get("command"), "set_priest_turning", "disable yields typed state command")
	_expect(not bool(disabled.get("payload", {}).get("enabled")), "opcode 82 disables priest turning")
	_expect_equal(disabled.get("payload", {}).get("soundId"), 10105, "disable preserves Classic sound")
	_expect_equal(
		disabled.get("payload", {}).get("message", {}).get("text"),
		"You may not use your ability to turn undead or nether spawn.",
		"disable preserves Classic feedback"
	)
	_expect(not interpreter.runtime_state.priest_turning_enabled, "disabled state is authoritative")
	var disabled_battle: Dictionary = interpreter.run_until_yield()
	_expect_equal(disabled_battle.get("command"), "start_battle", "disable action continues to battle")
	_expect(
		not bool(disabled_battle.get("payload", {}).get("priestTurningEnabled")),
		"battle request carries disabled turning state"
	)

	var restored = StateScript.new()
	restored.restore(interpreter.runtime_state.snapshot())
	_expect(not restored.priest_turning_enabled, "priest-turning gate survives snapshot")
	interpreter = InterpreterScript.new()
	interpreter.configure(bundle, restored)
	_expect(interpreter.begin_trigger("priest:enable"), "begin priest-turning enable fixture")
	var enabled: Dictionary = interpreter.run_until_yield()
	_expect(bool(enabled.get("payload", {}).get("enabled")), "opcode 83 enables priest turning")
	_expect_equal(enabled.get("payload", {}).get("soundId"), 20004, "enable preserves Classic sound")
	_expect_equal(
		enabled.get("payload", {}).get("message", {}).get("text"),
		"You regain your ability to turn undead and nether spawn.",
		"enable preserves Classic feedback"
	)
	_expect(restored.priest_turning_enabled, "enabled state is authoritative")
	var enabled_battle: Dictionary = interpreter.run_until_yield()
	_expect(
		bool(enabled_battle.get("payload", {}).get("priestTurningEnabled")),
		"battle request carries enabled turning state"
	)

	var legacy_state = StateScript.new()
	legacy_state.restore({})
	_expect(legacy_state.priest_turning_enabled, "older snapshots default priest turning to enabled")


func _test_turn_undead_rules() -> void:
	var caster := TurnUndeadTestCreature.new("Priest", 0)
	caster.turn_undead = 100
	var destroyed_target := TurnUndeadTestCreature.new("Skeleton", 1)
	var turned_target := TurnUndeadTestCreature.new("Wraith", 1)
	var resisted_target := TurnUndeadTestCreature.new("Lich", 1)
	var living_target := TurnUndeadTestCreature.new("Bandit", 1)
	var excluded_target := TurnUndeadTestCreature.new("Summoned shade", 1)
	for target: TurnUndeadTestCreature in [
		destroyed_target,
		turned_target,
		resisted_target,
		excluded_target,
	]:
		target.set_meta("classic_turn_undead_eligible", true)
		target.set_meta("classic_hit_dice", 2)
		target.set_meta("classic_magic_resistance", 0)
		target.set_meta("classic_can_summon", 0)
	excluded_target.set_meta("classic_can_summon", 255)
	living_target.set_meta("classic_turn_undead_eligible", false)
	var combatants := [
		CombatTestButton.new(caster),
		CombatTestButton.new(destroyed_target),
		CombatTestButton.new(turned_target),
		CombatTestButton.new(resisted_target),
		CombatTestButton.new(living_target),
		CombatTestButton.new(excluded_target),
	]

	_expect(
		not TurnUndeadRulesScript.can_attempt(
			caster,
			combatants,
			{"classicPriestTurningEnabled": false}
		),
		"opcode 82 gate hides the native turn-undead action"
	)
	var disabled: Dictionary = TurnUndeadRulesScript.perform_attempt(
		caster,
		combatants,
		{"classicPriestTurningEnabled": false},
		[100, 100, 100]
	)
	_expect_equal(disabled.get("status"), "unavailable", "disabled turning cannot mutate combat")
	_expect_equal(caster.used_apr, 0, "disabled turning consumes no actions")
	_expect(
		TurnUndeadRulesScript.can_attempt(
			caster,
			combatants,
			{"classicPriestTurningEnabled": true}
		),
		"opcode 83 gate exposes the native turn-undead action"
	)

	var result: Dictionary = TurnUndeadRulesScript.perform_attempt(
		caster,
		combatants,
		{"classicPriestTurningEnabled": true},
		[50, 60, 25]
	)
	_expect_equal(result.get("status"), "ok", "enabled turning performs a native combat action")
	_expect_equal(result.get("attempted"), 3, "turning checks each eligible hostile once")
	_expect_equal(result.get("destroyed"), 1, "turning can destroy a lower-margin success")
	_expect_equal(result.get("turned"), 1, "turning can convert a higher-margin success")
	_expect_equal(result.get("resisted"), 1, "turning preserves failed targets")
	_expect_equal(result.get("bonusExperience"), 150, "turning awards Classic caster experience")
	_expect_equal(destroyed_target.current_hp, 0, "destroyed undead enter normal death handling")
	_expect_equal(turned_target.curFaction, 0, "turned undead join the caster's faction")
	_expect_equal(resisted_target.curFaction, 1, "resisted undead stay hostile")
	_expect_equal(excluded_target.curFaction, 1, "Classic summon sentinel is not turnable")
	_expect_equal(caster.used_apr, 1, "turning consumes one native action")
	_expect(caster.has_turned_undead, "caster records its once-per-battle attempt")
	_expect(
		not TurnUndeadRulesScript.can_attempt(
			caster,
			combatants,
			{"classicPriestTurningEnabled": true}
		),
		"a caster cannot turn undead twice in one battle"
	)


func _test_combat_monster_presence_action() -> void:
	var bundle = _combat_monster_test_bundle()
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("combat:present"), "begin combat-monster check fixture")
	var check: Dictionary = interpreter.run_until_yield()
	_expect_equal(check.get("command"), "check_combat_monster", "opcode 127 yields typed check")
	_expect_equal(check.get("payload", {}).get("monsterNameId"), 12, "combat check preserves name ID")
	_expect(
		not check.get("payload", {}).has("monsterId"),
		"combat name checks do not pretend to reference a Data MD record"
	)
	var continued: Dictionary = interpreter.resume_combat_monster_check(true)
	_expect_equal(continued.get("command"), "show_text", "present monster continues combat macro")
	_expect_equal(continued.get("payload", {}).get("messageId"), 920, "present monster reaches next action")

	interpreter = _interpreter(bundle)
	interpreter.begin_trigger("combat:present")
	interpreter.run_until_yield()
	var stopped: Dictionary = interpreter.resume_combat_monster_check(false)
	_expect_equal(stopped.get("status"), "completed", "absent monster stops combat macro")
	_expect_equal(
		stopped.get("reason"),
		"required-combat-monster-absent",
		"absent-monster completion is explicit"
	)

	var adapter = GodotAdapterScript.new()
	var metadata_creature := CombatTestCreature.new("Imported enemy", 12)
	metadata_creature.classic_monster_id = 134
	metadata_creature.classic_monster_name_id = 12
	var named_creature := CombatTestCreature.new("Rat Demi-Lord 134", 12)
	var dead_creature := CombatTestCreature.new("Rat Demi-Lord 134", 0)
	dead_creature.classic_monster_name_id = 12
	_expect(
		adapter.combat_has_classic_monster(
			{"monsterNameId": 12},
			[CombatTestButton.new(metadata_creature)]
		),
		"combat roster resolves explicit Classic name metadata"
	)
	_expect(
		not adapter.combat_has_classic_monster(
			{"monsterNameId": 12},
			[CombatTestButton.new(named_creature)]
		),
		"record-ID name suffixes do not satisfy a distinct Classic name ID"
	)
	_expect(
		not adapter.combat_has_classic_monster(
			{"monsterNameId": 12},
			[CombatTestButton.new(dead_creature)]
		),
		"combat roster ignores defeated matching monsters"
	)
	_expect(
		adapter.combat_has_classic_monster(
			{"monsterNameId": 12},
			[{"creature": {"classicMonsterNameId": 12, "curHP": 1}}]
		),
		"combat roster accepts converted dictionary metadata"
	)
	_expect(
		not adapter.combat_has_classic_monster({}, [CombatTestButton.new(metadata_creature)]),
		"combat name checks reject a missing identity"
	)


func _test_combat_monster_destruction_action() -> void:
	var bundle = _combat_monster_test_bundle()
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("combat:destroy"), "begin combat-monster destruction fixture")
	var command: Dictionary = interpreter.run_until_yield()
	_expect_equal(command.get("command"), "destroy_combat_monsters", "opcode 125 yields typed mutation")
	_expect_equal(command.get("payload", {}).get("monsterNameId"), 12, "destruction preserves name ID")
	_expect_equal(command.get("payload", {}).get("maxMatches"), 100, "zero destruction limit becomes 100")
	_expect(
		not bool(command.get("payload", {}).get("includeAllFactions")),
		"default destruction targets hostile monsters"
	)
	_expect_equal(
		interpreter.run_until_yield().get("payload", {}).get("messageId"),
		921,
		"destruction command continues to the next combat action"
	)

	var adapter = GodotAdapterScript.new()
	var enemy_one_creature := CombatTestCreature.new("Rat Demi-Lord 134", 10)
	enemy_one_creature.classic_monster_name_id = 12
	enemy_one_creature.set_meta("classic_death_macro", 960)
	var enemy_one := CombatTestButton.new(enemy_one_creature)
	var enemy_two_creature := CombatTestCreature.new("Rat Demi-Lord 134", 10)
	enemy_two_creature.classic_monster_name_id = 12
	enemy_two_creature.set_meta("classic_death_macro", 960)
	var enemy_two := CombatTestButton.new(enemy_two_creature)
	var ally_creature := CombatTestCreature.new("Rat Demi-Lord 134", 10, 0)
	ally_creature.classic_monster_name_id = 12
	ally_creature.set_meta("classic_death_macro", 960)
	var ally := CombatTestButton.new(ally_creature)
	var other := CombatTestButton.new(CombatTestCreature.new("Podling 42", 10))
	var defeated_creature := CombatTestCreature.new("Rat Demi-Lord 134", 0)
	defeated_creature.classic_monster_name_id = 12
	var defeated := CombatTestButton.new(defeated_creature)
	var roster := [enemy_one, enemy_two, ally, other, defeated]
	var limited: Array = adapter.select_classic_combatants(
		{"monsterNameId": 12, "maxMatches": 1, "includeAllFactions": false},
		roster
	)
	_expect_equal(limited, [enemy_one], "destruction honors its match limit")
	var hostile_only: Array = adapter.select_classic_combatants(
		{"monsterNameId": 12, "maxMatches": 100, "includeAllFactions": false},
		roster
	)
	_expect_equal(hostile_only, [enemy_one, enemy_two], "destruction defaults to hostile matches")
	var all_factions: Array = adapter.select_classic_combatants(
		{"monsterNameId": 12, "maxMatches": 100, "includeAllFactions": true},
		roster
	)
	_expect_equal(all_factions, [enemy_one, enemy_two, ally], "destruction can include allied matches")
	var combat_state := CombatTestState.new(roster)
	_expect_equal(
		adapter.remove_classic_combatants(combat_state, all_factions),
		3,
		"combat adapter removes every selected match"
	)
	_expect_equal(combat_state.all_battle_creatures_btns.size(), 2, "removed matches leave the live roster")
	_expect_equal(combat_state.battle_creatures_yet_to_act_btns.size(), 2, "removed matches leave initiative")
	_expect_equal(combat_state.battle_dead_enemies.size(), 2, "only hostile removals enter battle rewards")
	_expect_equal(
		combat_state.queued_death_creatures,
		[enemy_one_creature, enemy_two_creature, ally_creature],
		"Classic removals queue each affected death macro"
	)


func _test_lower_undead_deanimation_action() -> void:
	var bundle = _combat_monster_test_bundle()
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("combat:deanimate"), "begin lower-undead deanimation fixture")
	var command: Dictionary = interpreter.run_until_yield()
	_expect_equal(command.get("command"), "deanimate_lower_undead", "opcode 121 yields typed mutation")
	_expect_equal(command.get("payload", {}).get("extraCodeId"), 0, "deanimation preserves Extra Code ID")
	_expect_equal(command.get("payload", {}).get("monsterIds"), [17, 78], "deanimation selects lower undead IDs")
	_expect_equal(
		interpreter.run_until_yield().get("payload", {}).get("messageId"),
		922,
		"deanimation command continues to the next combat action"
	)

	var adapter = GodotAdapterScript.new()
	var lower_enemy := CombatTestButton.new(CombatTestCreature.new("Skeletal Beast 17", 10))
	var lower_ally := CombatTestButton.new(CombatTestCreature.new("Zombie 78", 10, 0))
	var higher_undead := CombatTestButton.new(CombatTestCreature.new("Skeletal Giant 19", 10))
	var living_creature := CombatTestButton.new(CombatTestCreature.new("Podling 42", 10))
	var defeated_lower := CombatTestButton.new(CombatTestCreature.new("Skeletal Beast 17", 0))
	var roster := [lower_enemy, lower_ally, higher_undead, living_creature, defeated_lower]
	var selected: Array = adapter.select_classic_combatants_by_ids([17, 78], roster)
	_expect_equal(selected, [lower_enemy, lower_ally], "deanimation ignores higher and defeated undead")
	var combat_state := CombatTestState.new(roster)
	_expect_equal(
		adapter.remove_classic_combatants(combat_state, selected),
		2,
		"deanimation removes lower undead from every faction"
	)
	_expect_equal(combat_state.battle_dead_enemies, [lower_enemy.creature], "only hostile undead enter rewards")


func _test_combat_monster_rout_action() -> void:
	var bundle = _combat_monster_test_bundle()
	var interpreter = _interpreter(bundle)
	_expect(
		interpreter.begin_trigger("combat:rout", 0, {"actorFaction": 1}),
		"begin combat-monster rout fixture"
	)
	var command: Dictionary = interpreter.run_until_yield()
	_expect_equal(command.get("command"), "rout_combat_monsters", "opcode 123 yields typed mutation")
	_expect_equal(command.get("payload", {}).get("extraCodeId"), 2, "rout preserves Extra Code ID")
	_expect_equal(command.get("payload", {}).get("monsterIds"), [134, 42], "rout preserves monster IDs")
	_expect(bool(command.get("payload", {}).get("sameFactionAsActor")), "rout preserves faction rule")
	_expect(bool(command.get("payload", {}).get("permanent")), "rout preserves permanent duration")
	_expect_equal(command.get("payload", {}).get("surrenderPercent"), 50, "rout preserves surrender value")
	_expect_equal(command.get("payload", {}).get("actorFaction"), 1, "rout relays queued actor faction")
	_expect_equal(
		interpreter.run_until_yield().get("payload", {}).get("messageId"),
		924,
		"rout command continues to the next combat action"
	)

	var adapter = GodotAdapterScript.new()
	var matching_enemy := CombatTestButton.new(CombatTestCreature.new("Rat Demi-Lord 134", 10, 1))
	var second_enemy := CombatTestButton.new(CombatTestCreature.new("Podling 42", 10, 1))
	var matching_ally := CombatTestButton.new(CombatTestCreature.new("Rat Demi-Lord 134", 10, 0))
	var defeated_enemy := CombatTestButton.new(CombatTestCreature.new("Podling 42", 0, 1))
	var other_enemy := CombatTestButton.new(CombatTestCreature.new("Skeletal Beast 17", 10, 1))
	var roster := [matching_enemy, second_enemy, matching_ally, defeated_enemy, other_enemy]
	var selected: Array = adapter.select_classic_combatants_by_ids_and_faction([134, 42], 1, roster)
	_expect_equal(selected, [matching_enemy, second_enemy], "rout selects living IDs on the actor faction")
	_expect_equal(
		adapter.PERMANENT_FLEEING_TRAIT_PATH,
		"res://shared_assets/traits/p_fleeing.gd",
		"rout maps to Remake's permanent fleeing trait"
	)
	_expect_equal(
		adapter.apply_classic_rout(selected, GodotAdapterScript),
		2,
		"rout applies native fleeing to every match"
	)
	for combatant: Variant in selected:
		_expect_equal(combatant.creature.applied_traits.size(), 1, "routed creature receives one trait")
		_expect(CombatRoutRulesScript.is_routed(combatant.creature), "rout marks Classic exit behavior")
		_expect_equal(
			str(combatant.creature.applied_traits[0]["script"].resource_path),
			"res://scripts/classic_runtime/classic_godot_command_adapter.gd",
			"rout applies the supplied trait script"
		)
	matching_enemy.creature.position = Vector2(1, 45)
	second_enemy.creature.position = Vector2(2, 45)
	_expect(
		CombatRoutRulesScript.mark_exit_if_at_edge(matching_enemy.creature, Vector2i(90, 90)),
		"a routed enemy resolves at the Classic battlefield edge"
	)
	_expect(matching_enemy.creature.please_remove_from_combat, "routed edge exit queues native removal")
	_expect(
		not CombatRoutRulesScript.mark_exit_if_at_edge(second_enemy.creature, Vector2i(90, 90)),
		"a routed enemy inside the edge remains in combat"
	)
	var routed_state := CombatTestState.new([matching_enemy, second_enemy, matching_ally])
	_expect_equal(
		BattleRemovalRulesScript.remove_combatant(routed_state, matching_enemy),
		"enemy",
		"a routed hostile remains eligible for battle rewards"
	)
	_expect(
		not routed_state.all_battle_creatures_btns.has(matching_enemy),
		"a routed edge exit leaves the live roster"
	)
	_expect(
		not routed_state.battle_creatures_yet_to_act_btns.has(matching_enemy),
		"a routed edge exit leaves initiative"
	)
	CombatRoutRulesScript.mark_routed(matching_ally.creature)
	matching_ally.creature.position = Vector2(88, 45)
	matching_ally.creature.set_meta("classic_can_summon", -1)
	_expect(
		not CombatRoutRulesScript.mark_exit_if_at_edge(
			matching_ally.creature,
			Vector2i(90, 90)
		),
		"Classic's ally sentinel prevents a routed battlefield exit"
	)
	matching_ally.creature.set_meta("classic_can_summon", 0)
	_expect(
		CombatRoutRulesScript.mark_exit_if_at_edge(matching_ally.creature, Vector2i(90, 90)),
		"a routed ally also leaves the live roster at the edge"
	)
	_expect_equal(
		BattleRemovalRulesScript.remove_combatant(routed_state, matching_ally),
		"ally",
		"a routed ally is not classified as a battle reward"
	)
	_expect_equal(
		routed_state.battle_dead_enemies,
		[matching_enemy.creature],
		"only the routed hostile enters rewards"
	)
	_expect(
		routed_state.battle_dead_party_members.is_empty(),
		"a living routed ally is not a party defeat"
	)


func _test_combat_monster_spawn_action() -> void:
	var bundle = _combat_monster_test_bundle()
	var interpreter = _interpreter(bundle)
	_expect(
		interpreter.begin_trigger(
			"combat:spawn",
			0,
			{"actorFaction": 3, "actorPosition": Vector2(8, 9), "battleMacro": 0}
		),
		"begin combat-monster spawn fixture"
	)
	var command: Dictionary = interpreter.run_until_yield()
	_expect_equal(command.get("command"), "spawn_combat_monsters", "opcode 124 yields typed spawn")
	var payload: Dictionary = command.get("payload", {})
	_expect_equal(payload.get("monsterId"), 92, "spawn preserves monster ID")
	_expect_equal(payload.get("spawnCount"), 2, "positive spawn count is exact")
	_expect_equal(payload.get("soundId"), 640, "spawn preserves per-creature sound")
	_expect(bool(payload.get("inheritActorFaction")), "direct combat macro inherits actor faction")
	_expect_equal(payload.get("actorFaction"), 3, "spawn relays queued actor faction")
	_expect_equal(payload.get("actorPosition"), Vector2(8, 9), "spawn relays queued actor position")
	_expect_equal(
		interpreter.run_until_yield().get("payload", {}).get("messageId"),
		928,
		"spawn command continues to the next combat action"
	)

	interpreter = _interpreter(bundle)
	interpreter.begin_trigger("combat:spawn-random", 0, {"battleMacro": -118})
	var random_spawn: Dictionary = interpreter.run_until_yield()
	_expect_equal(random_spawn.get("payload", {}).get("authoredCount"), -1, "random spawn keeps signed count")
	_expect_equal(random_spawn.get("payload", {}).get("spawnCount"), 1, "singleton random spawn is stable")
	_expect(
		not bool(random_spawn.get("payload", {}).get("inheritActorFaction")),
		"battle-round spawn keeps its monster template faction"
	)

	interpreter = _interpreter(bundle)
	interpreter.begin_trigger("combat:spawn-explicit")
	var explicit_spawn: Dictionary = interpreter.run_until_yield()
	_expect_equal(explicit_spawn.get("payload", {}).get("factionOverride"), 2, "spawn keeps explicit faction")
	_expect(
		not bool(explicit_spawn.get("payload", {}).get("inheritActorFaction")),
		"explicit spawn faction takes precedence"
	)

	interpreter = _interpreter(bundle)
	interpreter.begin_trigger("combat:spawn-zero")
	_expect_equal(
		interpreter.run_until_yield().get("command"),
		"show_text",
		"zero-count spawn continues without requiring a monster record"
	)

	var adapter = GodotAdapterScript.new()
	var creature_book := {"Goblin 92": {"data": {"name": "Goblin"}}}
	var combat_state := CombatTestState.new([])
	var map := SpawnTestMap.new()
	var spawn_result: Dictionary = adapter.spawn_classic_combatants(
		payload,
		combat_state,
		map,
		creature_book,
		SpawnTestCreature,
		SpawnTestScene.new(),
		Vector2(8, 9),
		3
	)
	_expect_equal(spawn_result.get("spawned"), 2, "combat adapter creates requested monsters")
	_expect_equal(combat_state.all_battle_creatures_btns.size(), 2, "spawn extends live roster")
	_expect_equal(combat_state.battle_creatures_yet_to_act_btns.size(), 2, "spawn extends initiative")
	_expect_equal(map.creatures_node.children.size(), 2, "spawn adds native combat buttons to map")
	for spawned_value: Variant in spawn_result.get("combatants", []):
		var spawned: Variant = spawned_value.creature
		_expect_equal(spawned.initialized_name, "Goblin 92", "spawn resolves native bestiary entry")
		_expect_equal(spawned.get_meta("classic_monster_id"), 92, "spawn records Classic identity")
		_expect_equal(spawned.get_meta("classic_death_macro"), 960, "spawn records death macro")
		_expect_equal(spawned.classic_monster_id, 92, "spawn preserves Classic record identity")
		_expect_equal(spawned.classic_monster_name_id, 7, "spawn preserves Classic name identity")
		_expect_equal(spawned.curFaction, 3, "spawn inherits actor faction")
		_expect(not spawned_value.bgsprite.visible, "spawn hides native selection background")
	_expect_equal(
		combat_state.placement_origins,
		[Vector2(8, 9), Vector2(8, 9)],
		"each spawn searches outward from the macro actor"
	)

	var template_payload := payload.duplicate(true)
	template_payload["spawnCount"] = 1
	template_payload["inheritActorFaction"] = false
	var template_state := CombatTestState.new([])
	var template_result: Dictionary = adapter.spawn_classic_combatants(
		template_payload,
		template_state,
		SpawnTestMap.new(),
		creature_book,
		SpawnTestCreature,
		SpawnTestScene.new(),
		Vector2.ZERO
	)
	_expect_equal(
		template_result.get("combatants", [])[0].creature.curFaction,
		4,
		"battle macro preserves template faction"
	)

	var explicit_payload := template_payload.duplicate(true)
	explicit_payload["factionOverride"] = 2
	var explicit_result: Dictionary = adapter.spawn_classic_combatants(
		explicit_payload,
		CombatTestState.new([]),
		SpawnTestMap.new(),
		creature_book,
		SpawnTestCreature,
		SpawnTestScene.new(),
		Vector2.ZERO
	)
	_expect_equal(
		explicit_result.get("combatants", [])[0].creature.curFaction,
		2,
		"explicit spawn faction replaces template faction"
	)

	var crowded: Array = []
	for existing_index: int in range(99):
		crowded.append(SpawnTestButton.new())
		crowded[-1].set_creature_represented(SpawnTestCreature.new())
	var crowded_state := CombatTestState.new(crowded)
	var limited_result: Dictionary = adapter.spawn_classic_combatants(
		payload,
		crowded_state,
		SpawnTestMap.new(),
		creature_book,
		SpawnTestCreature,
		SpawnTestScene.new(),
		Vector2.ZERO,
		1
	)
	_expect_equal(limited_result.get("spawned"), 1, "spawn respects Classic's 100-monster limit")
	_expect(bool(limited_result.get("capacityLimited")), "spawn reports capacity truncation")
	_expect_equal(limited_result.get("slotsUsed"), 100, "spawn records the allocated Classic slots")

	var party_member := SpawnTestCreature.new()
	party_member.is_player_controlled = true
	var party_button := SpawnTestButton.new()
	party_button.set_creature_represented(party_member)
	_expect_equal(
		adapter.classic_combat_monster_count([party_button]),
		0,
		"party members do not consume Classic monster slots"
	)
	crowded_state.all_battle_creatures_btns = [party_button]
	crowded_state.battle_creatures_yet_to_act_btns = [party_button]
	var exhausted_result: Dictionary = adapter.spawn_classic_combatants(
		template_payload,
		crowded_state,
		SpawnTestMap.new(),
		creature_book,
		SpawnTestCreature,
		SpawnTestScene.new(),
		Vector2.ZERO
	)
	_expect_equal(
		exhausted_result.get("spawned"),
		0,
		"removed monsters do not reopen Classic spawn slots"
	)
	_expect_equal(
		crowded_state.all_battle_creatures_btns,
		[party_button],
		"capacity rejection leaves the party roster unchanged"
	)


func _test_native_combat_command_host() -> void:
	var rat := CombatTestCreature.new("Rat Demi-Lord 134", 10, 1)
	rat.classic_monster_id = 134
	rat.classic_monster_name_id = 12
	rat.set_meta("classic_death_macro", 960)
	var podling := CombatTestCreature.new("Podling 42", 10, 1)
	podling.classic_monster_id = 42
	var skeletal_beast := CombatTestCreature.new("Skeletal Beast 17", 10, 1)
	skeletal_beast.classic_monster_id = 17
	var zombie := CombatTestCreature.new("Zombie 78", 10, 0)
	zombie.classic_monster_id = 78
	var skeletal_giant := CombatTestCreature.new("Skeletal Giant 19", 10, 1)
	skeletal_giant.classic_monster_id = 19
	var roster := [
		CombatTestButton.new(rat),
		CombatTestButton.new(podling),
		CombatTestButton.new(skeletal_beast),
		CombatTestButton.new(zombie),
		CombatTestButton.new(skeletal_giant),
	]
	var combat_state := CombatTestState.new(roster)
	var state_machine := CombatIntegrationStateMachine.new(combat_state)
	var native_map := SpawnTestMap.new()
	var resources := CombatIntegrationResources.new({
		"Goblin 92": {"data": {"name": "Goblin"}},
	})
	var node_access := CombatIntegrationNodeAccess.new(resources, native_map)
	var game_global := CombatIntegrationGameGlobal.new(SpawnTestCreature)
	var adapter = CombatIntegrationAdapterScript.new()
	var bundle = _combat_monster_test_bundle()
	adapter.configure_classic_bundle(bundle)
	adapter.configure_test_dependencies(
		{
			"StateMachine": state_machine,
			"NodeAccess": node_access,
			"GameGlobal": game_global,
		},
		SpawnTestScene.new()
	)
	var host = HostScript.new()
	get_root().add_child(host)
	host.configure(adapter)
	var runtime_state = StateScript.new()
	runtime_state.configure_from_bundle(bundle)
	host.runtime.use_shared_campaign(bundle, runtime_state)

	var commands: Array = []
	var responses: Array = []
	host.command_started.connect(
		func(command: String, payload: Dictionary) -> void:
			commands.append({"command": command, "payload": payload})
	)
	host.command_finished.connect(
		func(command: String, response: Dictionary) -> void:
			responses.append({"command": command, "response": response})
	)

	var result: Dictionary = await host.run_trigger("combat:present")
	_expect_equal(result.get("status"), "completed", "native presence macro completes through host")
	_expect_equal(
		commands.map(func(entry: Dictionary) -> String: return entry["command"]),
		["check_combat_monster", "show_text"],
		"native presence result resumes the combat macro"
	)
	_expect(bool(responses[0]["response"].get("present")), "native roster reports matching monster")

	commands.clear()
	responses.clear()
	result = await host.run_trigger("combat:rout", 0, {"actorFaction": 1})
	_expect_equal(result.get("status"), "completed", "native rout macro completes through host")
	_expect_equal(responses[0]["response"].get("routed"), 2, "native rout affects matching faction")
	_expect_equal(rat.applied_traits.size(), 1, "native rout marks first matching creature")
	_expect_equal(podling.applied_traits.size(), 1, "native rout marks second matching creature")

	commands.clear()
	responses.clear()
	result = await host.run_trigger(
		"combat:spawn",
		0,
		{"actorFaction": 3, "actorPosition": Vector2(8, 9), "battleMacro": 0}
	)
	_expect_equal(result.get("status"), "completed", "native spawn macro completes through host")
	_expect_equal(responses[0]["response"].get("spawned"), 2, "native spawn extends live roster")
	_expect_equal(native_map.creatures_node.children.size(), 2, "native spawn adds combat buttons")
	_expect_equal(adapter.played_sounds, [640, 640], "native spawn plays one sound per creature")
	for spawned_button: Variant in responses[0]["response"].get("combatants", []):
		_expect_equal(spawned_button.creature.curFaction, 3, "native spawn inherits macro actor faction")

	commands.clear()
	responses.clear()
	result = await host.run_trigger("combat:destroy")
	_expect_equal(result.get("status"), "completed", "native destruction macro completes through host")
	_expect_equal(responses[0]["response"].get("removed"), 1, "native destruction removes matching enemy")
	_expect_equal(combat_state.queued_death_creatures, [rat], "native destruction queues its death macro")

	commands.clear()
	responses.clear()
	result = await host.run_trigger("combat:present")
	_expect_equal(
		result.get("reason"),
		"required-combat-monster-absent",
		"native absence stops the combat macro"
	)
	_expect_equal(
		commands.map(func(entry: Dictionary) -> String: return entry["command"]),
		["check_combat_monster"],
		"native absence does not run the next combat action"
	)

	commands.clear()
	responses.clear()
	result = await host.run_trigger("combat:deanimate")
	_expect_equal(result.get("status"), "completed", "native deanimation macro completes through host")
	_expect_equal(responses[0]["response"].get("removed"), 2, "native deanimation removes lower undead")
	_expect(combat_state.all_battle_creatures_btns.has(roster[4]), "native deanimation keeps higher undead")
	_expect_equal(
		adapter.shown_messages,
		[920, 924, 928, 921, 922],
		"native combat commands resume each authored follow-up once"
	)

	commands.clear()
	responses.clear()
	result = await host.run_trigger("combat:end")
	_expect_equal(result.get("reason"), "battle-ended", "native forced victory completes its macro")
	_expect_equal(
		game_global.battle_end_calls,
		[{"outcome": "won", "rewardMode": "experience_only"}],
		"native forced victory requests experience-only battle cleanup"
	)
	_expect_equal(adapter._take_forced_battle_resume_slot(), 8, "native forced victory records slot 8")
	_expect_equal(
		commands.map(func(entry: Dictionary) -> String: return entry["command"]),
		["end_classic_battle"],
		"native forced victory runs no later macro action"
	)
	host.queue_free()


func _test_battle_round_macro_action() -> void:
	var bundle = _combat_monster_test_bundle()
	var interpreter = _interpreter(bundle)
	_expect(
		interpreter.begin_trigger("combat:round", 0, {"combatRound": 3, "battleMacro": -118}),
		"begin exact-round battle macro fixture"
	)
	var activation: Dictionary = interpreter.run_until_yield()
	_expect_equal(
		activation.get("command"),
		"activate_battle_round_macro",
		"opcode 126 yields typed activation"
	)
	_expect_equal(activation.get("payload", {}).get("roundIndex"), 2, "battle macro uses elapsed rounds")
	_expect_equal(activation.get("payload", {}).get("targetMacroId"), 950, "battle macro selects target")
	_expect(bool(activation.get("payload", {}).get("disableSchedule")), "one-shot macro disables schedule")
	var target_result: Dictionary = interpreter.resume_battle_round_macro()
	_expect_equal(target_result.get("command"), "show_text", "battle macro enters its target action point")
	_expect_equal(target_result.get("payload", {}).get("messageId"), 925, "battle macro runs selected target")

	interpreter = _interpreter(bundle)
	interpreter.begin_trigger("combat:round", 0, {"combatRound": 2, "battleMacro": -118})
	var wrong_round: Dictionary = interpreter.run_until_yield()
	_expect_equal(wrong_round.get("status"), "completed", "exact-round macro skips other rounds")
	_expect_equal(wrong_round.get("reason"), "battle-round-macro-skipped", "round skip is explicit")

	interpreter = _interpreter(bundle)
	interpreter.set_percent_roll_provider(func() -> int: return 25)
	interpreter.begin_trigger("combat:chance", 0, {"combatRound": 4, "battleMacro": -119})
	var chance_activation: Dictionary = interpreter.run_until_yield()
	_expect_equal(chance_activation.get("payload", {}).get("chanceRoll"), 25, "chance macro uses inclusive roll")
	_expect(bool(chance_activation.get("payload", {}).get("repeat")), "repeating chance macro stays scheduled")
	_expect(
		not bool(chance_activation.get("payload", {}).get("disableSchedule")),
		"repeating macro preserves schedule"
	)
	_expect_equal(
		interpreter.resume_battle_round_macro().get("payload", {}).get("messageId"),
		926,
		"successful chance macro runs its target"
	)

	interpreter = _interpreter(bundle)
	interpreter.set_percent_roll_provider(func() -> int: return 26)
	interpreter.begin_trigger("combat:chance", 0, {"combatRound": 4, "battleMacro": -119})
	_expect_equal(
		interpreter.run_until_yield().get("reason"),
		"battle-round-macro-skipped",
		"chance macro skips rolls above its threshold"
	)

	interpreter = _interpreter(bundle)
	interpreter.begin_trigger("combat:random", 0, {"combatRound": 2, "battleMacro": -120})
	var random_activation: Dictionary = interpreter.run_until_yield()
	_expect(bool(random_activation.get("payload", {}).get("randomTarget")), "mode two selects a random macro")
	_expect_equal(random_activation.get("payload", {}).get("targetMacroId"), 952, "singleton range is stable")
	_expect_equal(
		interpreter.resume_battle_round_macro().get("payload", {}).get("messageId"),
		927,
		"random battle macro runs its selected target"
	)

	interpreter = _interpreter(bundle)
	interpreter.begin_trigger("combat:round", 0, {"combatRound": 3, "battleMacro": 118})
	_expect_equal(
		interpreter.run_until_yield().get("reason"),
		"legacy-battle-macro-disabled",
		"positive legacy battle macro is ignored"
	)
	interpreter = _interpreter(bundle)
	interpreter.begin_trigger("combat:round")
	_expect_equal(
		interpreter.run_until_yield().get("status"),
		"error",
		"battle macro stops without round context"
	)
	interpreter = _interpreter(bundle)
	interpreter.begin_trigger("combat:round", 0, {"combatRound": 0})
	_expect_equal(
		interpreter.run_until_yield().get("status"),
		"error",
		"battle macro rejects a zero-based round context"
	)

	var adapter = GodotAdapterScript.new()
	var battle_data := {"battleMacro": -119}
	_expect(adapter.apply_battle_round_macro_schedule(battle_data, false), "repeat schedule is accepted")
	_expect_equal(battle_data.get("battleMacro"), -119, "repeat schedule remains active")
	_expect(adapter.apply_battle_round_macro_schedule(battle_data, true), "one-shot schedule is accepted")
	_expect_equal(battle_data.get("battleMacro"), 0, "one-shot schedule is disabled")


func _test_classic_combat_macro_queue() -> void:
	var creature := CombatTestCreature.new("Queued Beast", 0, 3)
	creature.position = Vector2(8, 9)
	creature.set_meta("classic_death_macro", 960)
	creature.set_meta("classic_monster_id", 42)
	creature.set_meta("classic_monster_name_id", 7)
	var entry: Dictionary = CombatMacroQueueScript.death_macro_entry(creature)
	_expect_equal(entry.get("triggerId"), "Data ED3:macro:960", "death macro resolves ED3 trigger")
	var context: Dictionary = entry.get("context", {})
	_expect(bool(context.get("queuedMacro", false)), "death macro records queued execution")
	_expect_equal(context.get("actorPosition"), Vector2(8, 9), "death macro records actor position")
	_expect_equal(context.get("actorFaction"), 3, "death macro records actor faction")
	_expect_equal(context.get("actorMonsterId"), 42, "death macro records monster identity")
	_expect_equal(context.get("actorMonsterNameId"), 7, "death macro records name identity")
	var queue: Array = []
	_expect(CombatMacroQueueScript.enqueue_death_macro(queue, creature), "death macro enters queue")
	_expect_equal(queue, [entry], "death macro queue preserves its entry")
	creature.set_meta("classic_death_macro", 0)
	_expect(
		not CombatMacroQueueScript.enqueue_death_macro(queue, creature),
		"monster without death macro does not enter queue"
	)


func _test_native_battle_round_host() -> void:
	var bundle = _combat_monster_test_bundle()
	_add_stack_trigger(bundle, "Data ED3:macro:118", 118, [
		_classic_action(0, 126, 3),
	])
	var state = StateScript.new()
	state.configure_from_bundle(bundle)
	var adapter = BattleRoundHostAdapter.new(self)
	var host = HostScript.new()
	get_root().add_child(host)
	host.configure(adapter)
	host.runtime.use_shared_campaign(bundle, state)
	host.active = true
	host.command_context = {"outerMarker": "suspended-battle"}

	var opening_round: Variant = await host.run_battle_round_macro(
		{"battleMacro": -118},
		1
	)
	_expect(opening_round is Dictionary, "opening-round dispatch returns immediately")
	_expect(
		not bool(opening_round.get("handled", true)),
		"opening round does not run the schedule"
	)
	var disabled: Variant = await host.run_battle_round_macro({"battleMacro": 118}, 3)
	_expect(disabled is Dictionary, "disabled battle macro dispatch returns immediately")
	_expect(not bool(disabled.get("handled", true)), "positive battle macro remains disabled")

	var dispatch: Variant = await host.run_battle_round_macro(
		{"battleMacro": -118},
		3,
		{"actorPosition": Vector2(8, 9), "actorFaction": 3}
	)
	_expect(dispatch is Dictionary, "native battle-round dispatch completes")
	_expect(bool(dispatch.get("handled", false)), "native battle-round schedule is handled")
	_expect_equal(
		dispatch.get("triggerId"),
		"Data ED3:macro:118",
		"battle schedule resolves ED3 trigger"
	)
	_expect_equal(
		dispatch.get("result", {}).get("status"),
		"completed",
		"nested battle macro completes"
	)
	_expect_equal(
		adapter.commands.size(),
		2,
		"nested battle macro drives its activation and target"
	)
	_expect_equal(
		adapter.commands[0].get("command"),
		"activate_battle_round_macro",
		"host evaluates opcode 126"
	)
	_expect_equal(
		adapter.commands[0].get("payload", {}).get("combatRound"),
		3,
		"host supplies one-based round"
	)
	_expect_equal(
		adapter.commands[0].get("payload", {}).get("battleMacro"),
		-118,
		"host supplies schedule identity"
	)
	_expect_equal(
		adapter.commands[0].get("payload", {}).get("actorPosition"),
		Vector2(8, 9),
		"host supplies actor position"
	)
	_expect_equal(
		adapter.commands[0].get("payload", {}).get("actorFaction"),
		3,
		"host supplies actor faction"
	)
	_expect_equal(
		adapter.commands[1].get("payload", {}).get("messageId"),
		925,
		"host runs scheduled target"
	)
	_expect(host.active, "nested battle macro preserves the suspended outer action point")
	_expect_equal(
		host.command_context.get("outerMarker"),
		"suspended-battle",
		"outer command context is preserved"
	)
	_expect(not host.nested_trigger_active, "nested battle macro releases its execution guard")
	host.active = false
	host.command_context.clear()
	host.queue_free()


func _test_queued_combat_macro_host() -> void:
	var bundle = _combat_monster_test_bundle()
	bundle.messages_by_id[929] = {"id": 929, "text": "The nested macro returns."}
	bundle.messages_by_id[930] = {"id": 930, "text": "The nested macro runs."}
	_add_stack_trigger(bundle, "Data ED3:macro:970", 970, [
		_classic_action(0, -46, 10),
		_classic_action(1, 1, 929),
	])
	_add_stack_trigger(bundle, "Data ED3:macro:971", 971, [
		_classic_action(0, 1, 930),
		_classic_action(1, 111, 0),
	])
	_add_stack_branch(bundle, 10, 971)
	var state = StateScript.new()
	state.configure_from_bundle(bundle)
	var adapter = BattleRoundHostAdapter.new(self)
	var host = HostScript.new()
	get_root().add_child(host)
	host.configure(adapter)
	host.runtime.use_shared_campaign(bundle, state)
	host.active = true
	host.command_context = {"outerMarker": "suspended-battle"}
	var creature := CombatTestCreature.new("Queued Beast", 0, 3)
	creature.position = Vector2(8, 9)
	creature.set_meta("classic_death_macro", 960)
	var dispatch: Dictionary = await host.run_queued_combat_macro(
		CombatMacroQueueScript.death_macro_entry(creature),
		{"combatRound": 4, "battleMacro": -118}
	)
	_expect(bool(dispatch.get("handled", false)), "queued combat macro is handled")
	_expect_equal(dispatch.get("triggerId"), "Data ED3:macro:960", "queued macro resolves ED3 trigger")
	_expect_equal(dispatch.get("result", {}).get("status"), "completed", "queued macro completes")
	_expect_equal(adapter.commands.size(), 1, "queued macro drives its target action point")
	var payload: Dictionary = adapter.commands[0].get("payload", {})
	_expect_equal(payload.get("messageId"), 928, "queued macro runs its target")
	_expect_equal(payload.get("combatRound"), 4, "queued macro receives one-based round")
	_expect_equal(payload.get("battleMacro"), -118, "queued macro receives battle schedule")
	_expect(bool(payload.get("queuedMacro", false)), "queued macro receives queued state")
	_expect_equal(payload.get("actorPosition"), Vector2(8, 9), "queued macro receives actor position")
	_expect_equal(payload.get("actorFaction"), 3, "queued macro receives actor faction")
	_expect(host.active, "queued macro preserves the suspended outer action point")
	_expect_equal(
		host.command_context.get("outerMarker"),
		"suspended-battle",
		"queued macro preserves outer command context"
	)

	adapter.commands.clear()
	var stack_dispatch: Dictionary = await host.run_queued_combat_macro(
		{"triggerId": "Data ED3:macro:970", "context": {"queuedMacro": true}},
		{"combatRound": 4, "battleMacro": -118}
	)
	_expect_equal(
		stack_dispatch.get("result", {}).get("status"),
		"completed",
		"queued combat XAP chain completes"
	)
	_expect_equal(
		adapter.commands.map(
			func(entry: Dictionary) -> int: return int(entry.get("payload", {}).get("messageId", 0))
		),
		[930, 929],
		"queued combat XAP returns to its caller"
	)
	_expect(host.active, "queued combat XAP leaves the suspended outer host active")
	host.active = false
	host.command_context.clear()
	host.queue_free()


func _test_forced_battle_end_action() -> void:
	var bundle = _combat_monster_test_bundle()
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("combat:end"), "begin forced battle-end fixture")
	var command: Dictionary = interpreter.run_until_yield()
	_expect_equal(command.get("command"), "end_classic_battle", "opcode 100 yields typed battle end")
	_expect_equal(command.get("payload", {}).get("outcome"), "won", "forced battle end reports victory")
	_expect_equal(command.get("payload", {}).get("lootMode"), 5, "forced battle end preserves loot mode")
	_expect_equal(
		command.get("payload", {}).get("rewardMode"),
		"experience_only",
		"forced battle end requests experience-only rewards"
	)
	_expect_equal(command.get("payload", {}).get("resumeSlot"), 8, "forced battle end preserves resume slot")
	var completed: Dictionary = interpreter.resume_forced_battle_end()
	_expect_equal(completed.get("status"), "completed", "forced battle end completes the combat macro")
	_expect_equal(completed.get("reason"), "battle-ended", "forced battle completion is explicit")

	var defeated := [
		{"experience": 40, "money": [3, 2, 1], "inventory": ["Test blade"]},
		{"experience": 15, "money": [4, 0, 0], "inventory": ["Test shield"]},
	]
	var normal_rewards: Dictionary = BattleRewardRulesScript.collect(defeated)
	_expect_equal(normal_rewards.get("experience"), 55, "normal battle rewards retain experience")
	_expect_equal(normal_rewards.get("money"), [7, 2, 1], "normal battle rewards retain money")
	_expect_equal(
		normal_rewards.get("treasure"),
		["Test blade", "Test shield"],
		"normal battle rewards retain inventory"
	)
	var separated_weapon_rewards: Dictionary = BattleRewardRulesScript.collect([{
		"experience": 0,
		"money": [0, 0, 0],
		"inventory": [
			{"name": "Quarter Staff +1"},
			{"name": "Quarter Staff", "drops_on_defeat": false},
		],
	}])
	_expect_equal(
		separated_weapon_rewards.get("treasure"),
		[{"name": "Quarter Staff +1"}],
		"battle rewards omit an active weapon outside Classic's carried slots"
	)
	var native_resources = NativeResourcesScript.new()
	var restored_active_weapon: Dictionary = native_resources.generate_item_from_json_dict({
		"imgdata": "",
		"imgdatasize": 0,
		"name": "Quarter Staff",
		"type": "Melee Weapon",
		"sound": "",
		"drops_on_defeat": false,
	})
	_expect_equal(
		restored_active_weapon.get("drops_on_defeat"),
		false,
		"item reconstruction preserves the Classic defeat-loot boundary"
	)
	native_resources.free()
	var experience_rewards: Dictionary = BattleRewardRulesScript.collect(defeated, true)
	_expect_equal(experience_rewards.get("experience"), 55, "experience-only rewards retain experience")
	_expect_equal(experience_rewards.get("money"), [0, 0, 0], "experience-only rewards omit money")
	_expect_equal(experience_rewards.get("treasure"), [], "experience-only rewards omit inventory")

	var adapter = GodotAdapterScript.new()
	_expect(
		not adapter._record_forced_battle_resume_slot(7),
		"forced battle rejects a nonterminal resume slot"
	)
	_expect(adapter._record_forced_battle_resume_slot(8), "forced battle records slot 8")
	_expect_equal(adapter._take_forced_battle_resume_slot(), 8, "forced battle returns slot 8 once")
	_expect_equal(adapter._take_forced_battle_resume_slot(), -1, "forced battle resume slot is consumed")


func _test_forced_battle_resume_host() -> void:
	var bundle = _battle_outcome_test_bundle()
	var host = HostScript.new()
	get_root().add_child(host)
	var adapter = ForcedBattleResumeAdapter.new()
	var completions: Array = []
	host.playthrough_completed.connect(func(result: Dictionary) -> void: completions.append(result))
	host.configure(adapter)
	host.runtime.runtime_state.configure_from_bundle(bundle)
	host.runtime.interpreter.configure(bundle, host.runtime.runtime_state)
	_expect(
		host.start_trigger("battle:outcome"),
		"host starts battle that ends from a Classic combat macro"
	)
	_expect_equal(
		adapter.commands.map(
			func(entry: Dictionary) -> String: return entry["command"]
		),
		["start_battle"],
		"forced victory skips the outer battle outcome continuation"
	)
	_expect_equal(completions.size(), 1, "forced battle completes the outer action point once")
	_expect_equal(
		host.runtime.interpreter.trace.map(
			func(entry: Dictionary) -> int: return int(entry.get("slot", -1))
		),
		[0],
		"slot-8 resume runs no remaining outer actions"
	)
	_expect(not host.active, "forced battle closes the outer runtime host")
	host.queue_free()


func _test_action_point_copy_mutations(bundle) -> void:
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:0:5"), "begin CoB same-door action")
	var copied_text: Dictionary = interpreter.run_until_yield()
	_expect_equal(copied_text.get("command"), "show_text", "same-door copy executes borrowed actions")
	_expect_equal(copied_text.get("payload", {}).get("messageId"), -69, "same-door copy reaches source-backed text")
	_expect_equal(interpreter.trace[0].get("code"), 8, "same-door trace records copy action")
	_expect_equal(interpreter.trace[1].get("triggerId"), "Data DD:0:5", "borrowed actions retain active AP identity")
	_expect_equal(interpreter.active_action_point_header.get("recordIndex"), 5, "same-door copy preserves active header")
	_expect_equal(interpreter.run_until_yield().get("reason"), "keep-codes", "borrowed AP reaches its keep action")
	_expect(
		interpreter.runtime_state.get_action_point_override("Data DD:0:5").is_empty(),
		"same-door copy remains transient"
	)

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:0:27", 5), "begin CoB action-data patch")
	var patched_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(patched_result.get("reason"), "keep-codes", "action-data patch continues in source AP")
	var patched: Dictionary = interpreter.runtime_state.get_action_point_override("Data DD:0:27")
	_expect_equal(patched.get("recordIndex"), 27, "action-data patch preserves target record")
	_expect_equal(patched.get("coordinate", {}).get("x"), 47, "action-data patch preserves target x")
	_expect_equal(patched.get("coordinate", {}).get("y"), 5, "action-data patch preserves target y")
	_expect_equal(patched.get("actions", []).size(), 3, "action-data patch copies all authored XAP actions")
	_expect_equal(patched.get("actions", [])[0].get("id"), 241, "action-data patch copies source-backed XAP text")
	_expect_equal(
		bundle.get_trigger("Data DD:0:27").get("actions", [])[0].get("id"),
		-238,
		"action-data patch leaves compiled AP immutable"
	)

	var restored = StateScript.new()
	restored.restore(interpreter.runtime_state.snapshot())
	var replay = InterpreterScript.new()
	replay.configure(bundle, restored)
	_expect(replay.begin_trigger("Data DD:0:27"), "restart patched CoB action point")
	_expect_equal(
		replay.run_until_yield().get("payload", {}).get("messageId"),
		241,
		"patched action point survives snapshot"
	)

	var borrowed_target: Dictionary = bundle.get_trigger("Data DD:0:4").duplicate(true)
	borrowed_target["actions"] = bundle.get_extra_action_point(18).get("actions", []).duplicate(true)
	restored.set_action_point_override("Data DD:0:4", borrowed_target)
	replay = InterpreterScript.new()
	replay.configure(bundle, restored)
	_expect(replay.begin_trigger("Data DD:0:5"), "restart same-door action with patched target")
	_expect_equal(
		replay.run_until_yield().get("payload", {}).get("messageId"),
		241,
		"same-door copy reads the target's persistent override"
	)

	var miss_state = StateScript.new()
	miss_state.configure_from_bundle(bundle)
	var percent_door: Dictionary = bundle.get_trigger("Data DD:0:5").duplicate(true)
	percent_door["percent"] = 50
	miss_state.set_action_point_override("Data DD:0:5", percent_door)
	var miss_interpreter = InterpreterScript.new()
	miss_interpreter.configure(bundle, miss_state)
	miss_interpreter.set_percent_roll_provider(func() -> int: return 100)
	_expect(miss_interpreter.begin_trigger("Data DD:0:5"), "begin same-door percentage recheck")
	var miss_result: Dictionary = miss_interpreter.run_until_yield()
	_expect_equal(miss_result.get("reason"), "same-door-percent-miss", "same-door copy rechecks active percentage")
	_expect_equal(miss_interpreter.trace.size(), 1, "failed same-door recheck skips borrowed actions")


func _test_action_data_patch_variants() -> void:
	var bundle = _action_data_patch_test_bundle()
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("patch:dungeon"), "begin explicit dungeon action-data patch")
	_expect_equal(interpreter.run_until_yield().get("reason"), "keep-codes", "dungeon patch completes")
	var dungeon_patch: Dictionary = interpreter.runtime_state.get_action_point_override("Data DDD:2:4")
	_expect_equal(
		dungeon_patch.get("actions", [])[0].get("id"),
		902,
		"action-data level selector targets a dungeon AP"
	)

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("patch:simple"), "begin simple-result action-data patch")
	_expect_equal(interpreter.run_until_yield().get("command"), "start_encounter", "simple patch continues to encounter")
	var simple_result: Dictionary = interpreter.resume_encounter(3)
	_expect_equal(simple_result.get("payload", {}).get("messageId"), 900, "simple result uses copied XAP")
	_expect_equal(
		_action_id_at_slot(bundle.get_encounter("simple", 10).get("actions", []), 16),
		802,
		"simple patch leaves compiled encounter immutable"
	)
	var restored = StateScript.new()
	restored.restore(interpreter.runtime_state.snapshot())
	var restored_simple := restored.get_effective_simple_encounter(bundle.get_encounter("simple", 10))
	_expect_equal(_action_id_at_slot(restored_simple.get("actions", []), 16), 900, "simple result patch survives snapshot")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("patch:complex"), "begin complex-result action-data patch")
	_expect_equal(interpreter.run_until_yield().get("command"), "start_encounter", "complex patch continues to encounter")
	var complex_result: Dictionary = interpreter.resume_encounter(2)
	_expect_equal(complex_result.get("payload", {}).get("messageId"), 901, "complex result uses copied XAP")
	_expect_equal(
		_action_id_at_slot(bundle.get_encounter("complex", 11).get("actions", []), 8),
		811,
		"complex patch leaves compiled encounter immutable"
	)


func _test_battle_request(bundle) -> void:
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:0:27", 2), "begin CoB battle action")
	var result: Dictionary = interpreter.run_until_yield()
	var payload: Dictionary = result.get("payload", {})
	_expect_equal(result.get("command"), "start_battle", "battle command")
	_expect_equal(payload.get("battleIdRange"), [38, 38], "battle range decoded from EDCD row 70")
	_expect_equal(payload.get("soundId"), 30000, "battle sound decoded from EDCD row 70")
	_expect_equal(payload.get("battle", {}).get("id"), 38, "battle record resolves")


func _test_compiled_battle_materialization() -> void:
	var bundle = BundleScript.new()
	_expect(
		bundle.load_from_directory(PROVIDENCE_AUTHORITATIVE_FIXTURE),
		"producer battle fixture loads: %s" % bundle.last_error
	)
	if not bundle.last_error.is_empty():
		return
	var battle: Dictionary = bundle.get_battle(0).duplicate(true)
	battle["id"] = 12
	battle["dist"] = 7
	battle["messageBefore"] = 31
	battle["messageAfter"] = 32
	battle["battleMacro"] = -9
	battle["grid"][84] = -1
	bundle.monsters_by_id[1]["deathMacro"] = 42
	bundle.monsters_by_id[1]["typeFlags"] = [false, false, true, false, false, false, false, false]
	bundle.monsters_by_id[1]["hitDice"] = 7
	bundle.monsters_by_id[1]["magicResistance"] = 12
	bundle.monsters_by_id[1]["saves"] = [-25, -25, 100, 100, 100, 15]
	bundle.monsters_by_id[1]["spellImmunities"] = [1, 0, 0, 1, 1, 0]
	bundle.monsters_by_id[1]["canSummon"] = 1
	bundle.monsters_by_id[1]["conditions"][10] = -2
	bundle.monsters_by_id[1]["conditions"][16] = -1
	var adapter = GodotAdapterScript.new()
	var result: Dictionary = adapter.materialize_classic_battle(
		battle,
		bundle.monsters_by_id,
		{
			"Providence Sentinel": {
				"data": {
					"name": "Providence Sentinel",
					"classicMonsterId": 1,
				},
			},
		}
	)
	_expect_equal(result.get("creatureCount"), 1, "compiled battle materializes its monster grid")
	var native_battle: Dictionary = result.get("battle", {})
	_expect_equal(native_battle.get("bonus_distance"), 7, "compiled battle preserves distance")
	_expect_equal(native_battle.get("battleMacro"), -9, "compiled battle preserves round macro")
	_expect_equal(native_battle.get("classicMessageBefore"), 31, "compiled battle preserves before text")
	_expect_equal(native_battle.get("classicMessageAfter"), 32, "compiled battle preserves after text")
	var creature: Array = native_battle.get("Creatures", [])[0]
	_expect_equal(creature[0], "Providence Sentinel", "compiled monster resolves native bestiary")
	_expect_equal(creature[1], [1, 1], "compiled grid position uses Classic coordinates")
	_expect_equal(
		creature[2].get("classicMonsterId"),
		1,
		"compiled battle preserves monster identity"
	)
	_expect_equal(
		creature[2].get("classicMonsterNameId"),
		1,
		"compiled battle preserves monster name identity"
	)
	_expect_equal(
		creature[2].get("classicDeathMacro"),
		42,
		"compiled battle preserves monster death macro"
	)
	_expect(
		bool(creature[2].get("classicTurnUndeadEligible")),
		"compiled battle preserves nether-spawn eligibility"
	)
	_expect_equal(creature[2].get("classicHitDice"), 7, "compiled battle preserves hit dice")
	_expect_equal(
		creature[2].get("classicMagicResistance"),
		12,
		"compiled battle preserves turning resistance"
	)
	_expect_equal(
		creature[2].get("classicSpellSaves"),
		[-25, -25, 100, 100, 100, 15],
		"compiled battle preserves all six monster saves"
	)
	_expect_equal(
		creature[2].get("classicSpellImmunities"),
		[1, 0, 0, 1, 1, 0],
		"compiled battle preserves all six spell immunities"
	)
	_expect_equal(
		creature[2].get("classicRegenerationPerRound"),
		2,
		"compiled battle preserves permanent regeneration"
	)
	_expect_equal(
		creature[2].get("classicSpellScreenLevel"),
		1,
		"compiled battle preserves permanent first-level spell protection"
	)
	_expect_equal(creature[2].get("classicCanSummon"), 1, "compiled battle preserves summon flag")
	_expect(bool(creature[2].get("classicForceFriend")), "negative grid entry flips side")

	var existing_battle := {
		"Battle_0": {
			"nativeLayout": true,
			"Creatures": [["Providence Sentinel", [0, 0]]],
		},
	}
	var existing_bestiary := {
		"Providence Sentinel": {
			"data": {"name": "Providence Sentinel", "classicMonsterId": 1},
		},
	}
	adapter.configure_classic_bundle(bundle)
	var existing: Dictionary = adapter.ensure_classic_battle_resource(
		0,
		existing_battle,
		existing_bestiary
	)
	_expect(not bool(existing.get("created")), "existing native battle remains preferred")
	_expect(
		bool(existing_battle["Battle_0"].get("nativeLayout")),
		"compiled battle generation does not replace a native layout"
	)
	var existing_overrides: Dictionary = adapter.build_existing_classic_battle_overrides(
		0,
		existing_battle,
		existing_bestiary
	)
	_expect_equal(
		existing_overrides.get("Creatures", [])[0][2].get("classicMonsterId"),
		1,
		"native battle creatures receive compiled Classic identity"
	)

	var battle_book: Dictionary = {}
	var ensured: Dictionary = adapter.ensure_classic_battle_resource(
		0,
		battle_book,
		{
			"Providence Sentinel": {
				"data": {"name": "Providence Sentinel", "classicMonsterId": 1},
			},
		}
	)
	_expect(bool(ensured.get("created")), "missing native battle is generated from compiler data")
	_expect(battle_book.has("Battle_0"), "generated battle is registered for GameGlobal")


func _test_selective_battle_action() -> void:
	var bundle = _selective_battle_test_bundle()
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("selective:battle"), "begin selective battle")
	_expect_equal(
		interpreter.run_until_yield().get("command"),
		"pick_characters",
		"selective battle starts with character pick"
	)
	var battle: Dictionary = interpreter.run_until_yield()
	var payload: Dictionary = battle.get("payload", {})
	_expect_equal(battle.get("command"), "start_battle", "opcode 48 yields a battle request")
	_expect_equal(payload.get("battleIdRange"), [115, 119], "selective battle preserves inclusive range")
	_expect_equal(payload.get("participantMode"), "selected", "selective battle uses picked characters")
	_expect_equal(payload.get("soundId"), 30000, "selective battle preserves optional sound")
	_expect_equal(payload.get("messageId"), 900, "selective battle preserves optional text")
	_expect_equal(payload.get("treasureId"), 38, "selective battle preserves fixed treasure")
	_expect_equal(
		interpreter.run_until_yield().get("status"),
		"error",
		"selective battle requires an outcome"
	)
	var treasure: Dictionary = interpreter.resume_selective_battle(1)
	_expect_equal(
		treasure.get("command"),
		"give_treasure",
		"surviving participants receive fixed treasure"
	)
	_expect_equal(
		treasure.get("payload", {}).get("treasureId"),
		38,
		"selective battle resolves treasure record"
	)
	_expect_equal(
		interpreter.run_until_yield().get("reason"),
		"keep-codes",
		"selective battle resumes its encounter result"
	)

	interpreter = _interpreter(bundle)
	interpreter.begin_trigger("selective:battle")
	interpreter.run_until_yield()
	interpreter.run_until_yield()
	var no_survivors: Dictionary = interpreter.resume_selective_battle(0)
	_expect_equal(
		no_survivors.get("command"),
		"show_text",
		"no selected survivors presents Classic warning"
	)
	_expect_equal(
		no_survivors.get("payload", {}).get("message", {}).get("text"),
		"There is nobody left to collect any treasure.",
		"no selected survivors preserves Classic no-treasure text"
	)
	_expect_equal(
		interpreter.run_until_yield().get("reason"),
		"keep-codes",
		"no selected survivors still resumes encounter flow"
	)


func _test_selective_battle_request() -> void:
	var payload: Dictionary = _selective_battle_payload()
	var first := RogueTestCharacter.new()
	var second := RogueTestCharacter.new()
	var adapter = GodotAdapterScript.new()
	var request: Dictionary = adapter.build_classic_battle_request(
		payload,
		{"Battle_115": {}},
		[first, second],
		[second],
		115
	)
	_expect_equal(
		request.get("battleName"),
		"Battle_115",
		"battle adapter resolves native battle name"
	)
	_expect_equal(
		request.get("participants"),
		[second],
		"battle adapter passes only selected participants"
	)
	_expect(bool(request.get("allowLoss")), "selective battle cannot trigger a whole-party game over")
	_expect(bool(request.get("allowLoot")), "selective battle retains native defeated-enemy loot")

	second.current_hp = 0
	var empty_request: Dictionary = adapter.build_classic_battle_request(
		payload,
		{"Battle_115": {}},
		[first, second],
		[second],
		115
	)
	_expect(bool(empty_request.get("noBattle")), "dead selection skips an invalid native battle")

	var normal_payload := payload.duplicate(true)
	normal_payload.erase("participantMode")
	normal_payload["lootMode"] = 5
	var normal_request: Dictionary = adapter.build_classic_battle_request(
		normal_payload,
		{"Battle_115": {}},
		[first, second],
		[],
		115
	)
	_expect_equal(normal_request.get("participants"), [first, second], "normal battle uses whole party")
	_expect(not bool(normal_request.get("allowLoss")), "normal battle retains game-over behavior")
	_expect(not bool(normal_request.get("allowLoot")), "loot mode 5 suppresses native rewards")

	normal_payload["lootMode"] = 0
	normal_payload["outcomeBranch"] = true
	var branching_request: Dictionary = adapter.build_classic_battle_request(
		normal_payload,
		{"Battle_115": {}},
		[first, second],
		[],
		115
	)
	_expect(bool(branching_request.get("allowLoss")), "branching battle returns its defeat outcome")

	var native_battles_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(
		"res://Campaigns/City of Bywater/Battles/battles.json"
	))
	var native_battles: Dictionary = native_battles_value \
		if native_battles_value is Dictionary else {}
	for battle_id: int in range(115, 135):
		_expect(
			native_battles.has("Battle_%d" % battle_id),
			"native campaign contains selective battle %d" % battle_id
		)


func _test_selective_battle_host() -> void:
	var bundle = _selective_battle_test_bundle()
	var host = HostScript.new()
	get_root().add_child(host)
	var host_adapter = SelectiveBattleAdapter.new()
	var completions: Array = []
	host.playthrough_completed.connect(func(result: Dictionary) -> void: completions.append(result))
	host.configure(host_adapter)
	host.runtime.runtime_state.configure_from_bundle(bundle)
	host.runtime.interpreter.configure(bundle, host.runtime.runtime_state)
	_expect(host.start_trigger("selective:battle"), "host starts selective battle fixture")
	_expect_equal(
		host_adapter.commands.map(
			func(entry: Dictionary) -> String: return entry["command"]
		),
		["pick_characters", "start_battle", "give_treasure"],
		"host resumes surviving selective battle through treasure"
	)
	_expect_equal(completions.size(), 1, "host completes surviving selective battle")
	host.queue_free()

	host = HostScript.new()
	get_root().add_child(host)
	host_adapter = SelectiveBattleAdapter.new()
	host_adapter.survivor_count = 0
	completions = []
	host.playthrough_completed.connect(func(result: Dictionary) -> void: completions.append(result))
	host.configure(host_adapter)
	host.runtime.runtime_state.configure_from_bundle(bundle)
	host.runtime.interpreter.configure(bundle, host.runtime.runtime_state)
	_expect(host.start_trigger("selective:battle"), "host starts no-survivor selective battle")
	_expect_equal(
		host_adapter.commands.map(
			func(entry: Dictionary) -> String: return entry["command"]
		),
		["pick_characters", "start_battle", "show_text"],
		"host skips fixed treasure when nobody survives"
	)
	_expect_equal(completions.size(), 1, "host completes no-survivor selective battle")
	host.queue_free()


func _test_choice_continuation(bundle) -> void:
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:0:27", 1), "begin CoB inverted choice")
	var choice_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(choice_result.get("command"), "choice", "choice yields to Godot host")
	var declined_result: Dictionary = interpreter.resume_choice(false)
	_expect_equal(declined_result.get("status"), "completed", "declining inverted CoB choice exits AP")
	_expect_equal(declined_result.get("reason"), "choice-exit", "choice exit reason")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:0:27", 1), "restart CoB inverted choice")
	interpreter.run_until_yield()
	var accepted_result: Dictionary = interpreter.resume_choice(true)
	_expect_equal(accepted_result.get("command"), "start_battle", "accepting inverted CoB choice continues to battle")


func _test_sound_and_treasure(bundle) -> void:
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:0:10", 3), "begin CoB sound action")
	var sound_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(sound_result.get("command"), "play_sound", "sound command")
	_expect_equal(sound_result.get("payload", {}).get("soundId"), 10105, "sound resource id")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:0:30", 5), "begin CoB treasure action")
	var treasure_result: Dictionary = interpreter.run_until_yield()
	var payload: Dictionary = treasure_result.get("payload", {})
	_expect_equal(treasure_result.get("command"), "give_treasure", "treasure command")
	_expect_equal(payload.get("treasureId"), 11, "treasure record id")
	_expect_equal(payload.get("treasure", {}).get("exp"), 1200, "treasure record resolves")
	_expect_equal(payload.get("lootMode"), 1, "fixed treasure uses Classic loot mode 1")


func _test_shop_actions() -> void:
	var bundle = BundleScript.new()
	bundle.manifest = {"start": {"levelType": "land", "levelIndex": 0, "x": 0, "y": 0}}
	var item_ids: Array = []
	var quantities: Array = []
	item_ids.resize(1000)
	quantities.resize(1000)
	item_ids.fill(0)
	quantities.fill(0)
	for stock: Array in [
		[0, 1, 3],
		[200, 209, 2],
		[400, 418, 1],
		[600, 675, 1],
		[800, 803, 4],
	]:
		item_ids[stock[0]] = stock[1]
		quantities[stock[0]] = stock[2]
	bundle.shops_by_id[2] = {
		"id": 2,
		"inflation": 95,
		"itemIds": item_ids,
		"quantities": quantities,
	}
	bundle.item_texts_by_id[675] = {
		"itemId": 675,
		"identifiedName": "Quiver of Protection +2",
	}
	bundle.item_texts_by_id[617] = {
		"itemId": 617,
		"identifiedName": "Yellow Luck Stone +3",
	}
	bundle.extra_codes_by_id[7] = {"values": [-2, 1, 10, 600, 700]}
	bundle.extra_codes_by_id[8] = {"values": [2, 1, 100, 0, 0]}
	_add_stack_trigger(bundle, "shop:available", -1, [
		_classic_action(0, 6, 2),
		_classic_action(7, 24, 0),
	])
	_add_stack_trigger(bundle, "shop:immediate", -1, [
		_classic_action(0, 6, -2),
		_classic_action(7, 24, 0),
	])
	_add_stack_trigger(bundle, "shop:missing", -1, [_classic_action(0, 6, 3)])
	_add_stack_trigger(bundle, "shop:restricted", -1, [
		_classic_action(0, 73, 7),
		_classic_action(7, 24, 0),
	])
	_add_stack_trigger(bundle, "shop:single-range", -1, [_classic_action(0, 73, 8)])
	_add_stack_trigger(bundle, "shop:missing-ranges", -1, [_classic_action(0, 73, 9)])

	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("shop:available"), "begin available-shop action")
	var available_result: Dictionary = interpreter.run_until_yield()
	var available_payload: Dictionary = available_result.get("payload", {})
	_expect_equal(available_result.get("command"), "load_shop", "shop yields typed command")
	_expect_equal(available_payload.get("shopId"), 2, "shop ID is absolute")
	_expect_equal(available_payload.get("openImmediately"), false, "positive shop stays available")
	_expect_equal(available_payload.get("acceptRanges"), [0, 0, 0, 0], "plain shop clears restrictions")
	_expect_equal(available_payload.get("itemTexts", []).size(), 1, "shop carries scenario item text")
	_expect_equal(interpreter.run_until_yield().get("reason"), "keep-codes", "shop command resumes")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("shop:immediate"), "begin immediate-shop action")
	var immediate_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(
		immediate_result.get("payload", {}).get("openImmediately"),
		true,
		"negative shop opens immediately"
	)

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("shop:missing"), "begin missing-shop action")
	_expect_equal(interpreter.run_until_yield().get("status"), "error", "missing shop stops safely")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("shop:restricted"), "begin restricted-shop action")
	var restricted_result: Dictionary = interpreter.run_until_yield()
	var restricted_payload: Dictionary = restricted_result.get("payload", {})
	_expect_equal(restricted_result.get("command"), "load_shop", "restricted shop uses shop command")
	_expect_equal(restricted_payload.get("shopId"), 2, "restricted shop resolves Extra Code shop ID")
	_expect_equal(restricted_payload.get("openImmediately"), true, "signed Extra Code shop ID opens")
	_expect_equal(
		restricted_payload.get("acceptRanges"),
		[1, 10, 600, 700],
		"restricted shop carries both inclusive ranges"
	)
	_expect_equal(
		restricted_payload.get("itemTexts", []).size(),
		2,
		"restricted shop carries scenario item identities beyond its stock"
	)

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("shop:single-range"), "begin single-range shop action")
	var single_range_payload: Dictionary = interpreter.run_until_yield().get("payload", {})

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("shop:missing-ranges"), "begin missing restricted-shop row")
	_expect_equal(
		interpreter.run_until_yield().get("status"),
		"error",
		"missing restricted-shop Extra Code stops safely"
	)

	var item_mapping := {
		1: "Dagger",
		209: "Leather Armor",
		418: "Leather Cap",
		803: "Quiver of Arrows",
	}
	var available_items := {
		"Dagger": {},
		"Leather Armor": {},
		"Leather Cap": {},
		"Yellow Luck Stone +3": {},
		"Quiver of Protection +2": {},
		"Quiver of Arrows": {},
	}
	var built: Dictionary = GodotAdapterScript.new().build_shop_inventory(
		available_payload,
		item_mapping,
		available_items
	)
	var native_shop: Dictionary = built.get("shop", {})
	_expect_equal(native_shop.get("sell_rate"), 0.95, "shop inflation sets purchase rate")
	_expect_equal(native_shop.get("buy_rate"), 0.95, "shop inflation sets resale rate")
	_expect_equal(native_shop.get("Weapons"), [["Dagger", 3, -1]], "weapon slots map to Weapons")
	_expect_equal(native_shop.get("Armor"), [["Leather Armor", 2, -1]], "body armor maps to Armor")
	_expect_equal(native_shop.get("Limbs"), [["Leather Cap", 1, -1]], "limb armor maps to Limbs")
	_expect_equal(
		native_shop.get("Magic"),
		[["Quiver of Protection +2", 1, -1]],
		"scenario item text can resolve magic stock"
	)
	_expect_equal(native_shop.get("Supplies"), [["Quiver of Arrows", 4, -1]], "supplies map by slot")
	_expect_equal(built.get("itemCount"), 11, "shop reports total stock quantity")

	var restricted_built: Dictionary = GodotAdapterScript.new().build_shop_inventory(
		restricted_payload,
		item_mapping,
		available_items
	)
	var restricted_shop: Dictionary = restricted_built.get("shop", {})
	_expect_equal(
		restricted_shop.get("classic_accept_ranges"),
		[1, 10, 600, 700],
		"native shop retains Classic range evidence"
	)
	var accepted_item_names: Array = restricted_shop.get("accepted_item_names", {}).keys()
	accepted_item_names.sort()
	_expect_equal(
		accepted_item_names,
		["Dagger", "Quiver of Protection +2", "Yellow Luck Stone +3"],
		"native shop resolves both accepted ranges to available item identities"
	)
	_expect(
		ShopRulesScript.accepts_item(
			"restricted",
			{"restricted": restricted_shop},
			{"name": "Dagger"}
		),
		"restricted shop accepts range-one item"
	)
	_expect(
		ShopRulesScript.accepts_item(
			"restricted",
			{"restricted": restricted_shop},
			{"name": "Yellow Luck Stone +3"}
		),
		"restricted shop accepts scenario item in range two"
	)
	_expect(
		not ShopRulesScript.accepts_item(
			"restricted",
			{"restricted": restricted_shop},
			{"name": "Leather Armor"}
		),
		"restricted shop rejects item outside both ranges"
	)
	var single_range_built: Dictionary = GodotAdapterScript.new().build_shop_inventory(
		single_range_payload,
		item_mapping,
		available_items
	)
	_expect(
		not single_range_built.get("shop", {}).has("accepted_item_names"),
		"one populated range preserves Classic's unrestricted transfer result"
	)
	_expect(
		ShopRulesScript.accepts_item(
			"single",
			{"single": single_range_built.get("shop", {})},
			{"name": "Leather Armor"}
		),
		"single-range Classic shop remains unrestricted"
	)
	_expect_equal(
		ShopRulesScript.balances_after_purchase(10, 7, 10),
		[7, 0],
		"Classic shop purchases spend pooled gold before character gold"
	)
	var alias_items: Array = []
	var alias_quantities: Array = []
	alias_items.resize(612)
	alias_quantities.resize(612)
	alias_items.fill(0)
	alias_quantities.fill(0)
	alias_items[98] = 98
	alias_quantities[98] = 1
	alias_items[610] = 610
	alias_quantities[610] = 1
	alias_items[611] = 611
	alias_quantities[611] = 2
	var aliases: Dictionary = GodotAdapterScript.new().build_shop_inventory(
		{"shop": {"itemIds": alias_items, "quantities": alias_quantities}},
		{},
		{"Quarter Staff": {}, "Waterworld": {}, "Heal Small Wounds": {}}
	)
	_expect_equal(
		aliases.get("shop", {}).get("Weapons"),
		[["Quarter Staff", 1, -1]],
		"duplicate shared weapon ID resolves"
	)
	_expect_equal(
		aliases.get("shop", {}).get("Magic"),
		[["Waterworld", 1, -1], ["Heal Small Wounds", 2, -1]],
		"duplicate shared magic IDs resolve"
	)


func _test_service_actions() -> void:
	var bundle = BundleScript.new()
	bundle.manifest = {"start": {"levelType": "land", "levelIndex": 0, "x": 0, "y": 0}}
	_add_stack_trigger(bundle, "services", -1, [
		_classic_action(0, 49, 0),
		_classic_action(1, 32, 150),
		_classic_action(7, 24, 0),
	])
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("services"), "begin banking and temple actions")
	var bank_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(bank_result.get("command"), "enable_banking", "bank action yields typed command")
	_expect_equal(bank_result.get("payload", {}).get("soundId"), 128, "bank action preserves sound")
	_expect_equal(bank_result.get("payload", {}).get("warningId"), 106, "bank action preserves warning")
	var temple_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(temple_result.get("command"), "offer_temple", "temple action yields typed command")
	_expect_equal(temple_result.get("payload", {}).get("costPercent"), 150, "temple cost percentage")
	_expect_equal(temple_result.get("payload", {}).get("soundId"), 10105, "temple action preserves sound")
	_expect_equal(interpreter.run_until_yield().get("reason"), "keep-codes", "service actions resume")

	var adapter = GodotAdapterScript.new()
	var standard: Dictionary = adapter.build_temple_services(100)
	_expect_equal(
		standard.get("services", []).map(func(service: Array) -> int: return int(service[2])),
		[250, 350, 850, 200, 750, 200, 350, 550, 1500],
		"standard temple uses Classic base prices"
	)
	var expensive: Dictionary = adapter.build_temple_services(300)
	_expect_equal(expensive.get("services", [])[0][2], 750, "temple percentage scales prices")
	_expect_equal(
		adapter.build_temple_services(33).get("services", [])[0][2],
		82,
		"temple price scaling truncates fractional gold"
	)
	_expect_equal(
		adapter.build_temple_services(-1).get("status"),
		"error",
		"negative temple percentage stops safely"
	)
	_expect(
		TemplePaymentScript.can_afford_service(75, 100, 150),
		"temple combines character and pooled gold for affordability"
	)
	_expect_equal(
		TemplePaymentScript.balances_after_service(75, 100, 150),
		[25, 0],
		"temple spends pooled gold before character gold"
	)
	_expect(
		not TemplePaymentScript.can_afford_service(40, 50, 100),
		"temple rejects an unaffordable service"
	)
	var temple_entry_balances: Array = TemplePaymentScript.balances_after_transfer(
		[800, 3, 2],
		[100, 1, 0]
	)
	_expect_equal(
		temple_entry_balances,
		[[0, 0, 0], [900, 4, 2]],
		"banked wealth joins the pool on temple entry"
	)
	var hostile_payment: Array = TemplePaymentScript.balances_after_service(
		75,
		temple_entry_balances[1][0],
		expensive.get("services", [])[0][2]
	)
	temple_entry_balances[1][0] = hostile_payment[1]
	_expect_equal(
		hostile_payment,
		[75, 150],
		"hostile temple payment spends transferred pool gold first"
	)
	_expect_equal(
		TemplePaymentScript.balances_after_transfer(
			temple_entry_balances[1],
			temple_entry_balances[0]
		),
		[[0, 0, 0], [150, 4, 2]],
		"remaining temple pool returns to the bank on exit"
	)


func _test_treasure_delivery(bundle) -> void:
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:5:3"), "begin CoB treasure delivery path")
	interpreter.run_until_yield()
	interpreter.resume_encounter(2)
	var treasure_result: Dictionary = interpreter.run_until_yield()
	var payload: Dictionary = treasure_result.get("payload", {})
	_expect_equal(
		payload.get("itemTexts", []).map(
			func(item_text: Dictionary) -> int: return int(item_text.get("itemId", 0))
		),
		[600, 601, 617, 801, 806],
		"treasure payload carries exported item text records"
	)
	var delivery: Dictionary = GodotAdapterScript.new().build_treasure_delivery(
		payload,
		{
			600: "Invisible Skin",
			601: "Adrenalin",
			617: "Yellow Luck Stone +3",
		},
		{
			"Invisible Skin": {},
			"Adrenalin": {},
			"Yellow Luck Stone +3": {},
			"Priest Scroll Case": {},
			"Parchment": {},
		}
	)
	_expect_equal(
		delivery.get("itemNames"),
		[
			"Invisible Skin",
			"Adrenalin",
			"Yellow Luck Stone +3",
			"Priest Scroll Case",
			"Parchment",
		],
		"treasure IDs resolve through shared mappings and scenario item text"
	)
	_expect_equal(delivery.get("money"), [0, 5, 2], "treasure preserves classic money")
	_expect_equal(delivery.get("experience"), 600, "treasure preserves classic experience")


func _test_map_mutations(bundle) -> void:
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:0:69"), "begin CoB tile mutation")
	var tile_result: Dictionary = interpreter.run_until_yield()
	var tile_payload: Dictionary = tile_result.get("payload", {})
	_expect_equal(tile_result.get("command"), "set_map_tile", "tile mutation command")
	_expect_equal(tile_payload.get("levelType"), "land", "tile mutation map kind")
	_expect_equal(tile_payload.get("x"), 3, "land tile x keeps EDCD axis order")
	_expect_equal(tile_payload.get("y"), 28, "land tile y keeps EDCD axis order")
	_expect_equal(tile_payload.get("tileValue"), 193, "tile mutation value")
	_expect_equal(interpreter.runtime_state.get_tile("land", 0, 3, 28, -1), 193, "tile override persists")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:0:30", 6), "begin CoB trigger mutation")
	var trigger_result: Dictionary = interpreter.run_until_yield()
	var trigger_payload: Dictionary = trigger_result.get("payload", {})
	_expect_equal(trigger_result.get("command"), "set_trigger_percent", "trigger mutation command")
	_expect_equal(trigger_payload.get("triggerIds"), [17], "single trigger id decoded")
	_expect_equal(trigger_payload.get("percent"), 100, "trigger percent decoded")
	_expect_equal(
		interpreter.runtime_state.get_trigger_percent("land", 0, 17, -1),
		100,
		"trigger override persists"
	)


func _test_timed_encounter_mutation() -> void:
	var bundle = _timed_encounter_test_bundle()
	var interpreter = _interpreter(bundle)
	_expect(
		interpreter.begin_trigger("timed:reset", 0, {"scenarioDay": 41}),
		"begin timed encounter reset"
	)
	_expect_equal(
		interpreter.run_until_yield().get("reason"),
		"keep-codes",
		"timed encounter mutation continues through its action list"
	)
	var effective: Dictionary = interpreter.runtime_state.get_effective_timed_encounter(
		bundle.get_timed_encounter(0)
	)
	_expect_equal(effective.get("percent"), 100, "timed encounter mutation replaces chance")
	_expect_equal(effective.get("increment"), 0, "timed encounter mutation replaces increment")
	_expect_equal(effective.get("day"), 48, "timed encounter reset adds offset to current day")
	_expect_equal(bundle.get_timed_encounter(0).get("day"), 3, "compiled timed encounter stays immutable")

	_expect(interpreter.begin_trigger("timed:offset"), "begin timed encounter offset")
	_expect_equal(
		interpreter.run_until_yield().get("reason"),
		"keep-codes",
		"timed encounter offset completes"
	)
	effective = interpreter.runtime_state.get_effective_timed_encounter(
		bundle.get_timed_encounter(0)
	)
	_expect_equal(effective.get("day"), 50, "later mutation reads the effective timed encounter")
	_expect_equal(effective.get("percent"), 100, "unchanged chance sentinel preserves override")
	_expect_equal(effective.get("increment"), 0, "unchanged increment sentinel preserves override")

	_expect(interpreter.begin_trigger("timed:unchanged"), "begin unchanged timed encounter mutation")
	_expect_equal(interpreter.run_until_yield().get("reason"), "keep-codes", "sentinel mutation completes")
	_expect_equal(
		interpreter.runtime_state.get_effective_timed_encounter(
			bundle.get_timed_encounter(0)
		),
		effective,
		"negative sentinels leave the effective timed encounter unchanged"
	)

	var restored = StateScript.new()
	restored.restore(interpreter.runtime_state.snapshot())
	_expect_equal(
		restored.get_effective_timed_encounter(bundle.get_timed_encounter(0)).get("day"),
		50,
		"timed encounter mutation survives snapshot restore"
	)
	var runtime = RuntimeScript.new()
	runtime.bundle = bundle
	runtime.runtime_state = restored
	_expect_equal(runtime.get_timed_encounter(0).get("day"), 50, "facade reads effective timed encounter")
	_expect_equal(runtime.timed_encounters()[0].get("day"), 50, "timed encounter scan reads overrides")

	var missing_day = _interpreter(bundle)
	_expect(missing_day.begin_trigger("timed:reset"), "begin timed reset without clock context")
	_expect_equal(
		missing_day.run_until_yield().get("status"),
		"error",
		"timed reset rejects a missing scenario day"
	)


func _test_complex_encounter(bundle) -> void:
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:0:19"), "begin CoB complex encounter")
	var encounter_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(encounter_result.get("command"), "start_encounter", "complex encounter command")
	_expect_equal(encounter_result.get("payload", {}).get("encounterKind"), "complex", "complex encounter kind")
	var outcome_result: Dictionary = interpreter.resume_encounter(1)
	_expect_equal(outcome_result.get("command"), "show_text", "complex outcome executes first result block")
	_expect_equal(outcome_result.get("payload", {}).get("messageId"), 183, "complex result slot resolves")


func _test_complex_action_choices(bundle) -> void:
	var adapter = GodotAdapterScript.new()
	var cave_in: Dictionary = adapter.build_complex_action_choices(
		bundle.get_encounter("complex", 2),
		true
	)
	_expect_equal(
		cave_in.get("choices"),
		["Dig", "Throw stones at mountain", "Attempt to climb slope", "Back out"],
		"complex action choices expose shipped labels"
	)
	_expect_equal(
		cave_in.get("tokens"),
		["action:1", "action:1", "action:1", "back"],
		"complex actions share the source-backed result block"
	)
	var library: Dictionary = adapter.build_complex_action_choices(
		{
			"texts": [
				"Examine some books.",
				"Study quietly at a table.",
				"", "", "", "", "", "",
				"waterford",
			],
			"actionResult": 2,
		},
		false
	)
	_expect_equal(
		library.get("choices"),
		["Examine some books.", "Study quietly at a table."],
		"complex action choices exclude the separate spoken-word field"
	)


func _test_complex_word_results() -> void:
	var adapter = GodotAdapterScript.new()
	var archive := {
		"texts": [
			"Examine some books.",
			"Study quietly at a table.",
			"", "", "", "", "", "",
			"waterford",
		],
		"wordResult": 1,
	}
	var choices: Array = []
	var tokens: Array = []
	adapter._append_complex_word_choice(archive, choices, tokens)
	_expect_equal(choices, ["Speak"], "complex word response exposes the speech control")
	_expect_equal(tokens, ["word"], "complex word response uses its own selection token")
	choices.clear()
	tokens.clear()
	adapter._append_complex_word_choice({"wordResult": 0}, choices, tokens)
	_expect_equal(choices, [], "encounters without a word result omit the speech control")
	_expect_equal(
		adapter.resolve_complex_word_result(archive, "waterford"),
		1,
		"exact spoken word selects its authored result"
	)
	_expect_equal(
		adapter.resolve_complex_word_result(archive, "WATERFORD"),
		1,
		"spoken-word matching is case-insensitive"
	)
	_expect_equal(
		adapter.resolve_complex_word_result(archive, "waterford cellar"),
		1,
		"Classic accepts entered text beyond the matching word prefix"
	)
	_expect_equal(
		adapter.resolve_complex_word_result(archive, "water"),
		4,
		"short spoken-word prefixes use Classic's result 4 fallback"
	)
	_expect_equal(
		adapter.resolve_complex_word_result(archive, ""),
		4,
		"empty text cannot resolve a spoken-word result"
	)
	_expect_equal(
		adapter.resolve_complex_word_result(
			{
				"texts": ["", "", "", "", "", "", "", "", "magic phrase"],
				"wordResult": 3,
			},
			"MAGIC lantern"
		),
		3,
		"Classic stops the stored response at its first space"
	)
	var forty_character_response: Dictionary = archive.duplicate(true)
	forty_character_response["texts"][8] = "a".repeat(40) + "x"
	forty_character_response["wordResult"] = 2
	_expect_equal(
		adapter.resolve_complex_word_result(
			forty_character_response,
			"A".repeat(40) + "y"
		),
		2,
		"Classic compares no more than forty characters"
	)


func _test_encounter_lifecycle() -> void:
	var bundle = BundleScript.new()
	bundle.manifest = {"start": {"levelType": "land", "levelIndex": 0, "x": 0, "y": 0}}
	bundle.triggers_by_id["lifecycle:test"] = {
		"id": "lifecycle:test",
		"source": "Data DD",
		"actions": [{"slot": 0, "rawCode": 5, "code": 5, "id": 1}],
	}
	bundle.complex_encounters_by_id[1] = {
		"id": 1,
		"actions": [
			{"slot": 16, "rawCode": 1, "id": 303},
			{"slot": 24, "rawCode": 1, "id": 404},
		],
		"maxTimes": 2,
		"prompt": 0,
	}
	bundle.messages_by_id[303] = {"id": 303, "text": "Timed out"}
	bundle.messages_by_id[404] = {"id": 404, "text": "Try again"}
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("lifecycle:test"), "begin encounter lifecycle fixture")
	var encounter_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(
		encounter_result.get("payload", {}).get("remainingAttempts"),
		2,
		"encounter starts with its authored attempt count"
	)
	var first_failure: Dictionary = interpreter.resume_encounter(4)
	_expect_equal(
		first_failure.get("payload", {}).get("messageId"),
		404,
		"result 4 is unchanged before the final attempt"
	)
	var repeated: Dictionary = interpreter.run_until_yield()
	_expect_equal(repeated.get("command"), "start_encounter", "fallthrough repeats encounter")
	_expect_equal(
		repeated.get("payload", {}).get("remainingAttempts"),
		1,
		"encounter repetition decrements remaining attempts"
	)
	var timeout: Dictionary = interpreter.resume_encounter(4)
	_expect_equal(
		timeout.get("payload", {}).get("messageId"),
		303,
		"final complex result 4 uses Classic's result 3 timeout block"
	)
	var completed: Dictionary = interpreter.run_until_yield()
	_expect_equal(completed.get("status"), "completed", "final encounter attempt completes")


func _test_simple_encounter_mutation() -> void:
	var bundle = BundleScript.new()
	_expect(bundle.load_from_directory(FIXTURE), "CoB simple-option fixture loads: %s" % bundle.last_error)
	if not bundle.last_error.is_empty():
		return
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:0:8"), "begin CoB tavern encounter")
	var tavern_text: Dictionary = interpreter.run_until_yield()
	_expect_equal(tavern_text.get("payload", {}).get("messageId"), 75, "tavern intro message")
	var tavern: Dictionary = interpreter.run_until_yield()
	_expect_equal(tavern.get("payload", {}).get("encounterId"), 3, "tavern simple encounter")
	var barmaid: Dictionary = interpreter.resume_encounter(4)
	_expect_equal(barmaid.get("payload", {}).get("messageId"), 86, "barmaid response begins")
	var reopened: Dictionary = interpreter.run_until_yield()
	_expect_equal(reopened.get("command"), "start_encounter", "opcode 35 reopens the encounter")
	_expect_equal(
		reopened.get("payload", {}).get("remainingAttempts"),
		99,
		"opcode 35 does not consume an encounter attempt"
	)
	var effective_tavern: Dictionary = interpreter.runtime_state.get_effective_simple_encounter(
		bundle.get_encounter("simple", 3)
	)
	_expect_equal(
		effective_tavern.get("choiceResults", []).map(
			func(value: Variant) -> int: return int(value)
		),
		[1, 2, 3, 0],
		"opcode 35 removes its source choice"
	)
	_expect_equal(
		bundle.get_encounter("simple", 3).get("choiceResults", []).map(
			func(value: Variant) -> int: return int(value)
		),
		[1, 2, 3, 4],
		"opcode 35 leaves the compiled encounter immutable"
	)
	var restored = StateScript.new()
	restored.restore(interpreter.runtime_state.snapshot())
	_expect_equal(
		restored.get_effective_simple_encounter(bundle.get_encounter("simple", 3))
			.get("choiceResults", []).map(
				func(value: Variant) -> int: return int(value)
			),
		[1, 2, 3, 0],
		"simple option removal survives snapshot restore"
	)
	var cancelled: Dictionary = interpreter.resume_encounter(0)
	_expect_equal(cancelled.get("reason"), "encounter-cancelled", "party can leave the reopened tavern")

	bundle.triggers_by_id["simple-option:remote"] = {
		"id": "simple-option:remote",
		"source": "Data DD",
		"actions": [{"slot": 0, "rawCode": 4, "code": 4, "id": 4}],
	}
	var remote_interpreter = _interpreter(bundle)
	_expect(remote_interpreter.begin_trigger("simple-option:remote"), "begin remote option fixture")
	remote_interpreter.run_until_yield()
	var guards: Dictionary = remote_interpreter.resume_encounter(2)
	_expect_equal(guards.get("payload", {}).get("messageId"), 94, "remote mutation result begins")
	var crypt_map: Dictionary = remote_interpreter.run_until_yield()
	_expect_equal(crypt_map.get("payload", {}).get("messageId"), 95, "remote mutation result continues")
	var completed: Dictionary = remote_interpreter.run_until_yield()
	_expect_equal(completed.get("reason"), "keep-codes", "remote mutation result completes")
	_expect_equal(
		remote_interpreter.runtime_state.get_effective_simple_encounter(
			bundle.get_encounter("simple", 3)
		).get("choiceResults", []).map(
			func(value: Variant) -> int: return int(value)
		),
		[1, 2, 0, 0],
		"opcode 41 removes both Extra Code-selected choices"
	)
	_expect_equal(
		bundle.get_encounter("simple", 3).get("choiceResults", []).map(
			func(value: Variant) -> int: return int(value)
		),
		[1, 2, 3, 4],
		"opcode 41 leaves the compiled target immutable"
	)


func _test_spoken_word_archive() -> void:
	var bundle = BundleScript.new()
	_expect(
		bundle.load_from_directory(COB_SPOKEN_WORD_FIXTURE),
		"CoB spoken-word fixture loads: %s" % bundle.last_error
	)
	if not bundle.last_error.is_empty():
		return
	_expect_equal(bundle.get_player_map(2).get("level"), 0, "Waterford player map index")
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:6:28"), "begin CoB town archive")
	var encounter_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(encounter_result.get("command"), "start_encounter", "archive starts encounter")
	var first_message: Dictionary = interpreter.resume_encounter(1)
	_expect_equal(first_message.get("payload", {}).get("messageId"), 139, "archive result begins")
	var second_message: Dictionary = interpreter.run_until_yield()
	_expect_equal(second_message.get("payload", {}).get("messageId"), 153, "archive result continues")
	var map_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(map_result.get("command"), "give_map", "archive grants the Waterford map")
	_expect_equal(map_result.get("payload", {}).get("mapId"), 2, "archive map ID")
	_expect(not bool(map_result.get("payload", {}).get("display")), "positive map ID does not display")
	_expect(interpreter.runtime_state.is_map_owned(2), "archive map ownership persists")
	var repeated: Dictionary = interpreter.run_until_yield()
	_expect_equal(repeated.get("command"), "start_encounter", "archive reopens after result fallthrough")
	_expect_equal(
		repeated.get("payload", {}).get("remainingAttempts"),
		124,
		"archive decrements its source attempt count"
	)
	var effective: Dictionary = interpreter.runtime_state.get_effective_complex_encounter(
		bundle.get_encounter("complex", 1)
	)
	var first_result_actions: Array = effective.get("actions", []).filter(
		func(action: Dictionary) -> bool: return int(action.get("slot", -1)) < 8
	)
	_expect_equal(first_result_actions.size(), 1, "opcode 44 replaces the first result row")
	_expect_equal(first_result_actions[0].get("rawCode"), 24, "mutated result exits the encounter")
	_expect(
		bundle.get_encounter("complex", 1).get("actions", []).any(
			func(action: Dictionary) -> bool: return int(action.get("rawCode", 0)) == 44
		),
		"complex result mutation leaves the compiled bundle immutable"
	)
	var restored = StateScript.new()
	restored.restore(interpreter.runtime_state.snapshot())
	_expect(restored.is_map_owned(2), "map ownership survives snapshot restore")
	_expect_equal(
		restored.get_effective_complex_encounter(bundle.get_encounter("complex", 1))
			.get("actions", []).filter(
				func(action: Dictionary) -> bool: return int(action.get("slot", -1)) < 8
			).size(),
		1,
		"complex result mutation survives snapshot restore"
	)
	var cancelled: Dictionary = interpreter.resume_encounter(0)
	_expect_equal(cancelled.get("reason"), "encounter-cancelled", "party can leave reopened archive")
	bundle.triggers_by_id["map:display"] = {
		"id": "map:display",
		"source": "Data DD",
		"actions": [{"slot": 0, "rawCode": 29, "code": 29, "id": -2}],
	}
	var display_interpreter = _interpreter(bundle)
	_expect(display_interpreter.begin_trigger("map:display"), "begin display-map fixture")
	var display_map: Dictionary = display_interpreter.run_until_yield()
	_expect(bool(display_map.get("payload", {}).get("display")), "negative map ID requests display")
	_expect(display_interpreter.runtime_state.is_map_owned(2), "displayed map is also acquired")


func _test_percent_branching() -> void:
	var archive_bundle = BundleScript.new()
	_expect(
		archive_bundle.load_from_directory(COB_SPOKEN_WORD_FIXTURE),
		"CoB percent-branch fixture loads: %s" % archive_bundle.last_error
	)
	if not archive_bundle.last_error.is_empty():
		return

	var miss_interpreter = _interpreter(archive_bundle)
	miss_interpreter.set_percent_roll_provider(func() -> int: return 100)
	_expect(miss_interpreter.begin_trigger("Data DD:6:28"), "begin archive chance miss")
	miss_interpreter.run_until_yield()
	var study_message: Dictionary = miss_interpreter.resume_encounter(2)
	_expect_equal(study_message.get("payload", {}).get("messageId"), 141, "chance path begins")
	var missed: Dictionary = miss_interpreter.run_until_yield()
	_expect_equal(missed.get("command"), "start_encounter", "failed chance falls through")
	_expect_equal(
		missed.get("payload", {}).get("remainingAttempts"),
		124,
		"failed chance uses the active encounter loop"
	)

	var hit_interpreter = _interpreter(archive_bundle)
	hit_interpreter.set_percent_roll_provider(func() -> int: return 1)
	_expect(hit_interpreter.begin_trigger("Data DD:6:28"), "begin archive chance hit")
	hit_interpreter.run_until_yield()
	hit_interpreter.resume_encounter(2)
	var redirected: Dictionary = hit_interpreter.run_until_yield()
	_expect_equal(
		redirected.get("command"),
		"start_encounter",
		"successful chance follows the selected empty result row"
	)
	_expect_equal(
		redirected.get("triggerId"),
		"complex encounter:1:outcome:3",
		"result redirection does not start another encounter"
	)

	var bundle = _percent_branch_test_bundle()
	var interpreter = _interpreter(bundle)
	interpreter.set_percent_roll_provider(func() -> int: return 1)
	_expect(interpreter.begin_trigger("chance:ed3"), "begin percent ED3 branch")
	var ed3_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(ed3_result.get("payload", {}).get("messageId"), 500, "chance branches to ED3")

	interpreter = _interpreter(bundle)
	interpreter.set_percent_roll_provider(func() -> int: return 1)
	_expect(interpreter.begin_trigger("Data DD:0:1"), "begin percent keep branch")
	var kept: Dictionary = interpreter.run_until_yield()
	_expect_equal(kept.get("reason"), "keep-codes", "chance keeps source action point")
	_expect_equal(
		interpreter.runtime_state.get_trigger_percent("land", 0, 1, 100),
		100,
		"kept chance branch remains active"
	)

	interpreter = _interpreter(bundle)
	interpreter.set_percent_roll_provider(func() -> int: return 1)
	_expect(interpreter.begin_trigger("Data DD:0:2"), "begin percent consume branch")
	var consumed: Dictionary = interpreter.run_until_yield()
	_expect_equal(consumed.get("reason"), "dropout-and-erase", "chance consumes source action point")
	_expect_equal(
		interpreter.runtime_state.get_trigger_percent("land", 0, 2, 100),
		-1,
		"consumed chance branch persists its disabled percent"
	)

	interpreter = _interpreter(bundle)
	interpreter.set_percent_roll_provider(func() -> int: return 1)
	_expect(interpreter.begin_trigger("chance:slot-seven"), "begin percent dropout branch")
	var slot_seven: Dictionary = interpreter.run_until_yield()
	_expect_equal(slot_seven.get("payload", {}).get("messageId"), 501, "dropout executes slot seven")

	interpreter = _interpreter(bundle)
	interpreter.set_percent_roll_provider(func() -> int: return 1)
	_expect(interpreter.begin_trigger("chance:simple"), "begin simple result redirect")
	interpreter.run_until_yield()
	var simple_redirect: Dictionary = interpreter.resume_encounter(1)
	_expect_equal(
		simple_redirect.get("payload", {}).get("messageId"),
		502,
		"chance selects the loaded simple result row"
	)

	interpreter = _interpreter(bundle)
	interpreter.set_percent_roll_provider(func() -> int: return 1)
	_expect(interpreter.begin_trigger("chance:nested"), "begin nested result redirect")
	interpreter.run_until_yield()
	var nested_complex: Dictionary = interpreter.resume_encounter(1)
	_expect_equal(nested_complex.get("payload", {}).get("encounterId"), 3, "simple result starts nested complex encounter")
	var enclosing_simple: Dictionary = interpreter.resume_encounter(1)
	_expect_equal(
		enclosing_simple.get("payload", {}).get("messageId"),
		503,
		"nested complex result can select its loaded simple row"
	)

	interpreter = _interpreter(bundle)
	interpreter.set_percent_roll_provider(func() -> int: return 1)
	_expect(interpreter.begin_trigger("Data DD:0:3"), "begin encounter chance consume")
	interpreter.run_until_yield()
	var repeated: Dictionary = interpreter.resume_encounter(1)
	_expect_equal(repeated.get("command"), "start_encounter", "encounter chance dropout repeats")
	_expect_equal(
		interpreter.runtime_state.get_trigger_percent("land", 0, 3, 100),
		100,
		"encounter chance dropout does not consume the map action point"
	)


func _test_difficulty_branching() -> void:
	var bundle = _difficulty_branch_test_bundle()
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("difficulty:threshold"), "begin difficulty miss")
	var missed: Dictionary = interpreter.run_until_yield()
	_expect_equal(
		missed.get("payload", {}).get("messageId"),
		701,
		"difficulty below threshold continues the current action point"
	)

	interpreter = _interpreter(bundle)
	interpreter.runtime_state.set_difficulty(1)
	_expect(interpreter.begin_trigger("difficulty:threshold"), "begin difficulty boundary hit")
	var matched: Dictionary = interpreter.run_until_yield()
	_expect_equal(
		matched.get("payload", {}).get("messageId"),
		700,
		"difficulty equal to threshold follows its ED3 branch"
	)

	interpreter = _interpreter(bundle)
	interpreter.runtime_state.set_difficulty(2)
	_expect(interpreter.begin_trigger("difficulty:unused-mode"), "begin unused difficulty mode")
	var unused_mode: Dictionary = interpreter.run_until_yield()
	_expect_equal(
		unused_mode.get("payload", {}).get("messageId"),
		702,
		"unrecognized difficulty success mode continues like Classic"
	)

	interpreter = _interpreter(bundle)
	interpreter.runtime_state.set_difficulty(2)
	_expect(interpreter.begin_trigger("Data DD:0:4"), "begin difficulty consume branch")
	var consumed: Dictionary = interpreter.run_until_yield()
	_expect_equal(consumed.get("reason"), "dropout-and-erase", "difficulty branch consumes source")
	_expect_equal(
		interpreter.runtime_state.get_trigger_percent("land", 0, 4, 100),
		-1,
		"difficulty consume persists the disabled action point"
	)

	interpreter = _interpreter(bundle)
	interpreter.runtime_state.set_difficulty(1)
	_expect(interpreter.begin_trigger("Data DD:0:5"), "begin difficulty keep branch")
	var kept: Dictionary = interpreter.run_until_yield()
	_expect_equal(kept.get("reason"), "keep-codes", "difficulty branch keeps source")
	_expect_equal(
		interpreter.runtime_state.get_trigger_percent("land", 0, 5, 100),
		100,
		"difficulty keep leaves the action point active"
	)


func _test_complex_spell_results(bundle) -> void:
	var adapter = GodotAdapterScript.new()
	var spell_mapping: Dictionary = SpellIdsScript.new().mappings
	var cave_in: Dictionary = bundle.get_encounter("complex", 2)
	var flame_hands = load("res://shared_assets/spells/flame_hands.gd").new()
	var fireball = load("res://shared_assets/spells/fireball.gd").new()
	var fire_flare = load("res://shared_assets/spells/fire_flare.gd").new()
	var festering_wounds = load("res://shared_assets/spells/festering_wounds.gd").new()
	var power_drain = load("res://shared_assets/spells/power_drain.gd").new()
	var priest_power_drain = load(
		"res://shared_assets/spells/classic_power_drain_priest.gd"
	).new()
	var weakness = load("res://shared_assets/spells/weakness.gd").new()
	var improved_power_drain = load(
		"res://shared_assets/spells/improved_power_drain.gd"
	).new()
	var confuse = load("res://shared_assets/spells/confuse.gd").new()
	var daze = load("res://shared_assets/spells/daze.gd").new()
	var discover_magic = load("res://shared_assets/spells/discover_magic.gd").new()
	var area_discover_magic = load(
		"res://shared_assets/spells/classic_discover_magic_area.gd"
	).new()
	var magic_darts = load("res://shared_assets/spells/magic_darts.gd").new()
	var enchanter_magic_darts = load(
		"res://shared_assets/spells/classic_magic_darts_enchanter.gd"
	).new()
	_expect_equal(flame_hands.classic_spell_class, 1, "Flame Hands exports its Classic class")
	_expect_equal(flame_hands.get_range(7, null), 1, "Flame Hands keeps its touch range")
	_expect_equal(flame_hands.get_min_damage(3, null), 3, "Flame Hands minimum scales by power")
	_expect_equal(flame_hands.get_max_damage(3, null), 9, "Flame Hands maximum scales by power")
	_expect_equal(flame_hands.get_sp_cost(3, null), 6, "Flame Hands cost scales by power")
	_expect_equal(fireball.classic_spell_class, 1, "Fireball exports its Classic class")
	_expect_equal(fireball.classic_spell_save_index, 1, "Fireball uses the fire save")
	_expect_equal(fireball.classic_spell_save_mode, "half_damage", "Fireball halves damage on a save")
	_expect_equal(fireball.get_range(7, null), 15, "Fireball keeps its fixed range")
	_expect_equal(fireball.get_min_damage(7, null), 1, "Fireball keeps its fixed minimum damage")
	_expect_equal(fireball.get_max_damage(7, null), 16, "Fireball keeps its fixed maximum damage")
	_expect_equal(fireball.get_sp_cost(3, null), 27, "Fireball cost scales by power")
	_expect_equal(fireball.get_aoe(3, null), Spell.AoE_b3, "Fireball area scales by power")
	_expect(
		fire_flare.supports_classic_spell_id(4606),
		"Fire Flare exports its exact Classic ID"
	)
	_expect_equal(fire_flare.classic_spell_class, 1, "Fire Flare exports its Classic class")
	_expect_equal(fire_flare.get_range(7, null), 6, "Fire Flare keeps its fixed range")
	_expect_equal(fire_flare.get_min_damage(7, null), 1, "Fire Flare keeps its minimum damage")
	_expect_equal(fire_flare.get_max_damage(1, null), 10, "Fire Flare keeps its maximum damage")
	var fire_flare_damage: int = fire_flare.get_damage_roll(7, null)
	_expect(
		fire_flare_damage >= 1 and fire_flare_damage <= 10,
		"Fire Flare rolls its fixed damage range"
	)
	_expect_equal(
		fire_flare.get_duration_roll(3, null),
		3,
		"Fire Flare duration scales by power"
	)
	_expect_equal(fire_flare.get_sp_cost(3, null), 45, "Fire Flare cost scales by power")
	_expect_equal(
		fire_flare.get_aoe(7, null),
		Spell.AoE_b4,
		"Fire Flare keeps its fixed size-4 area"
	)
	_expect_equal(
		fire_flare.resist,
		Spell.RESIST_TYPE.IGNORE_DODGE,
		"Fire Flare checks fire resistance without a projectile dodge"
	)
	_expect(
		not fire_flare.in_combat and not fire_flare.in_field,
		"Fire Flare remains available only through scripted actions"
	)
	_expect(
		festering_wounds.supports_classic_spell_id(2304),
		"Festering Wounds exports its exact Classic ID"
	)
	_expect_equal(
		festering_wounds.classic_spell_class,
		4,
		"Festering Wounds exports its Classic class"
	)
	_expect_equal(festering_wounds.get_range(7, null), 0, "Festering Wounds needs no range")
	_expect_equal(
		festering_wounds.get_min_duration(3, null),
		3,
		"Festering Wounds minimum duration scales by power"
	)
	_expect_equal(
		festering_wounds.get_max_duration(3, null),
		9,
		"Festering Wounds maximum duration scales by power"
	)
	var disease_duration: int = festering_wounds.get_duration_roll(3, null)
	_expect(
		disease_duration >= 3 and disease_duration <= 9,
		"Festering Wounds rolls 1-3 rounds per power"
	)
	_expect_equal(
		festering_wounds.get_sp_cost(3, null),
		36,
		"Festering Wounds cost scales by power"
	)
	_expect_equal(
		festering_wounds.autotarget_type,
		Spell.AUTOTARGET_TYPE.ALL_ENEMIES,
		"Festering Wounds targets every enemy"
	)
	_expect(festering_wounds.skip_targeting, "Festering Wounds needs no target selection")
	_expect_equal(
		festering_wounds.resist,
		Spell.RESIST_TYPE.IGNORE_DODGE,
		"Festering Wounds checks magic resistance without native projectile dodge"
	)
	_expect_equal(
		festering_wounds.get_damage_roll(7, null),
		0,
		"Festering Wounds deals damage through disease rounds"
	)
	var diseased_target := ConditionTestCharacter.new("Diseased target")
	festering_wounds.add_traits_to_creature(null, diseased_target, 3)
	_expect_equal(diseased_target.traits.size(), 1, "Festering Wounds applies one condition trait")
	_expect(
		str(diseased_target.traits[0].name).ends_with("t_classic_disease.gd"),
		"Festering Wounds uses the Classic disease trait"
	)
	_expect(
		diseased_target.traits[0].power >= 3 and diseased_target.traits[0].power <= 9,
		"Festering Wounds passes its rolled duration to the disease trait"
	)
	_expect(power_drain.supports_classic_spell_id(1408), "Power Drain supports CoB's spell ID")
	_expect(power_drain.supports_classic_spell_id(3311), "Power Drain supports its Enchanter ID")
	_expect(
		adapter.classic_spell_resource_supports_id(power_drain, 1408),
		"field-spell adapter accepts a supported Power Drain ID"
	)
	_expect(
		not power_drain.supports_classic_spell_id(2708),
		"Power Drain rejects the mechanically distinct priest spell ID"
	)
	_expect(
		not adapter.classic_spell_resource_supports_id(power_drain, 2708),
		"the shared field-spell resource rejects the distinct Priest Power Drain ID"
	)
	_expect(
		adapter.classic_spell_resource_supports_id(priest_power_drain, 2708),
		"the field-spell adapter accepts the exact Priest Power Drain resource"
	)
	_expect_equal(
		adapter.resolve_complex_spell_result(
			{"spellIds": [1408], "spellResults": [2]},
			"Power Drain",
			7,
			spell_mapping,
			power_drain.classic_spell_ids
		),
		2,
		"complex encounters accept a supported Power Drain ID"
	)
	_expect_equal(
		adapter.resolve_complex_spell_result(
			{"spellIds": [2708], "spellResults": [2]},
			"Power Drain",
			7,
			spell_mapping,
			power_drain.classic_spell_ids
		),
		4,
		"the shared learned spell cannot answer a different Power Drain identity"
	)
	_expect_equal(
		adapter.resolve_complex_spell_result(
			{"spellIds": [2708], "spellResults": [2]},
			"Power Drain",
			7,
			spell_mapping,
			priest_power_drain.classic_spell_ids
		),
		2,
		"the exact Priest Power Drain answers its encounter identity"
	)
	_expect_equal(power_drain.classic_spell_class, 7, "Power Drain exports its Classic class")
	_expect_equal(power_drain.classic_spell_save_index, 7, "Power Drain uses the special save")
	_expect_equal(
		power_drain.classic_spell_save_mode,
		"half_damage",
		"a successful save halves Power Drain"
	)
	_expect_equal(
		power_drain.resist,
		Spell.RESIST_TYPE.IGNORE_DODGE,
		"Power Drain checks magic resistance without native projectile dodge"
	)
	_expect_equal(power_drain.get_range(7, null), 1, "Power Drain keeps its touch range")
	_expect_equal(power_drain.get_sp_cost(3, null), 30, "Power Drain cost scales by power")
	_expect_equal(
		power_drain.get_min_spell_point_drain(3),
		15,
		"Power Drain minimum scales by power"
	)
	_expect_equal(
		power_drain.get_max_spell_point_drain(3),
		24,
		"Power Drain maximum scales by power"
	)
	var spell_point_target := SpellPointTestCreature.new(100)
	var drained_spell_points: int = power_drain.apply_power_drain(spell_point_target, 2)
	_expect(
		drained_spell_points >= 10 and drained_spell_points <= 16,
		"Power Drain rolls once per power level"
	)
	_expect_equal(
		spell_point_target.current_sp,
		100 - drained_spell_points,
		"Power Drain changes current spell points instead of health"
	)
	var nearly_empty_target := SpellPointTestCreature.new(3)
	_expect_equal(
		power_drain.apply_power_drain(nearly_empty_target, 7),
		3,
		"Power Drain cannot remove more spell points than remain"
	)
	_expect_equal(nearly_empty_target.current_sp, 0, "Power Drain clamps spell points at zero")
	var saved_drain_target := SpellPointTestCreature.new(100)
	var saved_drain: int = power_drain.apply_classic_scaled_effect(
		null, saved_drain_target, 2, 0.5
	)
	_expect(saved_drain >= 5 and saved_drain <= 8, "a save halves the rolled spell-point drain")
	_expect_equal(
		saved_drain_target.current_sp,
		100 - saved_drain,
		"scaled Power Drain changes spell points only once"
	)
	_expect_equal(priest_power_drain.classic_spell_ids, [2708], "Priest Power Drain exact ID")
	_expect_equal(
		priest_power_drain.schools,
		[],
		"Priest Power Drain remains a compatibility-only resource"
	)
	_expect_equal(
		priest_power_drain.classic_save_adjust,
		-10,
		"Priest Power Drain scales its save penalty"
	)
	_expect_equal(
		priest_power_drain.classic_resist_adjust,
		-10,
		"Priest Power Drain scales its resistance penalty"
	)
	_expect_equal(priest_power_drain.get_sp_cost(3, null), 105, "Priest Power Drain cost")
	_expect_equal(
		priest_power_drain.get_min_spell_point_drain(3),
		90,
		"Priest Power Drain minimum scales by power"
	)
	_expect_equal(
		priest_power_drain.get_max_spell_point_drain(3),
		120,
		"Priest Power Drain maximum scales by power"
	)
	var priest_drain_target := SpellPointTestCreature.new(1000)
	var priest_drain: int = priest_power_drain.apply_power_drain(priest_drain_target, 2)
	_expect(
		priest_drain >= 60 and priest_drain <= 80,
		"Priest Power Drain rolls 30-40 spell points per power"
	)
	_expect_equal(
		priest_drain_target.current_sp,
		1000 - priest_drain,
		"Priest Power Drain uses the shared spell-point mutation path"
	)
	_expect_equal(weakness.classic_spell_ids, [2612], "Weakness exact ID")
	_expect_equal(weakness.classic_special, 60, "Weakness special")
	_expect_equal(weakness.classic_target_type, 6, "Weakness uses ray targeting")
	_expect(weakness.ray, "Weakness affects creatures along its ray")
	_expect_equal(weakness.get_range(3, null), 6, "Weakness range scales by power")
	_expect_equal(weakness.get_sp_cost(3, null), 120, "Weakness cost scales by power")
	_expect_equal(
		weakness.get_min_spell_point_drain(3),
		30,
		"Weakness recovers the intended minimum from the duration fields"
	)
	_expect_equal(
		weakness.get_max_spell_point_drain(3),
		50,
		"Weakness recovers the intended maximum from the duration fields"
	)
	_expect_equal(weakness.classic_spell_save_index, 7, "Weakness uses the special save")
	_expect_equal(
		weakness.classic_spell_save_mode,
		"half_damage",
		"a successful save halves Weakness"
	)
	var weakness_target := SpellPointTestCreature.new(100)
	var weakness_drain: int = weakness.apply_power_drain(weakness_target, 3)
	_expect(
		weakness_drain >= 30 and weakness_drain <= 50,
		"Weakness rolls its intended fixed drain range"
	)
	_expect_equal(
		weakness_target.current_sp,
		100 - weakness_drain,
		"Weakness drains spell points through the shared mutation path"
	)
	_expect_equal(
		improved_power_drain.classic_spell_ids,
		[2703],
		"Improved Power Drain exact ID"
	)
	_expect_equal(
		improved_power_drain.classic_target_type,
		0,
		"Improved Power Drain selects one creature per power"
	)
	_expect_equal(
		improved_power_drain.get_target_number(3, null),
		3,
		"Improved Power Drain target count scales by power"
	)
	_expect_equal(improved_power_drain.get_range(3, null), 1, "Improved Power Drain range")
	_expect_equal(
		improved_power_drain.get_sp_cost(3, null),
		60,
		"Improved Power Drain cost scales by power"
	)
	_expect_equal(
		improved_power_drain.get_min_spell_point_drain(3),
		6,
		"Improved Power Drain minimum includes its fixed base"
	)
	_expect_equal(
		improved_power_drain.get_max_spell_point_drain(3),
		18,
		"Improved Power Drain maximum includes its fixed base"
	)
	var improved_target := SpellPointTestCreature.new(100)
	var improved_drain: int = improved_power_drain.apply_classic_scaled_effect(
		null,
		improved_target,
		3,
		0.5
	)
	_expect(
		improved_drain >= 3 and improved_drain <= 9,
		"a save halves Improved Power Drain after its source roll"
	)
	_expect_equal(
		improved_target.current_sp,
		100 - improved_drain,
		"Improved Power Drain mutates spell points rather than health"
	)
	_expect(confuse.supports_classic_spell_id(2301), "Confuse exports its exact Classic ID")
	_expect_equal(confuse.classic_spell_class, 5, "Confuse exports its Classic class")
	_expect_equal(confuse.get_range(7, null), 9, "Confuse keeps its fixed range")
	_expect_equal(confuse.get_duration_roll(3, null), 3, "Confuse lasts one round per power")
	_expect_equal(confuse.get_sp_cost(3, null), 45, "Confuse cost scales by power")
	_expect_equal(confuse.get_aoe(1, null), Spell.AoE_b7, "Confuse keeps its fixed size-7 area")
	_expect_equal(confuse.get_damage_roll(7, null), 0, "Confuse does not deal health damage")
	_expect_equal(
		confuse.resist,
		Spell.RESIST_TYPE.IGNORE_DODGE,
		"Confuse checks magic resistance without native projectile dodge"
	)
	var confused_target := ConditionTestCharacter.new("Confused target")
	confuse.add_traits_to_creature(null, confused_target, 3)
	_expect_equal(confused_target.traits.size(), 1, "Confuse applies one condition trait")
	_expect(
		str(confused_target.traits[0].name).ends_with("t_classic_confused.gd"),
		"Confuse uses Classic's temporary confusion condition"
	)
	_expect_equal(confused_target.traits[0].power, 3, "Confuse passes its Classic duration")
	_expect(daze.supports_classic_spell_id(3202), "Daze exports its exact Classic ID")
	_expect_equal(daze.classic_spell_class, 0, "Daze exports its Classic class")
	_expect_equal(daze.classic_spell_save_index, 0, "Daze uses Classic's charm save")
	_expect_equal(daze.classic_spell_save_mode, "negate", "Daze's charm save negates confusion")
	_expect_equal(daze.classic_save_bonus, -15, "Daze keeps its source save penalty")
	_expect_equal(daze.get_range(3, null), 9, "Daze range scales by power")
	_expect_equal(daze.get_min_duration(7, null), 1, "Daze keeps its minimum duration")
	_expect_equal(daze.get_max_duration(1, null), 4, "Daze keeps its maximum duration")
	var daze_duration: int = daze.get_duration_roll(7, null)
	_expect(daze_duration >= 1 and daze_duration <= 4, "Daze rolls a 1-4 round duration")
	_expect_equal(daze.get_sp_cost(3, null), 21, "Daze cost scales by power")
	_expect_equal(daze.get_aoe(7, null), Spell.AoE_b1, "Daze ray has a one-tile base area")
	_expect(daze.ray, "Daze includes every creature along its ray")
	_expect(not daze.los, "Daze's negative range coefficient disables LOS blocking")
	_expect_equal(
		daze.resist,
		Spell.RESIST_TYPE.IGNORE_DODGE,
		"Daze checks resistance without a projectile dodge"
	)
	_expect_equal(daze.get_damage_roll(7, null), 0, "Daze does not deal health damage")
	var dazed_target := ConditionTestCharacter.new("Dazed target")
	daze.add_traits_to_creature(null, dazed_target, 7)
	_expect_equal(dazed_target.traits.size(), 1, "Daze applies one condition trait")
	_expect(
		str(dazed_target.traits[0].name).ends_with("t_classic_confused.gd"),
		"Daze shares the reviewed Classic confusion condition"
	)
	_expect(
		dazed_target.traits[0].power >= 1 and dazed_target.traits[0].power <= 4,
		"Daze passes its rolled duration to the confusion trait"
	)
	_expect_equal(discover_magic.classic_spell_class, 8, "Discover Magic exports its Classic class")
	_expect(discover_magic.supports_classic_spell_id(1101), "single-target Discover Magic supports 1101")
	_expect(
		not discover_magic.supports_classic_spell_id(2102),
		"single-target Discover Magic rejects the priest area variant"
	)
	_expect_equal(
		adapter.classic_spell_response_ids(discover_magic),
		[1101, 2102, 3102],
		"native Discover Magic can answer its three Classic caster-list entries"
	)
	_expect_equal(
		adapter.resolve_complex_spell_result(
			{"spellIds": [2102], "spellResults": [2]},
			discover_magic.name,
			discover_magic.classic_spell_class,
			spell_mapping,
			adapter.classic_spell_response_ids(discover_magic)
		),
		2,
		"Discover Magic response aliases reach the priest encounter result"
	)
	_expect(
		area_discover_magic.supports_classic_spell_id(2102)
		and area_discover_magic.supports_classic_spell_id(3102),
		"area Discover Magic supports its priest and enchanter IDs"
	)
	_expect_equal(
		area_discover_magic.schools,
		[],
		"compatibility-only area spell stays out of native learning lists"
	)
	_expect_equal(
		area_discover_magic.get_aoe(3, null),
		Spell.AoE_b3,
		"area Discover Magic scales its target area by power"
	)
	_expect_equal(magic_darts.classic_spell_class, 6, "Magic Darts exports its Classic class")
	_expect_equal(magic_darts.classic_spell_ids, [1108], "native Magic Darts owns Sorcerer ID 1108")
	_expect_equal(
		adapter.classic_spell_response_ids(magic_darts),
		[1108, 3208],
		"native Magic Darts can answer both caster-list encounter identities"
	)
	_expect_equal(magic_darts.get_range(7, null), 15, "Magic Darts keeps its fixed range")
	_expect_equal(magic_darts.get_target_number(4, null), 4, "Magic Darts targets once per power")
	_expect_equal(
		magic_darts.targettile,
		Spell.TARGET_TILE.CREATURE,
		"Magic Darts requires each selected Classic target to be a creature"
	)
	_expect_equal(magic_darts.get_min_damage(7, null), 1, "Sorcerer Magic Darts minimum damage")
	_expect_equal(magic_darts.get_max_damage(7, null), 5, "Sorcerer Magic Darts maximum damage")
	_expect_equal(magic_darts.get_sp_cost(3, null), 12, "Magic Darts cost scales by power")
	_expect_equal(magic_darts.classic_spell_save_mode, "none", "Magic Darts bypasses DRV saves")
	_expect_equal(
		magic_darts.resist,
		Spell.RESIST_TYPE.IGNORE_MRES_DODGE,
		"Magic Darts force-affects without resistance or projectile dodge"
	)
	_expect_equal(
		enchanter_magic_darts.classic_spell_ids,
		[3208],
		"Enchanter Magic Darts keeps its distinct Classic identity"
	)
	_expect_equal(
		enchanter_magic_darts.schools,
		[],
		"compatibility-only Enchanter variant stays out of native learning lists"
	)
	_expect_equal(
		enchanter_magic_darts.get_max_damage(7, null),
		4,
		"Enchanter Magic Darts preserves its lower damage maximum"
	)
	_expect_equal(
		adapter.classic_spell_mapping_key(1201),
		"10010",
		"packed Dig Hole ID resolves to Remake's spell-table key"
	)
	_expect_equal(
		adapter.resolve_complex_spell_result(cave_in, "Dig Hole", 0, spell_mapping),
		1,
		"exact complex spell selects its shipped result"
	)
	_expect_equal(
		adapter.resolve_complex_spell_result(cave_in, "Flesh", 0, spell_mapping),
		2,
		"duplicate caster-school spell names share their authored result"
	)
	_expect_equal(
		adapter.resolve_complex_spell_result(cave_in, "Hands to Clay", 0, spell_mapping),
		4,
		"explicit spell can select Classic's failure result"
	)
	_expect_equal(
		adapter.resolve_complex_spell_result(cave_in, "Magic Darts", 0, spell_mapping),
		4,
		"unmatched complex spell defaults to result 4"
	)
	_expect_equal(
		adapter.resolve_complex_spell_result(
			{"spellIds": [1], "spellResults": [3]},
			"Flame Hands",
			1,
			spell_mapping
		),
		3,
		"explicit Classic spell-class metadata selects a class shortcut"
	)
	_expect_equal(
		adapter.resolve_complex_spell_result(
			{"spellIds": [1101], "spellResults": [1]},
			"Discover Magic",
			0,
			spell_mapping
		),
		1,
		"Remake's Discover Magic name matches the legacy Sorcerer alias"
	)


func _test_complex_item_results(bundle) -> void:
	var adapter = GodotAdapterScript.new()
	var item_mapping: Dictionary = ItemIdsScript.new().mapping
	var trapped_chest: Dictionary = bundle.get_encounter("complex", 3)
	var locked_door: Dictionary = bundle.get_encounter("complex", 4)
	_expect_equal(
		adapter.resolve_complex_item_result(
			trapped_chest,
			"Iron Key",
			item_mapping,
			[]
		),
		2,
		"exact complex item selects its shipped result"
	)
	_expect_equal(
		adapter.resolve_complex_item_result(
			trapped_chest,
			"Necklace of Keys",
			item_mapping,
			[]
		),
		2,
		"second authored item can share an encounter result"
	)
	_expect_equal(
		adapter.resolve_complex_item_result(
			locked_door,
			"Iron Key",
			item_mapping,
			[]
		),
		4,
		"unmatched complex item defaults to result 4"
	)
	_expect_equal(
		adapter.resolve_complex_item_result(
			{"itemIds": [900], "itemResults": [3]},
			"Scenario Seal",
			{},
			[{
				"itemId": 900,
				"identifiedName": "Scenario Seal",
				"unidentifiedName": "Wax Seal",
			}]
		),
		3,
		"scenario item text can identify a complex response item"
	)
	_expect_equal(
		adapter.resolve_complex_item_result(
			{"itemIds": [878], "itemResults": [2]},
			"Renamed Rope",
			{},
			[],
			878
		),
		2,
		"stable Classic item metadata survives native item renaming"
	)
	_expect_equal(
		adapter.resolve_complex_item_result(
			{"itemIds": [878], "itemResults": [2]},
			"Renamed Rope",
			{},
			[],
			[801, 878]
		),
		2,
		"an item with multiple Classic identities selects the matching response"
	)
	_expect_equal(
		adapter._classic_item_names(
			878,
			{},
			[],
			{"Campaign Rope": {"classicItemId": 878}}
		),
		["Campaign Rope"],
		"scenario-local item metadata resolves without display-name guessing"
	)


func _test_complex_response_modes() -> void:
	var bundle = BundleScript.new()
	_expect(
		bundle.load_from_directory(COMPLEX_RESPONSE_MODES_FIXTURE),
		"complex response fixture loads: %s" % bundle.last_error
	)
	if not bundle.last_error.is_empty():
		return
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:0:0"), "begin complex response fixture")
	var encounter_result: Dictionary = interpreter.run_until_yield()
	var payload: Dictionary = encounter_result.get("payload", {})
	_expect_equal(encounter_result.get("command"), "start_encounter", "fixture starts encounter")
	_expect_equal(
		payload.get("scenarioItems", []).size(),
		3,
		"complex payload includes compiled scenario items"
	)

	var encounter: Dictionary = payload.get("encounter", {})
	var scenario_items: Array = payload.get("scenarioItems", [])
	var adapter = GodotAdapterScript.new()
	var scroll := {
		"name": "Renamed Fireball Scroll",
		"classicItemId": 900,
		"charges": 1,
		"charges_max": 1,
		"delete_on_empty": 1,
	}
	var door_sigil := {
		"name": "Door Sigil",
		"classicItemId": 901,
		"charges": 2,
		"charges_max": 2,
		"delete_on_empty": 0,
	}
	var ordinary_item := {
		"name": "Renamed Brass Key",
		"classicItemId": 902,
		"charges": 1,
		"charges_max": 1,
	}
	var scroll_mode: Dictionary = adapter.classify_complex_item(scroll, scenario_items)
	_expect_equal(scroll_mode.get("mode"), "spell-item", "type-20 item enters spell response")
	_expect_equal(scroll_mode.get("spellId"), 1306, "compiled scroll preserves spell ID")
	_expect_equal(scroll_mode.get("spellPower"), 2, "compiled scroll preserves spell power")
	var native_scroll := {
		"name": "Fireball",
		"type": "Scroll",
		"_on_combat_use_spell": ["Fireball (1306)", 1],
	}
	var native_scroll_mode: Dictionary = adapter.classify_complex_item(
		native_scroll,
		scenario_items
	)
	_expect_equal(native_scroll_mode.get("spellName"), "Fireball", "native scroll label is normalized")
	_expect_equal(native_scroll_mode.get("spellId"), 1306, "native scroll retains embedded Classic ID")
	_expect(
		adapter.is_complex_scroll_item(native_scroll, scenario_items),
		"native scroll can use Classic's separate scroll response"
	)
	var spell_staff := native_scroll.duplicate(true)
	spell_staff["type"] = "Staff"
	_expect(
		not adapter.is_complex_scroll_item(spell_staff, scenario_items),
		"spell-bearing staves remain on Classic's item-response path"
	)
	var fireball = load("res://shared_assets/spells/fireball.gd").new()
	var spell_mapping: Dictionary = SpellIdsScript.new().mappings
	_expect_equal(
		adapter.resolve_complex_spell_result(
			encounter,
			fireball.name,
			fireball.classic_spell_class,
			spell_mapping,
			fireball.classic_spell_ids
		),
		2,
		"compiled scroll spell selects the authored exact-ID result"
	)
	var class_encounter := encounter.duplicate(true)
	class_encounter["spellIds"] = [1]
	class_encounter["spellResults"] = [3]
	_expect_equal(
		adapter.resolve_complex_spell_result(
			class_encounter,
			fireball.name,
			fireball.classic_spell_class,
			spell_mapping,
			fireball.classic_spell_ids
		),
		3,
		"compiled low-ID spell class remains a valid response"
	)

	var scroll_holder := InventoryTestCharacter.new()
	scroll_holder.inventory = [scroll]
	var scroll_use: Dictionary = adapter.consume_complex_item(scroll_holder, scroll)
	_expect_equal(scroll_use.get("remainingCharges"), 0, "scroll response consumes a charge")
	_expect(bool(scroll_use.get("removed", false)), "empty disposable scroll is removed")
	_expect(scroll_holder.inventory.is_empty(), "consumed scroll leaves its owner's inventory")

	var door_mode: Dictionary = adapter.classify_complex_item(door_sigil, scenario_items)
	_expect_equal(door_mode.get("mode"), "door-activation", "type-23 item activates a door")
	_expect_equal(
		door_mode.get("doorActivationActionPointId"),
		7,
		"compiled door item preserves its Data ED3 target"
	)
	var door_holder := InventoryTestCharacter.new()
	door_holder.inventory = [door_sigil]
	var door_use: Dictionary = adapter.consume_complex_item(door_holder, door_sigil)
	_expect_equal(door_use.get("remainingCharges"), 1, "door activation consumes one charge")
	_expect_equal(door_holder.inventory.size(), 1, "charged door item remains in inventory")
	var door_result: Dictionary = interpreter.resume_encounter(0, {
		"doorActivationActionPointId": 7,
	})
	_expect_equal(door_result.get("status"), "completed", "door Data ED3 action completes")
	_expect(interpreter.runtime_state.is_quest_set(42), "door Data ED3 mutation persists")
	var restored = StateScript.new()
	restored.configure_from_bundle(bundle)
	restored.restore(interpreter.runtime_state.snapshot())
	_expect(restored.is_quest_set(42), "door mutation survives snapshot restore")

	var ordinary_mode: Dictionary = adapter.classify_complex_item(ordinary_item, scenario_items)
	_expect_equal(ordinary_mode.get("mode"), "item", "ordinary item keeps item-response mode")
	_expect_equal(
		adapter.resolve_complex_item_result(
			encounter,
			str(ordinary_item["name"]),
			{},
			payload.get("itemTexts", []),
			adapter._classic_item_ids(ordinary_item)
		),
		3,
		"ordinary compiled item selects its authored result"
	)
	_expect_equal(
		adapter.resolve_complex_item_selection(
			encounter,
			{"name": "Unmatched Token"},
			{},
			payload.get("itemTexts", []),
			scenario_items
		).get("outcome"),
		4,
		"unmatched item keeps Classic's result-4 fallback"
	)

	var resolver = RogueResolverScript.new()
	_expect(
		resolver.configure(encounter, payload.get("thiefEncounter", {})),
		"configure compiled trap-spell fixture"
	)
	var sprung_trap: Dictionary = resolver.resolve_action(6, true)
	_expect_equal(sprung_trap.get("status"), "trap", "armed fixture trap springs")
	_expect_equal(sprung_trap.get("trap", {}).get("spellId"), 1110, "trap preserves spell ID")
	_expect_equal(sprung_trap.get("trap", {}).get("spellPower"), 2, "trap preserves spell power")
	var rogue := RogueTestCharacter.new()
	var companion := RogueTestCharacter.new()
	companion.name = "Companion"
	var spell_request: Dictionary = adapter.rogue_trap_spell_request(
		sprung_trap.get("trap", {}),
		rogue,
		[rogue, companion]
	)
	_expect_equal(spell_request.get("targets", []).size(), 1, "rogue-only trap selects one target")
	_expect_equal(spell_request.get("targets", [])[0], rogue, "trap spell targets selected rogue")
	_expect_equal(spell_request.get("payload", {}).get("spellId"), 1110, "trap uses field-spell payload")
	var shine = ShineScript.new()
	_expect(shine.supports_classic_spell_id(1110), "Shine exposes its exact Classic identity")
	_expect(shine.supports_classic_spell_id(2110), "Shine exposes the equivalent Priest identity")
	_expect_equal(shine.classic_spell_save_mode, "none", "Shine uses the no-save field flow")
	var readiness_context := {"spells": {
		"Fireball": {
			"classicSpellClass": fireball.classic_spell_class,
			"classicSpellIds": fireball.classic_spell_ids,
			"classicSpellSaveIndex": fireball.classic_spell_save_index,
			"classicSpellSaveMode": fireball.classic_spell_save_mode,
		},
		"Shine": {
			"classicSpellClass": shine.classic_spell_class,
			"classicSpellIds": shine.classic_spell_ids,
			"classicSpellSaveIndex": shine.classic_spell_save_index,
			"classicSpellSaveMode": shine.classic_spell_save_mode,
		},
	}}
	var readiness: Dictionary = ReadinessScript.new().inspect(bundle, readiness_context)
	var readiness_codes: Array = readiness.get("diagnostics", []).map(
		func(diagnostic: Dictionary) -> String: return str(diagnostic.get("code", ""))
	)
	_expect(
		not readiness_codes.has("missing-native-spell"),
		"compiled trap and item spells have native resources"
	)
	_expect(
		not readiness_codes.has("missing-door-action-point"),
		"compiled door item resolves its Data ED3 target"
	)
	bundle.extra_action_points_by_id.erase(7)
	readiness = ReadinessScript.new().inspect(bundle, readiness_context)
	readiness_codes = readiness.get("diagnostics", []).map(
		func(diagnostic: Dictionary) -> String: return str(diagnostic.get("code", ""))
	)
	_expect(
		"missing-door-action-point" in readiness_codes,
		"readiness blocks a door item whose Data ED3 target is absent"
	)


func _test_shipped_lock_encounter(bundle) -> void:
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:5:12"), "begin shipped CoB lock encounter")
	var encounter_result: Dictionary = interpreter.run_until_yield()
	var payload: Dictionary = encounter_result.get("payload", {})
	_expect_equal(encounter_result.get("command"), "start_encounter", "lock starts complex encounter")
	_expect_equal(payload.get("encounterId"), 4, "lock resolves Data ED2 record 4")
	_expect_equal(payload.get("thiefEncounter", {}).get("id"), 4, "lock resolves Data TD2 record 4")

	var resolver = RogueResolverScript.new()
	_expect(
		resolver.configure(payload.get("encounter", {}), payload.get("thiefEncounter", {})),
		"configure shipped rogue encounter"
	)
	_expect_equal(
		resolver.available_actions().map(func(action: Dictionary) -> int: return int(action["index"])),
		[1, 4, 6],
		"shipped lock exposes Detect Trap, Force Lock, and Pick Lock"
	)
	_expect_equal(resolver.success_percent(6, 35.0), 45, "Pick Lock applies Data TD2 modifier")
	var choice_model: Dictionary = GodotAdapterScript.new().build_rogue_encounter_choices(
		resolver,
		RogueTestCharacter.new(),
		true
	)
	_expect_equal(
		choice_model.get("tokens"),
		["rogue:1", "rogue:4", "rogue:6", "back"],
		"Godot adapter exposes shipped rogue actions and back-out"
	)
	var failed_pick: Dictionary = resolver.resolve_action(6, false)
	_expect_equal(failed_pick.get("outcome"), 0, "failed lockpick remains in complex encounter")
	_expect_equal(failed_pick.get("messageId"), 3, "failed lockpick resolves shipped text")
	_expect_equal(failed_pick.get("soundId"), 696, "failed lockpick resolves shipped sound")
	_expect(
		not bool(failed_pick.get("thiefEncounter", {}).get("typeFlags", [])[6]),
		"failed lockpick consumes the Pick Lock action"
	)
	var cancelled: Dictionary = interpreter.resume_encounter(0, failed_pick)
	_expect_equal(cancelled.get("reason"), "encounter-cancelled", "party can leave failed lock encounter")
	_expect(
		bool(bundle.get_thief_encounter(4).get("typeFlags", [])[6]),
		"rogue encounter mutation leaves bundle immutable"
	)
	_expect(
		not bool(interpreter.runtime_state.get_effective_thief_encounter(
			bundle.get_thief_encounter(4)
		).get("typeFlags", [])[6]),
		"failed lockpick persists in runtime state"
	)

	var restored = StateScript.new()
	restored.configure_from_bundle(bundle)
	restored.restore(interpreter.runtime_state.snapshot())
	_expect(
		not bool(restored.get_effective_thief_encounter(
			bundle.get_thief_encounter(4)
		).get("typeFlags", [])[6]),
		"failed lockpick survives snapshot restore"
	)

	interpreter = _interpreter(bundle)
	interpreter.begin_trigger("Data DD:5:12")
	payload = interpreter.run_until_yield().get("payload", {})
	resolver = RogueResolverScript.new()
	resolver.configure(payload.get("encounter", {}), payload.get("thiefEncounter", {}))
	var successful_pick: Dictionary = resolver.resolve_action(6, true)
	_expect_equal(successful_pick.get("outcome"), 1, "successful lockpick selects result 1")
	var sound_result: Dictionary = interpreter.resume_encounter(1, successful_pick)
	_expect_equal(sound_result.get("command"), "play_sound", "lock result begins with shipped sound")
	_expect_equal(sound_result.get("payload", {}).get("soundId"), 141, "lock result sound id")
	var text_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(text_result.get("command"), "show_text", "lock result continues to shipped text")
	_expect_equal(text_result.get("payload", {}).get("messageId"), 4, "successful lock text id")


func _test_shipped_trap_encounter(bundle) -> void:
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:5:3"), "begin shipped CoB trapped chest")
	var encounter_result: Dictionary = interpreter.run_until_yield()
	var payload: Dictionary = encounter_result.get("payload", {})
	_expect_equal(payload.get("encounterId"), 3, "trapped chest resolves Data ED2 record 3")
	_expect_equal(payload.get("thiefEncounter", {}).get("id"), 1, "trapped chest resolves Data TD2 record 1")
	_expect_equal(
		payload.get("thiefMessages", []).map(func(message: Dictionary) -> int: return int(message["id"])),
		[7, 5, 4, 1, 6, 3],
		"rogue payload excludes trap parameters from text messages"
	)

	var resolver = RogueResolverScript.new()
	_expect(
		resolver.configure(payload.get("encounter", {}), payload.get("thiefEncounter", {})),
		"configure shipped trapped chest"
	)
	_expect_equal(
		resolver.available_actions().map(func(action: Dictionary) -> int: return int(action["index"])),
		[1, 6],
		"armed chest exposes Detect Trap and Pick Lock"
	)
	var detected: Dictionary = resolver.resolve_action(1, true)
	_expect_equal(detected.get("messageId"), 7, "Detect Trap uses shipped success text")
	_expect(
		bool(detected.get("thiefEncounter", {}).get("typeFlags", [])[2]),
		"Detect Trap enables Disarm Trap"
	)
	_expect(
		bool(detected.get("thiefEncounter", {}).get("typeFlags", [])[9]),
		"Detect Trap leaves the trap armed"
	)
	var disarmed: Dictionary = resolver.resolve_action(2, true)
	_expect_equal(disarmed.get("messageId"), 5, "Disarm Trap uses shipped success text")
	_expect(
		not bool(disarmed.get("thiefEncounter", {}).get("typeFlags", [])[9]),
		"successful Disarm Trap clears armed state"
	)

	resolver = RogueResolverScript.new()
	resolver.configure(payload.get("encounter", {}), payload.get("thiefEncounter", {}))
	var sprung_trap: Dictionary = resolver.resolve_action(6, true)
	_expect_equal(sprung_trap.get("status"), "trap", "armed chest springs before lock roll")
	_expect_equal(sprung_trap.get("trap", {}).get("damageLow"), 4, "shipped trap minimum damage")
	_expect_equal(sprung_trap.get("trap", {}).get("damageHigh"), 12, "shipped trap maximum damage")
	_expect_equal(sprung_trap.get("trap", {}).get("soundId"), 692, "shipped trap sound id")
	_expect(bool(sprung_trap.get("trap", {}).get("rogueOnly")), "shipped trap targets selected rogue")
	var sprung_flags: Array = sprung_trap.get("thiefEncounter", {}).get("typeFlags", [])
	_expect(not bool(sprung_flags[9]), "sprung trap clears armed state")
	_expect(not bool(sprung_flags[1]), "sprung trap consumes Detect Trap")
	_expect(bool(sprung_flags[6]), "sprung trap leaves Pick Lock available")

	var rogue := RogueTestCharacter.new()
	var damage_result: Dictionary = GodotAdapterScript.new().apply_rogue_trap_damage(
		sprung_trap.get("trap", {}),
		rogue,
		[rogue]
	)
	_expect_equal(damage_result.get("hits", []).size(), 1, "trap damages only selected rogue")
	_expect(rogue.current_hp >= 18 and rogue.current_hp <= 26, "trap applies shipped 4-12 damage range")

	var cancelled: Dictionary = interpreter.resume_encounter(0, sprung_trap)
	_expect_equal(cancelled.get("reason"), "encounter-cancelled", "party can regroup after sprung trap")
	var persisted: Dictionary = interpreter.runtime_state.get_effective_thief_encounter(
		bundle.get_thief_encounter(1)
	)
	_expect(not bool(persisted.get("typeFlags", [])[9]), "sprung trap state persists")
	_expect(bool(bundle.get_thief_encounter(1).get("typeFlags", [])[9]), "trap leaves bundle record immutable")

	_expect(interpreter.begin_trigger("Data DD:5:3"), "restart sprung CoB chest")
	payload = interpreter.run_until_yield().get("payload", {})
	resolver = RogueResolverScript.new()
	resolver.configure(payload.get("encounter", {}), payload.get("thiefEncounter", {}))
	var successful_pick: Dictionary = resolver.resolve_action(6, true)
	_expect_equal(successful_pick.get("outcome"), 2, "sprung chest lock selects result 2")
	var text_result: Dictionary = interpreter.resume_encounter(2, successful_pick)
	_expect_equal(text_result.get("command"), "show_text", "sprung chest result starts with source text")
	_expect_equal(text_result.get("payload", {}).get("messageId"), 210, "sprung chest result text id")
	var treasure_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(treasure_result.get("command"), "give_treasure", "sprung chest result gives treasure")
	_expect_equal(treasure_result.get("payload", {}).get("treasureId"), 8, "sprung chest treasure id")
	var completed: Dictionary = interpreter.run_until_yield()
	_expect_equal(completed.get("status"), "completed", "sprung chest result completes")
	_expect_equal(
		interpreter.runtime_state.get_trigger_percent("land", 5, 3, 100),
		-1,
		"sprung chest action point is consumed"
	)


func _test_battle_outcome(bundle) -> void:
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:4:44", 4), "begin CoB battle-outcome action")
	var battle_result: Dictionary = interpreter.run_until_yield()
	var payload: Dictionary = battle_result.get("payload", {})
	_expect_equal(battle_result.get("command"), "start_battle", "battle-outcome command")
	_expect_equal(payload.get("battleIdRange"), [250, 250], "battle-outcome range")
	_expect_equal(payload.get("cowardMacroId"), -1, "coward penalty sentinel")
	_expect_equal(payload.get("battle", {}).get("id"), 250, "battle-outcome battle resolves")
	var blocked_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(blocked_result.get("status"), "error", "battle outcome requires explicit resume")
	var coward_result: Dictionary = interpreter.resume_battle(true)
	_expect_equal(coward_result.get("command"), "apply_coward_penalty", "coward sentinel command")
	var coward_payload: Dictionary = coward_result.get("payload", {})
	_expect_equal(coward_payload.get("experiencePerLevel"), 2000, "Classic coward penalty")
	_expect_equal(coward_payload.get("warningIds"), [118, 124], "Classic coward warnings")
	_expect_equal(coward_payload.get("soundId"), 26260, "Classic coward sound")
	_expect_equal(coward_payload.get("levelType"), "land", "Classic coward level family")
	_expect(bool(coward_payload.get("backUpParty", false)), "Classic coward retreat request")

	interpreter = _interpreter(bundle)
	interpreter.runtime_state.set_location("dungeon", 0, 4, 44)
	_expect(interpreter.begin_trigger("Data DD:4:44", 4), "begin dungeon battle-outcome action")
	interpreter.run_until_yield()
	var dungeon_coward: Dictionary = interpreter.resume_battle(true)
	_expect_equal(
		dungeon_coward.get("payload", {}).get("levelType"),
		"dungeon",
		"dungeon coward outcome preserves its map family"
	)
	_expect(
		not bool(dungeon_coward.get("payload", {}).get("backUpParty", true)),
		"Classic dungeon coward outcome does not request a retreat"
	)

	interpreter = _interpreter(bundle)
	interpreter.begin_trigger("Data DD:4:44", 4)
	interpreter.run_until_yield()
	var victory_result: Dictionary = interpreter.resume_battle(false)
	_expect_equal(victory_result.get("command"), "give_battle_loot", "victory resumes through battle loot")


func _test_coward_experience_penalty() -> void:
	var adapter = GodotAdapterScript.new()
	var second_level = CowardPenaltyTestCharacter.new(2, 1000)
	var fifth_level = CowardPenaltyTestCharacter.new(5, 4000)
	var result: Dictionary = adapter.apply_classic_coward_experience_penalty(
		[second_level, fifth_level, {}],
		2000
	)
	_expect_equal(second_level.exp_tnl, 5000, "coward penalty increases level-two exp to next level")
	_expect_equal(fifth_level.exp_tnl, 14000, "coward penalty increases level-five exp to next level")
	_expect_equal(result.get("charactersAffected"), 2, "coward penalty counts compatible party members")
	_expect_equal(result.get("experienceRemoved"), 14000, "coward penalty reports the total experience loss")
	_expect_equal(result.get("experiencePerLevel"), 2000, "coward penalty reports its source rate")


func _test_coward_party_retreat() -> void:
	var adapter = GodotAdapterScript.new()
	var game_global = CowardRetreatTestGameGlobal.new()
	var result: Dictionary = adapter.retreat_classic_party(
		game_global,
		Vector2i(1, -1)
	)
	_expect(bool(result.get("partyBackedUp", false)), "coward retreat moves the party")
	_expect_equal(result.get("fromPosition"), Vector2i(12, 7), "coward retreat reports origin")
	_expect_equal(result.get("position"), Vector2i(11, 8), "coward retreat reverses entry movement")
	_expect_equal(
		Vector2i(
			game_global.map.focuscharacter.tile_position_x,
			game_global.map.focuscharacter.tile_position_y
		),
		Vector2i(11, 8),
		"coward retreat moves the map focus"
	)
	_expect_equal(
		Vector2i(
			game_global.map.owcharacter.tile_position_x,
			game_global.map.owcharacter.tile_position_y
		),
		Vector2i(11, 8),
		"coward retreat moves the overworld character"
	)
	_expect_equal(
		game_global.map.explored_positions,
		[Vector2i(11, 8)],
		"coward retreat refreshes exploration at the restored tile"
	)

	var missing_movement: Dictionary = adapter.retreat_classic_party(
		game_global,
		Vector2i.ZERO
	)
	_expect(
		not bool(missing_movement.get("partyBackedUp", true)),
		"coward retreat requires an entry movement"
	)
	_expect(
		str(missing_movement.get("backUpReason", "")).contains("unavailable"),
		"missing coward movement remains explicit"
	)


func _test_battle_outcome_host() -> void:
	var bundle = _battle_outcome_test_bundle()
	var host = HostScript.new()
	get_root().add_child(host)
	var host_adapter = BattleOutcomeAdapter.new()
	var completions: Array = []
	host.playthrough_completed.connect(func(result: Dictionary) -> void: completions.append(result))
	host.configure(host_adapter)
	host.runtime.runtime_state.configure_from_bundle(bundle)
	host.runtime.interpreter.configure(bundle, host.runtime.runtime_state)
	_expect(host.start_trigger("battle:outcome"), "host starts victory battle outcome")
	_expect_equal(
		host_adapter.commands.map(
			func(entry: Dictionary) -> String: return entry["command"]
		),
		["start_battle", "give_battle_loot"],
		"native victory resumes the suspended Classic action list once"
	)
	_expect_equal(
		host.runtime.last_result.get("status"),
		"completed",
		"victory battle outcome reaches a completed interpreter state"
	)
	_expect(not host.active, "victory battle outcome closes the runtime host")
	host.queue_free()

	host = HostScript.new()
	get_root().add_child(host)
	host_adapter = BattleOutcomeAdapter.new()
	host_adapter.coward = true
	completions = []
	host.playthrough_completed.connect(func(result: Dictionary) -> void: completions.append(result))
	host.configure(host_adapter)
	host.runtime.runtime_state.configure_from_bundle(bundle)
	host.runtime.interpreter.configure(bundle, host.runtime.runtime_state)
	_expect(
		host.start_trigger(
			"battle:outcome",
			0,
			{"entryMovement": Vector2i(1, 0)}
		),
		"host starts authored-loss battle outcome"
	)
	_expect_equal(
		host_adapter.commands.map(
			func(entry: Dictionary) -> String: return entry["command"]
		),
		["start_battle", "apply_coward_penalty"],
		"native loss resumes the suspended Classic penalty path once"
	)
	_expect_equal(
		host_adapter.commands[-1].get("payload", {}).get("entryMovement"),
		Vector2i(1, 0),
		"battle entry movement reaches the coward penalty command"
	)
	_expect_equal(completions.size(), 1, "authored-loss battle outcome completes once")
	host.queue_free()


func _test_state_snapshot(bundle) -> void:
	var state = StateScript.new()
	state.configure_from_bundle(bundle)
	state.set_quest_flag(20)
	state.set_location("dungeon", 5, 6, 83)
	state.set_dungeon_view(4, false)
	state.set_compass_enabled(false)
	state.view_type = StateScript.VIEW_MAP
	state.set_darkland("land", 4, 1)
	state.set_darkland("dungeon", 0, -1)
	state.set_landlook("land", 4, 10)
	state.set_random_rectangle("land", 4, 2, {
		"rectIndex": 2,
		"percent": 900,
		"battleRange": [1, 2],
	})
	state.set_tile("land", 0, 3, 28, 193)
	state.set_trigger_percent("land", 0, 17, 100)
	state.set_difficulty(1)
	state.set_priest_turning_enabled(false)
	var restored = StateScript.new()
	restored.restore(state.snapshot())
	_expect(restored.is_quest_set(20), "quest flag survives snapshot")
	_expect_equal(restored.level_type, "dungeon", "map family survives snapshot")
	_expect_equal(restored.level_index, 5, "position survives snapshot")
	_expect_equal(restored.x, 6, "snapshot x")
	_expect_equal(restored.y, 83, "snapshot y")
	_expect_equal(restored.heading, 4, "dungeon heading survives snapshot")
	_expect_equal(restored.multi_view, false, "dungeon multiview survives snapshot")
	_expect_equal(restored.view_type, StateScript.VIEW_MAP, "signed dungeon view type survives snapshot")
	_expect_equal(restored.compass_enabled, false, "compass state survives snapshot")
	_expect_equal(restored.get_darkland("land", 4, 0), 1, "land darkness survives snapshot")
	_expect_equal(restored.get_darkland("dungeon", 0, 0), -1, "dungeon darkness is map-specific")
	_expect_equal(restored.get_landlook("land", 4, 0), 10, "land-look survives snapshot")
	_expect_equal(
		restored.get_random_rectangle("land", 4, 2, {}).get("battleRange"),
		[1, 2],
		"random rectangle survives snapshot"
	)
	_expect_equal(restored.get_tile("land", 0, 3, 28, -1), 193, "tile override survives snapshot")
	_expect_equal(restored.get_trigger_percent("land", 0, 17, -1), 100, "trigger override survives snapshot")
	_expect_equal(restored.difficulty, 1, "difficulty survives snapshot")
	_expect_equal(restored.priest_turning_enabled, false, "priest-turning gate survives snapshot")
	restored.set_difficulty(10)
	_expect_equal(restored.difficulty, 2, "difficulty is capped at Classic's hardest setting")
	restored.set_difficulty(-10)
	_expect_equal(restored.difficulty, -2, "difficulty is capped at Classic's easiest setting")


func _test_full_bundle(path: String) -> void:
	var bundle = BundleScript.new()
	_expect(bundle.load_from_directory(path), "full CoB bundle loads: %s" % bundle.last_error)
	if not bundle.last_error.is_empty():
		return
	_expect_equal(bundle.triggers_by_id.size(), 1341, "full CoB trigger index")
	_expect_equal(bundle.extra_action_points_by_id.size(), 241, "full CoB ED3 AP index")
	_expect_equal(bundle.extra_codes_by_id.size(), 5282, "full CoB Extra Code index")
	_expect_equal(bundle.messages_by_id.size(), 881, "full CoB message index")
	_expect_equal(bundle.battles_by_id.size(), 257, "full CoB battle index")
	_expect_equal(bundle.treasures_by_id.size(), 76, "full CoB treasure index")
	_expect_equal(bundle.shops_by_id.size(), 16, "full CoB shop index")
	_expect_equal(bundle.monsters_by_id.size(), 155, "full CoB monster index")
	_expect_equal(bundle.get_monster(71).get("displayName"), "Vodalian", "full CoB ally monster index")
	_expect_equal(bundle.simple_encounters_by_id.size(), 20, "full CoB simple encounter index")
	_expect_equal(bundle.complex_encounters_by_id.size(), 14, "full CoB complex encounter index")
	_expect_equal(bundle.thief_encounters_by_id.size(), 8, "full CoB rogue encounter index")
	_expect_equal(bundle.timed_encounters_by_id.size(), 3, "full CoB timed encounter index")
	_expect_equal(bundle.maps_by_id.size(), 11, "full CoB map index")
	_expect_equal(bundle.player_maps_by_id.size(), 20, "full CoB player map index")
	_expect_equal(bundle.random_levels_by_id.size(), 11, "full CoB random-level index")
	_expect_equal(bundle.pictures_by_id.size(), 1, "full CoB picture index")
	_expect_equal(bundle.get_picture(32128).get("resourceType"), "PICT", "full CoB picture metadata")
	_expect_equal(bundle.dispatcher_noop_keys.size(), 470, "full CoB dispatcher no-op evidence index")
	var coordinate_trigger_count := 0
	for coordinate: Variant in bundle.triggers_by_coordinate:
		coordinate_trigger_count += bundle.triggers_by_coordinate[coordinate].size()
	_expect_equal(coordinate_trigger_count, 658, "full CoB active coordinate trigger index")
	var active_slots := 0
	var handled_slots := 0
	for trigger_value: Variant in bundle.triggers_by_id.values():
		if not bool(trigger_value.get("active", false)):
			continue
		for action_value: Variant in trigger_value.get("actions", []):
			active_slots += 1
			if InterpreterScript.handles_opcode(int(action_value.get("code", 0))):
				handled_slots += 1
	_expect_equal(active_slots, 2734, "full CoB active action slots")
	_expect_equal(handled_slots, 2264, "full CoB directly handled action slots")
	_expect_equal(handled_slots + bundle.dispatcher_noop_keys.size(), 2734, "full CoB defined-behavior slots")
	var execution_report: Dictionary = ExecutionAuditScript.new().inspect(bundle)
	var execution_totals: Dictionary = execution_report.get("totals", {})
	_expect(
		int(execution_report.get("contexts", {}).get("data-ed-result", {}).get("actions", 0)) > 0,
		"full CoB audit includes Data ED result actions"
	)
	_expect(
		int(execution_report.get("contexts", {}).get("data-ed2-result", {}).get("actions", 0)) > 0,
		"full CoB audit includes Data ED2 result actions"
	)
	_expect_equal(
		_audit_diagnostic_count(execution_report, "unsupported-action"),
		execution_totals.get("unknownExecutable"),
		"full CoB audit reports every executable unknown action"
	)
	_expect_equal(
		execution_totals.get("unknownExecutable"),
		0,
		"full CoB audit has no executable unknown actions"
	)

	var battle_end_interpreter = _interpreter(bundle)
	_expect(
		battle_end_interpreter.begin_trigger("Data ED3:macro:153", 5),
		"begin shipped CoB forced battle end"
	)
	var battle_end: Dictionary = battle_end_interpreter.run_until_yield()
	_expect_equal(battle_end.get("command"), "end_classic_battle", "shipped opcode 100 yields battle end")
	_expect_equal(battle_end.get("payload", {}).get("lootMode"), 5, "shipped battle end keeps loot mode")
	_expect_equal(
		battle_end.get("payload", {}).get("rewardMode"),
		"experience_only",
		"shipped battle end requests experience-only rewards"
	)

	for shipped_rout: Array in [
		["Data ED3:macro:109", 2, 387, [92, 129, 130, 116]],
		["Data ED3:macro:133", 1, 437, [49]],
		["Data ED3:macro:135", 2, 440, [92, 93, 129, 130]],
	]:
		var rout_interpreter = _interpreter(bundle)
		_expect(
			rout_interpreter.begin_trigger(shipped_rout[0], shipped_rout[1]),
			"begin shipped CoB combat rout %s" % shipped_rout[0]
		)
		var rout: Dictionary = rout_interpreter.run_until_yield()
		_expect_equal(rout.get("command"), "rout_combat_monsters", "shipped opcode 123 yields rout")
		_expect_equal(
			rout.get("payload", {}).get("extraCodeId"),
			shipped_rout[2],
			"shipped rout preserves Extra Code ID"
		)
		_expect_equal(
			rout.get("payload", {}).get("monsterIds"),
			shipped_rout[3],
			"shipped rout preserves monster IDs"
		)

	for shipped_spawn: Array in [
		["Data ED3:macro:94", 4, 647, 133, 6, 30000],
		["Data ED3:macro:94", 5, 649, 125, 3, 30000],
		["Data ED3:macro:110", 5, 405, 0, 0, 640],
		["Data ED3:macro:112", 5, 405, 0, 0, 640],
		["Data ED3:macro:113", 3, 402, 62, 6, 640],
		["Data ED3:macro:114", 2, 411, 73, 2, 640],
		["Data ED3:macro:115", 2, 412, 72, 2, 640],
		["Data ED3:macro:116", 1, 406, 83, -3, 640],
		["Data ED3:macro:118", 2, 420, 78, -10, 30002],
		["Data ED3:macro:120", 2, 422, 80, -8, 30001],
		["Data ED3:macro:122", 2, 424, 92, -4, 10136],
		["Data ED3:macro:122", 3, 425, 130, -2, 10136],
		["Data ED3:macro:124", 2, 432, 80, -10, 0],
		["Data ED3:macro:127", 2, 427, 4, 1, 605],
		["Data ED3:macro:130", 2, 433, 1, 12, 626],
		["Data ED3:macro:132", 1, 435, 76, -3, 626],
		["Data ED3:macro:132", 2, 436, 21, -2, 626],
		["Data ED3:macro:138", 4, 385, 91, -4, 30000],
		["Data ED3:macro:161", 5, 405, 0, 0, 640],
	]:
		var spawn_interpreter = _interpreter(bundle)
		var is_round_macro: bool = [118, 120, 122, 124, 127, 130, 132].has(
			int(str(shipped_spawn[0]).get_slice(":", 2))
		)
		_expect(
			spawn_interpreter.begin_trigger(
				shipped_spawn[0],
				shipped_spawn[1],
				{"battleMacro": -1 if is_round_macro else 0}
			),
			"begin shipped CoB combat spawn %s slot %d" % [shipped_spawn[0], shipped_spawn[1]]
		)
		var spawn: Dictionary = spawn_interpreter.run_until_yield()
		if int(shipped_spawn[4]) == 0:
			_expect(
				spawn.get("command") != "spawn_combat_monsters",
				"shipped zero-count spawn remains a no-op"
			)
			continue
		_expect_equal(spawn.get("command"), "spawn_combat_monsters", "shipped opcode 124 yields spawn")
		var spawn_payload: Dictionary = spawn.get("payload", {})
		_expect_equal(spawn_payload.get("extraCodeId"), shipped_spawn[2], "shipped spawn preserves Extra Code ID")
		_expect_equal(spawn_payload.get("monsterId"), shipped_spawn[3], "shipped spawn preserves monster ID")
		_expect_equal(spawn_payload.get("authoredCount"), shipped_spawn[4], "shipped spawn preserves signed count")
		_expect_equal(spawn_payload.get("soundId"), shipped_spawn[5], "shipped spawn preserves sound")
		var resolved_count := int(spawn_payload.get("spawnCount", 0))
		if int(shipped_spawn[4]) < 0:
			_expect(
				resolved_count >= 1 and resolved_count <= abs(int(shipped_spawn[4])),
				"shipped random spawn resolves inside its inclusive range"
			)
		else:
			_expect_equal(resolved_count, shipped_spawn[4], "shipped fixed spawn count is exact")
		_expect_equal(
			spawn_payload.get("inheritActorFaction"),
			not is_round_macro,
			"shipped spawn preserves actor/template faction rule"
		)

	for shipped_round_macro: Array in [
		["Data ED3:macro:117", 1, 415, 3, 118, false],
		["Data ED3:macro:119", 0, 421, 2, 120, true],
		["Data ED3:macro:121", 1, 430, 2, 122, true],
		["Data ED3:macro:123", 0, 431, 2, 124, true],
		["Data ED3:macro:126", 0, 426, 2, 127, true],
		["Data ED3:macro:131", 1, 434, 2, 132, true],
		["Data ED3:macro:134", 0, 438, 2, 130, false],
	]:
		var round_interpreter = _interpreter(bundle)
		round_interpreter.set_percent_roll_provider(func() -> int: return 1)
		_expect(
			round_interpreter.begin_trigger(
				shipped_round_macro[0],
				shipped_round_macro[1],
				{"combatRound": shipped_round_macro[3], "battleMacro": -1}
			),
			"begin shipped CoB battle-round macro %s" % shipped_round_macro[0]
		)
		var round_activation: Dictionary = round_interpreter.run_until_yield()
		_expect_equal(
			round_activation.get("command"),
			"activate_battle_round_macro",
			"shipped opcode 126 yields typed activation"
		)
		_expect_equal(
			round_activation.get("payload", {}).get("extraCodeId"),
			shipped_round_macro[2],
			"shipped round macro preserves Extra Code ID"
		)
		_expect_equal(
			round_activation.get("payload", {}).get("targetMacroId"),
			shipped_round_macro[4],
			"shipped round macro preserves target"
		)
		_expect_equal(
			round_activation.get("payload", {}).get("repeat"),
			shipped_round_macro[5],
			"shipped round macro preserves repeat mode"
		)

	var deanimate_interpreter = _interpreter(bundle)
	_expect(
		deanimate_interpreter.begin_trigger("Data ED3:macro:107", 2),
		"begin shipped CoB lower-undead deanimation"
	)
	var deanimate: Dictionary = deanimate_interpreter.run_until_yield()
	_expect_equal(deanimate.get("command"), "deanimate_lower_undead", "shipped opcode 121 yields typed mutation")
	var lower_undead_ids: Array = deanimate.get("payload", {}).get("monsterIds", [])
	for lower_undead_id: int in [17, 65, 70, 75, 78, 84, 85, 86]:
		_expect(lower_undead_ids.has(lower_undead_id), "shipped deanimation includes lower undead %d" % lower_undead_id)
	for higher_undead_id: int in [19, 100, 135]:
		_expect(not lower_undead_ids.has(higher_undead_id), "shipped deanimation protects higher undead %d" % higher_undead_id)

	for shipped_destruction: Array in [
		["Data ED3:macro:110", 2, 389, 37, 8],
		["Data ED3:macro:112", 2, 399, 42, 100],
		["Data ED3:macro:125", 4, 423, 4, 100],
		["Data ED3:macro:161", 2, 656, 44, 100],
	]:
		var destruction_interpreter = _interpreter(bundle)
		_expect(
			destruction_interpreter.begin_trigger(shipped_destruction[0], shipped_destruction[1]),
			"begin shipped CoB combat destruction %s" % shipped_destruction[0]
		)
		var destruction: Dictionary = destruction_interpreter.run_until_yield()
		_expect_equal(
			destruction.get("command"),
			"destroy_combat_monsters",
			"shipped opcode 125 yields typed mutation"
		)
		_expect_equal(
			destruction.get("payload", {}).get("extraCodeId"),
			shipped_destruction[2],
			"shipped destruction preserves Extra Code ID"
		)
		_expect_equal(
			destruction.get("payload", {}).get("monsterNameId"),
			shipped_destruction[3],
			"shipped destruction preserves monster name ID"
		)
		_expect_equal(
			destruction.get("payload", {}).get("maxMatches"),
			shipped_destruction[4],
			"shipped destruction preserves match limit"
		)

	for shipped_monster_check: Array in [
		["Data ED3:macro:121", 441],
		["Data ED3:macro:131", 31],
		["Data ED3:macro:135", 439],
		["Data ED3:macro:138", 400],
		["Data ED3:macro:94", 134],
	]:
		var combat_interpreter = _interpreter(bundle)
		_expect(
			combat_interpreter.begin_trigger(shipped_monster_check[0]),
			"begin shipped CoB combat-monster check %s" % shipped_monster_check[0]
		)
		var combat_check: Dictionary = combat_interpreter.run_until_yield()
		_expect_equal(
			combat_check.get("command"),
			"check_combat_monster",
			"shipped opcode 127 yields typed check"
		)
		_expect_equal(
			combat_check.get("payload", {}).get("monsterNameId"),
			shipped_monster_check[1],
			"shipped combat check preserves monster name ID"
		)

	for shipped_priest_turning: Array in [
		[
			"Data DD:6:9",
			0,
			true,
			20004,
			"You regain your ability to turn undead and nether spawn.",
		],
		[
			"Data DD:6:10",
			2,
			false,
			10105,
			"You may not use your ability to turn undead or nether spawn.",
		],
	]:
		var priest_interpreter = _interpreter(bundle)
		_expect(
			priest_interpreter.begin_trigger(shipped_priest_turning[0], shipped_priest_turning[1]),
			"begin shipped CoB priest-turning action %s" % shipped_priest_turning[0]
		)
		var priest_result: Dictionary = priest_interpreter.run_until_yield()
		_expect_equal(priest_result.get("command"), "set_priest_turning", "shipped turning yields typed command")
		_expect_equal(
			priest_result.get("payload", {}).get("enabled"),
			shipped_priest_turning[2],
			"shipped turning preserves enabled state"
		)
		_expect_equal(
			priest_result.get("payload", {}).get("soundId"),
			shipped_priest_turning[3],
			"shipped turning preserves sound"
		)
		_expect_equal(
			priest_result.get("payload", {}).get("message", {}).get("text"),
			shipped_priest_turning[4],
			"shipped turning preserves feedback"
		)
		_expect_equal(
			priest_interpreter.runtime_state.priest_turning_enabled,
			shipped_priest_turning[2],
			"shipped turning updates runtime state"
		)

	var condition_interpreter = _interpreter(bundle)
	_expect(
		condition_interpreter.begin_trigger("Data DD:3:15", 2),
		"begin shipped CoB Waterworld branch"
	)
	var condition_check: Dictionary = condition_interpreter.run_until_yield()
	_expect_equal(condition_check.get("command"), "check_party_condition", "shipped condition yields typed check")
	_expect_equal(condition_check.get("payload", {}).get("conditionIndex"), 1, "shipped condition checks Waterworld")
	var waterworld_branch: Dictionary = condition_interpreter.resume_party_condition_check(true)
	_expect_equal(waterworld_branch.get("command"), "start_encounter", "active Waterworld follows shipped branch")
	_expect_equal(waterworld_branch.get("payload", {}).get("encounterKind"), "complex", "Waterworld branch is complex")
	_expect_equal(waterworld_branch.get("payload", {}).get("encounterId"), 8, "Waterworld branch preserves encounter ID")
	condition_interpreter = _interpreter(bundle)
	condition_interpreter.begin_trigger("Data DD:3:15", 2)
	condition_interpreter.run_until_yield()
	_expect_equal(
		condition_interpreter.resume_party_condition_check(false).get("command"),
		"set_trigger_percent",
		"inactive Waterworld continues the shipped action point"
	)

	for shipped_ally_check: Array in [
		["Data DD:0:82", 2, 71],
		["Data ED3:macro:104", 7, 77],
	]:
		var ally_interpreter = _interpreter(bundle)
		_expect(
			ally_interpreter.begin_trigger(shipped_ally_check[0], shipped_ally_check[1]),
			"begin shipped CoB ally check %s" % shipped_ally_check[0]
		)
		var ally_check: Dictionary = ally_interpreter.run_until_yield()
		_expect_equal(ally_check.get("command"), "check_party_ally", "shipped ally yields typed check")
		_expect_equal(
			ally_check.get("payload", {}).get("monsterNameId"),
			shipped_ally_check[2],
			"shipped ally check preserves monster name ID"
		)

	var add_ally_interpreter = _interpreter(bundle)
	_expect(
		add_ally_interpreter.begin_trigger("Data ED3:macro:103", 5),
		"begin shipped CoB add-ally action"
	)
	var add_ally: Dictionary = add_ally_interpreter.run_until_yield()
	_expect_equal(add_ally.get("command"), "add_party_ally", "shipped add ally yields typed mutation")
	_expect_equal(add_ally.get("payload", {}).get("monsterId"), 71, "shipped add ally preserves Vodalian ID")

	for shipped_registration: Array in [
		["Data DD:0:37", 1, "keep-codes"],
		["Data ED3:macro:106", 0, "action-point-ended"],
	]:
		var registration_interpreter = _interpreter(bundle)
		_expect(
			registration_interpreter.begin_trigger(shipped_registration[0], shipped_registration[1]),
			"begin shipped CoB registration action %s" % shipped_registration[0]
		)
		var registration_result: Dictionary = registration_interpreter.run_until_yield()
		_expect_equal(registration_result.get("status"), "completed", "registration action continues")
		_expect_equal(
			registration_result.get("reason"),
			shipped_registration[2],
			"registration action preserves surrounding flow"
		)

	var malformed_random_interpreter = _interpreter(bundle)
	_expect(
		malformed_random_interpreter.begin_trigger("Data ED3:macro:197", 7),
		"begin malformed shipped CoB random branch"
	)
	var malformed_random: Dictionary = malformed_random_interpreter.run_until_yield()
	_expect_equal(malformed_random.get("status"), "error", "malformed shipped random branch remains explicit")
	_expect("-1700" in str(malformed_random.get("message", "")), "malformed random branch retains signed row ID")

	for shipped_click: Array in [
		["Data DD:7:55", 6],
		["Data DD:8:55", 6],
		["Data DDD:1:55", 6],
	]:
		var click_interpreter = _interpreter(bundle)
		_expect(
			click_interpreter.begin_trigger(shipped_click[0], shipped_click[1]),
			"begin shipped CoB click acknowledgement %s" % shipped_click[0]
		)
		var click_result: Dictionary = click_interpreter.run_until_yield()
		_expect_equal(click_result.get("command"), "wait_for_click", "shipped click yields typed command")
		_expect_equal(click_result.get("payload", {}).get("soundId"), 30005, "shipped click preserves sound")

	for shipped_picture: Array in [
		["Data DD:0:76", 0],
		["Data ED3:macro:162", 0],
	]:
		var picture_interpreter = _interpreter(bundle)
		_expect(
			picture_interpreter.begin_trigger(shipped_picture[0], shipped_picture[1]),
			"begin shipped CoB picture %s" % shipped_picture[0]
		)
		var picture_result: Dictionary = picture_interpreter.run_until_yield()
		_expect_equal(picture_result.get("command"), "show_picture", "shipped picture yields typed command")
		_expect_equal(picture_result.get("payload", {}).get("pictureId"), 32128, "shipped picture preserves ID")
		_expect_equal(
			picture_result.get("payload", {}).get("picture", {}).get("resourceType"),
			"PICT",
			"shipped picture resolves catalog metadata"
		)

	var redraw_interpreter = _interpreter(bundle)
	_expect(
		redraw_interpreter.begin_trigger("Data ED3:macro:73", 1),
		"begin shipped CoB map redraw"
	)
	_expect_equal(
		redraw_interpreter.run_until_yield().get("command"),
		"redraw_map",
		"shipped map redraw yields typed command"
	)

	for shipped_item_check: Array in [
		["Data DD:0:1", 1, 21, 990],
		["Data DD:0:2", 3, 38, 991],
		["Data ED3:macro:32", 1, 38, 808],
	]:
		var check_interpreter = _interpreter(bundle)
		_expect(
			check_interpreter.begin_trigger(shipped_item_check[0], shipped_item_check[1]),
			"begin shipped CoB item check %s" % shipped_item_check[0]
		)
		var check_result: Dictionary = check_interpreter.run_until_yield()
		_expect_equal(check_result.get("command"), "check_party_item", "shipped item check yields typed command")
		_expect_equal(
			check_result.get("payload", {}).get("itemId"),
			shipped_item_check[3],
			"shipped opcode %d preserves item ID" % shipped_item_check[2]
		)

	for shipped_item_mutation: Array in [
		["Data ED3:macro:33", 2, 808],
		["Data ED3:macro:39", 3, 807],
	]:
		var mutation_interpreter = _interpreter(bundle)
		_expect(
			mutation_interpreter.begin_trigger(shipped_item_mutation[0], shipped_item_mutation[1]),
			"begin shipped CoB item mutation %s" % shipped_item_mutation[0]
		)
		var mutation_result: Dictionary = mutation_interpreter.run_until_yield()
		_expect_equal(mutation_result.get("command"), "alter_party_items", "shipped item mutation yields typed command")
		_expect_equal(
			mutation_result.get("payload", {}).get("itemId"),
			shipped_item_mutation[2],
			"shipped item mutation preserves item ID"
		)

	for shipped_equipment_restore: Array in [
		["Data DD:1:19", 5],
		["Data DD:2:3", 4],
		["Data DD:8:49", 3],
		["Data DDD:1:49", 3],
	]:
		var restore_interpreter = _interpreter(bundle)
		_expect(
			restore_interpreter.begin_trigger(
				shipped_equipment_restore[0],
				shipped_equipment_restore[1]
			),
			"begin shipped CoB equipment restore %s" % shipped_equipment_restore[0]
		)
		var restore_result: Dictionary = restore_interpreter.run_until_yield()
		_expect_equal(restore_result.get("command"), "store_party_equipment", "shipped equipment restore yields typed command")
		_expect(not bool(restore_result.get("payload", {}).get("capture")), "shipped opcode 36 restores stored equipment")

	for shipped_shop: Array in [
		["Data DD:0:9", 2, 1],
		["Data DD:0:29", 2, 4],
		["Data DD:0:94", 1, 10],
		["Data DD:5:91", 1, 3],
		["Data ED3:macro:8", 1, 2],
	]:
		var shop_interpreter = _interpreter(bundle)
		_expect(
			shop_interpreter.begin_trigger(shipped_shop[0], shipped_shop[1]),
			"begin shipped CoB shop action %s" % shipped_shop[0]
		)
		var shop_result: Dictionary = shop_interpreter.run_until_yield()
		_expect_equal(shop_result.get("command"), "load_shop", "shipped shop yields typed command")
		_expect_equal(
			shop_result.get("payload", {}).get("shopId"),
			shipped_shop[2],
			"shipped shop record resolves"
		)
	var restricted_shop_interpreter = _interpreter(bundle)
	_expect(
		restricted_shop_interpreter.begin_trigger("Data ED3:macro:174", 5),
		"begin shipped CoB restricted-shop data row"
	)
	var restricted_shop_result: Dictionary = restricted_shop_interpreter.run_until_yield()
	_expect_equal(
		restricted_shop_result.get("command"),
		"load_shop",
		"shipped restricted-shop row yields typed command"
	)
	_expect_equal(
		restricted_shop_result.get("payload", {}).get("shopId"),
		1,
		"restricted shop resolves shop ID through Extra Code"
	)
	_expect_equal(
		restricted_shop_result.get("payload", {}).get("acceptRanges"),
		[1, 100, 0, 0],
		"restricted shop preserves shipped acceptance ranges"
	)
	var malformed_shop_interpreter = _interpreter(bundle)
	_expect(
		malformed_shop_interpreter.begin_trigger("Data ED3:macro:174", 3),
		"begin unresolved CoB restricted-shop row"
	)
	_expect_equal(
		malformed_shop_interpreter.run_until_yield().get("status"),
		"error",
		"missing restricted-shop Extra Code remains an explicit data error"
	)
	var shop_bank_interpreter = _interpreter(bundle)
	_expect(
		shop_bank_interpreter.begin_trigger("Data DD:0:9", 1),
		"begin shipped shop banking action"
	)
	_expect_equal(
		shop_bank_interpreter.run_until_yield().get("command"),
		"enable_banking",
		"shop banking action yields typed command"
	)
	var temple_interpreter = _interpreter(bundle)
	_expect(
		temple_interpreter.begin_trigger("Data DD:0:10", 1),
		"begin shipped temple service actions"
	)
	_expect_equal(
		temple_interpreter.run_until_yield().get("command"),
		"enable_banking",
		"temple entry enables banking first"
	)
	var standard_temple: Dictionary = temple_interpreter.run_until_yield()
	_expect_equal(standard_temple.get("command"), "offer_temple", "temple entry yields typed command")
	_expect_equal(
		standard_temple.get("payload", {}).get("costPercent"),
		100,
		"shipped temple uses standard prices"
	)
	var expensive_temple_interpreter = _interpreter(bundle)
	_expect(
		expensive_temple_interpreter.begin_trigger("Data ED3:macro:85", 1),
		"begin shipped expensive temple action"
	)
	_expect_equal(
		expensive_temple_interpreter.run_until_yield().get("payload", {}).get("costPercent"),
		300,
		"shipped expensive temple preserves its percentage"
	)
	var first_shop: Dictionary = bundle.get_shop(1)
	_expect_equal(
		first_shop.get("quantities", [])[0],
		3,
		"shipped Dagger stock quantity resolves"
	)
	var available_items_value: Variant = JSON.parse_string(
		FileAccess.get_file_as_string("res://shared_assets/items/stuff_book.json")
	)
	var available_items: Dictionary = available_items_value \
		if available_items_value is Dictionary else {}
	var shop_adapter = GodotAdapterScript.new()
	var built_shop_count := 0
	var resource_gap_count := 0
	for shop_value: Variant in bundle.shops_by_id.values():
		if not (shop_value is Dictionary):
			continue
		var built_shop: Dictionary = shop_adapter.build_shop_inventory(
			{
				"shop": shop_value,
				"itemTexts": bundle.item_texts_by_id.values(),
			},
			ItemIdsScript.new().mapping,
			available_items
		)
		var shop_id := int(shop_value.get("id", -1))
		if str(built_shop.get("status", "")).is_empty():
			built_shop_count += 1
		else:
			resource_gap_count += 1
			_expect(
				str(built_shop.get("message", "")).begins_with("Classic shop item "),
				"full CoB shop %d stops explicitly for unavailable item resources" % shop_id
			)
	_expect(built_shop_count >= 11, "all empty full CoB shops build for the native UI")
	_expect_equal(
		built_shop_count + resource_gap_count,
		16,
		"every full CoB shop either builds or reports its resource gap"
	)

	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:0:58", 1), "begin CoB branching battle outcome")
	var branch_battle: Dictionary = interpreter.run_until_yield()
	_expect_equal(branch_battle.get("payload", {}).get("cowardMacroId"), 144, "coward ED3 branch id")
	var coward_branch: Dictionary = interpreter.resume_battle(true)
	_expect_equal(coward_branch.get("command"), "teleport", "coward outcome executes ED3 branch")
	_expect_equal(coward_branch.get("payload", {}).get("extraCodeId"), 641, "coward branch reaches CoB teleport")


func _test_godot_runtime_facade() -> void:
	var runtime = RuntimeScript.new()
	var commands: Array = []
	var stops: Array = []
	var completions: Array = []
	runtime.command_requested.connect(
		func(command: String, payload: Dictionary) -> void:
			commands.append({"command": command, "payload": payload})
	)
	runtime.runtime_stopped.connect(func(result: Dictionary) -> void: stops.append(result))
	runtime.trigger_completed.connect(func(result: Dictionary) -> void: completions.append(result))
	_expect(runtime.load_campaign(FIXTURE), "Godot runtime facade loads CoB fixture")
	runtime.set_difficulty(10)
	_expect_equal(runtime.runtime_state.difficulty, 2, "facade sets Classic difficulty")
	_expect_equal(runtime.triggers_at("land", 0, 9, 17).size(), 1, "facade exposes map trigger lookup")
	_expect(runtime.activate_trigger("Data DD:0:0"), "facade activates CoB trigger")
	_expect_equal(commands.size(), 1, "facade emits native command signal")
	_expect_equal(commands[0].get("command"), "show_text", "facade emits text command")
	runtime.continue_after_command()
	_expect_equal(commands.size(), 2, "facade emits encounter request")
	_expect_equal(commands[1].get("command"), "start_encounter", "facade emits encounter command")
	runtime.finish_encounter(4)
	_expect_equal(commands.size(), 3, "facade emits encounter outcome command")
	_expect_equal(commands[2].get("command"), "show_text", "facade executes encounter result")
	runtime.continue_after_command()
	_expect_equal(completions.size(), 1, "facade completes encounter result")
	_expect_equal(stops.size(), 0, "facade stays within implemented slice")


func _test_encounter_continuation_restore() -> void:
	var bundle = _continuation_encounter_test_bundle()
	var adapter = SuspendedCommandAdapter.new()
	var host = _continuation_test_host(bundle, adapter)
	_expect(
		host.start_trigger("continuation:encounter", 0, {"actorFaction": 7}),
		"encounter continuation fixture starts"
	)
	_expect_equal(adapter.commands[0].get("command"), "start_encounter", "encounter suspends at its prompt")
	var saved_result: Dictionary = host.make_continuation_snapshot()
	_expect_equal(saved_result.get("status"), "ok", "encounter continuation can be saved")
	var saved: Dictionary = _json_round_trip(saved_result.get("snapshot", {}))
	_expect(not saved.is_empty(), "encounter continuation is JSON serializable")
	_release_suspended_host(host, adapter)

	var restored_adapter = SuspendedCommandAdapter.new()
	var restored_host = _continuation_test_host(bundle, restored_adapter)
	_expect_equal(
		restored_host.restore_continuation(saved).get("status"),
		"ok",
		"encounter continuation restores into a fresh host"
	)
	_expect(restored_host.has_restored_continuation(), "restored encounter waits for native map setup")
	_expect_equal(
		restored_host.resume_restored_continuation().get("status"),
		"ok",
		"restored encounter replays after map setup"
	)
	_expect_equal(restored_adapter.commands[0].get("command"), "start_encounter", "restored encounter reopens")
	_expect_equal(
		restored_adapter.commands[0].get("payload", {}).get("actorFaction"),
		7,
		"restored encounter retains its command context"
	)
	restored_adapter.respond({"outcome": 4})
	await process_frame
	_expect_equal(
		restored_adapter.commands[-1].get("payload", {}).get("messageId"),
		404,
		"restored encounter enters its selected result block"
	)
	restored_adapter.respond()
	await process_frame
	_expect_equal(restored_adapter.commands[-1].get("command"), "start_encounter", "encounter repetition survives load")
	_expect_equal(
		restored_adapter.commands[-1].get("payload", {}).get("remainingAttempts"),
		1,
		"encounter attempt count survives load"
	)
	restored_adapter.respond({"outcome": 4})
	await process_frame
	_expect_equal(
		restored_adapter.commands[-1].get("payload", {}).get("messageId"),
		303,
		"restored final attempt keeps Classic timeout routing"
	)
	restored_adapter.respond()
	await process_frame
	_expect(not restored_host.active, "restored encounter completes once")
	restored_host.queue_free()


func _test_gosub_continuation_restore() -> void:
	var bundle = _stack_test_bundle()
	var adapter = SuspendedCommandAdapter.new()
	var host = _continuation_test_host(bundle, adapter)
	_expect(host.start_trigger("stack:sticky"), "GOSUB continuation fixture starts")
	_expect_equal(
		adapter.commands[0].get("payload", {}).get("messageId"),
		902,
		"GOSUB continuation suspends in its innermost XAP"
	)
	var saved_result: Dictionary = host.make_continuation_snapshot()
	var saved: Dictionary = _json_round_trip(saved_result.get("snapshot", {}))
	_expect_equal(
		saved.get("executionState", {}).get("callStack", []).size(),
		2,
		"GOSUB continuation serializes every return frame"
	)
	_release_suspended_host(host, adapter)

	var restored_adapter = SuspendedCommandAdapter.new()
	var restored_host = _continuation_test_host(bundle, restored_adapter)
	_expect_equal(restored_host.restore_continuation(saved).get("status"), "ok", "GOSUB continuation restores")
	restored_host.resume_restored_continuation()
	for expected_message_id: int in [902, 901, 900]:
		_expect_equal(
			restored_adapter.commands[-1].get("payload", {}).get("messageId"),
			expected_message_id,
			"restored GOSUB resumes message %d at its authored slot" % expected_message_id
		)
		restored_adapter.respond()
		await process_frame
	_expect(not restored_host.active, "restored GOSUB stack unwinds to completion")
	_expect_equal(
		restored_host.runtime.interpreter.call_stack.size(),
		0,
		"restored GOSUB consumes each saved return frame"
	)
	restored_host.queue_free()


func _test_battle_continuation_restore() -> void:
	var bundle = _battle_outcome_test_bundle()
	var adapter = SuspendedCommandAdapter.new()
	var host = _continuation_test_host(bundle, adapter)
	_expect(host.start_trigger("battle:outcome"), "battle continuation fixture starts")
	var saved_result: Dictionary = host.make_continuation_snapshot()
	var saved: Dictionary = _json_round_trip(saved_result.get("snapshot", {}))
	_expect_equal(
		saved.get("yieldedResult", {}).get("command"),
		"start_battle",
		"battle continuation records the outer action-list suspension"
	)
	_release_suspended_host(host, adapter)

	for coward: bool in [false, true]:
		var restored_adapter = SuspendedCommandAdapter.new()
		var restored_host = _continuation_test_host(bundle, restored_adapter)
		_expect_equal(restored_host.restore_continuation(saved).get("status"), "ok", "battle continuation restores")
		restored_host.resume_restored_continuation()
		_expect_equal(restored_adapter.commands[-1].get("command"), "start_battle", "restored battle restarts natively")
		restored_adapter.respond({"coward": coward})
		await process_frame
		_expect_equal(
			restored_adapter.commands[-1].get("command"),
			"apply_coward_penalty" if coward else "give_battle_loot",
			"restored battle returns through its authored outcome"
		)
		restored_adapter.respond()
		await process_frame
		_expect(not restored_host.active, "restored battle outcome completes once")
		restored_host.queue_free()


func _test_deferred_action_point_continuation_restore() -> void:
	var bundle = _opcode_25_test_bundle()
	var adapter = SuspendedCommandAdapter.new()
	var host = _continuation_test_host(bundle, adapter)
	host.runtime.runtime_state.set_position(0, 2, 3)
	_expect(host.start_trigger("Data DD:0:7"), "deferred action-point continuation starts")
	adapter.respond()
	await process_frame
	_expect(host.runtime.interpreter.remove_action_point, "opcode 25 mutation is deferred at save time")
	_expect_equal(
		adapter.commands[-1].get("payload", {}).get("messageId"),
		901,
		"deferred mutation suspends before its final presentation"
	)
	var saved_result: Dictionary = host.make_continuation_snapshot()
	var saved: Dictionary = _json_round_trip(saved_result.get("snapshot", {}))
	_expect(
		bool(saved.get("executionState", {}).get("removeActionPoint", false)),
		"continuation serializes the deferred mutation flag"
	)
	_release_suspended_host(host, adapter)

	var restored_adapter = SuspendedCommandAdapter.new()
	var restored_host = _continuation_test_host(bundle, restored_adapter)
	_expect_equal(
		restored_host.restore_continuation(saved).get("status"),
		"ok",
		"deferred action-point continuation restores"
	)
	restored_host.resume_restored_continuation()
	restored_adapter.respond()
	await process_frame
	var replacement: Dictionary = restored_host.runtime.runtime_state.get_action_point_override(
		"Data DD:0:7"
	)
	_expect_equal(replacement.get("targetX"), 2, "restored deferred mutation captures activation x")
	_expect_equal(replacement.get("targetY"), 3, "restored deferred mutation captures activation y")
	_expect(not restored_host.active, "restored deferred mutation completes once")
	restored_host.queue_free()


func _test_unsafe_continuation_save_policy() -> void:
	var adapter = SuspendedCommandAdapter.new()
	adapter.save_safe = false
	var host = _continuation_test_host(_continuation_encounter_test_bundle(), adapter)
	host.start_trigger("continuation:encounter")
	var result: Dictionary = host.make_continuation_snapshot()
	_expect_equal(result.get("status"), "error", "unsafe mid-encounter save is rejected")
	_expect(
		str(result.get("message", "")).contains("Finish the current encounter response"),
		"unsafe save rejection explains the legal boundary"
	)
	_release_suspended_host(host, adapter)


func _continuation_test_host(bundle: Variant, adapter: Variant) -> Variant:
	var host = HostScript.new()
	get_root().add_child(host)
	host.configure(adapter)
	host.use_campaign(bundle)
	return host


func _release_suspended_host(host: Variant, adapter: Variant) -> void:
	host.active = false
	if adapter.waiting:
		adapter.respond()
	host.queue_free()


func _json_round_trip(value: Variant) -> Dictionary:
	var parsed: Variant = JSON.parse_string(JSON.stringify(value))
	return parsed if parsed is Dictionary else {}


func _test_runtime_host() -> void:
	var host = HostScript.new()
	get_root().add_child(host)
	var adapter = GuardHouseAdapter.new()
	var completions: Array = []
	var stops: Array = []
	host.playthrough_completed.connect(func(result: Dictionary) -> void: completions.append(result))
	host.playthrough_stopped.connect(func(result: Dictionary) -> void: stops.append(result))
	host.configure(adapter)
	_expect(host.load_campaign(FIXTURE), "runtime host loads CoB fixture")
	_expect(host.has_trigger("Data DD:0:0"), "runtime host recognizes a compiled map trigger")
	_expect(
		host.start_trigger("Data DD:0:0", 0, {"actorFaction": 2}),
		"runtime host starts guard-house trigger"
	)
	_expect_equal(adapter.commands.size(), 3, "runtime host drives complete guard-house command flow")
	_expect_equal(adapter.commands[0].get("command"), "show_text", "host starts with guard-house text")
	_expect_equal(
		adapter.commands[0].get("payload", {}).get("actorFaction"),
		2,
		"host forwards macro actor context to commands"
	)
	_expect_equal(
		adapter.commands[0].get("payload", {}).get("scenarioDay"),
		11,
		"host supplies adapter-owned scenario time to the interpreter"
	)
	_expect_equal(adapter.commands[1].get("command"), "start_encounter", "host requests simple encounter")
	_expect_equal(adapter.commands[2].get("payload", {}).get("messageId"), 61, "host runs selected outcome")
	_expect_equal(completions.size(), 1, "runtime host publishes completion")
	_expect_equal(completions[0].get("reason"), "keep-codes", "runtime host completion reason")
	_expect_equal(stops.size(), 0, "runtime host guard-house flow has no stop")
	_expect(host.start_trigger("Data DD:0:83"), "runtime host starts dungeon move")
	_expect_equal(adapter.commands[-1].get("command"), "teleport", "host dispatches dungeon move")
	_expect_equal(
		host.runtime.runtime_state.level_type,
		"dungeon",
		"host retains dungeon destination state"
	)
	_expect_equal(completions.size(), 2, "host completes dungeon move after adapter response")
	_expect_equal(completions[-1].get("reason"), "action-point-ended", "host does not resume moved AP")
	_expect(host.start_trigger("Data DDD:1:75"), "runtime host starts look direction")
	_expect_equal(adapter.commands[-2].get("command"), "set_view_direction", "host updates view direction")
	_expect_equal(adapter.commands[-1].get("command"), "teleport", "host continues after view update")
	_expect_equal(host.runtime.runtime_state.heading, 1, "host retains updated heading")
	_expect_equal(completions.size(), 3, "host completes look-direction action point")
	_expect(host.start_trigger("Data DD:7:85"), "runtime host starts allow-map action")
	_expect_equal(adapter.commands[-1].get("command"), "set_view_mode", "host dispatches view-mode change")
	_expect_equal(host.runtime.runtime_state.multi_view, true, "host retains updated map mode")
	_expect_equal(completions.size(), 4, "host completes view-mode action point")
	host.runtime.runtime_state.set_location("land", 4, 87, 28)
	_expect(host.start_trigger("Data DD:4:46", 2), "runtime host starts darkland action")
	_expect_equal(adapter.commands[-2].get("command"), "set_map_darkness", "host dispatches map darkness")
	_expect_equal(adapter.commands[-1].get("payload", {}).get("messageId"), 849, "host continues after darkness change")
	_expect_equal(host.runtime.runtime_state.get_darkland("land", 4, 0), 1, "host retains darkness override")
	_expect_equal(completions.size(), 5, "host completes darkland action point")
	host.runtime.runtime_state.set_location("land", 0, 0, 0)
	_expect(host.start_trigger("Data ED3:macro:163", 1), "runtime host starts land-look action")
	_expect_equal(adapter.commands[-2].get("command"), "set_land_look", "host dispatches land-look change")
	_expect_equal(adapter.commands[-1].get("payload", {}).get("messageId"), 867, "host continues after land-look change")
	_expect_equal(host.runtime.runtime_state.get_landlook("land", 0, 0), 10, "host retains land-look override")
	_expect_equal(completions.size(), 6, "host completes land-look action point")
	_expect(host.start_trigger("Data DD:1:30", 4), "runtime host starts experience award")
	_expect_equal(adapter.commands[-1].get("command"), "give_experience", "host dispatches experience award")
	_expect_equal(adapter.commands[-1].get("payload", {}).get("experience"), 1500, "host preserves experience total")
	_expect_equal(completions.size(), 7, "host completes experience action point")
	_expect_equal(
		host.runtime.runtime_state.get_action_point_override("Data DD:1:31").get("actions", [])[0].get("id"),
		522,
		"host continues through the following action-point patch"
	)
	_expect(host.start_trigger("Data ED3:macro:142"), "runtime host starts party damage action")
	_expect_equal(adapter.commands[-1].get("command"), "change_party_health", "host dispatches party health change")
	_expect_equal(adapter.commands[-1].get("payload", {}).get("rollRange"), [1, 1], "host preserves party damage range")
	_expect_equal(completions.size(), 8, "host completes party damage action point")
	_expect(host.start_trigger("Data DD:7:45", 1), "runtime host starts checked-character damage")
	_expect_equal(adapter.commands[-3].get("command"), "filter_selected_characters", "host dispatches character check")
	_expect_equal(adapter.commands[-2].get("command"), "change_selected_health", "host dispatches selected damage")
	_expect_equal(adapter.commands[-1].get("payload", {}).get("messageId"), 377, "host continues after selected damage")
	_expect_equal(completions.size(), 9, "host completes checked-character damage")
	_expect(host.start_trigger("Data ED3:macro:67"), "runtime host starts movement-based selection")
	_expect_equal(adapter.commands[-2].get("command"), "select_characters_by_misc", "host dispatches misc selector")
	_expect_equal(adapter.commands[-1].get("command"), "change_selected_health", "host continues to selected damage")
	_expect_equal(completions.size(), 10, "host completes movement-selected damage")
	_expect(host.start_trigger("Data DD:8:89", 1), "runtime host starts party spell action")
	_expect_equal(adapter.commands[-1].get("command"), "cast_classic_spell", "host dispatches party spell")
	_expect_equal(adapter.commands[-1].get("payload", {}).get("spellId"), 1408, "host preserves party spell ID")
	_expect_equal(completions.size(), 11, "host completes party spell action point")
	var godot_adapter = GodotAdapterScript.new()
	_expect(godot_adapter.has_method("execute_command"), "Godot command adapter loads")
	var encounter_choices: Dictionary = godot_adapter.build_simple_encounter_choices(
		host.runtime.bundle.get_encounter("simple", 0)
	)
	_expect_equal(encounter_choices.get("choices", []).size(), 5, "Godot adapter exposes simple back-out")
	_expect_equal(
		encounter_choices.get("outcomes"),
		["1", "2", "3", "4", "0"],
		"Godot adapter preserves Classic outcomes and back-out"
	)
	host.queue_free()

	var rejecting_host = HostScript.new()
	get_root().add_child(rejecting_host)
	var rejected: Array = []
	rejecting_host.playthrough_stopped.connect(func(result: Dictionary) -> void: rejected.append(result))
	rejecting_host.configure(RejectingAdapter.new())
	rejecting_host.load_campaign(FIXTURE)
	rejecting_host.start_trigger("Data DD:0:0")
	_expect_equal(rejected.size(), 1, "runtime host publishes adapter failure")
	_expect_equal(rejected[0].get("command"), "show_text", "runtime host identifies failed command")
	rejecting_host.queue_free()

	var start_host = HostScript.new()
	get_root().add_child(start_host)
	var start_adapter = StartLocationAdapter.new()
	start_host.configure(start_adapter)
	_expect(start_host.load_campaign(FIXTURE), "start-location host loads CoB fixture")
	var start_result: Dictionary = start_host.activate_start_location()
	_expect_equal(start_result.get("nativeMapName"), "map_0", "host resolves the Classic starting map")
	_expect_equal(start_result.get("position"), Vector2i(2, 1), "host applies the authored start position")
	_expect(bool(start_result.get("recheckDestination")), "campaign start requests native map-event entry")
	_expect_equal(
		start_adapter.reapplied_state,
		start_host.runtime.runtime_state,
		"campaign start reapplies persistent map state before entering the map"
	)
	_expect_equal(
		start_result.get("persistentMapState", {}).get("status"),
		"ok",
		"campaign start reports its persistent map replay"
	)
	_expect_equal(
		start_adapter.start_location.get("viewType"),
		StateScript.VIEW_3D,
		"campaign start carries the Classic view state"
	)
	start_host.queue_free()


func _interpreter(bundle):
	var state = StateScript.new()
	state.configure_from_bundle(bundle)
	var interpreter = InterpreterScript.new()
	interpreter.configure(bundle, state)
	return interpreter


func _execution_audit_test_bundle():
	var bundle = BundleScript.new()
	bundle.manifest = {"start": {"levelType": "land", "levelIndex": 0, "x": 0, "y": 0}}
	_add_stack_trigger(bundle, "Data ED3:macro:10", 10, [
		_classic_action(0, 126, 1),
		_classic_action(1, 124, 2),
	])
	bundle.extra_action_points_by_id[10]["active"] = false
	bundle.battles_by_id[3] = {"id": 3, "battleMacro": -10}
	bundle.monsters_by_id[3] = {"id": 3, "displayName": "Invalid Beast", "deathMacro": -10}
	bundle.monsters_by_id[4] = {"id": 4, "displayName": "Queued Beast", "deathMacro": 10}
	bundle.monsters_by_id[5] = {"id": 5, "displayName": "Broken Beast", "deathMacro": 99}
	bundle.monsters_by_id[6] = {"id": 6, "displayName": "Catalog End", "hitDice": 255}
	bundle.monsters_by_id[7] = {"id": 7, "displayName": "Trailing Bytes", "deathMacro": -62}
	_add_stack_trigger(bundle, "audit:complex", -1, [_classic_action(0, 5, 2)])
	bundle.complex_encounters_by_id[2] = {
		"id": 2,
		"actions": [
			{"slot": 0, "rawCode": 201, "id": 20},
			{"slot": 1, "rawCode": 200, "id": 0},
		],
		"actionResult": 1,
		"maxTimes": 1,
		"prompt": 0,
	}
	bundle.dispatcher_noop_keys["Data ED2:2:1:200"] = true
	return bundle


func _timed_encounter_test_bundle():
	var bundle = BundleScript.new()
	bundle.manifest = {"start": {"levelType": "land", "levelIndex": 0, "x": 0, "y": 0}}
	bundle.timed_encounters_by_id[0] = {
		"id": 0,
		"day": 3,
		"increment": 4,
		"percent": 25,
		"door": 83,
	}
	bundle.extra_codes_by_id[312] = {"id": 312, "values": [0, 100, 0, 1, 7]}
	bundle.extra_codes_by_id[313] = {"id": 313, "values": [0, -1, -1, 0, 2]}
	bundle.extra_codes_by_id[314] = {"id": 314, "values": [0, -1, -1, 0, -1]}
	_add_stack_trigger(bundle, "timed:reset", -1, [
		_classic_action(0, 54, 312),
		_classic_action(7, 24, 0),
	])
	_add_stack_trigger(bundle, "timed:offset", -1, [
		_classic_action(0, 54, 313),
		_classic_action(7, 24, 0),
	])
	_add_stack_trigger(bundle, "timed:unchanged", -1, [
		_classic_action(0, 54, 314),
		_classic_action(7, 24, 0),
	])
	return bundle


func _selective_battle_test_bundle():
	var bundle = BundleScript.new()
	bundle.manifest = {"start": {"levelType": "land", "levelIndex": 0, "x": 0, "y": 0}}
	bundle.messages_by_id[900] = {"id": 900, "text": "Selective battle test"}
	bundle.extra_codes_by_id[234] = {
		"id": 234,
		"values": [115, 119, 30000, 900, 38],
	}
	bundle.battles_by_id[115] = {"id": 115}
	bundle.treasures_by_id[38] = {
		"id": 38,
		"exp": 100,
		"money": [0, 0, 0],
		"itemIds": [],
	}
	_add_stack_trigger(bundle, "selective:battle", -1, [
		_classic_action(0, 14, 1),
		_classic_action(1, 48, 234),
		_classic_action(7, 24, 0),
	])
	return bundle


func _continuation_encounter_test_bundle():
	var bundle = BundleScript.new()
	bundle.manifest = {"start": {"levelType": "land", "levelIndex": 0, "x": 0, "y": 0}}
	_add_stack_trigger(bundle, "continuation:encounter", -1, [
		_classic_action(0, 5, 1),
		_classic_action(7, 24, 0),
	])
	bundle.complex_encounters_by_id[1] = {
		"id": 1,
		"actions": [
			_classic_action(16, 1, 303),
			_classic_action(24, 1, 404),
		],
		"maxTimes": 2,
		"prompt": 0,
	}
	bundle.messages_by_id[303] = {"id": 303, "text": "Timed out"}
	bundle.messages_by_id[404] = {"id": 404, "text": "Try again"}
	return bundle


func _battle_outcome_test_bundle():
	var bundle = BundleScript.new()
	bundle.manifest = {"start": {"levelType": "land", "levelIndex": 0, "x": 0, "y": 0}}
	bundle.extra_codes_by_id[1] = {"id": 1, "values": [1, 1, -1, 0, 0]}
	bundle.battles_by_id[1] = {"id": 1}
	_add_stack_trigger(bundle, "battle:outcome", -1, [
		_classic_action(0, 56, 1),
		_classic_action(7, 24, 0),
	])
	return bundle


func _selective_battle_payload() -> Dictionary:
	return {
		"battleIdRange": [115, 119],
		"lootMode": 0,
		"participantMode": "selected",
	}


func _give_condition_test_bundle():
	var bundle = BundleScript.new()
	bundle.manifest = {"start": {"levelType": "land", "levelIndex": 0, "x": 0, "y": 0}}
	bundle.extra_codes_by_id[53] = {
		"id": 53,
		"values": [1, 9, -1, 0, 0],
	}
	bundle.simple_encounters_by_id[4] = {
		"id": 4,
		"prompt": 0,
		"maxTimes": 1,
		"actions": [
			_classic_action(0, 43, 53),
			_classic_action(7, 24, 0),
		],
	}
	_add_stack_trigger(bundle, "condition:poison", -1, [_classic_action(0, 4, 4)])
	return bundle


func _take_gold_test_bundle():
	var bundle = BundleScript.new()
	bundle.manifest = {"start": {"levelType": "land", "levelIndex": 0, "x": 0, "y": 0}}
	for message_id: int in [
		900, 901, 907,
		910, 911, 917,
		920, 921, 927,
		930, 931, 937,
		940, 941, 947,
	]:
		bundle.messages_by_id[message_id] = {
			"id": message_id,
			"text": "Payment test %d" % message_id,
		}
	var specifications := [
		{
			"triggerId": "payment:success",
			"encounterId": 0,
			"extraCodeId": 100,
			"values": [7, 1, 1, 1, 0],
			"fallthroughText": 900,
			"branchText": 901,
			"lastSlotText": 907,
		},
		{
			"triggerId": "payment:failure",
			"encounterId": 1,
			"extraCodeId": 101,
			"values": [7, 0, 1, 1, 0],
			"fallthroughText": 910,
			"branchText": 911,
			"lastSlotText": 917,
		},
		{
			"triggerId": "payment:skip",
			"encounterId": 2,
			"extraCodeId": 102,
			"values": [7, -1, 0, 0, 0],
			"fallthroughText": 920,
			"branchText": 921,
			"lastSlotText": 927,
		},
		{
			"triggerId": "payment:gems",
			"encounterId": 3,
			"extraCodeId": 103,
			"values": [-4, 1, 1, 1, 0],
			"fallthroughText": 930,
			"branchText": 931,
			"lastSlotText": 937,
		},
		{
			"triggerId": "payment:force",
			"encounterId": 4,
			"extraCodeId": 104,
			"values": [7, 2, 1, 1, 0],
			"fallthroughText": 940,
			"branchText": 941,
			"lastSlotText": 947,
		},
	]
	for specification: Dictionary in specifications:
		var encounter_id := int(specification["encounterId"])
		var extra_code_id := int(specification["extraCodeId"])
		bundle.extra_codes_by_id[extra_code_id] = {
			"id": extra_code_id,
			"values": specification["values"],
		}
		bundle.simple_encounters_by_id[encounter_id] = {
			"id": encounter_id,
			"prompt": 0,
			"maxTimes": 1,
			"actions": [
				_classic_action(0, 33, extra_code_id),
				_classic_action(1, 1, int(specification["fallthroughText"])),
				_classic_action(7, 1, int(specification["lastSlotText"])),
				_classic_action(8, 1, int(specification["branchText"])),
			],
		}
		_add_stack_trigger(
			bundle,
			str(specification["triggerId"]),
			-1,
			[_classic_action(0, 4, encounter_id)]
		)
	return bundle


func _audit_has_diagnostic(report: Dictionary, code: String) -> bool:
	return _audit_diagnostic_count(report, code) > 0


func _audit_diagnostic_count(report: Dictionary, code: String) -> int:
	var count := 0
	for diagnostic_value: Variant in report.get("diagnostics", []):
		if diagnostic_value is Dictionary and diagnostic_value.get("code") == code:
			count += 1
	return count


func _party_state_test_bundle():
	var bundle = BundleScript.new()
	bundle.manifest = {"start": {"levelType": "land", "levelIndex": 0, "x": 0, "y": 0}}
	bundle.monsters_by_id[71] = {"id": 71, "nameId": 19, "displayName": "Vodalian"}
	bundle.monsters_by_name_id[19] = [bundle.monsters_by_id[71]]
	_add_stack_trigger(bundle, "party:condition", -1, [
		_classic_action(0, 40, 1),
		_classic_action(1, 1, 901),
	])
	_add_stack_trigger(bundle, "party:ally", -1, [
		_classic_action(0, 87, 2),
		_classic_action(1, 1, 902),
	])
	_add_stack_trigger(bundle, "party:ally-message", -1, [_classic_action(0, 87, 6)])
	_add_stack_trigger(bundle, "party:add-ally", -1, [_classic_action(0, 89, 71)])
	_add_stack_trigger(bundle, "party:registration", -1, [
		_classic_action(0, 98, 0),
		_classic_action(1, 1, 904),
	])
	_add_stack_trigger(bundle, "party:random-xap", -1, [_classic_action(0, 85, 3)])
	_add_stack_trigger(bundle, "party:random-gosub", -1, [
		_classic_action(0, -85, 7),
		_classic_action(1, 1, 911),
	])
	_add_stack_trigger(bundle, "party:random-simple", -1, [_classic_action(0, 85, 4)])
	_add_stack_trigger(bundle, "party:random-complex", -1, [_classic_action(0, 85, 5)])
	_add_stack_trigger(bundle, "party:random-missing", -1, [_classic_action(0, 85, -1700)])
	_add_stack_trigger(bundle, "Data ED3:macro:500", 500, [_classic_action(0, 1, 910)])
	_add_stack_trigger(bundle, "Data ED3:macro:501", 501, [
		_classic_action(0, 1, 912),
		_classic_action(1, 111, 0),
	])
	bundle.extra_codes_by_id[1] = {"id": 1, "values": [1, 3, 8, 1, 0]}
	bundle.extra_codes_by_id[2] = {"id": 2, "values": [19, 0, 1, 500, 0]}
	bundle.extra_codes_by_id[3] = {"id": 3, "values": [0, 500, 500, 10105, 905]}
	bundle.extra_codes_by_id[4] = {"id": 4, "values": [1, 3, 3, 0, 0]}
	bundle.extra_codes_by_id[5] = {"id": 5, "values": [2, 8, 8, 0, 0]}
	bundle.extra_codes_by_id[6] = {"id": 6, "values": [19, 0, 2, 500, 903]}
	bundle.extra_codes_by_id[7] = {"id": 7, "values": [0, 501, 501, 0, 0]}
	bundle.simple_encounters_by_id[3] = {
		"id": 3,
		"actions": [],
		"choiceResults": [1, 0, 0, 0],
		"maxTimes": 1,
		"prompt": 0,
	}
	bundle.complex_encounters_by_id[8] = {
		"id": 8,
		"actions": [],
		"choiceResults": [1, 0, 0, 0],
		"maxTimes": 1,
		"prompt": 0,
	}
	for message_id: int in [901, 902, 903, 904, 905, 910, 911, 912]:
		bundle.messages_by_id[message_id] = {"id": message_id, "text": "Message %d" % message_id}
	return bundle


func _combat_monster_test_bundle():
	var bundle = BundleScript.new()
	bundle.manifest = {"start": {"levelType": "land", "levelIndex": 0, "x": 0, "y": 0}}
	bundle.monsters_by_id[17] = {
		"id": 17,
		"displayName": "Skeletal Beast",
		"typeFlags": [0, 1, 0, 0, 0, 0, 0, 0],
	}
	bundle.monsters_by_id[19] = {
		"id": 19,
		"displayName": "Skeletal Giant",
		"typeFlags": [0, 1, 0, 0, 0, 1, 0, 0],
	}
	bundle.monsters_by_id[42] = {
		"id": 42,
		"displayName": "Podling",
		"typeFlags": [0, 0, 0, 0, 0, 0, 0, 0],
	}
	bundle.monsters_by_id[78] = {
		"id": 78,
		"displayName": "Zombie",
		"typeFlags": [0, 1, 0, 0, 0, 0, 0, 0],
	}
	bundle.monsters_by_id[92] = {
		"id": 92,
		"nameId": 7,
		"displayName": "Goblin",
		"traitor": 4,
		"deathMacro": 960,
		"typeFlags": [0, 0, 0, 0, 0, 0, 0, 0],
	}
	bundle.monsters_by_id[134] = {
		"id": 134,
		"nameId": 12,
		"displayName": "Rat Demi-Lord",
		"typeFlags": [0, 0, 0, 0, 0, 0, 0, 0],
	}
	bundle.messages_by_id[920] = {"id": 920, "text": "The fight continues."}
	bundle.messages_by_id[921] = {"id": 921, "text": "The remaining enemies recoil."}
	bundle.messages_by_id[922] = {"id": 922, "text": "The lower undead collapse."}
	bundle.messages_by_id[923] = {"id": 923, "text": "This action must not run after battle."}
	bundle.messages_by_id[924] = {"id": 924, "text": "The routed creatures scatter."}
	bundle.messages_by_id[925] = {"id": 925, "text": "The scheduled event begins."}
	bundle.messages_by_id[926] = {"id": 926, "text": "The repeating event begins."}
	bundle.messages_by_id[927] = {"id": 927, "text": "The random event begins."}
	bundle.messages_by_id[928] = {"id": 928, "text": "More enemies appear."}
	bundle.monsters_by_name_id[7] = [bundle.monsters_by_id[92]]
	bundle.monsters_by_name_id[12] = [bundle.monsters_by_id[134]]
	bundle.extra_codes_by_id[1] = {"id": 1, "values": [12, 0, 0, 0, 0]}
	bundle.extra_codes_by_id[2] = {"id": 2, "values": [134, 42, 0, 0, 0]}
	bundle.extra_codes_by_id[3] = {"id": 3, "values": [0, 2, 0, 950, 0]}
	bundle.extra_codes_by_id[4] = {"id": 4, "values": [1, 25, 1, 951, 0]}
	bundle.extra_codes_by_id[5] = {"id": 5, "values": [2, 0, 2, 952, 952]}
	bundle.extra_codes_by_id[6] = {"id": 6, "values": [0, 92, 2, 640, 0]}
	bundle.extra_codes_by_id[7] = {"id": 7, "values": [0, 92, -1, 0, 0]}
	bundle.extra_codes_by_id[8] = {"id": 8, "values": [0, 0, 0, 0, 0]}
	bundle.extra_codes_by_id[9] = {"id": 9, "values": [0, 92, 1, 0, 2]}
	_add_stack_trigger(bundle, "combat:present", -1, [
		_classic_action(0, 127, 12),
		_classic_action(1, 1, 920),
	])
	_add_stack_trigger(bundle, "combat:destroy", -1, [
		_classic_action(0, 125, 1),
		_classic_action(1, 1, 921),
	])
	_add_stack_trigger(bundle, "combat:deanimate", -1, [
		_classic_action(0, 121, 0),
		_classic_action(1, 1, 922),
	])
	_add_stack_trigger(bundle, "combat:rout", -1, [
		_classic_action(0, 123, 2),
		_classic_action(1, 1, 924),
	])
	_add_stack_trigger(bundle, "combat:spawn", -1, [
		_classic_action(0, 124, 6),
		_classic_action(1, 1, 928),
	])
	_add_stack_trigger(bundle, "combat:spawn-random", -1, [_classic_action(0, 124, 7)])
	_add_stack_trigger(bundle, "combat:spawn-zero", -1, [
		_classic_action(0, 124, 8),
		_classic_action(1, 1, 928),
	])
	_add_stack_trigger(bundle, "combat:spawn-explicit", -1, [_classic_action(0, 124, 9)])
	_add_stack_trigger(bundle, "combat:round", -1, [_classic_action(0, 126, 3)])
	_add_stack_trigger(bundle, "combat:chance", -1, [_classic_action(0, 126, 4)])
	_add_stack_trigger(bundle, "combat:random", -1, [_classic_action(0, 126, 5)])
	_add_stack_trigger(bundle, "Data ED3:macro:950", 950, [_classic_action(0, 1, 925)])
	_add_stack_trigger(bundle, "Data ED3:macro:951", 951, [_classic_action(0, 1, 926)])
	_add_stack_trigger(bundle, "Data ED3:macro:952", 952, [_classic_action(0, 1, 927)])
	_add_stack_trigger(bundle, "Data ED3:macro:960", 960, [_classic_action(0, 1, 928)])
	_add_stack_trigger(bundle, "combat:end", -1, [
		_classic_action(0, 100, 0),
		_classic_action(1, 1, 923),
	])
	return bundle


func _random_level_mutation_test_bundle():
	var bundle = BundleScript.new()
	bundle.manifest = {"start": {"levelType": "land", "levelIndex": 0, "x": 0, "y": 0}}
	_add_stack_trigger(bundle, "random:dungeon", -1, [
		_classic_action(0, -23, 1),
		_classic_action(7, 24, 0),
	])
	_add_stack_trigger(bundle, "random:missing", -1, [
		_classic_action(0, 23, 2),
		_classic_action(7, 24, 0),
	])
	bundle.extra_codes_by_id[1] = {"id": 1, "values": [0, 2, 250, -1, -1]}
	bundle.extra_codes_by_id[2] = {"id": 2, "values": [7, 18, 0, 0, 0]}
	bundle.random_levels_by_id["dungeon:0:randlevel"] = {
		"id": "dungeon:0:randlevel",
		"levelType": "dungeon",
		"levelIndex": 0,
		"rects": [{"rectIndex": 2, "percent": 100, "battleRange": [10, 20]}],
	}
	# Classic stores 20 fixed rectangle slots even when the compiler omits empty rows.
	bundle.random_levels_by_id["land:7:randlevel"] = {
		"id": "land:7:randlevel",
		"levelType": "land",
		"levelIndex": 7,
		"rects": [],
	}
	return bundle


func _percent_branch_test_bundle():
	var bundle = BundleScript.new()
	bundle.manifest = {"start": {"levelType": "land", "levelIndex": 0, "x": 0, "y": 0}}
	_add_stack_trigger(bundle, "chance:ed3", -1, [_classic_action(0, 42, 1)])
	_add_stack_trigger(bundle, "Data ED3:macro:50", 50, [_classic_action(0, 1, 500)])
	_add_stack_trigger(bundle, "chance:slot-seven", -1, [
		_classic_action(0, 42, 4),
		_classic_action(7, 1, 501),
	])
	_add_stack_trigger(bundle, "chance:simple", -1, [_classic_action(0, 4, 1)])
	_add_stack_trigger(bundle, "chance:nested", -1, [_classic_action(0, 4, 2)])
	_add_branch_map_trigger(bundle, 1, [_classic_action(0, 42, 2)])
	_add_branch_map_trigger(bundle, 2, [_classic_action(0, 42, 3)])
	_add_branch_map_trigger(bundle, 3, [_classic_action(0, 5, 2)])
	bundle.extra_codes_by_id[1] = {"id": 1, "values": [100, 1, 0, 50, 0]}
	bundle.extra_codes_by_id[2] = {"id": 2, "values": [100, 2, 0, 0, 0]}
	bundle.extra_codes_by_id[3] = {"id": 3, "values": [100, -2, 0, 0, 0]}
	bundle.extra_codes_by_id[4] = {"id": 4, "values": [100, 1, -1, 0, 0]}
	bundle.extra_codes_by_id[5] = {"id": 5, "values": [100, 1, 1, 1, 0]}
	bundle.extra_codes_by_id[6] = {"id": 6, "values": [100, -2, 0, 0, 0]}
	bundle.extra_codes_by_id[7] = {"id": 7, "values": [100, 1, 1, 1, 0]}
	bundle.simple_encounters_by_id[1] = {
		"id": 1,
		"actions": [
			_classic_action(0, 42, 5),
			_classic_action(8, 1, 502),
		],
		"choiceResults": [1, 0, 0, 0],
		"maxTimes": 1,
		"prompt": 0,
	}
	bundle.simple_encounters_by_id[2] = {
		"id": 2,
		"actions": [
			_classic_action(0, 5, 3),
			_classic_action(8, 1, 503),
		],
		"choiceResults": [1, 0, 0, 0],
		"maxTimes": 1,
		"prompt": 0,
	}
	bundle.complex_encounters_by_id[2] = {
		"id": 2,
		"actions": [_classic_action(0, 42, 6)],
		"choiceResults": [1, 0, 0, 0],
		"maxTimes": 2,
		"prompt": 0,
	}
	bundle.complex_encounters_by_id[3] = {
		"id": 3,
		"actions": [_classic_action(0, 42, 7)],
		"choiceResults": [1, 0, 0, 0],
		"maxTimes": 1,
		"prompt": 0,
	}
	bundle.messages_by_id[500] = {"id": 500, "text": "ED3 branch"}
	bundle.messages_by_id[501] = {"id": 501, "text": "Slot seven"}
	bundle.messages_by_id[502] = {"id": 502, "text": "Simple result two"}
	bundle.messages_by_id[503] = {"id": 503, "text": "Enclosing simple result"}
	return bundle


func _difficulty_branch_test_bundle():
	var bundle = BundleScript.new()
	bundle.manifest = {"start": {"levelType": "land", "levelIndex": 0, "x": 0, "y": 0}}
	_add_stack_trigger(bundle, "difficulty:threshold", -1, [
		_classic_action(0, 58, 10),
		_classic_action(1, 1, 701),
	])
	_add_stack_trigger(bundle, "difficulty:unused-mode", -1, [
		_classic_action(0, 58, 13),
		_classic_action(1, 1, 702),
	])
	_add_stack_trigger(bundle, "Data ED3:macro:60", 60, [_classic_action(0, 1, 700)])
	_add_branch_map_trigger(bundle, 4, [_classic_action(0, 58, 11)])
	_add_branch_map_trigger(bundle, 5, [_classic_action(0, 58, 12)])
	bundle.extra_codes_by_id[10] = {"id": 10, "values": [1, 1, 0, 60, 0]}
	bundle.extra_codes_by_id[11] = {"id": 11, "values": [2, -2, 0, 0, 0]}
	bundle.extra_codes_by_id[12] = {"id": 12, "values": [1, 2, 0, 0, 0]}
	# Tutorial contains difficulty rows with other success-mode values; Classic
	# simply continues when one of those rows meets its threshold.
	bundle.extra_codes_by_id[13] = {"id": 13, "values": [2, 3, 2, 25, 0]}
	bundle.messages_by_id[700] = {"id": 700, "text": "Hard route"}
	bundle.messages_by_id[701] = {"id": 701, "text": "Normal route"}
	bundle.messages_by_id[702] = {"id": 702, "text": "Unused mode continues"}
	return bundle


func _add_branch_map_trigger(bundle, record_index: int, actions: Array) -> void:
	var trigger := {
		"id": "Data DD:0:%d" % record_index,
		"source": "Data DD",
		"levelType": "land",
		"levelIndex": 0,
		"recordIndex": record_index,
		"active": true,
		"percent": 100,
		"actions": actions,
	}
	bundle.triggers_by_id[trigger["id"]] = trigger


func _opcode_25_test_bundle():
	# This pairs the source-backed XAP header-preservation and opcode 25 rules in
	# one small record so the copied action list is observable without a battle.
	var bundle = BundleScript.new()
	bundle.manifest = {"start": {"levelType": "land", "levelIndex": 0, "x": 2, "y": 3}}
	var root := {
		"id": "Data DD:0:7",
		"source": "Data DD",
		"levelType": "land",
		"levelIndex": 0,
		"recordIndex": 7,
		"active": true,
		"doorid": 302,
		"landid": 0,
		"targetX": 8,
		"targetY": 9,
		"percent": 100,
		"coordinate": {"x": 2, "y": 3},
		"actions": [_classic_action(0, -46, 700)],
	}
	bundle.triggers_by_id[root["id"]] = root
	_add_stack_trigger(bundle, "Data ED3:macro:700", 700, [
		_classic_action(0, 1, 900),
		_classic_action(1, 25, 0),
		_classic_action(2, 111, 0),
		_classic_action(3, 1, 901),
		_classic_action(7, 24, 0),
	])
	_add_stack_branch(bundle, 700, 700)
	bundle.messages_by_id[900] = {"id": 900, "text": "Before removal"}
	bundle.messages_by_id[901] = {"id": 901, "text": "After removal"}
	return bundle


func _action_data_patch_test_bundle():
	# CoB uses opcode 7 only for map APs. These small records exercise the two
	# encounter-result destinations dispatched by the same source case.
	var bundle = BundleScript.new()
	bundle.manifest = {"start": {"levelType": "land", "levelIndex": 0, "x": 0, "y": 0}}
	_add_stack_trigger(bundle, "patch:simple", -1, [
		_classic_action(0, 7, 1),
		_classic_action(1, 4, 10),
	])
	_add_stack_trigger(bundle, "patch:complex", -1, [
		_classic_action(0, 7, 2),
		_classic_action(1, 5, 11),
	])
	_add_stack_trigger(bundle, "patch:dungeon", -1, [
		_classic_action(0, 7, 3),
		_classic_action(7, 24, 0),
	])
	_add_stack_trigger(bundle, "Data ED3:macro:20", 20, [
		_classic_action(0, 1, 900),
		_classic_action(7, 24, 0),
	])
	_add_stack_trigger(bundle, "Data ED3:macro:21", 21, [
		_classic_action(0, 1, 901),
		_classic_action(7, 24, 0),
	])
	_add_stack_trigger(bundle, "Data ED3:macro:22", 22, [
		_classic_action(0, 1, 902),
		_classic_action(7, 24, 0),
	])
	bundle.extra_codes_by_id[1] = {"id": 1, "values": [-1, 10, 20, 0, 2]}
	bundle.extra_codes_by_id[2] = {"id": 2, "values": [-2, 11, 21, 0, 1]}
	bundle.extra_codes_by_id[3] = {"id": 3, "values": [2, 4, 22, 2, 0]}
	var dungeon_target := {
		"id": "Data DDD:2:4",
		"source": "Data DDD",
		"levelType": "dungeon",
		"levelIndex": 2,
		"recordIndex": 4,
		"active": true,
		"percent": 100,
		"actions": [_classic_action(0, 1, 820)],
	}
	bundle.triggers_by_id[dungeon_target["id"]] = dungeon_target
	bundle.simple_encounters_by_id[10] = {
		"id": 10,
		"actions": [
			_classic_action(0, 1, 800),
			_classic_action(7, 24, 0),
			_classic_action(8, 1, 801),
			_classic_action(15, 24, 0),
			_classic_action(16, 1, 802),
			_classic_action(23, 24, 0),
			_classic_action(24, 1, 803),
			_classic_action(31, 24, 0),
		],
		"choiceResults": [1, 2, 3, 4],
		"maxTimes": 1,
		"prompt": 0,
	}
	bundle.complex_encounters_by_id[11] = {
		"id": 11,
		"actions": [
			_classic_action(0, 1, 810),
			_classic_action(7, 24, 0),
			_classic_action(8, 1, 811),
			_classic_action(15, 24, 0),
			_classic_action(16, 1, 812),
			_classic_action(23, 24, 0),
			_classic_action(24, 1, 813),
			_classic_action(31, 24, 0),
		],
		"choiceResults": [1, 2, 3, 4],
		"maxTimes": 1,
		"prompt": 0,
	}
	for message_id: int in [800, 801, 802, 803, 810, 811, 812, 813, 820, 900, 901, 902]:
		bundle.messages_by_id[message_id] = {"id": message_id, "text": "Message %d" % message_id}
	return bundle


func _item_action_test_bundle():
	var bundle = BundleScript.new()
	bundle.manifest = {"start": {"levelType": "land", "levelIndex": 0, "x": 0, "y": 0}}
	_add_stack_trigger(bundle, "item:possession", -1, [
		_classic_action(0, 21, 1),
		_classic_action(1, 1, 910),
	])
	_add_stack_trigger(bundle, "item:missing-branch", -1, [_classic_action(0, 21, 2)])
	_add_stack_trigger(bundle, "item:missing-text", -1, [
		_classic_action(0, 21, 3),
		_classic_action(1, 1, 910),
	])
	_add_stack_trigger(bundle, "item:gosub", -1, [
		_classic_action(0, -21, 4),
		_classic_action(1, 1, 913),
		_classic_action(7, 24, 0),
	])
	_add_stack_trigger(bundle, "item:simple", -1, [_classic_action(0, 21, 8)])
	_add_stack_trigger(bundle, "item:result-present", -1, [
		_classic_action(0, 38, 5),
		_classic_action(1, 1, 920),
	])
	_add_stack_trigger(bundle, "item:result-absent", -1, [_classic_action(0, 38, 6)])
	_add_stack_trigger(bundle, "item:result-force", -1, [_classic_action(0, 38, 7)])
	_add_stack_trigger(bundle, "item:mutation", -1, [_classic_action(0, 22, 9)])
	_add_stack_trigger(bundle, "item:capture", -1, [_classic_action(0, 36, 44)])
	_add_stack_trigger(bundle, "item:restore", -1, [_classic_action(0, 36, 0)])
	_add_stack_trigger(bundle, "Data ED3:macro:10", 10, [_classic_action(0, 1, 900)])
	_add_stack_trigger(bundle, "Data ED3:macro:11", 11, [_classic_action(0, 1, 901)])
	_add_stack_trigger(bundle, "Data ED3:macro:12", 12, [
		_classic_action(0, 1, 911),
		_classic_action(1, 111, 0),
	])
	_add_stack_trigger(bundle, "Data ED3:macro:13", 13, [_classic_action(0, 1, 921)])
	_add_stack_trigger(bundle, "Data ED3:macro:14", 14, [_classic_action(0, 1, 922)])
	_add_stack_trigger(bundle, "Data ED3:macro:15", 15, [_classic_action(0, 1, 923)])
	bundle.extra_codes_by_id[1] = {"id": 1, "values": [100, 0, 1, 10, 0]}
	bundle.extra_codes_by_id[2] = {"id": 2, "values": [100, 0, 0, 10, 11]}
	bundle.extra_codes_by_id[3] = {"id": 3, "values": [100, 0, 2, 10, 902]}
	bundle.extra_codes_by_id[4] = {"id": 4, "values": [100, 0, 1, 12, 0]}
	bundle.extra_codes_by_id[5] = {"id": 5, "values": [100, 1, 0, 13, 0]}
	bundle.extra_codes_by_id[6] = {"id": 6, "values": [100, 0, 0, 14, 0]}
	bundle.extra_codes_by_id[7] = {"id": 7, "values": [100, 2, 0, 15, 0]}
	bundle.extra_codes_by_id[8] = {"id": 8, "values": [100, 1, 1, 2, 0]}
	bundle.extra_codes_by_id[9] = {"id": 9, "values": [100, 2, 3, -4, 101]}
	bundle.item_texts_by_id[100] = {
		"itemId": 100,
		"identifiedName": "Test Key",
		"unidentifiedName": "Unknown Key",
	}
	bundle.item_texts_by_id[101] = {
		"itemId": 101,
		"identifiedName": "Replacement Key",
		"unidentifiedName": "Unknown Key",
	}
	for message_id: int in [900, 901, 902, 910, 911, 913, 920, 921, 922, 923]:
		bundle.messages_by_id[message_id] = {
			"id": message_id,
			"text": "Message %d" % message_id,
		}
	bundle.simple_encounters_by_id[2] = {
		"id": 2,
		"prompt": 0,
		"maxTimes": 1,
		"choiceResults": [1, 2, 3, 4],
		"actions": [],
	}
	return bundle


func _test_item(item_name: String, equipped := 0, charges := 0) -> Dictionary:
	return {
		"name": item_name,
		"equipped": equipped,
		"charges": charges,
		"weight": 1,
		"charges_weight": 0,
		"is_identified": 1,
	}


func _stack_test_bundle():
	# CoB does not contain GOSUB opcodes, so these synthetic APs isolate the
	# source-backed stack rules without presenting them as scenario fixtures.
	var bundle = BundleScript.new()
	bundle.manifest = {"start": {"levelType": "land", "levelIndex": 0, "x": 0, "y": 0}}

	_add_stack_trigger(bundle, "stack:sticky", -1, [
		_classic_action(0, -46, 1),
		_classic_action(1, 1, 900),
		_classic_action(2, 24, 0),
	])
	_add_stack_trigger(bundle, "Data ED3:macro:100", 100, [
		_classic_action(0, 46, 2),
		_classic_action(1, 1, 901),
		_classic_action(2, 111, 0),
	])
	_add_stack_trigger(bundle, "Data ED3:macro:101", 101, [
		_classic_action(0, 1, 902),
		_classic_action(1, 111, 0),
	])
	_add_stack_branch(bundle, 1, 100)
	_add_stack_branch(bundle, 2, 101)

	_add_stack_trigger(bundle, "stack:pop", -1, [
		_classic_action(0, -46, 3),
		_classic_action(1, 1, 910),
	])
	_add_stack_trigger(bundle, "Data ED3:macro:200", 200, [
		_classic_action(0, 46, 4),
		_classic_action(1, 1, 911),
		_classic_action(2, 111, 0),
	])
	_add_stack_trigger(bundle, "Data ED3:macro:201", 201, [
		_classic_action(0, 112, 0),
		_classic_action(1, 111, 0),
	])
	_add_stack_branch(bundle, 3, 200)
	_add_stack_branch(bundle, 4, 201)

	_add_stack_trigger(bundle, "stack:empty-pop", -1, [
		_classic_action(0, 112, 0),
		_classic_action(1, 1, 912),
	])

	_add_stack_trigger(bundle, "stack:extend", -1, [
		_classic_action(0, -39, 600),
		_classic_action(1, 1, 930),
	])
	_add_stack_trigger(bundle, "Data ED3:macro:600", 600, [
		_classic_action(0, 1, 931),
		_classic_action(1, 111, 0),
	])

	_add_stack_trigger(bundle, "stack:no-implicit-return", -1, [
		_classic_action(0, -46, 5),
		_classic_action(1, 1, 920),
	])
	_add_stack_trigger(bundle, "Data ED3:macro:300", 300, [
		_classic_action(0, 1, 921),
	])
	_add_stack_branch(bundle, 5, 300)

	_add_stack_trigger(bundle, "stack:overflow", -1, [
		_classic_action(0, -46, 1000),
	])
	for index: int in range(21):
		var record_id := 400 + index
		var actions: Array = []
		if index < 20:
			actions.append(_classic_action(0, 46, 1001 + index))
		else:
			actions.append(_classic_action(0, 111, 0))
		_add_stack_trigger(bundle, "Data ED3:macro:%d" % record_id, record_id, actions)
	_add_stack_branch(bundle, 1000, 400)
	for index: int in range(20):
		_add_stack_branch(bundle, 1001 + index, 401 + index)

	return bundle


func _add_stack_trigger(
	bundle,
	trigger_id: String,
	record_id: int,
	actions: Array
) -> void:
	var trigger := {
		"id": trigger_id,
		"source": "Data ED3" if record_id >= 0 else "Stack test",
		"recordIndex": record_id,
		"active": true,
		"actions": actions,
	}
	bundle.triggers_by_id[trigger_id] = trigger
	if record_id >= 0:
		bundle.extra_action_points_by_id[record_id] = trigger


func _map_trigger(
	record_index: int,
	tile_x: int,
	tile_y: int,
	actions: Array,
	percent := 100
) -> Dictionary:
	return {
		"id": "Data DD:0:%d" % record_index,
		"source": "Data DD",
		"levelType": "land",
		"levelIndex": 0,
		"recordIndex": record_index,
		"active": percent > 0,
		"percent": percent,
		"coordinate": {"x": tile_x, "y": tile_y},
		"actions": actions,
	}


func _add_map_trigger(bundle, trigger: Dictionary) -> void:
	var trigger_id := str(trigger.get("id", ""))
	bundle.triggers_by_id[trigger_id] = trigger
	var coordinate: Dictionary = trigger.get("coordinate", {})
	var key := "%s:%d:%d:%d" % [
		trigger.get("levelType", "land"),
		int(trigger.get("levelIndex", 0)),
		int(coordinate.get("x", 0)),
		int(coordinate.get("y", 0)),
	]
	bundle.triggers_by_coordinate[key] = [trigger]


func _add_stack_branch(bundle, extra_code_id: int, target_record_id: int) -> void:
	bundle.extra_codes_by_id[extra_code_id] = {
		"id": extra_code_id,
		"values": [0, 2, 0, target_record_id, 0],
	}


func _classic_action(slot: int, raw_code: int, record_id: int) -> Dictionary:
	var starts_gosub := raw_code < 0 and raw_code not in [-14, -23]
	return {
		"slot": slot,
		"rawCode": raw_code,
		"code": abs(raw_code) if starts_gosub else raw_code,
		"id": record_id,
		"gosub": starts_gosub,
	}


func _trace_has_action(entries: Array, trigger_id: String, slot: int) -> bool:
	for entry: Variant in entries:
		if entry is Dictionary and entry.get("triggerId") == trigger_id and int(entry.get("slot", -1)) == slot:
			return true
	return false


func _action_id_at_slot(actions: Array, slot: int) -> int:
	for action: Variant in actions:
		if action is Dictionary and int(action.get("slot", -1)) == slot:
			return int(action.get("id", 0))
	return 0


func _expect(condition: bool, label: String) -> void:
	if condition:
		print("PASS: ", label)
		return
	failures += 1
	push_error("FAIL: %s" % label)


func _expect_equal(actual: Variant, expected: Variant, label: String) -> void:
	_expect(actual == expected, "%s (expected %s, got %s)" % [label, expected, actual])


func _same_tile_set(left: Array, right: Array) -> bool:
	if left.size() != right.size():
		return false
	for point: Variant in left:
		if not right.has(Vector2i(point)):
			return false
	return true


func _classic_record_high(low: int, high: int) -> int:
	return low if high == 0 and low != 0 else maxi(low, high)


func _finish() -> void:
	if failures == 0:
		print("Classic runtime tests passed.")
		quit(0)
		return
	push_error("Classic runtime tests failed: %d" % failures)
	quit(1)
