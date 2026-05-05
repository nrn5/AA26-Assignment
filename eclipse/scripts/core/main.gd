extends Node3D

@onready var maze: MazeGenerator = $n3DMazeGenerator
@onready var alien: Node3D = $Alien
@onready var player: Node3D = $Player
@onready var ui: GameUI = $GameUI
@onready var alien_interactable = $Alien/a3DInteractionArea
@onready var interaction_ui = $InteractionUI
@onready var pause_ui = $PauseMenu
@onready var auMusicPlayer = $auMusicPlayer
@onready var brain = $Alien/Brain

func _ready():
	get_tree().paused = false
	await get_tree().process_frame

	place_player()
	place_alien()
	player.food_updated.connect(ui.update_food)
	player.request_pause.connect(_on_player_pause_requested)
	alien_interactable.request_ui.connect(_on_alien_interact)
	interaction_ui.closed.connect(_on_interaction_closed)
	brain.trust_changed.connect(_on_trust_changed)

	print("Main setup complete")
	print(auMusicPlayer.bus)

func _on_trust_changed(value: float):
	print("_on_trust_changed fired: ", value)
	ui.update_trust(value)

# PLAYER
func _on_player_pause_requested():
	if interaction_ui.visible:
		return

	if pause_ui.visible:
		pause_ui.close_pause_menu()
	else:
		pause_ui.open_pause_menu(player)
		
func _on_alien_interact(alien):
	ui.hide_hud()
	interaction_ui.open(alien)

func _on_interaction_closed():
	ui.show_hud()                 

func place_player():
	player.global_position = maze.get_open_area_center() + Vector3(0, 0, 0)

func place_alien():
	alien.global_position = maze.get_open_area_center() + Vector3(2, 0, 0)
