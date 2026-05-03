extends Control

@onready var mouse_sn_val_lbl = $CenterContainer/Panel/mgnSettings/vbxSettingsMenu/vbxMouseSensitivity/lblMouseSnVal
@onready var music_val_lbl = $CenterContainer/Panel/mgnSettings/vbxSettingsMenu/vbxMusicVol/lblMusicVolVal
@onready var sfx_val_lbl =$CenterContainer/Panel/mgnSettings/vbxSettingsMenu/vbxSFXVol/lblSFXVolVal

signal back_pressed
var player_ref = null

# { INIT }
func _ready():
	hide()

func set_player(player):
	player_ref = player

# { MENU BTNS }
func _on_back_pressed():
	emit_signal("back_pressed")

# { MENU SLIDERS } (placeholders for now)
func _on_mouse_sensitivity_changed(value):
	if player_ref:
		player_ref.mouse_sensitivity = value
	mouse_sn_val_lbl.text = str(int(value)) + "%"

func _on_music_volumn_changed(value):
	print("Music volume:", value)
	music_val_lbl.text = str(int(value)) + "%"

func _on_sfx_volume_changed(value):
	print("SFX volume:", value)
	sfx_val_lbl.text = str(int(value)) + "%"
