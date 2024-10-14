##
##	100% pure GDScript software Mod Player [Godot Mod Player]
##		by あるる（きのもと 結衣） @arlez80
##
##	MIT License
##

@icon("icon.png")
class_name ModPlayer

extends Node

# -------------------------------------------------------
# 定数
const mod_master_bus_name:String = "arlez80_GModP_MASTER_BUS"
const mod_channel_bus_name:String = "arlez80_GModP_CHANNEL_BUS%d"
const default_mix_rate:int = 4144
const default_linear_mix_rate:int = 8363
const chip_speed:float = 50.0
const volume_table:Array[float] = [
	-144.0,-36.1,-30.1,-26.6,-24.1,-22.1,-20.6,
	-19.2,-18.1,-17.0,-16.1,-15.3,-14.5,-13.8,-13.2,
	-12.6,-12.0,-11.5,-11.0,-10.5,-10.1,-9.7,-9.3,
	-8.9,-8.5,-8.2,-7.8,-7.5,-7.2,-6.9,-6.6,-6.3,
	-6.0,-5.8,-5.5,-5.2,-5.0,-4.8,-4.5,-4.3,-4.1,
	-3.9,-3.7,-3.5,-3.3,-3.1,-2.9,-2.7,-2.5,-2.3,
	-2.1,-2.0,-1.8,-1.6,-1.5,-1.3,-1.2,-1.0,-0.9,
	-0.7,-0.6,-0.4,-0.3,-0.1,0.0
]

# -----------------------------------------------------------------------------
# Signals

signal note_on( channel_number, note )
signal looped

# -----------------------------------------------------------------------------
# Classes
class GodotModPlayerChannelAudioEffect:
	var ae_panner:AudioEffectPanner = null

class GodotModPlayerInstrument:
	var source:Mod.ModInstrument
	var array_asw:Array[AudioStreamWAV]

class GodotModPlayerPitch:
	const center_key_freq:float = 856.0

	## 現在値
	var value:int
	## 変化目標（ポルタメント用）
	var dest:int
	## 変化量（ポルタメント用）
	var speed:int
	## 最後の変化量（ポルタメント用）
	var last_speed:int
	## ポルタメント量
	var porta_value:int

	## アルペジオリスト
	var arpeggio:Array[int]
	## アルペジオカウンタ
	var arpeggio_count:int
	## アルペジオ有効
	var arpeggio_enabled:bool

	var linear_freq:bool = false

	func _init():
		self.value = 0
		self.dest = 0
		self.speed = 0
		self.last_speed = 0
		self.porta_value = 0

		self.arpeggio = [0,0,0]
		self.arpeggio_count = 0
		self.arpeggio_enabled = false

	func update( ):
		if self.dest < self.value:
			self.value -= self.speed
			if self.value <= self.dest:
				self.value = self.dest
				self.speed = 0
		elif self.value < self.dest:
			self.value += self.speed
			if self.dest <= self.value:
				self.value = self.dest
				self.speed = 0

	## 現在のピッチスケールを得る
	## @param	vibrato	ビブラート値
	## @return	計算したピッチスケール
	func get_pitch_scale( vibrato:int = 0 ) -> float:
		var v:int = self.value

		if self.arpeggio_enabled:
			v += self.arpeggio[self.arpeggio_count]
			self.arpeggio_count = ( self.arpeggio_count + 1 ) % 3

		if self.linear_freq:
			return pow( 2.0, ( ( 4608 - v ) / 768.0 ) - ( self.porta_value / 255.0 ) + ( vibrato / 255.0 / 12.0 * 5.0 ) )

		v += vibrato + self.porta_value
		if v == 0:
			return 0.0

		return center_key_freq / v

	## ファインピッチスケールを取得
	## @return	現在のファインピッチスケール
	func get_fine_pitch_scale( ) -> float:
		return pow( 2.0, ( self.value / 128.0 ) / 12.0 )

class GodotModPlayerEffect:
	var type:int = 0
	var phase:int = 0
	var speed:int = 0
	var depth:int = 0
	var depth_shift:int = 0

	var value:int = 0

	## 更新
	func update( ) -> void:
		var v:int = 0
		match self.type:
			Mod.ModWaveFormType.SINE_WAVEFORM:		# 正弦波
				# TODO: そのうちPackedByteArrayのtableにでもしておく
				v = int( sin( self.phase * ( PI / 32.0 ) ) * 255.0 )
			Mod.ModWaveFormType.SAW_WAVEFORM:		# のこぎり
				v = 255 - ( ( self.phase + 0x20 ) & 0x3F ) * 8
			Mod.ModWaveFormType.SQUARE_WAVEFORM:	# 矩形波
				v = 255 - ( self.phase & 0x20 ) * 16
			Mod.ModWaveFormType.RAMDOM_WAVEFORM:	# 乱数
				v = self.rng.randi( 511 ) - 255
			Mod.ModWaveFormType.REV_SAW_WAVEFORM:	# 逆のこぎり
				v = ( ( self.phase + 0x20 ) & 0x3F ) * 8

		self.phase += self.speed

		self.value = ( v * self.depth ) >> self.depth_shift

