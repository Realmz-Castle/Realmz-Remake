extends 'res://Creature/Creature.gd' # Weird, right?
class_name PlayerCharacter

const ClassicLearnedSpellIdentityScript = preload(
	"res://scripts/classic_runtime/classic_learned_spell_identity.gd"
)
const ClassicCharacterRulesScript = preload(
	"res://scripts/classic_runtime/classic_character_rules.gd"
)
const ClassicCharacterConditionRulesScript = preload(
	"res://scripts/classic_runtime/classic_character_condition_rules.gd"
)
const ClassicMagicResistanceScript = preload(
	"res://scripts/classic_runtime/classic_magic_resistance.gd"
)
const ClassicRegenerationScript = preload(
	"res://scripts/classic_runtime/classic_regeneration.gd"
)
const ClassicSpellScreenScript = preload(
	"res://scripts/classic_runtime/classic_spell_screen.gd"
)
const AutoCombatScript = preload(
	"res://shared_assets/CreatureScripts/test_crea_script.gd"
)

var portrait : Texture2D = null
var icon : Texture2D = null

var exp_tnl : int = 999999999999

var classgd : GDScript = null
var racegd : GDScript = null


var selection_pts : int = 0

var equippable_types : Dictionary = {
	"Mace" : 1,
	"Club" : 1,
	"Hammer" : 1,
	"Warhammer/Maul" : 1, # Two handed big blunt weapons
	"Dagger" : 1, # Better thana  knife ?
	"Shortsword" : 1, # Good for rogues and archers
	"Arming Sword" : 1, # Long 1 handed sword
	"Longsword" : 1,  # 2 handed or bastard swords
	"Short Axe" : 1,
	"Staff" : 1,
	"Pole Axe" : 1,
	"Spear" : 1,
	"Eastern Weapon" : 1,
	"Dart" : 1,
	"Throwing Bottle" : 1,
	"Throwing Dagger" : 1,
	"Throwing Rock" : 1,
	"Throwing Axe" : 1,
	"Throwing Hammer" : 1,
	"Throwing Spear" : 1,
	"Whip" : 1,
	"Bow" : 1,
	"Crossbow" : 1,
	"Quiver" : 1,
	"Throwing Aid" : 1,
	"Misc. Melee Weapon" : 1,
	"Misc Ranged Weapon" : 1,
	"Belt" : 1,
	"Necklace" : 1,
	"Ring" : 1,
	"Hat" : 1,  #cloth headwear
	"Soft Helmet" : 1, # Leather Cap...
	"Light Helmet" :1, # iron Cap
	"Great Helm" : 1, # Big Warrior helmet
	"Small Shield" : 1, #Bucklers for Fencers/Rogues...
	"Medium Shield" : 1,
	"Large Shield" : 1, #Kite/Tower shields
	"Bracers" : 1,
	"Cloth Gloves" : 1,
	"Leather Gloves" : 1,
	"Metal Gloves" : 1,
	"Cloak/Cape" : 1,
	"Robe" : 1,
	"Gambeson" : 1, #can be worn with plate armor ?
	"Leather Armor" : 1,
	"Chainmail Armor" : 1,
	"Splint Armor" : 1,
	"Plate Armor" : 1,
	"Soft Boots" : 1,
	"Hard Boots" : 1,
	"Scroll Case" : 1,
	"Ion Stone" : 1,
	"Misc. Magical Item" : -10000, #NOT EQUIPPABLE  EVER PLS
	"Misc. Item" : -10000 #NOT EQUIPPABLE  EVER PLS
	
}


var cur_campaign : String = "Free"
var classic_spell_identity_diagnostics : Array[String] = []
var classic_race_id := 0
var classic_caste_id := 0
var classic_race_name := ""
var classic_caste_name := ""
var classic_rule_profile: Dictionary = {}
var classic_magic_resistance := 0
var classic_magic_resistance_initialized := false
var classic_hand_to_hand := 0
var classic_hand_to_hand_initialized := false
var classic_prestige_penalty := 0
var classic_spellcaster_type := 0
var classic_spellcaster_type_initialized := false
var classic_first_spell_memory_byte := 0
var classic_first_spell_memory_byte_initialized := false
var classic_luck := 0
var classic_luck_initialized := false
var classic_gender := 0
var classic_age_years := 0
var classic_age_days := 0
var classic_age_group := 0
var classic_age_movement_adjustment := 0
var classic_creation_demographics_initialized := false
var classic_saving_throws: Array[int] = []
var classic_saving_throws_initialized := false
var classic_conditions: Array[int] = []
var classic_conditions_initialized := false
var classic_can_regenerate := false
var classic_can_regenerate_initialized := false
var classic_creation_resources_initialized := false
var classic_source_character: Dictionary = {}


