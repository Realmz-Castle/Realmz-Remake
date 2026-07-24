const classrace_name : String = "Priest"
const classrace_types : Array = ["Magic Classes"]  # changed to reflect divine magic type
const classrace_definition : String = "Description will come soon" # leave it as is
const can_dual_wield : bool = false  #leave it as is
const used_resource : String = "MP"  #changed to MP for magic class
const can_manage_ablt_anywhere = false  #leave it as is
const max_spell_lvl = 7

#Applied once on character creation
const base_stat_bonuses : Dictionary = {
	"MaxMovement" : -1,
	"MaxActions" : 1,
	"MaxSpellsPerRound" : 2,
	"Weight_Limit" : 0,
	"Strength" : -1,
	"Intellect" : 1,
	"Wisdom" : 2,
	"Dexterity" : -1,
	"Vitality" : 0,
	"curHP" : 12,
	"curSP" : 0,
	"curTP" : 0,
	"curFP" : 0,
	"curMP" : 0,
	"maxHP" : 12,
	"maxSP" : 0,
	"maxTP" : 0,
	"maxFP" : 0,
	"maxMP" : 100,
	"HP_regen_base" : 0.0,
	"SP_regen_base" : 0.0,
	"HP_regen_mult" : 0.0,
	"SP_regen_mult" : -10.0,
	"AccuracyMelee" : 0.04,
	"AccuracyRanged" : 0.03,
	"AccuracyMagic" : 1.0,
	"EvasionMelee" : 0,
	"EvasionRanged" : 0.04,
	"EvasionMagic" : 0,
	"ResistancePhysical" : 0.0,
	"ResistanceFire" : 0.0,
	"ResistanceIce" : 0.0,
	"ResistanceElect" : 0.0,
	"ResistancePoison" : 0.0,
	"ResistanceChemical" : 0.0,
	"ResistanceDisease" : 0.0,
	"ResistanceMagic" : 0.0,
	"ResistanceHealing" : 0.0,
	"ResistanceMental" : 0.0,
	"MultiplierPhysical" : 1.0,
	"MultiplierFire" : 1.025,
	"MultiplierIce" : 0.975,
	"MultiplierElect" : 1.0,
	"MultiplierPoison" : 1.0,
	"MultiplierChemical" : 0.975,
	"MultiplierDisease" : 1.0,
	"MultiplierMagic" : 1.025,
	"MultiplierHealing" : 1.0,
	"MultiplierMental" : 0.975,
	"Melee_Crit_Rate" : 0.0,
	"Melee_Crit_Mult" : 2.0,
	"Ranged_Crit_Rate" : 0.0,
	"Ranged_Crit_Mult" : 1.5,
	"Detect_Secret" : 5,
	"Acrobatics" : 2.0,
	"Detect_Trap" : 5.0,
	"Disable_Trap" : 2.0,
	"Force_Lock" : 10.0,
	"Pick_Lock" : 0.0,
	"Turn_Undead" : 5.0
}

#How those values increase !
const levelup_bonuses : Dictionary = {
	"MaxMovement" : 0,
	"MaxActions" : 0,
	"MaxSpellsPerRound" : 0,
	"Weight_Limit" : 0,
	"Strength" : 0,
	"Intellect" : 0,
	"Wisdom" : 0,
	"Dexterity" : 0,
	"Vitality" : 0,
	"curHP" : 0,
	"curSP" : 0,
	"maxHP" : 4,
	"maxSP" : 0,
	"HP_regen_base" : 0.0,
	"SP_regen_base" : 0.0,
	"HP_regen_mult" : 0.0,
	"SP_regen_mult" : 0.0,
	"AccuracyMelee" : 0.04,
	"AccuracyRanged" : 0.02,
	"AccuracyMagic" : 0,
	"EvasionMelee" : 0,
	"EvasionRanged" : 0.02,
	"EvasionMagic" : 0,
	"ResistancePhysical" : 0.0,
	"ResistanceFire" : 0.0,
	"ResistanceIce" : 0.0,
	"ResistanceElect" : 0.0,
	"ResistancePoison" : 0.0,
	"ResistanceChemical" : 0.0,
	"ResistanceDisease" : 0.0,
	"ResistanceMagic" : 0.0,
	"ResistanceHealing" : 0.0,
	"ResistanceMental" : 0.0,
	"MultiplierPhysical" : 0.0,
	"MultiplierFire" : 0.0,
	"MultiplierIce" : 0.0,
	"MultiplierElect" : 0.0,
	"MultiplierPoison" : 0.0,
	"MultiplierChemical" : 0.0,
	"MultiplierDisease" : 0.0,
	"MultiplierMagic" : 0.0,
	"MultiplierHealing" : 0.0,
	"MultiplierMental" : 0.0,
	"Melee_Crit_Rate" : 0.0,
	"Melee_Crit_Mult" : 0.0,
	"Ranged_Crit_Rate" : 0.0,
	"Ranged_Crit_Mult" : 0.0,
	"Detect_Secret" : 2.0,
	"Acrobatics" : 0.0,
	"Detect_Trap" : 0.0,
	"Disable_Trap" : 0.0,
	"Force_Lock" : 1.0,
	"Pick_Lock" : 0.0,
	"Turn_Undead" : 5.0
}

