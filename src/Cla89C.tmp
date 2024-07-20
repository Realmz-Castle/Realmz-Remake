#extends 'res://Creature/classrace_base.gd' # Weird, right? not used anymore

const classrace_name  : String = "Fighter"
const classrace_types : Array = ["Warrior Classes"]  #og caste_category 1
const classrace_definition : String = "Jack of all trades of everything related to physical combat"

const can_dual_wield : bool = false  #not very well implemented  idk what to do with this...
const used_resource : String = "RP"  #Rage Points, so maybe they will  have some Fighter spell abilities  later

const can_manage_ablt_anywhere = true  #new, can  they reorganize their spell list anytime ?






#Applied once on character creation
const base_stat_bonuses : Dictionary = {
	"MaxMovement" : 2,		#Movement points bonus for this class
	"MaxActions" : 1,			#Actions per round, = 1+bonus_half_attacks_per_round*0.5       
	"Weight_Limit" : 0,		#to be honest, not  implemented....
	"Strength" : 2,
	"Intellect" : -2,
	"Wisdom" : -1,		#same as original  game
	"Dexterity" : 1,
	"Vitality" : 1,
	"curHP" : 8,	#og fighter starts with 1-15, average is 8
	"curSP" : 0,
	"curTP" : 0,
	"curFP" : 0,
	"curRP" : 0,
	"maxHP" : 0,
	"maxSP" : 0,
	"maxTP" : 0,
	"maxFP" : 0,
	"maxRP" : 100,
	"HP_regen_base" : 0.0,	#Regenration is base*mult*level per day.
	"SP_regen_base" : 0.0,	#make them very negative to prevent natural regeneration (can t do damage)
	"HP_regen_mult" : 0.0, # leave at 0, Those should depend mostly on race  unless you're say a Monk
	"SP_regen_mult" : -10.0, 	#or you can set mult to  a negative amount to prevent passive regen, it's neve rgoing to do damage
	"AccuracyMelee" : 0.05,  #og base  melee_hit_chance is 5%
	"AccuracyRanged" :0.05, #og base missile_hit_chance is 5%
	"AccuracyMagic" : 1.0,	#new stat, usually  left at 1.0
	"EvasionMelee" : 0,		# =  innate Armor  rating
	"EvasionRanged" : 0.05,  #5% dodge missile chance at lv1
	"EvasionMagic" : 0,
	"ResistancePhysical" : 0.0,
	"ResistanceFire" : 0.0,
	"ResistanceIce" : 0.0,
	"ResistanceElect" : 0.0,
	"ResistancePoison" : 0.0,	#Flat damage reductions, not really used in the original game except  Ogre/Dragon Skin
	"ResistanceChemical" : 0.0,
	"ResistanceDisease" : 0.0,
	"ResistanceMagic" : 0.0,
	"ResistanceHealing" : 0.0,
	"ResistanceMental" : 0.0,
	"MultiplierPhysical" : 0.0,
	"MultiplierFire" : 0.8,
	"MultiplierIce" : 0.9,
	"MultiplierElect" : 0.9,	#Multipliers  replace DRVs.
	"MultiplierPoison" : 1.0,	#1% DRVs stat -> -2% Multiplier
	"MultiplierChemical" : 0.8,	#or you could increase evasion instead for a more dodgy class, or a combination of both, for same average result
	"MultiplierDisease" : 1.0,	#obviously  still affected by spell script if you  d prefer it to have a chance to miss
	"MultiplierMagic" : 0.9,
	"MultiplierHealing" : 1.0,	#Healing shuuld always be 1 unless you are making an undead (-1) or robot(0)
	"MultiplierMental" : 0.9,	#Charm now counts as Mental
	"Melee_Crit_Rate" : 0.05,	#Class should start with 5% bonus chance of major wound
	"Melee_Crit_Mult" : 2.0,	#this class doesnt have Sneak Attacks so critical hits do 2x damage only
	"Ranged_Crit_Rate" : 0.0,
	"Ranged_Crit_Mult" : 1.5,	#this class's Ranged critical hits will be weaker (depends on spell script though)
	# Resistances is damage  taken substracted, Multipliers is damage taken multiplied.
	# Damage taken = (base_damage - damage_resistance)*damage_multiplier
	"Detect_Secret" : 1.0,
	"Acrobatics" : 6.0,
	"Detect_Trap" : 1.0,
	"Disable_Trap" : 0.0,	#these are the same values as the original realmz class
	"Force_Lock" : 12.0,
	"Pick_Lock" : 0.0,
	"Turn_Undead" : 0.0
} 


