extends Node


const CLOCK_TICKING_SFX = preload("uid://b5ryt4aq6sw45")
const BUTTON_PRESSED_SFX = preload("uid://cwoqj40gmsarn")
const EAT_PELLETS_SFX = preload("uid://b447bg7dmcq4f")
const NOTICE_SFX = preload("uid://bh7l5pd8uxmdn")
const SUCCESSFUL_SFX = preload("uid://u7sxdl8sptvr")
const SLIDER_TICK_SFX = preload("uid://ctypbdhstdp78")
const CHARACTER_BURST_SFX = preload("uid://deaspcramvbe3")

var button_pressed_audio_stream_player: AudioStreamPlayer = AudioStreamPlayer.new()
var clock_ticking_audio_stream_player: AudioStreamPlayer = AudioStreamPlayer.new()
var eat_pellets_audio_stream_player: AudioStreamPlayer = AudioStreamPlayer.new()
var notice_sfx_audio_stream_player: AudioStreamPlayer = AudioStreamPlayer.new()
var successful_sfx_audio_stream_player: AudioStreamPlayer = AudioStreamPlayer.new()
var slider_tick_sfx_audio_stream_player: AudioStreamPlayer = AudioStreamPlayer.new()
var character_burst_sfx_audio_stream_player: AudioStreamPlayer = AudioStreamPlayer.new()

func _ready() -> void:
	configure_button_pressed_audio_stream_player()
	configure_clock_ticking_audio_stream_player()
	configure_eat_pellets_audio_stream_player()
	configure_notice_audio_stream_player()
	configure_successful_audio_stream_player()
	configure_character_burst_audio_stream_player()


func configure_button_pressed_audio_stream_player() -> void:
	button_pressed_audio_stream_player.bus = "sfx"
	button_pressed_audio_stream_player.stream = BUTTON_PRESSED_SFX
	button_pressed_audio_stream_player.volume_db = -30
	get_tree().root.add_child.call_deferred(button_pressed_audio_stream_player)
	print("button sfx properties set")

func configure_clock_ticking_audio_stream_player() -> void:
	clock_ticking_audio_stream_player.bus = "sfx"
	clock_ticking_audio_stream_player.stream = CLOCK_TICKING_SFX
	clock_ticking_audio_stream_player.volume_db = -30
	get_tree().root.add_child.call_deferred(clock_ticking_audio_stream_player)
	print("clock ticking sfx properties set")

func configure_eat_pellets_audio_stream_player() -> void:
	eat_pellets_audio_stream_player.bus = "sfx"
	eat_pellets_audio_stream_player.stream = EAT_PELLETS_SFX
	eat_pellets_audio_stream_player.volume_db = -30
	get_tree().root.add_child.call_deferred(eat_pellets_audio_stream_player)
	print("eat pellets sfx properties set")

func configure_notice_audio_stream_player() -> void:
	notice_sfx_audio_stream_player.bus = "sfx"
	notice_sfx_audio_stream_player.stream = NOTICE_SFX
	notice_sfx_audio_stream_player.volume_db = -30
	get_tree().root.add_child.call_deferred(notice_sfx_audio_stream_player)
	print("notice sfx properties set")

func configure_successful_audio_stream_player() -> void:
	successful_sfx_audio_stream_player.bus = "sfx"
	successful_sfx_audio_stream_player.stream = SUCCESSFUL_SFX
	successful_sfx_audio_stream_player.volume_db = -30
	get_tree().root.add_child.call_deferred(successful_sfx_audio_stream_player)
	print("successful sfx properties set")

func configure_slider_tick_audio_stream_player() -> void:
	slider_tick_sfx_audio_stream_player.bus = "sfx"
	slider_tick_sfx_audio_stream_player.stream = SUCCESSFUL_SFX
	slider_tick_sfx_audio_stream_player.volume_db = -30
	get_tree().root.add_child.call_deferred(slider_tick_sfx_audio_stream_player)
	print("slider tick sfx properties set")

func configure_character_burst_audio_stream_player() -> void:
	character_burst_sfx_audio_stream_player.bus = "sfx"
	character_burst_sfx_audio_stream_player.stream = SUCCESSFUL_SFX
	character_burst_sfx_audio_stream_player.volume_db = -40
	get_tree().root.add_child.call_deferred(character_burst_sfx_audio_stream_player)
	print("character burst sfx properties set")

func play_button_pressed_sfx() -> void:
	if button_pressed_audio_stream_player:
		button_pressed_audio_stream_player.play()
		print("button sfx playing")
		return
	print("button sfx not configured")

func play_clock_ticking_sfx() -> void:
	if clock_ticking_audio_stream_player:
		if not clock_ticking_audio_stream_player.playing:
			clock_ticking_audio_stream_player.play()
			print("playing clock tick")
			return
		return
	print("clock ticking sfx not configured")

func play_eat_pellets_sfx() -> void:
	if eat_pellets_audio_stream_player:
		if not eat_pellets_audio_stream_player.playing:
			eat_pellets_audio_stream_player.play()
			print("playing eat pellets")
			return
		return
	print("eat pellets sfx not configured")

func play_notice_ticking_sfx() -> void:
	if notice_sfx_audio_stream_player:
		if not notice_sfx_audio_stream_player.playing:
			notice_sfx_audio_stream_player.play()
			print("playing notice")
			return
		return
	print("notice sfx not configured")

func play_successful_sfx() -> void:
	if successful_sfx_audio_stream_player:
		if not successful_sfx_audio_stream_player.playing:
			successful_sfx_audio_stream_player.play()
			print("playing successful")
			return
		return
	print("successful sfx not configured")

func play_slider_tick_sfx() -> void:
	if slider_tick_sfx_audio_stream_player:
		if not slider_tick_sfx_audio_stream_player.playing:
			slider_tick_sfx_audio_stream_player.play()
			print("playing slider tick")
			return
		return
	print("slider tick sfx not configured")

func play_character_burst_sfx() -> void:
	if character_burst_sfx_audio_stream_player:
		if not character_burst_sfx_audio_stream_player.playing:
			character_burst_sfx_audio_stream_player.play()
			print("playing character burst")
			return
		return
	print("character burst sfx not configured")

func stop_clock_ticking_sfx() -> void:
	if clock_ticking_audio_stream_player:
		if clock_ticking_audio_stream_player.playing:
			clock_ticking_audio_stream_player.stop()
			print("stopped playing clock tick sfx")
		return
	print("clock ticking sfx not configured")