func _init(data : Dictionary,new_icon : Texture,new_portrait : Texture,new_classgd : GDScript,new_racegd : GDScript):
#	print("PlayerCharacterGD super.init data :")
#	print(data)
	if not ("name" in data) :
		name = "NO NAME SET YET"
	else :
		name = data['name']

	is_player_controlled = true
	baseFaction = 0
	curFaction = 0
	creature_script = AutoCombatScript
	ai_variables = {
		"cast_chance": 0,
		"flees_at": 0,
		"missile_chance": 0,
	}
	portrait = new_portrait
	icon = new_icon
	classgd = new_classgd
	used_resource = classgd.used_resource
	racegd = new_racegd
	if data.has("campaign") :
		cur_campaign = data["campaign"]
	classic_race_id = int(data.get("classicRaceId", data.get("classic_race_id", 0)))
	classic_caste_id = int(data.get("classicCasteId", data.get("classic_caste_id", 0)))
	var saved_rule_profile: Variant = data.get("classicRuleProfile", {})
	if saved_rule_profile is Dictionary:
		classic_rule_profile = saved_rule_profile.duplicate(true)
	classic_race_name = str(
		data.get(
			"classicRaceName",
			classic_rule_profile.get("raceName", "")
		)
	)
	classic_caste_name = str(
		data.get(
			"classicCasteName",
			classic_rule_profile.get("casteName", "")
		)
	)
	if data.has("classicMagicResistance"):
		set_classic_magic_resistance(int(data["classicMagicResistance"]))
	elif data.has("classic_magic_resistance"):
		set_classic_magic_resistance(int(data["classic_magic_resistance"]))
	if data.has("classicHandToHand"):
		set_classic_hand_to_hand(int(data["classicHandToHand"]))
	elif data.has("classic_hand_to_hand"):
		set_classic_hand_to_hand(int(data["classic_hand_to_hand"]))
	classic_prestige_penalty = int(
		data.get(
			"classicPrestigePenalty",
			data.get("classic_prestige_penalty", 0)
		)
	)
	if data.has("classicSpellcasterType"):
		set_classic_spellcaster_type(int(data["classicSpellcasterType"]))
	elif data.has("classic_spellcaster_type"):
		set_classic_spellcaster_type(int(data["classic_spellcaster_type"]))
	if data.has("classicFirstSpellMemoryByte"):
		set_classic_first_spell_memory_byte(
			int(data["classicFirstSpellMemoryByte"])
		)
	if data.has("classicLuck"):
		set_classic_luck(int(data["classicLuck"]))
	if data.has("classicGender") \
			or data.has("classicAgeYears") \
			or data.has("classicAgeDays") \
			or data.has("classicAgeMovementAdjustment") \
			or data.has("classicAgeGroup"):
		classic_gender = int(data.get("classicGender", 0))
		classic_age_years = int(data.get("classicAgeYears", 0))
		classic_age_days = int(
			data.get("classicAgeDays", classic_age_years * 365)
		)
		classic_age_group = int(data.get("classicAgeGroup", 0))
		classic_age_movement_adjustment = int(
			data.get("classicAgeMovementAdjustment", 0)
		)
		classic_creation_demographics_initialized = true
	if data.has("classicSavingThrows"):
		set_classic_saving_throws(data["classicSavingThrows"])
	if data.has("classicConditions"):
		set_classic_conditions(data["classicConditions"])
	if data.has("classicCanRegenerate"):
		set_classic_can_regenerate(bool(data["classicCanRegenerate"]))
	classic_creation_resources_initialized = bool(
		data.get("classicCreationResourcesInitialized", false)
	)
	var saved_source_character: Variant = data.get(
		"classicSourceCharacter",
		{}
	)
	if saved_source_character is Dictionary:
		classic_source_character = saved_source_character.duplicate(true)
	if data.has("is_npc_ally") :
		is_npc_ally = bool(data["is_npc_ally"])
	if data.has("is_summoned") :
		is_summoned = bool(data["is_summoned"])
	if data.has("summoner_name") :
		summoner_name = data["summoner_name"]
	if data.has("joins_combat") :
		joins_combat = bool(data["joins_combat"])
	if data.has("classicSpecialAbilities"):
		restore_classic_special_abilities(data["classicSpecialAbilities"])
	if data.has("exp_tnl") :
		exp_tnl = data["exp_tnl"]
