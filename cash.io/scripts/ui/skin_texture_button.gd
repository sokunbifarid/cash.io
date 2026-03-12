extends TextureButton

signal skin_button_pressed(button: TextureButton)

@onready var selected_texture_rect: TextureRect = $SelectedTextureRect

func _ready() -> void:
	selected_texture_rect.hide()

func selected() -> void:
	selected_texture_rect.show()

func deselected() -> void:
	selected_texture_rect.hide()

func _on_pressed() -> void:
	skin_button_pressed.emit(self)
	SfxAudioManager.play_button_pressed_sfx()