class GodotModPlayerEnvelope:
	var source:Mod.ModEnvelope

	var frame:int = 0
	var value:int = 0
	var init_value:int = 0
	var sustain:bool = false
	var enabled:bool = false

	## ノートオン
	## @param	_source	エンベロープデータ
	func note_on( _source:Mod.ModEnvelope ) -> void:
		self.source = _source
		self.sustain = true
		self.frame = 0
		if self.source != null and self.source.enabled:
			self.value = self.source.points[0].value
		else:
			self.value = self.init_value

	## ノートオフ
	func note_off( ) -> void:
		self.sustain = false

	## 更新
	func update( ) -> void:
		if self.source == null:
			self.value = self.init_value
			return

		self.enabled = self.source.enabled

		if not self.enabled:
			self.value = self.init_value
			return

		var current_point:int = 0
		var prev_sum_frame:int = 0
		var sum_frame:int = 0
		var loop_start_frame:int = 0
		for i in range( 1, self.source.point_count ):
			sum_frame += self.source.points[i].frame
			if self.source.loop_start_point == i:
				loop_start_frame = sum_frame
			if self.frame < sum_frame:
				var t:float = float( self.frame - prev_sum_frame ) / float( sum_frame - prev_sum_frame )
				var s:float = 1.0 - t
				self.value = int( self.source.points[i-1].value * s + self.source.points[i].value * t )
				break
			prev_sum_frame = sum_frame
			current_point = i

		if self.source.sustain_enabled and self.sustain and self.source.sustain_point == current_point:
			pass
		elif self.source.loop_enabled and self.source.loop_end_point == current_point:
			self.frame = loop_start_frame
		elif current_point == self.source.point_count and sum_frame < self.frame:
			self.frame = sum_frame
		else:
			self.frame += 1

