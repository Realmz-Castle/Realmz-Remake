extends ColorRect
class_name MiniMapRect

@onready var maptextrect : TextureRect = $BoxContainer/Control/MinimapTextureRect
@onready var xsprite : Sprite2D = $BoxContainer/Control/MinimapTextureRect/YouAreHereSprite
@onready var mmap_name_label : Label = $BoxContainer/MinimapsListRect/NameBoxContainer/MMNameLabel
var cur_map : Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func on_display() :
	print("MiniMapRect GameGlobal.minimaps : ", GameGlobal.minimaps )
	#find a known map
	var found_cur_map : bool = false
	var found_a_map : bool = false
	var first_map_found
	for m in GameGlobal.minimaps :
		if m[6]>0 :		#map is onwed
			if not found_a_map :
				first_map_found = m
				found_a_map = true
			if not cur_map.is_empty() :
				if m[0]==cur_map[0] :
					found_cur_map = true
					first_map_found = m
					break
	maptextrect.visible = found_a_map
	if not found_a_map :
		cur_map = []
	else :
		cur_map = first_map_found
	#display cur map
	display_map(cur_map)

func display_map(m : Array) :

	if m.is_empty() :
		maptextrect.hide()
		mmap_name_label.text = ''
		return
	else :
		maptextrect.show()
	#"MinimapName, MapItRepresents, splashimagename, description, topleftcoordinates(array), pixels/tile, owned
	var imgname : String = m[2]
	var path : String = Paths.campaignsfolderpath + GameGlobal.currentcampaign + "/Splash Images/" + imgname
	var maptexture : ImageTexture = Utils.FileHandler.load_img_texture(path)
	maptextrect.texture = maptexture
	mmap_name_label.text = m[0]
	UI.ow_hud.textRect.set_text(m[3], false,"walk woods.wav")
	if GameGlobal.currentmap_name == m[1] :
		xsprite.show()
		var chartposx : int = GameGlobal.map.focuscharacter.tile_position_x
		var chartposy : int = GameGlobal.map.focuscharacter.tile_position_y
		xsprite.position = (Vector2(chartposx, chartposy) - Vector2(m[4][0],m[4][1])) * m[5]
	else :
		xsprite.hide()


func _on_done_button_pressed() -> void:
	StateMachine.exit_ex_menu_state({})
	hide()


func _on_prev_button_pressed() -> void:
	var index = GameGlobal.minimaps.find(cur_map)
	var newmapcandidate : Array = []
	var next_map : Array = []
	while newmapcandidate != cur_map :
		index = index -1
		if index < 0 :
			index += GameGlobal.minimaps.size()
		newmapcandidate = GameGlobal.minimaps[index]
		if newmapcandidate == cur_map :
			break;
		if newmapcandidate[6]>0 :
			next_map = newmapcandidate
	if not next_map.is_empty() :
		display_map(next_map)
		cur_map = next_map


func _on_next_button_pressed() -> void:
	var index = GameGlobal.minimaps.find(cur_map)
	var newmapcandidate : Array = []
	var next_map : Array = []
	while newmapcandidate != cur_map :
		index = index  + 1
		if index >= GameGlobal.minimaps.size() :
			index -= GameGlobal.minimaps.size()
		newmapcandidate = GameGlobal.minimaps[index]
		if newmapcandidate == cur_map :
			break;
		if newmapcandidate[6]>0 :
			next_map = newmapcandidate
	if not next_map.is_empty() :
		display_map(next_map)
		cur_map = next_map
