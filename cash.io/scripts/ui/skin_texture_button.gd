extends TextureButton

#signal skin_button_pressed(skin_id_to_select: String)

@onready var selected_texture_rect: TextureRect = $SelectedTextureRect
@onready var skin_texture_rect: TextureRect = $SkinTextureClipTextureRect/SkinTextureRect

var skin_id: String = ""

func _ready() -> void:
	selected_texture_rect.hide()

func selected() -> void:
	selected_texture_rect.show()

func deselected() -> void:
	selected_texture_rect.hide()

func _on_pressed() -> void:
	if GlobalManager.player_selected_skin_id != skin_id:
		SfxAudioManager.play_button_pressed_sfx()
		#skin_button_pressed.emit(skin_id)
		HttpNetworkManager.request_append_user_selected_skin(skin_id)
		select_skin()

func set_texture(the_texture, id: String = "") -> void:
	skin_texture_rect.texture = the_texture
	skin_id = id

func select_skin() -> void:
	selected_texture_rect.show()

func unselect_skin() -> void:
	selected_texture_rect.hide()

func get_skin_id() -> String:
	return skin_id