class GodotModPlayerChannelStatus:
	const head_silent_second:float = 1.0
	const gap_second:float = 1024.0 / 44100.0

	var source_inst:Mod.ModInstrument
	var source_sample:Mod.ModSample
	var asps:Array[AudioStreamPlayer]
	var asp_switcher:int

	var channel_number:int
	var last_instrument:int = -1
	var last_key_number:int = -1
	var mute:bool
	var pitch:GodotModPlayerPitch
	var fine_pitch:GodotModPlayerPitch
	var relative_pitch:float = 1.0

	var volume:int
	var panning:int
	var amplified:int
	var fx_count:int
	var vibrato:GodotModPlayerEffect
	var tremolo:GodotModPlayerEffect

	var volume_env:GodotModPlayerEnvelope
	var panning_env:GodotModPlayerEnvelope

	var last_porta_up:int = 0
	var last_porta_down:int = 0
	var last_volume_slide:int = 0
	var last_panning_slide:int = 0
	var last_multi_retrig_note:int = 0

	var force_note_off:bool = false

	## コンストラクタ
	## @param	_channel_number	チャンネル番号
	## @param	linear_freq		周波数指定が線形か？
	func _init(_channel_number:int,linear_freq:bool):
		self.mute = false
		self.force_note_off = false

		self.channel_number = _channel_number
		self.panning = 128

		for i in range( 2 ):
			var asp: = AudioStreamPlayer.new( )
			asp.bus = mod_channel_bus_name % self.channel_number
			self.asps.append( asp )
		self.asp_switcher = 0

		self.pitch = GodotModPlayerPitch.new( )
		self.fine_pitch = GodotModPlayerPitch.new( )
		self.pitch.linear_freq = linear_freq
		self.fine_pitch.linear_freq = linear_freq
		self.vibrato = GodotModPlayerEffect.new( )
		self.vibrato.depth_shift = 6 if linear_freq else 7	# XXX: 多分 Linear Frequency の時に大きめに設定してある気がした。
		self.tremolo = GodotModPlayerEffect.new( )
		self.tremolo.depth_shift = 6
		self.volume_env = GodotModPlayerEnvelope.new( )
		self.volume_env.init_value = 64
		self.panning_env = GodotModPlayerEnvelope.new( )
		self.panning_env.init_value = 32

	## Tick更新
	func tick_update( ) -> void:
		self.volume_env.update( )
		self.panning_env.update( )

	## 更新
	func update( ) -> void:
		if self.mute:
			for asp in self.asps:
				if asp.is_playing( ):
					asp.stop( )
			return

		for i in range( self.asps.size( ) ):
			var asp:AudioStreamPlayer = self.asps[i]
			if self.asp_switcher == i and ( not self.force_note_off ):
				if asp.is_playing( ):
					asp.volume_db = self.get_volume_db( )
					var pitch:float = self.get_pitch_scale( )
					if pitch < 0.01:
						asp.stream_paused = true
					else:
						if asp.stream_paused:
							asp.stream_paused = false
						asp.pitch_scale = pitch
			else:
				if asp.is_playing( ):
					asp.volume_db -= 4.0
					if asp.volume_db < -100.0:
						asp.stop( )

	## volume_dbを取得
	## @return	現在のvolume_dbを返す
	func get_volume_db( ) -> float:
		var v:float = ( clampf( self.volume + self.tremolo.value, 0.0, 64.0 ) / 64.0 ) * ( self.volume_env.value / 64.0 )
		return volume_table[int(v * 64)]

	## ピッチスケールを取得
	## @return	現在のピッチスケールを返す
	func get_pitch_scale( ) -> float:
		return self.pitch.get_pitch_scale( self.vibrato.value ) * self.relative_pitch * self.fine_pitch.get_fine_pitch_scale( )

	## ボリュームスライドを実行
	## @param	value	値
	func execute_volume_slide( value:int ) -> void:
		if value == 0:
			value = self.last_volume_slide
		else:
			self.last_volume_slide = value
		self.volume = clampi( self.volume + ( value >> 4 ) - ( value & 0x0F ), 0, 64 )

	## ノートオフ
	func note_off( ) -> void:
		self.volume_env.note_off( )
		self.panning_env.note_off( )

	## 再トリガー
	func retrig( ) -> void:
		self.asp_switcher = ( self.asp_switcher + 1 ) % self.asps.size( )
		var asp:AudioStreamPlayer = self.asps[self.asp_switcher]
		var pitch_scale:float = self.get_pitch_scale( )
		asp.pitch_scale = pitch_scale
		asp.play( maxf( 0.0, self.head_silent_second - clampf( self.gap_second - AudioServer.get_time_to_next_mix( ), 0.0, self.gap_second ) * pitch_scale ) )

	## ノートオン
	## @param	inst			楽器データ
	## @param	effect_command	エフェクトコマンド
	## @param	key_number		周波数
	## @param	note			ノート番号
	## @param	sample_offset	サンプルオフセット
	## @param	reset_inst		楽器データ再設定
	func note_on( inst:GodotModPlayerInstrument, effect_command:int, key_number:int, note:int, sample_offset:int, reset_inst:bool ) -> void:
		self.last_key_number = key_number

		if self.mute:
			return

		var tone_porta:bool = effect_command == 0x03 || effect_command == 0x05

		self.force_note_off = false

		self.source_inst = inst.source
		self.source_sample = self.source_inst.samples[note-1]
		if self.source_sample.panning != -1:
			self.panning = self.source_sample.panning

		if not tone_porta:
			self.asp_switcher = ( self.asp_switcher + 1 ) % self.asps.size( )

		var asp:AudioStreamPlayer = self.asps[self.asp_switcher]
		var asw:AudioStreamWAV = inst.array_asw[note-1]
		if tone_porta:
			self.pitch.value += self.pitch.porta_value
			self.pitch.dest = key_number
		else:
			asp.stop( )
			asp.stream = asw
			self.pitch.value = key_number
		self.pitch.porta_value = 0
		self.fine_pitch.value = self.source_sample.finetune
		self.relative_pitch = pow( 2.0, self.source_sample.relative_note / 12.0 )
		
		#if self.source_inst.vibrato_type != -1:
			#self.vibrato.type = self.source_inst.vibrato_type
			#self.vibrato.speed = self.source_inst.vibrato_speed
			#self.vibrato.depth = self.source_inst.vibrato_depth
			#self.vibrato.depth_shift = 7 - self.source_inst.vibrato_depth_shift

		if reset_inst:
			self.volume = self.source_sample.volume
			self.volume_env.note_on( self.source_inst.volume_envelope )
			self.panning_env.note_on( self.source_inst.panning_envelope )

		asp.volume_db = self.get_volume_db( )
		var pitch_scale:float = self.get_pitch_scale( )
		if 0.0 < pitch_scale:
			asp.pitch_scale = pitch_scale
		if not tone_porta:
			asp.play( maxf( 0.0, self.head_silent_second + ( float(sample_offset) / float(asw.mix_rate) ) - clampf( self.gap_second - AudioServer.get_time_to_next_mix( ), 0.0, self.gap_second ) * pitch_scale ) )
		if pitch_scale < 0.01:
			asp.stream_paused = true

# -----------------------------------------------------------------------------
# Export

## ファイル
@export_file ("*.mod", "*.xm") var file:String = "" : set = set_file
## 再生中か？
@export var playing:bool = false
## 音量
@export_range(-144.0, 0.0) var volume_db:float = -20.0 : set = set_volume_db
## ループフラグ
@export var loop:bool = false
## mix_target same as AudioStreamPlayer's one
@export var mix_target:AudioStreamPlayer.MixTarget = AudioStreamPlayer.MIX_TARGET_STEREO
## bus same as AudioStreamPlayer's one
@export var bus:StringName = &"Master"

# -----------------------------------------------------------------------------
# 変数

