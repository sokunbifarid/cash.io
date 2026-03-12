extends VBoxContainer

@onready var coin_value_label: Label = $InGameCoinDataHBoxContainer/CoinValueLabel
@onready var mass_value_label: Label = $MassVBoxContainer/MassValueLabel

var coin_value: int = 0
var player_mass: int = 0

func _ready() -> void:
	set_process(false)

func _on_visibility_changed() -> void:
	if self.visible:
		set_process(true)
	else:
		set_process(false)
