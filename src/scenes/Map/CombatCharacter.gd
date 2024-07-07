extends Button
class_name CombatCreaButton
## A creature 's image in combat

const bg11 = preload("res://scenes/Map/CreaSelection11.png")
const bg12 = preload("res://scenes/Map/CreaSelection12.png")
const bg21 = preload("res://scenes/Map/CreaSelection21.png")
const bg22 = preload("res://scenes/Map/CreaSelection22.png")

var dying : bool = false
#var prev_state : int = 0

#const ATK_WPN : int = 33
#const ATK_HTH : int = 34
#const ATK_AROW : int = 19
#const ATK_FIRE : int = 35
#const ATK_ICE : int = 36
#const ATK_ELEC : int = 37
#const ATK_SKUL : int = 153

const pic_frame_dict : Dictionary = {
	"ATK_NUL" : 15,
	"ATK_WPN" : 35,
	"ATK_HTH" : 36,
	"ATK_ARO" : 20,
	"ATK_FIR" : 37,
	"ATK_ICE" : 38,
	"ATK_ELE" : 39,
	"ATK_PSN" : 40,
	"ATK_PRP" : 41,
	"ATK_SLM" : 25,
	"ATK_SKL" : 163
}

var map = null
#var tile_position_x = 0
#var tile_position_y = 0

var creature : Creature #a Creature.gd instance, the script of the creature it represents

@onready var sprite : Sprite2D = $Sprite2D
@onready var bgsprite : Sprite2D = $SpriteBG
@onready var atkSprite : Sprite2D = $AttackSprite2D
@onready var dmgLabel : Label = $AttackSprite2D/DamageLabel
@export var atkanimTimer : Timer

#var terraineffects_

# Called when the node enters the scene tree for the first time.
func _ready():	
#	print("OWcharacter _ready")
	# Player start Layer #
#	z_index = 4
	map = NodeAccess.__Map()
#	move(Vector2(3,3))


func set_icon(icon : Texture2D, size : Vector2) :
#	print("set_incon  size ", size)
	sprite.texture = icon
	var iconsize : Vector2 = icon.get_size()/32 #in pixels
	sprite.scale = size/iconsize


# Game inputs #
#func _input(event):
#	if event is InputEventMouseButton and Input.is_action_just_pressed("LeftClick"):
#		print("input ",creature.name)
##		if event.button_index == MOUSE_BUTTON_RIGHT :
#		UI.ow_hud.creatureRect.display_crea_info(self)
#	if event is InputEventKey and event.pressed:
#		if event is InputEventKey and event.scancode == KEY_UP:
#			position.y -= Utils.GRID_SIZE
#			tile_position_y-=1
#		elif event is InputEventKey and event.scancode == KEY_DOWN:
#			position.y += Utils.GRID_SIZE
#			tile_position_y+=1
#		elif event is InputEventKey and event.scancode == KEY_RIGHT:
#			position.x += Utils.GRID_SIZE
#			tile_position_x+=1
#		elif event is InputEventKey and event.scancode == KEY_LEFT:
#			position.x -= Utils.GRID_SIZE
#			tile_position_x-=1
#		if self==map.focsuscharacter :
#			map.update()

func get_stat(stat : String) :
	return creature.get_stat(stat)


func move(dir : Vector2) -> Array :  #returned is a list of new actions for the cmbat state action queue
	position  = position  + Utils.GRID_SIZE * dir
#	tile_position_x += dir.x
#	tile_position_y += dir.y
	if dir.x<0 :
		sprite.set_flip_h(false)
	if dir.x>0 :
		sprite.set_flip_h(true) 
	creature.position += dir #Vector2(tile_position_x,tile_position_y)
	#Terrain effects :
	#var terrain_effects_here : Array = GameGlobal.map.get_terrain_effects_at_pos(creature.position)
##	print(creature.name+" MOVE", terrain_effects_here)
	#for t in terrain_effects_here :
##		print("CombatCharacterButton Move on terrain : ", t["spell"].name)
		#var t_type = t["spell"].terrain_walk_type #0=on entry and re entry this turn 1=every step
		#if (t_type == 0 and not creature.terrain_already_crossed_this_turn.keys().has(t)) or t_type==1:
			#print("CombatCharacterButton  should be affected by terrain", t["spell"].name," BUT SPECIAL EFFECTS #TODO")
##			var damage : int = GameGlobal.calculate_spell_damage(t["caster"], creature, t["spell"], t["power"], true)
##			display_effect(t["spell"].proj_hit, damage)
			#GameGlobal.dontlognext_execute_spell = true
			#GameGlobal.execute_spell(t["caster"].combat_button,t["spell"],t["power"],Vector2i(creature.position), [Vector2i.ZERO] , {self:0}, {Vector2i(creature.position):0}, true, false)
			#creature.terrain_already_crossed_this_turn[t] = 0
