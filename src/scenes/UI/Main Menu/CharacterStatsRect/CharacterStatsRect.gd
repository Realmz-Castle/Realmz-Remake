extends NinePatchRect
class_name NewCharStatsRect

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var statnames = (
	["MaxMovement","MaxActions","","Weight_Limit",""]
	+ ["maxHP","HP_regen_base","HP_regen_mult","maxSP","SP_regen_base","SP_regen_mult",""]
	+ ["Strength","Intellect","Wisdom","Dexterity","Vitality",""]
	+ ["AccuracyMelee","AccuracyRanged","AccuracyMagic",""]
	+ ["EvasionMelee","EvasionRanged","EvasionMagic",""]
	+ ["ResistancePhysical","ResistanceMagic","ResistanceFire","ResistanceIce","ResistanceElect","ResistancePoison","ResistanceChemical","ResistanceDisease","ResistanceHealing",""]
	+ ["MultiplierPhysical","MultiplierMagic","MultiplierFire","MultiplierIce","MultiplierElect","MultiplierPoison","MultiplierChemical","MultiplierDisease","MultiplierHealing"]
	)

@export var portraitrect : TextureRect #= $"PortraitRect"
@export var namelabel : Label #= $"NameLabel"
@export var raceclasslabel : Label #= $"RaceClassLabel"
@export var levellabel : Label #= $"LevelLabel"
@export var statstable : RichTextLabel #= $StatsTable
@export var modstable : RichTextLabel #= $ModsTable

@onready var buttonGD : GDScript = preload( "res://scenes/UI/Main Menu/CharacterStatsRect/RichtextButton.gd" )
@onready var plusTexture : Texture2D = preload ( "res://scenes/UI/Main Menu/CharacterStatsRect/tinybutton_plus.png" )
@onready var minusTexture : Texture2D = preload ( "res://scenes/UI/Main Menu/CharacterStatsRect/tinybutton_minus.png" )

const hpspfirstline : Array = ["","Class", "Race", "Total","  ", "Class","Race", "Total","  ", "Final Stat"]

var character_level : int = 1

var meta_nodes : Array = []

var stat_mods_dict : Dictionary = {}

#var classname : String = ''
#var racename : String = ''

# Called when the node enters the scene tree for the first time.
func _ready():
	statstable.connect("meta_clicked",Callable(self,"statslabel_clicked"))


func statslabel_clicked(meta) :
	# update dictionary
	if stat_mods_dict.has(meta.stat) :
		stat_mods_dict[meta.stat] += meta.plusminus
	else :
		stat_mods_dict[meta.stat] = meta.plusminus
	if stat_mods_dict[meta.stat] == 0 :
		stat_mods_dict.erase(meta.stat)
	# display this checked modstable label :
	modstable.clear()
	# sort the dict keys lol :
	var dict_keys_sorted = []
	for s in statnames :
		if stat_mods_dict.has(s) :
			dict_keys_sorted.append(s)
	
#	modstable.push_align ( 0)#label.Align.ALIGNMENT_CENTER  )
	modstable.push_table(9)
	
	
	print("stat_mods_dict ",stat_mods_dict)
	
	for s in dict_keys_sorted :
		modstable.push_cell()
#		modstable.push_align ( 2)
		modstable.add_text(s+' : ')
#		modstable.pop()
		modstable.pop()
		modstable.push_cell()
#		modstable.push_align ( 0)
		modstable.add_text(str(stat_mods_dict[s])+'lol')
		modstable.pop()
#		modstable.pop()
#		modstable.push_cell()
#		modstable.add_text('  ')
#		modstable.pop()
	
	modstable.pop() # pop table
#	modstable.pop() # pop align
	
#	print("statslabel_clicked", meta.stat, meta.plusminus)

#	match meta :
#		"lol" :
#			print("was lol")

func delete_meta_nodes() :
	for n in meta_nodes :
		n.queue_free()
	meta_nodes.clear()

#func display_raceclass ( classgd : GDScript, racegd : GDScript) :
##	racename = nrac: Array =ename
##	classname = nclassname
#	if classgd==null or racegd==null :
#		raceclasslabel.text ="Select a  Class and a Race !"
#	else :
#		raceclasslabel.text = racegd.classrace_name+" "+classgd.classrace_name
#

func display_name (charname : String) :
	namelabel.text = charname

func display_portrait(portrait : Texture2D) :
	portraitrect.texture = portrait

func set_character_level(level : int) :
	character_level = level
	levellabel.set_text(str(character_level))

func display_data( character) :
	
	if character.classgd==null or character.racegd==null :
		raceclasslabel.text ="Select a  Class and a Race !"
		return
	portraitrect.texture = character.portrait
	raceclasslabel.set_text(character.racegd.classrace_name+' '+character.classgd.classrace_name)
#	namelabel.text = get_parent().new_char_name
	levellabel.text = str(character.level)
#	statstable.add_text(character.name)
	
#	var statnames : Array = []

	display_stat_table(statnames, character)
##	raceclasslabel.text = racegd.classrace_name+" "+classgd.classrace_name
##	print(racegd.classrace_name, " ",classgd.classrace_name )

