extends Control

@onready var settings_menu = $SettingsMenu
@onready var main_menu = $CenterContainer

func _ready():
	settings_menu.hide()
	settings_menu.back_pressed.connect(_on_settings_back)

# { MENU BTNS }
func _on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")

func _on_settings_pressed():
	settings_menu.show()
	main_menu.hide()

func _on_quit_pressed():
	get_tree().quit()

func _on_settings_back():
	settings_menu.hide()
	main_menu.show()