## Modデータ
var mod_data:Mod.ModData = null : set = set_mod_data
## テンポ
var tempo:float = 125.0 : set = set_tempo
## 行毎秒
var row_per_second:float = 0.02
## tick毎行
var tick_per_row:int = 4
## tick毎秒
var tick_per_second:float = 1.0 / chip_speed
## 次の行への秒数
var next_row_remain_second:float = 0.0
## 次のtickへの秒数
var next_tick_remain_second:float = 0.0
## 追加tick
var extra_tick:int = 0
## tick処理済み回数
var processed_tick_count:int = 0
## 位置（秒）
var position:float = 0.0
## 曲位置
var song_position:int = 0
## パターン内位置
var pattern_position:int = 0
## 次の行
var pattern_position_on_next_row:int = 0
## 楽器
var instruments:Array[GodotModPlayerInstrument] = []
## チャンネル
var channel_status:Array[GodotModPlayerChannelStatus] = []
## Modチャンネルエフェクト
var channel_audio_effects:Array[GodotModPlayerChannelAudioEffect] = []
## パターンジャンプ先
var pattern_position_jump_point:int = 0
## パターンループカウンタ
var pattern_loop_count:int = 0
## パターンループ先
var pattern_loop_origin:int = 0
## 乱数
var rng:RandomNumberGenerator
## グローバル音量コマンドを有効にするか？
var enable_global_volume_command:bool = true
## グローバル音量 (mod/xm指定の数字)
var global_volume:int = 64
## グローバル音量スライド最終パラメータ
var global_volume_slide_last_param:int = 0x00
## グローバル音量 (計算用db)
var global_volume_db:float = 0.0

## 準備
func _ready( ):
	self.rng = RandomNumberGenerator.new( )

	if AudioServer.get_bus_index( self.mod_master_bus_name ) == -1:
		AudioServer.add_bus( -1 )
		var mod_master_bus_idx:int = AudioServer.get_bus_count( ) - 1
		AudioServer.set_bus_name( mod_master_bus_idx, self.mod_master_bus_name )
		AudioServer.set_bus_send( mod_master_bus_idx, self.bus )
		AudioServer.set_bus_volume_db( AudioServer.get_bus_index( self.mod_master_bus_name ), self.volume_db )

		for i in range( 32 ):
			AudioServer.add_bus( -1 )
			var mod_channel_bus_idx:int = AudioServer.get_bus_count( ) - 1
			AudioServer.set_bus_name( mod_channel_bus_idx, self.mod_channel_bus_name % i )
			AudioServer.set_bus_send( mod_channel_bus_idx, self.mod_master_bus_name )
			AudioServer.set_bus_volume_db( mod_channel_bus_idx, 0.0 )

			var cae: = GodotModPlayerChannelAudioEffect.new( )
			cae.ae_panner = AudioEffectPanner.new( )
			AudioServer.add_bus_effect( mod_channel_bus_idx, cae.ae_panner )
			self.channel_audio_effects.append( cae )
	else:
		for i in range( 32 ):
			var mod_channel_bus_idx:int = 0
			for k in range( AudioServer.get_bus_count( ) ):
				if AudioServer.get_bus_name( k ) == self.mod_channel_bus_name % i:
					mod_channel_bus_idx = k
					break

			var cae: = GodotModPlayerChannelAudioEffect.new( )
			for k in range( AudioServer.get_bus_effect_count( mod_channel_bus_idx ) ):
				var ae: = AudioServer.get_bus_effect( mod_channel_bus_idx, k )
				if ae is AudioEffectPanner:
					cae.ae_panner = ae
			self.channel_audio_effects.append( cae )

	if self.playing:
		self.play( )

## 通知
## @param	what	通知要因
func _notification( what:int ):
	# 破棄時
	if what == NOTIFICATION_PREDELETE:
		pass
		# 削除せずに使いまわす
		#AudioServer.remove_bus( AudioServer.get_bus_index( self.mod_master_bus_name ) )
		#for i in range( 0, 16 ):
		#	AudioServer.remove_bus( AudioServer.get_bus_index( self.midi_channel_bus_name % i ) )

## 再生前の初期化
func _prepare_to_play( ) -> void:
	# ファイル読み込み
	if self.mod_data == null:
		match self.file.get_extension( ):
			"mod":
				var mod_reader: = Mod.new( )
				self.mod_data = mod_reader.read_file( self.file ).data
			"xm":
				var xm_reader: = XM.new( )
				var m:Object = xm_reader.read_file( self.file ).data
				self.mod_data = m
			_:
				self.mod_data = null

	if self.mod_data == null:
		self.stop( )
		return

	if self.channel_status != null:
		for t in self.channel_status:
			for asp in t.asps:
				self.remove_child( asp )

	self.set_volume_db( self.volume_db )

	self.instruments = []
	var temp_head_silent:Array[int] = []
	var head_silent_samples:int = default_mix_rate
	if self.mod_data.flags & Mod.ModFlags.LINEAR_FREQUENCY_TABLE != 0:
		head_silent_samples = default_linear_mix_rate
	for i in range( head_silent_samples ):
		temp_head_silent.append( 0 )
	var head_silent:PackedByteArray = PackedByteArray( temp_head_silent )
	var loaded:Dictionary = {}
	for t in self.mod_data.instruments:
		var inst:GodotModPlayerInstrument = GodotModPlayerInstrument.new( )

		inst.source = t
		inst.array_asw = []

		for sample in t.samples:
			var id:int = sample.get_instance_id( )
			var ass:AudioStreamWAV = null
			if not( id in loaded ):
				ass = AudioStreamWAV.new( )
				ass.stereo = false
				if self.mod_data.flags & Mod.ModFlags.LINEAR_FREQUENCY_TABLE != 0:
					ass.mix_rate = self.default_linear_mix_rate
				else:
					ass.mix_rate = self.default_mix_rate
				if sample.bit == 16:
					ass.data = head_silent + head_silent  + sample.data
					ass.format = AudioStreamWAV.FORMAT_16_BITS
					ass.loop_begin = sample.loop_start + head_silent_samples * 2
				else:
					ass.data = head_silent + sample.data
					ass.format = AudioStreamWAV.FORMAT_8_BITS
					ass.loop_begin = sample.loop_start + head_silent_samples
				ass.loop_end = ass.loop_begin + sample.loop_length
				if sample.bit == 16:
					ass.loop_begin /= 2
					ass.loop_end /= 2
				ass.loop_mode = AudioStreamWAV.LOOP_DISABLED
				if sample.loop_type & Mod.ModLoopType.FORWARD_LOOP != 0:
					ass.loop_mode = AudioStreamWAV.LOOP_FORWARD
				elif sample.loop_type & Mod.ModLoopType.PING_PONG_LOOP != 0:
					ass.loop_mode = AudioStreamWAV.LOOP_PINGPONG
				loaded[id] = ass
			else:
				ass = loaded[id]
			inst.array_asw.append( ass )

		self.instruments.append( inst )
	for k in loaded.keys( ):
		loaded.erase( k )

	self.channel_status = []
	for i in range( self.mod_data.channel_count ):
		var cs: = GodotModPlayerChannelStatus.new( i, self.mod_data.flags & Mod.ModFlags.LINEAR_FREQUENCY_TABLE != 0 )
		if 4 < self.mod_data.channel_count:
			cs.panning = 128
		else:
			cs.panning = [64,192,192,64][i]
		for asp in cs.asps:
			self.add_child( asp )
		self.channel_status.append( cs )