#How those values increase !
const levelup_bonuses : Dictionary = {
	"MaxMovement" : 0,		#Movement points, usually dont increase w level
	"MaxActions" : 0,			#Actions per round, they don't increase regularly
	"Weight_Limit" : 0,	#still to be implemented but shouldnt increase anyway
	"Strength" : 0,
	"Intellect" : 0,		#those should be left at 0 unless you re making a very unique class
	"Wisdom" : 0,
	"Dexterity" : 0,
	"Vitality" : 0,
	"curHP" : 5,
	"curSP" : 0,
	"maxHP" : 5,
	"maxSP" : 0,
	"HP_regen_base" : 0.0,
	"SP_regen_base" : 0.0,
	"HP_regen_mult" : 0.0, 
	"SP_regen_mult" : 0.0, 
	"AccuracyMelee" : 0.05,#melee_hit_chance +5% per level
	"AccuracyRanged" :0.04, #missile_hit_chance +4% per level
	"AccuracyMagic" : 0,
	"EvasionMelee" : 0,
	"EvasionRanged" : 0.2, #dodge_missile_chance +2% per level
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
	# Resistances is damage  taken substracted, Multipliers is damage taken multiplied.
	# Damage taken = (base_damage - damage_resistance)*damage_multiplier
	"MultiplierMental" : 0.0,
	"Melee_Crit_Rate" : 0.0,
	"Melee_Crit_Mult" : 0.0,
	"Ranged_Crit_Rate" : 0.0,
	"Ranged_Crit_Mult" : 0.0,
	"Detect_Secret" : 0.0,
	"Acrobatics" : 0.0,
	"Detect_Trap" : 0.0,
	"Disable_Trap" : 0.0,
	"Force_Lock" : 0.0,
	"Pick_Lock" : 0.0,
	"Turn_Undead" : 0.0
} 



static func _mod_equippable(_character) :
	#check PlayerCharacter.gd for list of all standard equipment types
	#Fighters can wear  anything except "Scroll Case"
	# 0 = wont prevent from wearing but  wont help if  race gives a penalty
	# if  rce+class mods>0, can wear item type
	var mod_equippable_types : Dictionary = {
		"Mace" : 2,
		"Club" : 2,
		"Hammer" : 1,
		"Warhammer/Maul" : 1, # Two handed big blunt weapons
		"Dagger" : 3, # Better thana  knife ?
		"Shortsword" : 2, # Good for rogues and archers
		"Arming Sword" : 1, # Long 1 handed sword
		"Longsword" : 1,  # 2 handed or bastard swords
		"Short Axe" : 2,
		"Staff" : 1,
		"Pole Axe" : 1,
		"Spear" : 2,
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
		"Throwing Aid" : 0,
		"Misc. Melee Weapon" : 1,
		"Misc Ranged Weapon" : 1,
		"Belt" : 1,
		"Necklace" : 0,
		"Ring" : 0,
		"Hat" : 0,  #cloth headwear
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
		"Cloak/Cape" : 0,
		"Robe" : 0,	#
		"Gambeson" : 1, #can be worn with plate armor ?
		"Leather Armor" : 1,
		"Chainmail Armor" : 1,
		"Splint Armor" : 1,
		"Plate Armor" : 1,
		"Soft Boots" : 1,
		"Hard Boots" : 1,
		"Scroll Case" : -999 #no way a Fighter can equip this
	}

	for t in _character.equippable_types :
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
	if [5,10,15,20,25,30,35,40].has(_new_level) :
		_character.base_stats["MaxActions"] += 0.5

#if  class OR race  scripts allow  (>0),  character ca, learn
static func can_learn_spell(_character, _spell) -> int :
	return 0

static func _character_creation_gifts(_character) :
	#will have to be rewritten wehn items are implemented
	var resources = NodeAccess.__Resources()
	resources.load_item_resources("shared_assets/items/")
	var dagger = resources.items_book["Dagger"]
	_character.inventory.append(dagger.duplicate(true))
	var oxshield =  resources.items_book["Shield of the Blue Oxen"]
	_character.inventory.append(oxshield.duplicate(true))
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
