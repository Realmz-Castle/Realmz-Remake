const name : String = 'castondeath.gd'
const menuname : String = 'Special Ability on Death (P)'
const stacks = false

const trait_types : Array = []
var spell_name : String = ''
var spell_power : int = 1
var chara
const permanent = 1
var trait_source : String = ''

func _init(args : Array):
	chara = args[0]
	spell_name = args[1]
	spell_power = args[2]

	
func get_saved_variables() :
	return [spell_name, spell_power]

func _on_crea_death(creature) :
	#{'type' : 'Spell', 'caster' : Crea, 'Effected Tiles' : [], 'effected creas' : [], 'targeted_tiles' : [], 'spell':GDScript, 's_plvl' : 1, 'used_item' : null , 'add_terrain' : true}
	var spelldict = GameGlobal.cmp_resources.spells_book[spell_name]
	var spell = spelldict['script']
	var targeter : TargetingLayer = GameGlobal.map.targetingLayer
	var picked_tiles : Array = targeter.get_affected_tiles(spell, spell_power, creature.combat_button, creature.position, []) 
	var picked_targets : Array = targeter.get_cbs_touching_tiles(picked_tiles)
	var act_msg : Dictionary = {'type' : 'Spell', 'caster' : creature.combat_button, 'Effected Tiles' : picked_tiles, 'Effected Creas' : picked_targets, 'Targeted Tiles' : [creature.position], 'spell':spell, 's_plvl' : spell_power, 'used_item' : {} , 'add_terrain' : true,  'override_aoe' : [], 'from_terrain' : false, 'Main Targeted Tile' : creature.position}
	return [act_msg]


func get_info_as_text() -> String :
	return 'casts '+spell_name+ 'lv'+str(spell_power)+' upon dying'+' (source : '+trait_source+')'

func equals_args(traits_array : Array) :
	return traits_array[0]==spell_name and traits_array[1]==spell_power
