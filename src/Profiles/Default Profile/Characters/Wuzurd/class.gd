#extends 'res://Creature/classrace_base.gd' # Weird, right?

const classrace_name  : String = "Sorcerer"
const classrace_types : Array = ["Mage Classes"]
const classrace_definition : String = "Can use MAGIC !"

const can_dual_wield : bool = false
const used_resource : String = "SP"

const can_manage_ablt_anywhere = true


const parry_trait_name : String = 'parrying.gd'
const guard_trait_name : String = 'guarding.gd'
const prepare_trait_name : String = 'preparing.gd'

#Applied once on character creation
const base_stat_bonuses : Dictionary = {
	"MaxMovement" : -1,		#Movement points
	"MaxActions" : 0,			#Actions per round
	"MaxSpellsPerRound" : 2,
	"Weight_Limit" : 0,
	"Strength" : -2,
	"Intellect" : +2,
	"Wisdom" : +1,
	"Dexterity" : 0,
	"Vitality" : -1,
	"curHP" : 0,
	"curSP" : 0,
	"curTP" : 0,
	"curFP" : 0,
	"curRP" : 0,
	"maxHP" : 0,
	"maxSP" : 20,
	"maxTP" : 0,
	"maxFP" : 0,
	"maxRP" : 0,
	"HP_regen_base" : 1.0,
	"SP_regen_base" : 1.0,
	"HP_regen_mult" : 0.0, #added to the character's multiplier
	"SP_regen_mult" : 0.0, #added to the character's multiplier
	"AccuracyMelee" : 4,
	"AccuracyRanged" :2,
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
	"Melee_Crit_Rate" : 0.25,
	"Melee_Crit_Mult" : 1.5,
	"Ranged_Crit_Rate" : 0.25,
	"Ranged_Crit_Mult" : 1.5,
	"Detect_Secret" : 3.0,
	"Acrobatics" : 0.0,
	"Detect_Trap" : 2.0,
	"Disable_Trap" : 1.0,
	"Force_Lock" : 0.0,
	"Pick_Lock" : 0.0,
	"Turn_Undead" : 10.0
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
	"curHP" : 3,
	"curSP" : 0,
	"maxHP" : 3,
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
	"Melee_Crit_Rate" : 0.0,
	"Melee_Crit_Mult" : 0.0,
	"Ranged_Crit_Rate" : 0.0,
	"Ranged_Crit_Mult" : 0.0,
	"Detect_Secret" : 2.0,
	"Acrobatics" : 0.0,
	"Detect_Trap" : 0.0,
	"Disable_Trap" : 0.0,
	"Force_Lock" : 0.0,
	"Pick_Lock" : 0.0,
	"Turn_Undead" : 1.0
} 



static func _mod_equippable(character) :
	character.equippable_types["Dagger"] +=1
	character.equippable_types["Throwing Dagger"] -=1
	character.equippable_types["Dart"] +=1
	character.equippable_types["Plate Armor"] -=10
	character.equippable_types["Splint Armor"] -=10
	character.equippable_types["Chainmail Armor"] -=10
	character.equippable_types["Large Shield"] -=10
	character.equippable_types["Medium Shield"] -=10
	character.equippable_types["Great Helm"] -=10
	character.equippable_types["Light Helmet"] -=10
	character.equippable_types["Arming Sword"] -=10
	character.equippable_types["Warhammer/Maul"] -=10

static func _add_base_stats(character) :
	for s in base_stat_bonuses :
		if typeof (base_stat_bonuses[s] ) == TYPE_DICTIONARY  :
			if not character.base_stats.has(s) :
				character.base_stats[s] = {}
				for t in base_stat_bonuses[s] :
					character.base_stats[s][t] = 0
			for t in base_stat_bonuses[s] :
				character.base_stats[s][t] += base_stat_bonuses[s][t]
		else :
			if not character.base_stats.has(s) :
				character.base_stats[s] = 0
			character.base_stats[s] += base_stat_bonuses[s]



static func _level_up(character, _new_level : int) :
	character.selection_pts +=2
	for s in levelup_bonuses :
		if typeof (levelup_bonuses[s] ) == TYPE_DICTIONARY  :
			if not character.base_stats.has(s) :
				character.base_stats[s] = {}
			for t in levelup_bonuses[s] :
				character.base_stats[s][t] += levelup_bonuses[s][t]
		else :
			if not character.base_stats.has(s) :
				character.base_stats[s] = 0
			character.base_stats[s] += levelup_bonuses[s]

## returns  the  Spell Level at which a spell is learned.
## <=0 should be changed to 1 in PlayerCHaracter 's can_learn_spell
## >7 means  the character can't learn this spell (unless race changes it)
static func can_learn_spell(_character, _spell) -> int :
	return min(_spell.level, 7)  # Sorcerer can learn any spell !

static func _character_creation_gifts(_character) :
	_character.selection_pts +=3
	var resources = NodeAccess.__Resources()
	resources.load_item_resources("shared_assets/items/")
	var dagger = resources.items_book["Dagger"]
	_character.inventory.append(dagger.duplicate(true))
	resources.items_book.clear()
	
	_character.spells =  [ [],[],[],[],[],[],[] ]
	
	print("class.gd adding spell to newly created  sorcerer "+_character.name)
	resources.load_spell_resources( "res://shared_assets/spells/" )
	print("class.gd load_spell_resources  finished")
	_character.add_spell_from_spells_book("Heal Minor Wounds",1) #fuction in creature.gd
	_character.add_spell_from_spells_book("Plane of Frost",1)
	_character.add_spell_from_spells_book("Phase",1)
	_character.add_spell_from_spells_book("Summon Alien Beetle",1)
	_character.add_spell_from_spells_book("Bear Form",1)
	_character.add_spell_from_spells_book("Cosmic Blast",1)
	_character.add_spell_from_spells_book("Heat Ray",1)
	_character.add_spell_from_spells_book("Discover Magic",1)
	_character.add_spell_from_spells_book("Death",7)
	print("class.gd DONE adding spell to newly created  sorcerer "+_character.name)

static func get_max_perma_summons(_character) ->int :
	return 1

static func get_selection_cost(_character, _ability, _cost) :
	return _cost

#static func get_abilities_pc_can_learn(_character) ->Array :
#	return NodeAccess.__Resources().spells_book.keys()

static func get_ablty_res_cost_mod(_character, _spell, _plvl : int, _cost ) :
	return -floor(_cost/2) if _spell.attributes.has("Magical") else 0

static func get_parrying_trait_name(_character) -> String :
	return "res://shared_assets/traits/"+'parrying.gd'

static func get_guarding_trait_name(_character) -> String :
	return "res://shared_assets/traits/"+'guarding.gd'

static func get_preparing_trait_name(_character) -> String :
	return "res://shared_assets/traits/"+'preparing.gd'
