extends CanvasLayer

@onready var pause_menu = $Root/CenterContainer/Panel/mgnPauseMenu/vbxPauseMenu
@onready var settings_menu = $Root/SettingsMenu

var player_ref = null

func _ready():
	hide()

	process_mode = Node.PROCESS_MODE_ALWAYS
	settings_menu.hide()
	settings_menu.back_pressed.connect(_on_settings_back_pressed)

# { UI CONTROL }
func open_pause_menu(player):
	player_ref = player

	show()
	pause_menu.show()
	settings_menu.hide()

	settings_menu.set_player(player_ref)

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true

func close_pause_menu():
	hide()

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false

# { BUTTONS PAUSE MENU }
func _on_resume_pressed():
	close_pause_menu()

func _on_settings_pressed():
	pause_menu.hide()
	settings_menu.show()

func _on_restart_pressed():
	await get_tree().process_frame
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_pressed():
	get_tree().quit()

# { BUTTONS SETTINGS MENU }
func _on_settings_back_pressed():
	settings_menu.hide()
	pause_menu.show()