#
	if data.has("money") :
		money = data["money"]
	else :
		money = [0,0,0]


	var restored_inventory_equipment := false
	if data.has("inventory") :
		var resourcenode = NodeAccess.__Resources()
		var restored_result: Dictionary = (
			resourcenode.deserialize_item_inventory_preserving_unresolved(
				data["inventory"]
			)
			if resourcenode != null
				and resourcenode.has_method(
					"deserialize_item_inventory_preserving_unresolved"
				)
			else {
				"ok": false,
				"errors": ["Item serialization service is unavailable"],
			}
		)
		if bool(restored_result.get("ok", false)):
			preserve_deferred_item_inventory(restored_result.get("deferred", []))
			for item_value: Variant in restored_result.get("instances", []):
				if not (item_value is ItemInstance):
					continue
				var item: ItemInstance = item_value
				var definition := resourcenode.get_item_definition(item)
				print(
					"PC init ITEM  ",
					definition.display_name_for(item) if definition != null else "",
				)
				_append_restored_inventory_item(item)
			restored_inventory_equipment = true
		else:
			for message: Variant in restored_result.get("errors", []):
				push_error(str(message))

	if data.has("spells") :
		spells = data["spells"]
		for slevel in spells :
			for spelldict in slevel :
				var spellscript : GDScript = GDScript.new()
				var spellsource = spelldict["source"]
				spellscript.set_source_code(spellsource)
				var _err_newscript_reload = spellscript.reload()
				var newscript = spellscript.new()
				spelldict["script"] = newscript
	else :
		spells = []

	if classgd :
#		print("PlayerCharacter classgd.get_script_method_list() : ", classgd.get_script_method_list())
		classgd._mod_equippable(self)
	if racegd :
		racegd._mod_equippable(self)

	if not data.has("base_stats") :
		level = 0
		selection_pts = 0
		var targlevel : int = data["level"]
		apply_raceclass_base_stats()
		while level < targlevel :
			level_up()
	else :
		level = data["level"]
		base_stats = data["base_stats"]
		selection_pts = data["selection_pts"]


	#set current "Melee Weapon" "Ranged Weapon" "Ammunition"
	if not restored_inventory_equipment:
		for item: ItemInstance in item_inventory.duplicate():
			if not item.equipped:
				continue
			item.equipped = false
			equip_item(item)

	recalculate_stats()
#	# generate inventory from the data dict :
#	if data.has("inventory") :
#		var data_inventory = data["inventory"]
#		var resources = NodeAccess.__Resources()
#		for item_dict in data_inventory :
#			var new_item = resources.generate_item_from_json_dict(item_dict)
#			add_inventory_item(new_item)
#			if new_item["equipped"] == 2 : #had been marked for equipping in Utils save_character
#				equip_item(new_item)


	if data.has("traits") :
		var data_traits = data["traits"]  #{source:"",
		for trait_dict in data_traits :
			if trait_dict["type"] == "standard" :
				var traitscript = load("res://shared_assets/traits/"+trait_dict["name"])
				add_trait(traitscript,trait_dict["saved_variables"])

	if data.has("curHP") :
		stats["curHP"] = data["curHP"]
	else :
		stats["curHP"] = stats["maxHP"]
	if stats["curHP"]<0 :
		#var life_status : int = 0  #0=fine  1=ko'd bleeding 2=ko'd bandaged 3=dead
		life_status = 2
	if data.has("curSP") :
		stats["curSP"] = data["curSP"]
	else :
		stats["curSP"] = stats["maxSP"]

#			elif  trait_dict["type"] == "custom" :
#				var newscript = GDScript.new()
#
#				var source = trait_dict["source"]
#				newscript.set_source_code(source)
#				var _err_newscript_reload = newscript.reload()
#				if _err_newscript_reload != OK :
#					print("ERROR LOADING CHaracter TRAIT SCRIPT "+" , error code : "+_err_newscript_reload)
#
#				if trait_dict["saved_variables"] != [] :
#					add_trait(newscript.new(trait_dict["saved_variables"]) )
#				else :
#					add_trait(newscript.new() )


func resolve_classic_learned_spell_identities(
	spell_book: Dictionary,
	spell_id_mapping: Dictionary
) -> Array[String]:
	var school_evidence := _classic_learned_spell_school()
	var resolution := ClassicLearnedSpellIdentityScript.resolve_spell_levels(
		spells,
		spell_book,
		spell_id_mapping,
		school_evidence
	)
	spells = resolution.get("spellLevels", spells)
	classic_spell_identity_diagnostics.clear()
	for diagnostic_value: Variant in resolution.get("diagnostics", []):
		var diagnostic := str(diagnostic_value)
		classic_spell_identity_diagnostics.append(diagnostic)
		push_warning("%s: %s" % [name, diagnostic])
	return classic_spell_identity_diagnostics.duplicate()


func _classic_learned_spell_school() -> String:
	if classic_spellcaster_type_initialized:
		return ClassicCharacterRulesScript.spellcaster_school(
			classic_spellcaster_type
		)
	return ClassicLearnedSpellIdentityScript.school_evidence_for_character(self, classgd)


func apply_classic_rule_profile(profile: Dictionary) -> void:
	classic_rule_profile = profile.duplicate(true)
	classic_race_id = int(profile.get("raceId", classic_race_id))
	classic_caste_id = int(profile.get("casteId", classic_caste_id))
	classic_race_name = str(profile.get("raceName", classic_race_name))
	classic_caste_name = str(profile.get("casteName", classic_caste_name))


