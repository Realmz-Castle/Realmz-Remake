#SpellsRect is the script for the spells menu checked the HUD
extends NinePatchRect




# Declare member variables here. Examples:
# var a = 2
# var b = "text"
@onready var spellbuttonTSCN : PackedScene = preload("res://scenes/UI/HUD/Spells/SpellButton.tscn")

@onready var spellButtonIconGray : Texture2D = preload("res://scenes/UI/HUD/Spells/SpellButtonIconGray.png" )
@onready var spellButtonIconGreen: Texture2D = preload("res://scenes/UI/HUD/Spells/SpellButtonIconGreen.png" )
@onready var spellButtonIconRed : Texture2D = preload("res://scenes/UI/HUD/Spells/SpellButtonIconRed.png" )

@onready var spellLevelsRect = $"VBoxContainer/TopContainer/SpellLevelsRect/SpellLevelsContainer"
@onready var spelllistContainer = $"VBoxContainer/TopContainer/SpellsListRect/ScrollContainer/SpellListContainer"

@onready var spellPowersContainer = $"VBoxContainer/MiddleContainer/PowerLevelsRect/PowerLevelsContainer"

@onready var charportrait : TextureRect = $"VBoxContainer/BottomContainer/PortraitFrameRect/PortraitRect"
@onready var charnameLabel : Label = $"VBoxContainer/MiddleContainer/SpellInfoRect/CharNameRect/CharNameLabel"

@onready var levelgroup: ButtonGroup = ButtonGroup.new()
@onready var powerbgroup: ButtonGroup = ButtonGroup.new()

#boxes for screen reszing
@onready var topcontainer : HBoxContainer = $"VBoxContainer/TopContainer"
@onready var midcontainer : HBoxContainer = $"VBoxContainer/MiddleContainer"
@onready var botcontainer : HBoxContainer = $"VBoxContainer/BottomContainer"

# spell info controls
@onready var aoeTextureRect : TextureRect = $"VBoxContainer/MiddleContainer/SpellInfoRect/SpellAoERect/AoETextureRect"

const aoe_b1_tex : Texture = preload("res://scenes/UI/HUD/Spells/TargetImages/b1.png")
const aoe_b2_tex : Texture = preload("res://scenes/UI/HUD/Spells/TargetImages/b2.png")
const aoe_b3_tex : Texture = preload("res://scenes/UI/HUD/Spells/TargetImages/b3.png")
const aoe_b4_tex : Texture = preload("res://scenes/UI/HUD/Spells/TargetImages/b4.png")
const aoe_b5_tex : Texture = preload("res://scenes/UI/HUD/Spells/TargetImages/b5.png")
const aoe_b6_tex : Texture = preload("res://scenes/UI/HUD/Spells/TargetImages/b6.png")
const aoe_b7_tex : Texture = preload("res://scenes/UI/HUD/Spells/TargetImages/b7.png")
const aoe_wh_tex : Texture = preload("res://scenes/UI/HUD/Spells/TargetImages/Wall.png")
const aoe_ry_tex : Texture = preload("res://scenes/UI/HUD/Spells/TargetImages/Ray.png")
const aoe_sf_tex : Texture = preload("res://scenes/UI/HUD/Spells/TargetImages/Self.png")
const aoe_pb_tex : Texture = preload("res://scenes/UI/HUD/Spells/TargetImages/PBAOE.png")
const aoe_cw_tex : Texture = preload("res://scenes/UI/HUD/Spells/TargetImages/Crown.png")
const aoe_2v_tex : Texture = preload("res://scenes/UI/HUD/Spells/TargetImages/2v.png")
const aoe_pt_tex : Texture = preload("res://scenes/UI/HUD/Spells/TargetImages/Party.png")
const aoe_af_tex : Texture = preload("res://scenes/UI/HUD/Spells/TargetImages/AllFriendly.png")
const aoe_ae_tex : Texture = preload("res://scenes/UI/HUD/Spells/TargetImages/AllEnemy.png")
const aoe_eo_tex : Texture = preload("res://scenes/UI/HUD/Spells/TargetImages/Everyone.png")
const aoe_sp_tex : Texture = preload("res://scenes/UI/HUD/Spells/TargetImages/Special.png")

const aoenametotex_dict : Dictionary = {'b1':aoe_b1_tex,'b2':aoe_b2_tex,'b3':aoe_b3_tex,'b4':aoe_b4_tex,'b5':aoe_b5_tex,'b6':aoe_b6_tex,'b7':aoe_b7_tex,
	'wh':aoe_wh_tex, 'ry':aoe_ry_tex, 'sf':aoe_sf_tex, 'pb':aoe_pb_tex, 'cw':aoe_cw_tex, '2v':aoe_2v_tex,
	'pt':aoe_pt_tex,'af':aoe_af_tex, 'ae':aoe_ae_tex,'eo':aoe_eo_tex, 'sp':aoe_sp_tex }

