extends Button

signal room_button_pressed

@onready var button_icon_texture_rect: TextureRect = $RoomButtonTextureRect/ButtonSorterHBoxContainer/ButtonIconTextureRect
@onready var button_text_label: Label = $RoomButtonTextureRect/ButtonSorterHBoxContainer/ButtonTextLabel

var button_room_id: String = ""

const GOTHAM_BOLD = preload("uid://b8rkdk37wxds1")

func _ready() -> void:
	if not button_icon_texture_rect.texture:
		button_icon_texture_rect.hide()

func set_button_data(texture_address: String = "", text: String = "", id: String = "") -> void:
	var new_label_settings: LabelSettings = LabelSettings.new()
	new_label_settings.font = GOTHAM_BOLD
	new_label_settings.font_size = 12
	button_text_label.text = text
	button_room_id = id
	if texture_address:
		button_icon_texture_rect.texture = ResourceLoader.load(texture_address)
	if button_text_label.text.length() < 10:
		new_label_settings.font_size = 12
	else:
		new_label_settings.font_size = 8
	button_text_label.label_settings = new_label_settings

func _on_pressed() -> void:
	room_button_pressed.emit(button_room_id)
	SfxAudioManager.play_button_pressed_sfx()