func clear_classic_rule_profile() -> void:
	classic_rule_profile.clear()
	classic_race_name = ""
	classic_caste_name = ""


func get_display_race_name() -> String:
	if not classic_race_name.is_empty():
		return classic_race_name
	if racegd:
		return str(racegd.classrace_name)
	return ""


func get_display_caste_name() -> String:
	if not classic_caste_name.is_empty():
		return classic_caste_name
	if classgd:
		return str(classgd.classrace_name)
	return ""


func set_classic_magic_resistance(value: int) -> void:
	classic_magic_resistance = value
	classic_magic_resistance_initialized = true
	set_meta(ClassicMagicResistanceScript.META_KEY, value)


func has_classic_magic_resistance() -> bool:
	return classic_magic_resistance_initialized


func set_classic_hand_to_hand(value: int) -> void:
	classic_hand_to_hand = value
	classic_hand_to_hand_initialized = true


func has_classic_hand_to_hand() -> bool:
	return classic_hand_to_hand_initialized


func set_classic_spellcaster_type(value: int) -> void:
	classic_spellcaster_type = value
	classic_spellcaster_type_initialized = value > 0
	if classic_spellcaster_type_initialized:
		used_resource = "SP"


func set_classic_first_spell_memory_byte(value: int) -> void:
	classic_first_spell_memory_byte = clampi(value, -128, 127)
	classic_first_spell_memory_byte_initialized = true


func set_classic_luck(value: int) -> void:
	classic_luck = value
	classic_luck_initialized = true


func set_classic_creation_spell_points(value: int) -> void:
	base_stats["maxSP"] = maxi(0, value)
	recalculate_stats()
	stats["curSP"] = get_stat("maxSP")


func set_classic_creation_attributes(values: Dictionary) -> void:
	for stat_name: String in [
		"Strength",
		"Intellect",
		"Wisdom",
		"Dexterity",
		"Vitality",
	]:
		if values.has(stat_name):
			base_stats[stat_name] = values[stat_name]
	if values.has("classicLuck"):
		set_classic_luck(int(values["classicLuck"]))
	classic_gender = int(values.get("classicGender", classic_gender))
	classic_age_years = int(values.get("classicAgeYears", classic_age_years))
	classic_age_days = int(
		values.get("classicAgeDays", classic_age_years * 365)
	)
	classic_age_group = int(values.get("classicAgeGroup", classic_age_group))
	classic_creation_demographics_initialized = true
	recalculate_stats()


func set_classic_age_state(values: Dictionary) -> void:
	var recalculate := false
	var attributes: Variant = values.get("attributes", {})
	if attributes is Dictionary:
		for stat_name: String in [
			"Strength",
			"Intellect",
			"Wisdom",
			"Dexterity",
			"Vitality",
		]:
			if attributes.has(stat_name):
				base_stats[stat_name] = attributes[stat_name]
				recalculate = true
	if values.has("AccuracyMelee"):
		base_stats["AccuracyMelee"] = values["AccuracyMelee"]
		recalculate = true
	if values.has("Bonus_Physical_dmg"):
		base_stats["Bonus_Physical_dmg"] = values["Bonus_Physical_dmg"]
		recalculate = true
	if values.has("classicLuck"):
		set_classic_luck(int(values["classicLuck"]))
	classic_age_days = int(values.get("classicAgeDays", classic_age_days))
	classic_age_years = int(values.get("classicAgeYears", classic_age_years))
	classic_age_group = int(values.get("classicAgeGroup", classic_age_group))
	classic_age_movement_adjustment = int(
		values.get(
			"classicAgeMovementAdjustment",
			classic_age_movement_adjustment
		)
	)
	if values.has("classicMagicResistance"):
		set_classic_magic_resistance(
			int(values["classicMagicResistance"])
		)
	if values.has("classicSavingThrows"):
		set_classic_saving_throws(values["classicSavingThrows"])
	if recalculate:
		recalculate_stats()


func advance_classic_age_days(day_change: int) -> Dictionary:
	return ClassicCharacterRulesScript.advance_character_age_days(
		self,
		day_change
	)


func advance_classic_age_between_times(
	previous_time: int,
	current_time: int
) -> Dictionary:
	return ClassicCharacterRulesScript.advance_character_age_between_times(
		self,
		previous_time,
		current_time
	)


func has_classic_creation_demographics() -> bool:
	return classic_creation_demographics_initialized


func set_classic_saving_throws(values: Variant) -> void:
	classic_saving_throws.clear()
	if values is Array:
		for index: int in range(mini(8, values.size())):
			classic_saving_throws.append(int(values[index]))
	classic_saving_throws_initialized = classic_saving_throws.size() == 8


func has_classic_saving_throws() -> bool:
	return classic_saving_throws_initialized


