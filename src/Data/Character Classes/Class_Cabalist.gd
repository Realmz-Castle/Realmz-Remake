const classrace_name : String = "Cabalist"
const classrace_types : Array = ["Magic Classes"]  # reflects the arcane magic nature of this class
const classrace_definition : String = "Description will come soon" # leave it as is
const can_dual_wield : bool = false  #leave it as is
const used_resource : String = "MP"  #changed to MP for magic class
const can_manage_ablt_anywhere = false  #leave it as is
const max_spell_lvl = 7

#Applied once on character creation
const base_stat_bonuses : Dictionary = {
	"MaxMovement" : -3,
	"MaxActions" : 1,
	"MaxSpellsPerRound" : 3,
	"Weight_Limit" : 0,
	"Strength" : -2,
	"Intellect" : 3,
	"Wisdom" : 0,
	"Dexterity" : -2,
	"Vitality" : -1,
	"curHP" : 8,
	"curSP" : 0,
	"curTP" : 0,
	"curFP" : 0,
	"curMP" : 0,
	"maxHP" : 8,
	"maxSP" : 0,
	"maxTP" : 0,
	"maxFP" : 0,
	"maxMP" : 100,
	"HP_regen_base" : 0.0,
	"SP_regen_base" : 0.0,
	"HP_regen_mult" : 0.0,
	"SP_regen_mult" : -10.0,
	"AccuracyMelee" : 0.02,
	"AccuracyRanged" : 0.0,
	"AccuracyMagic" : 1.0,
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
	"MultiplierPhysical" : 1.0,
	"MultiplierFire" : 1.025,
	"MultiplierIce" : 1.025,
	"MultiplierElect" : 1.025,
	"MultiplierPoison" : 1.0,
	"MultiplierChemical" : 1.025,
	"MultiplierDisease" : 1.0,
	"MultiplierMagic" : 0.90,
	"MultiplierHealing" : 1.0,
	"MultiplierMental" : 0.95,
	"Melee_Crit_Rate" : 0.0,
	"Melee_Crit_Mult" : 2.0,
	"Ranged_Crit_Rate" : 0.0,
	"Ranged_Crit_Mult" : 1.5,
	"Detect_Secret" : 10,
	"Acrobatics" : 2.0,
	"Detect_Trap" : 5.0,
	"Disable_Trap" : 5.0,
	"Force_Lock" : 0.0,
	"Pick_Lock" : 0.0,
	"Turn_Undead" : 0.0
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
	"maxHP" : 2,
	"maxSP" : 0,
	"HP_regen_base" : 0.0,
	"SP_regen_base" : 0.0,
	"HP_regen_mult" : 0.0,
	"SP_regen_mult" : 0.0,
	"AccuracyMelee" : 0.02,
	"AccuracyRanged" : 0.0,
	"AccuracyMagic" : 0,
	"EvasionMelee" : 0,
	"EvasionRanged" : 0.01,
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
	"Detect_Secret" : 1.0,
	"Acrobatics" : 0.0,
	"Detect_Trap" : 0.0,
	"Disable_Trap" : 0.0,
	"Force_Lock" : 0.0,
	"Pick_Lock" : 0.0,
	"Turn_Undead" : 0.0
}

static func _mod_equippable(_character) :
	var mod_equippable_types : Dictionary = {
"Ion Stone" : 1,
		"Mace" : 0,
		"Club" : 0,
		"Hammer" : 0,
		"Warhammer/Maul" : 0,
		"Dagger" : 1,
		"Shortsword" : 0,
		"Arming Sword" : 0,
		"Longsword" : 0,
		"Short Axe" : 0,
		"Staff" : 0,
		"Pole Axe" : 0,
		"Spear" : 0,
		"Eastern Weapon" : 0,
		"Dart" : 0,
		"Throwing Bottle" : 0,
		"Throwing Dagger" : 0,
		"Throwing Rock" : 0,
		"Throwing Axe" : 0,
		"Throwing Hammer" : 0,
		"Throwing Spear" : 0,
		"Whip" : 0,
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
		"Soft Helmet" : 0,
		"Light Helmet" : 0,
		"Great Helm" : 0,
		"Small Shield" : 0,
		"Medium Shield" : 0,
		"Large Shield" : 0,
		"Bracers" : 1,
		"Cloth Gloves" : 1,
		"Leather Gloves" : 0,
		"Metal Gloves" : 0,
		"Cloak/Cape" : 1,
		"Robe" : 1,
		"Gambeson" : 0,
		"Leather Armor" : 0,
		"Chainmail Armor" : 0,
		"Splint Armor" : 0,
		"Plate Armor" : 0,
		"Soft Boots" : 1,
		"Hard Boots" : 0,
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
	if [25,35].has(_new_level) :
		_character.base_stats["MaxActions"] += 0.5

## returns  the  Spell Level at which a spell is learned.
## <=0 should be changed to 1 in PlayerCHaracter 's can_learn_spell
## >7 means  the character can't learn this spell (unless race changes it)
static func can_learn_spell(_character, _spell) -> int :
	# Check school_levels dictionary first
	if _spell.get("school_levels") :
		if not _spell.school_levels.is_empty():
			# Only care about Sorcerer school
			if _spell.school_levels.has("Sorcerer"):
				var level : int = _spell.school_levels["Sorcerer"]
				if (level>0) and (level <= max_spell_lvl):
					return level
				else:
					return 10  # Can't learn Sorcerer spells above level 2
		return 10  # Can't learn non-Sorcerer spells
	return 10  # Can't learn spells without school information


static func _character_creation_gifts(_character) :
	var resources = NodeAccess.__Resources()
	resources.load_item_resources("shared_assets/items/")
	_character.spells = [[],[],[],[],[],[],[]]
	for name in ["Dagger","Robe","Silk Gloves","Leather Boots"] :
		var item = resources.create_item_instance(name)
		_character.add_inventory_item(item)
	_character.money[0] += 300
	resources.items_book.clear()

static func get_max_perma_summons(_character) ->int :
	return 0

static func get_selection_cost(_character, _ability, _cost) :
	# Only use Sorcerer school cost if available
	if "selection_costs" in _ability and _ability.selection_costs.has("Sorcerer"):
		return _ability.selection_costs["Sorcerer"]
	return _cost


#modifies the SP  (or FP RP etc)  cost of a spell or  ability
static func get_ablty_res_cost_mod(_character, _spell, _plvl : int, _cost ) :
	return 0

static func get_parrying_trait_name(_character) -> String :
	return "res://shared_assets/traits/"+'parrying.gd'

static func get_guarding_trait_name(_character) -> String :
	return "res://shared_assets/traits/"+'guarding.gd'

static func get_preparing_trait_name(_character) -> String :
	return "res://shared_assets/traits/"+'preparing.gd'
