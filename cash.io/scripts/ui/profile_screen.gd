extends Control

signal close_profile

@onready var profile_panel: Panel = $ProfilePanel
@onready var profile_skin_panel_grid_container: GridContainer = $ProfilePanel/ProfileSorterVBoxContainer/ProfilePanel2TextureRect/ProfilePanel2ScrollContainer/ProfileSkinPanelGridContainer
@onready var nickname_line_edit: LineEdit = $ProfilePanel/ProfileSorterVBoxContainer/ProfilePanel1TextureRect/ProfileDataHBoxContainer/NicknameLineEdit
@onready var selected_skin_texture_button: TextureButton = $ProfilePanel/ProfileSorterVBoxContainer/ProfilePanel1TextureRect/ProfileDataHBoxContainer/SkinTextureButton

const SKIN_TEXTURE_BUTTON = preload("uid://dgmmmjgadl8of")
var the_visibility_tween: Tween

var owned_skins: Array = []
const SKIN_PATH: String = "res://assets/game/character/avatars/"
const SKIN_DOMAIN: String = ".png"

const TWEEN_DURATION: float = 0.25
#var next_skin_id_to_select: String = ""

func _ready() -> void:
	SignalManager.player_data_loaded_successfully_signal.connect(_on_player_data_loaded_successfully_signal)
	#SignalManager.player_change_skin_successful.connect(_on_player_change_skin_successful)
	self.hide()

#func _on_player_change_skin_successful(condition: bool) -> void:
	#if condition:
		#for i in profile_skin_panel_grid_container.get_children():
			#if i.get_skin_id == next_skin_id_to_select:
				#i.select_skin()
				#GlobalManager.player_selected_skin_id = next_skin_id_to_select
			#else:
				#i.unselect_skin()
	#else:
		#SignalManager.emit_notice_signal("Unable to select current skin")


func _on_player_data_loaded_successfully_signal(payload: Dictionary) -> void:
	if payload.has("username"):
		nickname_line_edit.text = payload.username
	if payload.has("active_avatar"):
		set_active_skin(payload.active_avatar)
	if payload.has("owned_avatars"):
		populate_skins(payload.owned_avatars)

func open_profile() -> void:
	GlobalManager.current_game_state = GlobalManager.GAME_STATE.PROFILE
	self.show()
	profile_panel.scale = Vector2.ZERO
	if the_visibility_tween:
		the_visibility_tween.kill()
	the_visibility_tween = create_tween()
	the_visibility_tween.tween_property(profile_panel, "scale", Vector2(1,1), TWEEN_DURATION).set_trans(Tween.TRANS_ELASTIC)

func set_active_skin(skin: String) -> void:
	if skin != "":
		selected_skin_texture_button.set_texture(ResourceLoader.load(SKIN_PATH + skin + SKIN_DOMAIN))
		selected_skin_texture_button.unselect_skin()
		GlobalManager.player_selected_skin_id = skin

func populate_skins(avatars: Array) -> void:
	if profile_skin_panel_grid_container.get_child_count() > 0:
		for j in profile_skin_panel_grid_container.get_children():
			j.queue_free()
	for i in avatars:
		var skin: TextureButton = SKIN_TEXTURE_BUTTON.instantiate()
		profile_skin_panel_grid_container.add_child(skin)
		skin.set_texture(ResourceLoader.load(SKIN_PATH + i + SKIN_DOMAIN), i)
		#skin.skin_button_pressed.connect(_on_skin_button_pressed)
		if GlobalManager.player_selected_skin_id == i:
			skin.select_skin()
		else:
			skin.unselect_skin()

func _on_submit_button_textured_pressed() -> void:
	close_profile.emit()

func _on_back_button_textured_pressed() -> void:
	close_profile.emit()

#func _on_skin_button_pressed(sender_skin_id: String) -> void:
	#next_skin_id_to_select = sender_skin_id