func get_classic_saving_throw(save_index: int) -> int:
	if not classic_saving_throws_initialized \
			or save_index < 0 \
			or save_index >= classic_saving_throws.size():
		return 0
	return classic_saving_throws[save_index]


func set_classic_conditions(values: Variant) -> void:
	classic_conditions.clear()
	if values is Array:
		for index: int in range(mini(40, values.size())):
			classic_conditions.append(int(values[index]))
	classic_conditions_initialized = classic_conditions.size() == 40
	remove_meta(ClassicRegenerationScript.META_KEY)
	if classic_conditions_initialized \
			and classic_conditions[ClassicRegenerationScript.CONDITION_INDEX] < 0:
		set_meta(
			ClassicRegenerationScript.META_KEY,
			absi(
				classic_conditions[
					ClassicRegenerationScript.CONDITION_INDEX
				]
			)
		)
	var spell_screen_level := (
		ClassicSpellScreenScript.permanent_level(classic_conditions)
		if classic_conditions_initialized
		else 0
	)
	if spell_screen_level > 0:
		set_meta(ClassicSpellScreenScript.META_KEY, spell_screen_level)
	else:
		remove_meta(ClassicSpellScreenScript.META_KEY)


func has_classic_conditions() -> bool:
	return classic_conditions_initialized


func set_classic_condition(condition_index: int, value: int) -> void:
	if not classic_conditions_initialized \
			or condition_index < 0 \
			or condition_index >= classic_conditions.size():
		return
	classic_conditions[condition_index] = value


func get_classic_condition(condition_index: int) -> int:
	if not classic_conditions_initialized \
			or condition_index < 0 \
			or condition_index >= classic_conditions.size():
		return 0
	return classic_conditions[condition_index]


func set_classic_can_regenerate(value: bool) -> void:
	classic_can_regenerate = value
	classic_can_regenerate_initialized = true


func set_classic_creation_combat_stats(values: Dictionary) -> void:
	for stat_name: String in [
		"maxHP",
		"AccuracyMelee",
		"AccuracyRanged",
		"EvasionMelee",
		"EvasionRanged",
		"Bonus_Physical_dmg",
	]:
		if values.has(stat_name):
			base_stats[stat_name] = values[stat_name]
	if values.has("classicHandToHand"):
		set_classic_hand_to_hand(int(values["classicHandToHand"]))
	recalculate_stats()
	stats["curHP"] = get_stat("maxHP")


func set_classic_creation_resources(
	items: Array,
	starting_money: int
) -> Dictionary:
	if classic_creation_resources_initialized:
		return {"status": "skipped", "reason": "already-applied"}
	for item_value: Variant in items:
		if not (item_value is ItemInstance or item_value is Dictionary):
			return {
				"status": "error",
				"message": "Classic starting resources contain an invalid item.",
			}
	for item_value: ItemInstance in item_inventory:
		if item_value.equipped:
			return {
				"status": "error",
				"message": (
					"Classic starting resources must be applied before equipment."
				),
			}

	# Native race/class gifts are replaced, not combined with the active
	# Classic caste's creation resources.
	clear_inventory_items()
	money = [0, 0, 0]
	var added_item_ids: Array[int] = []
	var skipped_item_ids: Array[int] = []
	for item_value: Variant in items:
		var item: ItemInstance = NodeAccess.__Resources().import_item_instance(
			item_value
		)
		if item == null:
			continue
		item.identified = true
		item.equipped = false
		var item_ids := NodeAccess.__Resources().item_classic_ids(item)
		var item_id: int = item_ids[0] if not item_ids.is_empty() else 0
		if add_inventory_item(item):
			added_item_ids.append(item_id)
		else:
			skipped_item_ids.append(item_id)

	# Realmz checks item weight before adding startmoney to carried load.
	money[0] = starting_money
	var unequipped_item_ids: Array[int] = []
	for item_value: ItemInstance in item_inventory:
		var definition := get_item_definition(item_value)
		if definition == null or not definition.equippable:
			continue
		if not equip_item(item_value):
			var item_ids := NodeAccess.__Resources().item_classic_ids(item_value)
			unequipped_item_ids.append(
				item_ids[0] if not item_ids.is_empty() else 0
			)
	classic_creation_resources_initialized = true
	return {
		"status": "ok",
		"startingMoney": starting_money,
		"addedItemIds": added_item_ids,
		"skippedItemIds": skipped_item_ids,
		"unequippedItemIds": unequipped_item_ids,
	}


func has_classic_creation_resources() -> bool:
	return classic_creation_resources_initialized


func has_classic_spellcaster_type() -> bool:
	return classic_spellcaster_type_initialized


func has_classic_first_spell_memory_byte() -> bool:
	return classic_first_spell_memory_byte_initialized


func get_stat(statname: String):
	return ClassicCharacterRulesScript.adjusted_stat(
		self,
		classic_rule_profile,
		statname,
		super.get_stat(statname)
	)


