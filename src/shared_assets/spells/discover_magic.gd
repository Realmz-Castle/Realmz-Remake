extends Spell

func _init() -> void :
	name = "Discover Magic"
	elements = [GameGlobal.ELEMENTS.MAGICAL]
	tags = ["Magical", "Misc."]
	schools = ["Sorcerer", "Priest", "Enchanter"]
	classic_spell_class = 8
	classic_spell_ids = [1101]
	classic_spell_response_ids = [1101, 2102, 3102]
	classic_spell_save_index = -1
	classic_spell_save_mode = "none"
	targettile = TARGET_TILE.CREATURE
	school_levels = {"Sorcerer": 1, "Priest": 1, "Enchanter": 1}
	selection_costs = {"Sorcerer": 1, "Priest": 1, "Enchanter": 1}
	in_field = true
	in_combat = true
	description = "Discover Magic:  This spell will reveal all items that have magical properties.  It can be cast during combat or while collecting treasure.  It will not give specific information about magical items."
	los = false
	proj_hit = GFX.WHIRL
	sounds = ["spell launch 6.wav", "boing.wav"]


func get_min_duration(_power : int, _caster) -> int :
	return 3

func get_duration_roll(_power : int, _caster) -> int :
	return randi_range(3, 7)

func get_max_duration(_power : int, _caster) -> int :
	return 7

func get_range(_power : int, _caster) -> int :
	return 15

func get_sp_cost(_power : int, _caster) -> int :
	return _power * 1


func special_effect(_castercrea, _spell, _power, _main_targeted_tile, _effected_tiles, _effected_creas, _add_terrain) -> bool :
	var text : String = ""
	for c : Creature in _effected_creas :
		var c_magic_items : Array = []
		for i: ItemInstance in c.inventory_instances():
			var definition := NodeAccess.__Resources().get_item_definition(i)
			if definition != null and definition.magical:
				c_magic_items.append(definition.display_name_for(i))
		if c_magic_items.is_empty() :
			text += c.name + " carries no magic item.\n"
		else :
			text += c.name + " carries magic items :\n"
			for i : int in range(c_magic_items.size()) :
				if i < c_magic_items.size() :
					text += c_magic_items[i] + ", "
				else :
					text += c_magic_items[i] + "\n"
	var textRect = UI.ow_hud.textRect
	if StateMachine.is_combat_state() :
		textRect.show()
		UI.ow_hud.creatureRect.hide()
	textRect.set_text(text, true)
	await textRect.interruption_over
	if StateMachine.is_combat_state() :
		textRect.hide()
		UI.ow_hud.creatureRect.show()
	return true
