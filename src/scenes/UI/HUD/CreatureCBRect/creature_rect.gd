extends NinePatchRect
#creature rec,  bottomleft menu in combat 

var my_crea			
var my_crea_button 	# these two are about the creatur currently displayed
var charbutton_this_turn	#the  creature button who should normally be displayed unless looking at others
var statuses : Array = [] # array of strings
var statusesindex : int = 0
var melee_unarmed : Texture2D = preload("res://scenes/UI/HUD/CreatureCBRect/unarmed_melee.png")

@onready var creaNameLabel : Label = $HBoxContainer/CreaInfoRect/CreaStats/NameLabel
@onready var creaInfoButton : Button =$HBoxContainer/CreaInfoRect/CreaStats/CreatureButton
@onready var creaHPnLabel : Label = $HBoxContainer/CreaInfoRect/CreaStats/HPnLabel
@onready var creaMPnLabel : Label = $HBoxContainer/CreaInfoRect/CreaStats/MPnLabel
@onready var creaArmornLabel : Label = $HBoxContainer/CreaInfoRect/CreaStats/ArmornLabel
@onready var creaAPRnLabel : Label = $HBoxContainer/CreaInfoRect/CreaStats/APRnLabel
@onready var creaMovenLabel : Label = $HBoxContainer/CreaInfoRect/CreaStats/MovenLabel
@onready var creaStatusLabel : Label = $HBoxContainer/CreaInfoRect/StatusesControl/StatusLabel

@onready var creaMeleeButton : Button =$HBoxContainer/CreaInfoRect/WeaponsBoxContainer/MeleeControl/MeleeButton
@onready var creaMeleeCLabel : Label = $HBoxContainer/CreaInfoRect/WeaponsBoxContainer/MeleeControl/MeleeButton/MChargesLabel
@onready var creaRangeButton : Button =$HBoxContainer/CreaInfoRect/WeaponsBoxContainer/RangeControl/RangeButton
@onready var creaRangeCLabel : Label = $HBoxContainer/CreaInfoRect/WeaponsBoxContainer/RangeControl/RangeButton/RChargesLabel
@onready var creaAmmoButton : Button = $HBoxContainer/CreaInfoRect/WeaponsBoxContainer/AmmoControl/AmmoButton
@onready var creaAmmoCLabel : Label =  $HBoxContainer/CreaInfoRect/WeaponsBoxContainer/AmmoControl/AmmoButton/AChargesLabel
@onready var creaAmmoPanel : Panel = $HBoxContainer/CreaInfoRect/WeaponsBoxContainer/AmmoControl/AmmoButton/AmmoPanel
@onready var creaAmmoVBox : VBoxContainer = $HBoxContainer/CreaInfoRect/WeaponsBoxContainer/AmmoControl/AmmoButton/AmmoPanel/AmmoVBox

@onready var turnorderButton : CheckButton = $TurnOrderButton

@onready var logrect : LogRect = $HBoxContainer/LogRect


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func display_crea_info(creabutton : CombatCreaButton) :
	if creabutton == null :
		creaInfoButton.icon = null
		creaNameLabel.text = ''
		creaHPnLabel.text = ''
		creaMPnLabel.text = ''
		creaArmornLabel.text = ''
		creaAPRnLabel.text = ''
		creaMovenLabel.text = ''
		statuses.clear()
		return
#	print("CreatureRect display_crea_info "+creabutton.creature.name)
	my_crea_button = creabutton
	my_crea = creabutton.creature
	creaInfoButton.icon = creabutton.sprite.texture
	creaNameLabel.text = my_crea.name
	creaHPnLabel.text = str( my_crea.get_stat("curHP") ) + '/' + str( my_crea.get_stat("maxHP") )
	creaMPnLabel.text = str( my_crea.get_stat("curSP") ) + '/' + str( my_crea.get_stat("maxSP") )
	creaArmornLabel.text = str( my_crea.get_stat("ResistancePhysical") )
	creaAPRnLabel.text = str( my_crea.get_stat("MaxActions") - my_crea.used_apr ) + '/' + str( my_crea.get_stat("MaxActions") )
	creaMovenLabel.text = str( my_crea.get_movement_left() ) + '/' + str( my_crea.get_max_movement_weighted_down() )
	statuses.clear()
	for t in my_crea.traits :
		
		#var st_pow : String = ''
		#if t.get("power") :
			#st_pow = ' '+str(t.power)
		#var st_dur : String = ''
		#if t.get("duration") :
			#st_dur = ' for '+str(t.power)+' s'
		#else :
			#st_dur = " (permanent)"
#		var st_text : String = t.name
		statuses.append ( t.get_info_as_text() )
	statusesindex = 0
	_on_status_timer_timeout()
