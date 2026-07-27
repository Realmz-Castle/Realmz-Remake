extends AudioStreamPlayer

const MusicSettingsScript = preload("res://scripts/audio/music_settings.gd")

var oneofeachtype: Dictionary = MusicSettingsScript.DEFAULT_MUSIC_BY_TYPE.duplicate()
var mute: bool = false
var currently_playing: Dictionary = {"path": 'none', "type": 'none'}
var map_music_dict: Dictionary = {"path": ""}
var map_music_position: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	volume_db = -20

func set_mute(m: bool) -> void:
	mute = m
	set_stream_paused(m)

func set_type_music_choice(type: String, musicname: String) -> void:
	oneofeachtype[type] = musicname

func play_music_type(type: String) -> Dictionary:
	if type == '':
		print("ERROR: NO MUSIC TYPE, aborting play_music_type")
		return {"path": '', "type": ''}

	var resources = NodeAccess.__Resources()
	var musicsbookdict = resources.musics_book
	var musictypes = resources.musics_types_book
	var musicsofthistype: Dictionary = musictypes[type]

	var picked_music_name: String = ''
	var type_fav_music_name: String = oneofeachtype[type]

	if type_fav_music_name == "No Music" or type_fav_music_name == null:
		set_stream(null)
		stop()
		currently_playing = {"path": '', "type": ''}
		return {"path": '', "type": ''}

	if type_fav_music_name == "No Change":
		return currently_playing

	if not musicsofthistype.has(type_fav_music_name):
		if musicsofthistype.size() == 0:
			set_stream(null)
			stop()
			currently_playing = {"path": '', "type": ''}
			return currently_playing
		else:
			# Don't randomize if music playing before was from this pool
			for mname in musicsofthistype:
				if musicsofthistype[mname]["path"] == currently_playing["path"]:
					return currently_playing

			var randomindex = randi() % musicsofthistype.size()
			picked_music_name = musicsofthistype.keys()[randomindex]
			play_music_specific(picked_music_name)
			return musicsbookdict[picked_music_name]

	picked_music_name = type_fav_music_name
	play_music_specific(picked_music_name)
	return musicsbookdict[picked_music_name]

func play_music_specific(mname: String) -> void:
	print("play specific music: ", mname)
	var resources = NodeAccess.__Resources()

	if resources.musics_book.keys().has(mname):
		var musicdict: Dictionary = resources.musics_book[mname]
		play_music(musicdict)
	else:
		set_stream(null)
		stop()
		currently_playing = {"path": '', "type": ''}

func play_music(musicdict: Dictionary) -> void:
	print("previously playing: ", currently_playing.get("path", ""))

	if currently_playing == map_music_dict:
		# Save the map music position
		if str(map_music_dict.get("type", "")) == 'ogg':
			map_music_position = get_playback_position()
			print("map_music_position ", map_music_position)

	if musicdict == currently_playing:
		return

	set_stream(null)
	stop()

	var music_type := str(musicdict.get("type", ""))
	if music_type.is_empty():
		currently_playing = {"path": "", "type": ""}
		return

	if music_type == 'ogg' or music_type == 'mp3':
		print("Playing OGG/MP3: ", musicdict)
		set_stream(musicdict["sound"])
		var startpos: float = 0.0
		if musicdict == map_music_dict:
			startpos = map_music_position

		# Check for null packet_sequence for ogg vorbis
		var is_null_ogg: bool = false
		if stream is AudioStreamOggVorbis:
			if stream.packet_sequence == null:
				is_null_ogg = true

		if not is_null_ogg:
			play(startpos)

	elif music_type == 'mod':
		# Load the tracker file using OpenMPT (supports MOD, S3M, XM, IT, and many more formats)
		print("Loading tracker music: ", musicdict["path"])
		var file = FileAccess.open(musicdict["path"], FileAccess.READ)
		if file:
			var data = file.get_buffer(file.get_length())
			file.close()
			var mpt_stream = AudioStreamMPT.new()
			mpt_stream.data = data
			mpt_stream.loop_mode = 1  # Enable looping
			set_stream(mpt_stream)
			if musicdict["path"] == map_music_dict["path"]:
				# TODO: Implement position saving for tracker files if needed
				pass
			play()
			print("Successfully loaded tracker music: ", musicdict["path"])
		else:
			print("ERROR: Could not open tracker file: ", musicdict["path"])

	currently_playing = musicdict

func play_music_map() -> void:
	print("play_music_map")
	# If camping, play camp music
	if GameGlobal.camping:
		play_music_type("Camp")
		return

	var resources = NodeAccess.__Resources()
	var musicsbookdict = resources.musics_book
	var mapmusicdata: String = NodeAccess.__Map().mapmusictype

	if mapmusicdata == '':
		stop()
		return

	if oneofeachtype.keys().has(mapmusicdata):
		map_music_dict = play_music_type(mapmusicdata)
		return

	var maptype = NodeAccess.__Map().maptype
	var type_mus_choice: String = ""
	if oneofeachtype.has(maptype):
		type_mus_choice = oneofeachtype[maptype]

	if type_mus_choice == "No Change":
		return

	if type_mus_choice == '' or type_mus_choice == "No Music":
		stop()
		map_music_dict = {"path": ''}
		return

	print("play_music_map mapmusicdata " + type_mus_choice)
	play_music_specific(mapmusicdata)
	map_music_dict = musicsbookdict[mapmusicdata]

func _on_MusicStreamPlayer_finished() -> void:
	play()  # Loop the music
