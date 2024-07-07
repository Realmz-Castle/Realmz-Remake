extends NinePatchRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


@onready var soundvolLabel : Label = $VBoxContainer/VolumeVbox/SoundLabel/SoundVLabel
@onready var musicvolLabel : Label = $VBoxContainer/VolumeVbox/MusicLabel/MusicVLabel
@onready var soundbar : HScrollBar = $VBoxContainer/VolumeVbox/SoundLabel/SoundHScrollBar
@onready var musicbar : HScrollBar = $VBoxContainer/VolumeVbox/MusicLabel/MusicHScrollBar


@onready var mus_vbox : VBoxContainer = $VBoxContainer/MusScroll/MusVBox
#must be same as  MusicStreamPlayer.oneofeachtype  and folders  in Data/Music
const music_types : Array = ["Battle", "Camp", "Town","Forest", "Snow", "Swamp", "Desert", "Cave", "Indoor", "Dungeon", "Shop", "Temple", "Items", "Treasure", "Create"]#["Battle", "Camp", "Cave", "Create", "Dungeon", "Indoor", "Items", "Outdoor", "Shop", "Temple", "Treasure"]
#const typeindexesdict : Dictionary = {"Battle":0, "Camp":1, "Cave":2, "Create":3, "Dungeon":4, "Indoor":5, "Items":6, "Outdoor":7, "Shop":8, "Temple":9, "Treasure":10}

const MusicTypeTSCN : PackedScene = preload("res://scenes/UI/HUD/Settings/music_type_setting.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _initialize() :
	print("\n\n\n MusicSettingsRect READY")
	var _index : int = 0
	var favourites = MusicStreamPlayer.oneofeachtype
	
	musicbar.value = (MusicStreamPlayer.volume_db +100) *2
	soundbar.value = (SfxPlayer.volume_db +100) *2
	
	for mt in music_types :
		var mtypectrl = MusicTypeTSCN.instantiate()
		mus_vbox.add_child(mtypectrl)
		mtypectrl.set_type(mt,favourites)
		mtypectrl.button.connect("pressed",Callable(self,"_on_typebutton_pressed").bind(mtypectrl,mt))
		#get all the musics of this type
		#TODO check if  no such key ?
		var typemusicnames : Array = NodeAccess.__Resources().musics_types_book[mt].keys()
		typemusicnames.append("Random !")
		typemusicnames.append("No Change")
		typemusicnames.append("No Music")
		#add buttons with musicnames to the popup vbox
		for m in typemusicnames :
			var nbutton : Button = Button.new()
			nbutton.set_text(m)
			nbutton.connect("pressed",Callable(self,"_on_typepopup_button_pressed").bind(mt,m,mtypectrl))
			mtypectrl.vbox.add_child(nbutton)
		_index +=1
#		popup.set_global_position(bposition+Vector2(2,20))
#		popup.set_size(Vector2(196,popupvsize),true)
	print("\n\n\n")

func _on_typepopup_button_pressed(type : String, mname : String, mtypectrl) :
		mtypectrl.popup.hide()
		mtypectrl.button.set_text(mname)
		print(type + " "+ mname)
		#set this in the profile_settings.cfg
#		Utils.FileHandler.set_cfg_setting(path, section, key, value) :
		var path = Paths.profilesfolderpath+Paths.currentProfileFolderName+'/profile_settings.cfg'
		print("Utils.FileHandler.set_cfg_setting : ",path)
		MusicStreamPlayer.set_type_music_choice(type,mname)
		Utils.FileHandler.set_cfg_setting(path, "MUSIC", type, mname)
#		Paths.profilesfolderpath+newprofilename+'/profile_settings.cfg'

func _on_typebutton_pressed(button, _music_type : String) :
		var popup : PopupPanel = button.popup
		var bglobalpos : Vector2 = button.get_global_position()
		
		var screeny = UI.ow_hud.get_mofified_screensize().y
		var ysize = screeny-bglobalpos.y-60
		
		var _dropmenusize : int = button.vbox.get_child_count()
		
#		var popupvsize :float = min( ysize , dropmenusize*20+20)
		popup.popup( Rect2( bglobalpos+Vector2(0,20), Vector2(196,ysize) ) )

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_sound_h_scroll_bar_value_changed(value):
	var path = Paths.profilesfolderpath+Paths.currentProfileFolderName+'/profile_settings.cfg'
	Utils.FileHandler.set_cfg_setting(path, "VOLUME", "volume_sound", value)
	SfxPlayer.volume_db = (value-100)*0.5
	soundvolLabel.text = str(value)+'%'

func _on_music_h_scroll_bar_value_changed(value):
	var path = Paths.profilesfolderpath+Paths.currentProfileFolderName+'/profile_settings.cfg'
	Utils.FileHandler.set_cfg_setting(path, "VOLUME", "volume_music", value)
	MusicStreamPlayer.volume_db = (value-100)*0.5
	musicvolLabel.text = str(value)+'%'
	MusicStreamPlayer.modplayer.volume_db = value-100-20