@onready var dmgminLabel : Label = $"VBoxContainer/MiddleContainer/SpellInfoRect/StatsRect/DamageMinLabel"
@onready var dmgmaxLabel : Label = $"VBoxContainer/MiddleContainer/SpellInfoRect/StatsRect/DamageMaxLabel"
@onready var durminLabel : Label = $"VBoxContainer/MiddleContainer/SpellInfoRect/StatsRect/DurationMinLabel"
@onready var durmaxLabel : Label = $"VBoxContainer/MiddleContainer/SpellInfoRect/StatsRect/DurationMaxLabel"
@onready var rngLabel : Label = $"VBoxContainer/MiddleContainer/SpellInfoRect/StatsRect/RangeLabel"
@onready var rotLabel : Label = $"VBoxContainer/MiddleContainer/SpellInfoRect/StatsRect/RotationLabel"
@onready var losLabel : Label = $"VBoxContainer/MiddleContainer/SpellInfoRect/StatsRect/LoSLabel"
@onready var trgLabel : Label = $"VBoxContainer/MiddleContainer/SpellInfoRect/StatsRect/TargetsLabel"
@onready var attributesLabel : Label = $"VBoxContainer/MiddleContainer/SpellInfoRect/AttributesLabel"
@onready var costformulaLabel : Label = $"VBoxContainer/MiddleContainer/SpellInfoRect/CostFormulaLabel"
@onready var powerLabel : Label = $"VBoxContainer/MiddleContainer/SpellInfoRect/SpellCostBGRect/PowerLabel"
@onready var spcostLabel : Label = $"VBoxContainer/MiddleContainer/SpellInfoRect/SpellCostBGRect/SPCostLabel"
@onready var charaspLabel : Label = $"VBoxContainer/MiddleContainer/SpellInfoRect/SpellCostBGRect/CharaSPLabel"

@onready var textRect  = $"../VBoxScreen/HBoxBot/TextRect"

@onready var castButton : Button = $VBoxContainer/BottomContainer/CastButton

var picked_character = null
var picked_level = 1
var picked_spell = null
var picked_power : int = 1

@onready var plevelbutton1 = $"VBoxContainer/MiddleContainer/PowerLevelsRect/PowerLevelsContainer/PLevelButton1"
@onready var plevelbutton2 = $"VBoxContainer/MiddleContainer/PowerLevelsRect/PowerLevelsContainer/PLevelButton2"
@onready var plevelbutton3 = $"VBoxContainer/MiddleContainer/PowerLevelsRect/PowerLevelsContainer/PLevelButton3"
@onready var plevelbutton4 = $"VBoxContainer/MiddleContainer/PowerLevelsRect/PowerLevelsContainer/PLevelButton4"
@onready var plevelbutton5 = $"VBoxContainer/MiddleContainer/PowerLevelsRect/PowerLevelsContainer/PLevelButton5"
@onready var plevelbutton6 = $"VBoxContainer/MiddleContainer/PowerLevelsRect/PowerLevelsContainer/PLevelButton6"
@onready var plevelbutton7 = $"VBoxContainer/MiddleContainer/PowerLevelsRect/PowerLevelsContainer/PLevelButton7"
@onready var plevelbuttons : Array = [plevelbutton1,plevelbutton2,plevelbutton3,plevelbutton4,plevelbutton5,plevelbutton6,plevelbutton7]

signal spell_picked


# Called when the node enters the scene tree for the first time.
func _ready():
	await UI.ready
#	yield ( UI, "ready")
	connect("spell_picked",Callable(UI.ow_hud,"_on_spell_picked"))
	#Error connect(signal: String,Callable(target: Object,method: String).bind(binds: Array = [  ),flags: int = 0)

func on_viewport_size_changed(screensize) :
	
	if screensize.y <=600 :
		topcontainer.set_custom_minimum_size(Vector2(320,175))
		topcontainer.set_size(Vector2(320,275))
		set_scale( Vector2(1, screensize.y/600) )
#		topcontainer.set_size(Vector2(320,275))
#		midcontainer.set_size(Vector2(320,275))

	else :
		var h = max(screensize.y-325 , 175)
		set_scale( Vector2.ONE )
		topcontainer.set_custom_minimum_size(Vector2(320,h))
		topcontainer.set_size(Vector2(320,h))
		midcontainer.set_position(Vector2(0,screensize.y-325))
		botcontainer.set_position(Vector2(0,screensize.y-50))
