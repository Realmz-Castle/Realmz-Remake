extends NinePatchRect
class_name AbilitiesManagementRect

@export var abBtnTSCN : PackedScene

@export var nameLabel : Label
@export var pointsLabel : Label
@export var portraitRect : TextureRect
@export var knownCntnr : VBoxContainer
@export var availCntnr : VBoxContainer

var ablboxes : Array = [knownCntnr , availCntnr]

@export var lvbuttonCntnr : VBoxContainer

var character : PlayerCharacter
var charspells : Array

var spells_book : Dictionary

var known : Dictionary = {1:[], 2:[], 3:[], 4:[], 5:[], 6:[], 7:[]}
var avail : Dictionary = {1:[], 2:[], 3:[], 4:[], 5:[], 6:[], 7:[]}

signal on_closed

var show_class_abs : bool = false
var extra_abs : Array = []

var char_sp : int = 0

var level : int = 1  #1 to 7

# Called when the node enters the scene tree for the first time.
func _ready():
	knownCntnr.my_menu = self
	availCntnr.my_menu = self
	ablboxes = [knownCntnr , availCntnr]

#func Creature.add_spell_from_spells_book(spellname : String) :
#	var resources = NodeAccess.__Resources()
#	var spelldict = resources.spells_book[spellname]
#	var level = spelldict["script"].level
#	while spells.size() < level :
#		spells.append([])
#	spells[level-1].append(spelldict)

## extra_avail  should be an array of  arrays of teh form [spellname : String, spell_level : int]
func set_displayed_character(pc : PlayerCharacter, show_class_abilities : bool, extra_avail : Array = []) :
#	print("set_displayed_character")
	extra_abs = extra_avail
	show_class_abs = show_class_abilities
	extra_abs = extra_avail 
	spells_book = NodeAccess.__Resources().spells_book
	character = pc
	show_class_abilities = show_class_abilities or  character.can_manage_ablt_anywhere()
	charspells = character.spells
	nameLabel.text = pc.name
	char_sp = pc.selection_pts
	pointsLabel.text = str(char_sp)+" Selection Points"
	portraitRect.texture = pc.portrait

	build_known_dict()
	build_avail_dict()

	_on_s_level_button_pressed(1)
	

func build_known_dict() :
	known.clear()
	known = {1:[], 2:[], 3:[], 4:[], 5:[], 6:[], 7:[]}
	var maxlevel : int = charspells.size()
	for lvl in range(1,maxlevel+1) :
		known[lvl] = charspells[lvl-1].duplicate(true)

func build_avail_dict() :
	var maxlevel : int = charspells.size()
	avail.clear()
	avail = {1:[], 2:[], 3:[], 4:[], 5:[], 6:[], 7:[]}
	var _canlearnfromextras : Array = []
	#returns an array of  arrays  [spellname:String, level:int]
	for sa : Array in character.get_abilities_pc_can_learn()+ extra_abs :
		var slvl : int = sa[1]
		var sn : String = sa[0]
		if slvl <= maxlevel :
			var  is_known : bool = false
			for s_dict : Dictionary in known[slvl] :
				if s_dict['name'] == sn :
					is_known = true
					print("ABLITYMANAGEMEBT WOOOO "+sn)
					break
			if not is_known : avail[slvl].append(spells_book[sn])
			#if  character.can_learn_spell_at_level(spells_book[sn]["script"])>0 and (not is_known) :
				


func _on_ok_button_pressed():
	emit_signal("on_closed")
	hide()

func clear_vbox_list(vbox : VBoxContainer) :
	for entry in vbox.get_children() :
		entry.queue_free()

func _on_s_level_button_pressed(index : int):
	level = index
	for i in range(1,8) :
		lvbuttonCntnr.get_child(i).set_pressed_no_signal(false)
	var button = lvbuttonCntnr.get_child(index)
	print("_on_s_level_button_pressed : ", button.name)
	button.set_pressed_no_signal(true)
	clear_vbox_list(knownCntnr)
	clear_vbox_list(availCntnr)
	if charspells.size() < index :
		GameGlobal.play_sfx("target error.wav")
		return
#	print(" known l92 : ", known)
	for spell_dict in known[index] :
		var new_spellentrybutton: AbilityButton = abBtnTSCN.instantiate()
		knownCntnr.add_child(new_spellentrybutton)
		new_spellentrybutton.initialize(spell_dict, character, 0, self)
	for spell_dict in avail[index] :
		var new_spellentrybutton: AbilityButton = abBtnTSCN.instantiate()
		availCntnr.add_child(new_spellentrybutton)
		new_spellentrybutton.initialize(spell_dict, character, 1, self)



func move_abilbutton_from_to(btn : AbilityButton, frombox : AbilistContainer, tobox : AbilistContainer) :
	if  frombox == tobox or btn.get_parent()==tobox :
		return
	frombox.remove_child(btn)
	tobox.add_child(btn)
	btn.column = tobox.column
	var mult : int = 1 if tobox==availCntnr else -1
	char_sp += mult * btn.selection_cost
	
	if mult >0 : #removing spell
		known[level].erase(btn.spell_dict)
		avail[level].append(btn.spell_dict)
	else :
		known[level].append(btn.spell_dict)
		avail[level].erase(btn.spell_dict)
	
	pointsLabel.text = str(char_sp)+" Selection Points"

func _on_keep_button_pressed():
	var maxlevel : int = charspells.size()
	#for lvl in range(1,maxlevel+1) :
		#charspells[lvl-1].clear()
		#for sb in knownCntnr.get_children() :
			#character.add_spell_drom_dict(sb.spell_dict, lvl-1)
	for lvl in range(1,maxlevel+1) :
		charspells[lvl-1].clear()
		for sd : Dictionary in known[lvl] :
			character.add_spell_drom_dict(sd, lvl)
	character.selection_pts = char_sp
	set_displayed_character(character, show_class_abs, extra_abs)

func on_abltbutton_pressed(btn : AbilityButton) :
	UI.ow_hud.textRect.set_spell_info(btn.spell_dict, character)
