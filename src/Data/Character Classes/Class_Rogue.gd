#extends 'res://Creature/classrace_base.gd' # Weird, right?

const classrace_name  : String = "Rogue"
const classrace_types : Array = ["Thief Classes"]
const classrace_definition : String = "Living piece of shit"

const can_dual_wield : bool = true
const used_resource : String = "FP"

const can_manage_ablt_anywhere = true


const parry_trait_name : String = 'parrying.gd'
const guard_trait_name : String = 'guarding.gd'
const prepare_trait_name : String = 'preparing.gd'

#Applied once on character creation
const base_stat_bonuses : Dictionary = {
	"MaxMovement" : 2,		#Movement points
	"MaxActions" : 1,			#Actions per round
	"MaxSpellsPerRound" : 0,
	"Weight_Limit" : 0,
	"Strength" : 1,
	"Intellect" : -1,
	"Wisdom" : -1,
	"Dexterity" : 2,
	"Vitality" : 3,
	"curHP" : 0,
	"curSP" : 0,
	"curTP" : 0,
	"curFP" : 100,
	"curRP" : 0,
	"maxHP" : 0,
	"maxSP" : 0,
	"maxTP" : 0,
	"maxFP" : 100,
	"maxRP" : 0,
	"HP_regen_base" : 1.0,
	"SP_regen_base" : 1.0,
	"HP_regen_mult" : 0.0, #added to the character's multiplier
	"SP_regen_mult" : 0.0, #added to the character's multiplier
	"AccuracyMelee" : 6,
	"AccuracyRanged" :6,
	"AccuracyMagic" : 1.0,
	"EvasionMelee" : 0,
	"EvasionRanged" : 0,
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
	"Melee_Crit_Rate" : 0.75,
	"Melee_Crit_Mult" : 3.0,
	"Ranged_Crit_Rate" : 0.75,
	"Ranged_Crit_Mult" : 3.0,
	"Detect_Secret" : 0.0,
	"Acrobatics" : 5.0,
	"Detect_Trap" : 5.0,
	"Disable_Trap" : 5.0,
	"Force_Lock" : 3.0,
	"Pick_Lock" : 8.0,
	"Turn_Undead" : 0.0
} 


const levelup_bonuses : Dictionary = {
	"MaxMovement" : 0,		#Movement points
	"MaxActions" : 0,			#Actions per round
	"MaxSpellsPerRound" : 0,
	"Weight_Limit" : 0,
	"Strength" : 0,
	"Intellect" : 0,
	"Wisdom" : 0,
	"Dexterity" : 0,
	"Vitality" : 0,
	"curHP" : 4,
	"curSP" : 0,
	"maxHP" : 4,
	"maxSP" : 0,
	"HP_regen_base" : 0.0,
	"SP_regen_base" : 0.0,
	"HP_regen_mult" : 0.0, #added to the character's multiplier
	"SP_regen_mult" : 0.0, #added to the character's multiplier
	"AccuracyMelee" : 0,
	"AccuracyRanged" :0,
	"AccuracyMagic" : 0,
	"EvasionMelee" : 0,
	"EvasionRanged" : 0,
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
	"Melee_Crit_Rate" : 0.1,
	"Melee_Crit_Mult" : 0.0,
	"Ranged_Crit_Rate" : 0.05,
	"Ranged_Crit_Mult" : 0.0,
	"Detect_Secret" : 0.0,
	"Acrobatics" : 0.1,
	"Detect_Trap" : 0.2,
	"Disable_Trap" : 0.2,
	"Force_Lock" : 0.1,
	"Pick_Lock" : 0.2,
	"Turn_Undead" : 0.0
} 



static func _mod_equippable(character) :
	character.equippable_types["Dagger"] +=1
	character.equippable_types["Throwing Dagger"] +=1
	character.equippable_types["Dart"] +=1
	character.equippable_types["Plate Armor"] -=10
	character.equippable_types["Splint Armor"] -=8
	character.equippable_types["Chainmail Armor"] -=5
	character.equippable_types["Large Shield"] -=5
	character.equippable_types["Medium Shield"] -=2
	character.equippable_types["Great Helm"] -=4
	character.equippable_types["Light Helmet"] -=2
	character.equippable_types["Arming Sword"] -=8
	character.equippable_types["Warhammer/Maul"] -=10

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


#if  class OR race  scripts allow  (>0),  character ca, learn
## returns  the  Spell Level at which a spell is learned.
## <=0 should be changed to 1 in PlayerCHaracter 's can_learn_spell
## >7 means  the character can't learn this spell (unless race changes it)
static func can_learn_spell(_character, _spell) -> int :
	return _spell.level if _spell.level <= 3 else 10  #Rogues can learn all spells of level <=3

static func _character_creation_gifts(_character) :
	var resources = NodeAccess.__Resources()
	resources.load_item_resources("shared_assets/items/")
	var dagger = resources.items_book["Dagger"]
	_character.inventory.append(dagger.duplicate(true))
	var bow = resources.items_book["Bow"]
	_character.inventory.append(bow.duplicate(true))
	var quiver = resources.items_book["Quiver"]
	_character.inventory.append(quiver.duplicate(true))
	resources.items_book.clear()

static func get_max_perma_summons(_character) ->int :
	return 0

static func get_selection_cost(_character, _ability, _cost) :
	return _cost

#static func get_abilities_pc_can_learn(_character) ->Array :
#	return []

static func get_ablty_res_cost_mod(_character, _spell, _plvl : int, _cost ) :
	return 0
	
static func get_parrying_trait_name(_character) -> String :
	return "res://shared_assets/traits/"+'parrying.gd'

static func get_guarding_trait_name(_character) -> String :
	return "res://shared_assets/traits/"+'guarding.gd'

static func get_preparing_trait_name(_character) -> String :
	return "res://shared_assets/traits/"+'preparing.gd'
