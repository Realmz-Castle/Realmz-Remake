const classrace_name : String = "Berzerker"
const classrace_types : Array = ["Warrior Classes"]  # reflects the warrior nature of this class
const classrace_definition : String = "Description will come soon" # leave it as is
const can_dual_wield : bool = false  #leave it as is
const used_resource : String = "RP"  #changed to RP for rage points
const can_manage_ablt_anywhere = false  #leave it as is
const max_spell_lvl = 0

#Applied once on character creation
const base_stat_bonuses : Dictionary = {
	"MaxMovement" : 4,
	"MaxActions" : 1,
	"MaxSpellsPerRound" : 0,
	"Weight_Limit" : 0,
	"Strength" : 3,
	"Intellect" : -2,
	"Wisdom" : -3,
	"Dexterity" : -1,
	"Vitality" : 1,
	"curHP" : 20,
	"curSP" : 0,
	"curTP" : 0,
	"curFP" : 0,
	"curRP" : 0,
	"maxHP" : 20,
	"maxSP" : 0,
	"maxTP" : 0,
	"maxFP" : 0,
	"maxRP" : 100,
	"HP_regen_base" : 0.0,
	"SP_regen_base" : 0.0,
	"HP_regen_mult" : 0.0,
	"SP_regen_mult" : -10.0,
	"AccuracyMelee" : 0.10,
	"AccuracyRanged" : 0.0,
	"AccuracyMagic" : 1.0,
	"EvasionMelee" : 0,
	"EvasionRanged" : 0.0,
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
	"MultiplierFire" : 0.95,
	"MultiplierIce" : 0.95,
	"MultiplierElect" : 0.95,
	"MultiplierPoison" : 1.0,
	"MultiplierChemical" : 0.95,
	"MultiplierDisease" : 1.0,
	"MultiplierMagic" : 1.075,
	"MultiplierHealing" : 1.0,
	"MultiplierMental" : 1.125,
	"Melee_Crit_Rate" : 0.08,
	"Melee_Crit_Mult" : 2.0,
	"Ranged_Crit_Rate" : 0.0,
	"Ranged_Crit_Mult" : 1.5,
	"Detect_Secret" : 1,
	"Acrobatics" : 6.0,
	"Detect_Trap" : 1.0,
	"Disable_Trap" : 0.0,
	"Force_Lock" : 15.0,
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
	"maxHP" : 4,
	"maxSP" : 0,
	"HP_regen_base" : 0.0,
	"SP_regen_base" : 0.0,
	"HP_regen_mult" : 0.0,
	"SP_regen_mult" : 0.0,
	"AccuracyMelee" : 0.04,
	"AccuracyRanged" : 0.0,
	"AccuracyMagic" : 0,
	"EvasionMelee" : 0,
	"EvasionRanged" : 0.0,
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
	"Melee_Crit_Rate" : 0.01,
	"Melee_Crit_Mult" : 0.0,
	"Ranged_Crit_Rate" : 0.0,
	"Ranged_Crit_Mult" : 0.0,
	"Detect_Secret" : 0.0,
	"Acrobatics" : 2.0,
	"Detect_Trap" : 0.0,
	"Disable_Trap" : 0.0,
	"Force_Lock" : 2.0,
	"Pick_Lock" : 0.0,
	"Turn_Undead" : 0.0
}

static func _mod_equippable(_character) :
	var mod_equippable_types : Dictionary = {
"Ion Stone" : 1,
		"Mace" : 1,
		"Club" : 1,
		"Hammer" : 1,
		"Warhammer/Maul" : 1,
		"Dagger" : 1,
		"Shortsword" : 1,
		"Arming Sword" : 1,
		"Longsword" : 1,
		"Short Axe" : 1,
		"Staff" : 1,
		"Pole Axe" : 1,
		"Spear" : 1,
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
		"Misc. Melee Weapon" : 1,
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
		"Large Shield" : 0,
		"Bracers" : 1,
		"Cloth Gloves" : 1,
		"Leather Gloves" : 1,
		"Metal Gloves" : 1,
		"Cloak/Cape" : 1,
		"Robe" : 1,
		"Gambeson" : 1,
		"Leather Armor" : 0,
		"Chainmail Armor" : 0,
		"Splint Armor" : 0,
		"Plate Armor" : 0,
		"Soft Boots" : 1,
		"Hard Boots" : 1,
		"Scroll Case" : 0
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
	if [4,8,12,16,20,24].has(_new_level) :
		_character.base_stats["MaxActions"] += 0.5

## returns  the  Spell Level at which a spell is learned.
## <=0 should be changed to 1 in PlayerCHaracter 's can_learn_spell
## >7 means  the character can't learn this spell (unless race changes it)
static func can_learn_spell(_character, _spell) -> int :
	return 10  #Fighter can't learn any spell

static func _character_creation_gifts(_character) :
	var resources = NodeAccess.__Resources()
	resources.load_item_resources("shared_assets/items/")
	
	for name in ["Battleaxe","Dagger","Leather Armor","Leather Gloves","Leather Boots"] :
		var item = resources.create_item_instance(name)
		_character.add_inventory_item(item)
	_character.money[0] += 10
	resources.items_book.clear()

static func get_max_perma_summons(_character) ->int :
	return 0

static func get_selection_cost(_character, _ability, _cost) :
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
