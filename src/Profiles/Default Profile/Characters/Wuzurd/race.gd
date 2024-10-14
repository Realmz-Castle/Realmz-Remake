#extends 'res://Creature/classrace_base.gd' # Weird, right?

const classrace_name  : String = "Human"
const classrace_types : Array = ["Human Races"]
const classrace_definition : String = "Like you."

const can_dual_wield : bool = true

#Applied once on character creation
const base_stat_bonuses : Dictionary = {
	"MaxMovement" : 10,		#Movement points
	"MaxActions" : 2,			#Actions per round
	"MaxSpellsPerRound" : 0,
	"Weight_Limit" : 0,
	"Strength" : 10,
	"Intellect" : 10,
	"Wisdom" : 10,
	"Dexterity" : 10,
	"Vitality" : 10,
	"curHP" : 5,
	"curSP" : 0,
	"curFP" : 0,
	"curRP" : 0,
	"maxHP" : 5,
	"maxSP" : 0,
	"maxFP" : 0,
	"maxRP" : 0,
	"HP_regen_base" : 1.0,
	"SP_regen_base" : 1.0,
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
	"MultiplierPhysical" : 1.0,
	"MultiplierFire" : 1.0,
	"MultiplierIce" : 1.0,
	"MultiplierElect" : 1.0,
	"MultiplierPoison" : 1.0,
	"MultiplierChemical" : 1.0,
	"MultiplierDisease" : 1.0,
	"MultiplierMagic" : 1.0,
	"MultiplierHealing" : -1.0,
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
	"curHP" : 5,
	"curSP" : 0,
	"maxHP" : 5,
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
	"Detect_Secret" : 0.0,
	"Acrobatics" : 0.0,
	"Detect_Trap" : 0.0,
	"Disable_Trap" : 0.0,
	"Force_Lock" : 0.0,
	"Pick_Lock" : 0.0,
	"Turn_Undead" : 0.0
} 



static func _mod_equippable(_character) :
	pass


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
			if s.begins_with("Multiplier") :
				if character.base_stats[s]<0 and base_stat_bonuses[s]<0 :
					character.base_stats[s] = - abs(base_stat_bonuses[s] * character.base_stats[s])
				else :
					character.base_stats[s] *= base_stat_bonuses[s]
			else :
				character.base_stats[s] += base_stat_bonuses[s]
			
				



static func _level_up(character, _new_level : int) :
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


static func _character_creation_gifts(_character) :
	return

static func get_selection_cost(_character, _ability, _cost) :
	return _cost

## returns  the  Spell Level at which a spell is learned. <=7 : can learn.
## the normal value is returned  by the Class  script, not this one.
## Should return 0 (no modification) unless  this race  really should/shouldnt
## learn  this spell at a different level/never.
static func can_learn_spell(_character, _spell) -> int :
	return 0

#static func get_abilities_pc_can_learn(_character) ->Array :
#	return []

static func get_ablty_res_cost_mod(_character, _spell, _plvl : int, _cost ) :
	return 0
