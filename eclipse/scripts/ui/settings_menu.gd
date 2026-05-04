extends Control

@onready var mouse_sn_val_lbl = $CenterContainer/Panel/mgnSettings/vbxSettingsMenu/vbxMouseSensitivity/lblMouseSnVal
@onready var music_val_lbl = $CenterContainer/Panel/mgnSettings/vbxSettingsMenu/vbxMusicVol/lblMusicVolVal
@onready var sfx_val_lbl = $CenterContainer/Panel/mgnSettings/vbxSettingsMenu/vbxSFXVol/lblSFXVolVal

@onready var mouse_slider = $CenterContainer/Panel/mgnSettings/vbxSettingsMenu/vbxMouseSensitivity/hbxMouseSn/hslMouseSn
@onready var music_slider = $CenterContainer/Panel/mgnSettings/vbxSettingsMenu/vbxMusicVol/hbxMusicVol/hslMusicVol
@onready var sfx_slider = $CenterContainer/Panel/mgnSettings/vbxSettingsMenu/vbxSFXVol/hbxSFXVol/hslSFXVol

signal back_pressed

var player_ref = null
var _updating_ui := false

func _ready():
	hide()

# { PLAYER LINK }
func set_player(player):
	player_ref = player

	_updating_ui = true

	mouse_slider.value = player.mouse_sensitivity
	music_slider.value = get_music_volume()
	sfx_slider.value = get_sfx_volume()

	_updating_ui = false
	_update_all_labels()

func inverse_mouse_sensitivity(value: float) -> float:
	# convert 0.02–0.25 → 0–1
	return inverse_lerp(0.02, 0.25, value)

func _update_all_labels():
	mouse_sn_val_lbl.text = str(round(inverse_lerp(0.001, 0.05, mouse_slider.value) * 100.0)) + "%"
	music_val_lbl.text = str(round(music_slider.value * 100.0)) + "%"
	sfx_val_lbl.text = str(round(sfx_slider.value * 100.0)) + "%"

# { GETTERS }
func get_mouse_sensitivity() -> float:
	if player_ref:
		return player_ref.mouse_sensitivity
	return 100.0

func get_music_volume() -> float:
	var bus = AudioServer.get_bus_index("Music")
	return db_to_linear(AudioServer.get_bus_volume_db(bus))

func get_sfx_volume() -> float:
	var bus = AudioServer.get_bus_index("SFX")
	return db_to_linear(AudioServer.get_bus_volume_db(bus))

# { SETTERS }
func set_mouse_sensitivity(value: float):
	if player_ref:
		player_ref.mouse_sensitivity = value

	mouse_sn_val_lbl.text = str(round((value / 0.05) * 100.0)) + "%"

func set_music_volume(value: float):
	var bus = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(bus, linear_to_db(value))

	music_val_lbl.text = str(round(value * 100.0)) + "%"

func set_sfx_volume(value: float):
	var bus = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(bus, linear_to_db(value))

	sfx_val_lbl.text = str(round(value * 100.0)) + "%"

# { SLIDERS }
func _on_mouse_sensitivity_changed(value):
	if _updating_ui:
		return
	set_mouse_sensitivity(value)
	mouse_sn_val_lbl.text = str(round(inverse_lerp(0.001, 0.05, mouse_slider.value) * 100.0)) + "%"

func _on_music_volume_changed(value):
	if _updating_ui:
		return
	set_music_volume(value)
	music_val_lbl.text = str(round(value * 100.0)) + "%"

func _on_sfx_volume_changed(value):
	if _updating_ui:
		return
	set_sfx_volume(value)
	sfx_val_lbl.text = str(round(value * 100.0)) + "%"

# { BUTTONS }
func _on_back_pressed():
	emit_signal("back_pressed")