#	_set_size(Vector2(320, h))


func initialize(character) :
	picked_spell = null
	castButton.disabled = true
#	print("initialize spell menu for "+character.name)
	picked_character = character
	charnameLabel.text = picked_character.name
	if picked_character.get("portrait") :
		charportrait.texture = picked_character.portrait
	else :
		charportrait.texture = picked_character.textureL
#	print("spell menu with ", character.name, "\n spells : ", character.spells)
	var allowed_level : int = character.spells.size()
	for c in spellLevelsRect.get_children() :
		if c.get_index() >0 :
			c.set_button_group(levelgroup)
			c.disabled = (c.get_index() > allowed_level)
	
	for c in spellPowersContainer.get_children() :
		if c.get_index() >0 :
			c.set_button_group(powerbgroup)
	
	_on_SLevelButton_pressed(0)
	_on_PLevelButton_pressed(1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_CastButton_pressed():
	print("_on_CastButton_pressed")
#	hide()
#	picked_spell = "some spell "+String(randi()%1000)
	emit_signal("spell_picked", picked_character, picked_spell, picked_power, {} ) #item is {}
	if StateMachine.is_combat_state() :
		textRect.hide()
		UI.ow_hud.creatureRect.show()
		UI.ow_hud.creatureRect.display_crea_info(UI.ow_hud.creatureRect.my_crea_button)

func _on_AbortButton_pressed():
	print("SpellsRect AbortButton_pressed")
	hide()
	picked_spell = "abort"
	if StateMachine.is_combat_state() :
		StateMachine.exit_cb_menu_state()
	else :
		StateMachine.exit_ex_menu_state()
	UI.ow_hud._on_spell_menu_closed()
	UI.ow_hud._on_viewport_size_changed()
	textRect.hide()
	UI.ow_hud.creatureRect.show()
	if StateMachine.is_combat_state() and is_instance_valid(UI.ow_hud.creatureRect.my_crea_button):
		UI.ow_hud.creatureRect.display_crea_info(UI.ow_hud.creatureRect.my_crea_button)
#	UI.ow_hud.emit_signal( "pc_picked", [])

func _on_LeftButton_pressed():
	if picked_character.is_npc_ally :
		return
	var pcid : int = GameGlobal.player_characters.find(picked_character)-1
	var teamsize : int = GameGlobal.player_characters.size()
	#find the magic user before picked_character
	var prevchar = GameGlobal.player_characters[(pcid)%teamsize]
	while prevchar.spells.size()==0 :
		pcid = (pcid-1)%teamsize
		prevchar = GameGlobal.player_characters[(pcid)%teamsize]
	if prevchar == picked_character :
		return
	else :
		initialize(prevchar)
	#selected_character.spells.size()>0


func _on_RightButton_pressed():
	if picked_character.is_npc_ally :
		return
	var pcid : int = GameGlobal.player_characters.find(picked_character)+1
	var teamsize : int = GameGlobal.player_characters.size()
	#find the magic user before picked_character
	var nextchar = GameGlobal.player_characters[(pcid)%teamsize]
	while nextchar.spells.size()==0 :
		pcid = (pcid+1)%teamsize
		nextchar = GameGlobal.player_characters[(pcid)%teamsize]
	if nextchar == picked_character :
		return
	else :
		initialize(nextchar)


func _on_SLevelButton_pressed(slevel : int):
	picked_spell = null
	display_spell_info()
	picked_level = slevel
	for c in spelllistContainer.get_children() :
		c.queue_free()
		c.free()
	#if picked_character.spells[slevel-1].is_empty() :
		#return
	for s in picked_character.spells[slevel-1] :
#		print("adding spell button for "+s["name"])
		var new_button : Button = spellbuttonTSCN.instantiate()
		new_button.text = s["name"]
		new_button.connect("pressed",Callable(self,"_on_spell_selected").bind(s, new_button))
		spelllistContainer.add_child(new_button)
		castButton.disabled = true#not can_cast_spell(picked_character, spell, power : int)
		#if StateMachine.is_combat_state() :
			#castButton.disabled = castButton.disabled and picked_spell.in_combat
		#else :
			#castButton.disabled = castButton.disabled and picked_spell.in_field

func can_cast_spell(crea : Creature, spell, power : int) -> bool :
	if not spell.get("is_not_spell") and crea.get_spellsperround_left()<=0 :
		return false
	if StateMachine.is_combat_state() and (not spell.in_combat) :
		#print("SpellsRect can_cast_spell : "+spell.name+ "is not for combat mode")
		return false
	if StateMachine.is_exploration_state() and (not spell.in_field) :
		#print("SpellsRect can_cast_spell : "+spell.name+ "is not for field mode")
		return false
			#castButton.disabled = castButton.disabled and picked_spell.in_combat
		#else :
			#castButton.disabled = castButton.disabled and picked_spell.in_field
	if spell.has_method("can_use") :
		var canuse : bool = picked_spell.can_use(crea)
		if not canuse :
			#print("SpellsRect can_cast_spell : "+spell.name+ "can_use method returned false")
			return false
	var cost : int = crea.get_spell_resource_cost(spell,power)
	if spell.get("max_focus_loss") :
		if crea.focus_counter > spell.get("max_focus_loss") :
			#print("SpellsRect can_cast_spell : "+spell.name+ "requires less focus loss")
			return false
	#print("SpellsRect can_cast_spell : "+spell.name+ " cost is "+str(cost))
	return crea.get_stat("curSP")>= cost

func _on_PLevelButton_pressed(power : int):
	picked_power = power
	display_spell_info()

func _on_spell_selected(spelldict : Dictionary, button) :
	UI.ow_hud.emit_signal( "pc_picked", [])
	show()
	# this was to avoid changing the spell while picking targets
	# without preventing chosing a new checked with
	# ow_hud.selecting_several_characters : bool
	print("selected "+spelldict["name"])
	picked_spell = spelldict["script"]
	print(spelldict.keys())
	for b in spelllistContainer.get_children() :
		if b == button :
			b.set_button_icon(spellButtonIconGreen)
		else :
			b.set_button_icon(spellButtonIconGray)
	display_spell_info()
	
	if picked_spell.get("max_plevel") :
		var maxplevel = min(7,picked_spell.max_plevel)
		for i in range(7) :
			var pbutton = plevelbuttons[i]
			pbutton.set_disabled(i>=maxplevel)
		if picked_power >= maxplevel :
			var pbutton = plevelbuttons[maxplevel-1]
			pbutton.set_pressed(true)
			_on_PLevelButton_pressed(maxplevel-1)
	else :
		for b in plevelbuttons :
			b.set_disabled(false)

func display_spell_info() :
	if picked_spell == null :
		castButton.disabled = true
		# remove_at all labels text
		dmgminLabel.text = ''
		dmgmaxLabel.text = ''
		durminLabel.text = ''
		durmaxLabel.text = ''
		rngLabel.text = ''
		trgLabel.text = ''
		losLabel.text = ''
		rotLabel.text = ''
		attributesLabel.text = ''
		powerLabel.text = ''
		spcostLabel.text = ''
		charaspLabel.text = ''
		textRect.textLabel.parse_bbcode('')
		return
	print("SPellsRect picked spell : "+picked_spell.name, picked_spell)
	#print(typeof(picked_spell))
	#print(picked_spell)
	var cancast : bool = can_cast_spell(picked_character, picked_spell, picked_power)
	castButton.disabled = not cancast

	dmgminLabel.text = str(  picked_spell.get_min_damage(picked_power, picked_character)   )
	dmgmaxLabel.text = str(  picked_spell.get_max_damage(picked_power, picked_character)   )
	durminLabel.text = str(  picked_spell.get_min_duration(picked_power, picked_character)   )
	durmaxLabel.text = str(  picked_spell.get_max_duration(picked_power, picked_character)   )
	rngLabel.text = str(  picked_spell.get_range(picked_power, picked_character)   )
	trgLabel.text = str(  picked_spell.get_target_number(picked_power, picked_character) )
	
	var aoe = picked_spell.get_aoe(picked_power,picked_character)
	if aoe is String and aoenametotex_dict.has(aoe):
		aoeTextureRect.texture = aoenametotex_dict[aoe]
	else :
		aoeTextureRect.texture = aoe_sp_tex
	
	if picked_spell.los :
		losLabel.text = "Yes"
	else :
		losLabel.text = "No"
	if picked_spell.get("rot") :
		rotLabel.text = "Yes"
	else :
		rotLabel.text = "No"
	powerLabel.text = str(picked_power)
	attributesLabel.text =  str(  picked_spell.attributes  )+"\n"+picked_spell.description
	spcostLabel.text = str(picked_character.get_spell_resource_cost(picked_spell, picked_power))#String(  picked_spell.get_sp_cost(picked_power, picked_character)   )
	charaspLabel.text = str(  picked_character.get_stat("curSP")  )
	textRect.textLabel.parse_bbcode(picked_spell.description)
	
	#print("SpellsRect can_cast_spel "+ picked_spell.name +'?')
	castButton.disabled = not can_cast_spell(picked_character, picked_spell, picked_power)
#	textRect.set_text(picked_spell.description)
#	textRect.disablerButton.hide()
#		textLabel.clear()