#	var cbs = character.classgd.base_stat_bonuses
#	var clu = character.classgd.levelup_bonuses
#	var rbs = character.racegd.base_stat_bonuses
#	var rlu = character.racegd.levelup_bonuses
#
#	var sn = "MaxMovement"
#	var mvline = ["Movement",cbs[sn],rbs[sn],cbs[sn]+rbs[sn]," ",clu[sn],rlu[sn],clu[sn]+rlu[sn]," ",cbs[sn]+rbs[sn] + (clu[sn]+rlu[sn])*character_level]
#	sn = "MaxActions"
#	var aprline = [" A P R ",cbs[sn],rbs[sn],cbs[sn]+rbs[sn]," ",clu[sn],rlu[sn],clu[sn]+rlu[sn]," ",cbs[sn]+rbs[sn] + (clu[sn]+rlu[sn])*character_level]
#	display_result([hpspfirstline,mvline,aprline],mvaprtable )
#
#	sn = "maxHP"
#	var hpspsecondline = ["HP",cbs[sn],rbs[sn],cbs[sn]+rbs[sn]," ",clu[sn],rlu[sn],clu[sn]+rlu[sn]," ",cbs[sn]+rbs[sn] + (clu[sn]+rlu[sn])*character_level]
#	sn = "maxSP"
#	var hpspthirdline =  ["SP",cbs[sn],rbs[sn],cbs[sn]+rbs[sn]," ",clu[sn],rlu[sn],clu[sn]+rlu[sn]," ",cbs[sn]+rbs[sn] + (clu[sn]+rlu[sn])*character_level]
#	var hpsparray =  [hpspfirstline, hpspsecondline, hpspthirdline]
#	display_result(hpsparray,hptablelabel )
#
#	sn = "Strength"
#	var basesecondline = ["Strength",cbs[sn],rbs[sn],cbs[sn]+rbs[sn]," ",clu[sn],rlu[sn],clu[sn]+rlu[sn]," ",cbs[sn]+rbs[sn] + (clu[sn]+rlu[sn])*character_level]
#	sn = "Intellect"
#	var basethirdline = ["Intellect",cbs[sn],rbs[sn],cbs[sn]+rbs[sn]," ",clu[sn],rlu[sn],clu[sn]+rlu[sn]," ",cbs[sn]+rbs[sn] + (clu[sn]+rlu[sn])*character_level]
#	sn = "Wisdom"
#	var basefourthline = ["Wisdom",cbs[sn],rbs[sn],cbs[sn]+rbs[sn]," ",clu[sn],rlu[sn],clu[sn]+rlu[sn]," ",cbs[sn]+rbs[sn] + (clu[sn]+rlu[sn])*character_level]
#	sn = "Dexterity"
#	var basefifthline = ["Dexterity",cbs[sn],rbs[sn],cbs[sn]+rbs[sn]," ",clu[sn],rlu[sn],clu[sn]+rlu[sn]," ",cbs[sn]+rbs[sn] + (clu[sn]+rlu[sn])*character_level]
#	sn = "Vitality"
#	var basesixthline = ["Vitality",cbs[sn],rbs[sn],cbs[sn]+rbs[sn]," ",clu[sn],rlu[sn],clu[sn]+rlu[sn]," ",cbs[sn]+rbs[sn] + (clu[sn]+rlu[sn])*character_level]
#	display_result([hpspfirstline,basesecondline,basethirdline,basefourthline,basefifthline,basesixthline], basetable)


func display_stat_table(statnames : Array, character) :
#	print("display_stat_table\ndisplay_stat_table")
	
	delete_meta_nodes()
	
	var cbs = character.classgd.base_stat_bonuses
	var clu = character.classgd.levelup_bonuses
	var rbs = character.racegd.base_stat_bonuses
	var rlu = character.racegd.levelup_bonuses
	
	statstable.text = ""
#	statstable.push_align ( 1)#label.Align.ALIGNMENT_CENTER  )
	
#	var bgd = buttonGD.new('banana',1)
#	meta_nodes.append(bgd)
#	print("bgd class : ", bgd.get_class())
#	statstable.push_meta(bgd)
#	statstable.add_image(plusTexture,10,10)
#	statstable.pop()
	
	statstable.push_table(10)
	var firstline = [""," Class ", " Race ","  ", "Class","Race","  ", "Final Stat",'','']
	for s in firstline :
		statstable.push_cell()
		statstable.add_text(String(s))
		statstable.pop()
	
#	statstable.pop()
#	return
	
	for sn in statnames :
		var row : Array = ['','','','','','','','','','']
		if sn != "" :
			#cbs[sn],rbs[sn],cbs[sn]+rbs[sn]," ",clu[sn],rlu[sn],clu[sn]+rlu[sn]," ",cbs[sn]+rbs[sn] + (clu[sn]+rlu[sn])*character_level]
			var total_stat = character.get_stat(sn)
			row =  [sn, cbs[sn],rbs[sn]," ",clu[sn],rlu[sn]," ",total_stat]
		for c in row :
			statstable.push_cell()
			statstable.add_text(str(c))
			statstable.pop()
		
		if sn != "" :
			statstable.push_cell()
			var minusbgd = buttonGD.new(sn,-1)
			meta_nodes.append(minusbgd)
			statstable.push_meta(minusbgd)
			statstable.add_image(minusTexture,10,10)
			statstable.pop() # pop meta
			statstable.pop() # pop cell
			
			statstable.push_cell()
			var plusbgd = buttonGD.new(sn,1)
			meta_nodes.append(plusbgd)
			statstable.push_meta(plusbgd)
			statstable.add_image(plusTexture,10,10)
			statstable.pop() # pop meta
			statstable.pop() # pop cell
		
	statstable.pop() # pop the push_table
#	statstable.pop() # pop the align=1
#func display_result(rows: Array, label : RichTextLabel) -> void:
#	label.text = ""
#	label.push_align ( 1)#label.Align.ALIGNMENT_CENTER  )
#	label.push_table(rows[0].size())
##	for key in rows[0]: # Add table headers
##		label.push_cell()
##		label.add_text(key)
##		label.pop()
##
#	for row in rows: # Add table values
#		for key in row:
#			label.push_cell()
#			label.add_text(String(key))
#			label.pop()
#	label.pop()  # pop the table
#	label.pop()  #pop the align