##		for o in creature.terrain_already_crossed_this_turn.keys() :
##			if not terrain_effects_here.has(o) :
##				creature.terrain_already_crossed_this_turn.erase(o)
	var destpos : Vector2 = creature.position
	var tilestack : Array = GameGlobal.map.mapdata[destpos.x][destpos.y]
	var move_cost : int = creature.get_mp_cost_for_tile_stack(tilestack)
	print("COMBATCREABUTTON "+creature.name+ " move_cost : "+str(move_cost))
	creature.used_movepoints += move_cost
	print(creature.used_movepoints)
	#UI.ow_hud
	
	var returned_action_queue : Array = []
	for creabuton : CombatCreaButton in StateMachine.combat_state.all_battle_creatures_btns :
		var traits = creabuton.creature.traits
		for t in traits :
			if t.has_method("_on_other_creature_walked") :
				var msg_array : Array = t._on_other_creature_walked(self)
				#print("cbcreabutton msg : ", msg_array)
				for m in msg_array :
					returned_action_queue.append( m )
	
	if self== map.focuscharacter :
		map.queue_redraw()
	
	return returned_action_queue
	
#func _process(delta):
#	pass
#
#func on_thing_enter():
#	pass
#
#func on_thing_leave():
#	pass

func get_pixel_position()->Vector2 :
	return position

func set_creature_represented(crea) : #Crea is a creature.gd instance, or a playercharacter
#	print("set_creature_represented : ", crea)
#	sprite.texture = crea.textureL
	if crea.get("icon") :
		print("CombatCharacter "+crea.name+" must be a PC !")
		set_icon(crea.icon, crea.size)
	else :
		set_icon(crea.textureL, crea.size)
	creature = crea
	position = Utils.GRID_SIZE * crea.position
	match creature.size :
		Vector2.ONE :
			bgsprite.texture = bg11
		Vector2(1,2) :
			bgsprite.texture = bg12
		Vector2(2,1) :
			bgsprite.texture = bg21
		Vector2(2,2) :
			bgsprite.texture = bg22
	atkSprite.position = Vector2(16,16)*creature.size # multiplies nth component of each vector together
#	dmgLabel.position = atkSprite.position
	match creature.curFaction :
		0:
			bgsprite.frame = 0
		_:
			bgsprite.frame = 1
	for t  in crea.traits :
		if t.trait_types.has(["crea_bg_blue"]) :
			bgsprite.frame = 2
	size.x = creature.size[0]*32
	size.y = creature.size[1]*32
#	#TODO  connect it to  owhud somehow


func _on_mouse_entered():
	UI.ow_hud._on_mouse_enter_combat_crea_button(self)
	GameGlobal.map.mouseinside = true


func _on_mouse_exited():
	UI.ow_hud._on_mouse_exit_combat_crea_button()

#func move(dir : Vector2) :
#	tile_position_x += dir
#	tile_position_y += dir
#

func display_effect(picture : String, damage : int, time) :
	if time <= 0.05 :
		_on_atk_anim_timer_timeout()
		return
	atkSprite.frame = pic_frame_dict[picture]
	dmgLabel.text = str(damage)
	atkSprite.show()
	dmgLabel.show()
	atkanimTimer.start(time*GameGlobal.gamespeed)

	

func leave_combat() :
	# happens in cbdecide, and CbAnimation state
	if self == StateMachine.combat_state.get_selected_character_combatbutton() :
		StateMachine.cb_decide_state.end_active_creature_turn(true)
		#GameState.end_active_creature_turn(true)
	StateMachine.combat_state.all_battle_creatures_btns.erase(self)
	StateMachine.combat_state.battle_creatures_yet_to_act_btns.erase(self)
	creature.combat_button = null
	creature = null
	queue_free()
	print("CombatBUtton Leave_combat, TODO  free  tiles in  AI Pathfinding !")

func _on_atk_anim_timer_timeout():
	atkSprite.hide()
	dmgLabel.hide()


func _on_gui_input(event):
#	pass # Replace with function body.
##func _on_ItemSmallButton_gui_input(event):
#	if inventoryrect==null :
#		return
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
#			MOUSE_BUTTON_LEFT:
#				if Input.is_action_just_pressed("LeftClick") :
##					print("Cbbuttonlol")
#					GameState.map.pressed = true
#				if Input.is_action_just_released("LeftClick") :
#					GameState.map.pressed = false
#				inventoryrect.set_selected_item_ctrl(self)
##				print("# left button clicked")# left button clicked
##				if get_parent() == inventoryrect.inventoryBoxRight :
##					inventoryrect.set_selected_item_ctrl(self)
##				else :
##					inventoryrect.set_selected_item_ctrl(null)
#				
			MOUSE_BUTTON_RIGHT:
				UI.ow_hud.creatureRect.display_crea_info(self)
##				print("# right button clicked")
#				if item["equippable"] == 1 :
#					equip_item()
#				if item.has("_on_field_use") :
#					use_item()


func _on_button_down():
	GameGlobal.map._on_MapMouseControlButton_button_down()


func _on_button_up():
	GameGlobal.map._on_MapMouseControlButton_button_up()
