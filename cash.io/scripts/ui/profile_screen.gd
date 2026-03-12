extends Control

signal close_profile

@onready var profile_panel: Panel = $ProfilePanel
@onready var profile_skin_panel_grid_container: GridContainer = $ProfilePanel/ProfileSorterVBoxContainer/ProfilePanel2TextureRect/ProfilePanel2ScrollContainer/ProfileSkinPanelGridContainer
@onready var profile_selected_skin_texture_rect: TextureRect = $ProfilePanel/ProfileSorterVBoxContainer/ProfilePanel1TextureRect/ProfileDataHBoxContainer/ProfileSelectedSkinTextureRect
@onready var nickname_line_edit: LineEdit = $ProfilePanel/ProfileSorterVBoxContainer/ProfilePanel1TextureRect/ProfileDataHBoxContainer/NicknameLineEdit

const SKIN_TEXTURE_BUTTON = preload("uid://dgmmmjgadl8of")
var the_visibility_tween: Tween

const TWEEN_DURATION: float = 0.25

func _ready() -> void:
	SignalManager.player_data_loaded_successfully_signal.connect(_on_player_data_loaded_successfully_signal)
	populate_skins()
	self.hide()

func _on_player_data_loaded_successfully_signal(payload: Dictionary) -> void:
	if payload.has("username"):
		nickname_line_edit.text = payload.username

func open_profile() -> void:
	GlobalManager.current_game_state = GlobalManager.GAME_STATE.PROFILE
	self.show()
	profile_panel.scale = Vector2.ZERO
	if the_visibility_tween:
		the_visibility_tween.kill()
	the_visibility_tween = create_tween()
	the_visibility_tween.tween_property(profile_panel, "scale", Vector2(1,1), TWEEN_DURATION).set_trans(Tween.TRANS_ELASTIC)


func populate_skins() -> void:
	for i in range(GlobalManager.skins_list_texture_path.size()):
		var skin: TextureButton = SKIN_TEXTURE_BUTTON.instantiate()
		profile_skin_panel_grid_container.add_child(skin)
		skin.texture_normal = ResourceLoader.load(GlobalManager.skins_list_texture_path[i])
		skin.skin_button_pressed.connect(_on_skin_button_pressed)
		if i == GlobalManager.current_selected_skin:
			skin.get_child(0).show()
		else:
			skin.get_child(0).hide()

func _on_skin_button_pressed(the_button: TextureButton) -> void:
	for i in profile_skin_panel_grid_container.get_children():
		i.deselected()
		if i == the_button:
			the_button.selected()
			profile_selected_skin_texture_rect.texture = the_button.texture_normal

func _on_submit_button_textured_pressed() -> void:
	close_profile.emit()

func _on_back_button_textured_pressed() -> void:
	close_profile.emit()