## 再生
## @param	from_position	再生開始位置（現在未実装）
func play( from_position:float = 0.0 ):
	self._prepare_to_play( )
	if self.mod_data == null:
		return

	self.playing = true
	if from_position == 0.0:
		self.position = 0.0
		self.song_position = 0
		self.pattern_position_jump_point = 1
		self.pattern_position = -1
		self.pattern_position_on_next_row = -1
		self.pattern_loop_count = 0
		self.pattern_loop_origin = 0
		self.tick_per_second = 1.0 / self.chip_speed
		self.set_tempo( self.mod_data.init_bpm )
		self.set_tick( self.mod_data.init_tick )
		self.processed_tick_count = 10000
		self.next_tick_remain_second = 0.0
		self.next_row_remain_second = self.row_per_second
	else:
		self.seek( from_position )

## シーク
## @param	to_position	再生位置
func seek( to_position:float ) -> void:
	printerr( "Godot Mod Player: seekは未実装 seek not implemented yet" )

	self._stop_all_notes( )

## 停止
func stop( ) -> void:
	self._stop_all_notes( )
	self.playing = false

## ファイル変更
## @param	path	ファイルパス
func set_file( path:String ) -> void:
	file = path
	self.mod_data = null
	if self.playing:
		self.play( )

## Modデータ変更
## @param	md	Modデータ
func set_mod_data( md:Mod.ModData ) -> void:
	mod_data = md

## 音量設定
## @param	vdb	音量
func set_volume_db( vdb:float ) -> void:
	var master_bus_id:int = AudioServer.get_bus_index( self.mod_master_bus_name )
	volume_db = vdb
	if master_bus_id == -1:
		return

	var gvdb:float = self.global_volume_db if self.enable_global_volume_command else 0.0
	AudioServer.set_bus_volume_db( master_bus_id, volume_db + gvdb )

## 全音を止める
func _stop_all_notes( ) -> void:
	for t in self.channel_status:
		t.note_off( )
		t.force_note_off = true
		for asp in t.asps:
			if asp.is_playing( ):
				asp.stop( )

## テンポ設定
## @param	_tempo	テンポ
func set_tempo( _tempo:float ) -> void:
	tempo = _tempo
	self.tick_per_second = 1.0 / ( self.chip_speed * ( _tempo / 125.0 ) )
	self.next_row_remain_second -= self.row_per_second
	self.row_per_second = self.tick_per_row * self.tick_per_second
	self.next_row_remain_second += self.row_per_second

## tickからテンポ設定
## @param	_tick	Tick数
func set_tick( _tick:int ) -> void:
	self.tick_per_row = _tick
	self.next_row_remain_second -= self.row_per_second
	self.row_per_second = self.tick_per_row * self.tick_per_second
	self.next_row_remain_second += self.row_per_second

## 1フレームでの処理
## @param	delta	
func _process( delta:float ):
	if self.mod_data == null:
		return
	if not self.playing:
		return

	self.position += delta
	self.next_row_remain_second -= delta
	self.next_tick_remain_second -= delta
	if self.next_row_remain_second <= 0.0:
		self.next_tick_remain_second = -INF
	while self.next_tick_remain_second <= 0.0 and self.processed_tick_count < self.tick_per_row + self.extra_tick:
		self._process_tick( )
		self.next_tick_remain_second += self.tick_per_second
		self._process_row( )
		self.processed_tick_count += 1
	if self.next_row_remain_second <= 0.0:
		self.extra_tick = 0
		self._process_move_to_next_line( )
		self.next_row_remain_second = self.row_per_second + self.next_row_remain_second
		self.next_tick_remain_second = 0.0
		self.processed_tick_count = 1
	self._process_update_audio_effects( )

