extends TextureButton




func _on_pressed() -> void:
	SfxAudioManager.play_button_pressed_sfx()
