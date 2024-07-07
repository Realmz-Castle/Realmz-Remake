extends AudioStreamPlayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
@onready var modplayer : ModPlayer= $"MODXMPlayer"
var mute : bool = false
var currently_playing : Dictionary = {"path":'none',"type":'none'}
#var map_music_path : String = ''
var map_music_dict : Dictionary = {"path" : ''}
var map_music_position : float = 0

var oneofeachtype = {"Battle":"battle.mod", "Camp":"camp.mod", "Cave":"cave.mod", "Create":"create.mod", "Dungeon":"dungeon.mod", "Indoor":"indoor.mod", "Items":"items.mod", "Shop":"shop.mod", "Temple":"temple.mod", "Treasure":"treasure.mod",
					"Town":"outdoor.mod", "Forest":"outdoor.mod","Snow":"outdoor.mod", "Swamp":"outdoor.mod","Desert":"outdoor.mod"}   #format : { "Battle":"battle.ogg", "Outdoors":"outdoor.mod"}

# Called when the node enters the scene tree for the first time.
func _ready():
	modplayer.volume_db = volume_db-20
	pass # Replace with function body.

func set_mute(m : bool) :
	mute = m
	set_stream_paused(m)

func set_type_music_choice(type:String, musicname : String) :
	oneofeachtype[type] = musicname


func play_music_type(type : String) -> Dictionary :
#	print("play_music_type ", type)
	if type=='':
		print("ERROR : NO MUSIC TYPE, aborting play_music_type")
		return {"path":'',"type":''}
	var resources = NodeAccess.__Resources()
	var musicsbookdict = resources.musics_book
	var musictypes = resources.musics_types_book
	var musicsofthistype : Dictionary = musictypes[type]
#	print("musicsofthistype : ",musicsofthistype )
	# format {battle.mod:{path:D:/Programming/Godot/Realmz Remake Folder/Data/Music/Battle//battle.mod, type:mod}}
#	return
	var picked_music_name : String = ''
#	play_music_type("battle")
	var type_fav_music_name : String = oneofeachtype[type]
#	print ("type_fav_music_name before ifs : "+type_fav_music_name)
	
	if type_fav_music_name == "No Music" or type_fav_music_name == null:
		set_stream(null)
		stop()
		modplayer.stop( )
		currently_playing = {"path":'',"type":''}
		return {"path":'',"type":''}
	if type_fav_music_name == "No Change":
		return currently_playing
	if not musicsofthistype.has(type_fav_music_name) :
		#randomize ?
		if musicsofthistype.size()==0 :
			set_stream(null)
			stop()
			modplayer.stop( )
			currently_playing = {"path":'',"type":''}
			return currently_playing
			
		else :
			
			#dont randomize if music playing before was from this pool
			for mname in musicsofthistype :
				if musicsofthistype[mname]["path"]==currently_playing["path"] :
					return currently_playing
			
			var randomindex = randi() % musicsofthistype.size()
			picked_music_name = musicsofthistype.keys()[randomindex]
			play_music_specific(picked_music_name)
			return musicsbookdict[picked_music_name]
#	print("musicsofthistype ! ", musicsofthistype)
#	picked_music_name = musicsofthistype.keys().find(type_fav_music_name)
#	print("play music of type ",type," : ", picked_music_name)
	picked_music_name = type_fav_music_name
	play_music_specific(picked_music_name)
	return musicsbookdict[picked_music_name]


func play_music_specific(mname : String) :
	print("play specific music : ", mname)
	var resources = NodeAccess.__Resources()
#	print(resources.musics_book)
	if resources.musics_book.keys().has(mname) :
		var musicdict : Dictionary = resources.musics_book[mname]
		play_music(musicdict)
	else :
		set_stream(null)
		stop()
		modplayer.stop( )
		currently_playing = {"path":'',"type":''}
		return

func play_music(musicdict : Dictionary) :
	print("previously playing : ", currently_playing["path"])
#	print("play_music\n",currently_playing["path"],'\n',map_music_dict["path"])
	
	if currently_playing == map_music_dict :
		# save the   map music time / position
		if map_music_dict["type"] == 'ogg' :
			map_music_position = get_playback_position()
			print("map_music_position  ", map_music_position)
		elif map_music_dict["type"] == 'mod' :
#			map_music_position = ss
			pass
	
#	if musicdict == map_music_dict :
#		if musicdict["type"] == 'ogg' :
#			seek(map_music_position)
#		elif musicdict["type"] == 'mod' :
#			pass
	
	if musicdict == currently_playing :
		return
	modplayer.stop( )
	set_stream(null)
	stop()
	if musicdict["type"] == 'ogg' or musicdict["type"] == 'mp3':
		print("MusicStreamPayer 113 musicdict : " , musicdict)
		set_stream(musicdict["sound"])
		var startpos : float = 0.0
		if musicdict == map_music_dict :
			startpos = map_music_position
#			seek(map_music_position)
#			print("seeked position ",map_music_position )
		#check for  null packet_sequence for ogg vorbis
		var is_null_ogg : bool = false
		
		if stream.is_class("AudioStreamOggVorbis")  : 
			if stream.packet_sequence == null :
				is_null_ogg = true

		if not is_null_ogg :
			play(startpos)
		modplayer.stop( )
	elif musicdict["type"] == 'mod' :
		modplayer.set_file(musicdict["path"])
		if musicdict["path"] == map_music_dict["path"] :
			pass
		modplayer.play(0)
		set_stream(null)
		stop()
	currently_playing = musicdict

func play_music_map() :
	print("play_music_map")
	# if it's a general  msyuc type, play a thing of this type
	# if it s  the name of a specific track, play it
	if GameGlobal.camping :
		MusicStreamPlayer.play_music_type("Camp")
		return
	var resources = NodeAccess.__Resources()
	var musicsbookdict = resources.musics_book
	var mapmusicdata : String = NodeAccess.__Map().mapmusictype
	if mapmusicdata == '' :
		stop()
		modplayer.stop( )
		return
	if oneofeachtype.keys().has(mapmusicdata) :
		map_music_dict = play_music_type(mapmusicdata)
		return
	var maptype = NodeAccess.__Map().maptype
	var type_mus_choice : String = ""
	if oneofeachtype.has(maptype) :
		type_mus_choice = oneofeachtype[maptype]
	
	if type_mus_choice == "No Change" :
		return
	if type_mus_choice == '' or type_mus_choice=="No Music" :
		stop()
		map_music_dict = {"path" = ''}
		modplayer.stop( )
		return
	print("play_music_map mapmusicdata "+type_mus_choice)
	play_music_specific(mapmusicdata)
	map_music_dict = musicsbookdict[mapmusicdata]


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_MusicStreamPlayer_finished():
	play()