#	iconsprite.set_texture( nitem["texture"] )

	var resources = NodeAccess.__Resources()
	var crea_melee_item: ItemInstance = (
		my_crea.current_melee_weapon_instances[0]
		if not my_crea.current_melee_weapon_instances.is_empty() else null
	)
	var crea_range_item: ItemInstance = my_crea.current_range_weapon_instance
	var crea_ammo_item: ItemInstance = my_crea.current_ammo_weapon_instance
	var melee_definition := resources.get_item_definition(crea_melee_item)
	var range_definition := resources.get_item_definition(crea_range_item)
	var ammo_definition := resources.get_item_definition(crea_ammo_item)
	if crea_melee_item == null:
		creaMeleeButton.icon = melee_unarmed
	else:
		creaMeleeButton.icon = resources.item_texture(crea_melee_item)
	creaMeleeButton.disabled = (
			melee_definition != null
			and melee_definition.maximum_charges > 0
			and crea_melee_item.charges <= 0
		)
	creaMeleeCLabel.text = generate_item_charges_txt(crea_melee_item)

	if crea_range_item == null:
		creaRangeButton.icon = null
		creaRangeButton.disabled = true
	else:
		creaRangeButton.icon = resources.item_texture(crea_range_item)
		var noneedammo: bool = range_definition != null \
			and range_definition.ammo_type == "none"
		var hasammo := crea_ammo_item != null and (
			ammo_definition == null
			or ammo_definition.maximum_charges == 0
			or crea_ammo_item.charges > 0
		)
		creaRangeButton.disabled = not (noneedammo or hasammo)
	creaRangeCLabel.text = generate_item_charges_txt(crea_range_item)

	if crea_ammo_item == null:
		creaAmmoButton.icon = null
	else:
		creaAmmoButton.icon = resources.item_texture(crea_ammo_item)
	creaAmmoCLabel.text = generate_item_charges_txt(crea_ammo_item)

	var crea_is_pc_ally : bool = my_crea.get("classgd") and my_crea.curFaction==0
	creaMeleeButton.disabled = not crea_is_pc_ally
	creaRangeButton.disabled = not crea_is_pc_ally
	creaAmmoButton.disabled = not crea_is_pc_ally

func generate_item_charges_txt(item: ItemInstance) -> String:
	if item == null:
		return ""
	var definition := NodeAccess.__Resources().get_item_definition(item)
	if definition == null or definition.maximum_charges <= 0:
		return ""
	return "Charges : %d/%d" % [item.charges, definition.maximum_charges]


func _on_status_timer_timeout():
	if statuses.is_empty() :
		creaStatusLabel.text = ''
		statusesindex = 0
	else :
		statusesindex += 1
		statusesindex = statusesindex % statuses.size()
		creaStatusLabel.text = statuses[statusesindex]


func _on_melee_button_pressed():
	_on_mouse_entered()
	if not my_crea.current_melee_weapon_instances.is_empty():
		StateMachine.state.use_inventory_item(
			my_crea.current_melee_weapon_instances[0],
			my_crea,
		)


func _on_range_button_pressed():
	_on_mouse_entered()
	if my_crea.current_range_weapon_instance != null:
		StateMachine.state.use_inventory_item(
			my_crea.current_range_weapon_instance,
			my_crea,
		)
	#if my_crea.current_range_weapon.has("_on_combat_use_spell") :
		#var spellname : String = my_crea.current_range_weapon["_on_combat_use_spell"][0]
		#var spellpower : int = my_crea.current_range_weapon["_on_combat_use_spell"][1]
		#var spell = NodeAccess.__Resources().spells_book[spellname][ "script" ]
		##if spell.get_targets(spellpower, my_crea)>0 :
		#StateMachine.transition_to("Combat/CbTargeting", {"item" : my_crea.current_range_weapon, "caster" : my_crea.combat_button, "spell" : spell, "power" : spellpower, "ammo" : my_crea.current_ammo_weapon})
	#if my_crea.current_range_weapon.has("_on_combat_use") :
		#return


func _on_ammo_button_pressed():
	_on_mouse_entered()
	for c in creaAmmoVBox.get_children() :
		c.queue_free()
	creaAmmoPanel.show()
	var resources = NodeAccess.__Resources()
	var range_definition := resources.get_item_definition(
		my_crea.current_range_weapon_instance
	)
	for i: ItemInstance in my_crea.inventory_instances():
		var definition := resources.get_item_definition(i)
		if definition != null and definition.slots().has("Ammunition"):
			if range_definition != null \
					and range_definition.ammo_type == definition.ammo_type:
				var ibutton : Button = Button.new()
				var chargestext := (
					"%d/%d" % [i.charges, definition.maximum_charges]
					if definition.maximum_charges > 0 else "infinite"
				)
				var equippedtext := (
					" (equipped)"
					if my_crea.current_ammo_weapon_instance == i else ""
				)
				ibutton.text = (
					definition.display_name_for(i)
					+ " : "
					+ chargestext
					+ equippedtext
				)
				creaAmmoVBox.add_child(ibutton)
				ibutton.pressed.connect(_on_ammoselectbutton_pressed.bind(i, my_crea))
	if creaAmmoVBox.get_children().is_empty() :
		creaAmmoPanel.hide()


func _on_ammoselectbutton_pressed(ammo_item: ItemInstance, crea: Creature) -> void:
	_on_mouse_entered()
	if not crea.get("classgd") :
		return
	if my_crea.current_ammo_weapon_instance != null:
		crea.unequip_item(my_crea.current_ammo_weapon_instance)
	crea.equip_item(ammo_item)
	creaAmmoPanel.hide()
	display_crea_info(my_crea_button)


func _on_battle_start() :
	logrect.clear()


func _on_mouse_entered():
#	print("CreaRect _on_mouse_entered",my_crea_button, charbutton_this_turn )
	if my_crea_button!=null :
		if charbutton_this_turn != my_crea_button :
			display_crea_info(charbutton_this_turn)






func _on_turn_order_button_toggled(toggled_on):
	UI.ow_hud._on_turn_order_button_toggled(toggled_on)