## 次の行に移行する
func _process_move_to_next_line( ) -> void:
	if 0 <= self.pattern_position_on_next_row:
		self.pattern_position = self.pattern_position_on_next_row
		self.pattern_position_on_next_row = -1
		self.song_position = self.pattern_position_jump_point
		self.pattern_position_jump_point = self.song_position + 1
	else:
		self.pattern_position += 1
		if len( self.mod_data.patterns[self.mod_data.song_positions[self.song_position]] ) <= self.pattern_position:
			self.pattern_position = 0
			self.song_position = self.pattern_position_jump_point
			self.pattern_position_jump_point = self.song_position + 1

	if self.mod_data.song_length <= self.song_position:
		if self.loop:
			self.song_position = self.mod_data.restart_position
			self.pattern_position_jump_point = self.song_position + 1
			self.looped.emit( )
		else:
			self.song_position = 0
			self.stop( )
			return

## 1行処理
func _process_row( ) -> void:
	var pattern_line:Array[Mod.ModPatternNote] = self.mod_data.patterns[self.mod_data.song_positions[self.song_position]][self.pattern_position]
	for channel in self.channel_status:
		self._process_row_for_channel( channel, pattern_line[channel.channel_number] )

## チャンネルごとの1行処理
## @param	channel	チャンネルデータ
## @param	note	ノートデータ
func _process_row_for_channel( channel:GodotModPlayerChannelStatus, note:Mod.ModPatternNote ) -> void:
	#printt( channel.channel_number, pattern_node.sample_number, pattern_node.key_number, pattern_node.effect_command )

	var note_on:bool = self.processed_tick_count == 1
	var sample_offset:int = 0
	# Note関係のエフェクトコマンド
	if note.effect_command == 0x0E:
		match ( note.effect_param >> 4 ):
			0x09:	# Retrigger Note
				note_on = ( ( self.processed_tick_count - 1 ) % ( note.effect_param & 0x0F ) ) == 0
			0x0D:	# Note Delay
				note_on = ( note.effect_param & 0x0F ) == self.processed_tick_count - 1
	elif note.effect_command == 0x09:
		sample_offset = note.effect_param * 256

	# 楽器設定
	if note.instrument != 0:
		channel.last_instrument = note.instrument - 1
	# 発音
	if note_on:
		channel.pitch.arpeggio_count = 0
		if note.note == 96:
			channel.note_off( )
		elif 0 < note.key_number or note.instrument != 0:
			var key_number: = note.key_number if 0 < note.key_number else channel.last_key_number
			if 0 <= channel.last_instrument and channel.last_instrument < self.instruments.size( ) and 0 < key_number:
				var inst:GodotModPlayerInstrument = self.instruments[channel.last_instrument]
				channel.note_on( inst, note.effect_command, key_number, note.note, sample_offset, note.instrument != 0 )

			self.note_on.emit( channel.channel_number, note )

	if self.processed_tick_count == 1:
		self._process_tick_for_channel( channel, note, true )

## 1tick処理
func _process_tick( ) -> void:
	if self.pattern_position < 0:
		return

	var pattern_line:Array[Mod.ModPatternNote] = self.mod_data.patterns[self.mod_data.song_positions[self.song_position]][self.pattern_position]
	for channel in self.channel_status:
		self._process_tick_for_channel( channel, pattern_line[channel.channel_number], false )

