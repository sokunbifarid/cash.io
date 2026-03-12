extends Node


const BUTTON_PRESSED_SFX = preload("uid://dp34nfoujypcl")
const CLOCK_TICKING_SFX = preload("uid://b5ryt4aq6sw45")

var button_pressed_audio_stream_player: AudioStreamPlayer = AudioStreamPlayer.new()
var clock_ticking_audio_stream_player: AudioStreamPlayer = AudioStreamPlayer.new()

func _ready() -> void:
	configure_button_pressed_audio_stream_player()
	configure_clock_ticking_audio_stream_player()

func configure_button_pressed_audio_stream_player() -> void:
	button_pressed_audio_stream_player.bus = "sfx"
	button_pressed_audio_stream_player.stream = BUTTON_PRESSED_SFX
	get_tree().root.add_child.call_deferred(button_pressed_audio_stream_player)
	print("button sfx properties set")

func configure_clock_ticking_audio_stream_player() -> void:
	clock_ticking_audio_stream_player.bus = "sfx"
	clock_ticking_audio_stream_player.stream = CLOCK_TICKING_SFX
	clock_ticking_audio_stream_player.volume_db = -12
	get_tree().root.add_child.call_deferred(clock_ticking_audio_stream_player)
	print("clock ticking sfx properties set")

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

func stop_clock_ticking_sfx() -> void:
	if clock_ticking_audio_stream_player:
		clock_ticking_audio_stream_player.stop()
		print("stopped playing clock tick sfx")
		return
	print("clock ticking sfx not configured")