func apply_raceclass_base_stats() :
	for s in base_stats :
		base_stats[s] = 0
	for s in stats :
		stats[s] = 0
	classgd._add_base_stats(self)
	racegd._add_base_stats(self)
	stats = base_stats.duplicate(true)
	#full heal !
	stats["curHP"] = base_stats["maxHP"]
	stats["curSP"] = base_stats["maxSP"]
	stats["curFP"] = base_stats["maxFP"]
	stats["curTP"] = base_stats["maxTP"]
	stats["curRP"] = base_stats["maxRP"]

#	print(name," has curHP maxHP : ", stats["curHP"], ' ',stats["maxHP"])
	can_dual_wield = classgd.can_dual_wield and racegd.can_dual_wield
	print("PC after apply_raceclass_base_stats(), ",base_stats["curHP"] ,'/',base_stats["maxHP"])




func level_up() :
	print("PC b4 level up  base_stats ", base_stats["curHP"] ,'/',base_stats["maxHP"])
	level +=1
	classgd._level_up(self, level)
	racegd._level_up(self, level)

	recalculate_stats()
	ClassicCharacterRulesScript.apply_level_up_stamina_progression(self)
	var spellcasting_result := (
		ClassicCharacterRulesScript.apply_level_up_spellcasting_progression(self)
	)
	if str(spellcasting_result.get("status", "")) == "error":
		push_error(str(spellcasting_result.get("message", "")))
	ClassicCharacterRulesScript.apply_level_up_combat_progression(self)
	ClassicCharacterRulesScript.apply_level_up_attack_progression(self)
	ClassicCharacterRulesScript.apply_level_up_magic_resistance(self)
	var special_ability_result := (
		ClassicCharacterRulesScript.apply_level_up_special_ability_progression(
			self
		)
	)
	if str(special_ability_result.get("status", "")) == "error":
		push_error(str(special_ability_result.get("message", "")))
	var condition_result := (
		ClassicCharacterRulesScript.apply_level_up_condition_progression(self)
	)
	if str(condition_result.get("status", "")) == "error":
		push_error(str(condition_result.get("message", "")))
	print("PC after level up  base_stats ", base_stats["curHP"] ,'/',base_stats["maxHP"])


func can_equip_item(item) -> bool :
	var instance := get_item_instance(item)
	if instance == null and item is ItemInstance:
		instance = item
	var definition := get_item_definition(instance)
	if definition == null:
		return false
	print(
		"PlayerCharacter "+name+" can_equip_item : ",
		definition.display_name_for(instance),
	)
#	print(equipment_slots)
	var classic_permission := (
		ClassicCharacterRulesScript.classic_item_use_permission(
			self,
			NodeAccess.__Resources().legacy_item_view_for_adapter(instance),
		)
	)
	if not bool(classic_permission.get("allowed", true)):
		return false
	var classic_identity_handled := bool(
		classic_permission.get("handlesIdentityRestrictions", false)
	)
	#check "only_usable_by_classes"
	var my_class_types : Array = classgd.classrace_types
	var my_race_types : Array = racegd.classrace_types

	var item_usable_by_classes := definition.only_usable_by_classes()
	if not item_usable_by_classes.is_empty() and not classic_identity_handled :
		if not array_contains_lfstr_or_one_of_oarray(item_usable_by_classes, classgd.classrace_name,my_class_types) :
			return false
	var item_usable_by_races := definition.only_usable_by_races()
	if not item_usable_by_races.is_empty() and not classic_identity_handled :
		if not array_contains_lfstr_or_one_of_oarray(item_usable_by_races, racegd.classrace_name,my_race_types) :
			return false
	var item_not_usable_by_classes := definition.not_usable_by_classes()
	if not item_not_usable_by_classes.is_empty():
		if array_contains_lfstr_or_one_of_oarray(item_not_usable_by_classes, classgd.classrace_name,my_class_types) :
			return false
	var item_not_usable_by_races := definition.not_usable_by_races()
	if not item_not_usable_by_races.is_empty():
		if array_contains_lfstr_or_one_of_oarray(item_not_usable_by_races, racegd.classrace_name,my_race_types) :
			return false
	#check "not_usable_by"
	var hasfreeslots : bool = true
	var item_slots := definition.slots()
	for s in item_slots:
		hasfreeslots = hasfreeslots and (equipment_slots[s]==0)
	print(" PlayerCharacter hasfreeslots l274 : ", hasfreeslots)
	if definition.hand_count > 0:

	# you can equip two 1 handed melee weapons if you can dual wield
	# however you may still equip  only  one shield
		if item_slots.has("Shield") :
			hasfreeslots = hasfreeslots and (free_hands >= definition.hand_count)
			print(" PlayerCharacter hasfreeslots l281: ", hasfreeslots)
		else :
			if item_slots.has("Melee Weapon") :
				hasfreeslots =  hasfreeslots and (free_hands >= definition.hand_count)
				print(" PlayerCharacter hasfreeslots l284: ", hasfreeslots)
			if item_slots.has("Melee Weapon") and equipment_slots["Melee Weapon"]!=0 :
				hasfreeslots = can_dual_wield and hasfreeslots
	print(" PlayerCharacter canequipitem : ", equippable_types[definition.item_type]>0, 'free slots:',hasfreeslots)
	return equippable_types[definition.item_type]>0 and hasfreeslots #and super.can_equip_item(item)