## チャンネルごとの1tick処理
## @param	channel				チャンネルデータ
## @param	note				ノートデータ
## @param	disable_channel_row	チャンネルイベントを無視する
func _process_tick_for_channel( channel:GodotModPlayerChannelStatus, note:Mod.ModPatternNote, disable_channel_row:bool ) -> void:
	#print( "%08x %08x" % [ note.effect_command, note.effect_param ] )

	channel.pitch.arpeggio_enabled = false
	channel.vibrato.value = 0
	channel.tremolo.value = 0

	channel.tick_update( )

	if 0x10 <= note.volume and note.volume <= 0x50:
		channel.volume = note.volume - 0x10
	elif 0x60 <= note.volume:
		match note.volume >> 4:
			0x06:	# Volume slide down
				if not disable_channel_row:
					channel.volume = clampi( channel.volume - ( note.volume & 0x0F ), 0, 64 )
			0x07:	# Volume slide up
				if not disable_channel_row:
					channel.volume = clampi( channel.volume + ( note.volume & 0x0F ), 0, 64 )
			0x08:	# Fine volume slide down
				if not disable_channel_row:
					channel.volume = clampi( channel.volume - ( note.volume & 0x0F ), 0, 64 )
			0x09:	# Fine volume slide up
				if not disable_channel_row:
					channel.volume = clampi( channel.volume + ( note.volume & 0x0F ), 0, 64 )
			0x0A:	# Set vibrato speed
				channel.vibrato.speed = (channel.vibrato.speed & 0x0F) | ( ( note.volume & 0x0F ) << 4 );
			0x0B:	# Vibrato Depth
				channel.vibrato.depth = note.volume & 0x0F
			0x0C:	# Panning
				var p:int = note.volume & 0x0F
				p |= p << 4
				channel.panning = p
			0x0D:	# Panning slide left
				if not disable_channel_row:
					channel.panning = clampi( channel.panning - ( note.volume & 0x0F ), 0, 255 )
			0x0E:	# Panning slide right
				if not disable_channel_row:
					channel.panning = clampi( channel.panning + ( note.volume & 0x0F ), 0, 255 )
			0x0F:	# Tone portamento
				if 0 < note.volume & 0x0F:
					var p:int = note.volume & 0x0F
					p |= p << 4
					channel.pitch.speed = self._fix_tone_portament( p )
			_:
				printerr( "unknown volume effect command: %02x" % note.volume )

	# エフェクトコマンド
	match note.effect_command:
		0x00:	# Arpeggio
			if note.effect_param != 0:
				if channel.pitch.linear_freq:
					const linear_freq_factor:int = -64 # -( 768 / 12 )
					channel.pitch.arpeggio[1] = ( note.effect_param >> 4 ) * linear_freq_factor
					channel.pitch.arpeggio[2] = ( note.effect_param & 0x0F ) * linear_freq_factor
				else:
					channel.pitch.arpeggio[1] = int( channel.pitch.value / pow( 2.0, ( note.effect_param >> 4 ) / 12.0 ) ) - channel.pitch.value
					channel.pitch.arpeggio[2] = int( channel.pitch.value / pow( 2.0, ( note.effect_param & 0x0F ) / 12.0 ) ) - channel.pitch.value
				channel.pitch.arpeggio_enabled = true
			else:
				channel.pitch.arpeggio_enabled = false
		0x01:	# Portament up
			var value:int = note.effect_param
			if value == 0:
				value = channel.last_porta_up
			else:
				channel.last_porta_up = value
			if not disable_channel_row:
				channel.pitch.porta_value -= value
		0x02:	# Portament down
			var value:int = note.effect_param
			if value == 0:
				value = channel.last_porta_down
			else:
				channel.last_porta_down = value
			if not disable_channel_row:
				channel.pitch.porta_value += value
		0x03:	# Portament speed
			if note.effect_param != 0:
				channel.pitch.speed = self._fix_tone_portament( note.effect_param )
				channel.pitch.last_speed = channel.pitch.speed
			else:
				channel.pitch.speed = channel.pitch.last_speed
			channel.pitch.update( )
		0x04:	# Vibrato
			if ( note.effect_param & 0xF0 ) != 0:
				channel.vibrato.speed = note.effect_param >> 4
			if ( note.effect_param & 0x0F ) != 0:
				channel.vibrato.depth = note.effect_param & 0x0F
			channel.vibrato.update( )
		0x05:	# Portament + Volume slide
			channel.pitch.update( )
			if not disable_channel_row:
				channel.execute_volume_slide( note.effect_param )
		0x06:	# Vibrato + Volume slide
			channel.vibrato.update( )
			if not disable_channel_row:
				channel.execute_volume_slide( note.effect_param )
		0x07:	# Tremolo
			if note.effect_param & 0xF0 != 0:
				channel.tremolo.speed = note.effect_param >> 4
			if note.effect_param & 0x0F != 0:
				channel.tremolo.depth = note.effect_param & 0x0F
			channel.tremolo.update( )
		0x08:	# Panning
			channel.panning = clampi( note.effect_param * 2, 0, 255 )
		0x09:	# Sample offset
			# 発音時に処理
			pass
		0x0A:	# Volume slide
			if not disable_channel_row:
				channel.execute_volume_slide( note.effect_param )
		0x0B:	# Pattern jump
			if disable_channel_row:
				self.pattern_position_jump_point = note.effect_param
				self.pattern_position_on_next_row = 0
		0x0C:	# Volume
			channel.volume = clampi( note.effect_param, 0, 64 )
		0x0D:	# Pattern break
			if disable_channel_row:
				self.pattern_position_jump_point = self.song_position + 1
				self.pattern_position_on_next_row = ( note.effect_param >> 4 ) * 10 + ( note.effect_param & 0x0F )
				if 64 <= self.pattern_position_on_next_row:
					self.pattern_position_on_next_row = 0
		0x0E:	# 拡張コマンド
			match ( note.effect_param >> 4 ):
				0x01:	# Fine portamento up
					if note.effect_param & 0x0F != 0:
						channel.fine_pitch.speed = note.effect_param & 0x0F
					channel.fine_pitch.update( )
				0x02:	# Fine portamento down
					if note.effect_param & 0x0F != 0:
						channel.fine_pitch.speed = - (note.effect_param & 0x0F)
					channel.fine_pitch.update( )
				0x04:	# Vibrato type
					channel.vibrato.type = note.effect_param
					channel.vibrato.update( )
				0x06:	# Pattern loop
					if disable_channel_row:
						if 0 < ( note.effect_param & 0x0F ):
							if ( note.effect_param & 0x0F ) == self.pattern_loop_count:
								self.pattern_loop_count = 0
							else:
								self.pattern_loop_count += 1
								self.pattern_position_jump_point = self.song_position
								self.pattern_position_on_next_row = self.pattern_loop_origin
						else:
							self.pattern_loop_origin = self.pattern_position
				0x07:	# Tremoro type
					channel.tremolo.type = note.effect_param
					channel.tremolo.update( )
				0x09:	# Retrigger Note
					pass
				0x0A:	# Fine volume slide up
					if not disable_channel_row:
						channel.volume = clampi( channel.volume + ( note.volume & 0x0F ), 0, 64 )
				0x0B:	# Fine volume slide down
					if not disable_channel_row:
						channel.volume = clampi( channel.volume - ( note.volume & 0x0F ), 0, 64 )
				0x0C:	# Note cut
					if self.processed_tick_count - 1 == note.effect_param & 0x0F:
						channel.volume = 0
				0x0D:	# Note delay （上で処理する）
					pass
				0x0E:	# Pattern delay
					var r:int = ( note.effect_param & 0x0F )
					self.extra_tick = r * self.tick_per_row
					if disable_channel_row:
						self.next_row_remain_second += self.row_per_second * r
				_:
					printerr( "unknown extended command: %04x" % [ note.effect_param ] )
		0x0F:	# Tick / Tempo
			if disable_channel_row:
				if note.effect_param < 0x20:
					self.set_tick( note.effect_param )
				else:
					self.set_tempo( note.effect_param )
		0x10:	# Global volume
			self.global_volume = clampi( note.effect_param, 0, 64 )
			self.global_volume_db = self.volume_table[self.global_volume]
			self.set_volume_db( self.volume_db )
		0x11:	# Global volume slide
			if note.effect_param != 0x00:
				self.global_volume_slide_last_param = note.effect_param
			self.global_volume = clampi( self.global_volume + ( self.global_volume_slide_last_param >> 4 ) - ( self.global_volume_slide_last_param & 0x0F ), 0, 64 )
			self.global_volume_db = self.volume_table[self.global_volume]
			self.set_volume_db( self.volume_db )
		0x14:	# Key unchecked
			printerr( "not implemented: Kxx Key unchecked" )
		0x15:	# Set envelope position
			channel.tremolo.phase = note.effect_param
		0x19:	# Pannning slide
			if not disable_channel_row:
				var value:int = note.effect_param
				if value == 0:
					value = channel.last_panning_slide
				else:
					channel.last_panning_slide = value
				channel.panning = clampi( channel.panning + ( value >> 4 ) - ( value & 0x0F ), 0, 255 )
		0x1B:	# Multi retrig note
			var value:int = note.effect_param
			if value == 0:
				value = channel.last_multi_retrig_note
			else:
				channel.last_multi_retrig_note = value
			if ( ( value & 0xF0 ) >> 4 ) == 0 or ( ( self.processed_tick_count - 1 ) % ( ( value & 0xF0 ) >> 4 ) ) == 0:
				channel.retrig( )
			if disable_channel_row:
				match value & 0x0F:
					0:
						pass
					1:
						self.global_volume = clampi( self.global_volume - 1, 0, 64 )
					2:
						self.global_volume = clampi( self.global_volume - 2, 0, 64 )
					3:
						self.global_volume = clampi( self.global_volume - 4, 0, 64 )
					4:
						self.global_volume = clampi( self.global_volume - 8, 0, 64 )
					5:
						self.global_volume = clampi( self.global_volume - 16, 0, 64 )
					6:
						self.global_volume = clampi( floori( self.global_volume * 2.0 / 3.0 ), 0, 64 )
					7:
						self.global_volume = clampi( floori( self.global_volume / 2.0 ), 0, 64 )
					8:
						printerr( "error: can't use 8 volume command in multi retrig note (0x1B)" )
					9:
						self.global_volume = clampi( self.global_volume + 1, 0, 64 )
					10:
						self.global_volume = clampi( self.global_volume + 2, 0, 64 )
					11:
						self.global_volume = clampi( self.global_volume + 4, 0, 64 )
					12:
						self.global_volume = clampi( self.global_volume + 8, 0, 64 )
					13:
						self.global_volume = clampi( self.global_volume + 16, 0, 64 )
					14:
						self.global_volume = clampi( floori( self.global_volume * 3.0 / 2.0 ), 0, 64 )
					15:
						self.global_volume = clampi( floori( self.global_volume * 2.0 ), 0, 64 )
		0x1D:	# Tremor
			printerr( "not implemented: Txy Tremor" )
		0x21:	# Extra Fine Porta Up
			printerr( "not implemented: Xxx Extra Fine Porta Up" )
		_:
			printerr( "unknown command: %02x : %04x" % [ note.effect_command, note.effect_param ] )

## ポルタメント補正
## @param	v	元値
## @return	補正後値
func _fix_tone_portament( v:int ) -> int:
	# Linear Frequency
	if self.mod_data.flags & Mod.ModFlags.LINEAR_FREQUENCY_TABLE != 0:
		# XXX: この4倍には根拠なし。耳コピでこのぐらいだと思った。
		return v * 4

	# Amiga Frequency
	return v

## Godotのオーディオエフェクト更新
func _process_update_audio_effects( ) -> void:
	for channel in self.channel_status:
		channel.update( )
		var cae:GodotModPlayerChannelAudioEffect = self.channel_audio_effects[channel.channel_number]
		cae.ae_panner.pan = clampf( ( ( channel.panning - 128 ) / 128.0 ) + ( ( channel.panning_env.value - 32 ) / 32.0 ), -1.0, 1.0 )
