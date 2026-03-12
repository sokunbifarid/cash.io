extends TextureButton

signal room_button_pressed

@onready var button_icon_texture_rect: TextureRect = $ButtonSorterHBoxContainer/ButtonIconTextureRect
@onready var button_text_label: Label = $ButtonSorterHBoxContainer/ButtonTextLabel

var button_room_id: String = ""

func _ready() -> void:
	if not button_icon_texture_rect.texture:
		button_icon_texture_rect.hide()

func set_button_data(texture_address: String = "", text: String = "", id: String = "") -> void:
	button_text_label.text = text
	button_room_id = id
	if texture_address:
		button_icon_texture_rect.texture = ResourceLoader.load(texture_address)

func _on_pressed() -> void:
	room_button_pressed.emit(button_room_id)
	SfxAudioManager.play_button_pressed_sfx()