func can_use_inventory_item(item: Variant) -> bool:
	var instance := get_item_instance(item)
	if instance == null and item is ItemInstance:
		instance = item
	if instance == null:
		return false
	var permission := (
		ClassicCharacterRulesScript.classic_item_use_permission(
			self,
			NodeAccess.__Resources().legacy_item_view_for_adapter(instance),
		)
	)
	return bool(permission.get("allowed", true))


func array_contains_lfstr_or_one_of_oarray( arr : Array,  lfstr : String, oarr :Array) -> bool :
	if arr.has(lfstr) :
		return true
	var has_oarr : bool = false
	for a in arr :
		for o in oarr :
			if a==o :
				has_oarr = true
				break
	if has_oarr :
		return true
	return false


func get_max_perma_summons() ->int :
	return classgd.get_max_perma_summons(self)

func get_selection_cost(ability) -> int:
	if ClassicCharacterRulesScript.has_classic_spell_selection(self):
		return ClassicCharacterRulesScript.classic_spell_selection_cost_for_spell(
			self,
			ability
		)
	var cost : float = 0
	cost = racegd.get_selection_cost(self, ability, cost) + classgd.get_selection_cost(self, ability, cost)
	return roundi(cost)
#func get_used_resource()->String :
#	return classgd.used_resource

static func get_exp_req_for_lvl(lvl : int) -> int :
	return pow(lvl,3)*100

## returns  the spell level at which the character can learn spell,  or  0 if it can't.
## should return a value in [0,7]
func can_learn_spell_at_level(spell) -> int :
	if ClassicCharacterRulesScript.has_classic_spell_selection(self):
		return ClassicCharacterRulesScript.classic_spell_level(self, spell)
	#print("PlayerCHararcter.gd can_learn_spell_at_level ", spell.get_script_property_list())
	var spell_level : int = classgd.can_learn_spell(self,spell) + racegd.can_learn_spell(self,spell)
	#printerr("PlayerCharacter.gd can_learn_spell_at_level ", name, ' ',spell.name, ' lv? ', spell_level )
	if spell_level > 7 : return 0
	return max(1, spell_level)

##returns an array of  arrays  [spellname:String, level:int]
func get_abilities_pc_can_learn() ->Array : #only  Strings  as spell names
	#printerr("PlayerCharacter.gd get_abilities_pc_can_learn for "+name)
	var spells_book = NodeAccess.__Resources().spells_book
	var returned = []
	for sn in spells_book :#classgd.get_abilities_pc_can_learn(self) :
		#printerr("PlayerCharacter.gd get_abilities_pc_can_learn "+sn)
		var s_level : int = can_learn_spell_at_level(spells_book[sn]['script'])
		if s_level>0 :
			returned.append([sn, s_level])
	#for sn in racegd.get_abilities_pc_can_learn(self) :
		#if can_learn_spell(spells_book[sn]) :
			#if (not returned.has(sn)) :
				#returned.append(sn)
	#printerr("PlayerCharacter.gd get_abilities_pc_can_learn ", returned)
	return returned

#func can_manage_ablt_anywhere()->bool :
	#return classgd.can_manage_ablt_anywhere

func can_show_ability_list() -> bool :
	return (
		ClassicCharacterRulesScript.has_classic_spell_selection(self)
		or classgd.can_manage_ablt_anywhere
	)


func get_ability_selection_points() -> int:
	if ClassicCharacterRulesScript.has_classic_spell_selection(self):
		return ClassicCharacterRulesScript.classic_spell_selection_remaining(self)
	return selection_pts


func set_ability_selection_points(value: int) -> void:
	if ClassicCharacterRulesScript.has_classic_spell_selection(self):
		return
	selection_pts = value


func get_ability_selection_points_label() -> String:
	if ClassicCharacterRulesScript.has_classic_spell_selection(self):
		return "Spell Selection Points"
	return "Ability Selection Points"


func prepare_ability_selection() -> void:
	if ClassicCharacterRulesScript.has_classic_spell_selection(self):
		ClassicCharacterRulesScript.enforce_classic_spell_selection_budget(self)


func ensure_classic_spell_levels(maximum_level: int) -> void:
	var target_level := clampi(maximum_level, 0, 7)
	while spells.size() < target_level:
		spells.append([])


