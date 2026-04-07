extends TextureButton

signal skin_button_pressed(skin_id_to_select: String)

@onready var selected_texture_rect: TextureRect = $SelectedTextureRect
@onready var skin_texture_rect: TextureRect = $SkinTextureClipTextureRect/SkinTextureRect

var skin_id: String = ""
var _current_active_skin_id: String = ""

func _ready() -> void:
	selected_texture_rect.hide()


#func selected(active_skin_id: String) -> void:
	#selected_texture_rect.show()
	#current_active_skin_id = active_skin_id
#
#func deselected(active_skin_id: String) -> void:
	#selected_texture_rect.hide()
	#current_active_skin_id = active_skin_id

func _on_pressed() -> void:
	if _current_active_skin_id != skin_id:
		SfxAudioManager.play_button_pressed_sfx()
		skin_button_pressed.emit(skin_id)
		HttpNetworkManager.request_append_user_selected_skin(skin_id)
		select_skin(skin_id)

func set_texture(the_texture, id: String = "") -> void:
	skin_texture_rect.texture = the_texture
	skin_id = id

func select_skin(active_skin_id: String) -> void:
	selected_texture_rect.show()
	_current_active_skin_id = active_skin_id

func unselect_skin(active_skin_id: String) -> void:
	selected_texture_rect.hide()
	_current_active_skin_id = active_skin_id

func get_skin_id() -> String:
	return skin_id
