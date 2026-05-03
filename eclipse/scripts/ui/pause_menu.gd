extends CanvasLayer

@onready var pause_menu = $Root/CenterContainer/Panel/MarginContainer/vbxPauseMenu
@onready var settings_menu = $Root/SettingsMenu

var player_ref = null

# { INIT }
func _ready():
	hide()
	# ui still works when game paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	# hide settings menu
	settings_menu.hide()

# { OPEN & CLOSE }
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
	# lock mouse back into gameplay mode
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# resume game
	get_tree().paused = false

# { MENU BTNS }
func _on_resume_pressed():
	close_pause_menu()

func _on_settings_pressed():
	pause_menu.hide()
	settings_menu.show()

func _on_restart_pressed():
	pass

func _on_quit_pressed():
	get_tree().quit()

func _on_settings_back_pressed():
	settings_menu.hide()
	pause_menu.show()