static func _mod_equippable(_character) :
	var mod_equippable_types : Dictionary = {
"Ion Stone" : 1,
		"Mace" : 1,
		"Club" : 1,
		"Hammer" : 1,
		"Warhammer/Maul" : 1,
		"Dagger" : 0,
		"Shortsword" : 0,
		"Arming Sword" : 0,
		"Longsword" : 0,
		"Short Axe" : 0,
		"Staff" : 1,
		"Pole Axe" : 0,
		"Spear" : 0,
		"Eastern Weapon" : 0,
		"Dart" : 0,
		"Throwing Bottle" : 1,
		"Throwing Dagger" : 0,
		"Throwing Rock" : 0,
		"Throwing Axe" : 0,
		"Throwing Hammer" : 1,
		"Throwing Spear" : 0,
		"Whip" : 1,
		"Bow" : 0,
		"Crossbow" : 0,
		"Quiver" : 0,
		"Throwing Aid" : 0,
		"Misc. Melee Weapon" : 0,
		"Misc Ranged Weapon" : 0,
		"Belt" : 1,
		"Necklace" : 1,
		"Ring" : 1,
		"Hat" : 1,
		"Soft Helmet" : 1,
		"Light Helmet" : 1,
		"Great Helm" : 1,
		"Small Shield" : 1,
		"Medium Shield" : 1,
		"Large Shield" : 1,
		"Bracers" : 1,
		"Cloth Gloves" : 1,
		"Leather Gloves" : 1,
		"Metal Gloves" : 1,
		"Cloak/Cape" : 1,
		"Robe" : 1,
		"Gambeson" : 1,
		"Leather Armor" : 1,
		"Chainmail Armor" : 1,
		"Splint Armor" : 1,
		"Plate Armor" : 1,
		"Soft Boots" : 1,
		"Hard Boots" : 1,
		"Scroll Case" : 1
	}

	for t in mod_equippable_types :
		_character.equippable_types[t] += mod_equippable_types[t]



static func _add_base_stats(_character) :
	for s in base_stat_bonuses :
		if typeof (base_stat_bonuses[s] ) == TYPE_DICTIONARY  :
			if not _character.base_stats.has(s) :
				_character.base_stats[s] = {}
				for t in base_stat_bonuses[s] :
					_character.base_stats[s][t] = 0
			for t in base_stat_bonuses[s] :
				_character.base_stats[s][t] += base_stat_bonuses[s][t]
		else :
			if not _character.base_stats.has(s) :
				_character.base_stats[s] = 0
			_character.base_stats[s] += base_stat_bonuses[s]



static func _level_up(_character, _new_level : int) :
	for s in levelup_bonuses :
		if typeof (levelup_bonuses[s] ) == TYPE_DICTIONARY  :
			if not _character.base_stats.has(s) :
				_character.base_stats[s] = {}
			for t in levelup_bonuses[s] :
				_character.base_stats[s][t] += levelup_bonuses[s][t]
		else :
			if not _character.base_stats.has(s) :
				_character.base_stats[s] = 0
			_character.base_stats[s] += levelup_bonuses[s]
	# ADD APR AT LEVEL
	if [10,20].has(_new_level) :
		_character.base_stats["MaxActions"] += 0.5

## returns  the  Spell Level at which a spell is learned.
## <=0 should be changed to 1 in PlayerCHaracter 's can_learn_spell
## >7 means  the character can't learn this spell (unless race changes it)
static func can_learn_spell(_character, _spell) -> int :
	# Check school_levels dictionary first
	if _spell.get("school_levels") :
		if not _spell.school_levels.is_empty():
			# Only care about Priest school
			if _spell.school_levels.has("Priest"):
				var level : int = _spell.school_levels["Priest"]
				if (level>0) and (level <= max_spell_lvl):
					return level
				else:
					return 10  # Can't learn Priest spells above level 7
			return 10  # Can't learn non-Priest spells
	else :
		printerr("Priest?gd can_learn_spell", _spell, " has no school_level")
	return 10  # Can't learn spells without school information

static func _character_creation_gifts(_character) :
	var resources = NodeAccess.__Resources()
	_character.spells = [[],[],[],[],[],[],[]]
	resources.load_item_resources("shared_assets/items/")

	for name in ["Mace","Chain Armor","Helm","Leather Gloves","Leather Boots","Shield"] :
		var item = resources.create_item_instance(name)
		_character.add_inventory_item(item)
	_character.money[0] += 50
	resources.items_book.clear()

static func get_max_perma_summons(_character) ->int :
	return 0

static func get_selection_cost(_character, _ability, _cost) :
	# Only use Priest school cost if available
	if _ability.get("selection_costs") and _ability.selection_costs.has("Priest"):
		return _ability.selection_costs["Priest"]
	return _cost  # Return base cost if no school cost available


#modifies the SP  (or FP RP etc)  cost of a spell or  ability
static func get_ablty_res_cost_mod(_character, _spell, _plvl : int, _cost ) :
	return 0

static func get_parrying_trait_name(_character) -> String :
	return "res://shared_assets/traits/"+'parrying.gd'

static func get_guarding_trait_name(_character) -> String :
	return "res://shared_assets/traits/"+'guarding.gd'

static func get_preparing_trait_name(_character) -> String :
	return "res://shared_assets/traits/"+'preparing.gd'
