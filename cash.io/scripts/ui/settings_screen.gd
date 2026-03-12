extends Control

signal close_settings
signal open_withdrawal

@onready var music_h_slider: HSlider = $SettingsPanelTextureRect/SettingsItemsVBoxContainer/SettingsItem1/SettingsItem1HBoxContainer/MusicVBoxContainer/MusicSliderControl/MusicHSlider
@onready var sound_effect_h_slider: HSlider = $SettingsPanelTextureRect/SettingsItemsVBoxContainer/SettingsItem1/SettingsItem1HBoxContainer/SoundEffectVBoxContainer/SoundEffectSliderControl/SoundEffectHSlider

var the_visibility_tween: Tween

const TWEEN_DURATION: float = 0.25

var music_value: int = 6
var sound_effects_value: int = 6

func _ready() -> void:
	set_sound_settings_properties()

func open_settings() -> void:
	GlobalManager.current_game_state = GlobalManager.GAME_STATE.SETTINGS
	self.show()
	self.scale = Vector2.ZERO
	if the_visibility_tween:
		the_visibility_tween.kill()
	the_visibility_tween = create_tween()
	the_visibility_tween.tween_property(self, "scale", Vector2(1,1), TWEEN_DURATION).set_trans(Tween.TRANS_ELASTIC)


func set_sound_settings_properties() -> void:
	music_value = GlobalManager.get_music_value()
	sound_effects_value = GlobalManager.get_sound_effect_value()
	music_h_slider.value = music_value
	sound_effect_h_slider.value = sound_effects_value
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("music"), music_value)
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("music"), sound_effects_value)

func prepare_to_save_settings() -> void:
	music_value = music_h_slider.value
	sound_effects_value = sound_effect_h_slider.value

func _on_settings_back_button_textured_pressed() -> void:
	close_settings.emit()

func _on_signout_button_textured_pressed() -> void:
	SignalManager.emit_signout_successful_signal()
	SignalManager.emit_notice_signal("Signout Successful")


func _on_delete_account_button_textured_pressed() -> void:
	pass # Replace with function body.


func _on_help_and_support_button_textured_pressed() -> void:
	pass # Replace with function body.


func _on_music_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("music"), value)

func _on_sound_effect_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("music"), value)


func _on_music_h_slider_drag_started() -> void:
	SfxAudioManager.play_button_pressed_sfx()


func _on_sound_effect_h_slider_drag_started() -> void:
	SfxAudioManager.play_button_pressed_sfx()


func _on_withdraw_texture_button_pressed() -> void:
	open_withdrawal.emit()