func get_spell_resource_cost(spell, plvl : int) :
	#print("PlayerChar get_spell_resource_cost "+name+' '+classgd.classrace_name+' '+racegd.classrace_name+' : '+spell.name+' '+str(plvl))
	if spell.has_method("get_sp_cost") :
		var cost = spell.get_sp_cost(plvl,self)
		#print("PlayerChar get_spell_resource_cost "+spell.name+' : '+str(cost))
		cost += classgd.get_ablty_res_cost_mod(self, spell, plvl, cost)
		#print("PlayerChar get_spell_resource_cost after class : "+str(cost))
		cost += racegd.get_ablty_res_cost_mod(self, spell, plvl, cost)
		#print("PlayerChar get_spell_resource_cost after race : "+str(cost))
		for t in traits :
			if t.has_method("_on_get_spell_sp_cost") :
				#print("PlayerCHar get_spell_resource_cost trait affects")
				cost = t._on_get_spell_sp_cost(cost,spell, plvl, self)
		print(max(0,floor(cost)))
		return max(0,floor(cost))
	else :
		return 0


func start_parrying()->void :
	var traitscript = load(classgd.get_parrying_trait_name(self))
	#print("PlayerChara start_parrying  ", classgd.get_parrying_trait_name(self))
	add_trait(traitscript, [self])
func start_guarding()->void :
	var traitscript = load(classgd.get_guarding_trait_name(self))
	add_trait(traitscript, [self])
func start_preparing()->void :
	var traitscript = load(classgd.get_preparing_trait_name(self))
	add_trait(traitscript, [self])




func get_save_string()->String :
	var crea_string : String = super.get_save_string()
	if crea_string.is_empty():
		return ""
	crea_string += (',\n"selection_pts" : '+ str(selection_pts))
	crea_string += (',\n"exp_tnl" : '+ str(exp_tnl))
	crea_string += (',\n"campaign" : "'+ str(cur_campaign)+'"')
	if classic_race_id > 0:
		crea_string += (',\n"classicRaceId" : '+ str(classic_race_id))
	if classic_caste_id > 0:
		crea_string += (',\n"classicCasteId" : '+ str(classic_caste_id))
	if not classic_race_name.is_empty():
		crea_string += (
			',\n"classicRaceName" : '
			+ JSON.stringify(classic_race_name)
		)
	if not classic_caste_name.is_empty():
		crea_string += (
			',\n"classicCasteName" : '
			+ JSON.stringify(classic_caste_name)
		)
	if not classic_rule_profile.is_empty():
		crea_string += (',\n"classicRuleProfile" : '+ JSON.stringify(classic_rule_profile))
	if classic_magic_resistance_initialized:
		crea_string += (
			',\n"classicMagicResistance" : '
			+ str(classic_magic_resistance)
		)
	if classic_hand_to_hand_initialized:
		crea_string += (
			',\n"classicHandToHand" : '
			+ str(classic_hand_to_hand)
		)
	if classic_prestige_penalty != 0:
		crea_string += (
			',\n"classicPrestigePenalty" : '
			+ str(classic_prestige_penalty)
		)
	if classic_spellcaster_type_initialized:
		crea_string += (
			',\n"classicSpellcasterType" : '
			+ str(classic_spellcaster_type)
		)
	if classic_first_spell_memory_byte_initialized:
		crea_string += (
			',\n"classicFirstSpellMemoryByte" : '
			+ str(classic_first_spell_memory_byte)
		)
	if classic_luck_initialized:
		crea_string += (',\n"classicLuck" : '+ str(classic_luck))
	if classic_creation_demographics_initialized:
		crea_string += (',\n"classicGender" : '+ str(classic_gender))
		crea_string += (',\n"classicAgeYears" : '+ str(classic_age_years))
		crea_string += (',\n"classicAgeDays" : '+ str(classic_age_days))
		crea_string += (',\n"classicAgeGroup" : '+ str(classic_age_group))
		crea_string += (
			',\n"classicAgeMovementAdjustment" : '
			+ str(classic_age_movement_adjustment)
		)
	if classic_saving_throws_initialized:
		crea_string += (
			',\n"classicSavingThrows" : '
			+ JSON.stringify(classic_saving_throws)
		)
	if classic_conditions_initialized:
		crea_string += (
			',\n"classicConditions" : '
			+ JSON.stringify(
				ClassicCharacterConditionRulesScript.snapshot(self)
			)
		)
	if classic_can_regenerate_initialized:
		crea_string += (
			',\n"classicCanRegenerate" : '
			+ str(classic_can_regenerate)
		)
	if classic_creation_resources_initialized:
		crea_string += ',\n"classicCreationResourcesInitialized" : true'
	if not classic_source_character.is_empty():
		crea_string += (
			',\n"classicSourceCharacter" : '
			+ JSON.stringify(classic_source_character)
		)
	crea_string += ('\n}')
	return crea_string
